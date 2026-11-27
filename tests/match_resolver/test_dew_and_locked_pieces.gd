# GUT tests for IR-53 (healing dew spreads) and IR-54 (pieces under an overlay are locked).
# API: tests/API_CONTRACT.md section 2b (dew targets). Dew is an underlay with id "OB04".
# Pending placeholders name the open question (OQ) that blocks a case.
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
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	BB.set_dew_target(board, 6, 2)
	board.goals = ["OB04"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(EV.cells_of(events, "crane_landing"), [Vector2i(6, 2)], "the Crane lands on (6,2)")
	assert_true(BB.has_dew(board, 6, 2), "(6,2) has dew")
	assert_eq(BB.dew_targets_left(board), 0, "the dew goal is complete")


func test_ir53_pending_cells_with_no_piece_in_a_special_area() -> void:
	pending("OQ-46: do cells in a special's area that held no piece (e.g. a bramble cell) also get dew")


func test_ir53_pending_crane_landing_on_dew_target_clears_the_piece() -> void:
	pending("OQ-49: does a Crane landing on an uncovered dew target also clear the piece there")


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


func test_ir54_pending_match_through_a_covered_piece_and_the_cells_below() -> void:
	pending("OQ-41: what a match through a covered piece does to the piece and the layers; how cells below a locked piece are filled")
