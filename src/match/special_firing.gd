# Fires single specials: Rocket line (IR-16), Firecracker double 3x3 blast (IR-17), Jade Orb colour
# clear (IR-18, IR-19), Paper Crane flight (IR-20, IR-48). Specials they cover are lifted and fire
# afterwards (IR-41). Covered cells lose their piece and take one top-layer hit (IR-09). Check: test_special_effects.gd.
class_name SpecialFiring
extends RefCounted

const MAX_FIRES: int = 500
const LanternShrine: GDScript = preload("res://src/obstacles/ob05_lantern_shrine.gd")


## Fires each order in turn; after each one, the specials it set off fire (IR-41).
static func run(board: BoardModel, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	for order in queue:
		var waiting: Array[FireOrder] = []
		fire(board, order, waiting, events)
		fire_set_offs(board, waiting, events)


## Owner decision OQ-27: set-off specials were lifted off the board when hit. Once the special
## that hit them has finished, pieces fall, then they fire one at a time from the cell where they
## were hit, lowest first then left-most, each finishing (and falling) before the next. Owner
## decision OQ-47 (chat 27 Nov 2026, trial, revisit after playtest): specials they set off join the
## same waiting list, so the lowest, then left-most waiting special always fires next. Owner
## decision OQ-44 (chat 27 Nov 2026): pieces fall and refill before each one fires; cascade
## matches wait until every waiting special has fired.
static func fire_set_offs(board: BoardModel, waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var fired: int = 0
	while not waiting.is_empty() and fired < MAX_FIRES:
		BoardGravity.apply(board, events)
		var next: FireOrder = _pop_lowest(waiting)
		fire(board, next, waiting, events)
		fired += 1


static func fire(board: BoardModel, order: FireOrder, waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	if order.on_board and board.get_kind(order.cell.x, order.cell.y) != order.kind:
		return   # already gone (set off earlier in this resolve)
	match order.kind:
		"rocket_row", "rocket_col":
			_fire_rocket(board, order, waiting, events)
		"firecracker":
			_fire_firecracker(board, order, waiting, events)
		"orb":
			if order.set_off:
				return   # owner decision OQ-27: a set-off Orb is removed without effect (IR-41)
			fire_orb(board, order, most_common_color(board), waiting, events)
		"crane":
			fire_crane(board, order, waiting, events)


# ---------------------------------------------------------------- the four specials

static func _fire_rocket(board: BoardModel, order: FireOrder, waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var own: Array[Vector2i] = take_off_board(board, order)
	var cells: Array[Vector2i] = row_cells(board, order.cell.y) if order.kind == "rocket_row" else col_cells(board, order.cell.x)
	fire_rocket_line(board, order, cells, {}, "special", waiting, events, own)


## One Rocket's fire event and its line (also used for Rockets made by Orb + Rocket).
static func fire_rocket_line(board: BoardModel, order: FireOrder, cells: Array[Vector2i], hitset: Dictionary, source: String,
		waiting: Array[FireOrder], events: Array[BoardEvent], own: Array[Vector2i] = []) -> void:
	var e: BoardEvent = BoardEvent.new("rocket_fire")
	e.cell = order.cell
	e.kind = order.kind
	e.color = order.color
	e.cells = cells
	events.append(e)
	cover(board, cells, hitset, source, waiting, events, own)


static func _fire_firecracker(board: BoardModel, order: FireOrder, waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var own: Array[Vector2i] = take_off_board(board, order)
	double_blast(board, rect_cells(board, order.cell, 1), order.cell, {}, "special", waiting, events, own)


## Two blasts on the same area and centre; one hit per obstacle in total (IR-12). Owner decision
## OQ-32: between the blasts pieces fall, refill and every cascade resolves (also for the 5x5 combo).
static func double_blast(board: BoardModel, area: Array[Vector2i], centre: Vector2i, hitset: Dictionary, source: String,
		waiting: Array[FireOrder], events: Array[BoardEvent], own: Array[Vector2i]) -> void:
	for index in [1, 2]:
		var e: BoardEvent = BoardEvent.new("blast")
		e.cell = centre
		e.cells = area
		e.data = {"index": index}
		events.append(e)
		cover(board, area, hitset, source, waiting, events, own if index == 1 else ([] as Array[Vector2i]))
		if index == 1:
			MatchResolver.cascade(board, events)


## Clears every plain piece of `color` (IR-18, IR-19). Owner decisions: only plain pieces are
## cleared, coloured specials are left alone (OQ-33); plain pieces under an overlay are ignored,
## so neither they nor their overlay are touched (OQ-42, chat 27 Nov 2026).
static func fire_orb(board: BoardModel, order: FireOrder, color: String, waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var own: Array[Vector2i] = take_off_board(board, order)
	var cells: Array[Vector2i] = plain_cells_of(board, color)
	var e: BoardEvent = BoardEvent.new("orb_fire")
	e.cell = order.cell
	e.color = color
	e.cells = cells
	events.append(e)
	cover(board, cells, {}, "orb", waiting, events, own)


## Target shown, take-off, landing (IR-48). Owner decision OQ-34: take-off counts as a special
## covering the Crane's own cell: a piece that fell in is cleared, a special there is set off, the
## top layer takes one hit. Landing: collects a drop item, gives an uncovered dew target dew, puts
## one piece into a lantern shrine, or else hits the cell. Owner decision OQ-49 (chat 27 Nov 2026):
## a dew landing clears the piece there like any special AND gives the cell dew. Open question
## OQ-55 (provisional): a shrine landing counts as one piece and one hp, not a separate special hit.
static func fire_crane(board: BoardModel, order: FireOrder, waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var target: Vector2i = CraneTargeting.choose(board, order.cell, [order.cell] as Array[Vector2i])
	var e_target: BoardEvent = BoardEvent.new("crane_target")
	e_target.cell = target
	e_target.color = order.color
	events.append(e_target)
	var e_off: BoardEvent = BoardEvent.new("crane_takeoff")
	e_off.cell = order.cell
	events.append(e_off)
	var hitset: Dictionary = {}   # take-off and landing are one special
	var own: Array[Vector2i] = take_off_board(board, order)
	cover(board, [order.cell] as Array[Vector2i], hitset, "crane", waiting, events, own)
	var e_land: BoardEvent = BoardEvent.new("crane_landing")
	e_land.cell = target
	events.append(e_land)
	if target.x < 0:
		return
	var content: BoardContent = board.get_content(target.x, target.y)
	if board.get_drop_item(target.x, target.y) != "":
		BoardGravity.collect_drop(board, target, events)
	elif board.is_uncovered_dew_target(target.x, target.y):
		cover(board, [target] as Array[Vector2i], hitset, "crane", waiting, events)
		board.give_dew(target.x, target.y)   # OQ-49: clear the piece, then give dew
	elif content != null and content.id == "OB05" and not content.needs.is_empty():
		LanternShrine.take_one_piece(board, content, hitset, events)
	else:
		cover(board, [target] as Array[Vector2i], hitset, "crane", waiting, events)


# ---------------------------------------------------------------- shared helpers

## Clears the piece in every covered cell (never drop items, IR-28) and gives each cell one hit to
## its top layer (IR-09). Covered specials are lifted off the board and added to `waiting` (IR-41).
## `own` = cells of the firing special(s), already removed, listed in the clear.
## `no_chain` = cells whose specials are cleared without firing (Orb + Orb).
static func cover(board: BoardModel, cells: Array[Vector2i], hitset: Dictionary, source: String,
		waiting: Array[FireOrder], events: Array[BoardEvent], own: Array[Vector2i] = [], no_chain: Dictionary = {}) -> void:
	var cleared: Array[Vector2i] = own.duplicate()
	for c in cells:
		var kind: String = board.get_kind(c.x, c.y)
		if kind == "" or kind == "drop":
			continue
		if BoardModel.SPECIAL_KINDS.has(kind) and not no_chain.has(c):
			var lifted: FireOrder = FireOrder.new(kind, board.get_color(c.x, c.y), c, false)
			lifted.set_off = true
			waiting.append(lifted)
		board.clear_piece(c.x, c.y)
		cleared.append(c)
	_clear_event(events, cleared, source)
	var covered: Array[Vector2i] = own.duplicate()
	covered.append_array(cells)
	BoardDamage.note_cleared(board, cleared, covered, hitset)
	for c in cells:
		BoardDamage.hit_top_layer(board, c, hitset, events)


## Removes a special that is still on the board before it fires; returns its cell (or nothing).
static func take_off_board(board: BoardModel, order: FireOrder) -> Array[Vector2i]:
	var own: Array[Vector2i] = []
	if order.on_board and board.get_kind(order.cell.x, order.cell.y) == order.kind:
		board.clear_piece(order.cell.x, order.cell.y)
		own.append(order.cell)
	order.on_board = false
	return own


## Sorts cells lowest row first, then left-most (IR-41, IR-25).
static func sort_lowest_first(cells: Array[Vector2i]) -> void:
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y > b.y or (a.y == b.y and a.x < b.x))


static func _pop_lowest(waiting: Array[FireOrder]) -> FireOrder:
	var best: int = 0
	for i in range(waiting.size()):
		var c: Vector2i = waiting[i].cell
		var b: Vector2i = waiting[best].cell
		if c.y > b.y or (c.y == b.y and c.x < b.x):
			best = i
	var order: FireOrder = waiting[best]
	waiting.remove_at(best)
	return order


## Most common colour among plain pieces; ties go R, Y, B, G, then other colours A-Z (IR-19, IR-47).
## Owner decisions: coloured specials are not counted (OQ-33); plain pieces under an overlay are
## not counted (OQ-42, chat 27 Nov 2026).
static func most_common_color(board: BoardModel) -> String:
	var counts: Dictionary = {}
	for y in range(board.height):
		for x in range(board.width):
			if _orb_can_take(board, x, y):
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


## Cells the Jade Orb clears or converts for this colour: uncovered plain pieces only (OQ-33, OQ-42).
static func plain_cells_of(board: BoardModel, color: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if color == "":
		return out
	for y in range(board.height):
		for x in range(board.width):
			if _orb_can_take(board, x, y) and board.get_color(x, y) == color:
				out.append(Vector2i(x, y))
	return out


## A plain piece with no overlay on it: the only kind of piece the Jade Orb counts, clears or
## converts (owner decisions OQ-33, OQ-42 chat 27 Nov 2026).
static func _orb_can_take(board: BoardModel, x: int, y: int) -> bool:
	return board.get_kind(x, y) == "plain" and board.overlay_hp(x, y) <= 0


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
