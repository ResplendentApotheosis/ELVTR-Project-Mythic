# GUT tests for IR-80: coins start at 500, only a win adds, only continues/lives/boosters spend, never below 0.
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir80_new_save_has_500_coins() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	assert_eq(int(s.coins()), 500)


func test_ir80_win_with_4_finale_rockets_adds_40() -> void:
	var s: Variant = save_with({"next_level": 12, "coins": 500})
	if s == null:
		return
	win(s, 12, 4)
	assert_eq(int(s.coins()), 540)


func test_ir80_win_on_last_move_adds_20() -> void:
	var s: Variant = save_with({"next_level": 12, "coins": 500})
	if s == null:
		return
	win(s, 12, 0)
	assert_eq(int(s.coins()), 520)


func test_ir80_fail_without_buying_anything_keeps_coins() -> void:
	var s: Variant = save_with({"next_level": 12, "coins": 500})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.coins()), 500)


func test_ir80_buy_all_lives_refused_with_120_coins() -> void:
	var s: Variant = save_with({"lives": 0, "coins": 120})
	if s == null:
		return
	var r: Variant = s.buy_all_lives()
	assert_false(_bought(r), "120 < 150: refused")
	assert_eq(String(r.get("reason", "")) if r is Dictionary else "", "not_enough_coins")
	assert_eq(int(s.coins()), 120)
	assert_eq(int(s.lives()), 0)


func test_ir80_buy_all_lives_with_150_coins() -> void:
	var s: Variant = save_with({"lives": 0, "coins": 150})
	if s == null:
		return
	assert_true(_bought(s.buy_all_lives()), "bought")
	assert_eq(int(s.coins()), 0)
	assert_eq(int(s.lives()), 5)


func test_ir80_paid_hero_booster_refused_with_90_coins() -> void:
	var s: Variant = save_with({"coins": 90, "hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": 0}})
	if s == null:
		return
	assert_false(s.use_hero_booster("hoof_tap"), "100-coin Hoof Tap refused with 90 coins")
	assert_eq(int(s.coins()), 90)


func test_ir80_pre_level_booster_refused_with_140_coins_attempt_can_start_without() -> void:
	var s: Variant = save_with({
		"next_level": 18, "coins": 140, "pre_unlocked": true,
		"pre_free": {"rocket_crane": 0, "firecracker": 0},
	})
	if s == null:
		return
	assert_false(started(start(s, 18, ["firecracker"])), "150-coin Firecracker refused with 140 coins")
	assert_eq(int(s.coins()), 140)
	var d: Dictionary = start(s, 18)
	assert_true(started(d), "the attempt can still start without it")
	assert_eq(pre_specials_of(d), [])
	assert_eq(int(s.coins()), 140)


func test_ir80_continue_spend_is_kept_by_the_save_after_sync() -> void:
	# IR-37 + IR-80: a continue spends coins on the tracker; sync_attempt writes that to the save
	var s: Variant = save_with({"next_level": 12, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	s.sync_attempt()
	assert_eq(int(s.coins()), 700)


func test_ir81_buy_all_lives_at_5_lives_is_refused_no_coins_charged() -> void:
	var s: Variant = save_with({"lives": 5, "coins": 500})
	if s == null:
		return
	var r: Variant = s.buy_all_lives()
	assert_true(r is Dictionary, "buy_all_lives returns a Dictionary")
	if not (r is Dictionary):
		return
	assert_false(bool(r.get("ok", true)), "refused at 5 lives")
	assert_eq(String(r.get("reason", "")), "already_full")
	assert_eq(String(r.get("message", "")), "You already have 5 lives")
	assert_eq(int(s.lives()), 5)
	assert_eq(int(s.coins()), 500, "no coins charged")
	assert_eq(s.life_log(), [], "a refused purchase is not logged")
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.coins()), 500, "still 500 after reopening")


func test_ir81_buy_all_lives_at_4_lives_costs_150() -> void:
	var s: Variant = save_with({"lives": 4, "coins": 500})
	if s == null:
		return
	var r: Variant = s.buy_all_lives()
	assert_true(_bought(r))
	assert_eq(int(s.lives()), 5)
	assert_eq(int(s.coins()), 350)
	assert_eq(s.life_log(), ["lives_bought"])
