# Grey-box board view: draws the floor, obstacles (underlay = tinted cell, content = grey block, overlay = outline)
# and one GreyboxPieceTile per piece, and plays AnimationQueue steps with short tweens. It only shows things:
# every rule comes from the logic, and the final "sync" step makes the picture match the real board exactly.
# Check: F5 the greybox scene; make matches and watch pieces swap, pop, fall and drop in.
class_name GreyboxBoardView
extends Node2D

const NO_CELL: Vector2i = Vector2i(-1, -1)
const FLOOR_A: Color = Color(0.22, 0.24, 0.27)
const FLOOR_B: Color = Color(0.26, 0.28, 0.31)
const CONTENT_COLOR: Color = Color(0.45, 0.45, 0.48)
const OVERLAY_COLOR: Color = Color(0.55, 0.95, 0.55)
const SELECT_COLOR: Color = Color(1.0, 1.0, 0.3)
const FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 0.7)
const UNDERLAY_TINTS: Dictionary = {
	"OB04": Color(0.45, 0.80, 0.95, 0.55),   # healing dew
	"OB10": Color(0.60, 0.30, 0.70, 0.65),   # creep goo
}
const OTHER_UNDERLAY: Color = Color(0.8, 0.5, 0.2, 0.6)

@export var cell_size: float = 64.0

var board: BoardModel = null
var selected: Vector2i = NO_CELL
var _tiles: Dictionary = {}        # cell -> GreyboxPieceTile
var _obstacles: Dictionary = {}    # BoardSnapshot.obstacle_grid copy, updated by hit steps
var _pieces_layer: Node2D
var _overlay_layer: Node2D
var _fx_layer: Node2D


func _ready() -> void:
	_pieces_layer = Node2D.new()
	_pieces_layer.name = "Pieces"
	add_child(_pieces_layer)
	_overlay_layer = Node2D.new()
	_overlay_layer.name = "Overlays"
	add_child(_overlay_layer)
	_overlay_layer.draw.connect(_draw_overlays)
	_fx_layer = Node2D.new()
	_fx_layer.name = "Effects"
	add_child(_fx_layer)


## Shows a new board from scratch (start or retry).
func setup(new_board: BoardModel) -> void:
	board = new_board
	selected = NO_CELL
	for t in _tiles.values():
		(t as Node).queue_free()
	_tiles.clear()
	sync_to_board()


func set_selected(cell: Vector2i) -> void:
	selected = cell
	_overlay_layer.queue_redraw()


func board_pixel_size() -> Vector2:
	if board == null:
		return Vector2.ZERO
	return Vector2(board.width, board.height) * cell_size


## Makes the picture match the real board, with no animation.
func sync_to_board() -> void:
	if board == null:
		return
	var wanted: Dictionary = BoardSnapshot.piece_grid(board)
	for cell in _tiles.keys():
		if not wanted.has(cell):
			_remove_tile(cell)
	for cell in wanted:
		var look: Dictionary = wanted[cell]
		if _tiles.has(cell):
			var t: GreyboxPieceTile = _tiles[cell]
			t.position = _center(cell)
			t.scale = Vector2.ONE
			t.modulate = Color.WHITE
			if t.look != look:
				t.set_look(look)
		else:
			_add_tile(cell, look)
	_obstacles = BoardSnapshot.obstacle_grid(board)
	queue_redraw()
	_overlay_layer.queue_redraw()


# ---------------------------------------------------------------- playing steps (called by AnimationQueue)

func play_step(step: Dictionary) -> void:
	var d: float = float(step.get("duration", 0.0))
	match String(step.type):
		"swap":
			_play_swap(step.from, step.to, d)
		"invalid_swap":
			_play_bounce(step.from, step.to, d)
		"clear":
			for c in step.cells:
				_pop_away(c, d)
		"special":
			_remove_tile(step.cell)
			var t: GreyboxPieceTile = _add_tile(step.cell, step.look)
			t.scale = Vector2(0.3, 0.3)
			t.create_tween().tween_property(t, "scale", Vector2.ONE, d)
		"fall":
			_play_fall(step.moves, d)
		"spawn":
			_play_spawn(step.pieces, d)
		"fire":
			_flash(step.cells, d)
			if String(step.get("name", "")) == "blast":
				_shake(d)
		"hit":
			BoardSnapshot.apply_hit(_obstacles, step.layer, step.cell, step.id, step.hp)
			_flash([step.cell], d)
			queue_redraw()
			_overlay_layer.queue_redraw()
		"obstacle_cleared":
			BoardSnapshot.apply_cleared(_obstacles, step.cell, step.id)
			queue_redraw()
			_overlay_layer.queue_redraw()
		"collect":
			_collect(step.cell, d)
		"shuffle":
			for p in step.pieces:
				_remove_tile(p.cell)
				var t: GreyboxPieceTile = _add_tile(p.cell, p.look)
				t.scale = Vector2(0.6, 0.6)
				t.create_tween().tween_property(t, "scale", Vector2.ONE, d)
		"sync":
			sync_to_board()
		_:
			pass   # "wait" and "outcome" draw nothing


