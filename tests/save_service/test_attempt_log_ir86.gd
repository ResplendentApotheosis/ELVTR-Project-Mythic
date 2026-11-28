# GUT tests for IR-86: every attempt is logged (level, won, quit, first try); lives running out and lives bought
# are logged too; a continue adds no entry. Log entry: {"level", "won", "quit", "first_try"} (API_CONTRACT 12.5).
# Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func _entry(level: int, won: bool, quit: bool, first_try: bool) -> Dictionary:
	return {"level": level, "won": won, "quit": quit, "first_try": first_try}


func _same(entry: Variant, expected: Dictionary, label: String) -> void:
	assert_true(entry is Dictionary, label + ": an entry exists")
	if not (entry is Dictionary):
		return
	for k in expected:
		assert_eq(entry.get(k), expected[k], "%s: %s" % [label, k])


func test_ir86_quit_then_retry_win_two_entries() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	quit_level(s, 12)
	var entries: Array = s.attempt_log()
	assert_eq(entries.size(), 1)
	_same(entries[0], _entry(12, false, true, true), "quit")
	win(s, 12)
	entries = s.attempt_log()
	assert_eq(entries.size(), 2)
	_same(entries[1], _entry(12, true, false, false), "retry win")


func test_ir86_finale_first_attempt_declined_offer() -> void:
	var s: Variant = save_with({"next_level": 25})
	if s == null:
		return
	var d: Dictionary = start(s, 25)
	run_out(d.tracker, BB.blank())
	d.tracker.decline_offer()
	s.end_attempt("fail")
	var entries: Array = s.attempt_log()
	assert_eq(entries.size(), 1)
	_same(entries[0], _entry(25, false, false, true), "level 25 fail")


func test_ir86_continue_then_win_is_one_entry_first_try() -> void:
	var s: Variant = save_with({"next_level": 30, "coins": 1000, "fragments_rat": 2})
	if s == null:
		return
	var d: Dictionary = start(s, 30)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	assert_eq((s.attempt_log() as Array).size(), 0, "a continue adds no entry while the attempt runs")
	s.end_attempt("win", 0)
	var entries: Array = s.attempt_log()
	assert_eq(entries.size(), 1)
	_same(entries[0], _entry(30, true, false, true), "level 30 win")


func test_ir86_lives_ran_out_and_lives_bought_are_logged() -> void:
	var s: Variant = save_with({"next_level": 14, "lives": 1})
	if s == null:
		return
	lose(s, 14)
	assert_eq(int(s.lives()), 0)
	assert_true((s.life_log() as Array).has("lives_ran_out"), "lives running out is logged")
	s.debug_set({"coins": 150})
	assert_true(_bought(s.buy_all_lives()), "bought")
	assert_eq(s.life_log(), ["lives_ran_out", "lives_bought"])


func test_ir86_a_fail_that_leaves_lives_above_0_logs_no_lives_ran_out() -> void:
	var s: Variant = save_with({"next_level": 14, "lives": 2})
	if s == null:
		return
	lose(s, 14)
	assert_eq(s.life_log(), [])


func test_ir86_killed_app_logged_on_next_launch_then_retry_win() -> void:
	var s: Variant = save_with({"next_level": 17})
	if s == null:
		return
	assert_true(started(start(s, 17)))
	var s2: Variant = reopen()
	if s2 == null:
		return
	var entries: Array = s2.attempt_log()
	assert_eq(entries.size(), 1)
	_same(entries[0], _entry(17, false, true, true), "killed attempt")
	win(s2, 17)
	entries = s2.attempt_log()
	assert_eq(entries.size(), 2)
	_same(entries[1], _entry(17, true, false, false), "retry win")


func test_ir86_log_is_kept_after_close_and_reopen_in_order() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	lose(s, 12)
	win(s, 12)
	win(s, 13)
	var s2: Variant = reopen()
	if s2 == null:
		return
	var entries: Array = s2.attempt_log()
	assert_eq(entries.size(), 3)
	_same(entries[0], _entry(12, false, false, true), "first")
	_same(entries[1], _entry(12, true, false, false), "second")
	_same(entries[2], _entry(13, true, false, true), "third")
