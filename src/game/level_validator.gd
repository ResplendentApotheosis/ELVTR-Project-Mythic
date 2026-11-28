# Checks a level dictionary against the level-file rules: identity, shape, moves, colours, debuts, fragment,
# goals and starting drop columns (IR-63..IR-70, IR-75, IR-31, IR-59, IR-61); object and fixed-tile checks live in LevelObjectChecks.
# Each error starts with its IR id; GoalTracker's goal errors start with "goals: ". Public entry: LevelLoader.validate.
# Check: tests/level_loader/test_validator_layout.gd and test_validator_rules.gd.
class_name LevelValidator
extends RefCounted

const PLAN_PATH: String = "res://research/match-villains/levels_1_100_plan.csv"
const LAST_LEVEL: int = 50
const TIERS: Array[String] = ["intro", "easy", "medium", "hard", "finale"]
const FINALE_LEVELS: Array[int] = [25, 50]
const HARD_LEVELS: Array[int] = [15, 20, 30, 35, 40, 45]
const MAX_SIDE: int = 9
const MIN_MOVES: int = 16
const MOVES_SLACK: int = 2
const FRAGMENT_ITEM_FROM: int = 38   # fragments ride drop items only from level 38 (IR-70)
# IR-67: debut level of every obstacle used in levels 1-50. Anything else (OB09, OB13-OB17) is never used.
const DEBUT: Dictionary = {
	"OB02": 1, "OB04": 4, "OB03": 7, "OB05": 10, "OB06": 13, "OB07": 17, "OB08": 22, "OB10": 28, "OB11": 34, "OB12": 41,
}

static var _plan: Dictionary = {}   # level id -> {"tier": String, "moves": int}, read once from PLAN_PATH


static func validate(level: Dictionary, file_id: int = -1) -> Array:
	var errors: Array = []
	var id: int = LevelLoader.as_int(level.get("id"), -1)
	_check_identity(level, id, file_id, errors)
	var tier: String = String(level.get("tier", ""))
	var colors: Array[String] = _check_colors(level, tier, errors)
	_check_moves(level, id, errors)
	var shape_ok: bool = _check_shape(level, errors)
	var before_layout: int = errors.size()
	LevelObjectChecks.check_objects(level, colors, shape_ok, errors)
	var tiles_ok: bool = LevelObjectChecks.check_fixed_tiles(level, colors, shape_ok, errors)
	var layout_ok: bool = shape_ok and errors.size() == before_layout
	_check_debuts(level, id, errors)
	_check_fragment(level, id, errors)
	var goals: Array = LevelLoader.goal_list(level)
	for e in GoalTracker.goal_errors(id, tier, goals):
		errors.append("goals: " + String(e))
	if shape_ok:
		var layers: BoardModel = LevelLoader.build_layers(level, 1)
		var spawn: Dictionary = {"drop_items": LevelLoader.dict_of(LevelLoader.dict_of(level.get("spawn")).get("drop_items"))}
		for e in GoalTracker.goal_count_errors(goals, layers, spawn):
			errors.append("goals: " + String(e))
	if layout_ok and tiles_ok:
		_check_drop_columns(level, errors)
		_check_start_board(level, errors)
	return errors


## Plan row for a level ({} if the plan file can't be read or has no row for it).
static func plan_row(id: int) -> Dictionary:
	if _plan.is_empty() and FileAccess.file_exists(PLAN_PATH):
		for line in FileAccess.get_file_as_string(PLAN_PATH).split("\n", false):
			var cols: PackedStringArray = line.split(",")
			if cols.size() > 3 and cols[0].is_valid_int():
				_plan[int(cols[0])] = {"tier": cols[2].strip_edges(), "moves": int(cols[3])}
	return _plan.get(id, {})


# ---------------------------------------------------------------- IR-63

