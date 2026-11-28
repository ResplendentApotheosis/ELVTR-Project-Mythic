# Turns a level file (level_agent_brief.md section 5 + "fragment") into a LevelAttempt: board layers,
# fixed tiles, a seeded starting fill with no match and 3+ matching swaps, drop items and pre-level specials.
# Never runs the full validate() on load; it gives null + last_errors only for an unknown pre_specials name
# (IR-77) or a board that can't be built or played (moves < 1, broken shape; structure_errors, IR-88).
# Check: run the GUT suite; tests/level_loader/ covers it (API: tests/API_CONTRACT.md section 11).
class_name LevelLoader
extends RefCounted

const COLOR_LETTERS: Dictionary = {"red": "R", "yellow": "Y", "blue": "B", "green": "G"}
const ALL_COLORS: Array[String] = ["red", "yellow", "blue", "green"]
# fixed_tiles names that are specials (IR-76); the plain-colour names are the keys of COLOR_LETTERS.
const SPECIAL_TILES: Dictionary = {
	"line_h": "rocket_row", "line_v": "rocket_col", "firecracker": "firecracker", "crane": "crane", "orb": "orb",
}
const FILL_TRIES: int = 200        # re-draws of the starting fill until it has no match and 3 matching swaps
const MIN_MATCHING_SWAPS: int = 3  # IR-69

static var _seed_source: RandomNumberGenerator = null   # only used to pick a NEW seed when none is given
## Why the last load_level / load_file / retry failed ("IR-77: ..." Strings); [] after a good load.
static var last_errors: Array = []
## How many boards have been built (load_level, so also load_file and retry). Tests reset it to 0.
static var build_count: int = 0


# ---------------------------------------------------------------- public API

static func level_path(id: int) -> String:
	return "res://levels/level_%03d.json" % id


## Builds a new attempt from a level dictionary. Never validates: assumes a valid level.
## Returns null (nothing placed) if options hold an unknown pre_specials name; see last_errors (IR-77).
static func load_level(level: Dictionary, options: Dictionary = {}) -> LevelAttempt:
	last_errors = structure_errors(level)
	last_errors.append_array(LevelStartItems.pre_special_errors(options))
	if not last_errors.is_empty():
		return null
	var seed_value: int = as_int(options["seed"], 0) if options.has("seed") else new_seed(0)
	var attempt: LevelAttempt = LevelAttempt.new()
	attempt.level = level.duplicate(true)
	attempt.level_id = as_int(level.get("id"), 0)
	attempt.seed_value = seed_value
	attempt.board = _build_board(attempt.level, seed_value, options)
	build_count += 1
	attempt.tracker = GoalTracker.new(goal_list(attempt.level), attempt.level_id)
	attempt.board.goal_tracker = attempt.tracker
	if has_dew_goal(attempt.level):
		attempt.tracker.attach(attempt.board)
	var field: Variant = level.get("fragment")
	if field is Dictionary:
		attempt.fragment_guardian = String((field as Dictionary).get("guardian", "rat"))
	return attempt


## Reads a JSON level file and builds an attempt; null if the file is missing or not a JSON object.
static func load_file(path: String, options: Dictionary = {}) -> LevelAttempt:
	last_errors = []
	var level: Variant = read_level_file(path)
	if not level is Dictionary:
		return null
	var attempt: LevelAttempt = load_level(level as Dictionary, options)
	if attempt == null:
		return null
	attempt.source_path = path
	return attempt


## IR-58, IR-71: a new attempt built again from the file (or the same dictionary), with a new seed.
## Lives and coins are copied from the last attempt (SaveService owns them); everything else starts fresh.
static func retry(previous: LevelAttempt, options: Dictionary = {}) -> LevelAttempt:
	last_errors = []
	var opts: Dictionary = options.duplicate()
	if not opts.has("seed"):
		opts["seed"] = new_seed(previous.seed_value)
	var attempt: LevelAttempt = null
	if previous.source_path != "":
		attempt = load_file(previous.source_path, opts)
	else:
		attempt = load_level(previous.level, opts)
	if attempt == null:
		return null
	attempt.tracker.lives = previous.tracker.lives
	attempt.tracker.coins = previous.tracker.coins
	return attempt


## Only the problems that make a board impossible to build or play (producer decision, 28 Nov 2026, for
## IR-88): moves under 1, or a missing / empty / malformed board shape. NOT the full validate(): a level
## that breaks a design rule (e.g. an obstacle before its debut, IR-67) still builds. [] = buildable.
static func structure_errors(level: Dictionary) -> Array:
	var errors: Array = []
	if as_int(level.get("moves"), 30) < 1:
		errors.append("IR-68: moves must be at least 1 (got %s)" % str(level.get("moves")))
	var w: int = as_int(level.get("width"), 9)
	var h: int = as_int(level.get("height"), 9)
	if w < 1 or h < 1:
		errors.append("IR-64: width and height must be at least 1 (got %d x %d)" % [w, h])
		return errors
	var cells: Variant = level.get("cells")
	if not cells is Array or (cells as Array).size() != h:
		errors.append("IR-64: cells must be a list of %d rows" % h)
		return errors
	var playable: int = 0
	for row in cells:
		if not row is String or (row as String).length() != w:
			errors.append("IR-64: every cells row must be %d characters" % w)
			return errors
		playable += (row as String).count("#")
	if playable == 0:
		errors.append("IR-64: the board has no playable (#) cell")
	return errors


