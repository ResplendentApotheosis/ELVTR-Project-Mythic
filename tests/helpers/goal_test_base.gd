# Base class for the GoalTracker tests: loads GoalTracker / BoosterService by path (so a missing
# class makes a test FAIL with a clear message instead of breaking the whole file) and builds
# small boards. Contract: tests/API_CONTRACT.md section 10. Check: run the GoalTracker tests.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")
const TRACKER_PATH: String = "res://src/goals/goal_tracker.gd"
const BOOSTER_PATH: String = "res://src/boosters/booster_service.gd"


## A GoalTracker for these goals, attached to the board (board.goal_tracker). Null (and a failed
## test) if the class or the board field does not exist yet.
func track(board: BoardModel, goals: Array, level: int = 12) -> Variant:
	if not ResourceLoader.exists(TRACKER_PATH):
		fail_test("GoalTracker missing: " + TRACKER_PATH + " (API_CONTRACT.md section 10)")
		return null
	var script: GDScript = load(TRACKER_PATH)
	var tracker: Variant = script.new(goals, level)
	board.set("goal_tracker", tracker)
	if board.get("goal_tracker") != tracker:
		fail_test("BoardModel.goal_tracker is missing (API_CONTRACT.md section 10)")
		return null
	return tracker


## Like track(), for a level with an OB04 (dew) goal. Set the seeds (dew) on the board BEFORE calling this.
## Needs the new GoalTracker.attach(board) (API_CONTRACT.md 10.8): afterwards goal_units_done of the
## dew goal = the playable cells that have dew on that board now (seed cells counted from the start,
## OQ-66), kept up to date as the board changes. Fails the test if attach() is missing.
func track_dew(board: BoardModel, goals: Array, level: int = 12) -> Variant:
	var t: Variant = track(board, goals, level)
	if t == null:
		return null
	if not t.has_method("attach"):
		fail_test("GoalTracker.attach(board) is missing (API_CONTRACT.md 10.8)")
		return null
	t.attach(board)
	return t


## A tracker that is not attached to a board (flow tests: lives, coins, offers).
func loose_tracker(goals: Array, level: int = 12) -> Variant:
	if not ResourceLoader.exists(TRACKER_PATH):
		fail_test("GoalTracker missing: " + TRACKER_PATH + " (API_CONTRACT.md section 10)")
		return null
	var script: GDScript = load(TRACKER_PATH)
	return script.new(goals, level)


## Calls a static GoalTracker function (coins, validators). Returns null and fails if missing.
func tracker_static(fn: String, args: Array) -> Variant:
	if not ResourceLoader.exists(TRACKER_PATH):
		fail_test("GoalTracker missing: " + TRACKER_PATH)
		return null
	var script: GDScript = load(TRACKER_PATH)
	if not script.has_method(fn):
		fail_test("GoalTracker.%s() is missing" % fn)
		return null
	var result: Variant = script.callv(fn, args)
	if result == null:
		fail_test("GoalTracker.%s() returned null (wrong arguments or not implemented?)" % fn)
	return result


## Calls a static BoosterService function. Returns null and fails if missing.
func booster(fn: String, args: Array) -> Variant:
	if not ResourceLoader.exists(BOOSTER_PATH):
		fail_test("BoosterService missing: " + BOOSTER_PATH + " (API_CONTRACT.md section 10)")
		return null
	var script: GDScript = load(BOOSTER_PATH)
	if not script.has_method(fn):
		fail_test("BoosterService.%s() is missing" % fn)
		return null
	return script.callv(fn, args)


func units(tracker: Variant, index: int) -> int:
	return int(tracker.goal_units_done(index))


## Sets up a 3-in-a-row swap on a board: R at (cx-1,cy) and (cx+1,cy), Y at (cx,cy), R at (cx,cy+1); the
## cells around become unique fillers so nothing else can match. Returns the swap's [from, to].
func prime_row_match(board: BoardModel, cx: int, cy: int) -> Array[Vector2i]:
	for d in [[-2, 0], [2, 0], [-1, 1], [1, 1], [0, 2], [-1, -1], [0, -1], [1, -1]]:
		var x: int = cx + int(d[0])
		var y: int = cy + int(d[1])
		if board.is_playable(x, y) and board.content_id(x, y) == "":
			board.set_piece(x, y, "plain", "z%d_%d" % [x, y])
	board.set_piece(cx - 1, cy, "plain", "R")
	board.set_piece(cx + 1, cy, "plain", "R")
	board.set_piece(cx, cy, "plain", "Y")
	board.set_piece(cx, cy + 1, "plain", "R")
	return [Vector2i(cx, cy + 1), Vector2i(cx, cy)]


## Primes the match and makes the swap. Returns the events.
func swap_row_match(board: BoardModel, cx: int, cy: int) -> Array[BoardEvent]:
	var pair: Array[Vector2i] = prime_row_match(board, cx, cy)
	return MatchResolver.swap(board, pair[0], pair[1])


## Board for IR-56 / IR-57 / IR-32: the swap (2,8)->(3,8) clears R at (3,6),(3,7),(3,8) (touches no
## obstacle); column 3 falls by 3 so the G from (3,3) lands in (3,6) and forms a G line
## (3,6),(4,6),(5,6) with (5,6) next to (6,6): a cascade match. Swap with swap_cascade().
func cascade_board(moves: int) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.moves = moves
	BB.put(board, "R", [[3, 6], [3, 7], [2, 8]])
	BB.put(board, "Y", [[3, 8]])
	BB.put(board, "G", [[3, 3], [4, 6], [5, 6]])
	return board


func swap_cascade(board: BoardModel) -> Array[BoardEvent]:
	return MatchResolver.swap(board, Vector2i(2, 8), Vector2i(3, 8))


func has_type(events: Array, type: String) -> bool:
	return EV.count(events, type) > 0


## Index of the last event of any of these types, or -1.
func last_index_of_any(events: Array, types: Array) -> int:
	var found: int = -1
	for i in range(events.size()):
		if types.has(events[i].type):
			found = i
	return found


func obstacle_goal(id: String, count: int, fragment: bool = false) -> Dictionary:
	var g: Dictionary = {"obstacle": id, "count": count}
	if fragment:
		g["fragment"] = true
	return g
