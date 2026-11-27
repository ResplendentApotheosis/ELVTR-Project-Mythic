# GUT tests for IR-03..IR-08, IR-40, IR-42, IR-43, IR-50 (match detection, special creation).
# API: tests/API_CONTRACT.md. Cascade matches are made with MatchResolver.settle(board).
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


func _created(events: Array[BoardEvent]) -> Array:
	return EV.of_type(events, "special_created")

func _kinds(events: Array[BoardEvent]) -> Array:
	var out: Array = []
	for e in _created(events):
		out.append(e.kind)
	return out


func _colors(events: Array[BoardEvent]) -> Array:
	var out: Array = []
	for e in _created(events):
		out.append(e.color)
	return out



func _assert_created_one(events: Array[BoardEvent], kind: String, color: String, cell: Vector2i) -> void:
	var made: Array = _created(events)
	assert_eq(made.size(), 1, "exactly one special created")
	if made.size() == 1:
		assert_eq(made[0].kind, kind)
		assert_eq(made[0].color, color)
		assert_eq(made[0].cell, cell)


# ---------------------------------------------------------------- IR-03

func test_ir03_horizontal_three_clears() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 2], [2, 2], [3, 3]])
	BB.put(board, "Y", [[3, 2]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(3, 2))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]:
		assert_true(matched.has(c))


func test_ir03_vertical_three_clears() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[5, 1], [5, 2], [6, 3]])
	BB.put(board, "Y", [[5, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(6, 3), Vector2i(5, 3))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(5, 1), Vector2i(5, 2), Vector2i(5, 3)]:
		assert_true(matched.has(c))


func test_ir03_two_in_line_plus_a_stray_is_not_a_match() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[1, 2], [2, 2], [3, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- IR-04

func test_ir04_two_by_two_square_makes_a_crane() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 2], [3, 2], [3, 3], [1, 3]])
	BB.put(board, "Y", [[2, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(1, 3), Vector2i(2, 3))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]:
		assert_true(matched.has(c))
	_assert_created_one(events, "crane", "R", Vector2i(2, 3))


# ---------------------------------------------------------------- IR-05

func test_ir05_horizontal_four_makes_row_rocket() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 4], [4, 4], [3, 5]])
	BB.put(board, "Y", [[3, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 5), Vector2i(3, 4))
	assert_eq(EV.matched(events).size(), 4)
	_assert_created_one(events, "rocket_row", "R", Vector2i(3, 4))


func test_ir05_vertical_four_makes_column_rocket() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[5, 1], [5, 2], [5, 4], [4, 3]])
	BB.put(board, "Y", [[5, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 3), Vector2i(5, 3))
	assert_eq(EV.matched(events).size(), 4)
	_assert_created_one(events, "rocket_col", "R", Vector2i(5, 3))


# ---------------------------------------------------------------- IR-06

func test_ir06_l_shape_by_swap_makes_firecracker() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 2], [2, 3], [3, 4], [4, 4], [1, 4]])
	BB.put(board, "Y", [[2, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(1, 4), Vector2i(2, 4))
	assert_eq(EV.matched(events).size(), 5)
	_assert_created_one(events, "firecracker", "R", Vector2i(2, 4))


func test_ir06_t_shape_by_cascade_makes_firecracker_on_crossing_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 2], [3, 2], [4, 2], [3, 3], [3, 4]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.matched(events).size(), 5)
	_assert_created_one(events, "firecracker", "R", Vector2i(3, 2))


func test_ir06_plus_shape_by_cascade_makes_one_firecracker_on_the_crossing_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[3, 1], [2, 2], [3, 2], [4, 2], [3, 3]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.matched(events).size(), 5)
	_assert_created_one(events, "firecracker", "R", Vector2i(3, 2))


# ---------------------------------------------------------------- IR-07

func test_ir07_five_in_a_line_by_swap_makes_jade_orb() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[0, 6], [1, 6], [3, 6], [4, 6], [2, 7]])
	BB.put(board, "Y", [[2, 6]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 7), Vector2i(2, 6))
	assert_eq(EV.matched(events).size(), 5)
	_assert_created_one(events, "orb", "", Vector2i(2, 6))


