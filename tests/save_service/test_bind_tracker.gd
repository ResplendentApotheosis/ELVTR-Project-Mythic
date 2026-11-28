# GUT tests for the "one board build" change (owner, 28 Nov 2026): SaveService.start_attempt can decide an
# attempt with NO tracker (tracker = null), and bind_tracker(tracker) gives the tracker lives and coins later.
# Rules touched: IR-77, IR-79, IR-80, IR-81, IR-83, IR-84, IR-38. API: tests/API_CONTRACT.md 12.2 (bind_tracker).
# Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func _bind_missing(s: Variant) -> bool:
	if not s.has_method("bind_tracker"):
		fail_test("SaveService.bind_tracker(tracker) is missing (API_CONTRACT.md 12.2)")
		return true
	return false


func test_start_attempt_without_tracker_is_accepted_and_opens_the_attempt() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5})
	if s == null:
		return
	var r: Variant = s.start_attempt(12, null)
	assert_true(r is Dictionary and bool(r.get("ok", false)), "accepted with no tracker")
	assert_eq(r.get("pre_specials", ["x"]), [])
	assert_true(bool(r.get("first_try", false)))
	var again: Variant = reopen()
	assert_eq(again.attempt_log().size(), 1, "the open attempt was recovered as a quit on the next launch")
	assert_true(bool(again.attempt_log()[0].quit))


func test_start_attempt_without_tracker_with_a_pre_booster_pays_and_returns_specials() -> void:
	var s: Variant = save_with({"next_level": 12, "coins": 500, "pre_unlocked": true, "pre_free": {"firecracker": 0, "rocket_crane": 0}})
	if s == null:
		return
	var r: Variant = s.start_attempt(12, null, ["firecracker"])
	assert_true(bool(r.get("ok", false)))
	assert_eq(r.pre_specials, ["firecracker"])
	assert_eq(s.coins(), 350, "IR-83: 150 coins, with no tracker involved")


func test_start_attempt_without_tracker_uses_up_the_chest() -> void:
	var s: Variant = save_with({"next_level": 12, "chest_waiting": true})
	if s == null:
		return
	var r: Variant = s.start_attempt(12, null)
	assert_eq(r.pre_specials, ["rocket", "crane"])
	assert_false(s.chest_waiting())


func test_refused_start_without_tracker_changes_nothing() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 0, "coins": 500, "chest_waiting": true})
	if s == null:
		return
	var r: Variant = s.start_attempt(12, null)
	assert_false(bool(r.get("ok", true)))
	assert_true(s.chest_waiting(), "a refused start keeps the chest")
	assert_eq(s.coins(), 500)
	assert_eq(s.attempt_log().size(), 0)


func test_bind_tracker_sets_lives_and_coins_from_the_save() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 3, "coins": 777})
	if s == null or _bind_missing(s):
		return
	s.start_attempt(12, null)
	var t: Variant = loose_tracker([obstacle_goal("OB02", 5)], 12)
	t.lives = 1
	t.coins = 1
	s.bind_tracker(t)
	assert_eq(t.lives, 3)
	assert_eq(t.coins, 777)


func test_bind_tracker_shows_the_coins_after_a_pre_booster_was_paid() -> void:
	var s: Variant = save_with({"next_level": 12, "coins": 500, "pre_unlocked": true, "pre_free": {"firecracker": 0, "rocket_crane": 0}})
	if s == null or _bind_missing(s):
		return
	s.start_attempt(12, null, ["firecracker"])
	var t: Variant = loose_tracker([obstacle_goal("OB02", 5)], 12)
	s.bind_tracker(t)
	assert_eq(t.coins, 350)


func test_bound_tracker_keeps_the_save_in_step_like_a_tracker_given_at_start() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null or _bind_missing(s):
		return
	s.start_attempt(12, null)
	var t: Variant = loose_tracker([obstacle_goal("OB02", 5)], 12)
	s.bind_tracker(t)
	var board: BoardModel = BB.blank()
	run_out(t, board)
	assert_true(t.accept_offer(board))
	s.sync_attempt()
	assert_eq(reopen().coins(), 700, "IR-38: the continue's spend was taken from the bound tracker")


func test_end_attempt_gives_the_bound_tracker_the_save_values() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null or _bind_missing(s):
		return
	s.start_attempt(12, null)
	var t: Variant = loose_tracker([obstacle_goal("OB02", 5)], 12)
	s.bind_tracker(t)
	s.end_attempt("fail")
	assert_eq(t.lives, 4)
	assert_eq(t.coins, 1000)


func test_end_attempt_without_a_bound_tracker_still_works() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5, "coins": 1000})
	if s == null:
		return
	s.start_attempt(12, null)
	s.end_attempt("fail")
	assert_eq(s.lives(), 4)
	assert_eq(s.coins(), 1000)
