# Keeps one attempt's goals (obstacle goals and the fragment goal), the continue offers and the life lost
# on a fail (IR-56, IR-57, IR-59, IR-60, IR-61, IR-31, IR-37). Pure logic: it reads events, never animates.
# Check: run the GUT suite; tests/goal_tracker/ covers it (API: tests/API_CONTRACT.md section 10).
class_name GoalTracker
extends RefCounted

const FRAGMENT_LEVELS: Array[int] = [26, 30, 33, 35, 38, 40, 45, 50]
const FINALE_LEVELS: Array[int] = [25, 50]   # a fail costs no life here (IR-60)
const MAX_OFFERS: int = 5                    # continue offers per attempt (IR-37)
const FIRST_OFFER_PRICE: int = 300
const LATER_OFFER_PRICE: int = 500
const OFFER_MOVES: int = 5
const WIN_COINS: int = 20                    # IR-16: 20 + 5 per finale Rocket
const COINS_PER_ROCKET: int = 5
# How many goals each tier may have: [fewest, most] (IR-59). The fragment entry counts inside these.
const TIER_GOALS: Dictionary = {
	"intro": [1, 1], "easy": [1, 2], "medium": [2, 3], "hard": [3, 4], "finale": [4, 4],
}

var lives: int = 5
var coins: int = 0
var level: int = 1

var _goals: Array = []          # the goal dictionaries, e.g. {"obstacle": "OB07", "count": 1, "fragment": true}
var _done: Array[int] = []      # units finished per goal
var _offers_accepted: int = 0
var _offer_price: int = 0       # price of the offer on screen now; 0 = none
var _failed: bool = false       # the attempt has ended in a fail (a life is lost only once)
var _board_ref: WeakRef = null   # set by attach(); dew goal progress is read from that board (OQ-66).
                                # Weak, because the board also holds this tracker (no memory loop).

# Bookkeeping for one MatchResolver / BoosterService call (see GoalHook).
var _fed: int = 0               # events of the current call already passed to observe()
var _won_at_start: bool = false
var _holding: bool = false   # true while one hit is applied (see hold_announce)
var _held_at: int = -1       # event position where the first goal finished during the hold
var _announced: Array[bool] = []   # goals whose `goal_done` event was already sent (IR-56)


func _init(goals: Array, level_number: int = 1) -> void:
	level = level_number
	for g in goals:
		_goals.append(g)
		_done.append(0)
		_announced.append(false)


# ---------------------------------------------------------------- goals

## Reads one board event and adds goal units (IR-61, IR-31). A goal never goes above its count.
func observe(event: BoardEvent) -> void:
	match event.type:
		"obstacle_cleared":
			_add_plain(String(event.data.get("id", "")))
		"shrine_lit":
			_add_plain("OB05")
		"collected":
			var item: String = String(event.data.get("item", ""))
			if item == "fragment":
				_add_fragment()
				_add_plain(String(event.data.get("carrier", "")))   # IR-31: also counts for a plain goal
			else:
				_add_plain(item)


## Owner decision, chat 28 Nov 2026 › OQ-66 A (trial): a dew (OB04) goal's progress is read from the
## board itself, so call this once when the attempt starts (LevelLoader does). Other goals ignore it.
func attach(board: BoardModel) -> void:
	_board_ref = weakref(board)


## Units done for goals[index]. A dew goal on an attached board = playable cells with dew right now
## (seed cells included, each cell once), capped at the count (what to show past it is OQ-73).
func goal_units_done(index: int) -> int:
	var board: BoardModel = _attached_board()
	if board != null and String(_goals[index].get("obstacle", "")) == "OB04" and not _is_fragment_goal(index):
		return mini(GoalCountCheck.dew_cells(board), goal_units_total(index))
	return _done[index]


## The board given to attach(), or null (never attached, or already freed).
func _attached_board() -> BoardModel:
	if _board_ref == null:
		return null
	return _board_ref.get_ref() as BoardModel


