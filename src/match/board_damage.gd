# Gives hits to obstacle layers (overlay, content, underlay) and removes them at 0 hp.
# A "hitset" Dictionary is shared by one special / one combo / one match, so each obstacle takes
# at most one hit from it (IR-10, IR-12, IR-13, IR-14, IR-45). Check: test_damage_and_obstacles.gd.
class_name BoardDamage
extends RefCounted

const HealingDew: GDScript = preload("res://src/obstacles/ob04_healing_dew.gd")


## A special covering this cell: one hit to its top obstacle layer (IR-09). Dew is never hit.
static func hit_top_layer(board: BoardModel, cell: Vector2i, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	if board.overlay_hp(cell.x, cell.y) > 0:
		hit_overlay(board, cell, hitset, events)
	elif board.get_content(cell.x, cell.y) != null:
		hit_content(board, board.get_content(cell.x, cell.y), hitset, events)
	elif board.underlay_hp(cell.x, cell.y) > 0:
		hit_underlay(board, cell, hitset, events)


## Records the cells one special (or combo) has cleared and covered so far in its hitset. If any
## cleared cell is on healing dew, every covered cell gets dew (IR-53, owner decision OQ-46),
## including cells covered earlier by the same special. Call it AFTER the hits, so goo has taken
## its hit first (owner decision OQ-56, chat 27 Nov 2026).
static func note_cleared(board: BoardModel, cleared: Array[Vector2i], covered: Array[Vector2i], hitset: Dictionary) -> void:
	if not hitset.has("cleared_cells"):
		hitset["cleared_cells"] = [] as Array[Vector2i]
		hitset["covered_cells"] = [] as Array[Vector2i]
	var all_cleared: Array[Vector2i] = hitset["cleared_cells"]
	all_cleared.append_array(cleared)
	var all_covered: Array[Vector2i] = hitset["covered_cells"]
	for c in covered:
		if not all_covered.has(c):
			all_covered.append(c)
	HealingDew.spread(board, all_cleared, all_covered)


## Hits a match gives: the layer under/over its own pieces (IR-15) and every adjacent-match
## obstacle or overlay next to any of its pieces, once each (IR-14). Diagonals never count.
## A match on dew spreads it to all its cells (IR-53), after the goo under them took its hit (OQ-56).
static func hit_by_match(board: BoardModel, match_cells: Array[Vector2i], events: Array[BoardEvent]) -> void:
	var hitset: Dictionary = {}
	var in_match: Dictionary = {}
	for c in match_cells:
		in_match[c] = true
	for c in match_cells:
		# Owner decision OQ-41 (chat 27 Nov 2026): a matched piece under an overlay is cleared and
		# hits the overlay only, not the underlay below it.
		if board.overlay_hp(c.x, c.y) > 0:
			hit_overlay(board, c, hitset, events)
		elif board.underlay_hp(c.x, c.y) > 0:
			hit_underlay(board, c, hitset, events)
	HealingDew.spread(board, match_cells, match_cells)
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
	var id: String = board.underlay_id(cell.x, cell.y)
	if not ObstacleRegistry.behaviour(id).takes_hits():
		return   # healing dew is never damaged (IR-53)
	var key: String = "underlay:%d,%d" % [cell.x, cell.y]
	if hitset.has(key):
		return
	hitset[key] = true
	var hp: int = board.underlay_hp(cell.x, cell.y) - 1
	board.set_underlay_hp(cell.x, cell.y, hp)
	events.append(_hit_event(cell, "underlay", id, hp))
	if hp <= 0:
		events.append_array(ObstacleRegistry.behaviour(id).on_cleared(board, id, cell, null))


static func hit_content(board: BoardModel, content: BoardContent, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	if hitset.has(content):
		return
	var behaviour: ObstacleBehaviour = ObstacleRegistry.behaviour(content.id)
	if not behaviour.can_be_hit(content):
		return
	hitset[content] = true
	content.hp -= 1
	events.append(_hit_event(content.rect.position, "content", content.id, content.hp))
	behaviour.after_content_hit(board, content, events)


static func neighbours(c: Vector2i) -> Array[Vector2i]:
	return [c + Vector2i.UP, c + Vector2i.DOWN, c + Vector2i.LEFT, c + Vector2i.RIGHT]


static func _hit_event(cell: Vector2i, layer: String, id: String, hp_left: int) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new("hit")
	e.cell = cell
	e.data = {"layer": layer, "id": id, "hp": maxi(hp_left, 0)}
	return e
