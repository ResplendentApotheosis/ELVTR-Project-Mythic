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

func test_ir39_firecracker_swapped_with_plain_is_never_snapped_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "Y", [[5, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 4), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "no snap-back")
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "blast"), 2, "exactly one Firecracker fire = two blast events")


func test_ir39_crane_swapped_with_plain_fires_and_costs_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "G", [[4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 0)
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "crane_target"), 1, "the Crane fires (IR-49)")


func test_ir39_same_setup_with_two_plain_pieces_snaps_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "G", [[4, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir39_pending_firing_cell_and_order_with_a_match() -> void:
	pending("OQ-26: which cell a swapped special fires from, and order when the swap also makes a match")


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
	assert_eq(BB.find_drop(board, "OB11"), [Vector2i(4, 5)] as Array[Vector2i], "hatchling moved to (4,5)")
	assert_eq(board.moves, 9)


func test_ir52_pending_covered_pieces_and_drop_item_no_match_swaps() -> void:
	pending("OQ-29 (pieces under an overlay) and OQ-30 (drop item swaps with no match / with a special)")