func test_ir07_six_in_a_line_by_cascade_makes_one_orb_at_lowest_leftmost() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[0, 6], [1, 6], [2, 6], [3, 6], [4, 6], [5, 6]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.matched(events).size(), 6)
	_assert_created_one(events, "orb", "", Vector2i(0, 6))


func test_ir07_seven_in_a_line_by_cascade_makes_one_orb() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[0, 6], [1, 6], [2, 6], [3, 6], [4, 6], [5, 6], [6, 6]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.matched(events).size(), 7)
	assert_eq(_created(events).size(), 1)
	assert_eq(_kinds(events), ["orb"])


# ---------------------------------------------------------------- IR-08

func test_ir08_five_line_that_is_also_a_t_makes_only_an_orb() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [4, 3], [4, 2]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	var made: Array = _created(events)
	assert_eq(made.size(), 1, "one special only")
	assert_eq(_kinds(events), ["orb"])


func test_ir08_four_line_that_is_also_an_l_makes_only_a_firecracker() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 4], [3, 4], [4, 4], [5, 4], [2, 3], [2, 2]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	var made: Array = _created(events)
	assert_eq(made.size(), 1)
	assert_eq(_kinds(events), ["firecracker"])


func test_ir08_four_line_that_contains_a_square_makes_only_a_rocket() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 4], [3, 4], [4, 4], [5, 4], [2, 3], [3, 3]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	var made: Array = _created(events)
	assert_eq(made.size(), 1)
	assert_eq(_kinds(events), ["rocket_row"])


# ---------------------------------------------------------------- IR-40

func test_ir40_swap_special_appears_on_the_target_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 4], [4, 4], [3, 5]])
	BB.put(board, "Y", [[3, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 5), Vector2i(3, 4))
	_assert_created_one(events, "rocket_row", "R", Vector2i(3, 4))


func test_ir40_swap_special_is_on_target_cell_not_the_lowest_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[6, 2], [6, 3], [6, 5], [5, 4]])
	BB.put(board, "Y", [[6, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 4), Vector2i(6, 4))
	_assert_created_one(events, "rocket_col", "R", Vector2i(6, 4))


func test_ir40_cascade_row_rocket_on_leftmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 6], [3, 6], [4, 6], [5, 6]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	_assert_created_one(events, "rocket_row", "R", Vector2i(2, 6))


func test_ir40_cascade_column_rocket_on_lowest_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[7, 1], [7, 2], [7, 3], [7, 4]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	_assert_created_one(events, "rocket_col", "R", Vector2i(7, 4))


