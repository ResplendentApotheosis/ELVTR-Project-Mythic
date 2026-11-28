# GUT tests for IR-81 (lives part 2) and IR-60: no start or retry at 0 lives except finales 25 and 50, the retry
# screen at 0 lives, and the 10 minutes of unlimited lives after winning a finale (real time, closed game too).
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir81_zero_lives_refuses_a_normal_level_and_retry_screen_offers_wait_or_buy() -> void:
	var s: Variant = save_with({"next_level": 14, "lives": 0})
	if s == null:
		return
	assert_false(s.can_start(14))
	assert_false(started(start(s, 14)), "starting level 14 with 0 lives is refused")
	var choices: Array = s.retry_choices(14)
	assert_true(choices.has("wait"), "the retry screen offers waiting")
	assert_true(choices.has("buy_lives"), "the retry screen offers buying all 5")
	assert_false(choices.has("retry"), "but no retry")


func test_ir81_zero_lives_finale_25_can_start_and_retry() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 0})
	if s == null:
		return
	assert_true(s.can_start(25))
	lose(s, 25)
	assert_eq(int(s.lives()), 0)
	assert_true(s.can_start(25), "retry allowed at 0 lives on a finale")
	assert_true(s.retry_choices(25).has("retry"))


func test_ir81_zero_lives_finale_50_can_start() -> void:
	var s: Variant = save_with({"next_level": 50, "lives": 0, "fragments_rat": 7})
	if s == null:
		return
	assert_true(s.can_start(50))


func test_ir81_unlimited_lives_after_finale_win_then_run_out_then_refill() -> void:
	# lives 1, countdown last restarted at T - 5 min (next life at T + 15 min)
	var s: Variant = save_with({"next_level": 25, "lives": 1, "refill_started_at": T0 - 5 * 60})
	if s == null:
		return
	at(0)
	win(s, 25)
	assert_true(s.unlimited_lives_active(), "10 minutes of unlimited lives from the win")
	at(5)
	lose(s, 26)
	assert_eq(int(s.lives()), 1, "fail during unlimited lives costs no life")
	at(8)
	lose(s, 26)
	assert_eq(int(s.lives()), 1)
	at(11)
	assert_false(s.unlimited_lives_active(), "over at T + 10 min")
	lose(s, 26)
	assert_eq(int(s.lives()), 0)
	at(12)
	assert_false(s.can_start(26), "0 lives, unlimited over, level 26 is not a finale")
	assert_false(started(start(s, 26)))
	at(15)
	assert_eq(int(s.lives()), 0, "T + 15 min: the countdown running at T was dropped, no life yet")
	assert_false(s.can_start(26), "retry still refused")
	at(29)
	assert_eq(int(s.lives()), 0, "a fresh countdown started at T + 10 min, the loss at T + 11 did not restart it")
	at(30)
	assert_eq(int(s.lives()), 1, "T + 30 min")
	assert_true(s.can_start(26), "retry allowed")


func test_ir81_unlimited_lives_count_real_time_with_the_game_closed() -> void:
	# lives 0, countdown last restarted at T - 1 min (next life at T + 19 min)
	var s: Variant = save_with({"next_level": 25, "lives": 0, "refill_started_at": T0 - 60})
	if s == null:
		return
	at(0)
	win(s, 25)
	at(1)
	var s2: Variant = reopen()
	if s2 == null:
		return
	at(6)
	var s3: Variant = reopen()
	if s3 == null:
		return
	assert_true(s3.unlimited_lives_active())
	assert_true(s3.can_start(26), "level 26 can be started at 0 lives until T + 10 min")
	at(12)
	var s4: Variant = reopen()
	if s4 == null:
		return
	assert_false(s4.unlimited_lives_active())
	assert_false(s4.can_start(26), "opened at T + 12 min: refused")
	assert_eq(int(s4.lives()), 0, "lives 0 until T + 30 min (fresh countdown from T + 10 min)")
	at(29)
	assert_eq(int(s4.lives()), 0, "T + 29 min")
	at(30)
	assert_eq(int(s4.lives()), 1, "T + 30 min")


func test_ir81_failed_finale_gives_no_unlimited_lives_won_one_later_does() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 3, "refill_started_at": T0 - 60})
	if s == null:
		return
	at(0)
	lose(s, 25)
	assert_false(s.unlimited_lives_active(), "a failed finale gives none (no map badge)")
	assert_eq(int(s.lives()), 3)
	at(5)
	win(s, 25)
	assert_true(s.unlimited_lives_active())
	at(14)
	lose(s, 26)
	assert_eq(int(s.lives()), 3, "T + 14 min: still unlimited, no life lost")
	at(16)
	lose(s, 26)
	assert_eq(int(s.lives()), 2, "T + 16 min: over, a life is lost")
	at(34)
	assert_eq(int(s.lives()), 2, "a fresh countdown started at T + 15 min, not the dropped one")
	at(35)
	assert_eq(int(s.lives()), 3, "T + 35 min")


func test_ir81_countdown_dropped_at_unlimited_start_fresh_one_when_they_end() -> void:
	# lives 3, countdown 5 min in (started at T - 5 min)
	var s: Variant = save_with({"next_level": 25, "lives": 3, "refill_started_at": T0 - 5 * 60})
	if s == null:
		return
	at(0)
	win(s, 25)
	assert_true(s.unlimited_lives_active())
	assert_eq(int(s.lives()), 3)
	at(9)
	assert_eq(int(s.lives()), 3, "no countdown during unlimited lives")
	at(10)
	assert_false(s.unlimited_lives_active())
	assert_eq(int(s.lives()), 3, "T + 10 min: unlimited lives end, a fresh countdown starts")
	at(15)
	assert_eq(int(s.lives()), 3, "no life from the dropped countdown")
	at(29)
	assert_eq(int(s.lives()), 3)
	at(30)
	assert_eq(int(s.lives()), 4, "T + 30 min")
	at(49)
	assert_eq(int(s.lives()), 4)
	at(50)
	assert_eq(int(s.lives()), 5, "T + 50 min")


func test_ir81_fresh_countdown_counts_from_the_end_of_unlimited_lives_with_the_game_closed() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 3, "refill_started_at": T0 - 5 * 60})
	if s == null:
		return
	at(0)
	win(s, 25)
	at(1)
	var s2: Variant = reopen()
	if s2 == null:
		return
	at(45)
	var s3: Variant = reopen()
	if s3 == null:
		return
	assert_eq(int(s3.lives()), 4, "counted from T + 10 min: a life at T + 30, the next due at T + 50")
	at(49)
	assert_eq(int(s3.lives()), 4)
	at(50)
	assert_eq(int(s3.lives()), 5, "T + 50 min")


func test_ir81_no_countdown_starts_when_unlimited_lives_end_at_5_lives() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 5})
	if s == null:
		return
	at(0)
	win(s, 25)
	assert_eq(int(s.lives()), 5)
	at(10)
	assert_eq(int(s.lives()), 5, "T + 10 min: still 5, no countdown")
	at(30)
	assert_eq(int(s.lives()), 5, "T + 30 min")
