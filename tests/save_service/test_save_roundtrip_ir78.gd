# GUT tests for IR-78: the save keeps the player's progress between sessions and attempts.
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir78_new_save_starting_values() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	assert_eq(int(s.coins()), 500, "new save: 500 coins")
	assert_eq(int(s.lives()), 5, "new save: 5 lives")
	assert_eq(int(s.next_level()), 1)
	assert_eq(int(s.streak()), 0)
	assert_false(s.chest_waiting())
	assert_eq(int(s.fragments("rat")), 0)
	assert_eq(s.restored(), [])


func test_ir78_round_trip_every_value_and_schema_version() -> void:
	var s: Variant = save_with({
		"next_level": 28, "coins": 840, "lives": 5, "fragments_rat": 1, "restored": [],
		"hero_unlocked": ["hoof_tap", "tail_slam", "bamboo_dash"],
		"hero_free": {"hoof_tap": 3, "tail_slam": 2, "bamboo_dash": 0, "feather_fan": 0},
	})
	if s == null:
		return
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.next_level()), 28)
	assert_eq(int(s2.coins()), 840)
	assert_eq(int(s2.lives()), 5)
	assert_eq(int(s2.fragments("rat")), 1)
	assert_eq(s2.restored(), [])
	assert_eq(int(s2.hero_free_uses("hoof_tap")), 3)
	assert_eq(int(s2.hero_free_uses("tail_slam")), 2)
	assert_eq(int(s2.hero_free_uses("bamboo_dash")), 0)
	assert_true(s2.hero_unlocked("bamboo_dash"), "unlocked with 0 free uses left")
	assert_false(s2.hero_unlocked("feather_fan"))
	var data: Variant = read_file_json()
	if data == null:
		return
	assert_true(data is Dictionary, "the save file is a JSON object")
	assert_true((data as Dictionary).has("schema_version"), "the file carries a schema_version")
	assert_gte(int((data as Dictionary).get("schema_version", 0)), 1)


func test_ir78_retry_starts_with_coins_and_lives_the_save_holds() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 4, "coins": 700})
	if s == null:
		return
	var d: Dictionary = start(s, 12)
	assert_true(started(d))
	var t: Variant = d.tracker
	var board: BoardModel = BB.blank()
	run_out(t, board)
	assert_true(t.accept_offer(board), "offer 1 accepted")
	assert_eq(int(t.coins), 400)
	s.sync_attempt()
	run_out(t, board)
	t.decline_offer()
	s.end_attempt("fail")
	var d2: Dictionary = start(s, 12)
	assert_true(started(d2), "retry starts")
	assert_eq(int(d2.tracker.coins), 400, "attempt 2 starts with coins 400, not 700")
	assert_eq(int(d2.tracker.lives), 3, "attempt 2 starts with lives 3, not 4")
	assert_eq(int(s.coins()), 400)
	assert_eq(int(s.lives()), 3)


func test_ir78_win_with_finale_rockets_survives_close_and_reopen() -> void:
	var s: Variant = save_with({"next_level": 26, "coins": 500, "fragments_rat": 0})
	if s == null:
		return
	win(s, 26, 2)
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.coins()), 530)
	assert_eq(int(s2.fragments("rat")), 1)
	assert_eq(int(s2.next_level()), 27)


func test_ir78_chest_streak_and_story_beats_survive_close_and_reopen() -> void:
	var s: Variant = save_with({"next_level": 21, "streak": 5, "seen_beats": [1, 15, 17, 20]})
	if s == null:
		return
	win(s, 21)
	assert_true(s.chest_waiting(), "chest waiting after the 6th win")
	assert_eq(int(s.streak()), 0)
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_true(s2.chest_waiting(), "the chest is still waiting")
	assert_eq(int(s2.streak()), 0)
	assert_eq(s2.seen_story_beats(), [1, 15, 17, 20])


func test_ir78_level_20_milestone_saves_nothing_extra() -> void:
	var s: Variant = save_with({
		"next_level": 20, "coins": 500, "streak": 2, "lives": 5, "pre_unlocked": true,
		"pre_free": {"rocket_crane": 1, "firecracker": 1},
		"hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": 3},
	})
	if s == null:
		return
	win(s, 20, 0)
	assert_eq(int(s.coins()), 520, "no extra coins for the milestone")
	assert_eq(int(s.streak()), 3)
	assert_eq(int(s.next_level()), 21)
	assert_eq(int(s.hero_free_uses("hoof_tap")), 3, "no booster uses added")
	assert_eq(int(s.pre_free_uses("rocket_crane")), 1)
	assert_eq(int(s.pre_free_uses("firecracker")), 1)
	assert_eq(int(s.lives()), 5)
	assert_eq(int(s.fragments("rat")), 0)


func test_ir78_attempt_log_and_lives_survive_reopen() -> void:
	var s: Variant = save_with({"next_level": 12, "lives": 5})
	if s == null:
		return
	lose(s, 12)
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_eq(int(s2.lives()), 4)
	assert_eq((s2.attempt_log() as Array).size(), 1)


func _write_raw(text: String) -> void:
	var f: FileAccess = FileAccess.open(_file, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _assert_new_player(s: Variant) -> void:
	assert_eq(int(s.next_level()), 1, "next level 1")
	assert_eq(int(s.coins()), 500, "500 coins")
	assert_eq(int(s.lives()), 5, "5 lives")
	assert_eq(int(s.fragments("rat")), 0, "fragments.rat 0")
	assert_eq(s.restored(), [], "nothing restored")
	assert_eq(int(s.streak()), 0, "streak 0")
	assert_false(s.chest_waiting())
	assert_false(s.unlimited_lives_active())


func test_ir78_unreadable_save_without_temp_copy_starts_a_new_player() -> void:
	_write_raw("{ this is not json ][")
	var s: Variant = open_save()
	if s == null:
		return
	_assert_new_player(s)
	assert_true(s.can_start(1), "and level 1 can be started")


func test_ir78_progress_save_overwritten_with_invalid_json_starts_a_new_player() -> void:
	var s: Variant = save_with({"next_level": 30, "coins": 90, "lives": 2, "streak": 3,
		"fragments_rat": 4, "restored": ["rat"], "chest_waiting": true})
	if s == null:
		return
	assert_false(FileAccess.file_exists(_file + ".tmp"), "no temporary copy lying around")
	_write_raw("")
	var s2: Variant = reopen()
	if s2 == null:
		return
	_assert_new_player(s2)
	_write_raw("{\"schema_version\": 1, \"coins\": ")
	var s3: Variant = reopen()
	if s3 == null:
		return
	_assert_new_player(s3)
