# GUT tests for the IR-56 "goal done" event (added 28 Nov 2026): one `goal_done` event per goal, emitted
# right after the event that reached the count and before the rest of the move. API: tests/API_CONTRACT.md 10.9.
# Check: run the GoalTracker tests; every test here needs MatchResolver to append `goal_done` events.
extends "res://tests/helpers/goal_test_base.gd"


func _goal_ids(events: Array) -> Array:
	var out: Array = []
	for e in EV.of_type(events, "goal_done"):
		out.append(int(e.data.get("goal", -1)))
	return out


func _creature_board(moves: int, x: int = 2, y: int = 3) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = moves
	board.add_content("OB07", x, y, 1)
	return board


func test_ir56_goal_done_event_comes_after_the_clear_and_before_the_fall_and_the_win() -> void:
	var board: BoardModel = _creature_board(10)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(events, "goal_done"), 1, "exactly one goal done event")
	assert_eq(_goal_ids(events), [0], "it names goal index 0")
	var i_freed: int = EV.index_of(events, "obstacle_cleared")
	var i_goal: int = EV.index_of(events, "goal_done")
	var i_fall: int = EV.index_of(events, "fall")
	var i_win: int = EV.index_of(events, "win")
	assert_true(i_freed >= 0 and i_goal == i_freed + 1, "goal done comes right after the event that freed the creature")
	assert_true(i_fall > i_goal, "before the first fall")
	assert_true(i_win > i_goal and i_win == events.size() - 1, "before the win, which is still last")
	assert_eq(EV.index_of(events, "win"), events.size() - 1)
	assert_eq(board.moves, 9)


func test_ir56_two_goals_in_different_steps_make_two_goal_done_events_in_order() -> void:
	# cascade_board: the swap's match frees the creature at (2,7) (next to (3,7)); the fall forms a G cascade
	# (3,6),(4,6),(5,6) that removes the bramble (1 layer) at (6,6).
	var board: BoardModel = cascade_board(10)
	board.palette = BB.spread_palette()
	board.add_content("OB07", 2, 7, 1)
	board.add_content("OB02", 6, 6, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1), obstacle_goal("OB02", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "match"), 2, "precondition: the swap's match and one cascade match")
	assert_eq(_goal_ids(events), [0, 1], "two goal done events, creature goal first")
	var i_g0: int = EV.index_of(events, "goal_done", 0)
	var i_g1: int = EV.index_of(events, "goal_done", 1)
	var i_fall0: int = EV.index_of(events, "fall")
	var i_match1: int = EV.index_of(events, "match", 1)
	assert_true(i_g0 < i_fall0, "goal 0 done before the first fall")
	assert_true(i_fall0 < i_match1 and i_match1 < i_g1, "goal 1 done only in the cascade")
	assert_true(EV.index_after(events, "fall", i_g1) > i_g1, "a fall follows goal 1's event")
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(EV.index_of(events, "win"), events.size() - 1, "the win is last")


func test_ir56_goal_finished_by_a_cascade_has_no_goal_done_before_the_cascade() -> void:
	var board: BoardModel = cascade_board(5)
	board.palette = BB.spread_palette()
	board.add_content("OB07", 6, 6, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "goal_done"), 1)
	var i_goal: int = EV.index_of(events, "goal_done")
	var i_match1: int = EV.index_of(events, "match", 1)
	assert_true(i_match1 >= 0 and i_goal > i_match1, "no goal done event before the cascade match")
	assert_true(EV.index_after(events, "fall", i_goal) > i_goal, "the cascade's fall comes after the goal done event")
	assert_true(EV.index_of(events, "win") > EV.index_after(events, "refill", i_goal), "then refill, then the win")


func test_ir56_goal_finished_by_the_last_moves_cascade_is_goal_done_then_win_with_no_fail() -> void:
	var board: BoardModel = cascade_board(1)
	board.palette = BB.spread_palette()
	board.add_content("OB07", 6, 6, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	var i_goal: int = EV.index_of(events, "goal_done")
	var i_win: int = EV.index_of(events, "win")
	assert_eq(EV.count(events, "goal_done"), 1)
	assert_true(i_goal >= 0 and i_win > i_goal, "goal done, then the rest of the cascade, then the win")
	assert_true(EV.index_after(events, "fall", i_goal) < i_win, "the cascade's fall is between them")
	assert_eq(EV.count(events, "fail"), 0)
	assert_eq(int(events.back().data.get("moves_left", -1)), 0, "0 finale Rockets")


func test_ir56_dew_goal_reaching_its_count_mid_move_makes_one_goal_done_event() -> void:
	var bare: Array = [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4),
			Vector2i(3, 3), Vector2i(5, 3), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(6, 0)]
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	assert_eq(BB.dew_level(board, bare), 70, "precondition: 70 cells have dew")
	BB.put(board, "R-", [[0, 4]])
	BB.put(board, "G", [[3, 2], [4, 2], [5, 2]])
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 72)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(BB.dew_cells(board).size(), 77, "75 after the Rocket, 77 after the cascade")
	assert_eq(EV.count(events, "goal_done"), 1, "one goal done event, none for the extra dew")
	var i_goal: int = EV.index_of(events, "goal_done")
	assert_true(i_goal < EV.index_of(events, "fall"), "the count is reached inside the Rocket, before its fall")
	assert_true(i_goal < EV.index_of(events, "match"), "and before the cascade")
	assert_eq(EV.count(events, "win"), 1)
	assert_true(EV.index_of(events, "win") > i_goal)


