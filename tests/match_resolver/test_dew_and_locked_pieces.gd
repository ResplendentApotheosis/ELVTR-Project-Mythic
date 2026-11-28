# GUT tests for IR-53 (healing dew spreads) and IR-54 (pieces under an overlay are locked).
# API: tests/API_CONTRACT.md section 2b (dew targets). Dew is an underlay with id "OB04".
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


# ---------------------------------------------------------------- IR-53

func test_ir53_match_on_dew_spreads_it_to_every_cell_of_the_match() -> void:
	var board: BoardModel = BB.blank()
	BB.set_dew(board, 3, 5)
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	var dew: Array[Vector2i] = BB.dew_cells(board)
	assert_eq(dew.size(), 3, "exactly three dew cells")
	for c in [Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5)]:
		assert_true(BB.has_dew(board, c.x, c.y), "dew at %s" % c)


func test_ir53_special_that_clears_a_piece_on_dew_spreads_it_to_every_cleared_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.set_dew(board, 5, 2)
	BB.put(board, "R-", [[0, 2]])
	MatchResolver.tap(board, Vector2i(0, 2))
	var dew: Array[Vector2i] = BB.dew_cells(board)
	assert_eq(dew.size(), 9, "all 9 cells of row 2 have dew and no other cell does")
	for c in EV.row_cells(2):
		assert_true(BB.has_dew(board, c.x, c.y), "dew at %s" % c)


func test_ir53_match_next_to_dew_does_not_spread_it() -> void:
	var board: BoardModel = BB.blank()
	BB.set_dew(board, 3, 6)
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_eq(BB.dew_cells(board), [Vector2i(3, 6)] as Array[Vector2i], "only the original dew cell has dew")


func test_ir53_crane_landing_on_the_last_dew_target_gives_it_dew() -> void:
	# 9x9, all 81 cells playable and targets (OQ-66); 80 have dew, (6,2) has none.
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	BB.dew_level(board, [Vector2i(6, 2)])
	board.goals = ["OB04"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(EV.cells_of(events, "crane_landing"), [Vector2i(6, 2)], "the Crane lands on (6,2)")
	assert_true(BB.has_dew(board, 6, 2), "(6,2) has dew")
	assert_eq(BB.dew_targets_left(board), 0, "no target cell is left without dew")


func test_ir53_special_gives_dew_to_an_obstacle_cell_it_covers() -> void:
	# OQ-46 B (trial): every playable cell the special covers gets dew, a bramble cell included.
	var board: BoardModel = BB.blank()
	BB.set_dew(board, 5, 2)
	BB.put(board, "R-", [[0, 2]])
	board.add_content("OB02", 7, 2, 2)
	MatchResolver.tap(board, Vector2i(0, 2))
	assert_eq(board.content_hp(7, 2), 1, "the bramble takes one hit")
	var dew: Array[Vector2i] = BB.dew_cells(board)
	assert_eq(dew.size(), 9, "all 9 cells of row 2 have dew, the bramble cell included")
	assert_true(BB.has_dew(board, 7, 2), "dew at the bramble cell (7,2)")


func test_ir53_special_gives_dew_to_cells_holding_a_drop_item_or_fragment() -> void:
	var board: BoardModel = BB.blank()
	BB.set_dew(board, 5, 2)
	BB.put(board, "R-", [[0, 2]])
	BB.put(board, "H", [[3, 2]])
	BB.put(board, "Q", [[6, 2]])
	MatchResolver.tap(board, Vector2i(0, 2))
	assert_true(BB.has_dew(board, 3, 2), "dew under the hatchling's cell")
	assert_true(BB.has_dew(board, 6, 2), "dew under the fragment's cell")
	assert_eq(BB.find_drop(board, "OB11").size(), 1, "hatchling not destroyed")
	assert_eq(BB.find_drop(board, "fragment").size(), 1, "fragment not destroyed")


func test_ir53_orb_covers_only_the_cells_whose_piece_it_clears() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 7], [7, 2]])
	BB.set_dew(board, 1, 7)
	MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	for c in [Vector2i(1, 7), Vector2i(7, 2), Vector2i(4, 4)]:
		assert_true(BB.has_dew(board, c.x, c.y), "dew at %s, where a B was cleared" % c)
	for c in [Vector2i(0, 0), Vector2i(8, 8), Vector2i(3, 3), Vector2i(2, 7)]:
		assert_false(BB.has_dew(board, c.x, c.y), "no dew at %s" % c)


