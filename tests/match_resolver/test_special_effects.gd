# GUT tests for IR-16..IR-21, IR-41, IR-47, IR-48, IR-49 (what each special does).
# API: tests/API_CONTRACT.md. Orb count boards come from BoardBuilder.with_counts.
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


func _orb_board(counts: Dictionary) -> BoardModel:
	var board: BoardModel = BB.with_counts(counts, {Vector2i(4, 4): "O"})
	board.moves = 10
	return board


# ---------------------------------------------------------------- IR-16

func test_ir16_row_rocket_clears_its_whole_row() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.row_cells(4))), "exactly row 4 cleared")


func test_ir16_column_rocket_clears_its_whole_column() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.col_cells(4))), "exactly column 4 cleared")


func test_ir16_pending_converted_rockets() -> void:
	pending("OQ-24: direction of Rockets not made from a line (Orb + Rocket, finale)")


# ---------------------------------------------------------------- IR-17

func test_ir17_firecracker_blasts_twice_with_a_fall_between() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var seq: Array[String] = []
	for e in events:
		if e.type == "blast" or e.type == "fall":
			seq.append(e.type)
	assert_true(seq.size() >= 3, "blast, fall, blast expected")
	if seq.size() >= 3:
		assert_eq(seq[0], "blast")
		assert_eq(seq[1], "fall")
		assert_eq(seq[2], "blast")
	assert_eq(EV.count(events, "blast"), 2)
	assert_eq(EV.cleared_total(events), 18, "9 pieces per blast")
	var blasts: Array = EV.of_type(events, "blast")
	var area: Dictionary = EV.to_set(EV.rect_cells(3, 3, 5, 5))
	if blasts.size() < 2:
		return
	assert_true(EV.same_set(EV.to_set(blasts[0].cells), area))
	assert_true(EV.same_set(EV.to_set(blasts[1].cells), area), "same centre cell both times")


func test_ir17_firecracker_in_the_corner_is_clipped_to_the_board() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[0, 0]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 0))
	var blasts: Array = EV.of_type(events, "blast")
	assert_eq(blasts.size(), 2)
	for b in blasts:
		assert_true(EV.same_set(EV.to_set(b.cells), EV.to_set(EV.rect_cells(0, 0, 1, 1))))


func test_ir17_pending_what_happens_between_blasts() -> void:
	pending("OQ-32: whether refill and cascade matches happen between the two blasts")


# ---------------------------------------------------------------- IR-18

func test_ir18_orb_swapped_with_a_plain_piece_clears_that_colour() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 7], [7, 2], [8, 8]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	var cleared: Dictionary = EV.cleared(events)
	# after the swap the B is at (4,4) and the Orb at (5,4)
	for c in [Vector2i(4, 4), Vector2i(1, 7), Vector2i(7, 2), Vector2i(8, 8), Vector2i(5, 4)]:
		assert_true(cleared.has(c), "cell %s cleared (every B, plus the used-up Orb)" % c)
	assert_eq(board.moves, 14)
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].color, "B")


func test_ir18_orb_hits_goo_under_a_cleared_piece() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 1]])
	board.set_underlay(1, 1, "OB10", 1)
	MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	assert_eq(board.underlay_hp(1, 1), 0)


func test_ir18_orb_does_not_hit_obstacles_next_to_cleared_pieces() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [2, 3]])
	board.add_content("OB02", 2, 2, 2)
	MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	assert_eq(board.content_hp(2, 2), 2)


func test_ir18_pending_coloured_specials_of_that_colour() -> void:
	pending("OQ-33: whether coloured specials and covered pieces count as pieces of that colour")


# ---------------------------------------------------------------- IR-19

func test_ir19_tapped_orb_clears_the_most_common_colour() -> void:
	var board: BoardModel = _orb_board({"R": 20, "Y": 18, "B": 17, "G": 16})
	var expected: Array[Vector2i] = BB.find_color(board, "R")
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(expected.size(), 20)
	var cleared: Dictionary = EV.cleared(events)
	for c in expected:
		assert_true(cleared.has(c), "R at %s cleared" % c)
	assert_eq(board.moves, 9)