func goal_units_total(index: int) -> int:
	return int(_goals[index].get("count", 0))


func is_goal_done(index: int) -> bool:
	return goal_units_done(index) >= goal_units_total(index)


## True when every goal is done, the fragment goal included (IR-56, IR-31).
func is_won() -> bool:
	for i in range(_goals.size()):
		if not is_goal_done(i):
			return false
	return true


func _add_plain(id: String) -> void:
	if id == "":
		return
	for i in range(_goals.size()):
		if not _is_fragment_goal(i) and String(_goals[i].get("obstacle", "")) == id:
			_add_unit(i)


func _add_fragment() -> void:
	for i in range(_goals.size()):
		if _is_fragment_goal(i):
			_add_unit(i)


func _add_unit(index: int) -> void:
	_done[index] = mini(_done[index] + 1, goal_units_total(index))


func _is_fragment_goal(index: int) -> bool:
	return bool(_goals[index].get("fragment", false))


## How many goals this attempt has.
func goal_count() -> int:
	return _goals.size()


## The goal's id: its obstacle id (e.g. "OB02"), or "fragment" for the fragment goal.
func goal_id(index: int) -> String:
	return "fragment" if _is_fragment_goal(index) else String(_goals[index].get("obstacle", ""))


## An independent copy of this tracker (goals, progress, offers, lives, coins) that watches `board`
## instead: it becomes board.goal_tracker, and a dew goal reads `board`. Used to try a move on a copy.
func copy_for(board: BoardModel) -> GoalTracker:
	var t: GoalTracker = GoalTracker.new(_goals.duplicate(true), level)
	t._done = _done.duplicate()
	t._announced = _announced.duplicate()
	t.lives = lives
	t.coins = coins
	t._offers_accepted = _offers_accepted
	t._offer_price = _offer_price
	t._failed = _failed
	if _board_ref != null:
		t.attach(board)
	board.goal_tracker = t
	return t


# ---------------------------------------------------------------- continue offers and lives

## The resolver calls this when moves reach 0 and the level is not won (IR-57). Offers 1-5 are shown
## (300, then 500 coins); the 6th time there is no offer and the attempt is a fail (IR-37, IR-60).
func moves_ran_out(_board: BoardModel) -> void:
	if _offers_accepted < MAX_OFFERS:
		_offer_price = FIRST_OFFER_PRICE if _offers_accepted == 0 else LATER_OFFER_PRICE
	else:
		_end_in_fail()


## Price of the continue offer shown now; 0 = no offer.
func offer_price() -> int:
	return _offer_price


## Pays for the offer and adds 5 moves. False (and nothing changes) with no offer or too few coins.
func accept_offer(board: BoardModel) -> bool:
	if _offer_price <= 0 or coins < _offer_price:
		return false
	coins -= _offer_price
	board.moves += OFFER_MOVES
	_offers_accepted += 1
	_offer_price = 0
	return true


## The player said no to the offer: the attempt ends in a fail (IR-37, IR-60).
func decline_offer() -> void:
	_end_in_fail()


## Quitting mid-level is a fail with no offer (IR-38, IR-60).
func quit() -> void:
	_end_in_fail()


## One life lost per attempt at most, and none on chapter finales (IR-60).
func _end_in_fail() -> void:
	_offer_price = 0
	if _failed:
		return
	_failed = true
	if not FINALE_LEVELS.has(level):
		lives -= 1


# ---------------------------------------------------------------- per-call bookkeeping (used by GoalHook)

## Called at the start of each resolver or booster call.
func begin_call() -> void:
	_fed = 0
	_won_at_start = is_won()
	for i in range(_goals.size()):
		if is_goal_done(i):
			_announced[i] = true   # already done before this call: never announced again


## Observes the events of this call not seen yet. True if this call has just won the level.
func feed(events: Array[BoardEvent]) -> bool:
	while _fed < events.size():
		observe(events[_fed])
		_fed += 1
	return just_won()


func just_won() -> bool:
	return is_won() and not _won_at_start