func test_ir40_cascade_square_crane_on_lowest_then_leftmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "Y", [[5, 2], [6, 2], [5, 3], [6, 3]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	_assert_created_one(events, "crane", "Y", Vector2i(5, 3))


func _created_set(events: Array[BoardEvent]) -> Dictionary:
	var out: Dictionary = {}
	for e in _created(events):
		out["%s|%s|%d,%d" % [e.kind, e.color, e.cell.x, e.cell.y]] = true
	return out


func test_ir40_start_cell_match_vertical_uses_the_lowest_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[4, 1], [4, 2], [4, 4], [3, 3]])
	BB.put(board, "Y", [[3, 1], [3, 2], [3, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(4, 3))
	var made: Dictionary = _created_set(events)
	assert_eq(_created(events).size(), 2, "exactly two specials")
	assert_true(made.has("rocket_col|R|4,3"), "red column Rocket on the target cell (4,3)")
	assert_true(made.has("rocket_col|Y|3,4"), "yellow column Rocket on the lowest cell (3,4) of its match")


func test_ir40_start_cell_match_horizontal_uses_the_leftmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 3], [3, 3], [5, 3], [4, 4]])
	BB.put(board, "Y", [[2, 4], [3, 4], [5, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	var made: Dictionary = _created_set(events)
	assert_eq(_created(events).size(), 2, "exactly two specials")
	assert_true(made.has("rocket_row|R|4,3"), "red row Rocket on the target cell (4,3)")
	assert_true(made.has("rocket_row|Y|2,4"), "yellow row Rocket on the left-most cell (2,4) of its match")


func test_ir40_pending_finale_rockets() -> void:
	pending("OQ-40: direction (and placement) of the win-finale Rockets; not a match special")


# ---------------------------------------------------------------- IR-42

func test_ir42_fall_that_lines_up_four_makes_a_rocket_without_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "B", [[0, 7], [1, 7], [2, 7], [3, 7]])
	BB.put(board, "X", [[0, 8], [1, 8], [2, 8], [3, 8]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	_assert_created_one(events, "rocket_row", "B", Vector2i(0, 8))
	assert_eq(board.moves, 10, "cascades use no move")


func test_ir42_vertical_five_by_cascade_makes_an_orb_at_the_lowest_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "G", [[4, 2], [4, 3], [4, 4], [4, 5], [4, 6]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	_assert_created_one(events, "orb", "", Vector2i(4, 6))


# ---------------------------------------------------------------- IR-43

func test_ir43_one_swap_two_matches_both_clear_and_first_special_on_target() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[3, 3], [4, 1], [4, 2], [4, 4]])
	BB.put(board, "Y", [[4, 3], [3, 4], [3, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(4, 3))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(4, 1), Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4), Vector2i(3, 3), Vector2i(3, 4), Vector2i(3, 5)]:
		assert_true(matched.has(c), "cell %s should be in a match" % c)
	_assert_created_one(events, "rocket_col", "R", Vector2i(4, 3))
	assert_eq(board.moves, 9)


func test_ir43_two_four_lines_clear_eight_and_make_two_rockets() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[4, 1], [4, 2], [4, 4], [3, 3]])
	BB.put(board, "Y", [[3, 1], [3, 2], [3, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(4, 3))
	assert_eq(EV.matched(events).size(), 8, "8 pieces in two matches")
	var made: Dictionary = _created_set(events)
	assert_eq(_created(events).size(), 2, "exactly two specials")
	assert_true(made.has("rocket_col|R|4,3"), "red column Rocket at (4,3)")
	assert_true(made.has("rocket_col|Y|3,4"), "yellow column Rocket at (3,4): lowest cell of the start-cell match (OQ-25)")
	assert_eq(board.moves, 9)


# ---------------------------------------------------------------- IR-50

func test_ir50_coloured_rocket_in_a_match_clears_and_fires() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 5]])
	BB.put(board, "R-", [[3, 4]])
	BB.put(board, "Y", [[2, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 5), Vector2i(2, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)]:
		assert_true(matched.has(c), "cell %s in the 3-match" % c)
	var cleared: Dictionary = EV.cleared(events)
	for c in EV.row_cells(4):
		assert_true(cleared.has(c), "row 4 cleared by the fired rocket: %s" % c)
	# OQ-26: the match resolves first, then the Rocket fires from (3,4).
	var i_match_clear: int = EV.index_of_clear(events, "match")
	var i_fire: int = EV.index_of(events, "rocket_fire")
	assert_true(i_match_clear >= 0 and i_fire > i_match_clear, "match clear event comes before the Rocket fires")
	if i_match_clear >= 0:
		var first: Dictionary = EV.to_set(events[i_match_clear].cells)
		for c in [Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)]:
			assert_true(first.has(c), "the first clear is the 3-match, includes %s" % c)
	assert_eq(EV.cells_of(events, "rocket_fire"), [Vector2i(3, 4)], "fires from (3,4)")


func test_ir50_jade_orb_is_never_part_of_a_match() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 4], [4, 4], [5, 4]])
	BB.put(board, "O", [[3, 4]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.matched(events).size(), 0)
	assert_eq(board.get_kind(3, 4), "orb", "the Orb stays")


func test_ir50_crane_reports_the_colour_it_was_made_from() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "Y", [[5, 2], [6, 2], [5, 3], [6, 3]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	var made: Array = _created(events)
	assert_eq(made.size(), 1)
	assert_eq(_kinds(events), ["crane"])
	assert_eq(_colors(events), ["Y"])