func test_ir53_crane_landing_on_an_uncovered_dew_target_clears_the_piece_and_gives_dew() -> void:
	# OQ-49 B: the only cell without dew is (6,2), holding Y; no other goal.
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	BB.put(board, "Y", [[6, 2]])
	BB.dew_level(board, [Vector2i(6, 2)])
	board.goals = ["OB04"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(EV.cells_of(events, "crane_landing"), [Vector2i(6, 2)])
	assert_true(EV.cleared(events).has(Vector2i(6, 2)), "Y is cleared")
	assert_true(BB.has_dew(board, 6, 2), "(6,2) has dew")
	assert_eq(BB.dew_targets_left(board), 0, "dew goal complete")
	assert_eq(board.get_color(6, 2), BB.filler_color(6, 1), "(6,2) refilled by the piece from (6,1)")


func _goo_dew_match_board(goo_hp: int) -> BoardModel:
	# Dew under (3,5); goo under (4,5). The R swap makes the 3-match (2,5),(3,5),(4,5).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	BB.set_dew(board, 3, 5)
	board.set_underlay(4, 5, "OB10", goo_hp)
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	return board


func test_ir53_goo_that_survives_its_hit_blocks_the_dew() -> void:
	# OQ-56 A: goo hp 2 -> 1, so (4,5) gets no dew this time.
	var board: BoardModel = _goo_dew_match_board(2)
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_true(BB.has_dew(board, 2, 5), "dew at (2,5)")
	assert_true(BB.has_dew(board, 3, 5), "dew at (3,5)")
	assert_eq(board.underlay_id(4, 5), "OB10", "(4,5) still holds goo")
	assert_eq(board.underlay_hp(4, 5), 1, "goo hp 2 -> 1")
	assert_false(BB.has_dew(board, 4, 5), "no dew at (4,5)")


func test_ir53_goo_removed_by_the_hit_lets_the_dew_in() -> void:
	var board: BoardModel = _goo_dew_match_board(1)
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_true(BB.has_dew(board, 2, 5), "dew at (2,5)")
	assert_true(BB.has_dew(board, 3, 5), "dew at (3,5)")
	assert_true(BB.has_dew(board, 4, 5), "goo at (4,5) removed, so (4,5) has dew")


func test_ir53_rocket_over_goo_moss_and_dew_cells() -> void:
	# OQ-56 A in one row. Dew under (5,2). Goo hp 1 at (1,2), goo hp 2 at (7,2), moss hp 1 on goo hp 1 at (6,2).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	BB.set_dew(board, 5, 2)
	BB.put(board, "R-", [[0, 2]])
	board.set_underlay(1, 2, "OB10", 1)
	board.set_underlay(7, 2, "OB10", 2)
	board.set_underlay(6, 2, "OB10", 1)
	board.set_overlay(6, 2, "OB03", 1)
	MatchResolver.tap(board, Vector2i(0, 2))
	assert_true(BB.has_dew(board, 1, 2), "(1,2): goo removed, so it has dew")
	assert_eq(board.underlay_id(7, 2), "OB10", "(7,2) still goo")
	assert_eq(board.underlay_hp(7, 2), 1, "(7,2): goo hp 2 -> 1")
	assert_false(BB.has_dew(board, 7, 2), "(7,2): no dew")
	assert_eq(board.overlay_hp(6, 2), 0, "(6,2): moss removed")
	assert_eq(board.underlay_id(6, 2), "OB10", "(6,2): the goo under the moss is untouched")
	assert_eq(board.underlay_hp(6, 2), 1, "(6,2): goo still hp 1 (IR-09)")
	assert_false(BB.has_dew(board, 6, 2), "(6,2): no dew")
	for x in [0, 2, 3, 4, 5, 8]:
		assert_true(BB.has_dew(board, x, 2), "dew at (%d,2)" % x)


# ---------------------------------------------------------------- IR-54

func test_ir54_covered_piece_is_locked_for_swaps() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	board.set_overlay(4, 4, "OB03", 1)
	var before: String = BB.snapshot(board)
	var e1: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var e2: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 5))
	assert_eq(BB.snapshot(board), before, "board unchanged")
	assert_eq(board.moves, 10, "no move used")
	assert_eq(EV.count(e1, "invalid_swap"), 1)
	assert_eq(EV.count(e2, "invalid_swap"), 1)


func test_ir54_cell_under_a_surviving_overlay_refills_and_the_new_piece_is_locked() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R-", [[0, 3]])
	BB.put(board, "Y", [[6, 3]])
	board.set_overlay(6, 3, "OB03", 2)
	MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(board.moves, 9)
	assert_eq(board.overlay_hp(6, 3), 1, "moss hp 2 -> 1")
	assert_eq(board.get_color(6, 3), BB.filler_color(6, 2), "(6,3) now holds the piece that was at (6,2)")
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(6, 3), Vector2i(6, 4))
	assert_eq(BB.snapshot(board), before, "the piece that fell in is covered too, so it can't be swapped")
	assert_eq(EV.count(events, "invalid_swap"), 1)


func test_ir54_covered_piece_does_not_fall() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "G", [[4, 3]])
	board.set_overlay(4, 3, "OB03", 2)
	BB.put(board, "X", [[4, 6], [4, 7], [4, 8]])
	MatchResolver.settle(board)
	assert_eq(board.get_color(4, 3), "G", "G is still at (4,3)")
	assert_eq(board.overlay_hp(4, 3), 2, "under moss hp 2")




