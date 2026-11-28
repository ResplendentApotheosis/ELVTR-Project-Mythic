# Connects MatchResolver and BoosterService to the board's GoalTracker (board.goal_tracker; null = do nothing).
# Owner decision, chat 28 Nov 2026 › OQ-72: the winning move always plays out in full; at the end of the
# call this feeds the tracker every event and adds `win` (or `fail`) as the LAST event (IR-56, IR-57).
# Check: tests/goal_tracker/test_win_and_fail.gd.
class_name GoalHook
extends RefCounted


## Call at the start of a swap, tap, settle, finale or booster.
static func begin(board: BoardModel) -> void:
	if board.goal_tracker != null:
		board.goal_tracker.begin_call()


## Call at the end of a call, once the board has settled. Adds `win` if this call won the level
## (data.moves_left = finale Rockets), else, when `can_fail` and no moves are left, tells the tracker
## and adds `fail` (data.offer_price).
static func finish(board: BoardModel, events: Array[BoardEvent], can_fail: bool) -> void:
	var tracker: GoalTracker = board.goal_tracker
	if tracker == null:
		return
	if tracker.feed(events):
		var win: BoardEvent = BoardEvent.new("win")
		win.data = {"moves_left": board.moves}
		events.append(win)
	elif can_fail and board.moves <= 0 and not tracker.is_won():
		tracker.moves_ran_out(board)
		var fail: BoardEvent = BoardEvent.new("fail")
		fail.data = {"offer_price": tracker.offer_price()}
		events.append(fail)
	tracker.feed(events)   # the win / fail event is passed on too (the tracker ignores it)


## Call right after an event that can finish a goal (obstacle_cleared, collected, shrine_lit, a dew spread):
## appends a `goal_done` event straight after it when that event reached a goal's count (IR-56).
static func announce(board: BoardModel, events: Array[BoardEvent]) -> void:
	if board.goal_tracker != null:
		board.goal_tracker.announce(events)