func _play_swap(a: Vector2i, b: Vector2i, d: float) -> void:
	var ta: Variant = _tiles.get(a)
	var tb: Variant = _tiles.get(b)
	_tiles.erase(a)
	_tiles.erase(b)
	if ta != null:
		_tiles[b] = ta
		_slide(ta, _center(b), d)
	if tb != null:
		_tiles[a] = tb
		_slide(tb, _center(a), d)


func _play_bounce(a: Vector2i, b: Vector2i, d: float) -> void:
	for pair in [[a, b], [b, a]]:
		var t: Variant = _tiles.get(pair[0])
		if t == null:
			continue
		var tile: GreyboxPieceTile = t
		var tw: Tween = tile.create_tween()
		tw.tween_property(tile, "position", _center(pair[1]), d / 2.0)
		tw.tween_property(tile, "position", _center(pair[0]), d / 2.0)


func _play_fall(moves: Array, d: float) -> void:
	# Move the tiles in the dictionary one move at a time (like the board did), then slide each
	# tile once to where it ended up.
	var moved: Array[GreyboxPieceTile] = []
	for m in moves:
		var from: Vector2i = m["from"]
		var to: Vector2i = m["to"]
		if not _tiles.has(from):
			continue
		var tile: GreyboxPieceTile = _tiles[from]
		_tiles.erase(from)
		_remove_tile(to)   # something left behind there (e.g. a special lifted by a match)
		_tiles[to] = tile
		if not moved.has(tile):
			moved.append(tile)
	for cell in _tiles:
		var tile: GreyboxPieceTile = _tiles[cell]
		if moved.has(tile):
			_slide(tile, _center(cell), d)


func _play_spawn(pieces: Array, d: float) -> void:
	for p in pieces:
		var cell: Vector2i = p.cell
		_remove_tile(cell)
		var t: GreyboxPieceTile = _add_tile(cell, p.look)
		t.position = _center(cell) - Vector2(0, cell_size)
		t.modulate.a = 0.0
		var tw: Tween = t.create_tween().set_parallel(true)
		tw.tween_property(t, "position", _center(cell), d)
		tw.tween_property(t, "modulate:a", 1.0, d)


func _pop_away(cell: Vector2i, d: float) -> void:
	if not _tiles.has(cell):
		return
	var t: GreyboxPieceTile = _tiles[cell]
	_tiles.erase(cell)
	var tw: Tween = t.create_tween()
	tw.tween_property(t, "scale", Vector2(1.2, 1.2), d / 3.0)   # GDD: pop to 120%, gone in 0.12 s
	tw.tween_property(t, "scale", Vector2.ZERO, d * 2.0 / 3.0)
	tw.tween_callback(t.queue_free)


func _collect(cell: Vector2i, d: float) -> void:
	if not _tiles.has(cell):
		return
	var t: GreyboxPieceTile = _tiles[cell]
	_tiles.erase(cell)
	var tw: Tween = t.create_tween().set_parallel(true)
	tw.tween_property(t, "scale", Vector2(1.4, 1.4), d)
	tw.tween_property(t, "modulate:a", 0.0, d)
	tw.chain().tween_callback(t.queue_free)


func _flash(cells: Array, d: float) -> void:
	for c in cells:
		var r: ColorRect = ColorRect.new()
		r.color = FLASH_COLOR
		r.size = Vector2(cell_size, cell_size)
		r.position = Vector2(c.x, c.y) * cell_size
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fx_layer.add_child(r)
		var tw: Tween = r.create_tween()
		tw.tween_property(r, "modulate:a", 0.0, d)
		tw.tween_callback(r.queue_free)


