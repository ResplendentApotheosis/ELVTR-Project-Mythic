# LevelLoader tests for how a level file marks the fragment (IR-31, IR-70, OQ-71) and how a failed fragment level
# is rebuilt for the retry (IR-58). Banking fragments.rat on a win is SaveService work (not built): not tested here.
# Contract: tests/API_CONTRACT.md section 11. Check: run the GUT suite; the names carry the IR id.
extends "res://tests/level_loader/level_loader_test_base.gd"


func _free_fragment_event(carrier: String) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new("collected")
	e.data = {"item": "fragment", "carrier": carrier}
	return e


func _fail_attempt(a: Variant) -> void:
	a.board.moves = 0
	a.tracker.moves_ran_out(a.board)
	a.tracker.decline_offer()


func _level_38_with_item() -> Dictionary:
	var objects: Array = []
	for x in range(3):
		objects.append({"type": "OB02", "x": x, "y": 6, "hp": 1})
	return LF.valid(38, {
		"objects": objects,
		"goals": [{"obstacle": "OB02", "count": 3}, {"obstacle": "OB11", "count": 1, "fragment": true}],
		"spawn": {"drop_items": {"type": "OB11", "total": 3, "max_on_board": 1, "exit_columns": [2, 6], "fragment_item": 2}, "generators": null}})


func test_IR31_loader_marks_the_fragment_in_the_cocoon_whose_entry_has_fragment_true() -> void:
	var a: Variant = load_attempt(LF.level(26, {"objects": [
		{"type": "OB07", "x": 2, "y": 2, "hp": 1},
		{"type": "OB07", "x": 4, "y": 4, "hp": 1, "fragment": true},
		{"type": "OB07", "x": 6, "y": 6, "hp": 1}]}), {"seed": 1})
	if a == null:
		return
	assert_true(a.board.get_content(4, 4).fragment, "the cocoon at (4,4) holds the fragment")
	assert_false(a.board.get_content(2, 2).fragment, "(2,2) holds none")
	assert_false(a.board.get_content(6, 6).fragment, "(6,6) holds none")


func test_IR70_fragment_field_makes_a_rat_fragment_level() -> void:
	var a: Variant = load_attempt(LF.valid(26), {"seed": 1})
	var plain: Variant = load_attempt(LF.valid(27), {"seed": 1})
	if a == null or plain == null:
		return
	assert_eq(a.fragment_guardian, "rat")
	assert_eq(plain.fragment_guardian, "", "level 27 carries no fragment")


func test_IR58_retry_level_26_puts_the_fragment_back_in_the_marked_cocoon() -> void:
	var a: Variant = load_attempt(LF.valid(26), {"seed": 1})
	if a == null:
		return
	assert_true(a.board.get_content(8, 8).fragment, "the marked cocoon is at (8,8) in the fixture")
	a.board.remove_content(a.board.get_content(8, 8))
	a.tracker.observe(_free_fragment_event("OB07"))
	assert_true(a.tracker.is_goal_done(0), "fragment goal done in attempt 1")
	_fail_attempt(a)
	var r: Variant = retry(a)
	if r == null:
		return
	assert_eq(r.board.content_id(8, 8), "OB07", "cocoon back")
	assert_true(r.board.get_content(8, 8).fragment, "with the fragment inside")
	assert_false(r.tracker.is_goal_done(0), "fragment goal not done")
	assert_false(r.tracker.is_won())
	assert_eq(r.fragment_guardian, "rat")


func test_IR58_retry_level_38_counts_drop_items_again_from_1() -> void:
	var a: Variant = load_attempt(_level_38_with_item(), {"seed": 1})
	if a == null:
		return
	assert_eq(vget(a.board, "drop_spawned"), 1, "item 1 at the start")
	a.board.set("drop_spawned", 2)           # the 2nd item (the fragment) entered during play
	a.tracker.observe(_free_fragment_event("OB11"))
	assert_true(a.tracker.is_goal_done(1), "fragment goal done in attempt 1")
	a.board.set("drop_spawned", 3)
	_fail_attempt(a)
	var r: Variant = retry(a)
	if r == null:
		return
	assert_eq(vget(r.board, "drop_spawned"), 1, "the spawn count starts again from 1")
	assert_eq(vget(r.board, "drop_fragment_item"), 2, "the 2nd item spawned carries the fragment again")
	assert_eq(LF.drops(r.board, "OB11").size(), 1)
	assert_eq(LF.drops(r.board, "fragment").size(), 0)
	assert_false(r.tracker.is_goal_done(1), "fragment goal not done")
