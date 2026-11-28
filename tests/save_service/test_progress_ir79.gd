# GUT tests for IR-79: levels are played in order, a won level cannot be played again, nothing after 50.
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir79_new_save_only_level_1_can_start() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	assert_eq(int(s.next_level()), 1)
	assert_true(s.can_start(1))
	for lv in range(2, 51):
		assert_false(s.can_start(lv), "level %d cannot be started on a new save" % lv)
	assert_false(s.can_start(0))
	assert_false(s.can_start(51))
	assert_false(started(start(s, 2)), "starting level 2 is refused")


func test_ir79_win_moves_on_and_replay_or_skip_is_refused() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	win(s, 12)
	assert_eq(int(s.next_level()), 13)
	assert_false(started(start(s, 12)), "level 12 cannot be started again")
	assert_false(started(start(s, 14)), "level 14 cannot be skipped to")
	assert_true(s.can_start(13))
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.next_level()), 13)
	assert_eq((s2.attempt_log() as Array).size(), 1, "refused starts open no attempt and log nothing")


func test_ir79_fail_leaves_next_level_unchanged() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	lose(s, 12)
	assert_eq(int(s.next_level()), 12)
	assert_true(s.can_start(12), "retry allowed")


func test_ir79_quit_leaves_next_level_unchanged() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	quit_level(s, 12)
	assert_eq(int(s.next_level()), 12)


func test_ir79_after_level_50_no_level_can_start() -> void:
	var s: Variant = save_with({"next_level": 50, "fragments_rat": 7})
	if s == null:
		return
	win(s, 50)
	assert_eq(int(s.next_level()), 51, "nothing left to play")
	assert_false(s.can_start(50))
	assert_false(s.can_start(51))
	assert_false(started(start(s, 50)))
	assert_false(started(start(s, 51)))
