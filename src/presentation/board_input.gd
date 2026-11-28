# Turns mouse or finger input on the board into what the player meant: select a cell, swap two cells
# (click one then a neighbour, or press and drag toward a neighbour), or tap a special (click it without dragging).
# Pure logic: positions are in the board's own pixels (top-left of cell (0,0) = (0,0)); no nodes.
# Check: GUT tests for BoardInput (test-engineer); in the greybox scene, click or drag pieces.
class_name BoardInput
extends RefCounted

const NO_CELL: Vector2i = Vector2i(-1, -1)
const DRAG_THRESHOLD: float = 0.4   # a drag counts once the finger moved 40% of a cell (provisional)

var width: int
var height: int
var cell_size: float
var selected: Vector2i = NO_CELL     # the cell picked by a first click, or NO_CELL

var _press_cell: Vector2i = NO_CELL
var _press_pos: Vector2 = Vector2.ZERO
var _dragged: bool = false


func _init(board_width: int, board_height: int, size: float) -> void:
	width = board_width
	height = board_height
	cell_size = size


# ---------------------------------------------------------------- cell maths (static)

## The cell under a pixel, or NO_CELL outside the board.
static func pixel_to_cell(pos: Vector2, size: float, board_width: int, board_height: int) -> Vector2i:
	if pos.x < 0.0 or pos.y < 0.0:
		return NO_CELL
	var cell: Vector2i = Vector2i(int(pos.x / size), int(pos.y / size))
	if cell.x >= board_width or cell.y >= board_height:
		return NO_CELL
	return cell


## The pixel at the centre of a cell.
static func cell_center(cell: Vector2i, size: float) -> Vector2:
	return Vector2((cell.x + 0.5) * size, (cell.y + 0.5) * size)


## True when the two cells touch side by side or one above the other (never diagonally).
static func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return absi(a.x - b.x) + absi(a.y - b.y) == 1


## The neighbour a drag points at, or NO_CELL while the drag is shorter than `threshold` cells.
## The longer direction wins; an exact diagonal counts as sideways.
static func drag_neighbour(from: Vector2i, delta: Vector2, size: float, threshold: float = DRAG_THRESHOLD) -> Vector2i:
	if delta.length() < threshold * size:
		return NO_CELL
	if absf(delta.x) >= absf(delta.y):
		return from + Vector2i(1 if delta.x > 0.0 else -1, 0)
	return from + Vector2i(0, 1 if delta.y > 0.0 else -1)


# ---------------------------------------------------------------- gestures

## Finger or mouse button down.
func press(pos: Vector2) -> void:
	_press_cell = pixel_to_cell(pos, cell_size, width, height)
	_press_pos = pos
	_dragged = false


## Finger or mouse moved while down. Returns {"action": "swap", "from", "to"} once, when the drag is
## long enough and points at a cell on the board; otherwise {"action": "none"}.
func move(pos: Vector2) -> Dictionary:
	if _press_cell == NO_CELL or _dragged:
		return {"action": "none"}
	var target: Vector2i = drag_neighbour(_press_cell, pos - _press_pos, cell_size)
	if target == NO_CELL:
		return {"action": "none"}
	_dragged = true
	selected = NO_CELL
	if target.x < 0 or target.y < 0 or target.x >= width or target.y >= height:
		return {"action": "none"}
	return {"action": "swap", "from": _press_cell, "to": target}


## Finger or mouse button up. A click (no drag, same cell) returns one of:
## {"action": "swap", "from": selected, "to": cell} when a neighbour of the selected cell is clicked;
## {"action": "deselect"} when the selected cell is clicked again;
## {"action": "tap", "cell"} when a special is clicked (and it is not a swap);
## {"action": "select", "cell"} when a cell holding a piece or drop item is clicked;
## {"action": "none"} otherwise.
func release(pos: Vector2, board: BoardModel) -> Dictionary:
	var cell: Vector2i = pixel_to_cell(pos, cell_size, width, height)
	var was_click: bool = not _dragged and cell != NO_CELL and cell == _press_cell
	_press_cell = NO_CELL
	_dragged = false
	if not was_click:
		return {"action": "none"}
	if selected != NO_CELL and is_adjacent(selected, cell):
		var from: Vector2i = selected
		selected = NO_CELL
		return {"action": "swap", "from": from, "to": cell}
	if selected == cell:
		selected = NO_CELL
		return {"action": "deselect"}
	if board.is_special(cell.x, cell.y):
		selected = NO_CELL
		return {"action": "tap", "cell": cell}
	if board.has_item(cell.x, cell.y):
		selected = cell
		return {"action": "select", "cell": cell}
	selected = NO_CELL
	return {"action": "deselect"}


## Forgets any press and selection (e.g. when a panel opens).
func cancel() -> void:
	_press_cell = NO_CELL
	_dragged = false
	selected = NO_CELL
