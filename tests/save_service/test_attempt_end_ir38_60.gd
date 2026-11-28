# GUT tests for IR-38 (quit and killed app are fails) and IR-60 (a fail costs a life, except on finales and while
# unlimited lives run) as SaveService keeps them. The tracker side is in tests/goal_tracker/.
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func _last_entry(s: Variant) -> Dictionary:
	var entries: Array = s.attempt_log()
	if entries.is_empty():
		fail_test("the attempt entries is empty")
		return {}
	return entries[entries.size() - 1]


# ---------------------------------------------------------------- IR-38

func test_ir38_quit_level_12_costs_a_life_logged_fail_and_first_try() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	assert_true(started(d))
	assert_true(bool((d.result as Dictionary).get("first_try", false)), "start reports first_try")
	d.tracker.quit()
	s.end_attempt("quit")
	assert_eq(int(s.lives()), 4)
	var e: Dictionary = _last_entry(s)
	assert_eq(int(e.get("level", 0)), 12)
	assert_false(bool(e.get("won", true)), "logged as a fail")
	assert_true(bool(e.get("quit", false)), "logged as a quit")
	assert_true(bool(e.get("first_try", false)), "logged as the first try")


func test_ir38_quit_on_finale_25_costs_no_life() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 3})
	if s == null:
		return
	quit_level(s, 25)
	assert_eq(int(s.lives()), 3)
	assert_false(bool(_last_entry(s).get("won", true)), "logged as a fail")


func test_ir38_quit_with_moves_left_no_offer_coins_unchanged() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	board.moves = 7
	d.tracker.quit()
	assert_eq(int(d.tracker.offer_price()), 0, "no continue offer")
	s.end_attempt("quit")
	assert_eq(int(s.lives()), 4)
	assert_eq(int(s.coins()), 1000)


func test_ir38_app_killed_after_a_continue_is_a_quit_on_next_launch() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "streak": 3, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	assert_eq(int(d.tracker.coins), 700)
	s.sync_attempt()
	# the app is killed here: no end_attempt, the next launch is a new SaveService on the same file
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.next_level()), 12, "the map is shown, level 12 not resumed")
	assert_true(s2.can_start(12))
	assert_eq(int(s2.lives()), 4)
	assert_eq(int(s2.streak()), 0)
	assert_eq(int(s2.coins()), 700, "coins spent on the continue stay spent")
	var entries: Array = s2.attempt_log()
	assert_eq(entries.size(), 1, "one attempt logged")
	var e: Dictionary = entries[0]
	assert_eq(int(e.get("level", 0)), 12)
	assert_false(bool(e.get("won", true)))
	assert_true(bool(e.get("quit", false)))
	assert_true(bool(e.get("first_try", false)))


func test_ir38_app_killed_on_finale_25_costs_no_life_but_is_logged() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 2})
	if s == null:
		return
	assert_true(started(start(s, 25)))
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.lives()), 2)
	var e: Dictionary = _last_entry(s2)
	assert_false(bool(e.get("won", true)), "logged as a fail")
	assert_true(bool(e.get("quit", false)), "logged as a quit")


func test_ir38_killed_attempt_is_logged_once_not_again_on_later_launches() -> void:
	var s: Variant = save_with({"next_level": 12})
	if s == null:
		return
	assert_true(started(start(s, 12)))
	var s2: Variant = reopen()
	var s3: Variant = reopen()
	if s2 == null or s3 == null:
		return
	assert_eq((s3.attempt_log() as Array).size(), 1)
	assert_eq(int(s3.lives()), 4, "only one life lost")


# ---------------------------------------------------------------- IR-60

func test_ir60_declined_offer_costs_one_life_and_tracker_matches() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.lives()), 4)
	assert_eq(int(d.tracker.lives), 4, "tracker.lives matches the save after the attempt")


func test_ir60_finale_fail_costs_no_life() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 3, "coins": 1000})
	if s == null:
		return
	lose(s, 25)
	assert_eq(int(s.lives()), 3)


func test_ir60_quit_on_level_50_costs_no_life() -> void:
	var s: Variant = save_with({"next_level": 50, "lives": 2, "fragments_rat": 7})
	if s == null:
		return
	quit_level(s, 50)
	assert_eq(int(s.lives()), 2)


func test_ir60_accepted_continue_then_win_costs_no_life() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	s.end_attempt("win", 0)
	assert_eq(int(s.lives()), 5)
	assert_eq(int(s.coins()), 720, "1000 - 300 + 20")


func test_ir60_accept_then_decline_costs_one_life_not_two() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	run_out(d.tracker, board)
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.lives()), 4)
	assert_eq(int(s.coins()), 700)


func test_ir60_five_offers_accepted_sixth_run_out_costs_one_life() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 3000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	for i in range(5):
		run_out(d.tracker, board)
		assert_true(d.tracker.accept_offer(board))
		s.sync_attempt()
		assert_eq(int(s.lives()), 5, "lives 5 after offer %d" % (i + 1))
	run_out(d.tracker, board)
	s.end_attempt("fail")
	assert_eq(int(s.lives()), 4)
	assert_eq(int(s.coins()), 700)


func test_ir60_accept_then_quit_costs_one_life() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	d.tracker.quit()
	s.end_attempt("quit")
	assert_eq(int(s.lives()), 4)


func test_ir60_finale_accept_then_decline_costs_no_life() -> void:
	var s: Variant = save_with({"next_level": 25, "lives": 3, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 25)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	run_out(d.tracker, board)
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.lives()), 3)


func test_ir60_fail_during_unlimited_lives_costs_no_life() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "unlimited_until": T0 + 5 * 60})
	if s == null:
		return
	lose(s, 12)
	assert_eq(int(s.lives()), 5)
