# GUT tests for IR-01, IR-02, IR-39, IR-52 (swaps, taps, what can be swapped).
# API: tests/API_CONTRACT.md. Run: see CLAUDE.md "Run all tests".
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


# ---------------------------------------------------------------- IR-01

func test_ir01_swap_that_makes_a_match_clears_it_and_uses_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(matched.has(c), "cell %s should be in the match" % c)
	assert_eq(board.moves, 19, "a matching swap uses one move")


func test_ir01_swap_with_no_match_snaps_back_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(0, 0), Vector2i(1, 0))
	assert_eq(BB.snapshot(board), before, "board identical after snap-back")
	assert_eq(board.moves, 20)
	assert_eq(EV.count(events, "invalid_swap"), 1, "an invalid_swap event is returned")


func test_ir01_hatchling_swap_with_no_match_snaps_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "H", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(BB.snapshot(board), before, "hatchling still at (4,4), Y still at (4,5)")
	assert_eq(board.moves, 20)
	assert_eq(EV.count(events, "invalid_swap"), 1)


func test_ir01_hatchling_swap_that_makes_a_match_uses_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "H", [[4, 4]])
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(matched.has(c), "cell %s should match" % c)
	assert_eq(board.moves, 19)


func test_ir01_two_hatchlings_swapped_with_no_match_snap_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "H", [[4, 4], [5, 4]])
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	assert_eq(BB.snapshot(board), before)
	assert_eq(EV.count(events, "invalid_swap"), 1)


# ---------------------------------------------------------------- IR-02

func test_ir02_tapping_a_firecracker_fires_it_and_costs_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(EV.count(events, "blast"), 2, "Firecracker blasts twice (IR-17)")
	assert_eq(board.moves, 9)


func test_ir02_tapping_a_plain_piece_does_nothing() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(events.size(), 0, "no events for a plain tap")
	assert_eq(BB.snapshot(board), before)
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- IR-39

func test_ir39_rocket_swapped_with_plain_fires_from_its_new_cell() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "never snapped back")
	assert_eq(board.moves, 9)
	assert_eq(EV.cells_of(events, "rocket_fire"), [Vector2i(4, 5)], "fires once, from (4,5)")
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.row_cells(5))), "all of row 5 and nothing in row 4")


func test_ir39_firecracker_swapped_with_plain_is_never_snapped_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "Y", [[5, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 4), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "no snap-back")
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "blast"), 2, "exactly one Firecracker fire = two blast events")
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(5, 4), Vector2i(5, 4)], "centred on its new cell (5,4)")


func test_ir39_match_resolves_first_then_the_firecracker_fires_from_its_new_cell() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "YF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_blast: int = EV.index_of(events, "blast", 0)
	assert_true(i_clear >= 0 and i_blast >= 0, "a match clear and a blast exist")
	assert_true(i_clear < i_blast, "the match's clear event comes first")
	if i_clear >= 0:
		var first: Dictionary = EV.to_set(events[i_clear].cells)
		for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
			assert_true(first.has(c), "R match cell %s" % c)
	var blasts: Array = EV.of_type(events, "blast")
	assert_eq(blasts.size(), 2)
	for b in blasts:
		assert_eq(b.cell, Vector2i(4, 5), "centred on (4,5), where the Firecracker now sits")
		assert_true(EV.same_set(EV.to_set(b.cells), EV.to_set(EV.rect_cells(3, 4, 5, 6))), "area x 3-5, y 4-6")


func test_ir39_crane_swapped_with_plain_fires_from_its_new_cell() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "G", [[4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 0)
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "crane_target"), 1, "the Crane fires (IR-49)")
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 3)], "take-off from (4,3)")


func test_ir39_firecracker_swapped_with_hatchling_fires_and_spares_the_hatchling() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "H", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "accepted")
	assert_eq(board.moves, 9)
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(4, 5), Vector2i(4, 5)], "centred on (4,5)")
	assert_eq(BB.find_drop(board, "OB11").size(), 1, "hatchling not destroyed")
	assert_eq(board.collected_count("OB11"), 0, "and not collected")


func test_ir39_same_setups_with_two_plain_pieces_snap_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "G", [[4, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir39_pending_falls_before_the_special_fires() -> void:
	pending("OQ-44: whether pieces fall and cascades resolve between the swap's match and the special firing")


# ---------------------------------------------------------------- IR-52

func _assert_refused(board: BoardModel, from: Vector2i, to: Vector2i) -> void:
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, from, to)
	assert_eq(BB.snapshot(board), before, "refused swap changes nothing (moves included)")
	assert_eq(board.moves, 10)
	assert_eq(EV.count(events, "invalid_swap"), 1, "refusal reports invalid_swap")


func test_ir52_swap_with_an_obstacle_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	board.add_content("OB02", 4, 4, 2)
	BB.put(board, "R", [[4, 5]])
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))


func test_ir52_diagonal_swap_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	_assert_refused(board, Vector2i(3, 3), Vector2i(4, 4))


func test_ir52_swap_with_a_cocooned_fragment_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	board.add_content("OB07", 2, 2, 1, 1, 1, true)
	BB.put(board, "Y", [[3, 2]])
	_assert_refused(board, Vector2i(3, 2), Vector2i(2, 2))


func test_ir52_swap_with_an_empty_cell_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "X", [[4, 4]])
	BB.put(board, "R", [[4, 5]])
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))


func test_ir52_hatchling_can_be_swapped_when_the_swap_makes_a_match() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "H", [[4, 4]])
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(matched.has(c), "cell %s should match" % c)
	assert_eq(board.moves, 9)
	# The swap moved the hatchling to (4,5); it then fell or was collected at the bottom (IR-51, IR-30).
	assert_eq(BB.find_drop(board, "OB11").size() + board.collected_count("OB11"), 1, "hatchling kept")


func test_ir52_covered_piece_cannot_be_swapped_either_way() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	board.set_overlay(4, 4, "OB03", 1)
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))
	_assert_refused(board, Vector2i(4, 4), Vector2i(4, 5))


func test_ir52_covered_piece_that_would_make_a_match_is_still_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	board.set_overlay(4, 5, "OB03", 1)
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))
