# Gives hits to obstacle layers (overlay, content, underlay) and removes them at 0 hp.
# A "hitset" Dictionary is shared by one special / one combo / one match, so each obstacle takes
# at most one hit from it (IR-10, IR-12, IR-13, IR-14, IR-45). Check: test_damage_and_obstacles.gd.
class_name BoardDamage
extends RefCounted


## A special covering this cell: one hit to its top obstacle layer (IR-09).
static func hit_top_layer(board: BoardModel, cell: Vector2i, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	if board.overlay_hp(cell.x, cell.y) > 0:
		hit_overlay(board, cell, hitset, events)
	elif board.get_content(cell.x, cell.y) != null:
		hit_content(board, board.get_content(cell.x, cell.y), hitset, events)
	elif board.underlay_hp(cell.x, cell.y) > 0:
		hit_underlay(board, cell, hitset, events)


## Hits a match gives: the layer under/over its own pieces (IR-15) and every adjacent-match
## obstacle or overlay next to any of its pieces, once each (IR-14). Diagonals never count.
static func hit_by_match(board: BoardModel, match_cells: Array[Vector2i], events: Array[BoardEvent]) -> void:
	var hitset: Dictionary = {}
	var in_match: Dictionary = {}
	for c in match_cells:
		in_match[c] = true
	for c in match_cells:
		# Open question OQ-29: a matched piece under an overlay hits the overlay, not the underlay.
		if board.overlay_hp(c.x, c.y) > 0:
			hit_overlay(board, c, hitset, events)
		elif board.underlay_hp(c.x, c.y) > 0:
			hit_underlay(board, c, hitset, events)
	for c in match_cells:
		for n in neighbours(c):
			if in_match.has(n) or not board.is_playable(n.x, n.y):
				continue
			if board.overlay_hp(n.x, n.y) > 0:
				if ObstacleRegistry.behaviour(board.overlay_id(n.x, n.y)).takes_adjacent_match_hits():
					hit_overlay(board, n, hitset, events)
				continue
			var content: BoardContent = board.get_content(n.x, n.y)
			if content != null and ObstacleRegistry.behaviour(content.id).takes_adjacent_match_hits():
				hit_content(board, content, hitset, events)


static func hit_overlay(board: BoardModel, cell: Vector2i, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	var key: String = "overlay:%d,%d" % [cell.x, cell.y]
	if hitset.has(key):
		return
	hitset[key] = true
	var id: String = board.overlay_id(cell.x, cell.y)
	var hp: int = board.overlay_hp(cell.x, cell.y) - 1
	board.set_overlay_hp(cell.x, cell.y, hp)
	events.append(_hit_event(cell, "overlay", id, hp))
	if hp <= 0:
		events.append_array(ObstacleRegistry.behaviour(id).on_cleared(board, id, cell, null))


static func hit_underlay(board: BoardModel, cell: Vector2i, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	var key: String = "underlay:%d,%d" % [cell.x, cell.y]
	if hitset.has(key):
		return
	hitset[key] = true
	var id: String = board.underlay_id(cell.x, cell.y)
	var hp: int = board.underlay_hp(cell.x, cell.y) - 1
	board.set_underlay_hp(cell.x, cell.y, hp)
	events.append(_hit_event(cell, "underlay", id, hp))
	if hp <= 0:
		events.append_array(ObstacleRegistry.behaviour(id).on_cleared(board, id, cell, null))


static func hit_content(board: BoardModel, content: BoardContent, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	if hitset.has(content):
		return
	hitset[content] = true
	content.hp -= 1
	var cell: Vector2i = content.rect.position
	events.append(_hit_event(cell, "content", content.id, content.hp))
	if content.hp <= 0:
		board.remove_content(content)
		events.append_array(ObstacleRegistry.behaviour(content.id).on_cleared(board, content.id, cell, content))


static func neighbours(c: Vector2i) -> Array[Vector2i]:
	return [c + Vector2i.UP, c + Vector2i.DOWN, c + Vector2i.LEFT, c + Vector2i.RIGHT]


static func _hit_event(cell: Vector2i, layer: String, id: String, hp_left: int) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new("hit")
	e.cell = cell
	e.data = {"layer": layer, "id": id, "hp": maxi(hp_left, 0)}
	return e
