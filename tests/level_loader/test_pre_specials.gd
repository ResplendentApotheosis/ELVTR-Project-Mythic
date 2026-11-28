# LevelLoader tests for pre-level booster and streak-chest specials on the starting board (IR-77):
# placement by seed, never under moss, the piece's colour, and the Rocket's direction (more targets wins).
# Test seams: options stub_special_cells and stub_tie_pick (API_CONTRACT.md 11.2). Check: run the GUT suite.
extends "res://tests/level_loader/level_loader_test_base.gd"

const ROCKETS: Array[String] = ["rocket_row", "rocket_col"]


func _special_cells(board: BoardModel) -> Array[Vector2i]:
	return BB.find_kinds(board, ["rocket_row", "rocket_col", "firecracker", "crane"])


func _rocket_at(level: Dictionary, cell: Vector2i, extra: Dictionary = {}) -> String:
	var opts: Dictionary = {"seed": 1234, "pre_specials": ["rocket"], "stub_special_cells": [cell]}
	for k in extra:
		opts[k] = extra[k]
	var a: Variant = load_attempt(level, opts)
	if a == null:
		return ""
	return String(a.board.get_kind(cell.x, cell.y))


func _brambles(cells: Array) -> Array:
	var out: Array = []
	for c in cells:
		out.append({"type": "OB02", "x": c[0], "y": c[1], "hp": 1})
	return out


func test_IR77_rocket_and_crane_same_seed_same_cells_and_colours_piece_colour_kept() -> void:
	var level: Dictionary = LF.level(16)
	var opts: Dictionary = {"seed": 1234, "pre_specials": ["rocket", "crane"]}
	var a1: Variant = load_attempt(level, opts)
	var a2: Variant = load_attempt(level, opts)
	var plain: Variant = load_attempt(level, {"seed": 1234})
	if a1 == null or a2 == null or plain == null:
		return
	var b1: BoardModel = a1.board
	var cells: Array[Vector2i] = _special_cells(b1)
	assert_eq(cells.size(), 2, "one Rocket and one Crane")
	assert_eq(_special_cells(a2.board), cells, "same seed, same cells")
	for c in cells:
		assert_eq(a2.board.get_color(c.x, c.y), b1.get_color(c.x, c.y), "same colour at %s" % c)
		assert_eq(b1.get_color(c.x, c.y), plain.board.get_color(c.x, c.y), "keeps the colour of the piece it replaced at %s" % c)
		assert_eq(plain.board.get_kind(c.x, c.y), "plain", "it replaced a plain piece")
	assert_eq(BB.find_kind(b1, "crane").size(), 1)
	assert_eq(BB.find_kinds(b1, ROCKETS).size(), 1)
	assert_false(BB.has_match(b1), "the board still has no match")


func test_IR77_firecracker_never_under_moss_never_replaces_fixed_tile_drop_or_obstacle_200_seeds() -> void:
	var objects: Array = [{"type": "OB02", "x": 0, "y": 8, "hp": 1}]
	for i in range(20):
		objects.append({"type": "OB03", "x": 1 + (i % 7), "y": 2 + floori(i / 7.0), "hp": 1})   # 20 moss cells
	var level: Dictionary = LF.level(38, {
		"objects": objects,
		"fixed_tiles": [{"x": 4, "y": 8, "tile": "crane", "color": "red"}],
		"spawn": {"drop_items": {"type": "OB11", "total": 2, "max_on_board": 2}, "generators": null}})
	for s in range(1, 201):
		var a: Variant = load_attempt(level, {"seed": s, "pre_specials": ["firecracker"]})
		if a == null:
			return
		var b: BoardModel = a.board
		var fc: Array[Vector2i] = BB.find_kind(b, "firecracker")
		if fc.size() != 1:
			fail_test("seed %d: expected 1 Firecracker, got %d" % [s, fc.size()])
			return
		if b.overlay_hp(fc[0].x, fc[0].y) > 0:
			fail_test("seed %d: Firecracker under moss at %s" % [s, fc[0]])
			return
		if b.get_kind(4, 8) != "crane" or LF.drops(b, "OB11").size() != 2 or b.content_id(0, 8) != "OB02":
			fail_test("seed %d: the Firecracker replaced a fixed tile, a drop item or an obstacle" % s)
			return
		if BB.has_match(b):
			fail_test("seed %d: match on the board" % s)
			return
	pass_test("200 seeds fine")


func test_IR77_row_with_more_goal_brambles_gives_a_row_rocket() -> void:
	var level: Dictionary = LF.level(12, {"goals": [{"obstacle": "OB02", "count": 4}],
		"objects": _brambles([[0, 5], [1, 5], [8, 5], [2, 0]])})
	assert_eq(_rocket_at(level, Vector2i(2, 5)), "rocket_row", "row 5 holds 3, column 2 holds 1")


