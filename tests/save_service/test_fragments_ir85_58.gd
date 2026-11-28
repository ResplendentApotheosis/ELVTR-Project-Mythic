# GUT tests for IR-85 (Rat restored at its 8th fragment) and the SaveService half of IR-58 (a fragment is banked
# only on a win; a fail or quit keeps `fragments.rat`). API: tests/API_CONTRACT.md section 12.
# Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func _free_fragment(t: Variant, carrier: String) -> void:
	var e: BoardEvent = BoardEvent.new("collected")
	e.data = {"item": "fragment", "carrier": carrier}
	t.observe(e)


func _expected_rat(level: int) -> int:
	var n: int = 0
	for f in FRAGMENT_LEVELS:
		if int(f) <= level:
			n += 1
	return n


func test_ir85_eighth_fragment_at_level_50_restores_the_rat() -> void:
	var s: Variant = save_with({"next_level": 50, "fragments_rat": 7})
	if s == null:
		return
	win(s, 50)
	assert_eq(int(s.fragments("rat")), 8)
	assert_eq(s.restored(), ["rat"])


func test_ir85_seventh_fragment_does_not_restore() -> void:
	var s: Variant = save_with({"next_level": 45, "fragments_rat": 6})
	if s == null:
		return
	win(s, 45)
	assert_eq(int(s.fragments("rat")), 7)
	assert_eq(s.restored(), [])


func test_ir85_levels_1_to_50_won_in_order_fragment_counts() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	for lv in range(1, 51):
		win(s, lv)
		assert_eq(int(s.fragments("rat")), _expected_rat(lv), "fragments.rat after level %d" % lv)
		if lv < 50:
			assert_eq(s.restored(), [], "not restored after level %d" % lv)
	assert_eq(int(s.fragments("rat")), 8)
	assert_eq(s.restored(), ["rat"])
	assert_eq(int(s.next_level()), 51)


func test_ir85_fail_continue_and_booster_do_not_change_fragments() -> void:
	var s: Variant = save_with({
		"next_level": 12, "fragments_rat": 3, "coins": 1000,
		"hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": 0},
	})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	var board: BoardModel = BB.blank()
	run_out(d.tracker, board)
	assert_true(d.tracker.accept_offer(board), "a continue bought")
	assert_true(s.use_hero_booster("hoof_tap"), "a booster bought")
	run_out(d.tracker, board)
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.fragments("rat")), 3)
	assert_eq(int(s.coins()), 600)


func test_ir58_level_26_fragment_freed_then_declined_keeps_zero() -> void:
	var s: Variant = save_with({"next_level": 26, "fragments_rat": 0, "coins": 1000})
	if s == null:
		return
	var d: Dictionary = start(s, 26)
	_free_fragment(d.tracker, "OB07")
	run_out(d.tracker, BB.blank())
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.fragments("rat")), 0, "no fragment gained on a fail")
	assert_eq(int(s.next_level()), 26)


func test_ir58_level_38_fragment_item_collected_then_fail_keeps_three() -> void:
	var s: Variant = save_with({"next_level": 38, "fragments_rat": 3})
	if s == null:
		return
	var d: Dictionary = start(s, 38)
	_free_fragment(d.tracker, "OB11")
	run_out(d.tracker, BB.blank())
	d.tracker.decline_offer()
	s.end_attempt("fail")
	assert_eq(int(s.fragments("rat")), 3)


func test_ir58_level_26_win_banks_one() -> void:
	var s: Variant = save_with({"next_level": 26, "fragments_rat": 0})
	if s == null:
		return
	win(s, 26)
	assert_eq(int(s.fragments("rat")), 1)


func test_ir58_level_30_fragment_collected_then_quit_keeps_one() -> void:
	var s: Variant = save_with({"next_level": 30, "fragments_rat": 1})
	if s == null:
		return
	var d: Dictionary = start(s, 30)
	_free_fragment(d.tracker, "OB11")
	d.tracker.quit()
	s.end_attempt("quit")
	assert_eq(int(s.fragments("rat")), 1)


func test_ir58_fragment_not_banked_when_the_app_is_killed() -> void:
	var s: Variant = save_with({"next_level": 30, "fragments_rat": 1})
	if s == null:
		return
	var d: Dictionary = start(s, 30)
	_free_fragment(d.tracker, "OB07")
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.fragments("rat")), 1)


func test_ir85_counts_by_level_number_without_a_level_file() -> void:
	# start() gives a tracker with no fragment goal at all: only the level number tells SaveService
	var s: Variant = save_with({"next_level": 26})
	if s == null:
		return
	win(s, 26)
	assert_eq(int(s.fragments("rat")), 1, "level 26 won: +1")
	win(s, 27)
	assert_eq(int(s.fragments("rat")), 1, "level 27 won: unchanged")


func test_ir85_each_fragment_level_adds_one_by_number() -> void:
	for lv in FRAGMENT_LEVELS:
		var s: Variant = save_with({"next_level": int(lv), "fragments_rat": 2})
		if s == null:
			return
		win(s, int(lv))
		assert_eq(int(s.fragments("rat")), 3, "level %d won: +1" % int(lv))
