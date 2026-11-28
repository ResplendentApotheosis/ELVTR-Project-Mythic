# Runs one level from start to win or fail by calling the real modules in the right order: LevelLoader
# (build, retry), SaveService (open, sync, close the attempt), MatchResolver (swap, tap, finale) and
# GoalTracker (continue offers). It never decides a rule itself and never animates: it returns the events.
# Check: GUT tests for LevelSession (test-engineer); F5 plays the greybox scene, which drives it.
class_name LevelSession
extends RefCounted

const NOT_STARTED: String = "not_started"   # no attempt yet (or the file did not load)
const PLAYING: String = "playing"           # the player can swap and tap
const OFFER: String = "offer"               # moves ran out: the continue offer is on screen (IR-37)
const WON: String = "won"                   # the level was won and the finale has fired (IR-16, IR-56)
const RETRY: String = "retry"               # the attempt failed, or the save refused to start one (IR-37, IR-81)

var state: String = NOT_STARTED
var attempt: LevelAttempt = null
var last_error: String = ""      # why the last start / retry did not work ("" = it worked)
var win_coins: int = 0           # coins the win paid (20 + 5 per finale Rocket, IR-16)
var finale_rockets: int = 0      # moves left at the win

var _save: SaveService
var _level_path: String


func _init(level_path: String, save: SaveService) -> void:
	_level_path = level_path
	_save = save


# ---------------------------------------------------------------- starting

## Builds a fresh attempt from the level file and opens it in the save. `options` go to LevelLoader
## (e.g. {"seed": 1234}). False if the file did not load or the save refused (then see last_error).
func start(options: Dictionary = {}) -> bool:
	if _attempt_open():
		last_error = "an attempt is already running"
		return false
	var built: LevelAttempt = LevelLoader.load_file(_level_path, options)
	if built == null:
		last_error = "could not load %s %s" % [_level_path, LevelLoader.last_errors]
		state = NOT_STARTED
		return false
	return _open(built)


## IR-58 / IR-71: a new attempt rebuilt from the level file with a new seed (LevelLoader.retry), then
## opened in the save. Only from the retry screen.
func retry(options: Dictionary = {}) -> bool:
	if state != RETRY or attempt == null:
		last_error = "retry is only possible from the retry screen"
		return false
	var built: LevelAttempt = LevelLoader.retry(attempt, options)
	if built == null:
		last_error = "could not rebuild %s %s" % [_level_path, LevelLoader.last_errors]
		return false
	return _open(built)


## Opens `built` in the save (IR-79, IR-81). The save may hand back pre-level or streak-chest specials
## (IR-77, IR-84); the board is then rebuilt with the same seed plus those specials.
func _open(built: LevelAttempt) -> bool:
	var result: Dictionary = _save.start_attempt(built.level_id, built.tracker)
	attempt = built
	if not bool(result.get("ok", false)):
		last_error = "the save refused to start level %d (%s)" % [built.level_id, result.get("reason", "")]
		state = RETRY
		return false
	var specials: Array = result.get("pre_specials", [])
	if not specials.is_empty():
		attempt = _with_specials(built, specials)
	last_error = ""
	win_coins = 0
	finale_rockets = 0
	state = PLAYING
	return true


## Same level, same seed, plus the specials; keeps the tracker the save already holds.
func _with_specials(built: LevelAttempt, specials: Array) -> LevelAttempt:
	var opts: Dictionary = {"seed": built.seed_value, "pre_specials": specials}
	var again: LevelAttempt = null
	if built.source_path != "":
		again = LevelLoader.load_file(built.source_path, opts)
	else:
		again = LevelLoader.load_level(built.level, opts)
	if again == null:
		last_error = "could not place %s %s" % [specials, LevelLoader.last_errors]
		return built
	again.tracker = built.tracker
	again.board.goal_tracker = built.tracker
	if LevelLoader.has_dew_goal(again.level):
		built.tracker.attach(again.board)
	return again


# ---------------------------------------------------------------- moves

