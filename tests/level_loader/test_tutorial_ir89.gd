# Tests for IR-89 (the optional `tutorial` swap hint in a level file): validator cases and LevelLoader carrying
# the field to LevelAttempt.tutorial. Contract: tests/API_CONTRACT.md 11.1 and 11.4. Check: run the GUT suite.
extends "res://tests/level_loader/level_loader_test_base.gd"

const HINT: Dictionary = {"teach": "rocket", "hint_cells": [[3, 4], [4, 4]]}


func _lv(tutorial: Variant) -> Dictionary:
	return LF.valid(2, {"tutorial": tutorial})


func _with_hint(cells: Variant) -> Dictionary:
	return _lv({"teach": "rocket", "hint_cells": cells})


# ---------------------------------------------------------------- validator

func test_IR89_valid_hint_null_and_absent_are_accepted() -> void:
	expect_valid(_lv(HINT.duplicate(true)), "rocket hint on level 2")
	expect_valid(_lv(null), "tutorial null")
	expect_valid(LF.valid(2), "tutorial absent")


func test_IR89_teach_names() -> void:
	for t in ["firecracker", "crane", "orb"]:
		expect_valid(_lv({"teach": t, "hint_cells": [[3, 4], [4, 4]]}), "teach " + t)
	for bad in ["banana", "Rocket", ""]:
		expect_rejected(_lv({"teach": bad, "hint_cells": [[3, 4], [4, 4]]}), "IR-89", "teach '%s'" % bad)
	expect_rejected(_lv({"hint_cells": [[3, 4], [4, 4]]}), "IR-89", "missing teach")


func test_IR89_hint_cells_count_and_distinct() -> void:
	expect_rejected(_with_hint([[3, 4]]), "IR-89", "1 cell")
	expect_rejected(_with_hint([[3, 4], [4, 4], [5, 4]]), "IR-89", "3 cells")
	expect_rejected(_with_hint([]), "IR-89", "0 cells")
	expect_rejected(_lv({"teach": "rocket"}), "IR-89", "missing hint_cells")
	expect_rejected(_with_hint([[3, 4], [3, 4]]), "IR-89", "same cell twice")


func test_IR89_cells_must_be_orthogonal_neighbours() -> void:
	expect_rejected(_with_hint([[3, 4], [5, 4]]), "IR-89", "two apart")
	expect_rejected(_with_hint([[3, 4], [4, 5]]), "IR-89", "diagonal")
	expect_valid(_with_hint([[3, 4], [3, 5]]), "vertical neighbours")


func test_IR89_cells_must_be_playable_with_a_plain_piece() -> void:
	var dot: Array = LF.with_char(LF.rows(9, 9, "#"), 4, 4, ".")
	expect_rejected(LF.valid(2, {"cells": dot, "tutorial": HINT.duplicate(true)}), "IR-89", "hint on a . cell")
	# bramble cells of the level 2 fixture are (0..2, 6)
	expect_rejected(_with_hint([[1, 6], [1, 5]]), "IR-89", "hint on an OB02 bramble")
	# level 13 has only 2 goal slots (OB02, OB03), so add the pillar explicitly: it covers (7,0)..(7,2)
	var pillar: Dictionary = LF.valid_with(13, {"type": "OB06", "x": 7, "y": 0, "w": 1, "h": 3, "hp": 3},
			{"tutorial": {"teach": "rocket", "hint_cells": [[7, 3], [7, 2]]}})
	expect_rejected(pillar, "IR-89", "hint on an OB06 pillar cell (7,2)")
	var idol: Dictionary = LF.valid_with(2, {"type": "OB12", "x": 4, "y": 4, "hp": 2}, {"tutorial": HINT.duplicate(true)})
	expect_rejected(idol, "IR-89", "hint on an OB12 idol")