func test_ir19_tie_goes_to_red() -> void:
	var board: BoardModel = _orb_board({"R": 18, "B": 18, "Y": 17, "G": 17})
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].color, "R")


func test_ir19_pending_what_counts_toward_most_common() -> void:
	pending("OQ-33: what counts toward 'most common' (coloured specials, covered pieces)")


# ---------------------------------------------------------------- IR-20

func test_ir20_crane_goes_for_the_unfreed_fragment_first() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 1, 1, 1)
	board.add_content("OB07", 7, 7, 3, 1, 1, true)
	board.goals = ["OB02", "fragment"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var targets: Array = EV.of_type(events, "crane_target")
	assert_eq(targets.size(), 1)
	if targets.size() == 1:
		assert_eq(targets[0].cell, Vector2i(7, 7), "the cocoon, not the bramble with fewer hits")


func test_ir20_crane_events_come_in_order_target_takeoff_landing() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var i_target: int = EV.index_of(events, "crane_target")
	var i_off: int = EV.index_of(events, "crane_takeoff")
	var i_land: int = EV.index_of(events, "crane_landing")
	assert_true(i_target >= 0 and i_off >= 0 and i_land >= 0, "all three events exist")
	assert_true(i_target < i_off and i_off < i_land, "order: target, take-off, landing")
	if i_target < 0 or i_off < 0 or i_land < 0:
		return
	assert_eq(events[i_off].cell, Vector2i(4, 4), "take-off from the Crane's cell")
	assert_eq(events[i_target].cell, events[i_land].cell, "lands on the target")


# ---------------------------------------------------------------- IR-21

func test_ir21_firecracker_in_a_match_fires() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 5]])
	BB.put(board, "RF", [[3, 4]])
	BB.put(board, "Y", [[2, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 5), Vector2i(2, 4))
	assert_eq(EV.count(events, "blast"), 2, "the matched Firecracker fires")


func test_ir21_pending_order_of_match_and_fire() -> void:
	pending("OQ-26: order between a match and the special it sets off")


# ---------------------------------------------------------------- IR-41

func test_ir41_rocket_sets_off_another_rocket_after_it_finishes() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[1, 4]])
	BB.put(board, "R|", [[6, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 4))
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 2)
	if fires.size() == 2:
		assert_true(EV.same_set(EV.to_set(fires[0].cells), EV.to_set(EV.row_cells(4))), "row 4 first")
		assert_true(EV.same_set(EV.to_set(fires[1].cells), EV.to_set(EV.col_cells(6))), "then column 6")
		var i1: int = EV.index_of(events, "rocket_fire", 0)
		var i2: int = EV.index_of(events, "rocket_fire", 1)
		var clear_between: bool = false
		for i in range(i1 + 1, i2):
			if events[i].type == "clear":
				clear_between = true
		assert_true(clear_between, "the first rocket's clear comes before the second fires")


func test_ir41_set_off_rocket_hits_obstacles_in_its_line() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[1, 4]])
	BB.put(board, "R|", [[6, 4]])
	board.add_content("OB02", 6, 7, 2)
	MatchResolver.tap(board, Vector2i(1, 4))
	assert_eq(board.content_hp(6, 7), 1)


func test_ir41_rocket_sets_off_a_crane() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 0]])
	BB.put(board, "GC", [[4, 6]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 0))
	var i_fire: int = EV.index_of(events, "rocket_fire")
	var i_crane: int = EV.index_of(events, "crane_target")
	assert_true(i_fire >= 0 and i_crane > i_fire, "the Crane fires after the Rocket")


func test_ir41_pending_chain_details() -> void:
	pending("OQ-27: order of several set-off specials, Firecracker chains, set-off Orb, Orb + Orb")


# ---------------------------------------------------------------- IR-47

func _tap_orb_colour(counts: Dictionary) -> String:
	var board: BoardModel = _orb_board(counts)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var fires: Array = EV.of_type(events, "orb_fire")
	if fires.size() != 1:
		return "<no orb_fire event>"
	return fires[0].color


func test_ir47_red_yellow_tie_goes_to_red() -> void:
	assert_eq(_tap_orb_colour({"R": 18, "Y": 18, "B": 17, "G": 16}), "R")


