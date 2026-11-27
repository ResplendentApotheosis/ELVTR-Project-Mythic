# GUT tests for IR-56 (win), IR-57 (fail) and the GoalTracker side of IR-16 (finale start, last-move win).
# API: tests/API_CONTRACT.md section 10. Run: see CLAUDE.md "Run all tests".
# Win timing (owner, 28 Nov 2026: OQ-64 changed, OQ-72): when the last goal is done the REST of that move
# still happens in full (rest of the match or special, falls, refills, waiting specials, second blasts,
# cascades, free shuffle); `win` is the last event of the move, then the finale starts on the settled board.
extends "res://tests/helpers/goal_test_base.gd"


func _creature_board(moves: int, x: int = 2, y: int = 3) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.moves = moves
	board.add_content("OB07", x, y, 1)
	return board


# ---------------------------------------------------------------- IR-56

func test_ir56_win_when_the_last_goal_is_done_with_leftover_moves() -> void:
	var board: BoardModel = _creature_board(10)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(events, "win"), 1, "one win event")
	assert_eq(events.back().type, "win", "the win is the last event of the move")
	assert_eq(EV.sequence(events, ["match", "fall", "refill", "win"]), ["match", "fall", "refill", "win"], "the move settles first, then win")
	assert_eq(board.moves, 9)
	assert_eq(int(events.back().data.get("moves_left", -1)), 9, "9 moves left = 9 finale Rockets")
	assert_true(t.is_won())
	assert_eq(tracker_static("win_coins", [9]), 65, "20 + 5 x 9")


