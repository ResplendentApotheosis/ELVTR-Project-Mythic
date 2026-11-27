# Two specials swapped together (IR-22..IR-27, IR-46). Rocket/Firecracker combos are centred on the
# swap's target cell; a whole combo is one special for the one-hit rules (IR-45). A Crane with any
# special makes no combo: the other fires first, then the Crane (IR-27). Check: test_combos.gd.
class_name ComboFiring
extends RefCounted


## `target` = the cell the player moved into, `start` = the other cell. The swap is already done.
static func fire(board: BoardModel, start: Vector2i, target: Vector2i, events: Array[BoardEvent]) -> void:
	var k_t: String = board.get_kind(target.x, target.y)
	var k_s: String = board.get_kind(start.x, start.y)
	var queue: Array[FireOrder] = []
	if k_t == "crane" or k_s == "crane":
		_crane_with_special(board, start, target, events)
		return
	var pair: Array[String] = [_family(k_t), _family(k_s)]
	pair.sort()
	var own: Array[Vector2i] = [target, start]
	for c in own:
		board.clear_piece(c.x, c.y)
	var hitset: Dictionary = {}
	match "%s+%s" % [pair[0], pair[1]]:
		"rocket+rocket":
			var cells: Array[Vector2i] = _union([SpecialFiring.row_cells(board, target.y), SpecialFiring.col_cells(board, target.x)])
			_combo_event(events, target, cells, "rocket_rocket")
			SpecialFiring.cover(board, cells, hitset, "combo", queue, events, own)
		"firecracker+rocket":
			var bands: Array = []
			for d in [-1, 0, 1]:
				bands.append(SpecialFiring.row_cells(board, target.y + d))
				bands.append(SpecialFiring.col_cells(board, target.x + d))
			var cells2: Array[Vector2i] = _union(bands)
			_combo_event(events, target, cells2, "rocket_firecracker")
			SpecialFiring.cover(board, cells2, hitset, "combo", queue, events, own)
		"firecracker+firecracker":
			var area: Array[Vector2i] = SpecialFiring.rect_cells(board, target, 2)
			_combo_event(events, target, area, "firecracker_firecracker")
			SpecialFiring.double_blast(board, area, target, hitset, "combo", queue, events, own)
		"orb+orb":
			_orb_orb(board, target, own, events)
		"orb+rocket", "firecracker+orb":
			var special_kind: String = k_t if k_t != "orb" else k_s
			_orb_special(board, target, special_kind, own, queue, events)
	SpecialFiring.run(board, queue, events)


static func _family(kind: String) -> String:
	if kind == "rocket_row" or kind == "rocket_col":
		return "rocket"
	return kind


## IR-27: no combo. The other special fires as if tapped, then the Crane flies once.
## Crane + Crane: the Crane the player did not drag fires first (open question OQ-34, provisional).
static func _crane_with_special(board: BoardModel, start: Vector2i, target: Vector2i, events: Array[BoardEvent]) -> void:
	# The dragged piece now sits on `target`; the other one on `start`.
	var crane_cell: Vector2i = target if board.get_kind(target.x, target.y) == "crane" else start
	var other_cell: Vector2i = start if crane_cell == target else target
	var crane: FireOrder = FireOrder.new("crane", board.get_color(crane_cell.x, crane_cell.y), crane_cell, true)
	# Lift the Crane off so the other special can't set it off a second time.
	SpecialFiring.take_off_board(board, crane)
	var lifted: BoardEvent = BoardEvent.new("clear")
	lifted.cells = [crane_cell] as Array[Vector2i]
	lifted.source = "crane"
	events.append(lifted)
	var other: FireOrder = FireOrder.new(board.get_kind(other_cell.x, other_cell.y), board.get_color(other_cell.x, other_cell.y), other_cell, true)
	var queue: Array[FireOrder] = [other]
	SpecialFiring.run(board, queue, events)
	queue = [crane]
	SpecialFiring.run(board, queue, events)


## IR-26: clears every piece, collects every drop item, hits every obstacle once.
## Open question OQ-27: other specials on the board are cleared without firing (provisional).
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
	var queue: Array[FireOrder] = []
	var hitset: Dictionary = {}
	SpecialFiring.cover(board, all_cells, hitset, "combo", queue, events, own, no_chain)
	# cover() hit each cell's top layer; "hits every obstacle once" also reaches layers below.
	for c in all_cells:
		if board.overlay_hp(c.x, c.y) > 0:
			BoardDamage.hit_overlay(board, c, hitset, events)
		var content: BoardContent = board.get_content(c.x, c.y)
		if content != null:
			BoardDamage.hit_content(board, content, hitset, events)
		if board.underlay_hp(c.x, c.y) > 0:
			BoardDamage.hit_underlay(board, c, hitset, events)


## IR-25: every plain piece of the most common colour becomes the swapped special and fires; the
## whole combo is one special. Open questions: converted Rockets copy the swapped Rocket's direction
## (OQ-24), they fire in reading order (OQ-27), only plain pieces count (OQ-33). All provisional.
static func _orb_special(board: BoardModel, target: Vector2i, kind: String, own: Array[Vector2i],
		queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var color: String = SpecialFiring.most_common_color(board)
	var converted: Array[Vector2i] = SpecialFiring.plain_cells_of(board, color)
	_combo_event(events, target, converted, "orb_" + _family(kind))
	var clear: BoardEvent = BoardEvent.new("clear")
	clear.cells = own
	clear.source = "combo"
	events.append(clear)
	var members: Dictionary = {}
	for c in converted:
		board.set_piece(c.x, c.y, kind, color)
		members[c] = true
	var hitset: Dictionary = {}
	var orders: Array[FireOrder] = []
	for c in converted:
		orders.append(FireOrder.new(kind, color, c, true))
	if kind == "firecracker":
		for index in [1, 2]:
			for o in orders:
				var own_cell: Array[Vector2i] = []
				if index == 1:
					own_cell = SpecialFiring.take_off_board(board, o)
				var area: Array[Vector2i] = SpecialFiring.rect_cells(board, o.cell, 1)
				var e: BoardEvent = BoardEvent.new("blast")
				e.cell = o.cell
				e.cells = area
				e.data = {"index": index}
				events.append(e)
				SpecialFiring.cover(board, area, hitset, "combo", queue, events, own_cell, members if index == 1 else {})
			if index == 1:
				BoardGravity.apply(board, events)
	else:
		for o in orders:
			var own_cell2: Array[Vector2i] = SpecialFiring.take_off_board(board, o)
			var line: Array[Vector2i] = SpecialFiring.row_cells(board, o.cell.y) if kind == "rocket_row" else SpecialFiring.col_cells(board, o.cell.x)
			var e2: BoardEvent = BoardEvent.new("rocket_fire")
			e2.cell = o.cell
			e2.kind = kind
			e2.color = color
			e2.cells = line
			events.append(e2)
			SpecialFiring.cover(board, line, hitset, "combo", queue, events, own_cell2, members)


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
