# GUT tests for IR-88 (OQ-97 Option A): a cancelled attempt puts the whole save back as it was, so a pre-level
# booster (its free use or 150 coins), a used streak chest and a hero booster unlocked by that start all come back.
# API: SaveService.cancel_attempt, API_CONTRACT.md 15.1 / 16.1. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func _pre_state(next_level: int, coins: int, rc: int = 1, fc: int = 1) -> Dictionary:
	return {"next_level": next_level, "coins": coins, "pre_unlocked": true,
		"pre_free": {"rocket_crane": rc, "firecracker": fc}}


func _cancel(s: Variant) -> void:
	if not s.has_method("cancel_attempt"):
		fail_test("SaveService.cancel_attempt() is missing (API_CONTRACT.md 15.1)")
		return
	s.cancel_attempt()


func test_IR88_free_pre_level_booster_use_comes_back() -> void:
	var s: Variant = save_with(_pre_state(18, 500))
	if s == null:
		return
	assert_true(started(start(s, 18, ["firecracker"])))
	assert_eq(int(s.pre_free_uses("firecracker")), 0, "spent at the start")
	_cancel(s)
	assert_eq(int(s.pre_free_uses("firecracker")), 1, "free use back")
	assert_eq(int(s.pre_free_uses("rocket_crane")), 1)
	assert_eq(int(s.coins()), 500)


func test_IR88_paid_pre_level_booster_gives_the_150_coins_back_and_charges_again_next_time() -> void:
	var s: Variant = save_with(_pre_state(18, 500, 0, 1))
	if s == null:
		return
	var d: Dictionary = start(s, 18, ["rocket_crane"])
	assert_true(started(d))
	assert_eq(int(s.coins()), 350)
	_cancel(s)
	assert_eq(int(s.coins()), 500, "coins back")
	assert_eq(int(s.pre_free_uses("rocket_crane")), 0)
	var d2: Dictionary = start(s, 18, ["rocket_crane"])
	assert_true(started(d2))
	assert_eq(pre_specials_of(d2), ["rocket", "crane"])
	assert_eq(int(s.coins()), 350, "the next attempt pays again")


func test_IR88_streak_chest_is_waiting_again_and_the_next_board_gets_it() -> void:
	var s: Variant = save_with({"next_level": 22, "streak": 0, "chest_waiting": true, "coins": 500})
	if s == null:
		return
	var d: Dictionary = start(s, 22)
	assert_eq(pre_specials_of(d), ["rocket", "crane"])
	assert_false(s.chest_waiting(), "used up by the start")
	_cancel(s)
	assert_true(s.chest_waiting(), "waiting again")
	assert_eq(int(s.streak()), 0)
	var d2: Dictionary = start(s, 22)
	assert_true(started(d2))
	assert_eq(pre_specials_of(d2), ["rocket", "crane"], "the next board has the chest's specials")
	assert_false(s.chest_waiting(), "now used up")


func test_IR88_hero_booster_unlocked_by_the_cancelled_start_is_locked_again() -> void:
	var s: Variant = save_with({"next_level": 11, "coins": 500})
	if s == null:
		return
	assert_true(started(start(s, 11)))
	assert_true(s.hero_unlocked("hoof_tap"))
	_cancel(s)
	assert_false(s.hero_unlocked("hoof_tap"), "locked again")
	assert_eq(int(s.hero_free_uses("hoof_tap")), 0, "no free uses given")
	assert_false(s.use_hero_booster("hoof_tap"))
	assert_true(started(start(s, 11)))
	assert_true(s.hero_unlocked("hoof_tap"))
	assert_eq(int(s.hero_free_uses("hoof_tap")), 3, "unlocks with its 3 free uses on the next real start")
	assert_true(s.use_hero_booster("hoof_tap"))


func test_IR88_pre_level_boosters_unlocked_by_the_cancelled_start_are_locked_again() -> void:
	var s: Variant = save_with({"next_level": 16, "coins": 500})
	if s == null:
		return
	assert_true(started(start(s, 16, ["rocket_crane"])))
	_cancel(s)
	assert_false(s.pre_boosters_unlocked())
	assert_eq(int(s.coins()), 500)
	assert_true(started(start(s, 16, ["rocket_crane"])))
	assert_true(s.pre_boosters_unlocked())
	assert_eq(int(s.coins()), 500, "free on the next real start")


func test_IR88_cancel_survives_closing_the_app() -> void:
	var s: Variant = save_with(_pre_state(18, 500, 0, 1))
	if s == null:
		return
	assert_true(started(start(s, 18, ["rocket_crane"])))
	_cancel(s)
	var s2: Variant = reopen()
	assert_eq(int(s2.coins()), 500)
	assert_eq(int(s2.lives()), 5)
	assert_eq(s2.attempt_log().size(), 0)