func test_ir56_fragment_goal_done_comes_right_after_the_fragment_is_collected() -> void:
	# Level 26. Move 1 clears the bramble (goal 0 done). Move 2 frees the fragment cocoon at (7,5) (goal 1).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 4
	board.add_content("OB02", 3, 3, 1)
	board.add_content("OB07", 7, 5, 1, 1, 1, true)
	var t: Variant = track(board, [obstacle_goal("OB02", 1), obstacle_goal("OB07", 1, true)], 26)
	if t == null:
		return
	var first: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(_goal_ids(first), [0], "move 1: only the bramble goal is done")
	assert_eq(EV.count(first, "win"), 0)
	var events: Array[BoardEvent] = swap_row_match(board, 7, 6)
	assert_eq(_goal_ids(events), [1], "move 2: the fragment goal is done, goal 0 is not announced again")
	var i_got: int = EV.index_of(events, "collected")
	var i_goal: int = EV.index_of(events, "goal_done")
	assert_true(i_got >= 0 and i_goal == i_got + 1, "right after the fragment is collected")
	assert_true(i_goal < EV.index_of(events, "fall"), "before the fall")
	assert_eq(EV.count(events, "win"), 1)
	assert_true(EV.index_of(events, "win") > EV.index_of(events, "refill"), "the win comes after the settle")


func test_ir56_fragment_goal_done_but_another_goal_not_done_is_no_win() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 4
	board.add_content("OB07", 2, 3, 1, 1, 1, true)
	board.add_content("OB02", 7, 7, 2)
	var t: Variant = track(board, [obstacle_goal("OB07", 1, true), obstacle_goal("OB02", 1)], 26)
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(_goal_ids(events), [0], "the fragment goal is announced")
	assert_eq(EV.count(events, "win"), 0, "the other goal is not done: no win")


func test_ir56_a_done_goal_is_never_announced_again_or_undone() -> void:
	# Bramble goal (count 1): bramble at (2,6) goes in the swap's match (goal done); a second bramble at (6,6)
	# goes in the cascade. The creature goal is not done.
	var board: BoardModel = cascade_board(5)
	board.palette = BB.spread_palette()
	board.add_content("OB02", 2, 6, 1)
	board.add_content("OB02", 6, 6, 1)
	board.add_content("OB07", 8, 0, 1)
	var t: Variant = track(board, [obstacle_goal("OB02", 1), obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "match"), 2, "precondition: swap match and cascade")
	assert_eq(EV.count(events, "obstacle_cleared"), 2, "precondition: both brambles are gone")
	assert_eq(_goal_ids(events), [0], "goal 0 announced once, goal 1 never")
	assert_true(t.is_goal_done(0), "goal 0 stays done")
	assert_eq(EV.count(events, "win"), 0, "the creature goal is not done: no win")


func test_ir56_a_booster_that_finishes_the_goal_makes_goal_done_then_win_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.set_drop_item(4, 2, "OB11")
	board.moves = 6
	var t: Variant = track(board, [obstacle_goal("OB11", 1)])
	if t == null:
		return
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 2)])
	if events == null:
		return
	assert_eq(EV.count(events, "goal_done"), 1)
	var i_got: int = EV.index_of(events, "collected")
	var i_goal: int = EV.index_of(events, "goal_done")
	assert_true(i_got >= 0 and i_goal == i_got + 1, "goal done right after the collect")
	assert_eq(EV.count(events, "win"), 1)
	assert_true(EV.index_of(events, "win") > i_goal)
	assert_eq(events.back().type, "win")
	assert_eq(board.moves, 6, "Hoof Tap uses no move")


# IR-56 / GDD Rules clarifications row 101: two goals finished by one hit show in goal-bar order
# (the order listed in the level file); each event carries the goal index (data.goal) and obstacle id (data.id).
func _one_hit_board() -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R|", [[6, 0]])
	board.add_content("OB02", 6, 6, 1)
	board.add_content("OB07", 6, 7, 1)
	return board


func _goal_pairs(events: Array) -> Array:
	var out: Array = []
	for e in EV.of_type(events, "goal_done"):
		out.append([int(e.data.get("goal", -1)), str(e.data.get("id", ""))])
	return out


func test_ir56_two_goals_by_one_hit_come_in_file_order_bramble_first() -> void:
	var board: BoardModel = _one_hit_board()
	var t: Variant = track(board, [obstacle_goal("OB02", 1), obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(6, 0))
	assert_eq(_goal_pairs(events), [[0, "OB02"], [1, "OB07"]], "goal-bar order, index and id on each event")
	var i_first: int = EV.index_of(events, "goal_done", 0)
	var i_second: int = EV.index_of(events, "goal_done", 1)
	var i_fall: int = EV.index_of(events, "refill")  # a full column clear has no fall, the refill is the next step
	assert_true(i_first >= 0 and i_second > i_first and i_fall > i_second, "both before the first fall")
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(events.back().type, "win", "the win comes last, after the settle")
	assert_true(EV.index_of(events, "win") > EV.index_after(events, "refill", i_second), "after the refill")


func test_ir56_two_goals_by_one_hit_follow_the_file_order_not_the_board_or_the_id() -> void:
	var board: BoardModel = _one_hit_board()
	var t: Variant = track(board, [obstacle_goal("OB07", 1), obstacle_goal("OB02", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(6, 0))
	assert_eq(_goal_pairs(events), [[0, "OB07"], [1, "OB02"]], "OB07 listed first: index 0")
	assert_true(EV.index_of(events, "goal_done", 1) < EV.index_of(events, "refill"), "both before the refill (next step of the move)")