static func _check_identity(level: Dictionary, id: int, file_id: int, errors: Array) -> void:
	if id < 1 or id > LAST_LEVEL:
		errors.append("IR-63: id must be a level number 1-%d, found %s" % [LAST_LEVEL, level.get("id")])
		return
	if file_id >= 0 and id != file_id:
		errors.append("IR-63: id %d does not match the file name (level_%03d)" % [id, file_id])
	var chapter: int = 1 if id <= 25 else 2
	if LevelLoader.as_int(level.get("chapter"), -1) != chapter:
		errors.append("IR-63: level %d is in chapter %d, found %s" % [id, chapter, level.get("chapter")])
	var tier: String = String(level.get("tier", ""))
	if not TIERS.has(tier):
		errors.append("IR-63: unknown tier '%s'" % tier)
		return
	var fixed_tier: String = "finale" if FINALE_LEVELS.has(id) else ("hard" if HARD_LEVELS.has(id) else "")
	if fixed_tier != "" and tier != fixed_tier:
		errors.append("IR-63: level %d must be %s, found %s" % [id, fixed_tier, tier])
	elif fixed_tier == "" and (tier == "hard" or tier == "finale"):
		errors.append("IR-63: only levels %s are hard and %s are finales, level %d is %s" % [HARD_LEVELS, FINALE_LEVELS, id, tier])
	var beat: Variant = level.get("story_beat")
	if tier == "hard" and beat != "mini":
		errors.append("IR-63: a hard level has story_beat \"mini\", found %s" % [beat])
	if tier == "finale" and beat != "chapter":
		errors.append("IR-63: a finale has story_beat \"chapter\", found %s" % [beat])


# ---------------------------------------------------------------- IR-68

## Checks colors / color_set and returns the level's colour names (all four if they are not valid).
static func _check_colors(level: Dictionary, tier: String, errors: Array) -> Array[String]:
	var colors: int = LevelLoader.as_int(level.get("colors"), -1)
	var color_set: Variant = level.get("color_set")
	if colors == 4:
		if color_set != null:
			errors.append("IR-68: a 4-colour level has no color_set")
	elif colors == 3:
		if tier != "intro":
			errors.append("IR-68: 3 colours only on an intro level, this one is %s" % tier)
		if not color_set is Array:
			errors.append("IR-68: a 3-colour level names its colours in color_set")
		else:
			var seen: Array[String] = []
			for c in color_set:
				var name: String = String(c)
				if not LevelLoader.COLOR_LETTERS.has(name):
					errors.append("IR-68: unknown colour '%s' in color_set" % name)
				elif seen.has(name):
					errors.append("IR-68: colour '%s' twice in color_set" % name)
				else:
					seen.append(name)
			if (color_set as Array).size() != 3:
				errors.append("IR-68: color_set needs 3 colours, found %d" % (color_set as Array).size())
	else:
		errors.append("IR-68: colors must be 4 (or 3 on an intro level), found %s" % [level.get("colors")])
	return LevelLoader.color_names(level)


static func _check_moves(level: Dictionary, id: int, errors: Array) -> void:
	var moves: int = LevelLoader.as_int(level.get("moves"), -1)
	if moves < MIN_MOVES:
		var shown: Variant = moves if (level.get("moves") is int or level.get("moves") is float) else level.get("moves")
		errors.append("IR-68: moves %s is under %d" % [shown, MIN_MOVES])   # JSON gives 0.0: show it as 0
	var plan: Dictionary = plan_row(id)
	if plan.is_empty():
		errors.append("IR-68: no plan row for level %d (is %s readable?)" % [id, PLAN_PATH])
	elif absi(moves - int(plan["moves"])) > MOVES_SLACK:
		errors.append("IR-68: moves %d is more than %d away from the plan's %d" % [moves, MOVES_SLACK, plan["moves"]])


# ---------------------------------------------------------------- IR-64, IR-65