func _shake(d: float) -> void:
	var tw: Tween = create_tween()
	var home: Vector2 = position
	tw.tween_property(self, "position", home + Vector2(4, 0), d / 4.0)
	tw.tween_property(self, "position", home - Vector2(4, 0), d / 4.0)
	tw.tween_property(self, "position", home, d / 2.0)


func _slide(tile: GreyboxPieceTile, target: Vector2, d: float) -> void:
	tile.create_tween().tween_property(tile, "position", target, d).set_ease(Tween.EASE_OUT)


func _add_tile(cell: Vector2i, look: Dictionary) -> GreyboxPieceTile:
	var t: GreyboxPieceTile = GreyboxPieceTile.new()
	t.size = cell_size - 6.0
	t.set_look(look)
	t.position = _center(cell)
	_pieces_layer.add_child(t)
	_tiles[cell] = t
	return t


func _remove_tile(cell: Vector2i) -> void:
	if _tiles.has(cell):
		(_tiles[cell] as Node).queue_free()
		_tiles.erase(cell)


func _center(cell: Vector2i) -> Vector2:
	return BoardInput.cell_center(cell, cell_size)


# ---------------------------------------------------------------- drawing

## Floor, underlays and content blockers (under the pieces).
func _draw() -> void:
	if board == null:
		return
	var font: Font = ThemeDB.fallback_font
	for y in range(board.height):
		for x in range(board.width):
			if not board.is_playable(x, y):
				continue
			var r: Rect2 = Rect2(Vector2(x, y) * cell_size, Vector2(cell_size, cell_size))
			draw_rect(r, FLOOR_A if (x + y) % 2 == 0 else FLOOR_B)
	for cell in _obstacles.underlay:
		var u: Dictionary = _obstacles.underlay[cell]
		var r: Rect2 = Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size))
		draw_rect(r.grow(-1.0), UNDERLAY_TINTS.get(u.id, OTHER_UNDERLAY))
		_label(self, font, "%s %d" % [u.id, u.hp], r.position + Vector2(0, cell_size - 3), cell_size, 10, Color.WHITE)
	for key in _obstacles.content:
		var c: Dictionary = _obstacles.content[key]
		var rect: Rect2i = c.rect
		var r: Rect2 = Rect2(Vector2(rect.position) * cell_size, Vector2(rect.size) * cell_size).grow(-3.0)
		draw_rect(r, CONTENT_COLOR)
		draw_rect(r, Color.BLACK, false, 2.0)
		var text: String = "%s %d" % [c.id, c.hp]
		if bool(c.fragment):
			text += " F"
		_label(self, font, text, r.position + Vector2(0, 20), r.size.x, 13, Color.WHITE)
		var extra: String = _content_extra(c)
		if extra != "":
			_label(self, font, extra, r.position + Vector2(0, 36), r.size.x, 11, Color.WHITE)


## Overlays (an outline over the piece) and the selected cell, drawn above the pieces.
func _draw_overlays() -> void:
	if board == null:
		return
	var font: Font = ThemeDB.fallback_font
	for cell in _obstacles.overlay:
		var o: Dictionary = _obstacles.overlay[cell]
		var r: Rect2 = Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size)).grow(-2.0)
		_overlay_layer.draw_rect(r, OVERLAY_COLOR, false, 4.0)
		_overlay_layer.draw_rect(Rect2(r.position, Vector2(r.size.x, 14)), Color(0, 0, 0, 0.6))
		_label(_overlay_layer, font, "%s %d" % [o.id, o.hp], r.position + Vector2(0, 11), r.size.x, 10, OVERLAY_COLOR)
	if selected != NO_CELL:
		var s: Rect2 = Rect2(Vector2(selected) * cell_size, Vector2(cell_size, cell_size))
		_overlay_layer.draw_rect(s, SELECT_COLOR, false, 3.0)


## Shrine needs ("R2 B1") or a lantern colour, for the second label line.
func _content_extra(c: Dictionary) -> String:
	var parts: Array[String] = []
	var needs: Dictionary = c.get("needs", {})
	for colour in needs:
		if int(needs[colour]) > 0:
			parts.append("%s%d" % [colour, int(needs[colour])])
	if String(c.get("color", "")) != "":
		parts.append(String(c.color))
	return " ".join(parts)


func _label(target: CanvasItem, font: Font, text: String, pos: Vector2, width: float, font_size: int, color: Color) -> void:
	target.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)
