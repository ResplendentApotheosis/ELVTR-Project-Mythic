# Validator tests (LevelLoader.validate) for moves and colours (IR-68), pre-made matches (IR-69), the fragment field
# (IR-70, IR-31), shrine needs (IR-73), fixed tiles (IR-76) and the goal checks it reuses (IR-59, IR-61, IR-31).
# Contract: tests/API_CONTRACT.md 11.4 (each error starts with its IR id). Check: run the GUT suite.
extends "res://tests/level_loader/level_loader_test_base.gd"

const THREE: Dictionary = {"tier": "intro", "colors": 3, "color_set": ["red", "yellow", "blue"]}


# ---------------------------------------------------------------- IR-68

func test_IR68_moves_must_be_within_2_of_the_plan_and_at_least_16() -> void:
	expect_valid(LF.valid(26, {"moves": 26}), "plan 24, moves 26")
	expect_valid(LF.valid(26, {"moves": 22}), "plan 24, moves 22")
	expect_rejected(LF.valid(26, {"moves": 27}), "IR-68", "27 is 3 above the plan")
	expect_rejected(LF.valid(26, {"moves": 21}), "IR-68", "21 is 3 below the plan")
	expect_rejected(LF.valid(26, {"moves": 15}), "IR-68", "15 is under 16")


func test_IR68_three_colours_only_on_intro_levels_and_never_5_or_2() -> void:
	expect_rejected(LF.valid(26, {"colors": 3, "color_set": ["red", "yellow", "blue"]}), "IR-68", "easy level, 3 colours")
	expect_valid(LF.valid(28, THREE), "intro level, 3 colours")
	expect_rejected(LF.valid(28, {"colors": 5}), "IR-68", "5 colours")
	expect_rejected(LF.valid(28, {"colors": 2}), "IR-68", "2 colours")
	expect_rejected(LF.valid(12, {"colors": 5}), "IR-68", "5 colours on a medium level")
	expect_rejected(LF.valid(12, {"colors": 2}), "IR-68", "2 colours on a medium level")


func test_IR68_color_set_rules() -> void:
	expect_rejected(LF.valid(28, {"tier": "intro", "colors": 3}), "IR-68", "3 colours, no color_set")
	expect_rejected(LF.valid(28, {"tier": "intro", "colors": 3, "color_set": ["red", "red", "blue"]}), "IR-68", "duplicate colour")
	expect_rejected(LF.valid(28, {"tier": "intro", "colors": 3, "color_set": ["red", "yellow"]}), "IR-68", "only two colours")
	expect_rejected(LF.valid(28, {"tier": "intro", "colors": 3, "color_set": ["red", "yellow", "purple"]}), "IR-68", "purple")
	expect_rejected(LF.valid(28, {"colors": 4, "color_set": ["red", "yellow", "blue", "green"]}), "IR-68", "color_set on a 4-colour level")
	expect_valid(LF.valid(28, {"colors": 4}), "4 colours, no color_set")


# ---------------------------------------------------------------- IR-69

func test_IR69_fixed_tiles_that_make_a_match_are_rejected() -> void:
	var tiles: Array = [{"x": 0, "y": 0, "tile": "red"}, {"x": 1, "y": 0, "tile": "red"}, {"x": 2, "y": 0, "tile": "red"}]
	expect_rejected(LF.valid(12, {"fixed_tiles": tiles}), "IR-69", "three red in a row")
	expect_valid(LF.valid(12, {"fixed_tiles": [tiles[0], tiles[1]]}), "two red in a row")


# ---------------------------------------------------------------- IR-70 and IR-31

func test_IR70_fragment_field_only_on_the_fragment_levels() -> void:
	var field: Dictionary = {"guardian": "rat", "scripted": true}
	expect_rejected(LF.valid(27, {"fragment": field}), "IR-70", "level 27 with a fragment field")
	var no_field: Dictionary = LF.valid(30)
	no_field.erase("fragment")
	expect_rejected(no_field, "IR-70", "level 30 without the field")


func test_IR70_field_and_fragment_goal_go_together() -> void:
	var bramble_only: Dictionary = LF.valid(26, {"goals": [{"obstacle": "OB02", "count": 3}],
		"objects": [{"type": "OB02", "x": 0, "y": 6, "hp": 1}, {"type": "OB02", "x": 1, "y": 6, "hp": 1}, {"type": "OB02", "x": 2, "y": 6, "hp": 1}]})
	expect_rejected(bramble_only, ["IR-70", "IR-31", "goals"], "level 26: field but no fragment goal")
	var no_field: Dictionary = LF.valid(26)
	no_field.erase("fragment")
	expect_rejected(no_field, "IR-70", "level 26: fragment goal but no field")