func test_ir54_match_through_a_covered_piece_hits_the_overlay_once_and_the_cell_refills_covered() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	board.set_overlay(3, 4, "OB03", 2)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var cleared: Dictionary = EV.cleared(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(cleared.has(c), "match cell %s cleared" % c)
	assert_eq(board.overlay_hp(3, 4), 1, "one hit on the moss, although (2,4) and (4,4) also touch it")
	assert_eq(board.get_color(3, 4), BB.filler_color(3, 3), "(3,4) holds the piece that was at (3,3), under moss hp 1")


func test_ir54_cell_below_a_locked_piece_is_filled_by_a_diagonal_slide() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "G", [[4, 3]])
	board.set_overlay(4, 3, "OB03", 2)
	BB.put(board, "X", [[4, 4]])
	MatchResolver.settle(board)
	assert_eq(board.get_color(4, 3), "G", "G is still at (4,3)")
	assert_eq(board.overlay_hp(4, 3), 2, "under moss hp 2")
	assert_eq(board.get_color(4, 4), BB.filler_color(3, 3), "(4,4) is filled from (3,3) by a diagonal slide")
	assert_eq(BB.empty_cells(board).size(), 0, "no playable cell is empty")


func test_ir54_special_under_an_overlay_is_locked_no_swap_no_tap_no_fall() -> void:
	# OQ-57 A. Red row Rocket under moss hp 1 at (2,6); Y at (3,6).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R-", [[2, 6]])
	BB.put(board, "Y", [[3, 6]])
	board.set_overlay(2, 6, "OB03", 1)
	var before: String = BB.snapshot(board)
	var e1: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 6), Vector2i(2, 6))
	assert_eq(EV.count(e1, "invalid_swap"), 1, "swap refused")
	var e2: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(2, 6))
	assert_eq(EV.count(e2, "rocket_fire"), 0, "tap does nothing")
	assert_eq(BB.snapshot(board), before, "board unchanged")
	assert_eq(board.moves, 10)
	BB.put(board, "X", [[2, 7]])
	MatchResolver.settle(board)
	assert_eq(board.get_kind(2, 6), "rocket_row", "the Rocket does not fall")
	assert_eq(board.overlay_hp(2, 6), 1)


func test_ir54_covered_special_is_set_off_by_another_special() -> void:
	# OQ-57 A. Red row Rocket under moss hp 1 at (2,6); a column Rocket tapped at (2,0).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R-", [[2, 6]])
	BB.put(board, "B|", [[2, 0]])
	board.set_overlay(2, 6, "OB03", 1)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(2, 0))
	assert_eq(board.overlay_hp(2, 6), 0, "the moss at (2,6) is removed by the column Rocket")
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 2, "the column Rocket, then the set-off red Rocket")
	if fires.size() == 2:
		assert_eq(fires[0].kind, "rocket_col")
		assert_eq(fires[1].kind, "rocket_row")
		assert_eq(fires[1].cell, Vector2i(2, 6), "fires from (2,6)")
		assert_true(EV.same_set(EV.to_set(fires[1].cells), EV.to_set(EV.row_cells(6))), "along row 6")


func test_ir54_covered_special_can_be_matched_by_colour_and_fires_from_its_cell() -> void:
	# OQ-57 A + OQ-54 A. Red row Rocket under moss hp 2 at (2,6); R at (3,6); Y at (4,6); R at (4,7).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R-", [[2, 6]])
	BB.put(board, "R", [[3, 6], [4, 7]])
	BB.put(board, "Y", [[4, 6]])
	board.set_overlay(2, 6, "OB03", 2)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 7), Vector2i(4, 6))
	assert_eq(board.moves, 9)
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(3, 6), Vector2i(4, 6)]:
		assert_true(matched.has(c), "R match clears %s" % c)
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_fall: int = EV.index_after(events, "fall", i_clear)
	var i_refill: int = EV.index_after(events, "refill", i_fall)
	var i_fire: int = EV.index_of(events, "rocket_fire")
	assert_true(i_clear >= 0 and i_fall > i_clear and i_refill > i_fall and i_fire > i_refill, "events in order: match clear, fall, refill, Rocket fire")
	if i_fall >= 0:
		assert_eq(EV.fall_map(events[i_fall]).get(Vector2i(2, 6)), Vector2i(2, 5), "(2,6) refills by falling: the piece from (2,5) drops in")
	if i_fire >= 0:
		assert_eq(events[i_fire].cell, Vector2i(2, 6))
		assert_eq(events[i_fire].kind, "rocket_row")
		assert_true(EV.same_set(EV.to_set(events[i_fire].cells), EV.to_set(EV.row_cells(6))), "along row 6")
	assert_eq(board.overlay_hp(2, 6), 0, "moss hp 2: one hit from the match, one from the Rocket that clears the piece that fell in")
