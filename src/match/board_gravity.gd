# Gravity and refill (IR-51, IR-32) and drop-item collection at the bottom (IR-30).
# Items fall straight down; a cell a blocker hides from above is filled by a diagonal slide;
# new pieces come from board.rng and never make a match. Check: test_collectibles_and_gravity.gd.
class_name BoardGravity
extends RefCounted

const MAX_STEPS: int = 2000
const NEW_PIECE_MARK: String = "~new"   # colour a new piece carries until it comes to rest

static var _next_new_id: int = 0


## Falls, slides, refills and collects drop items until nothing changes. Appends events.
static func apply(board: BoardModel, events: Array[BoardEvent]) -> void:
	for _guard in range(MAX_STEPS):
		_fill(board, events)
		if not _collect_drops(board, events):
			return


static func _fill(board: BoardModel, events: Array[BoardEvent]) -> void:
	for _guard in range(MAX_STEPS):
		var moves: Array = []
		_fall_straight(board, moves)
		if _slide_one_pass(board, moves):
			_add_fall_event(events, moves)
			continue
		_add_fall_event(events, moves)
		if not _refill(board, events):
			_color_new_pieces(board)
			return


## Every column: items drop to the bottom of their stretch of cells. Content blockers split a
## column into stretches; cells that are not playable are passed through.
## Open question OQ-35: passing straight through non-playable gaps is a provisional choice.
static func _fall_straight(board: BoardModel, moves: Array) -> void:
	for x in range(board.width):
		var stretch: Array[Vector2i] = []
		for y in range(board.height + 1):
			var blocked: bool = y == board.height or board.get_content(x, y) != null
			if blocked:
				_compact(board, stretch, moves)
				stretch = []
			elif board.is_playable(x, y):
				stretch.append(Vector2i(x, y))


static func _compact(board: BoardModel, stretch: Array[Vector2i], moves: Array) -> void:
	var target: int = stretch.size() - 1
	for i in range(stretch.size() - 1, -1, -1):
		var c: Vector2i = stretch[i]
		if board.has_item(c.x, c.y):
			var to: Vector2i = stretch[target]
			if to != c:
				board.move_piece(c, to)
				moves.append({"from": c, "to": to})
			target -= 1


## Fills empty cells that a blocker hides from above with an item sliding in diagonally.
## Open question OQ-35: upper-left is tried before upper-right (provisional).
static func _slide_one_pass(board: BoardModel, moves: Array) -> bool:
	var slid: bool = false
	for y in range(board.height - 1, 0, -1):
		for x in range(board.width):
			if not board.is_empty(x, y) or _fed_from_above(board, x, y):
				continue
			for dx in [-1, 1]:
				var src: Vector2i = Vector2i(x + dx, y - 1)
				if board.has_item(src.x, src.y):
					board.move_piece(src, Vector2i(x, y))
					moves.append({"from": src, "to": Vector2i(x, y)})
					slid = true
					break
	return slid


## True if nothing but empty or non-playable cells lie between this cell and the top edge.
static func _fed_from_above(board: BoardModel, x: int, y: int) -> bool:
	for yy in range(y - 1, -1, -1):
		if board.get_content(x, yy) != null or board.has_item(x, yy):
			return false
	return true


## New pieces for every empty cell that the top of its column can reach. Returns true if any.
static func _refill(board: BoardModel, events: Array[BoardEvent]) -> bool:
	var filled: Array[Vector2i] = []
	for x in range(board.width):
		for y in range(board.height - 1, -1, -1):
			if board.is_empty(x, y) and _fed_from_above(board, x, y):
				# A unique stand-in colour; the real colour is picked once the piece has stopped moving.
				_next_new_id += 1
				board.set_piece(x, y, "plain", "%s%d" % [NEW_PIECE_MARK, _next_new_id])
				filled.append(Vector2i(x, y))
	if filled.is_empty():
		return false
	var e: BoardEvent = BoardEvent.new("refill")
	e.cells = filled
	events.append(e)
	return true


## Gives every new piece its real colour where it came to rest, bottom row first, so that the
## refill never makes a match (tests/API_CONTRACT.md §2).
static func _color_new_pieces(board: BoardModel) -> void:
	for y in range(board.height - 1, -1, -1):
		for x in range(board.width):
			if board.get_kind(x, y) == "plain" and board.get_color(x, y).begins_with(NEW_PIECE_MARK):
				board.set_piece(x, y, "plain", pick_refill_color(board, Vector2i(x, y)))


## A palette colour from board.rng that does not complete a match with pieces already placed.
static func pick_refill_color(board: BoardModel, cell: Vector2i) -> String:
	var options: Array = board.palette.duplicate()
	var first: String = String(options[board.rng.randi_range(0, options.size() - 1)])
	var pick: String = first
	while not options.is_empty():
		if not MatchFinder.would_match(board, cell, pick):
			return pick
		options.erase(pick)
		if options.is_empty():
			break
		pick = String(options[board.rng.randi_range(0, options.size() - 1)])
	return first   # every colour would match: very rare; the cascade then resolves it


## Drop items resting on the bottom playable cell of their column are collected (IR-30).
static func _collect_drops(board: BoardModel, events: Array[BoardEvent]) -> bool:
	var any: bool = false
	for x in range(board.width):
		if not board.exit_columns.is_empty() and not board.exit_columns.has(x):
			continue
		var y: int = board.bottom_playable_y(x)
		if y < 0:
			continue
		var item: String = board.get_drop_item(x, y)
		if item == "":
			continue
		collect_drop(board, Vector2i(x, y), events)
		any = true
	return any


## Collects the drop item in a cell: count goes up, the cell empties, a `collected` event.
static func collect_drop(board: BoardModel, cell: Vector2i, events: Array[BoardEvent]) -> void:
	var item: String = board.get_drop_item(cell.x, cell.y)
	if item == "":
		return
	board.add_collected(item)
	board.clear_piece(cell.x, cell.y)
	var e: BoardEvent = BoardEvent.new("collected")
	e.cell = cell
	e.data = {"item": item}
	events.append(e)


static func _add_fall_event(events: Array[BoardEvent], moves: Array) -> void:
	if moves.is_empty():
		return
	var e: BoardEvent = BoardEvent.new("fall")
	e.data = {"moves": moves.duplicate()}
	events.append(e)
	moves.clear()