# ---------------------------------------------------------------- static checks (LevelLoader, validator)

## Coins for a win: 20 + 5 per finale Rocket (IR-16, IR-56).
static func win_coins(finale_rockets: int) -> int:
	return WIN_COINS + COINS_PER_ROCKET * finale_rockets


## Problems with a level's goal list; [] = valid (IR-59 tier counts, IR-61 no colour goals, IR-31 fragment).
static func goal_errors(level_number: int, tier: String, goals: Array) -> Array:
	var errors: Array = []
	if not TIER_GOALS.has(tier):
		errors.append("unknown tier '%s'" % tier)
	else:
		var limits: Array = TIER_GOALS[tier]
		if goals.size() < int(limits[0]) or goals.size() > int(limits[1]):
			errors.append("a %s level needs %d-%d goals, found %d" % [tier, limits[0], limits[1], goals.size()])
	var has_fragment: bool = false
	for g in goals:
		if g.has("color") or g.has("colour"):
			errors.append("colour goals are not allowed (IR-61): %s" % [g])
		elif not g.has("obstacle"):
			errors.append("goal has no obstacle id: %s" % [g])
		if bool(g.get("fragment", false)):
			has_fragment = true
	if FRAGMENT_LEVELS.has(level_number) and not has_fragment:
		errors.append("level %d is a fragment level but has no fragment goal (IR-31)" % level_number)
	return errors


## Problems where a goal's count differs from what the level places (IR-61, IR-31, OQ-66, OQ-71); [] = valid.
## `spawn` = the level file's "spawn" object. See GoalCountCheck.
static func goal_count_errors(goals: Array, board: BoardModel, spawn: Dictionary = {}) -> Array:
	return GoalCountCheck.errors(goals, board, spawn)


## How many units of this obstacle id are on the board.
static func count_placed(board: BoardModel, id: String) -> int:
	return GoalCountCheck.count_placed(board, id)


# ---------------------------------------------------------------- goal done events (IR-56)

## Reads the events so far and, for each goal that has just reached its count, appends one `goal_done`
## event (data.goal = index, data.id, data.fragment) at the end of `events`. Never repeats a goal.
## Call it right after an event that can finish a goal, so the new event follows it immediately.
func announce(events: Array[BoardEvent]) -> void:
	feed(events)
	if _holding:
		# One hit is still going: remember where the first goal finished, announce at release_hold().
		if _held_at < 0 and _has_new_done_goal():
			_held_at = events.size()
		return
	_emit_goal_done(events, events.size())


## IR-56: while one hit (a special's cover) is being applied, goals that finish are held back so
## that two or more can be announced together, in goal-bar order.
func hold_announce() -> void:
	_holding = true
	_held_at = -1


## Ends the hold. One new goal is announced right after its own event; two or more together at the
## end of the events, sorted by goal index.
func release_hold(events: Array[BoardEvent]) -> void:
	feed(events)
	_holding = false
	if _held_at < 0:
		return
	var at: int = events.size()
	if _new_done_goals().size() == 1:
		at = _held_at
	_held_at = -1
	_emit_goal_done(events, at)


func _new_done_goals() -> Array[int]:
	var out: Array[int] = []
	for i in range(_goals.size()):
		if not _announced[i] and is_goal_done(i):
			out.append(i)
	return out


func _has_new_done_goal() -> bool:
	return not _new_done_goals().is_empty()


## Inserts one goal_done per newly finished goal (index order) starting at position `at`.
func _emit_goal_done(events: Array[BoardEvent], at: int) -> void:
	for i in _new_done_goals():
		_announced[i] = true
		var e: BoardEvent = BoardEvent.new("goal_done")
		if not events.is_empty():
			e.cell = events[maxi(at - 1, 0)].cell
		e.data = {"goal": i, "id": goal_id(i), "fragment": _is_fragment_goal(i)}
		if at < _fed:
			_fed += 1   # inserted before the end of what was already fed
		events.insert(at, e)
		at += 1