func test_IR89_cells_inside_the_board() -> void:
	expect_rejected(_with_hint([[9, 4], [8, 4]]), "IR-89", "x = 9")
	expect_rejected(_with_hint([[-1, 4], [0, 4]]), "IR-89", "x = -1")
	expect_rejected(_with_hint([[4, 9], [4, 8]]), "IR-89", "y = 9")


func test_IR89_wrong_types_are_rejected() -> void:
	expect_rejected(_lv("rocket"), "IR-89", "tutorial a string")
	expect_rejected(_lv([]), "IR-89", "tutorial an array")
	expect_rejected(_lv(3), "IR-89", "tutorial a number")
	expect_rejected(_lv({"teach": "rocket", "hint_cells": "3,4"}), "IR-89", "hint_cells a string")
	expect_rejected(_with_hint([3, 4]), "IR-89", "hint_cells [3,4], not a list of pairs")
	expect_rejected(_with_hint([[3], [4]]), "IR-89", "cells with one number")
	expect_rejected(_with_hint([["a", "b"], ["c", "d"]]), "IR-89", "cells with strings")


# ---------------------------------------------------------------- loader

func test_IR89_loader_carries_the_field_to_the_attempt_unchanged() -> void:
	var a: Variant = load_attempt(_lv(HINT.duplicate(true)), {"seed": 5})
	if a == null:
		return
	assert_eq(a.tutorial, HINT, "tutorial equals the file's field exactly")


func test_IR89_no_field_or_null_gives_an_empty_dictionary() -> void:
	var a: Variant = load_attempt(LF.valid(2), {"seed": 5})
	if a != null:
		assert_eq(a.tutorial, {}, "absent -> {}")
	var b: Variant = load_attempt(_lv(null), {"seed": 5})
	if b != null:
		assert_eq(b.tutorial, {}, "null -> {}")


func test_IR89_hint_changes_no_board_move_or_goal() -> void:
	var with_hint: Variant = load_attempt(_lv(HINT.duplicate(true)), {"seed": 9})
	var plain: Variant = load_attempt(LF.valid(2), {"seed": 9})
	if with_hint == null or plain == null:
		return
	assert_eq(with_hint.board.moves, 28, "moves 28")
	assert_eq(with_hint.board.moves, plain.board.moves)
	assert_eq(with_hint.level["goals"], plain.level["goals"], "same goals")
	for y in range(9):
		for x in range(9):
			assert_eq(with_hint.board.get_kind(x, y), plain.board.get_kind(x, y), "kind (%d,%d)" % [x, y])
			assert_eq(with_hint.board.get_color(x, y), plain.board.get_color(x, y), "colour (%d,%d)" % [x, y])


func test_IR89_a_different_legal_swap_costs_one_move_as_usual() -> void:
	var a: Variant = load_attempt(_lv(HINT.duplicate(true)), {"seed": 9})
	if a == null:
		return
	var swap: Array = LF.first_matching_swap(a.board)
	if swap.is_empty():
		pass_test("no matching swap on this seed")
		return
	MatchResolver.swap(a.board, swap[0], swap[1])
	assert_eq(a.board.moves, 27, "one move used")


func test_IR89_retry_carries_the_same_field() -> void:
	var a: Variant = load_attempt(_lv(HINT.duplicate(true)), {"seed": 5})
	if a == null:
		return
	var r: Variant = retry(a, {"seed": 6})
	if r != null:
		assert_eq(r.tutorial, HINT, "retry keeps the field")


# ---------------------------------------------------------------- IR-63 story_beat carried to the attempt

func test_IR63_loader_carries_story_beat_with_empty_string_for_null() -> void:
	var one: Variant = load_attempt(LF.valid(1), {"seed": 1})
	if one != null:
		assert_eq(one.story_beat, "intro", "level 1")
	var two: Variant = load_attempt(LF.valid(2), {"seed": 1})
	if two != null:
		assert_eq(two.story_beat, "", "level 2: null -> empty string")
	var hard: Variant = load_attempt(LF.valid(30), {"seed": 1})
	if hard != null:
		assert_eq(hard.story_beat, "mini", "level 30")
