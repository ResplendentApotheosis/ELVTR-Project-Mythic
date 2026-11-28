# GUT tests for IR-84: 6 wins in a row drop a free Rocket + Crane (a chest) onto the next board; a fail or quit
# resets the streak; the chest is used up by the next attempt. API: tests/API_CONTRACT.md section 12.
# Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir84_sixth_win_drops_chest_next_board_has_rocket_and_crane() -> void:
	var s: Variant = save_with({
		"next_level": 21, "streak": 5, "coins": 500, "pre_unlocked": true,
		"pre_free": {"rocket_crane": 1, "firecracker": 1},
	})
	if s == null:
		return
	win(s, 21)
	assert_true(s.chest_waiting())
	assert_eq(int(s.streak()), 0)
	var coins_before: int = int(s.coins())
	var d: Dictionary = start(s, 22)
	assert_true(started(d))
	assert_eq(pre_specials_of(d), ["rocket", "crane"])
	assert_eq(int(s.coins()), coins_before, "the chest costs no coins")
	assert_eq(int(s.pre_free_uses("rocket_crane")), 1, "and no pre-level booster use")
	assert_eq(int(s.pre_free_uses("firecracker")), 1)
	assert_false(s.chest_waiting(), "used up by this attempt")


func test_ir84_chest_used_next_board_has_none_second_chest_after_six_more_wins() -> void:
	var s: Variant = save_with({"next_level": 21, "streak": 5})
	if s == null:
		return
	win(s, 21)
	var d22: Dictionary = start(s, 22)
	assert_eq(pre_specials_of(d22), ["rocket", "crane"])
	s.end_attempt("win", 0)
	assert_eq(int(s.streak()), 1)
	var d23: Dictionary = start(s, 23)
	assert_eq(pre_specials_of(d23), [], "level 23 has no chest Rocket or Crane")
	s.end_attempt("win", 0)
	for lv in range(24, 28):
		win(s, lv)
	assert_true(s.chest_waiting(), "streak 6 after level 27: the next chest")
	assert_eq(int(s.streak()), 0)
	var d28: Dictionary = start(s, 28)
	assert_eq(pre_specials_of(d28), ["rocket", "crane"], "level 28 starts with it")


func test_ir84_chest_board_fail_streak_zero_retry_has_no_chest() -> void:
	var s: Variant = save_with({"next_level": 21, "streak": 5})
	if s == null:
		return
	win(s, 21)
	var d: Dictionary = start(s, 22)
	assert_eq(pre_specials_of(d), ["rocket", "crane"])
	s.end_attempt("fail")
	assert_eq(int(s.streak()), 0)
	var d2: Dictionary = start(s, 22)
	assert_true(started(d2))
	assert_eq(pre_specials_of(d2), [], "the retry starts without the chest")


func test_ir84_chest_is_used_up_even_if_the_app_is_killed() -> void:
	var s: Variant = save_with({"next_level": 21, "streak": 5})
	if s == null:
		return
	win(s, 21)
	assert_eq(pre_specials_of(start(s, 22)), ["rocket", "crane"])
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_false(s2.chest_waiting())
	assert_eq(pre_specials_of(start(s2, 22)), [])


func test_ir84_quit_resets_streak() -> void:
	var s: Variant = save_with({"next_level": 14, "streak": 4})
	if s == null:
		return
	quit_level(s, 14)
	assert_eq(int(s.streak()), 0)


func test_ir84_win_after_accepted_continue_counts() -> void:
	var s: Variant = save_with({"next_level": 14, "streak": 4, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 14)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	assert_eq(int(s.streak()), 4, "accepting a continue does not touch the streak")
	s.end_attempt("win", 0)
	assert_eq(int(s.streak()), 5)


func test_ir84_finale_fail_resets_streak_without_losing_a_life() -> void:
	var s: Variant = save_with({"next_level": 25, "streak": 3, "lives": 5})
	if s == null:
		return
	lose(s, 25)
	assert_eq(int(s.streak()), 0)
	assert_eq(int(s.lives()), 5)


func test_ir84_sixth_win_on_level_50_gives_no_chest() -> void:
	var s: Variant = save_with({"next_level": 50, "streak": 5, "fragments_rat": 7})
	if s == null:
		return
	win(s, 50)
	assert_false(s.chest_waiting(), "no next board, no chest")
	assert_false(s.can_start(50))
	assert_false(s.can_start(51))


func test_ir84_killed_app_resets_streak() -> void:
	var s: Variant = save_with({"next_level": 14, "streak": 4})
	if s == null:
		return
	assert_true(started(start(s, 14)))
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.streak()), 0)


func test_ir84_pre_level_booster_on_the_chest_board_chest_specials_placed_after() -> void:
	var s: Variant = save_with({
		"next_level": 21, "streak": 5, "coins": 500, "pre_unlocked": true,
		"pre_free": {"rocket_crane": 1, "firecracker": 0},
	})
	if s == null:
		return
	win(s, 21)
	assert_true(s.chest_waiting())
	var coins_before: int = int(s.coins())
	var d: Dictionary = start(s, 22, ["firecracker"])
	assert_true(started(d))
	assert_eq(pre_specials_of(d), ["firecracker", "rocket", "crane"], "Firecracker first, then the chest's Rocket and Crane")
	assert_eq(int(s.coins()), coins_before - 150, "the Firecracker costs 150, the chest nothing")
	assert_eq(int(s.pre_free_uses("rocket_crane")), 1, "the chest used no pre-level booster use")
	assert_false(s.chest_waiting(), "the chest is used up")