func test_IR77_column_with_more_goal_brambles_gives_a_column_rocket() -> void:
	var level: Dictionary = LF.level(12, {"goals": [{"obstacle": "OB02", "count": 4}],
		"objects": _brambles([[0, 5], [1, 5], [8, 5], [2, 0]])})
	assert_eq(_rocket_at(level, Vector2i(8, 2)), "rocket_col", "row 2 holds 0, column 8 holds 1")


func test_IR77_tie_is_a_seeded_50_50_repeatable_and_stubbable() -> void:
	var level: Dictionary = LF.level(12, {"goals": [{"obstacle": "OB02", "count": 2}],
		"objects": _brambles([[0, 5], [2, 0]])})
	var first: String = _rocket_at(level, Vector2i(2, 5))
	assert_true(ROCKETS.has(first), "a Rocket")
	assert_eq(_rocket_at(level, Vector2i(2, 5)), first, "same seed, same direction")
	assert_eq(_rocket_at(level, Vector2i(2, 5), {"stub_tie_pick": "column"}), "rocket_col")
	assert_eq(_rocket_at(level, Vector2i(2, 5), {"stub_tie_pick": "row"}), "rocket_row")
	var zero: String = _rocket_at(level, Vector2i(6, 7))
	assert_true(ROCKETS.has(zero), "0 and 0 is also a tie")
	assert_eq(_rocket_at(level, Vector2i(6, 7)), zero, "same seed, same draw")
	assert_eq(_rocket_at(level, Vector2i(6, 7), {"stub_tie_pick": "column"}), "rocket_col")
	assert_eq(_rocket_at(level, Vector2i(6, 7), {"stub_tie_pick": "row"}), "rocket_row")


func test_IR77_ties_use_both_directions_across_seeds() -> void:
	var level: Dictionary = LF.level(12, {"goals": [{"obstacle": "OB02", "count": 2}],
		"objects": _brambles([[0, 5], [2, 0]])})
	var seen: Dictionary = {}
	for s in range(1, 41):
		var k: String = _rocket_at(level, Vector2i(2, 5), {"seed": s})
		seen[k] = true
	assert_true(seen.has("rocket_row") and seen.has("rocket_col"), "a 50/50 draw gives both over 40 seeds, got %s" % [seen.keys()])


func test_IR77_pillar_counts_once_per_line() -> void:
	var objects: Array = _brambles([[0, 1], [0, 7]])
	objects.append({"type": "OB06", "x": 4, "y": 4, "w": 2, "h": 2, "hp": 2})
	var level: Dictionary = LF.level(16, {"goals": [{"obstacle": "OB06", "count": 1}, {"obstacle": "OB02", "count": 2}],
		"objects": objects})
	assert_eq(_rocket_at(level, Vector2i(0, 4)), "rocket_col", "row 4 holds 1 (pillar once), column 0 holds 2")


func test_IR77_moss_is_not_a_goal_so_it_does_not_count() -> void:
	var objects: Array = _brambles([[8, 5]])
	for y in [1, 2, 3]:
		objects.append({"type": "OB03", "x": 2, "y": y, "hp": 1})
	var level: Dictionary = LF.level(12, {"goals": [{"obstacle": "OB02", "count": 1}], "objects": objects})
	assert_eq(_rocket_at(level, Vector2i(2, 5)), "rocket_row", "row 5 holds 1, column 2 holds 0")


func test_IR77_dew_goal_counts_playable_cells_without_dew() -> void:
	var under: Array = LF.rows(9, 9, "s")
	for x in range(4):
		under = LF.with_char(under, x, 3, ".")          # row 3: 4 cells without dew
	under = LF.with_char(under, 6, 0, ".")
	under = LF.with_char(under, 6, 1, ".")              # column 6: 2 cells without dew; (6,3) itself has dew
	var level: Dictionary = LF.level(12, {"goals": [{"obstacle": "OB04", "count": 80}], "underlay": under})
	assert_eq(_rocket_at(level, Vector2i(6, 3)), "rocket_row", "row 3 holds 4, column 6 holds 2")


func test_IR77_drop_items_count_one_each() -> void:
	var level: Dictionary = LF.level(38, {"goals": [{"obstacle": "OB11", "count": 3}],
		"spawn": {"drop_items": {"type": "OB11", "total": 3, "max_on_board": 2}, "generators": null}})
	var kind: String = _rocket_at(level, Vector2i(5, 0), {"stub_drop_columns": [1, 7]})
	assert_eq(kind, "rocket_row", "row 0 holds 2 hatchlings, column 5 holds 0")
