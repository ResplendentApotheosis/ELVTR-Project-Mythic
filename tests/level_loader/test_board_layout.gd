# LevelLoader tests for how a level file becomes board layers: IR-64 (cells), IR-65 (underlay),
# IR-66 (objects and their layers), IR-73 (shrine needs). Contract: tests/API_CONTRACT.md section 11.
# Check: run the GUT suite; the names carry the IR id.
extends "res://tests/level_loader/level_loader_test_base.gd"


func _board(level: Dictionary, options: Dictionary = {}) -> Variant:
	var a: Variant = load_attempt(level, options)
	if a == null:
		return null
	return a.board


# ---------------------------------------------------------------- IR-64

func test_IR64_notches_in_row_0_are_not_playable() -> void:
	var cells: Array = LF.rows(9, 9, "#")
	cells[0] = "..#######"
	var b: Variant = _board(LF.level(12, {"cells": cells}))
	if b == null:
		return
	assert_false(b.is_playable(0, 0))
	assert_false(b.is_playable(1, 0))
	assert_true(b.is_playable(2, 0))
	var playable: int = 0
	for y in range(9):
		for x in range(9):
			if b.is_playable(x, y):
				playable += 1
	assert_eq(playable, 79, "81 cells minus the 2 notches")


func test_IR64_7_by_8_board_has_that_size() -> void:
	var b: Variant = _board(LF.level(12, {"width": 7, "height": 8, "cells": LF.rows(7, 8, "#"), "underlay": LF.rows(7, 8, ".")}))
	if b == null:
		return
	assert_eq(b.width, 7)
	assert_eq(b.height, 8)
	assert_true(b.is_playable(6, 7))
	assert_false(b.is_playable(7, 0), "column 7 is off the board")
	assert_false(b.is_playable(0, 8), "row 8 is off the board")


func test_IR64_only_entry_point_is_the_top_playable_cell_of_the_column() -> void:
	var b: Variant = _board(LF.level(12))
	if b == null:
		return
	b.set_piece(6, 8, "")
	var events: Array[BoardEvent] = MatchResolver.settle(b)
	var refills: Array = EV.of_type(events, "refill")
	assert_gt(refills.size(), 0, "a refill happened")
	assert_eq((refills[0] as BoardEvent).cells, [Vector2i(6, 0)] as Array[Vector2i], "the only new piece enters at (6,0)")
	assert_true((b.spawners as Array).is_empty(), "levels 1-50 load no spawner cells")


func test_IR64_json_file_numbers_are_read_as_ints() -> void:
	var a: Variant = load_file("res://tests/level_loader/fixtures/level_fixture_012.json", {"seed": 5})
	if a == null:
		return
	assert_eq(a.level_id, 12)
	assert_eq(a.board.width, 9)
	assert_eq(a.board.moves, 26)
	assert_false(a.board.is_playable(0, 0), "row 0 of the fixture is \"..#######\"")
	assert_eq(a.board.content_hp(1, 1), 3, "the pillar hp came through the JSON floats")


# ---------------------------------------------------------------- IR-65

func test_IR65_goo_and_dew_in_row_4() -> void:
	var under: Array = LF.rows(9, 9, ".")
	under[4] = "..2..s..."
	var b: Variant = _board(LF.level(30, {"underlay": under}))
	if b == null:
		return
	assert_eq(b.underlay_id(2, 4), "OB10")
	assert_eq(b.underlay_hp(2, 4), 2)
	assert_eq(b.underlay_id(5, 4), "OB04")
	assert_true(b.underlay_hp(5, 4) > 0)
	var others: int = 0
	for x in range(9):
		if b.underlay_hp(x, 4) > 0:
			others += 1
	assert_eq(others, 2, "no underlay in the other 7 cells of row 4")
	assert_eq(b.get_kind(2, 4), "plain")
	assert_eq(b.get_kind(5, 4), "plain")


func test_IR65_moss_over_a_piece_on_goo() -> void:
	var under: Array = LF.with_char(LF.rows(9, 9, "."), 3, 4, "1")
	var b: Variant = _board(LF.level(30, {"underlay": under, "objects": [{"type": "OB03", "x": 3, "y": 4, "hp": 1}]}))
	if b == null:
		return
	assert_eq(b.overlay_id(3, 4), "OB03")
	assert_eq(b.overlay_hp(3, 4), 1)
	assert_eq(b.get_kind(3, 4), "plain", "a piece under the moss")
	assert_eq(b.underlay_id(3, 4), "OB10")
	assert_eq(b.underlay_hp(3, 4), 1)


