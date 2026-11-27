# Two specials swapped together (IR-22..IR-27, IR-46). Rocket/Firecracker combos are centred on the
# swap's target cell; a whole combo is one special for the one-hit rules (IR-45). A Crane with any
# special makes no combo: the other fires first, then the Crane (IR-27). Check: test_combos.gd.
class_name ComboFiring
extends RefCounted


## `target` = the cell the player moved into, `start` = the other cell. The swap is already done.
static func fire(board: BoardModel, start: Vector2i, target: Vector2i, events: Array[BoardEvent]) -> void:
	var k_t: String = board.get_kind(target.x, target.y)
	var k_s: String = board.get_kind(start.x, start.y)
	if k_t == "crane" or k_s == "crane":
		_crane_with_special(board, start, target, events)
		return
	var pair: Array[String] = [_family(k_t), _family(k_s)]
	pair.sort()
	var own: Array[Vector2i] = [target, start]
	for c in own:
		board.clear_piece(c.x, c.y)
	var waiting: Array[FireOrder] = []   # specials the combo sets off (IR-41)
	var hitset: Dictionary = {}
	match "%s+%s" % [pair[0], pair[1]]:
		"rocket+rocket":
			var cells: Array[Vector2i] = _union([SpecialFiring.row_cells(board, target.y), SpecialFiring.col_cells(board, target.x)])
			_combo_event(events, target, cells, "rocket_rocket")
			SpecialFiring.cover(board, cells, hitset, "combo", waiting, events, own)
		"firecracker+rocket":
			var bands: Array = []
			for d in [-1, 0, 1]:
				bands.append(SpecialFiring.row_cells(board, target.y + d))
				bands.append(SpecialFiring.col_cells(board, target.x + d))
			var cells2: Array[Vector2i] = _union(bands)
			_combo_event(events, target, cells2, "rocket_firecracker")
			SpecialFiring.cover(board, cells2, hitset, "combo", waiting, events, own)
		"firecracker+firecracker":
			var area: Array[Vector2i] = SpecialFiring.rect_cells(board, target, 2)
			_combo_event(events, target, area, "firecracker_firecracker")
			SpecialFiring.double_blast(board, area, target, hitset, "combo", waiting, events, own)
		"orb+orb":
			_orb_orb(board, target, own, events)
		"orb+rocket", "firecracker+orb":
			var special_kind: String = k_t if k_t != "orb" else k_s
			_orb_special(board, target, special_kind, own, waiting, events)
	SpecialFiring.fire_set_offs(board, waiting, events)


static func _family(kind: String) -> String:
	if kind == "rocket_row" or kind == "rocket_col":
		return "rocket"
	return kind


## IR-27: no combo. The other special fires first (an Orb as if tapped), then the Crane flies once.
## Owner decision OQ-34: in Crane + Crane the Crane the player dragged (now on `target`) flies first.
static func _crane_with_special(board: BoardModel, start: Vector2i, target: Vector2i, events: Array[BoardEvent]) -> void:
	var first_cell: Vector2i
	var last_cell: Vector2i
	if board.get_kind(target.x, target.y) == "crane" and board.get_kind(start.x, start.y) == "crane":
		first_cell = target
		last_cell = start
	elif board.get_kind(target.x, target.y) == "crane":
		first_cell = start
		last_cell = target
	else:
		first_cell = target
		last_cell = start
	var first: FireOrder = FireOrder.new(board.get_kind(first_cell.x, first_cell.y), board.get_color(first_cell.x, first_cell.y), first_cell, true)
	var last: FireOrder = FireOrder.new("crane", board.get_color(last_cell.x, last_cell.y), last_cell, true)
	# Lift the Crane that flies last so the first special can't set it off a second time.
	SpecialFiring.take_off_board(board, last)
	var lifted: BoardEvent = BoardEvent.new("clear")
	lifted.cells = [last_cell] as Array[Vector2i]
	lifted.source = "crane"
	events.append(lifted)
	SpecialFiring.run(board, [first] as Array[FireOrder], events)
	SpecialFiring.run(board, [last] as Array[FireOrder], events)


## IR-26: clears every piece, collects every drop item, hits every obstacle once.
## Owner decisions: other specials are cleared without firing (OQ-27); only the top layer of each
## cell is hit, so goo under moss is untouched (OQ-37).
static func _orb_orb(board: BoardModel, target: Vector2i, own: Array[Vector2i], events: Array[BoardEvent]) -> void:
	var all_cells: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.is_playable(x, y):
				all_cells.append(Vector2i(x, y))
	_combo_event(events, target, all_cells, "orb_orb")
	for c in all_cells:
		if board.get_drop_item(c.x, c.y) != "":
			BoardGravity.collect_drop(board, c, events)
	var no_chain: Dictionary = {}
	for c in all_cells:
		no_chain[c] = true
	var none: Array[FireOrder] = []
	SpecialFiring.cover(board, all_cells, {}, "combo", none, events, own, no_chain)


## IR-25: every plain piece of the most common colour becomes the swapped special; they fire one
## after another, lowest first then left-most; the whole combo is one special. Owner decisions:
## converted Rockets copy the swapped Rocket's direction (OQ-24), firing order (OQ-27), only plain
## pieces are counted and converted (OQ-33). Open question OQ-48 (provisional): the converted
## specials leave the board at once and fire from their cells, so falls between Firecracker blasts
## can't move them.
## Open question OQ-42 (provisional): plain pieces under an overlay are converted too.
static func _orb_special(board: BoardModel, target: Vector2i, kind: String, own: Array[Vector2i],
		waiting: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var color: String = SpecialFiring.most_common_color(board)
	var converted: Array[Vector2i] = SpecialFiring.plain_cells_of(board, color)
	SpecialFiring.sort_lowest_first(converted)
	_combo_event(events, target, converted, "orb_" + _family(kind))
	var lifted: Array[Vector2i] = own.duplicate()
	for c in converted:
		board.clear_piece(c.x, c.y)
		lifted.append(c)
	var hitset: Dictionary = {}
	var clear: BoardEvent = BoardEvent.new("clear")
	clear.cells = lifted
	clear.source = "combo"
	events.append(clear)
	BoardDamage.note_cleared(board, lifted, hitset)
	for c in converted:
		var order: FireOrder = FireOrder.new(kind, color, c, false)
		if kind == "firecracker":
			SpecialFiring.double_blast(board, SpecialFiring.rect_cells(board, c, 1), c, hitset, "combo", waiting, events, [] as Array[Vector2i])
		else:
			var line: Array[Vector2i] = SpecialFiring.row_cells(board, c.y) if kind == "rocket_row" else SpecialFiring.col_cells(board, c.x)
			SpecialFiring.fire_rocket_line(board, order, line, hitset, "combo", waiting, events)


static func _combo_event(events: Array[BoardEvent], target: Vector2i, cells: Array[Vector2i], name: String) -> void:
	var e: BoardEvent = BoardEvent.new("combo")
	e.cell = target
	e.cells = cells
	e.data = {"name": name}
	events.append(e)


static func _union(lists: Array) -> Array[Vector2i]:
	var seen: Dictionary = {}
	var out: Array[Vector2i] = []
	for l in lists:
		for c in l:
			if not seen.has(c):
				seen[c] = true
				out.append(c)
	return out
