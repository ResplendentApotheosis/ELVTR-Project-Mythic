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


func test_ir40_start_cell_match_vertical_rocket_is_on_the_start_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[4, 1], [4, 2], [4, 4], [3, 3]])
	BB.put(board, "Y", [[3, 1], [3, 2], [3, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(4, 3))
	var made: Dictionary = _created_set(events)
	assert_eq(_created(events).size(), 2, "exactly two specials")
	assert_true(made.has("rocket_col|R|4,3"), "red column Rocket on the target cell (4,3)")
	assert_true(made.has("rocket_col|Y|3,3"), "yellow column Rocket on the start cell (3,3), not the lowest cell (3,4) (IR-40, 28 Nov)")


func test_ir40_start_cell_match_horizontal_rocket_is_on_the_start_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 3], [3, 3], [5, 3], [4, 4]])
	BB.put(board, "Y", [[2, 4], [3, 4], [5, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	var made: Dictionary = _created_set(events)
	assert_eq(_created(events).size(), 2, "exactly two specials")
	assert_true(made.has("rocket_row|R|4,3"), "red row Rocket on the target cell (4,3)")
	assert_true(made.has("rocket_row|Y|4,4"), "yellow row Rocket on the start cell (4,4), not the left-most cell (2,4) (IR-40, 28 Nov)")


func test_ir40_orb_from_a_swap_appears_on_the_start_cell_when_only_it_is_in_the_match() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "Y", [[0, 5], [1, 5], [3, 5], [4, 5], [2, 6]])
	BB.put(board, "R", [[2, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 5), Vector2i(2, 6))
	assert_eq(EV.matched(events).size(), 5, "Y at (0,5)-(4,5) clear")
	_assert_created_one(events, "orb", "", Vector2i(2, 5))


func test_ir40_single_match_with_only_the_start_cell_puts_the_column_rocket_on_it() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "Y", [[6, 1], [6, 2], [6, 4], [7, 3]])
	BB.put(board, "R", [[6, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(6, 3), Vector2i(7, 3))
	assert_eq(EV.matched(events).size(), 4)
	_assert_created_one(events, "rocket_col", "Y", Vector2i(6, 3))


func test_ir40_cascade_orb_stays_on_the_leftmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[0, 6], [1, 6], [2, 6], [3, 6], [4, 6]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	_assert_created_one(events, "orb", "", Vector2i(0, 6))


func test_ir40_firecracker_provisional_l_with_the_target_cell_is_on_the_target() -> void:
	# OQ-100 provisional: unchanged. Same board as the IR-06 L test.
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 2], [2, 3], [3, 4], [4, 4], [1, 4]])
	BB.put(board, "Y", [[2, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(1, 4), Vector2i(2, 4))
	_assert_created_one(events, "firecracker", "R", Vector2i(2, 4))


func test_ir40_firecracker_provisional_t_with_only_the_start_cell_is_on_the_crossing_cell() -> void:
	# OQ-100 provisional: start (2,3) gets Y from target (2,4); T = (2,3),(3,3),(4,3) + stem (3,2),(3,1); crossing (3,3).
	var board: BoardModel = BB.blank()
	BB.put(board, "Y", [[3, 3], [4, 3], [3, 2], [3, 1], [2, 4]])
	BB.put(board, "R", [[2, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 3), Vector2i(2, 4))
	assert_eq(EV.matched(events).size(), 5)
	_assert_created_one(events, "firecracker", "Y", Vector2i(3, 3))


func test_ir40_crane_provisional_with_only_the_start_cell_is_on_the_lowest_leftmost_cell() -> void:
	# OQ-100 provisional: 2x2 (1,2),(2,2),(1,3),(2,3); start (2,3) gets Y from target (2,4).
	var board: BoardModel = BB.blank()
	BB.put(board, "Y", [[1, 2], [2, 2], [1, 3], [2, 4]])
	BB.put(board, "R", [[2, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 3), Vector2i(2, 4))
	assert_eq(EV.matched(events).size(), 4)
	_assert_created_one(events, "crane", "Y", Vector2i(1, 3))


# Win-finale Rockets are not match specials; see test_finale_rockets.gd (IR-16).

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
	assert_true(made.has("rocket_col|Y|3,3"), "yellow column Rocket at (3,3): the start cell (IR-40, 28 Nov; not (3,4))")
	assert_eq(board.moves, 9)


# ---------------------------------------------------------------- IR-50

func test_ir50_coloured_rocket_in_a_match_clears_and_fires() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 5]])
	BB.put(board, "R-", [[3, 4]])
	BB.put(board, "Y", [[2, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 5), Vector2i(2, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(1, 4), Vector2i(2, 4)]:
		assert_true(matched.has(c), "cell %s is a cleared piece of the match" % c)
	var cleared: Dictionary = EV.cleared(events)
	for c in EV.row_cells(4):
		assert_true(cleared.has(c), "row 4 cleared by the fired rocket: %s" % c)
	# OQ-26: the match resolves first, then the Rocket fires from (3,4).
	var i_match_clear: int = EV.index_of_clear(events, "match")
	var i_fire: int = EV.index_of(events, "rocket_fire")
	assert_true(i_match_clear >= 0 and i_fire > i_match_clear, "match clear event comes before the Rocket fires")
	if i_match_clear >= 0:
		var first: Dictionary = EV.to_set(events[i_match_clear].cells)
		for c in [Vector2i(1, 4), Vector2i(2, 4)]:
			assert_true(first.has(c), "the first clear is the match, includes %s" % c)
		assert_false(first.has(Vector2i(3, 4)), "IR-50: the lifted Rocket is not in the match's clear event")
	assert_eq(EV.cells_of(events, "rocket_fire"), [Vector2i(3, 4)], "fires from (3,4)")
	# OQ-44 A: only the fall and refill happen between the match clear and the Rocket firing.
	var i_fall: int = EV.index_after(events, "fall", i_match_clear)
	var i_refill: int = EV.index_after(events, "refill", i_fall)
	assert_true(i_fall > i_match_clear and i_refill > i_fall and i_refill < i_fire, "match clear, fall, refill, then the Rocket fires")


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



func test_ir50_matched_rocket_is_lifted_and_the_row_clear_counts_eleven_pieces() -> void:
	# OQ-54 A. R at (1,4); Y at (2,4); red row Rocket at (3,4); R at (2,5). Swap (2,5)->(2,4).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R", [[1, 4], [2, 5]])
	BB.put(board, "Y", [[2, 4]])
	BB.put(board, "R-", [[3, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 5), Vector2i(2, 4))
	assert_eq(EV.count(events, "match"), 1, "no cascade match in this set-up")
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_fall: int = EV.index_after(events, "fall", i_clear)
	var i_refill: int = EV.index_after(events, "refill", i_fall)
	var i_fire: int = EV.index_of(events, "rocket_fire")
	assert_true(i_clear >= 0 and i_fall > i_clear and i_refill > i_fall and i_fire > i_refill, "match clear, fall, refill, Rocket fire")
	if i_fall >= 0:
		var moved: Dictionary = EV.fall_map(events[i_fall])
		for x in [1, 2, 3]:
			assert_eq(moved.get(Vector2i(x, 4)), Vector2i(x, 3), "column %d drops by one, (3,4) included because the Rocket was lifted" % x)
	if i_refill >= 0:
		assert_true(EV.same_set(EV.to_set(events[i_refill].cells), EV.to_set([Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])), "new pieces at (1,0),(2,0),(3,0)")
	if i_fire >= 0:
		assert_eq(events[i_fire].cell, Vector2i(3, 4), "fires from the cell it was matched in")
		assert_eq(events[i_fire].cells.size(), 9, "row 4")
	assert_eq(EV.cleared_total(events), 11, "2 matched pieces + 9 pieces of row 4 (including the one that fell into (3,4))")


# ---------------------------------------------------------------- IR-40 onto a covered cell (OQ-57 A)

func test_ir40_cascade_special_on_a_covered_cell_appears_there_locked() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	BB.put(board, "R", [[2, 6], [3, 6], [4, 6], [5, 6]])
	board.set_overlay(2, 6, "OB03", 2)
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	var cleared: Dictionary = EV.cleared(events)
	for x in [2, 3, 4, 5]:
		assert_true(cleared.has(Vector2i(x, 6)), "R at (%d,6) cleared" % x)
	assert_eq(board.overlay_hp(2, 6), 1, "moss hp 2 -> 1")
	_assert_created_one(events, "rocket_row", "R", Vector2i(2, 6))
	assert_eq(board.get_kind(2, 6), "rocket_row", "the Rocket sits at (2,6), under the moss")
	assert_eq(board.get_color(2, 6), "R")
