# GUT tests for IR-81 (lives part 1): at most 5, one lost per fail, real-time refill (open or closed game),
# clock moved back or forward, buying all 5. A fake clock is passed in; nothing waits.
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir81_new_save_has_5_lives() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	assert_eq(int(s.lives()), 5)


func test_ir81_fail_costs_a_life_and_win_after_continue_costs_none() -> void:
	var s: Variant = save_with({"next_level": 12, "coins": 1000})
	if s == null:
		return
	lose(s, 12)
	assert_eq(int(s.lives()), 4)
	var s2: Variant = save_with({"next_level": 12, "coins": 1000, "lives": 5})
	var d: Dictionary = start(s2, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s2.end_attempt("win", 0)
	assert_eq(int(s2.lives()), 5, "a win after one accepted continue costs no life")


func test_ir81_one_life_back_every_20_minutes_never_above_5() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	at(0)
	lose(s, 12)
	assert_eq(int(s.lives()), 4)
	at(19)
	assert_eq(int(s.lives()), 4, "T + 19 min")
	at(20)
	assert_eq(int(s.lives()), 5, "T + 20 min")
	at(180)
	assert_eq(int(s.lives()), 5, "T + 3 h: never above 5")


func test_ir81_second_fail_does_not_restart_countdown_closed_game() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	at(0)
	lose(s, 12)
	at(10)
	lose(s, 12)
	assert_eq(int(s.lives()), 3)
	at(11)
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.lives()), 3)
	at(50)
	var s3: Variant = reopen()
	if s3 == null:
		return
	assert_eq(int(s3.lives()), 5, "lives back at T + 20 and T + 40")


func test_ir81_three_fails_two_lives_back_after_50_minutes() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	at(0)
	lose(s, 12)
	at(1)
	lose(s, 12)
	at(2)
	lose(s, 12)
	assert_eq(int(s.lives()), 2)
	at(50)
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.lives()), 4, "back at T + 20 and T + 40")
	at(60)
	assert_eq(int(s2.lives()), 5)


func test_ir81_clock_set_back_gives_nothing_and_takes_nothing() -> void:
	var s: Variant = save_with({"lives": 4, "refill_started_at": T0})
	if s == null:
		return
	at(-60)
	assert_eq(int(s.lives()), 4, "clock T - 60 min")
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.lives()), 4, "still 4 after a close and reopen on the set-back clock")
	at(19)
	assert_eq(int(s2.lives()), 4)
	at(20)
	assert_eq(int(s2.lives()), 5)


func test_ir81_clock_set_back_never_takes_lives_away() -> void:
	var s: Variant = save_with({"lives": 3, "refill_started_at": T0})
	if s == null:
		return
	for m in [-60, -30, -1]:
		at(m)
		assert_eq(int(s.lives()), 3, "clock at %d min" % m)


func test_ir81_clock_moved_forward_gives_lives() -> void:
	var s: Variant = save_with({"lives": 4, "refill_started_at": T0})
	if s == null:
		return
	at(45)
	assert_eq(int(s.lives()), 5)


func test_ir81_buying_all_lives_restarts_countdown_from_the_next_loss() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 2, "coins": 300, "refill_started_at": T0})
	if s == null:
		return
	at(0)
	assert_true(_bought(s.buy_all_lives()), "bought")
	assert_eq(int(s.lives()), 5)
	assert_eq(int(s.coins()), 150)
	at(30)
	lose(s, 12)
	assert_eq(int(s.lives()), 4)
	at(49)
	assert_eq(int(s.lives()), 4, "not back before T + 50 min")
	at(50)
	assert_eq(int(s.lives()), 5)
