# GUT tests for IR-82: hero boosters unlock at 11, 23, 29, 36 when that level is first started, with free uses given
# once, then cost coins paid at use. API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir82_nothing_usable_before_level_11() -> void:
	var s: Variant = save_with({"next_level": 10, "coins": 1000})
	if s == null:
		return
	for bname in HERO:
		assert_false(s.hero_unlocked(bname), "%s not unlocked" % bname)
		assert_false(s.use_hero_booster(bname), "%s cannot be used" % bname)
	assert_eq(int(s.coins()), 1000)


func test_ir82_level_35_started_feather_fan_still_locked() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	play_to(s, 35)
	assert_true(started(start(s, 35)))
	assert_true(s.hero_unlocked("hoof_tap"))
	assert_true(s.hero_unlocked("tail_slam"))
	assert_true(s.hero_unlocked("bamboo_dash"))
	assert_false(s.hero_unlocked("feather_fan"), "Feather Fan unlocks at 36")


func test_ir82_unlock_happens_when_the_level_is_first_started_with_free_uses() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	for bname in ["hoof_tap", "tail_slam", "bamboo_dash", "feather_fan"]:
		var info: Dictionary = HERO[bname]
		play_to(s, int(info.level))
		assert_false(s.hero_unlocked(bname), "%s: not unlocked before level %d is started" % [bname, info.level])
		var d: Dictionary = start(s, int(info.level))
		assert_true(started(d))
		assert_true(s.hero_unlocked(bname), "%s unlocked when level %d starts" % [bname, info.level])
		assert_eq(int(s.hero_free_uses(bname)), int(info.free), "%s free uses" % bname)
		s.end_attempt("win", 0)


func test_ir82_free_uses_not_given_again_on_retry() -> void:
	var s: Variant = save_with({"next_level": 11})
	if s == null:
		return
	assert_true(started(start(s, 11)))
	assert_true(s.use_hero_booster("hoof_tap"))
	s.end_attempt("fail")
	assert_eq(int(s.hero_free_uses("hoof_tap")), 2)
	assert_true(started(start(s, 11)), "retry")
	assert_eq(int(s.hero_free_uses("hoof_tap")), 2, "not given again")


func test_ir82_free_uses_then_paid_at_100() -> void:
	var s: Variant = save_with({"coins": 500, "hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": 3}})
	if s == null:
		return
	for i in range(3):
		assert_true(s.use_hero_booster("hoof_tap"), "free use %d" % (i + 1))
	assert_eq(int(s.hero_free_uses("hoof_tap")), 0)
	assert_eq(int(s.coins()), 500, "free uses cost nothing")
	assert_true(s.use_hero_booster("hoof_tap"), "4th use is paid")
	assert_eq(int(s.coins()), 400)
	assert_eq(int(s.hero_free_uses("hoof_tap")), 0, "paid uses are never banked")


func test_ir82_each_booster_price_when_no_free_uses() -> void:
	for bname in HERO:
		var s: Variant = save_with({"coins": 1000, "hero_unlocked": [bname], "hero_free": {bname: 0}})
		if s == null:
			return
		assert_true(s.use_hero_booster(bname))
		assert_eq(int(s.coins()), 1000 - int(HERO[bname].price), "%s price" % bname)


func test_ir82_no_free_uses_per_level() -> void:
	var s: Variant = save_with({"next_level": 14, "hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": 2}})
	if s == null:
		return
	win(s, 14)
	assert_true(started(start(s, 15)))
	assert_eq(int(s.hero_free_uses("hoof_tap")), 2, "still 2 after level 15 started")


func test_ir82_tail_slam_refused_at_150_then_paid_at_200() -> void:
	var s: Variant = save_with({"coins": 150, "hero_unlocked": ["tail_slam"], "hero_free": {"tail_slam": 0}})
	if s == null:
		return
	assert_false(s.use_hero_booster("tail_slam"))
	assert_eq(int(s.coins()), 150)
	s.debug_set({"coins": 200})
	assert_true(s.use_hero_booster("tail_slam"))
	assert_eq(int(s.coins()), 0)


func test_ir82_paid_use_during_an_attempt_keeps_continue_spend_and_tracker_in_step() -> void:
	var s: Variant = save_with({
		"next_level": 12, "coins": 1000, "hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": 0},
	})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board))
	assert_true(s.use_hero_booster("hoof_tap"))
	assert_eq(int(s.coins()), 600, "1000 - 300 (continue) - 100 (Hoof Tap)")
	assert_eq(int(d.tracker.coins), 600, "the tracker's coins follow")
