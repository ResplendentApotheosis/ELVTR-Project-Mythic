# Validator check: does each goal's count match what the level places on the board? (IR-61, IR-31)
# Counts units, not hp; dew (OB04) goals: more than the seed cells, at most 90% of playable (OQ-74, OQ-66);
# fragment goals need exactly one marked cocoon or a valid drop-item number (OQ-71).
# Check: tests/goal_tracker/test_goal_units.gd (the "validator" tests). Used via GoalTracker.goal_count_errors.
class_name GoalCountCheck
extends RefCounted

const DEW_SHARE_TENTHS: int = 9   # a dew goal may ask for at most 9/10 of the playable cells


## Problems with the goal counts; [] = valid. `spawn` = the level file's "spawn" object (may be {}).
static func errors(goals: Array, board: BoardModel, spawn: Dictionary = {}) -> Array:
	var out: Array = []
	for g in goals:
		var id: String = String(g.get("obstacle", ""))
		var count: int = int(g.get("count", 0))
		if id == "":
			continue
		if bool(g.get("fragment", false)):
			_check_fragment(id, board, spawn, out)
		elif id == "OB04":
			_check_dew(count, board, out)
		else:
			var placed: int = count_placed(board, id) + _spawned(id, spawn)
			if count != placed:
				out.append("goal %s count %d but %d placed" % [id, count, placed])
	return out


## OQ-74: count > seed cells (so at least one new dew cell is needed).
## OQ-66 (trial): count <= 90% of the playable cells.
static func _check_dew(count: int, board: BoardModel, out: Array) -> void:
	var seeds: int = seed_cells(board)
	if count <= seeds:
		out.append("dew goal %d is not more than the %d seed cells" % [count, seeds])
	var playable: int = playable_cells(board)
	if count * 10 > playable * DEW_SHARE_TENTHS:
		out.append("dew goal %d is more than 90%% of the %d playable cells" % [count, playable])


## OQ-71: a fragment rides exactly one marked cocoon (OB07) or the n-th drop item (OB11).
static func _check_fragment(id: String, board: BoardModel, spawn: Dictionary, out: Array) -> void:
	if id == "OB07":
		var marked: int = 0
		for c in board.all_contents():
			if c.id == "OB07" and c.fragment:
				marked += 1
		if marked != 1:
			out.append("fragment goal needs exactly one OB07 with \"fragment\": true, found %d" % marked)
	elif id == "OB11":
		var items: Dictionary = spawn.get("drop_items", {})
		var total: int = int(items.get("total", 0))
		var n: int = int(items.get("fragment_item", 0))
		if String(items.get("type", "")) != "OB11" or n < 1 or n > total:
			out.append("fragment goal needs spawn.drop_items.fragment_item in 1..%d, found %d" % [total, n])
	else:
		out.append("a fragment goal must be OB07 or OB11, not %s" % id)


## Drop items still to spawn during the level (they count toward a plain OB11 goal).
static func _spawned(id: String, spawn: Dictionary) -> int:
	var items: Dictionary = spawn.get("drop_items", {})
	if String(items.get("type", "")) != id:
		return 0
	return int(items.get("total", 0))


## How many units of this obstacle id are on the board.
static func count_placed(board: BoardModel, id: String) -> int:
	var n: int = 0
	for c in board.all_contents():
		if c.id == id:
			n += 1
	for y in range(board.height):
		for x in range(board.width):
			if board.overlay_id(x, y) == id:
				n += 1
			if board.underlay_id(x, y) == id:
				n += 1
			if board.get_drop_item(x, y) == id:
				n += 1
	return n


## Seed cells: cells that start with dew (underlay OB04) when the level is checked.
static func seed_cells(board: BoardModel) -> int:
	var n: int = 0
	for y in range(board.height):
		for x in range(board.width):
			if board.underlay_id(x, y) == "OB04":
				n += 1
	return n


static func playable_cells(board: BoardModel) -> int:
	var n: int = 0
	for y in range(board.height):
		for x in range(board.width):
			if board.is_playable(x, y):
				n += 1
	return n


## Playable cells that have healing dew now (seed cells included; each cell once). OQ-66 trial.
static func dew_cells(board: BoardModel) -> int:
	var n: int = 0
	for y in range(board.height):
		for x in range(board.width):
			if board.has_dew(x, y):
				n += 1
	return n