func test_ir47_yellow_blue_tie_goes_to_yellow() -> void:
	assert_eq(_tap_orb_colour({"R": 10, "Y": 19, "B": 19, "G": 10}), "Y")


func test_ir47_blue_green_tie_goes_to_blue() -> void:
	assert_eq(_tap_orb_colour({"R": 12, "Y": 12, "B": 20, "G": 20}), "B")


# ---------------------------------------------------------------- IR-48

func test_ir48_crane_hits_its_target_and_clears_its_start_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.content_hp(6, 2), 1)
	assert_true(EV.cleared(events).has(Vector2i(1, 7)), "take-off clears the start cell")
	assert_eq(BB.find_kind(board, "crane").size(), 0, "the Crane is used up")


func test_ir48_crane_collects_a_drop_item() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	BB.put(board, "H", [[5, 3]])
	board.goals = ["OB11"]
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.collected_count("OB11"), 1, "collected, not destroyed")


func test_ir48_crane_freeing_a_cocoon_collects_the_fragment() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	board.add_content("OB07", 4, 1, 1, 1, 1, true)
	board.goals = ["fragment"]
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.content_hp(4, 1), 0)
	assert_eq(board.collected_count("fragment"), 1)


func test_ir48_pending_takeoff_underlay_and_dew_landing() -> void:
	pending("OQ-34 (does take-off hit an underlay under the Crane) and OQ-31 (landing on a dew target)")


# ---------------------------------------------------------------- IR-49

func _crane_target(board: BoardModel) -> Vector2i:
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var targets: Array = EV.of_type(events, "crane_target")
	if targets.size() != 1:
		return Vector2i(-99, -99)
	return targets[0].cell


func test_ir49_fewest_hits_left_goal_wins() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 1, 1, 3)
	board.add_content("OB02", 7, 7, 3)
	board.add_content("OB07", 6, 2, 1)
	board.goals = ["OB02", "OB07"]
	assert_eq(_crane_target(board), Vector2i(6, 2))


func test_ir49_tie_goes_to_the_leftmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 2, 4, 1)
	board.add_content("OB07", 6, 4, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(2, 4))


func test_ir49_tie_goes_to_the_topmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 4, 1, 1)
	board.add_content("OB07", 4, 7, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(4, 1))


func test_ir49_closest_cell_beats_reading_order() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 5, 4, 1)
	board.add_content("OB07", 1, 4, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(5, 4))


func test_ir49_no_goal_left_aims_at_the_nearest_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 4, 2, 1)
	board.add_content("OB02", 0, 8, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(4, 2))


func test_ir49_no_obstacle_left_uses_the_seeded_random_piece() -> void:
	var first: Vector2i = Vector2i(-1, -1)
	var second: Vector2i = Vector2i(-2, -2)
	for run in range(2):
		var board: BoardModel = BB.blank(9, 9, 777)
		BB.put(board, "GC", [[4, 4]])
		var t: Vector2i = _crane_target(board)
		if run == 0:
			first = t
		else:
			second = t
	assert_eq(first, second, "same seed, same target")
	assert_true(first.x >= 0 and first.x < 9 and first.y >= 0 and first.y < 9, "target is on the board")


func test_ir49_no_goal_left_goo_counts_as_an_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.set_underlay(4, 5, "OB10", 1)
	board.add_content("OB02", 4, 1, 1)
	board.goals = []
	assert_eq(_crane_target(board), Vector2i(4, 5), "goo is closer than the bramble")
	assert_eq(board.underlay_hp(4, 5), 0, "goo removed")
	assert_eq(board.content_hp(4, 1), 1, "bramble untouched")


func test_ir49_no_goal_left_moss_counts_as_an_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.set_overlay(1, 1, "OB03", 1)
	board.goals = []
	assert_eq(_crane_target(board), Vector2i(1, 1))
	assert_eq(board.overlay_hp(1, 1), 0, "moss removed")


func test_ir49_pending_dew_as_no_goal_target() -> void:
	pending("OQ-38: whether healing dew (OB04) counts as an obstacle for the Crane when no goal is left")


func test_ir49_pending_distance_measure_and_non_hit_goals() -> void:
	pending("OQ-34: how 'closest' is measured; hits left for dew, shrine and drop-item goals; shrine colour")