func test_ir56_one_goal_done_and_one_not_is_no_win() -> void:
	var board: BoardModel = _creature_board(10)
	board.set_drop_item(6, 1, "OB11")
	var t: Variant = track(board, [obstacle_goal("OB07", 1), obstacle_goal("OB11", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(units(t, 0), 1, "OB07 goal done")
	assert_eq(units(t, 1), 0, "OB11 goal not done")
	assert_eq(EV.count(events, "win"), 0)
	assert_false(t.is_won())
	assert_eq(board.moves, 9)


func test_ir56_fragment_goal_not_done_is_no_win() -> void:
	# IR-31: every non-fragment goal done, the fragment not yet collected, moves 4 -> no win.
	var board: BoardModel = BB.blank()
	board.moves = 4
	board.add_content("OB02", 3, 3, 1)
	board.add_content("OB07", 7, 7, 1, 1, 1, true)
	var t: Variant = track(board, [obstacle_goal("OB02", 1), obstacle_goal("OB07", 1, true)], 26)
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(units(t, 0), 1, "the bramble is gone")
	assert_eq(units(t, 1), 0, "the fragment is not collected")
	assert_eq(EV.count(events, "win"), 0, "a level cannot be won without the fragment")
	assert_false(t.is_won())


func test_ir56_bramble_needs_every_layer_before_the_win() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	board.add_content("OB02", 4, 3, 2)
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 4, 4)
	assert_eq(board.content_hp(4, 3), 1, "1 layer left")
	assert_eq(units(t, 0), 0, "goal 0/1")
	assert_eq(EV.count(events, "win"), 0)
	assert_eq(board.moves, 9)
	events = swap_row_match(board, 4, 4)
	assert_eq(board.content_hp(4, 3), 0, "bramble gone")
	assert_eq(units(t, 0), 1, "goal 1/1")
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(board.moves, 8)


func test_ir56_goals_finished_on_the_last_move_are_a_win_with_no_finale_rockets() -> void:
	var board: BoardModel = _creature_board(1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(board.moves, 0)
	assert_eq(EV.count(events, "win"), 1, "a win event")
	assert_eq(EV.count(events, "fail"), 0, "no fail event")
	assert_eq(int(t.offer_price()), 0, "no continue offer")
	assert_eq(int(events.back().data.get("moves_left", -1)), 0, "0 finale Rockets")
	assert_eq(tracker_static("win_coins", [0]), 20)
	assert_eq(EV.count(MatchResolver.fire_finale(board), "rocket_fire"), 0, "no finale Rocket events")


func test_ir56_a_cascade_in_the_last_move_that_finishes_the_goal_wins() -> void:
	var board: BoardModel = cascade_board(1)
	board.add_content("OB07", 6, 6, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "match"), 2, "the swap's match and the cascade match")
	assert_eq(units(t, 0), 1, "the cascade freed the creature")
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(EV.count(events, "fail"), 0)
	assert_eq(int(t.offer_price()), 0)
	assert_eq(board.moves, 0)
	assert_eq(tracker_static("win_coins", [0]), 20)


func test_ir56_firecracker_tap_finishing_in_blast_1_still_plays_blast_2_and_the_settling() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 3
	BB.put(board, "RF", [[4, 4]])
	board.add_content("OB07", 5, 5, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(EV.sequence(events, ["blast", "fall", "refill", "win"]),
		["blast", "fall", "refill", "blast", "fall", "refill", "win"], "blast 1, fall, refill, blast 2, fall, refill, win")
	assert_eq(events.back().type, "win", "nothing after the win event")
	assert_eq(board.moves, 2)
	assert_eq(int(events.back().data.get("moves_left", -1)), 2, "2 finale Rockets")
	assert_eq(EV.count(MatchResolver.fire_finale(board), "rocket_fire"), 2)
	assert_eq(tracker_static("win_coins", [2]), 30)


func test_ir56_swap_with_a_yellow_firecracker_finishing_in_the_match_still_blasts_twice_before_the_win() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 5
	board.add_content("OB07", 2, 3, 1)
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "YF", [[4, 4]])
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(EV.sequence(events, ["match", "fall", "refill", "blast", "win"]),
		["match", "fall", "refill", "blast", "fall", "refill", "blast", "fall", "refill", "win"],
		"match, fall, refill, blast 1, fall, refill, blast 2, fall, refill, win")
	assert_eq(EV.blast_centres(events, 1), [Vector2i(4, 5)], "blast 1 is centred on (4,5)")
	assert_eq(events.back().type, "win")
	assert_eq(board.moves, 4)
	assert_eq(int(events.back().data.get("moves_left", -1)), 4)
	var finale: Array[BoardEvent] = MatchResolver.fire_finale(board)
	assert_eq(EV.count(finale, "rocket_fire"), 4, "4 finale Rockets")
	assert_eq(tracker_static("win_coins", [4]), 40)


func test_ir56_the_whole_row_rocket_applies_not_only_up_to_the_creature() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 3
	board.add_content("OB07", 2, 4, 1)
	board.add_content("OB02", 6, 4, 2)   # not a goal
	BB.put(board, "R-", [[0, 4]])
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(units(t, 0), 1, "creature freed")
	assert_eq(board.content_hp(6, 4), 1, "the bramble at the far end of the row still takes its hit")
	assert_eq(EV.count(events, "win"), 1)
	var i_win: int = EV.index_of(events, "win")
	assert_true(i_win > EV.index_of(events, "fall"), "the win comes after the fall")
	assert_true(i_win > EV.index_of(events, "refill"), "the win comes after the refill")
	assert_eq(i_win, events.size() - 1)
	assert_eq(board.moves, 2)


func test_ir56_a_cascade_after_the_goal_still_makes_a_rocket_that_stays_unfired() -> void:
	# cascade_board: the swap clears (3,6),(3,7),(3,8) and frees the creature at (4,7) (next to the match). Column 3 falls by 3
	# and column 4 by 1, so G pieces land in (3,7) and (4,7); with G at (2,7),(5,7) that is a 4-line in row 7 (a Rocket, IR-42).
	var board: BoardModel = cascade_board(2)
	board.palette = BB.spread_palette()
	BB.put(board, "G", [[3, 4], [2, 7], [5, 7]])
	board.add_content("OB07", 4, 7, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "match"), 2, "the swap's match and the cascade match")
	assert_eq(units(t, 0), 1)
	var made: Array = EV.of_type(events, "special_created")
	assert_eq(made.size(), 1, "the cascade made a special")
	if made.size() == 1:
		assert_true(String(made[0].kind).begins_with("rocket"), "a Rocket")
		assert_eq(board.get_kind(made[0].cell.x, made[0].cell.y), String(made[0].kind), "it stays on the board")
	assert_eq(EV.count(events, "rocket_fire"), 0, "unfired")
	var i_win: int = EV.index_of(events, "win")
	assert_true(i_win >= 0 and i_win == events.size() - 1, "the win is the last event")
	assert_true(i_win > EV.index_after(events, "match", EV.index_of(events, "match")), "the win is after the cascade match")
	assert_true(i_win > last_index_of_any(events, ["fall", "refill"]), "and after its fall and refill")
	assert_eq(board.moves, 1)
	assert_eq(EV.count(MatchResolver.fire_finale(board), "rocket_fire"), 1, "then 1 finale Rocket")


func test_ir56_the_free_shuffle_comes_before_the_win() -> void:
	# A blank board of unique pieces has no possible move once the match is gone (refills use 12 spread colours).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.auto_shuffle = true
	board.moves = 4
	board.add_content("OB07", 2, 3, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(units(t, 0), 1)
	assert_eq(EV.count(events, "shuffle"), 1, "precondition: the settled board had no possible move, so it shuffled")
	assert_eq(EV.count(events, "win"), 1)
	assert_true(EV.index_of(events, "win") > EV.index_of(events, "shuffle"), "shuffle, then win")
	assert_eq(events.back().type, "win")
	assert_eq(board.moves, 3)


func test_ir56_crane_that_flies_after_the_goals_aims_by_the_no_goal_case_and_adds_no_coins() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 5
	board.add_content("OB07", 2, 2, 1)
	board.add_content("OB02", 6, 6, 2)   # not a goal
	BB.put(board, "GC", [[6, 2]])
	BB.put(board, "R-", [[0, 2]])
	board.goals = ["OB07"]
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 2))
	assert_eq(board.content_hp(6, 6), 1, "the Crane still flew and hit the bramble")
	assert_eq(EV.count(events, "win"), 1, "one win event")
	assert_eq(events.back().type, "win")
	assert_eq(board.moves, 4)
	assert_eq(tracker_static("win_coins", [int(events.back().data.get("moves_left", -1))]), 40, "20 + 5 x 4: the extra clears add no coins")