func test_IR70_fragment_rides_a_drop_item_only_from_level_38() -> void:
	var goals: Array = [{"obstacle": "OB02", "count": 3}, {"obstacle": "OB11", "count": 1, "fragment": true}]
	var spawn: Dictionary = {"drop_items": {"type": "OB11", "total": 3, "max_on_board": 1, "exit_columns": [2, 6], "fragment_item": 2}, "generators": null}
	var brambles: Array = [{"type": "OB02", "x": 0, "y": 6, "hp": 1}, {"type": "OB02", "x": 1, "y": 6, "hp": 1}, {"type": "OB02", "x": 2, "y": 6, "hp": 1}]
	var on_item_35: Dictionary = LF.valid(35, {"goals": [{"obstacle": "OB02", "count": 3}, {"obstacle": "OB03", "count": 1},
		{"obstacle": "OB11", "count": 1, "fragment": true}], "spawn": spawn,
		"objects": brambles + [{"type": "OB03", "x": 4, "y": 4, "hp": 1}]})
	expect_rejected(on_item_35, "IR-70", "level 35: fragment on a drop item")
	expect_valid(LF.valid(38, {"goals": goals, "spawn": spawn, "objects": brambles}), "level 38: fragment_item 2")
	expect_valid(LF.valid(38), "level 38: fragment in a marked cocoon")


func test_IR31_validator_fragment_in_cocoon_counts() -> void:
	# fragment goal OB07 count 1 and plain OB07 count 3: three OB07 entries, one marked
	var objects: Array = [{"type": "OB07", "x": 2, "y": 2, "hp": 1}, {"type": "OB07", "x": 4, "y": 4, "hp": 1, "fragment": true},
		{"type": "OB07", "x": 6, "y": 6, "hp": 1}]
	var goals3: Array = [{"obstacle": "OB07", "count": 1, "fragment": true}, {"obstacle": "OB07", "count": 3}]
	expect_valid(LF.valid(33, {"goals": goals3, "objects": objects}), "plain count includes the fragment's cocoon")
	var goals2: Array = [{"obstacle": "OB07", "count": 1, "fragment": true}, {"obstacle": "OB07", "count": 2}]
	expect_any_error(LF.valid(33, {"goals": goals2, "objects": objects}), "plain count 2 leaves out the fragment cocoon")
	var unmarked: Array = [{"type": "OB07", "x": 2, "y": 2, "hp": 1}, {"type": "OB07", "x": 4, "y": 4, "hp": 1}]
	expect_any_error(LF.valid(33, {"goals": [{"obstacle": "OB07", "count": 1, "fragment": true}, {"obstacle": "OB07", "count": 2}], "objects": unmarked}), "no marked cocoon")
	var two_marked: Array = [{"type": "OB07", "x": 2, "y": 2, "hp": 1, "fragment": true}, {"type": "OB07", "x": 4, "y": 4, "hp": 1, "fragment": true}]
	expect_any_error(LF.valid(33, {"goals": [{"obstacle": "OB07", "count": 1, "fragment": true}, {"obstacle": "OB07", "count": 2}], "objects": two_marked}), "two marked cocoons")


func test_IR31_validator_fragment_item_bounds_and_plain_count() -> void:
	var di: Dictionary = {"type": "OB11", "total": 3, "max_on_board": 1, "exit_columns": [2, 6], "fragment_item": 2}
	var goals3: Array = [{"obstacle": "OB11", "count": 1, "fragment": true}, {"obstacle": "OB11", "count": 3}]
	expect_valid(LF.valid(38, {"goals": goals3, "objects": [], "spawn": {"drop_items": di, "generators": null}}), "plain OB11 3 includes the fragment item")
	var goals2: Array = [{"obstacle": "OB11", "count": 1, "fragment": true}, {"obstacle": "OB11", "count": 2}]
	expect_any_error(LF.valid(38, {"goals": goals2, "objects": [], "spawn": {"drop_items": di, "generators": null}}), "plain OB11 count 2")
	var no_item: Dictionary = di.duplicate()
	no_item.erase("fragment_item")
	expect_any_error(LF.valid(38, {"goals": goals3, "objects": [], "spawn": {"drop_items": no_item, "generators": null}}), "no fragment_item")
	var too_big: Dictionary = di.merged({"fragment_item": 4}, true)
	expect_any_error(LF.valid(38, {"goals": goals3, "objects": [], "spawn": {"drop_items": too_big, "generators": null}}), "fragment_item 4 of total 3")


# ---------------------------------------------------------------- IR-73

func test_IR73_shrine_needs_colours_and_counts() -> void:
	var shrine: Dictionary = {"type": "OB05", "x": 1, "y": 1, "w": 2, "h": 2, "hp": 3}
	expect_valid(LF.valid_with(12, shrine.merged({"needs": {"red": 2, "blue": 1}})), "valid needs on a 4-colour level")
	expect_rejected(LF.valid_with(12, shrine.merged({"needs": {"purple": 1}})), "IR-73", "needs purple")
	expect_rejected(LF.valid_with(12, shrine), "IR-73", "no needs")
	expect_rejected(LF.valid_with(12, shrine.merged({"needs": {}})), "IR-73", "empty needs")
	expect_rejected(LF.valid_with(12, shrine.merged({"needs": {"red": 2, "blue": 0}})), "IR-73", "a count of 0")