## True when width, height, cells and underlay are all well formed (so a board can be built).
static func _check_shape(level: Dictionary, errors: Array) -> bool:
	var before: int = errors.size()
	var w: int = LevelLoader.as_int(level.get("width"), -1)
	var h: int = LevelLoader.as_int(level.get("height"), -1)
	if w < 1 or w > MAX_SIDE or h < 1 or h > MAX_SIDE:
		errors.append("IR-64: the board is %sx%s, it must be 1-9 by 1-9" % [level.get("width"), level.get("height")])
		return false
	var cells: Array = LevelLoader.array_of(level.get("cells"))
	_check_grid(cells, "cells", "IR-64", "#.", w, h, errors)
	var under: Array = LevelLoader.array_of(level.get("underlay"))
	_check_grid(under, "underlay", "IR-65", ".123s", w, h, errors)
	if errors.size() == before:
		for y in range(h):
			for x in range(w):
				if String(under[y])[x] != "." and String(cells[y])[x] != "#":
					errors.append("IR-65: underlay at (%d,%d) is on a cell that is not playable" % [x, y])
	return errors.size() == before


static func _check_grid(rows: Array, key: String, ir: String, allowed: String, w: int, h: int, errors: Array) -> void:
	if rows.size() != h:
		errors.append("%s: %s has %d rows, height is %d" % [ir, key, rows.size(), h])
	for y in range(rows.size()):
		var row: String = String(rows[y])
		if row.length() != w:
			errors.append("%s: row %d of %s has %d characters, width is %d" % [ir, y, key, row.length(), w])
		for i in range(row.length()):
			if not allowed.contains(row[i]):
				errors.append("%s: row %d of %s has '%s'; only '%s' are allowed" % [ir, y, key, row[i], allowed])


# ---------------------------------------------------------------- IR-67

static func _check_debuts(level: Dictionary, id: int, errors: Array) -> void:
	var used: Dictionary = {}   # obstacle id -> where it was found
	for o in LevelLoader.array_of(level.get("objects")):
		if o is Dictionary:
			used[String((o as Dictionary).get("type", ""))] = "objects"
	for row in LevelLoader.array_of(level.get("underlay")):
		var text: String = String(row)
		if text.contains("s"):
			used["OB04"] = "underlay"
		if text.contains("1") or text.contains("2") or text.contains("3"):
			used["OB10"] = "underlay"
	var spawn: Dictionary = LevelLoader.dict_of(level.get("spawn"))
	var drops: Variant = spawn.get("drop_items")
	if drops is Dictionary:
		used[String((drops as Dictionary).get("type", ""))] = "spawn.drop_items"
	if spawn.get("generators") != null:
		errors.append("IR-67: spawn.generators is not used in levels 1-%d" % LAST_LEVEL)
	for g in LevelLoader.goal_list(level):
		var gid: String = String(g.get("obstacle", ""))
		if gid != "" and not used.has(gid):
			used[gid] = "goals"
	for obstacle in used:
		var oid: String = String(obstacle)
		if not DEBUT.has(oid):
			errors.append("IR-67: %s (in %s) is not used in levels 1-%d" % [oid, used[obstacle], LAST_LEVEL])
		elif id >= 1 and id < int(DEBUT[oid]):
			errors.append("IR-67: %s (in %s) debuts at level %d, this is level %d" % [oid, used[obstacle], DEBUT[oid], id])


# ---------------------------------------------------------------- IR-70, IR-31