## Problems with a level, one String each, starting with the IR it breaks; [] = valid (API_CONTRACT 11.4).
static func validate(level: Dictionary, file_id: int = -1) -> Array:
	return LevelValidator.validate(level, file_id)


# ---------------------------------------------------------------- helpers shared with the validator

## The parsed JSON (a Dictionary for a level file), or null if the file is missing or not JSON.
static func read_level_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return json.data


## JSON numbers arrive as floats: this turns a number into an int (anything else gives `fallback`).
static func as_int(value: Variant, fallback: int = 0) -> int:
	if value is int:
		return value
	if value is float:
		return int(value)
	return fallback


## A new random seed, never equal to `avoid` (IR-72: every attempt gets a new seed).
static func new_seed(avoid: int) -> int:
	if _seed_source == null:
		_seed_source = RandomNumberGenerator.new()
		_seed_source.randomize()
	var s: int = int(_seed_source.randi())
	while s == avoid:
		s = int(_seed_source.randi())
	return s


## The level's colour names: all four, or the three in color_set on a 3-colour level (IR-68).
static func color_names(level: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var set_v: Variant = level.get("color_set")
	if as_int(level.get("colors"), 4) == 3 and set_v is Array:
		for c in set_v:
			if COLOR_LETTERS.has(String(c)) and not out.has(String(c)):
				out.append(String(c))
	if out.is_empty():
		out = ALL_COLORS.duplicate()
	return out


static func has_dew_goal(level: Dictionary) -> bool:
	for g in goal_list(level):
		if String(g.get("obstacle", "")) == "OB04" and not bool(g.get("fragment", false)):
			return true
	return false


## The board's shape, underlay, objects and dew targets: no pieces yet (validator uses it for goal counts).
static func build_layers(level: Dictionary, seed_value: int) -> BoardModel:
	var w: int = as_int(level.get("width"), 9)
	var h: int = as_int(level.get("height"), 9)
	var board: BoardModel = BoardModel.new(w, h, seed_value)
	board.moves = as_int(level.get("moves"), 30)
	board.palette = []
	for name in color_names(level):
		board.palette.append(COLOR_LETTERS[name])
	var cells: Array = _list(level, "cells")
	var under: Array = _list(level, "underlay")
	for y in range(h):
		for x in range(w):
			board.set_playable(x, y, _char(cells, x, y) == "#")
			if not board.is_playable(x, y):
				continue
			var u: String = _char(under, x, y)
			if u == "s":
				board.set_underlay(x, y, "OB04", 1)
			elif u in ["1", "2", "3"]:
				board.set_underlay(x, y, "OB10", int(u))
	for o in _list(level, "objects"):
		_place_object(board, o)
	if has_dew_goal(level):
		for y in range(h):
			for x in range(w):
				if board.is_playable(x, y):
					board.set_dew_target(x, y)
	return board


# ---------------------------------------------------------------- building the board

## Order (API_CONTRACT 11.3): shape, underlay, objects, fixed tiles, plain fill, drop items, pre-level specials.
static func _build_board(level: Dictionary, seed_value: int, options: Dictionary) -> BoardModel:
	var board: BoardModel = build_layers(level, seed_value)
	board.goals = _goal_ids(level)
	var drops: Dictionary = dict_of(dict_of(level.get("spawn")).get("drop_items"))
	board.exit_columns = []
	for c in array_of(drops.get("exit_columns")):
		board.exit_columns.append(as_int(c, -1))
	var fixed: Dictionary = place_fixed_tiles(board, level)
	for i in range(FILL_TRIES):
		_fill(board, fixed)
		LevelStartItems.place_drop_items(board, drops, fixed, options)
		if MatchFinder.find_groups(board).is_empty() and count_matching_swaps(board, MIN_MATCHING_SWAPS) >= MIN_MATCHING_SWAPS:
			break
	LevelStartItems.place_pre_specials(board, level, fixed, options)
	return board


static func _place_object(board: BoardModel, o: Variant) -> void:
	if not o is Dictionary:
		return
	var d: Dictionary = o
	var id: String = String(d.get("type", ""))
	var x: int = as_int(d.get("x"), -1)
	var y: int = as_int(d.get("y"), -1)
	var hp: int = as_int(d.get("hp"), 1)
	if id == "OB03":
		board.set_overlay(x, y, "OB03", hp)   # moss is an overlay; a piece goes under it (IR-66)
		return
	board.add_content(id, x, y, hp, as_int(d.get("w"), 1), as_int(d.get("h"), 1), bool(d.get("fragment", false)))
	if id == "OB05":
		var needs: Dictionary = {}
		var raw: Dictionary = dict_of(d.get("needs"))
		for name in raw:
			if COLOR_LETTERS.has(String(name)):
				needs[COLOR_LETTERS[String(name)]] = as_int(raw[name], 0)
		board.set_shrine_needs(x, y, needs)
	elif id == "OB08":
		board.set_content_color(x, y, String(COLOR_LETTERS.get(String(d.get("color", "")), "")))


## IR-76: plain colours and specials in their cells. Returns the fixed cells (Vector2i -> true).
static func place_fixed_tiles(board: BoardModel, level: Dictionary) -> Dictionary:
	var fixed: Dictionary = {}
	for t in _list(level, "fixed_tiles"):
		if not t is Dictionary:
			continue
		var d: Dictionary = t
		var cell: Vector2i = Vector2i(as_int(d.get("x"), -1), as_int(d.get("y"), -1))
		if not board.is_playable(cell.x, cell.y) or board.get_content(cell.x, cell.y) != null:
			continue
		var tile: String = String(d.get("tile", ""))
		if COLOR_LETTERS.has(tile):
			board.set_piece(cell.x, cell.y, "plain", COLOR_LETTERS[tile])
		elif tile == "orb":
			board.set_piece(cell.x, cell.y, "orb", "")
		elif SPECIAL_TILES.has(tile):
			var color: String = String(COLOR_LETTERS.get(String(d.get("color", "")), ""))
			if color == "":
				color = String(board.palette[board.rng.randi_range(0, board.palette.size() - 1)])   # seeded (IR-72)
			board.set_piece(cell.x, cell.y, SPECIAL_TILES[tile], color)
		else:
			continue
		fixed[cell] = true
	return fixed


## IR-69: a seeded plain piece in every free cell (under moss and on underlays too), avoiding matches.
static func _fill(board: BoardModel, fixed: Dictionary) -> void:
	for y in range(board.height):
		for x in range(board.width):
			if needs_piece(board, x, y) and not fixed.has(Vector2i(x, y)):
				board.clear_piece(x, y)
	for y in range(board.height):
		for x in range(board.width):
			if needs_piece(board, x, y) and not fixed.has(Vector2i(x, y)):
				board.set_piece(x, y, "plain", BoardGravity.pick_refill_color(board, Vector2i(x, y)))


## A playable cell with no content obstacle: it holds a piece at the start.
static func needs_piece(board: BoardModel, x: int, y: int) -> bool:
	return board.is_playable(x, y) and board.get_content(x, y) == null


## How many swaps of two plain, unlocked neighbours make a match (stops at `stop_at`). IR-69.
static func count_matching_swaps(board: BoardModel, stop_at: int) -> int:
	var n: int = 0
	for y in range(board.height):
		for x in range(board.width):
			var a: Vector2i = Vector2i(x, y)
			for b in [a + Vector2i.RIGHT, a + Vector2i.DOWN]:
				if not _swappable_plain(board, a) or not _swappable_plain(board, b):
					continue
				board.swap_pieces(a, b)
				if MatchFinder.has_match_at(board, a) or MatchFinder.has_match_at(board, b):
					n += 1
				board.swap_pieces(a, b)
				if n >= stop_at:
					return n
	return n


static func _swappable_plain(board: BoardModel, c: Vector2i) -> bool:
	return board.get_kind(c.x, c.y) == "plain" and not board.is_locked(c.x, c.y)


# ---------------------------------------------------------------- small readers (JSON-safe)

## Goals as dictionaries with int counts (JSON gives floats).
static func goal_list(level: Dictionary) -> Array:
	var out: Array = []
	for g in _list(level, "goals"):
		if g is Dictionary:
			var copy: Dictionary = (g as Dictionary).duplicate()
			if copy.has("count"):
				copy["count"] = as_int(copy["count"], 0)
			out.append(copy)
	return out


## Goal ids for the Crane (board.goals): obstacle ids, and "fragment" for the fragment goal.
static func _goal_ids(level: Dictionary) -> Array:
	var out: Array = []
	for g in goal_list(level):
		var id: String = "fragment" if bool(g.get("fragment", false)) else String(g.get("obstacle", ""))
		if id != "" and not out.has(id):
			out.append(id)
	return out


static func _char(rows: Array, x: int, y: int) -> String:
	if y < 0 or y >= rows.size():
		return "."
	var row: String = String(rows[y])
	return row[x] if x >= 0 and x < row.length() else "."


static func _list(level: Dictionary, key: String) -> Array:
	return array_of(level.get(key))


static func array_of(value: Variant) -> Array:
	return value if value is Array else []


static func dict_of(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
