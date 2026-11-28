# Puts the starting drop items (IR-75, IR-31) and pre-level / streak-chest specials (IR-77) on a freshly
# filled starting board; every pick uses board.rng unless a test passes a stub. eligible_columns is shared
# with the validator (IR-75); pre_special_errors lets load_level refuse unknown names (IR-77).
# Check: tests/level_loader/test_drop_items_start.gd and test_pre_specials.gd.
class_name LevelStartItems
extends RefCounted

const PRE_SPECIAL_KINDS: Dictionary = {"rocket": "rocket", "crane": "crane", "firecracker": "firecracker"}


## IR-75: the first max_on_board items (never more than total), each in the top playable cell of a different
## seeded column whose top cell holds an uncovered plain piece; numbered left to right (fragment_item, IR-31).
static func place_drop_items(board: BoardModel, drops: Dictionary, fixed: Dictionary, options: Dictionary) -> void:
	var item_type: String = String(drops.get("type", "OB11"))
	board.drop_total = LevelLoader.as_int(drops.get("total"), 0)
	board.drop_max_on_board = LevelLoader.as_int(drops.get("max_on_board"), 0)
	board.drop_fragment_item = LevelLoader.as_int(drops.get("fragment_item"), 0)
	board.drop_spawned = 0
	var wanted: int = mini(board.drop_max_on_board, board.drop_total)
	if wanted <= 0:
		return
	var eligible: Array[int] = eligible_columns(board, fixed)
	var picked: Array[int] = []
	if options.has("stub_drop_columns"):
		for c in options["stub_drop_columns"]:
			picked.append(LevelLoader.as_int(c, -1))
	else:
		# The validator rejects a level with fewer eligible columns than max_on_board (IR-75), so a valid level
		# always has enough. If an invalid one is loaded anyway, this places as many as fit instead of crashing.
		while picked.size() < wanted and not eligible.is_empty():
			picked.append(eligible.pop_at(board.rng.randi_range(0, eligible.size() - 1)))
	picked.sort()
	for i in range(picked.size()):
		var x: int = picked[i]
		var y: int = top_playable_y(board, x)
		if y < 0:
			continue
		var number: int = board.drop_spawned + 1
		board.set_drop_item(x, y, "fragment" if number == board.drop_fragment_item else item_type)
		board.drop_spawned = number


## IR-75: columns that can take a starting drop item: the top playable cell holds (or will hold) an uncovered
## plain piece, so no content obstacle, no moss and no fixed tile. Used by the loader and by the validator.
static func eligible_columns(board: BoardModel, fixed: Dictionary) -> Array[int]:
	var out: Array[int] = []
	for x in range(board.width):
		var y: int = top_playable_y(board, x)
		if y >= 0 and LevelLoader.needs_piece(board, x, y) and board.overlay_hp(x, y) == 0 and not fixed.has(Vector2i(x, y)):
			out.append(x)
	return out


## IR-77: one "IR-77: ..." line per name in options.pre_specials that is not a known special.
static func pre_special_errors(options: Dictionary) -> Array:
	var errors: Array = []
	for n in LevelLoader.array_of(options.get("pre_specials", [])):
		if not (n is String and PRE_SPECIAL_KINDS.has(n)):
			errors.append("IR-77: unknown pre_special \"%s\"" % [n])
	return errors


## IR-77: each special replaces a seeded plain piece (not under moss, not a fixed tile) and keeps its colour.
static func place_pre_specials(board: BoardModel, level: Dictionary, fixed: Dictionary, options: Dictionary) -> void:
	var specials: Array = options.get("pre_specials", []) as Array
	var stub_cells: Array = options.get("stub_special_cells", []) as Array
	for i in range(specials.size()):
		var name: String = String(specials[i])   # load_level already refused unknown names (pre_special_errors)
		var cell: Vector2i = Vector2i(-1, -1)
		if i < stub_cells.size():
			cell = stub_cells[i]
		else:
			var options_list: Array[Vector2i] = _plain_cells(board, fixed)
			if options_list.is_empty():
				continue
			cell = options_list[board.rng.randi_range(0, options_list.size() - 1)]
		var color: String = board.get_color(cell.x, cell.y)
		var kind: String = name
		if name == "rocket":
			kind = _rocket_kind(board, level, cell, String(options.get("stub_tie_pick", "")))
		board.set_piece(cell.x, cell.y, kind, color)


## Top playable row of a column, or -1 if the column has none.
static func top_playable_y(board: BoardModel, x: int) -> int:
	for y in range(board.height):
		if board.is_playable(x, y):
			return y
	return -1


static func _plain_cells(board: BoardModel, fixed: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == "plain" and board.overlay_hp(x, y) == 0 and not fixed.has(Vector2i(x, y)):
				out.append(Vector2i(x, y))
	return out


## Row Rocket if its row holds more targets, column Rocket if its column does; a tie is a seeded 50/50.
static func _rocket_kind(board: BoardModel, level: Dictionary, cell: Vector2i, stub_tie: String) -> String:
	var row: Array[Vector2i] = []
	for x in range(board.width):
		row.append(Vector2i(x, cell.y))
	var col: Array[Vector2i] = []
	for y in range(board.height):
		col.append(Vector2i(cell.x, y))
	var row_targets: int = line_targets(board, level, row)
	var col_targets: int = line_targets(board, level, col)
	if row_targets > col_targets:
		return "rocket_row"
	if col_targets > row_targets:
		return "rocket_col"
	if stub_tie == "row":
		return "rocket_row"
	if stub_tie == "column":
		return "rocket_col"
	return "rocket_row" if board.rng.randi_range(0, 1) == 0 else "rocket_col"


## IR-77 targets in a line: each goal obstacle with a cell in it (once), playable cells without dew on a
## dew-goal level, and 1 per drop item.
static func line_targets(board: BoardModel, level: Dictionary, cells: Array[Vector2i]) -> int:
	var goal_ids: Dictionary = {}
	for g in LevelLoader.goal_list(level):
		goal_ids[String(g.get("obstacle", ""))] = true
	var dew_goal: bool = LevelLoader.has_dew_goal(level)
	var seen: Array[BoardContent] = []
	var n: int = 0
	for c in cells:
		if not board.is_playable(c.x, c.y):
			continue
		var content: BoardContent = board.get_content(c.x, c.y)
		if content != null and goal_ids.has(content.id) and not seen.has(content):
			seen.append(content)
			n += 1
		if board.overlay_hp(c.x, c.y) > 0 and goal_ids.has(board.overlay_id(c.x, c.y)):
			n += 1
		var under: String = board.underlay_id(c.x, c.y)
		if under != "" and under != "OB04" and goal_ids.has(under):
			n += 1
		if dew_goal and not board.has_dew(c.x, c.y):
			n += 1
		if board.get_kind(c.x, c.y) == "drop":
			n += 1
	return n