static func _check_fragment(level: Dictionary, id: int, errors: Array) -> void:
	var fragment_level: bool = GoalTracker.FRAGMENT_LEVELS.has(id)
	var field: Variant = level.get("fragment")
	var has_field: bool = field != null
	if has_field and not fragment_level:
		errors.append("IR-70: level %d is not a fragment level but has a fragment field" % id)
	if fragment_level and not has_field:
		errors.append("IR-70: level %d is a fragment level and needs the fragment field" % id)
	if has_field and (not field is Dictionary or (field as Dictionary).get("guardian") != "rat" or (field as Dictionary).get("scripted") != true):
		errors.append("IR-70: the fragment field must be {\"guardian\": \"rat\", \"scripted\": true}")
	var fragment_goals: Array = []
	for g in LevelLoader.goal_list(level):
		if bool(g.get("fragment", false)):
			fragment_goals.append(g)
	if has_field and fragment_goals.is_empty():
		errors.append("IR-70: the fragment field needs a goal with \"fragment\": true")
	if not has_field and not fragment_goals.is_empty():
		errors.append("IR-70: a fragment goal needs the fragment field")
	if fragment_goals.size() > 1:
		errors.append("IR-31: only one fragment goal, found %d" % fragment_goals.size())
	var drops: Dictionary = LevelLoader.dict_of(LevelLoader.dict_of(level.get("spawn")).get("drop_items"))
	var rides_item: bool = drops.has("fragment_item")
	for g in fragment_goals:
		var gid: String = String(g.get("obstacle", ""))
		if gid != "OB07" and gid != "OB11":
			errors.append("IR-31: a fragment goal is OB07 or OB11, found %s" % gid)
		if LevelLoader.as_int(g.get("count"), 0) != 1:
			errors.append("IR-31: a fragment goal has count 1")
		if gid == "OB11":
			rides_item = true
	if rides_item and id < FRAGMENT_ITEM_FROM:
		errors.append("IR-70: a fragment rides a drop item only from level %d" % FRAGMENT_ITEM_FROM)
	var item_goal: bool = fragment_goals.any(func(g: Dictionary) -> bool: return String(g.get("obstacle", "")) == "OB11")
	if drops.has("fragment_item") and not item_goal:
		errors.append("IR-31: spawn.drop_items has fragment_item but no OB11 fragment goal")
	var cocoon_goal: bool = fragment_goals.any(func(g: Dictionary) -> bool: return String(g.get("obstacle", "")) == "OB07")
	for o in LevelLoader.array_of(level.get("objects")):
		if o is Dictionary and bool((o as Dictionary).get("fragment", false)):
			if String((o as Dictionary).get("type", "")) != "OB07":
				errors.append("IR-31: only an OB07 entry can hold the fragment")
			elif not cocoon_goal:
				errors.append("IR-31: an OB07 entry holds the fragment but there is no OB07 fragment goal")


# ---------------------------------------------------------------- IR-75

## Enough columns must be able to take a starting drop item (same test the loader uses to pick them).
static func _check_drop_columns(level: Dictionary, errors: Array) -> void:
	var drops: Dictionary = LevelLoader.dict_of(LevelLoader.dict_of(level.get("spawn")).get("drop_items"))
	var wanted: int = mini(LevelLoader.as_int(drops.get("max_on_board"), 0), LevelLoader.as_int(drops.get("total"), 0))
	if wanted <= 0:
		return
	var board: BoardModel = LevelLoader.build_layers(level, 1)
	var fixed: Dictionary = LevelLoader.place_fixed_tiles(board, level)
	var eligible: int = LevelStartItems.eligible_columns(board, fixed).size()
	if eligible < wanted:
		errors.append("IR-75: only %d column(s) can take a starting drop item, but max_on_board needs %d" % [eligible, wanted])


# ---------------------------------------------------------------- IR-69

## The loader must be able to build a starting board with no match and at least 3 matching swaps.
static func _check_start_board(level: Dictionary, errors: Array) -> void:
	var attempt: LevelAttempt = LevelLoader.load_level(level, {"seed": 1})
	if attempt == null:
		return   # the board could not be built at all; that problem (e.g. moves < 1) is already reported
	var board: BoardModel = attempt.board
	if not MatchFinder.find_groups(board).is_empty():
		errors.append("IR-69: the starting board has a match")
	elif LevelLoader.count_matching_swaps(board, LevelLoader.MIN_MATCHING_SWAPS) < LevelLoader.MIN_MATCHING_SWAPS:
		errors.append("IR-69: the starting board has fewer than %d swaps that make a match" % LevelLoader.MIN_MATCHING_SWAPS)
