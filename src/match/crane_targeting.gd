# Chooses the Paper Crane's target cell (IR-49): an unfreed fragment first, else the goal with the
# fewest hits left; ties go to the closest cell (straight-line), then top-most, then left-most. No goal
# left: the nearest obstacle or uncovered dew target; none: a piece picked with board.rng. Check: test_special_effects.gd IR-20, IR-49.
class_name CraneTargeting
extends RefCounted

const LanternShrine: GDScript = preload("res://src/obstacles/ob05_lantern_shrine.gd")


## `start` is the Crane's cell (used for distance); `exclude` cells are never chosen.
static func choose(board: BoardModel, start: Vector2i, exclude: Array[Vector2i]) -> Vector2i:
	# 1. An unfreed soul fragment always comes first.
	if board.goals.has("fragment"):
		var frag: Array[Vector2i] = _goal_cells(board, "fragment", exclude)
		if not frag.is_empty():
			return _closest(frag, start)
	# 2. The unfinished goal(s) with the fewest hits left.
	var best_hits: int = -1
	var best_cells: Array[Vector2i] = []
	for g in board.goals:
		var goal: String = String(g)
		if goal == "fragment":
			continue
		var cells: Array[Vector2i] = _goal_cells(board, goal, exclude)
		if cells.is_empty():
			continue
		var hits: int = _hits_left(board, goal)
		if best_hits < 0 or hits < best_hits:
			best_hits = hits
			best_cells = cells
		elif hits == best_hits:
			best_cells.append_array(cells)
	if not best_cells.is_empty():
		return _closest(best_cells, start)
	# 3. No goal left: the nearest remaining obstacle on any layer, or uncovered dew target
	#    (owner decision OQ-38). Dew itself is not an obstacle to hit. Open question OQ-59 (c)
	#    (provisional): a lit lantern shrine is not a target any more.
	var obstacles: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			var c: Vector2i = Vector2i(x, y)
			if exclude.has(c):
				continue
			var hittable_underlay: bool = board.underlay_hp(x, y) > 0 and not board.has_dew(x, y)
			var content: BoardContent = board.get_content(x, y)
			var live_content: bool = content != null and not content.lit
			if board.overlay_hp(x, y) > 0 or live_content or hittable_underlay \
					or board.is_uncovered_dew_target(x, y):
				obstacles.append(c)
	if not obstacles.is_empty():
		return _closest(obstacles, start)
	# 4. No obstacle left: a seeded random piece.
	var pieces: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			var c2: Vector2i = Vector2i(x, y)
			var kind: String = board.get_kind(x, y)
			if kind != "" and kind != "drop" and not exclude.has(c2):
				pieces.append(c2)
	if pieces.is_empty():
		return Vector2i(-1, -1)
	return pieces[board.rng.randi_range(0, pieces.size() - 1)]


## Cells still holding something of this goal: uncovered target cells for dew ("OB04"), a cocoon
## with a fragment or a fragment drop item for "fragment", a drop item for "OB11", else obstacles with that id.
static func _goal_cells(board: BoardModel, goal: String, exclude: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			var c: Vector2i = Vector2i(x, y)
			if exclude.has(c) or not board.is_playable(x, y):
				continue
			var content: BoardContent = board.get_content(x, y)
			var hit: bool = false
			if goal == "OB04":
				hit = board.is_uncovered_dew_target(x, y)
			elif goal == "fragment":
				hit = (content != null and content.fragment) or board.get_drop_item(x, y) == "fragment"
			elif board.get_drop_item(x, y) == goal:
				hit = true
			elif content != null and content.id == goal and not content.lit:
				hit = true
			elif board.overlay_id(x, y) == goal or board.underlay_id(x, y) == goal:
				hit = true
			if hit:
				out.append(c)
	return out


## Hits left for a goal (owner decision OQ-34): dew = uncovered target cells; lantern shrine =
## pieces still needed; drop items = items still on the board; others = the sum of hp of its
## obstacles (each multi-cell obstacle once).
static func _hits_left(board: BoardModel, goal: String) -> int:
	if goal == "OB04":
		return board.dew_targets_left()
	var total: int = 0
	for content in board.all_contents():
		if content.id == goal:
			total += LanternShrine.pieces_needed(content) if goal == "OB05" else content.hp
	for y in range(board.height):
		for x in range(board.width):
			if board.overlay_id(x, y) == goal:
				total += board.overlay_hp(x, y)
			if board.underlay_id(x, y) == goal:
				total += board.underlay_hp(x, y)
			if board.get_drop_item(x, y) == goal:
				total += 1
	return total


## Closest cell by straight-line distance (owner decision OQ-34), then top-most, then left-most.
static func _closest(cells: Array[Vector2i], start: Vector2i) -> Vector2i:
	var best: Vector2i = cells[0]
	var best_d: int = _distance_squared(best, start)
	for c in cells:
		var d: int = _distance_squared(c, start)
		if d < best_d or (d == best_d and (c.y < best.y or (c.y == best.y and c.x < best.x))):
			best = c
			best_d = d
	return best


## Squared straight-line distance: compares the same way as the real distance, with whole numbers.
static func _distance_squared(a: Vector2i, b: Vector2i) -> int:
	return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
