# Copies what the screen needs from a BoardModel into plain Dictionaries (pieces and obstacle layers),
# and updates an obstacle copy when a "hit" or "obstacle_cleared" event is played. Pure data: no nodes.
# The views draw from these copies, because the real board is already at the end of the move when animation starts.
# Check: GUT tests for BoardSnapshot (test-engineer); the greybox scene draws from it (F5).
class_name BoardSnapshot
extends RefCounted


## One look per cell that holds something that can move: {cell: {"kind", "color", "item"}}.
## "item" is the drop item ("OB11" or "fragment") for kind "drop", else "".
static func piece_grid(board: BoardModel) -> Dictionary:
	var grid: Dictionary = {}
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) != "":
				grid[Vector2i(x, y)] = look_at(board, Vector2i(x, y))
	return grid


## The look of one cell: {"kind", "color", "item"}; kind "" when the cell holds nothing that moves.
static func look_at(board: BoardModel, cell: Vector2i) -> Dictionary:
	return {
		"kind": board.get_kind(cell.x, cell.y),
		"color": board.get_color(cell.x, cell.y),
		"item": board.get_drop_item(cell.x, cell.y),
	}


## The obstacle layers: {"underlay": {cell: {"id", "hp"}}, "overlay": {cell: {"id", "hp"}},
## "content": {top_left_cell: {"id", "hp", "rect", "fragment", "needs", "color"}}}.
## A multi-cell obstacle (pillar, shrine) is one "content" entry keyed by its top-left cell.
static func obstacle_grid(board: BoardModel) -> Dictionary:
	var under: Dictionary = {}
	var over: Dictionary = {}
	for y in range(board.height):
		for x in range(board.width):
			if board.underlay_id(x, y) != "" and board.underlay_hp(x, y) > 0:
				under[Vector2i(x, y)] = {"id": board.underlay_id(x, y), "hp": board.underlay_hp(x, y)}
			if board.overlay_id(x, y) != "" and board.overlay_hp(x, y) > 0:
				over[Vector2i(x, y)] = {"id": board.overlay_id(x, y), "hp": board.overlay_hp(x, y)}
	var content: Dictionary = {}
	for c in board.all_contents():
		content[c.rect.position] = {
			"id": c.id, "hp": c.hp, "rect": c.rect, "fragment": c.fragment,
			"needs": c.needs.duplicate(), "color": c.color,
		}
	return {"underlay": under, "overlay": over, "content": content}


## Applies one "hit" event (layer "overlay", "content" or "underlay"; hp = hp left) to an obstacle copy.
## hp 0 removes that layer from the cell.
static func apply_hit(obstacles: Dictionary, layer: String, cell: Vector2i, id: String, hp: int) -> void:
	if layer == "content":
		var key: Variant = content_key_at(obstacles, cell)
		if key == null:
			return
		if hp <= 0:
			(obstacles.content as Dictionary).erase(key)
		else:
			obstacles.content[key].hp = hp
		return
	if not obstacles.has(layer):
		return
	var cells: Dictionary = obstacles[layer]
	if hp <= 0:
		cells.erase(cell)
	elif cells.has(cell):
		cells[cell].hp = hp
	else:
		cells[cell] = {"id": id, "hp": hp}


## Applies one "obstacle_cleared" (or "shrine_lit") event: removes the layer with that id at that cell.
static func apply_cleared(obstacles: Dictionary, cell: Vector2i, id: String) -> void:
	for layer in ["overlay", "underlay"]:
		var cells: Dictionary = obstacles[layer]
		if cells.has(cell) and String(cells[cell].id) == id:
			cells.erase(cell)
	var key: Variant = content_key_at(obstacles, cell)
	if key != null and String(obstacles.content[key].id) == id:
		(obstacles.content as Dictionary).erase(key)


## The "content" key (top-left cell) of the obstacle covering `cell`, or null if none covers it.
static func content_key_at(obstacles: Dictionary, cell: Vector2i) -> Variant:
	for key in obstacles.content:
		var rect: Rect2i = obstacles.content[key].rect
		if rect.has_point(cell):
			return key
	return null
