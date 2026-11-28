# LevelLoader tests for the starting drop items (IR-75 load-time part) and the fragment on the n-th item (IR-31).
# OUT OF SCOPE for this module (MatchResolver refill work, write them there): IR-75 test cases 3, 6 and 7
# (replacement items entering at the next refill, only in columns that get a new piece, several collected at once).
# Contract: tests/API_CONTRACT.md section 11. Check: run the GUT suite; the names carry the IR id.
extends "res://tests/level_loader/level_loader_test_base.gd"


func _drop_level(total: int, max_on_board: int, extra: Dictionary = {}, overrides: Dictionary = {}) -> Dictionary:
	var di: Dictionary = {"type": "OB11", "total": total, "max_on_board": max_on_board, "exit_columns": [2, 6]}
	for k in extra:
		di[k] = extra[k]
	var d: Dictionary = LF.level(38, {"spawn": {"drop_items": di, "generators": null}})
	for k in overrides:
		d[k] = overrides[k]
	return d


func test_IR75_one_hatchling_in_row_0_same_seed_same_column() -> void:
	var a1: Variant = load_attempt(_drop_level(3, 1), {"seed": 1234})
	var a2: Variant = load_attempt(_drop_level(3, 1), {"seed": 1234})
	if a1 == null or a2 == null:
		return
	var d1: Array[Vector2i] = LF.drops(a1.board, "OB11")
	assert_eq(d1.size(), 1, "exactly one hatchling at the start")
	assert_eq(d1[0].y, 0, "in row 0")
	assert_eq(LF.drops(a2.board, "OB11"), d1, "same seed, same column")
	assert_eq(vcall(a1.board, "get_kind", [d1[0].x, 0]), "drop")


func test_IR75_two_hatchlings_two_columns_and_total_caps_the_count() -> void:
	var a: Variant = load_attempt(_drop_level(3, 2), {"seed": 5})
	if a == null:
		return
	var d: Array[Vector2i] = LF.drops(a.board, "OB11")
	assert_eq(d.size(), 2)
	assert_eq(d[0].y, 0)
	assert_eq(d[1].y, 0)
	assert_ne(d[0].x, d[1].x, "two different columns")
	var capped: Variant = load_attempt(_drop_level(1, 2), {"seed": 5})
	if capped == null:
		return
	assert_eq(LF.drops(capped.board, "OB11").size(), 1, "total 1 beats max_on_board 2")
	assert_eq(vget(capped.board, "drop_spawned"), 1)


func test_IR75_start_state_for_later_spawns() -> void:
	var a: Variant = load_attempt(_drop_level(3, 2, {"fragment_item": 2}), {"seed": 5})
	if a == null:
		return
	assert_eq(vget(a.board, "drop_total"), 3)
	assert_eq(vget(a.board, "drop_max_on_board"), 2)
	assert_eq(vget(a.board, "drop_spawned"), 2, "the starting items count as spawned")
	assert_eq(vget(a.board, "drop_fragment_item"), 2)


func test_IR75_columns_with_covered_or_blocked_tops_never_get_an_item_200_seeds() -> void:
	var cells: Array = LF.rows(9, 9, "#")
	cells[0] = "..#######"
	var level: Dictionary = _drop_level(2, 2, {}, {
		"cells": cells,
		"objects": [{"type": "OB02", "x": 2, "y": 0, "hp": 1}, {"type": "OB03", "x": 3, "y": 0, "hp": 1}],
		"fixed_tiles": [{"x": 4, "y": 0, "tile": "red"}]})
	for s in range(1, 201):
		var a: Variant = load_attempt(level, {"seed": s})
		if a == null:
			return
		var d: Array[Vector2i] = LF.drops(a.board, "OB11")
		if d.size() != 2 or d[0].x == d[1].x:
			fail_test("seed %d: need 2 hatchlings in 2 columns, got %s" % [s, d])
			return
		for c in d:
			if [2, 3, 4].has(c.x):
				fail_test("seed %d: item in column %d whose top cell is not an uncovered plain piece" % [s, c.x])
				return
			if c.x < 2 and c.y != 1:
				fail_test("seed %d: columns 0 and 1 start at row 1, item at %s" % [s, c])
				return
			if c.x >= 5 and c.y != 0:
				fail_test("seed %d: item at %s should be in row 0" % [s, c])
				return
	pass_test("200 seeds fine")


func test_IR75_IR31_fragment_rides_item_number_two_counted_left_to_right() -> void:
	var a: Variant = load_attempt(_drop_level(3, 2, {"fragment_item": 2}), {"seed": 1, "stub_drop_columns": [6, 1]})
	if a == null:
		return
	assert_eq(vcall(a.board, "get_drop_item", [1, 0]), "OB11", "(1,0) is item 1, a plain hatchling")
	assert_eq(vcall(a.board, "get_drop_item", [6, 0]), "fragment", "(6,0) is item 2 and carries the fragment")
	assert_eq(LF.drops(a.board, "OB11").size(), 1)
	assert_eq(LF.drops(a.board, "fragment").size(), 1)


func test_IR31_fragment_on_item_one_when_it_is_the_leftmost() -> void:
	var a: Variant = load_attempt(_drop_level(3, 2, {"fragment_item": 1}), {"seed": 1, "stub_drop_columns": [6, 1]})
	if a == null:
		return
	assert_eq(vcall(a.board, "get_drop_item", [1, 0]), "fragment")
	assert_eq(vcall(a.board, "get_drop_item", [6, 0]), "OB11")


func test_IR31_loader_spawns_the_fragment_on_the_nth_drop_item() -> void:
	# total 3, max 1, fragment_item 2: the start shows item 1 (plain); the board remembers that item 2 carries the fragment
	var a: Variant = load_attempt(_drop_level(3, 1, {"fragment_item": 2}), {"seed": 8})
	if a == null:
		return
	assert_eq(LF.drops(a.board, "OB11").size(), 1, "item 1 is a plain hatchling")
	assert_eq(LF.drops(a.board, "fragment").size(), 0, "the fragment is not on the board yet")
	assert_eq(vget(a.board, "drop_fragment_item"), 2, "item 2 will carry the fragment; items 1 and 3 are plain")
	assert_eq(vget(a.board, "drop_total"), 3)
	assert_eq(vget(a.board, "drop_spawned"), 1)
