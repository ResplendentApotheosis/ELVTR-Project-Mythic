# Gravity and refill (IR-51, IR-32) and drop-item collection at the bottom (IR-30).
# Items fall straight down first; then a cell a blocker hides from above is filled by a diagonal
# slide (upper-left first); new pieces enter at each column's top playable cell and at spawners,
# coloured from board.rng so they never make a match; each refill event lists their colours (data.colors).
# Check: test_collectibles_and_gravity.gd and test_refill_colors.gd.
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


## Owner decision OQ-35: straight falls first, then one diagonal slide at a time, then refill.
static func _fill(board: BoardModel, events: Array[BoardEvent]) -> void:
	# Speed: with no empty cell nothing can fall, slide or refill, so there is nothing to do.
	if not board.has_empty_cell():
		return
	var first_new_event: int = events.size()
	for _guard in range(MAX_STEPS):
		var moves: Array = []
		_fall_straight(board, moves)
		var slid: bool = _slide_one(board, moves)
		_add_fall_event(events, moves)
		if slid:
			continue
		if not _refill(board, events):
			var real_colors: Dictionary = _color_new_pieces(board)
			_put_colors_on_refills(events, first_new_event, real_colors)
			return


## Owner, 28 Nov 2026: each refill event's data.colors lists every new piece's real colour (parallel to
## cells). While falling, a piece carries its stand-in name; here each stand-in is swapped for its colour.
static func _put_colors_on_refills(events: Array[BoardEvent], from_index: int, real_colors: Dictionary) -> void:
	for i in range(from_index, events.size()):
		var e: BoardEvent = events[i]
		if e.type != "refill":
			continue
		var colors: Array = []
		for stand_in in e.data.get("colors", []):
			colors.append(String(real_colors.get(stand_in, stand_in)))
		e.data["colors"] = colors


## True if this cell stops pieces from falling through it: a content blocker, or a piece locked
## under an overlay (IR-54). An empty cell under an overlay is filled like any other cell.
static func _is_stopper(board: BoardModel, x: int, y: int) -> bool:
	return board.get_content(x, y) != null or board.is_locked(x, y)


## Every column: items drop to the bottom of their stretch of cells. Stoppers split a column
## into stretches. Owner decision OQ-45 (chat 27 Nov 2026): non-playable cells are passed through.
static func _fall_straight(board: BoardModel, moves: Array) -> void:
	for x in range(board.width):
		if not _column_has_empty(board, x):
			continue   # speed: a column with no empty cell has nothing to fall into
		var stretch: Array[Vector2i] = []
		for y in range(board.height + 1):
			if y == board.height or _is_stopper(board, x, y):
				_compact(board, stretch, moves)
				stretch = []
			elif board.is_playable(x, y):
				stretch.append(Vector2i(x, y))


static func _column_has_empty(board: BoardModel, x: int) -> bool:
	for y in range(board.height):
		if board.is_empty(x, y):
			return true
	return false


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


## Fills ONE empty cell that a stopper hides from above (lowest row first, then left-most) with
## an item sliding in diagonally, upper-left before upper-right (owner decision OQ-35).
## Owner decision OQ-41 (chat 27 Nov 2026): a locked piece is a blocker, so cells below it fill the same way.
static func _slide_one(board: BoardModel, moves: Array) -> bool:
	for y in range(board.height - 1, 0, -1):
		for x in range(board.width):
			if not board.is_empty(x, y) or not _blocked_above(board, x, y):
				continue
			for dx in [-1, 1]:
				var src: Vector2i = Vector2i(x + dx, y - 1)
				if board.has_item(src.x, src.y) and not board.is_locked(src.x, src.y):
					board.move_piece(src, Vector2i(x, y))
					moves.append({"from": src, "to": Vector2i(x, y)})
					return true
	return false


## True if a stopper sits above this cell with only empty or non-playable cells in between.
static func _blocked_above(board: BoardModel, x: int, y: int) -> bool:
	for yy in range(y - 1, -1, -1):
		if _is_stopper(board, x, yy):
			return true
		if board.has_item(x, yy):
			return false
	return false


## True if nothing but empty or non-playable cells lie between this cell and the top edge.
static func _open_to_top(board: BoardModel, x: int, y: int) -> bool:
	for yy in range(y - 1, -1, -1):
		if board.get_content(x, yy) != null or board.has_item(x, yy):
			return false
	return true


## New pieces for every empty cell that the top of its column can reach, and for empty spawner
## cells (owner decision OQ-35). Returns true if any piece was added.
static func _refill(board: BoardModel, events: Array[BoardEvent]) -> bool:
	var filled: Array[Vector2i] = []
	var stand_ins: Array = []   # the colours are filled in later by _put_colors_on_refills
	for x in range(board.width):
		for y in range(board.height - 1, -1, -1):
			if board.is_empty(x, y) and (_open_to_top(board, x, y) or board.spawners.has(Vector2i(x, y))):
				# A unique stand-in colour; the real colour is picked once the piece has stopped moving.
				_next_new_id += 1
				var stand_in: String = "%s%d" % [NEW_PIECE_MARK, _next_new_id]
				board.set_piece(x, y, "plain", stand_in)
				stand_ins.append(stand_in)
				filled.append(Vector2i(x, y))
	if filled.is_empty():
		return false
	var e: BoardEvent = BoardEvent.new("refill")
	e.cells = filled
	e.data = {"colors": stand_ins}
	events.append(e)
	return true


## Gives every new piece its real colour where it came to rest, bottom row first, so that the
## refill never makes a match (tests/API_CONTRACT.md §2). Returns {stand-in name: real colour}.
static func _color_new_pieces(board: BoardModel) -> Dictionary:
	var real_colors: Dictionary = {}
	var colors: PackedStringArray = board.color_grid()   # speed: read once; only stand-ins are looked at
	for y in range(board.height - 1, -1, -1):
		for x in range(board.width):
			var stand_in: String = colors[y * board.width + x]
			if stand_in.begins_with(NEW_PIECE_MARK) and board.get_kind(x, y) == "plain":
				var color: String = pick_refill_color(board, Vector2i(x, y))
				board.set_piece(x, y, "plain", color)
				real_colors[stand_in] = color
	return real_colors


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
	if item == "fragment":
		e.data["carrier"] = "OB11"   # a fragment on a drop item also counts for a plain OB11 goal (IR-31)
	events.append(e)
	GoalHook.announce(board, events)


static func _add_fall_event(events: Array[BoardEvent], moves: Array) -> void:
	if moves.is_empty():
		return
	var e: BoardEvent = BoardEvent.new("fall")
	e.data = {"moves": moves.duplicate()}
	events.append(e)
	moves.clear()
