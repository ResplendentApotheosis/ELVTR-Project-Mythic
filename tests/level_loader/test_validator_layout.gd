# Validator tests (LevelLoader.validate) for the level file's identity and layout: IR-63, IR-64, IR-65, IR-66, IR-67.
# The later tools/validate_level script just calls validate(). Contract: tests/API_CONTRACT.md 11.4
# (each error starts with its IR id). Check: run the GUT suite; names carry the IR id.
extends "res://tests/level_loader/level_loader_test_base.gd"


func test_base_levels_are_valid_for_every_level_1_to_50() -> void:
	for id in range(1, 51):
		var e: Variant = errors_of(LF.valid(id), id)
		if e == null:
			return
		if not (e as Array).is_empty():
			fail_test("level %d fixture should be valid, got %s" % [id, e])
			return
	pass_test("all 50 fixtures valid")


# ---------------------------------------------------------------- IR-63

func test_IR63_id_must_match_the_file_name() -> void:
	expect_valid(LF.valid(26), "id 26 in level_026", 26)
	expect_rejected(LF.valid(26, {"id": 27}), "IR-63", "id 27 in level_026", 26)


func test_IR63_chapter_is_1_up_to_25_and_2_from_26() -> void:
	expect_rejected(LF.valid(26, {"chapter": 1}), "IR-63", "level 26 chapter 1")
	expect_valid(LF.valid(26, {"chapter": 2}), "level 26 chapter 2")
	expect_rejected(LF.valid(25, {"chapter": 2}), "IR-63", "level 25 chapter 2")


func test_IR63_tier_of_finales_and_hard_levels_is_fixed() -> void:
	expect_rejected(LF.valid(25, {"tier": "hard"}), "IR-63", "level 25 hard")
	expect_valid(LF.valid(25, {"tier": "finale"}), "level 25 finale")
	expect_rejected(LF.valid(30, {"tier": "medium"}), "IR-63", "level 30 medium")
	expect_valid(LF.valid(30, {"tier": "hard"}), "level 30 hard")
	expect_rejected(LF.valid(12, {"tier": "legendary"}), "IR-63", "unknown tier")


func test_IR63_story_beat_mini_on_hard_chapter_on_finale() -> void:
	expect_rejected(LF.valid(30, {"story_beat": null}), "IR-63", "level 30 no beat")
	expect_valid(LF.valid(30, {"story_beat": "mini"}), "level 30 mini")
	expect_valid(LF.valid(50, {"story_beat": "chapter"}), "level 50 chapter")
	expect_rejected(LF.valid(50, {"story_beat": "mini"}), "IR-63", "level 50 mini")


# ---------------------------------------------------------------- IR-64

func test_IR64_short_cells_row_and_wrong_row_count_are_rejected() -> void:
	var cells: Array = LF.rows(9, 9, "#")
	cells[3] = "########"
	expect_rejected(LF.valid(12, {"cells": cells}), "IR-64", "a row of 8 on width 9")
	expect_rejected(LF.valid(12, {"cells": LF.rows(9, 8, "#")}), "IR-64", "8 rows when height is 9")


func test_IR64_wider_than_9_and_foreign_characters_are_rejected() -> void:
	expect_rejected(LF.valid(12, {"width": 10, "cells": LF.rows(10, 9, "#"), "underlay": LF.rows(10, 9, ".")}), "IR-64", "width 10")
	expect_rejected(LF.valid(12, {"height": 10, "cells": LF.rows(9, 10, "#"), "underlay": LF.rows(9, 10, ".")}), "IR-64", "height 10")
	expect_rejected(LF.valid(12, {"cells": LF.with_char(LF.rows(9, 9, "#"), 8, 8, "S")}), "IR-64", "an S cell")


# ---------------------------------------------------------------- IR-65

func test_IR65_underlay_characters_and_size() -> void:
	expect_rejected(LF.valid(30, {"underlay": LF.with_char(LF.rows(9, 9, "."), 0, 8, "4")}), "IR-65", "a 4")
	expect_rejected(LF.valid(30, {"underlay": LF.with_char(LF.rows(9, 9, "."), 0, 8, "x")}), "IR-65", "an x")
	var short: Array = LF.rows(9, 9, ".")
	short[2] = "........"
	expect_rejected(LF.valid(30, {"underlay": short}), "IR-65", "underlay row of 8 on width 9")


