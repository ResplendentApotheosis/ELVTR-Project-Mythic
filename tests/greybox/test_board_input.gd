# GUT tests for BoardInput (click, drag and tap on the board, in board pixels).
# API: tests/API_CONTRACT.md section 13. Also IR-02 (tap a special) and IR-01 (swap neighbours).
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")
const S: float = 100.0


func _bi(w: int = 4, h: int = 3) -> BoardInput:
	return BoardInput.new(w, h, S)


func _click(i: BoardInput, board: BoardModel, cell: Vector2i) -> Dictionary:
	var p: Vector2 = BoardInput.cell_center(cell, S)
	i.press(p)
	return i.release(p, board)


func test_pixel_to_cell() -> void:
	assert_eq(BoardInput.pixel_to_cell(Vector2(0, 0), S, 4, 3), Vector2i(0, 0))
	assert_eq(BoardInput.pixel_to_cell(Vector2(199, 250), S, 4, 3), Vector2i(1, 2))
	assert_eq(BoardInput.pixel_to_cell(Vector2(-1, 5), S, 4, 3), BoardInput.NO_CELL)
	assert_eq(BoardInput.pixel_to_cell(Vector2(400, 5), S, 4, 3), BoardInput.NO_CELL)
	assert_eq(BoardInput.pixel_to_cell(Vector2(5, 300), S, 4, 3), BoardInput.NO_CELL)


func test_cell_center_round_trip() -> void:
	assert_eq(BoardInput.cell_center(Vector2i(2, 1), S), Vector2(250, 150))
	assert_eq(BoardInput.pixel_to_cell(BoardInput.cell_center(Vector2i(3, 2), S), S, 4, 3), Vector2i(3, 2))


func test_is_adjacent() -> void:
	assert_true(BoardInput.is_adjacent(Vector2i(1, 1), Vector2i(2, 1)))
	assert_true(BoardInput.is_adjacent(Vector2i(1, 1), Vector2i(1, 0)))
	assert_false(BoardInput.is_adjacent(Vector2i(1, 1), Vector2i(2, 2)))
	assert_false(BoardInput.is_adjacent(Vector2i(1, 1), Vector2i(1, 1)))
	assert_false(BoardInput.is_adjacent(Vector2i(1, 1), Vector2i(3, 1)))


func test_drag_neighbour_threshold_and_direction() -> void:
	var f: Vector2i = Vector2i(1, 1)
	assert_eq(BoardInput.drag_neighbour(f, Vector2(39, 0), S), BoardInput.NO_CELL)
	assert_eq(BoardInput.drag_neighbour(f, Vector2(41, 0), S), Vector2i(2, 1))
	assert_eq(BoardInput.drag_neighbour(f, Vector2(-50, 10), S), Vector2i(0, 1))
	assert_eq(BoardInput.drag_neighbour(f, Vector2(10, -60), S), Vector2i(1, 0))
	assert_eq(BoardInput.drag_neighbour(f, Vector2(10, 60), S), Vector2i(1, 2))
	assert_eq(BoardInput.drag_neighbour(f, Vector2(50, 50), S), Vector2i(2, 1), "exact diagonal counts as sideways")


func test_click_piece_selects() -> void:
	var b: BoardModel = BB.blank(4, 3)
	var r: Dictionary = _click(_bi(), b, Vector2i(1, 1))
	assert_eq(r.action, "select")
	assert_eq(r.cell, Vector2i(1, 1))


func test_click_selected_again_deselects() -> void:
	var b: BoardModel = BB.blank(4, 3)
	var i: BoardInput = _bi()
	_click(i, b, Vector2i(1, 1))
	assert_eq(_click(i, b, Vector2i(1, 1)).action, "deselect")
	assert_eq(i.selected, BoardInput.NO_CELL)


func test_click_neighbour_swaps() -> void:
	var b: BoardModel = BB.blank(4, 3)
	var i: BoardInput = _bi()
	_click(i, b, Vector2i(1, 1))
	var r: Dictionary = _click(i, b, Vector2i(2, 1))
	assert_eq(r.action, "swap")
	assert_eq(r.from, Vector2i(1, 1))
	assert_eq(r.to, Vector2i(2, 1))


func test_click_far_cell_moves_selection() -> void:
	var b: BoardModel = BB.blank(4, 3)
	var i: BoardInput = _bi()
	_click(i, b, Vector2i(0, 0))
	var r: Dictionary = _click(i, b, Vector2i(3, 2))
	assert_eq(r.action, "select")
	assert_eq(i.selected, Vector2i(3, 2))


func test_IR02_click_special_with_nothing_selected_is_tap() -> void:
	var b: BoardModel = BB.from_rows(["R- Y B G", ". . . .", ". . . ."])
	var r: Dictionary = _click(_bi(), b, Vector2i(0, 0))
	assert_eq(r.action, "tap")
	assert_eq(r.cell, Vector2i(0, 0))


func test_click_special_next_to_selected_is_a_swap_not_tap() -> void:
	var b: BoardModel = BB.from_rows(["R- Y B G", ". . . .", ". . . ."])
	var i: BoardInput = _bi()
	_click(i, b, Vector2i(1, 0))
	assert_eq(_click(i, b, Vector2i(0, 0)).action, "swap")


func test_empty_or_unplayable_cell_is_not_selectable() -> void:
	var b: BoardModel = BB.from_rows(["R X # G", ". . . .", ". . . ."])
	var i: BoardInput = _bi()
	assert_ne(_click(i, b, Vector2i(1, 0)).action, "select")
	assert_ne(_click(i, b, Vector2i(2, 0)).action, "select")
	assert_eq(i.selected, BoardInput.NO_CELL)


func test_drop_item_is_selectable() -> void:
	var b: BoardModel = BB.from_rows(["H Y B G", ". . . .", ". . . ."])
	assert_eq(_click(_bi(), b, Vector2i(0, 0)).action, "select")


func test_drag_swaps_once() -> void:
	var b: BoardModel = BB.blank(4, 3)
	var i: BoardInput = _bi()
	var c: Vector2 = BoardInput.cell_center(Vector2i(1, 1), S)
	i.press(c)
	assert_eq(i.move(c + Vector2(10, 0)).action, "none")
	var r: Dictionary = i.move(c + Vector2(60, 5))
	assert_eq(r.action, "swap")
	assert_eq(r.from, Vector2i(1, 1))
	assert_eq(r.to, Vector2i(2, 1))
	assert_eq(i.move(c + Vector2(90, 5)).action, "none", "only once")
	assert_eq(i.release(BoardInput.cell_center(Vector2i(2, 1), S), b).action, "none", "release after a drag does nothing")


func test_drag_off_the_board_does_nothing() -> void:
	var i: BoardInput = _bi()
	var c: Vector2 = BoardInput.cell_center(Vector2i(0, 0), S)
	i.press(c)
	assert_eq(i.move(c + Vector2(-60, 0)).action, "none")


func test_cancel_forgets_selection() -> void:
	var b: BoardModel = BB.blank(4, 3)
	var i: BoardInput = _bi()
	_click(i, b, Vector2i(1, 1))
	i.cancel()
	assert_eq(i.selected, BoardInput.NO_CELL)
	assert_eq(_click(i, b, Vector2i(2, 1)).action, "select", "not a swap any more")
