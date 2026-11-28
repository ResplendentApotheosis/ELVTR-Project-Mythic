# Checks the test fixtures themselves (not LevelLoader): every LF.valid(id) level for 1-50 has a goal list
# GoalTracker.goal_errors accepts, the right row sizes and no overlapping objects. Passes today.
# Check: run the GUT suite; this file must be green before the validator tests mean anything.
extends GutTest

const LF := preload("res://tests/level_loader/level_fixtures.gd")


func test_fixture_goal_lists_pass_goal_errors_for_levels_1_to_50() -> void:
	for id in range(1, 51):
		var d: Dictionary = LF.valid(id)
		var errs: Array = GoalTracker.goal_errors(id, String(d["tier"]), d["goals"])
		assert_eq(errs, [], "level %d goal list" % id)


func test_fixture_objects_do_not_overlap_and_stay_on_the_board() -> void:
	for id in [1, 12, 25, 26, 30, 50]:
		var d: Dictionary = LF.valid(id)
		var seen: Dictionary = {}
		for o in d["objects"]:
			for dx in range(int(o.get("w", 1))):
				for dy in range(int(o.get("h", 1))):
					var c: Vector2i = Vector2i(int(o["x"]) + dx, int(o["y"]) + dy)
					assert_false(seen.has(c), "level %d: two objects on %s" % [id, c])
					assert_true(c.x < 9 and c.y < 9, "level %d: object off the board" % id)
					seen[c] = true


func test_fixture_plan_rows_are_read() -> void:
	assert_eq(int(LF.plan(26)["moves"]), 24)
	assert_eq(String(LF.plan(25)["tier"]), "finale")
	assert_eq(String(LF.plan(30)["tier"]), "hard")
	assert_eq(String(LF.plan(28)["tier"]), "intro")
