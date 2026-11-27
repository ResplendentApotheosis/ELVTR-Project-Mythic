# Fires single specials: Rocket line (IR-16), Firecracker double 3x3 blast (IR-17), Jade Orb colour
# clear (IR-18, IR-19), Paper Crane flight (IR-20, IR-48). Specials they cover fire afterwards as a
# chain (IR-41). Covered cells lose their piece and take one top-layer hit (IR-09). Check: test_special_effects.gd.
class_name SpecialFiring
extends RefCounted

const MAX_FIRES: int = 500


## Fires every order in the queue, plus any specials they set off, one after another.
static func run(board: BoardModel, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var fired: int = 0
	while not queue.is_empty() and fired < MAX_FIRES:
		var order: FireOrder = queue.pop_front()
		fire(board, order, queue, events)
		fired += 1


static func fire(board: BoardModel, order: FireOrder, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	if order.on_board and board.get_kind(order.cell.x, order.cell.y) != order.kind:
		return   # already gone (set off earlier in this resolve)
	match order.kind:
		"rocket_row", "rocket_col":
			_fire_rocket(board, order, queue, events)
		"firecracker":
			_fire_firecracker(board, order, queue, events)
		"orb":
			fire_orb(board, order, most_common_color(board), queue, events)
		"crane":
			fire_crane(board, order, queue, events)


# ---------------------------------------------------------------- the four specials

static func _fire_rocket(board: BoardModel, order: FireOrder, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var own: Array[Vector2i] = take_off_board(board, order)
	var cells: Array[Vector2i] = row_cells(board, order.cell.y) if order.kind == "rocket_row" else col_cells(board, order.cell.x)
	var e: BoardEvent = BoardEvent.new("rocket_fire")
	e.cell = order.cell
	e.kind = order.kind
	e.color = order.color
	e.cells = cells
	events.append(e)
	cover(board, cells, {}, "special", queue, events, own)


## Two blasts on the same 3x3, with a fall between; one hit per obstacle in total (IR-12).
## Open question OQ-32: pieces fall and refill between blasts; cascades wait until after blast 2.
static func _fire_firecracker(board: BoardModel, order: FireOrder, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var own: Array[Vector2i] = take_off_board(board, order)
	double_blast(board, rect_cells(board, order.cell, 1), order.cell, {}, "special", queue, events, own)


static func double_blast(board: BoardModel, area: Array[Vector2i], centre: Vector2i, hitset: Dictionary, source: String,
		queue: Array[FireOrder], events: Array[BoardEvent], own: Array[Vector2i]) -> void:
	for index in [1, 2]:
		var e: BoardEvent = BoardEvent.new("blast")
		e.cell = centre
		e.cells = area
		e.data = {"index": index}
		events.append(e)
		cover(board, area, hitset, source, queue, events, own if index == 1 else ([] as Array[Vector2i]))
		if index == 1:
			BoardGravity.apply(board, events)


## Clears every plain piece of `color` (IR-18, IR-19). Only plain pieces count (open question OQ-33).
static func fire_orb(board: BoardModel, order: FireOrder, color: String, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var own: Array[Vector2i] = take_off_board(board, order)
	var cells: Array[Vector2i] = plain_cells_of(board, color)
	var e: BoardEvent = BoardEvent.new("orb_fire")
	e.cell = order.cell
	e.color = color
	e.cells = cells
	events.append(e)
	cover(board, cells, {}, "orb", queue, events, own)


## Target shown, take-off (clears the Crane's own cell), landing: collects a drop item there or
## hits the cell like a special (IR-48). Open question OQ-34: take-off gives no hit to an underlay.
static func fire_crane(board: BoardModel, order: FireOrder, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var exclude: Array[Vector2i] = []
	if order.on_board:
		exclude.append(order.cell)
	var target: Vector2i = CraneTargeting.choose(board, order.cell, exclude)
	var e_target: BoardEvent = BoardEvent.new("crane_target")
	e_target.cell = target
	e_target.color = order.color
	events.append(e_target)
	var e_off: BoardEvent = BoardEvent.new("crane_takeoff")
	e_off.cell = order.cell
	events.append(e_off)
	var own: Array[Vector2i] = take_off_board(board, order)
	if not own.is_empty():
		_clear_event(events, own, "crane")
	var e_land: BoardEvent = BoardEvent.new("crane_landing")
	e_land.cell = target
	events.append(e_land)
	if target.x < 0:
		return
	if board.get_drop_item(target.x, target.y) != "":
		BoardGravity.collect_drop(board, target, events)
	else:
		cover(board, [target] as Array[Vector2i], {}, "crane", queue, events)


# ---------------------------------------------------------------- shared helpers

## Clears the piece in every covered cell (never drop items, IR-28) and gives each cell one hit to
## its top layer (IR-09). Covered specials are queued to fire next (IR-41), top-most then left-most
## (open question OQ-27). `own` = cells of the firing special(s), already removed, listed in the clear.
## `no_chain` = cells whose specials are cleared without firing.
static func cover(board: BoardModel, cells: Array[Vector2i], hitset: Dictionary, source: String,
		queue: Array[FireOrder], events: Array[BoardEvent], own: Array[Vector2i] = [], no_chain: Dictionary = {}) -> void:
	var cleared: Array[Vector2i] = own.duplicate()
	var chained: Array[FireOrder] = []
	for c in cells:
		var kind: String = board.get_kind(c.x, c.y)
		if kind == "" or kind == "drop":
			continue
		if BoardModel.SPECIAL_KINDS.has(kind) and not no_chain.has(c):
			chained.append(FireOrder.new(kind, board.get_color(c.x, c.y), c, false))
		board.clear_piece(c.x, c.y)
		cleared.append(c)
	_clear_event(events, cleared, source)
	for c in cells:
		BoardDamage.hit_top_layer(board, c, hitset, events)
	chained.sort_custom(func(a: FireOrder, b: FireOrder) -> bool:
		return a.cell.y < b.cell.y or (a.cell.y == b.cell.y and a.cell.x < b.cell.x))
	queue.append_array(chained)


## Removes a special that is still on the board before it fires; returns its cell (or nothing).
static func take_off_board(board: BoardModel, order: FireOrder) -> Array[Vector2i]:
	var own: Array[Vector2i] = []
	if order.on_board and board.get_kind(order.cell.x, order.cell.y) == order.kind:
		board.clear_piece(order.cell.x, order.cell.y)
		own.append(order.cell)
	order.on_board = false
	return own


## Most common colour among plain pieces; ties go R, Y, B, G, then other colours A-Z (IR-19, IR-47).
static func most_common_color(board: BoardModel) -> String:
	var counts: Dictionary = {}
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == "plain":
				var c: String = board.get_color(x, y)
				counts[c] = int(counts.get(c, 0)) + 1
	var order: Array[String] = ["R", "Y", "B", "G"]
	var others: Array[String] = []
	for k in counts:
		if not order.has(String(k)):
			others.append(String(k))
	others.sort()
	order.append_array(others)
	var best: String = ""
	var best_n: int = 0
	for c in order:
		var n: int = int(counts.get(c, 0))
		if n > best_n:
			best = c
			best_n = n
	return best


static func plain_cells_of(board: BoardModel, color: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if color == "":
		return out
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == "plain" and board.get_color(x, y) == color:
				out.append(Vector2i(x, y))
	return out


static func row_cells(board: BoardModel, y: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x in range(board.width):
		if board.is_playable(x, y):
			out.append(Vector2i(x, y))
	return out


static func col_cells(board: BoardModel, x: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		if board.is_playable(x, y):
			out.append(Vector2i(x, y))
	return out


## Playable cells of the square of half-size `r` around `centre` (r = 1 is 3x3, r = 2 is 5x5).
static func rect_cells(board: BoardModel, centre: Vector2i, r: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(centre.y - r, centre.y + r + 1):
		for x in range(centre.x - r, centre.x + r + 1):
			if board.is_playable(x, y):
				out.append(Vector2i(x, y))
	return out


static func _clear_event(events: Array[BoardEvent], cells: Array[Vector2i], source: String) -> void:
	if cells.is_empty():
		return
	var e: BoardEvent = BoardEvent.new("clear")
	e.cells = cells
	e.source = source
	events.append(e)