# ---------------------------------------------------------------- IR-16 (GoalTracker side)

func test_ir16_finale_starts_on_the_board_as_it_is_with_one_rocket_per_leftover_move() -> void:
	var board: BoardModel = _creature_board(3)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var win_events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(win_events, "win"), 1)
	assert_eq(board.moves, 2)
	var finale: Array[BoardEvent] = MatchResolver.fire_finale(board)
	assert_eq(EV.count(finale, "rocket_fire"), 2, "2 finale Rockets for 2 leftover moves")
	var all: Array = []
	all.append_array(win_events)
	all.append_array(finale)
	var i_win: int = EV.index_of(all, "win")
	var i_first: int = EV.index_of(all, "rocket_fire")
	assert_true(i_first > i_win, "the finale comes after the win")
	assert_eq(EV.count_between(all, "fall", i_win, i_first), 0, "no fall between the win and Rocket 1")
	assert_eq(EV.count_between(all, "refill", i_win, i_first), 0, "no refill between the win and Rocket 1")
	assert_eq(EV.count_between(all, "match", i_win, i_first), 0, "no cascade between the win and Rocket 1")
	assert_eq(tracker_static("win_coins", [2]), 30)


func test_ir16_first_finale_rocket_is_drawn_on_the_settled_board() -> void:
	# IR-16 last case: events match, fall, refill, win, then Rocket 1; its cell is a plain piece of the settled board.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 3
	board.add_content("OB07", 2, 3, 1)
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.sequence(events, ["match", "fall", "refill", "win"]), ["match", "fall", "refill", "win"])
	assert_eq(board.moves, 2)
	var kinds: Dictionary = {}
	for y in range(board.height):
		for x in range(board.width):
			kinds[Vector2i(x, y)] = board.get_kind(x, y)
	var finale: Array[BoardEvent] = MatchResolver.fire_finale(board)
	assert_eq(EV.count(finale, "rocket_fire"), 2)
	var made: Array = EV.of_type(finale, "special_created")
	assert_true(made.size() >= 1, "Rocket 1 was placed")
	if made.size() >= 1:
		assert_eq(kinds[made[0].cell], "plain", "Rocket 1 replaced a plain piece of the settled board, never an empty cell")


