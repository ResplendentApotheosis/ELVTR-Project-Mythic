# GUT tests for IR-83 (and IR-77's hand-off): pre-level boosters unlock when level 16 is first started, 1 free of each,
# then 150 coins, paid when the attempt starts, one of the two per attempt. start_attempt returns the
# `pre_specials` names for LevelLoader. API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"

const LF := preload("res://tests/level_loader/level_fixtures.gd")


func _pre_state(next_level: int, coins: int, rc: int = 1, fc: int = 1) -> Dictionary:
	return {"next_level": next_level, "coins": coins, "pre_unlocked": true,
		"pre_free": {"rocket_crane": rc, "firecracker": fc}}


func test_ir83_not_available_before_level_16_is_started() -> void:
	var s: Variant = save_with({"next_level": 15, "coins": 1000})
	if s == null:
		return
	assert_false(s.pre_boosters_unlocked())
	assert_false(started(start(s, 15, ["firecracker"])), "no pre-level booster on level 15")
	assert_false(started(start(s, 15, ["rocket_crane"])))
	assert_eq(int(s.coins()), 1000)


func test_ir83_level_16_first_attempt_can_choose_rocket_crane_free() -> void:
	var s: Variant = save_with({"next_level": 16, "coins": 500})
	if s == null:
		return
	var d: Dictionary = start(s, 16, ["rocket_crane"])
	assert_true(started(d), "unlocked by this very start")
	assert_true(s.pre_boosters_unlocked())
	assert_eq(pre_specials_of(d), ["rocket", "crane"])
	assert_eq(int(s.coins()), 500, "first one is free")
	assert_eq(int(s.pre_free_uses("rocket_crane")), 0)
	assert_eq(int(s.pre_free_uses("firecracker")), 1)


func test_ir83_level_16_first_attempt_can_choose_firecracker_free() -> void:
	var s: Variant = save_with({"next_level": 16, "coins": 500})
	if s == null:
		return
	var d: Dictionary = start(s, 16, ["firecracker"])
	assert_true(started(d))
	assert_eq(pre_specials_of(d), ["firecracker"])
	assert_eq(int(s.coins()), 500)


func test_ir83_second_rocket_crane_costs_150() -> void:
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	var d1: Dictionary = start(s, 18, ["rocket_crane"])
	assert_true(started(d1))
	assert_eq(int(s.coins()), 500, "free")
	s.end_attempt("fail")
	var d2: Dictionary = start(s, 18, ["rocket_crane"])
	assert_true(started(d2))
	assert_eq(int(s.coins()), 350)
	assert_eq(int(d2.tracker.coins), 350, "the tracker starts with the paid-down coins")


func test_ir83_first_firecracker_free_after_rocket_crane_used() -> void:
	var s: Variant = save_with(_pre_state(18, 500, 0, 1))
	if s == null:
		return
	assert_true(started(start(s, 18, ["firecracker"])))
	assert_eq(int(s.coins()), 500)


func test_ir83_both_for_one_attempt_refused() -> void:
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	assert_false(started(start(s, 18, ["rocket_crane", "firecracker"])), "only one can be chosen")
	assert_eq(int(s.coins()), 500)
	assert_eq(int(s.pre_free_uses("rocket_crane")), 1, "nothing spent")
	assert_eq(int(s.pre_free_uses("firecracker")), 1)
	assert_true(started(start(s, 18)), "no attempt was left open: a plain start works")


func test_ir83_retry_needs_another_use_retry_with_nothing_is_free() -> void:
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	assert_true(started(start(s, 18, ["firecracker"])))
	assert_eq(int(s.coins()), 500)
	s.end_attempt("fail")
	var d2: Dictionary = start(s, 18, ["firecracker"])
	assert_true(started(d2))
	assert_eq(int(s.coins()), 350, "retry with a Firecracker pays 150")
	s.end_attempt("fail")
	var d3: Dictionary = start(s, 18)
	assert_true(started(d3))
	assert_eq(int(s.coins()), 350, "retry with nothing: coins unchanged")
	assert_eq(pre_specials_of(d3), [], "no Firecracker on the board")


func test_ir83_spent_even_if_the_attempt_is_killed() -> void:
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	assert_true(started(start(s, 18, ["firecracker"])))
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.pre_free_uses("firecracker")), 0, "stays spent")
	assert_eq(int(s2.coins()), 500)


func test_ir83_unknown_pre_booster_name_refused() -> void:
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	assert_false(started(start(s, 18, ["banana"])))
	assert_eq(int(s.coins()), 500)


func test_ir83_pre_specials_names_load_in_level_loader() -> void:
	# IR-77 hand-off: the names SaveService returns are the ones LevelLoader accepts
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	var d: Dictionary = start(s, 18, ["rocket_crane"])
	assert_true(started(d))
	var loader: Variant = load("res://src/game/level_loader.gd")
	var attempt: Variant = loader.load_level(LF.valid(18), {"seed": 1234, "pre_specials": pre_specials_of(d)})
	assert_not_null(attempt, "LevelLoader accepts the pre_specials from SaveService; errors: %s" % [loader.last_errors])


func test_ir83_pre_booster_on_a_chest_board_is_allowed_firecracker_first_then_chest() -> void:
	var st: Dictionary = _pre_state(22, 500)
	st["streak"] = 0
	st["chest_waiting"] = true
	var s: Variant = save_with(st)
	if s == null:
		return
	var d: Dictionary = start(s, 22, ["firecracker"])
	assert_true(started(d), "allowed on the chest board")
	assert_eq(pre_specials_of(d), ["firecracker", "rocket", "crane"], "booster's special first, then the chest's")
	assert_eq(int(s.pre_free_uses("firecracker")), 0, "the free Firecracker was used")
	assert_eq(int(s.coins()), 500, "free use, the chest costs nothing")
	assert_false(s.chest_waiting(), "chest used up")


func test_ir83_rocket_crane_on_a_chest_board_gives_four_specials_booster_first() -> void:
	var st: Dictionary = _pre_state(22, 500, 0, 1)
	st["chest_waiting"] = true
	var s: Variant = save_with(st)
	if s == null:
		return
	var d: Dictionary = start(s, 22, ["rocket_crane"])
	assert_true(started(d))
	assert_eq(pre_specials_of(d), ["rocket", "crane", "rocket", "crane"])
	assert_eq(int(s.coins()), 350, "only the booster is paid (no free use left); the chest is free")