func test_IR65_underlay_only_on_playable_cells() -> void:
	var cells: Array = LF.rows(9, 9, "#")
	cells[0] = "..#######"
	var under_s: Array = LF.rows(9, 9, ".")
	under_s[0] = "s........"
	var under_g: Array = LF.rows(9, 9, ".")
	under_g[0] = "1........"
	var under_ok: Array = LF.rows(9, 9, ".")
	under_ok[0] = "..s......"
	expect_rejected(LF.valid(30, {"cells": cells, "underlay": under_s}), "IR-65", "dew on a . cell")
	expect_rejected(LF.valid(30, {"cells": cells, "underlay": under_g}), "IR-65", "goo on a . cell")
	expect_valid(LF.valid(30, {"cells": cells, "underlay": under_ok}), "dew on the playable (2,0)")


# ---------------------------------------------------------------- IR-66

func test_IR66_overlap_off_board_and_dot_cell_are_rejected() -> void:
	expect_rejected(LF.valid_with(12, {"type": "OB02", "x": 0, "y": 6, "hp": 1}), "IR-66", "two entries on (0,6)")
	expect_rejected(LF.valid_with(13, {"type": "OB06", "x": 5, "y": 6, "w": 1, "h": 4, "hp": 2}), "IR-66", "pillar off the bottom")
	var cells: Array = LF.with_char(LF.rows(9, 9, "#"), 0, 6, ".")
	expect_rejected(LF.valid(12, {"cells": cells}), "IR-66", "bramble on a . cell")


func test_IR66_overlap_between_a_multicell_object_and_another_is_rejected() -> void:
	expect_rejected(LF.valid_with(15, {"type": "OB06", "x": 6, "y": 1, "w": 2, "h": 2, "hp": 2}), "IR-66", "2x2 pillar over the (7,1) pillar cell")


## valid_with, but the extra object's own goal count goes up by one so IR-61 (count = placed) stays satisfied
## and only the hp range is under test.
func _with_counted(id: int, obj: Dictionary) -> Dictionary:
	var d: Dictionary = LF.valid_with(id, obj)
	var goals: Array = []
	for g in (d["goals"] as Array):
		var g2: Dictionary = (g as Dictionary).duplicate()
		if g2.get("obstacle", "") == obj["type"] and not g2.has("fragment"):
			g2["count"] = int(g2["count"]) + 1
		goals.append(g2)
	d["goals"] = goals
	return d


func test_IR66_hp_ranges() -> void:
	expect_rejected(_with_counted(12, {"type": "OB02", "x": 5, "y": 7, "hp": 4}), "IR-66", "OB02 hp 4")
	expect_valid(_with_counted(12, {"type": "OB02", "x": 5, "y": 7, "hp": 3}), "OB02 hp 3")
	expect_rejected(LF.valid_with(41, {"type": "OB12", "x": 5, "y": 5, "hp": 3}), "IR-66", "OB12 hp 3")
	expect_valid(LF.valid_with(41, {"type": "OB12", "x": 5, "y": 5, "hp": 2}), "OB12 hp 2")
	expect_valid(_with_counted(12, {"type": "OB03", "x": 5, "y": 7, "hp": 3}), "OB03 hp 3")
	expect_rejected(_with_counted(12, {"type": "OB03", "x": 5, "y": 7, "hp": 4}), "IR-66", "OB03 hp 4")
	expect_rejected(LF.valid_with(17, {"type": "OB07", "x": 5, "y": 7, "hp": 0}), "IR-66", "OB07 hp 0")
	var shrine: Dictionary = {"type": "OB05", "x": 1, "y": 1, "w": 2, "h": 2, "needs": {"red": 2, "blue": 1}}
	expect_valid(LF.valid_with(12, shrine.merged({"hp": 3})), "OB05 hp 3")
	expect_rejected(LF.valid_with(12, shrine.merged({"hp": 4})), "IR-66", "OB05 hp 4")
	var pillar: Dictionary = {"type": "OB06", "x": 5, "y": 0, "w": 1, "h": 2}
	expect_valid(LF.valid_with(13, pillar.merged({"hp": 3})), "OB06 hp 3")
	expect_valid(LF.valid_with(13, pillar.merged({"hp": 4})), "OB06 hp 4")
	expect_rejected(LF.valid_with(13, pillar.merged({"hp": 5})), "IR-66", "OB06 hp 5")
	expect_rejected(LF.valid_with(13, pillar.merged({"hp": 0})), "IR-66", "OB06 hp 0")


