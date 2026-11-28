# Validator checks for a level's `objects` (IR-66, IR-73) and `fixed_tiles` (IR-76, plus IR-69: fixed
# tiles must not form a match on their own). Used by LevelValidator; each error starts with its IR id.
# Check: tests/level_loader/test_validator_layout.gd (IR-66) and test_validator_rules.gd (IR-73, IR-76).
class_name LevelObjectChecks
extends RefCounted

const MULTI_CELL: Array[String] = ["OB05", "OB06", "OB16"]
# IR-66: allowed hp per object type [lowest, highest]. OB12 always has 2 hits.
const HP_RANGE: Dictionary = {
	"OB02": [1, 3], "OB03": [1, 3], "OB05": [1, 3], "OB07": [1, 3], "OB08": [1, 3], "OB06": [1, 4], "OB12": [2, 2],
}


static func check_objects(level: Dictionary, colors: Array[String], shape_ok: bool, errors: Array) -> void:
	var w: int = LevelLoader.as_int(level.get("width"), 0)
	var h: int = LevelLoader.as_int(level.get("height"), 0)
	var cells: Array = LevelLoader.array_of(level.get("cells"))
	var taken: Dictionary = {}   # Vector2i -> true
	for o in LevelLoader.array_of(level.get("objects")):
		if not o is Dictionary:
			errors.append("IR-66: an objects entry is not an object: %s" % [o])
			continue
		var d: Dictionary = o
		var id: String = String(d.get("type", ""))
		var x: int = LevelLoader.as_int(d.get("x"), -1)
		var y: int = LevelLoader.as_int(d.get("y"), -1)
		var ow: int = LevelLoader.as_int(d.get("w"), 1)
		var oh: int = LevelLoader.as_int(d.get("h"), 1)
		if ow < 1 or oh < 1 or (not MULTI_CELL.has(id) and (ow != 1 or oh != 1)):
			errors.append("IR-66: %s at (%d,%d) has size %dx%d; only OB05, OB06 and OB16 cover more than one cell" % [id, x, y, ow, oh])
		if HP_RANGE.has(id):
			var hp: int = LevelLoader.as_int(d.get("hp"), -1)
			var r: Array = HP_RANGE[id]
			if hp < int(r[0]) or hp > int(r[1]):
				errors.append("IR-66: %s at (%d,%d) has hp %s, allowed %d-%d" % [id, x, y, d.get("hp"), r[0], r[1]])
		if shape_ok:
			for dy in range(maxi(oh, 1)):
				for dx in range(maxi(ow, 1)):
					var c: Vector2i = Vector2i(x + dx, y + dy)
					if c.x < 0 or c.y < 0 or c.x >= w or c.y >= h:
						errors.append("IR-66: %s at (%d,%d) goes off the board at (%d,%d)" % [id, x, y, c.x, c.y])
					elif String(cells[c.y])[c.x] != "#":
						errors.append("IR-66: %s at (%d,%d) is on a cell that is not playable (%d,%d)" % [id, x, y, c.x, c.y])
					elif taken.has(c):
						errors.append("IR-66: two objects share the cell (%d,%d)" % [c.x, c.y])
					taken[c] = true
		if id == "OB08":
			var color: String = String(d.get("color", ""))
			if not colors.has(color):
				errors.append("IR-66: OB08 at (%d,%d) needs a \"color\" among the level's colours %s, found '%s'" % [x, y, colors, color])
		if id == "OB05":
			_check_needs(d, x, y, colors, errors)


## IR-73: needs is a non-empty count per colour, each count at least 1, each colour one of the level's.
static func _check_needs(d: Dictionary, x: int, y: int, colors: Array[String], errors: Array) -> void:
	var needs: Variant = d.get("needs")
	if not needs is Dictionary or (needs as Dictionary).is_empty():
		errors.append("IR-73: OB05 at (%d,%d) needs a \"needs\" list with at least one colour" % [x, y])
		return
	for name in needs:
		if not colors.has(String(name)):
			errors.append("IR-73: OB05 at (%d,%d) needs '%s', which is not one of the level's colours %s" % [x, y, name, colors])
		if LevelLoader.as_int((needs as Dictionary)[name], 0) < 1:
			errors.append("IR-73: OB05 at (%d,%d) needs %s of '%s'; every count is at least 1" % [x, y, (needs as Dictionary)[name], name])


## IR-76 (and IR-69 for a match made by fixed tiles alone). True if a board can be built with them.
static func check_fixed_tiles(level: Dictionary, colors: Array[String], shape_ok: bool, errors: Array) -> bool:
	var before: int = errors.size()
	var tiles: Array = LevelLoader.array_of(level.get("fixed_tiles"))
	if tiles.is_empty() or not shape_ok:
		return errors.size() == before
	var board: BoardModel = LevelLoader.build_layers(level, 1)
	var probe: BoardModel = BoardModel.new(board.width, board.height, 1)   # fixed tiles only, to look for a match
	var used: Dictionary = {}
	for t in tiles:
		if not t is Dictionary:
			errors.append("IR-76: a fixed_tiles entry is not an object: %s" % [t])
			continue
		var d: Dictionary = t
		var c: Vector2i = Vector2i(LevelLoader.as_int(d.get("x"), -1), LevelLoader.as_int(d.get("y"), -1))
		var tile: String = String(d.get("tile", ""))
		var has_color: bool = d.get("color") != null
		var color: String = String(d.get("color", ""))
		if not LevelLoader.COLOR_LETTERS.has(tile) and not LevelLoader.SPECIAL_TILES.has(tile):
			errors.append("IR-76: unknown tile '%s' at (%d,%d)" % [tile, c.x, c.y])
			continue
		if not board.is_playable(c.x, c.y):
			errors.append("IR-76: tile at (%d,%d) is not on a playable cell" % [c.x, c.y])
		elif board.get_content(c.x, c.y) != null:
			errors.append("IR-76: tile at (%d,%d) is on an obstacle (%s)" % [c.x, c.y, board.content_id(c.x, c.y)])
		elif used.has(c):
			errors.append("IR-76: two fixed tiles on (%d,%d)" % [c.x, c.y])
		used[c] = true
		if LevelLoader.COLOR_LETTERS.has(tile):
			if not colors.has(tile):
				errors.append("IR-76: tile '%s' at (%d,%d) is not one of the level's colours %s" % [tile, c.x, c.y, colors])
			else:
				probe.set_piece(c.x, c.y, "plain", LevelLoader.COLOR_LETTERS[tile])
		elif tile == "orb":
			if has_color:
				errors.append("IR-76: the orb at (%d,%d) has no colour" % [c.x, c.y])
		elif has_color:
			if not colors.has(color):
				errors.append("IR-76: tile '%s' at (%d,%d) has colour '%s', not one of the level's %s" % [tile, c.x, c.y, color, colors])
			elif probe.in_bounds(c.x, c.y):
				probe.set_piece(c.x, c.y, LevelLoader.SPECIAL_TILES[tile], LevelLoader.COLOR_LETTERS[color])
	if errors.size() == before and not MatchFinder.find_groups(probe).is_empty():
		errors.append("IR-69: the fixed tiles make a match on their own")
	return errors.size() == before