## The player drags `from` into `to`. Returns every event to play (an empty list when not playing).
## A winning move also returns the finale's events (fire_finale), after the `win` event.
func swap(from: Vector2i, to: Vector2i) -> Array[BoardEvent]:
	if state != PLAYING:
		return [] as Array[BoardEvent]
	var events: Array[BoardEvent] = MatchResolver.swap(attempt.board, from, to)
	_after_move(events)
	return events


## The player taps a cell (IR-02). Tapping a non-special returns no events and uses no move.
func tap(cell: Vector2i) -> Array[BoardEvent]:
	if state != PLAYING:
		return [] as Array[BoardEvent]
	var events: Array[BoardEvent] = MatchResolver.tap(attempt.board, cell)
	_after_move(events)
	return events


## Reads the last event: `win` -> finale, coins, save (IR-16, IR-56); `fail` -> offer or retry (IR-37, IR-57).
func _after_move(events: Array[BoardEvent]) -> void:
	if events.is_empty():
		return
	var last: BoardEvent = events.back()
	if last.type == "win":
		finale_rockets = int(last.data.get("moves_left", 0))
		events.append_array(MatchResolver.fire_finale(attempt.board))
		win_coins = GoalTracker.win_coins(finale_rockets)
		_save.end_attempt("win", finale_rockets)
		state = WON
	elif last.type == "fail":
		if int(last.data.get("offer_price", 0)) > 0:
			state = OFFER
		else:
			# 6th run-out: the tracker has already ended the attempt as a fail (IR-37, IR-60).
			_save.end_attempt("fail")
			state = RETRY


# ---------------------------------------------------------------- continue offer (IR-37)

## Price of the offer on screen (300, then 500); 0 when there is none.
func offer_price() -> int:
	return attempt.tracker.offer_price() if state == OFFER else 0


func can_accept_offer() -> bool:
	return state == OFFER and attempt.tracker.coins >= offer_price()


## IR-37: "you have less than N coins" when the player can't pay; "" otherwise.
func offer_message() -> String:
	if state != OFFER or can_accept_offer():
		return ""
	return "you have less than %d coins" % offer_price()


## Pays for +5 moves (GoalTracker) and writes the coins to the save at once (IR-38). False if refused.
func accept_offer() -> bool:
	if state != OFFER:
		return false
	if not attempt.tracker.accept_offer(attempt.board):
		return false
	_save.sync_attempt()
	state = PLAYING
	return true


## Ends the attempt as a fail (a life lost, IR-60) and goes to the retry screen.
func decline_offer() -> void:
	if state != OFFER:
		return
	attempt.tracker.decline_offer()
	_save.end_attempt("fail")
	state = RETRY


# ---------------------------------------------------------------- retry screen (IR-81)

## ["retry"], or ["wait", "buy_lives"] at 0 lives (SaveService.retry_choices).
func retry_choices() -> Array:
	return _save.retry_choices(level_id())


## Buy all 5 lives for 150 coins (SaveService.buy_all_lives): {"ok": true} or {"ok": false, "reason", "message"}.
func buy_lives() -> Dictionary:
	return _save.buy_all_lives()


# ---------------------------------------------------------------- what the HUD shows

func board() -> BoardModel:
	return attempt.board if attempt != null else null


func level_id() -> int:
	return attempt.level_id if attempt != null else 0


func moves_left() -> int:
	return attempt.board.moves if attempt != null else 0


## While an attempt is open the tracker holds the live balance (a continue spends it there); else the save.
func coins() -> int:
	if _attempt_open():
		return attempt.tracker.coins
	return _save.coins()


func lives() -> int:
	return _save.lives()


## One entry per goal: {"id": "OB06", "fragment": bool, "done": int, "total": int}.
func goal_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if attempt == null:
		return rows
	var goals: Array = LevelLoader.goal_list(attempt.level)
	for i in range(goals.size()):
		var g: Dictionary = goals[i]
		rows.append({
			"id": String(g.get("obstacle", "")),
			"fragment": bool(g.get("fragment", false)),
			"done": attempt.tracker.goal_units_done(i),
			"total": attempt.tracker.goal_units_total(i),
		})
	return rows


func _attempt_open() -> bool:
	return state == PLAYING or state == OFFER