# ---------------------------------------------------------------- IR-66

func test_IR66_pillar_covers_its_cells_with_one_hp() -> void:
	var b: Variant = _board(LF.level(13, {"objects": [{"type": "OB06", "x": 1, "y": 0, "w": 1, "h": 4, "hp": 4}],
		"goals": [{"obstacle": "OB06", "count": 1}]}))
	if b == null:
		return
	for y in range(4):
		assert_eq(b.content_id(1, y), "OB06", "pillar at (1,%d)" % y)
		assert_eq(b.content_hp(1, y), 4)
		assert_eq(b.get_kind(1, y), "", "no piece under the pillar at (1,%d)" % y)
	assert_eq(b.get_content(1, 0), b.get_content(1, 3), "one obstacle, not four")
	assert_eq(b.get_content(1, 0).rect, Rect2i(1, 0, 1, 4))
	assert_eq(GoalTracker.count_placed(b, "OB06"), 1, "counts 1 toward an OB06 goal (IR-61)")
	assert_eq(b.content_id(1, 4), "", "the pillar ends at row 3")


func test_IR66_moss_is_an_overlay_over_a_locked_piece() -> void:
	var b: Variant = _board(LF.level(12, {"objects": [{"type": "OB03", "x": 3, "y": 4, "hp": 1}]}))
	if b == null:
		return
	assert_eq(b.overlay_id(3, 4), "OB03")
	assert_eq(b.overlay_hp(3, 4), 1)
	assert_eq(b.get_kind(3, 4), "plain")
	assert_true(b.is_locked(3, 4), "the piece under moss is locked (IR-54)")
	assert_eq(b.content_id(3, 4), "", "moss is not a content obstacle")


func test_IR66_bramble_creature_and_idol_fill_their_content_cell() -> void:
	var b: Variant = _board(LF.level(45, {"objects": [
		{"type": "OB02", "x": 0, "y": 6, "hp": 2},
		{"type": "OB07", "x": 4, "y": 4, "hp": 1},
		{"type": "OB12", "x": 5, "y": 5, "hp": 2}]}))
	if b == null:
		return
	assert_eq(b.content_id(0, 6), "OB02")
	assert_eq(b.content_hp(0, 6), 2)
	assert_eq(b.get_kind(0, 6), "")
	assert_eq(b.content_id(4, 4), "OB07")
	assert_eq(b.content_hp(4, 4), 1)
	assert_eq(b.get_kind(4, 4), "")
	assert_eq(b.content_id(5, 5), "OB12")
	assert_eq(b.content_hp(5, 5), 2, "a frozen idol has 2 hits left")
	assert_eq(b.get_kind(5, 5), "")


func test_IR66_paper_screen_lantern_has_colour_and_hp_and_is_not_lit() -> void:
	var b: Variant = _board(LF.level(30, {"objects": [{"type": "OB08", "x": 4, "y": 3, "hp": 2, "color": "red"}]}))
	if b == null:
		return
	assert_eq(b.content_id(4, 3), "OB08")
	assert_eq(b.content_hp(4, 3), 2, "screen hp")
	assert_eq(vcall(b, "content_color", [4, 3]), "R")
	assert_false(b.get_content(4, 3).lit, "not lit at the start")
	assert_eq(b.get_kind(4, 3), "")


# ---------------------------------------------------------------- IR-73

func test_IR73_shrine_needs_counts_per_colour_and_covers_2x2() -> void:
	var b: Variant = _board(LF.level(12, {"objects": [
		{"type": "OB05", "x": 3, "y": 3, "w": 2, "h": 2, "hp": 3, "needs": {"red": 2, "blue": 1}}]}))
	if b == null:
		return
	for c in [Vector2i(3, 3), Vector2i(4, 3), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_eq(b.content_id(c.x, c.y), "OB05", "shrine covers %s" % c)
		assert_eq(b.content_hp(c.x, c.y), 3)
		assert_eq(b.get_kind(c.x, c.y), "", "no piece in the shrine cell %s" % c)
	assert_eq(b.get_content(3, 3).rect, Rect2i(3, 3, 2, 2))
	var needs: Dictionary = b.shrine_needs(3, 3)
	assert_eq(int(needs.get("R", 0)), 2)
	assert_eq(int(needs.get("B", 0)), 1)
	assert_eq(int(needs.get("Y", 0)) + int(needs.get("G", 0)), 0, "needs nothing else")