func test_IR66_paper_screen_lantern_hp_and_colour() -> void:
	var lantern: Dictionary = {"type": "OB08", "x": 4, "y": 2}
	expect_valid(LF.valid_with(30, lantern.merged({"hp": 1, "color": "red"})), "OB08 hp 1")
	expect_valid(LF.valid_with(30, lantern.merged({"hp": 3, "color": "red"})), "OB08 hp 3")
	expect_rejected(LF.valid_with(30, lantern.merged({"hp": 0, "color": "red"})), "IR-66", "OB08 hp 0")
	expect_rejected(LF.valid_with(30, lantern.merged({"hp": 4, "color": "red"})), "IR-66", "OB08 hp 4")
	expect_rejected(LF.valid_with(30, lantern.merged({"hp": 2})), "IR-66", "OB08 without colour")
	expect_rejected(LF.valid_with(30, lantern.merged({"hp": 2, "color": "purple"})), "IR-66", "OB08 purple")


func test_IR66_paper_screen_colour_must_be_one_of_the_levels_colours() -> void:
	var three: Dictionary = {"tier": "intro", "colors": 3, "color_set": ["red", "yellow", "blue"]}
	var lantern: Dictionary = {"type": "OB08", "x": 4, "y": 2, "hp": 2}
	expect_rejected(LF.valid_with(28, lantern.merged({"color": "green"}), three), "IR-66", "green on a red/yellow/blue level")
	expect_valid(LF.valid_with(28, lantern.merged({"color": "yellow"}), three), "yellow on that level")


# ---------------------------------------------------------------- IR-67

func test_IR67_goo_from_level_28() -> void:
	var goo: Array = LF.with_char(LF.rows(9, 9, "."), 0, 8, "1")
	expect_rejected(LF.valid(27, {"underlay": goo}), "IR-67", "goo at 27")
	expect_valid(LF.valid(28, {"underlay": goo}), "goo at 28")


func test_IR67_drop_items_from_level_34() -> void:
	var spawn: Dictionary = {"drop_items": {"type": "OB11", "total": 1, "max_on_board": 1, "exit_columns": [2, 6]}, "generators": null}
	expect_rejected(LF.valid(33, {"spawn": spawn}), "IR-67", "OB11 at 33")
	expect_valid(LF.valid(34, {"spawn": spawn, "goals": [{"obstacle": "OB11", "count": 1}], "objects": []}), "OB11 at 34")


func test_IR67_frozen_idol_from_level_41() -> void:
	var idol: Dictionary = {"type": "OB12", "x": 5, "y": 5, "hp": 2}
	expect_rejected(LF.valid_with(40, idol), "IR-67", "OB12 at 40")
	expect_valid(LF.valid_with(41, idol), "OB12 at 41")


func test_IR67_no_nians_eye_and_dew_from_level_4() -> void:
	expect_rejected(LF.valid_with(46, {"type": "OB09", "x": 5, "y": 5, "hp": 1}), "IR-67", "OB09 object at 46")
	expect_rejected(LF.valid(46, {"goals": [{"obstacle": "OB09", "count": 1}]}), "IR-67", "OB09 goal at 46")
	expect_rejected(LF.valid(3, {"underlay": LF.with_char(LF.rows(9, 9, "."), 0, 8, "s")}), "IR-67", "dew at 3")
	expect_valid(LF.valid(4, {"underlay": LF.with_char(LF.rows(9, 9, "."), 0, 8, "s")}), "dew seed at 4")


func test_IR67_moss_from_level_7_creature_from_level_17() -> void:
	var moss: Dictionary = {"type": "OB03", "x": 5, "y": 7, "hp": 1}
	expect_rejected(LF.valid_with(6, moss), "IR-67", "moss at 6")
	expect_valid(LF.valid_with(7, moss), "moss at 7")
	var creature: Dictionary = {"type": "OB07", "x": 5, "y": 7, "hp": 1}
	expect_rejected(LF.valid_with(16, creature), "IR-67", "creature at 16")
	expect_rejected(LF.valid(16, {"goals": [{"obstacle": "OB07", "count": 1}]}), "IR-67", "OB07 goal at 16")
	expect_valid(LF.valid_with(17, creature), "creature at 17")