func test_IR73_needs_must_be_among_the_levels_colours() -> void:
	var shrine: Dictionary = {"type": "OB05", "x": 1, "y": 1, "w": 2, "h": 2, "hp": 3}
	expect_rejected(LF.valid_with(28, shrine.merged({"needs": {"green": 1}}), THREE), "IR-73", "green on a red/yellow/blue level")
	expect_valid(LF.valid_with(28, shrine.merged({"needs": {"yellow": 2}}), THREE), "yellow is allowed there")


# ---------------------------------------------------------------- IR-76

func _tile_level(tile: Dictionary, overrides: Dictionary = {}) -> Dictionary:
	var o: Dictionary = {"fixed_tiles": [tile]}
	for k in overrides:
		o[k] = overrides[k]
	return LF.valid(12, o)


func test_IR76_valid_tiles() -> void:
	expect_valid(_tile_level({"x": 4, "y": 8, "tile": "line_h"}), "line_h")
	expect_valid(_tile_level({"x": 4, "y": 8, "tile": "line_v", "color": "blue"}), "line_v blue")
	expect_valid(_tile_level({"x": 2, "y": 2, "tile": "orb"}), "orb without colour")
	expect_valid(_tile_level({"x": 4, "y": 4, "tile": "crane"}), "crane under moss (4,4)")


func test_IR76_bad_name_cell_and_colour_are_rejected() -> void:
	expect_rejected(_tile_level({"x": 4, "y": 8, "tile": "rocket"}), "IR-76", "tile 'rocket'")
	expect_rejected(_tile_level({"x": 0, "y": 6, "tile": "red"}), "IR-76", "on a bramble cell")
	expect_rejected(_tile_level({"x": 0, "y": 8, "tile": "red"}, {"cells": LF.with_char(LF.rows(9, 9, "#"), 0, 8, ".")}), "IR-76", "on a . cell")
	expect_rejected(_tile_level({"x": 4, "y": 8, "tile": "line_h", "color": "purple"}), "IR-76", "colour purple")
	expect_rejected(LF.valid(28, THREE.merged({"fixed_tiles": [{"x": 4, "y": 8, "tile": "green"}]})), "IR-76", "green on a 3-colour level")


func test_IR76_orb_has_no_colour() -> void:
	expect_rejected(_tile_level({"x": 2, "y": 2, "tile": "orb", "color": "red"}), "IR-76", "orb with a colour")


# ---------------------------------------------------------------- goal checks the validator reuses

func test_IR59_validator_counts_goals_by_tier() -> void:
	var two: Array = [{"obstacle": "OB02", "count": 3}, {"obstacle": "OB03", "count": 2}]
	expect_any_error(LF.valid(28, {"goals": two}), "an intro level with 2 goals")
	expect_any_error(LF.valid(12, {"goals": [two[0]]}), "a medium level with 1 goal")


func test_IR61_validator_goal_count_must_equal_the_obstacles_placed() -> void:
	expect_any_error(LF.valid(12, {"goals": [{"obstacle": "OB02", "count": 4}, {"obstacle": "OB03", "count": 2}]}), "4 brambles wanted, 3 placed")
	expect_any_error(LF.valid(12, {"goals": [{"obstacle": "OB02", "count": 3}, {"obstacle": "OB03", "count": 2, "color": "red"}]}), "a colour goal")


func test_IR31_validator_fragment_level_needs_a_fragment_goal_inside_the_tier_count() -> void:
	var goals: Array = [{"obstacle": "OB02", "count": 3}, {"obstacle": "OB03", "count": 2}]
	expect_any_error(LF.valid(35, {"goals": goals}), "level 35 without a fragment goal")
	var five: Array = goals + [{"obstacle": "OB06", "count": 1}, {"obstacle": "OB07", "count": 1, "fragment": true}, {"obstacle": "OB07", "count": 1}]
	expect_any_error(LF.valid(35, {"goals": five}), "5 goals on a hard level")


# ---------------------------------------------------------------- IR-75 (starting drop item columns)

## Level 36 (easy, 1 goal): OB11 goal 3, total 3, max_on_board 2. Row 0 holds a bramble in every column except
## the ones in `open_cols`; `tiles` are fixed tiles.
func _drop_row_level(open_cols: Array, tiles: Array = []) -> Dictionary:
	var objects: Array = []
	for x in range(9):
		if not open_cols.has(x):
			objects.append({"type": "OB02", "x": x, "y": 0, "hp": 1})
	return LF.valid(36, {"goals": [{"obstacle": "OB11", "count": 3}], "objects": objects, "fixed_tiles": tiles,
		"spawn": {"drop_items": {"type": "OB11", "total": 3, "max_on_board": 2}, "generators": null}})


func test_IR75_validator_rejects_one_eligible_column_for_two_starting_items() -> void:
	expect_rejected(_drop_row_level([4]), "IR-75", "only column 4 is eligible, max_on_board 2")


func test_IR75_validator_accepts_two_eligible_columns() -> void:
	expect_valid(_drop_row_level([4, 6]), "columns 4 and 6 are eligible")


func test_IR75_validator_rejects_when_a_fixed_tile_takes_the_second_column() -> void:
	expect_rejected(_drop_row_level([4, 6], [{"x": 6, "y": 0, "tile": "red"}]), "IR-75", "(6,0) holds a fixed tile, so only column 4 is eligible")
