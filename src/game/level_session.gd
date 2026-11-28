# Runs one level from start to win or fail by calling the real modules in the right order: LevelLoader
# (build, retry), SaveService (open, sync, close the attempt), MatchResolver (swap, tap, finale) and
# GoalTracker (continue offers). It never decides a rule itself and never animates: it returns the events.
# The save says yes first, then the board is built once (with any pre-level / chest specials). Debug-only
# shortcuts (jump to level, play again, debug moves) work only when DebugGate is on.
# Check: GUT tests for LevelSession (test-engineer); F5 plays the greybox scene, which drives it.
class_name LevelSession
extends RefCounted

const NOT_STARTED: String = "not_started"   # no attempt yet (or the file did not load)
const PLAYING: String = "playing"           # the player can swap and tap
const OFFER: String = "offer"               # moves ran out: the continue offer is on screen (IR-37)
const WON: String = "won"                   # the level was won and the finale has fired (IR-16, IR-56)
const RETRY: String = "retry"               # the attempt failed, or the save refused to start one (IR-37, IR-81)
## IR-88 / OQ-97 A: the exact words the player sees when a level's board can't be built.
const BUILD_FAILED_NOTICE: String = "This level couldn't be loaded"

var state: String = NOT_STARTED
var attempt: LevelAttempt = null
var last_error: String = ""      # why the last start / retry did not work ("" = it worked); technical text
var notice: String = ""          # the message the player sees ("" normally); set when the board can't build
var win_coins: int = 0           # coins the win paid (20 + 5 per finale Rocket, IR-16)
var finale_rockets: int = 0      # moves left at the win
var debug_enabled: bool = DebugGate.enabled()   # debug shortcuts allowed? (never in a release build)
var debug_moves: int = 0         # debug only: moves for the NEXT start or retry (0 = the file's moves)

var _save: SaveService
var _level_path: String
var _level_id: int = 0           # read from the file, so the retry screen knows the level even with no board


func _init(level_path: String, save: SaveService) -> void:
	_level_path = level_path
	_save = save


# ---------------------------------------------------------------- starting

## Opens a new attempt in the save, then builds its board once. `options` go to LevelLoader (e.g.
## {"seed": 1234}), except "pre_boosters" (e.g. ["firecracker"]), which goes to the save.
## False if the file did not load or the save refused (then see last_error).
func start(options: Dictionary = {}) -> bool:
	if _attempt_open():
		last_error = "an attempt is already running"
		return false
	return _begin(options, false)


## IR-58 / IR-71: a new attempt built again from the level file with a new seed. Only from the retry
## screen. Takes the same options as start().
func retry(options: Dictionary = {}) -> bool:
	if state != RETRY:
		last_error = "retry is only possible from the retry screen"
		return false
	return _begin(options, true)


## The order (owner, 28 Nov 2026): the save decides the attempt (IR-79, IR-81, IR-83, IR-84); only if it
## says yes is the board built, once, with the specials it handed back (IR-77); then the tracker is bound.
func _begin(options: Dictionary, is_retry: bool) -> bool:
	notice = ""
	_level_id = _read_level_id()
	if _level_id <= 0:
		last_error = "could not load %s" % _level_path
		state = NOT_STARTED
		return false
	var opts: Dictionary = options.duplicate()
	var pre_boosters: Array = LevelLoader.array_of(opts.get("pre_boosters", []))
	opts.erase("pre_boosters")
	var result: Dictionary = _save.start_attempt(_level_id, null, pre_boosters)
	if not bool(result.get("ok", false)):
		last_error = "the save refused to start level %d (%s)" % [_level_id, result.get("reason", "")]
		state = RETRY
		return false
	opts["pre_specials"] = result.get("pre_specials", [])
	var built: LevelAttempt = null
	if is_retry and attempt != null:
		built = LevelLoader.retry(attempt, opts)   # a new seed unless the caller gave one
	else:
		built = LevelLoader.load_file(_level_path, opts)
	if built == null:
		# IR-88: the board did not build (e.g. moves 0, a broken board): cancel the attempt and put the
		# save back as it was. Not a quit: no life lost, no first try used, nothing logged. The player
		# goes back to the screen they started from (a retry keeps the old attempt for its next seed).
		_save.cancel_attempt()
		last_error = "could not build %s %s" % [_level_path, LevelLoader.last_errors]
		notice = BUILD_FAILED_NOTICE
		if is_retry:
			state = RETRY
		else:
			attempt = null
			state = NOT_STARTED
		return false
	if debug_enabled and debug_moves > 0:
		built.board.moves = debug_moves   # debug only: changes the starting moves, nothing else
	_save.bind_tracker(built.tracker)
	attempt = built
	last_error = ""
	win_coins = 0
	finale_rockets = 0
	state = PLAYING
	return true


## The level's id from its file (0 if the file is missing or not a level).
func _read_level_id() -> int:
	var level: Variant = LevelLoader.read_level_file(_level_path)
	if not level is Dictionary:
		return 0
	return LevelLoader.as_int((level as Dictionary).get("id"), 0)


# ---------------------------------------------------------------- debug shortcuts (debug builds only)

## Debug only: makes `level` (1-50) the save's next level. False, and nothing touched, with the gate off.
func debug_jump_to_level(level: int) -> bool:
	if not debug_enabled or level < 1 or level > 50:
		return false
	_save.debug_set({"next_level": level})
	return true


## Debug only: moves the save back to this level and starts it again. False with the gate off.
func debug_play_again(options: Dictionary = {}) -> bool:
	if not debug_enabled:
		return false
	var id: int = _read_level_id()
	if not debug_jump_to_level(id):
		return false
	return start(options)


## Debug only: the moves the next start or retry gets (0 or less = off, the file's moves).
func set_debug_moves(n: int) -> void:
	debug_moves = maxi(n, 0)


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
	return attempt.level_id if attempt != null else _level_id


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