func test_ir16_win_on_the_last_move_has_no_finale_rockets_and_pays_20() -> void:
	var board: BoardModel = _creature_board(1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(int(events.back().data.get("moves_left", -1)), 0)
	assert_eq(tracker_static("win_coins", [0]), 20)
	assert_eq(tracker_static("win_coins", [1]), 25)
	assert_eq(tracker_static("win_coins", [10]), 70)


# ---------------------------------------------------------------- IR-57

func test_ir57_last_move_that_finishes_no_goal_is_a_fail_with_the_first_offer() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 1
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(board.moves, 0)
	assert_eq(EV.count(events, "fail"), 1, "one fail event")
	assert_eq(EV.count(events, "win"), 0)
	assert_eq(int(t.offer_price()), 300, "continue offer 1 costs 300 (IR-37)")


func test_ir57_swap_that_snaps_back_never_causes_a_fail() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 1
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(0, 0), Vector2i(1, 0))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 1)
	assert_eq(EV.count(events, "fail"), 0)
	assert_eq(int(t.offer_price()), 0)


func test_ir57_refused_swap_never_causes_a_fail() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 1
	board.add_content("OB02", 4, 4, 2)
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 1)
	assert_eq(EV.count(events, "fail"), 0)


func test_ir57_tapping_a_plain_piece_never_causes_a_fail() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 1
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.moves, 1)
	assert_eq(EV.count(events, "fail"), 0)


func test_ir57_fail_comes_only_after_the_third_of_three_moves() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 3
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var e1: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(e1, "fail"), 0, "none after move 1")
	var e2: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(e2, "fail"), 0, "none after move 2")
	var e3: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(board.moves, 0)
	assert_eq(EV.count(e3, "fail"), 1, "one fail after move 3")


func test_ir57_fail_comes_after_the_whole_firecracker_resolve() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 1
	BB.put(board, "RF", [[4, 4]])
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.moves, 0)
	assert_eq(EV.count(events, "blast"), 2, "both blasts happened")
	assert_eq(EV.count(events, "fail"), 1, "exactly one fail event")
	var i_fail: int = EV.index_of(events, "fail")
	assert_true(i_fail > last_index_of_any(events, ["blast", "fall", "refill", "match", "clear"]), "the fail comes after the last fall/refill of that move")


func test_ir57_fail_waits_for_the_cascade_between_the_two_blasts() -> void:
	# Blast 1 clears x 3-5, y 3-5; columns 3-5 fall by 3, so R from (3,2),(4,2) land in (3,5),(4,5)
	# next to the R at (2,5): a cascade match between blast 1 and blast 2.
	var board: BoardModel = BB.blank()
	board.moves = 1
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "R", [[3, 2], [4, 2], [2, 5]])
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_true(EV.count(events, "match") >= 1, "precondition: a cascade match happened")
	assert_eq(EV.count(events, "fail"), 1)
	assert_true(EV.index_of(events, "fail") > last_index_of_any(events, ["blast", "fall", "refill", "match", "clear"]))


func test_ir57_goal_finished_by_a_cascade_in_the_last_move_is_a_win_not_a_fail() -> void:
	var board: BoardModel = cascade_board(1)
	board.add_content("OB07", 6, 6, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(EV.count(events, "fail"), 0)


func test_ir57_hero_booster_never_causes_a_fail() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 1
	var t: Variant = track(board, [obstacle_goal("OB02", 3)])
	if t == null:
		return
	var events: Variant = booster("hoof_tap", [board, Vector2i(3, 3)])
	if events == null:
		return
	assert_eq(board.moves, 1, "Hoof Tap uses no move (IR-62)")
	assert_eq(EV.count(events, "fail"), 0)
	assert_eq(int(t.offer_price()), 0)
