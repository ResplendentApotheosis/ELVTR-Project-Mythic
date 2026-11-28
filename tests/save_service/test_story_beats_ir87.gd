# GUT tests for IR-87: each story beat plays once, the first time its level is reached; the save remembers it.
# A skipped beat counts as played: whoever shows the card calls mark_story_beat_seen when it was shown OR skipped.
# API: tests/API_CONTRACT.md section 12. Check: run the GUT suite.
extends "res://tests/save_service/save_test_base.gd"


func test_ir87_beat_levels_are_due_on_a_fresh_save_other_levels_are_not() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	for lv in range(1, 51):
		assert_eq(bool(s.should_play_story_beat(lv)), BEAT_LEVELS.has(lv), "beat due at level %d" % lv)


func test_ir87_level_15_plays_on_first_attempt_not_on_retry() -> void:
	var s: Variant = save_with({"next_level": 15})
	if s == null:
		return
	assert_true(s.should_play_story_beat(15), "first attempt: the card plays")
	assert_true(started(start(s, 15)))
	s.mark_story_beat_seen(15)
	s.end_attempt("fail")
	assert_false(s.should_play_story_beat(15), "retry: no card")


func test_ir87_seen_beat_survives_close_and_reopen() -> void:
	var s: Variant = save_with({"next_level": 15, "seen_beats": [1]})
	if s == null:
		return
	s.mark_story_beat_seen(15)
	var s2: Variant = reopen()
	if s2 == null:
		return
	assert_false(s2.should_play_story_beat(15))
	assert_false(s2.should_play_story_beat(1))
	assert_true(started(start(s2, 15)))
	assert_false(s2.should_play_story_beat(15), "level 15 retried: no card")
	assert_eq(s2.seen_story_beats(), [1, 15])


func test_ir87_skipped_beat_is_marked_like_a_played_one() -> void:
	# the player skips the card: the UI marks it seen the same way
	var s: Variant = save_with({"next_level": 15})
	if s == null:
		return
	s.mark_story_beat_seen(15)
	assert_eq(s.seen_story_beats(), [15])
	assert_false(s.should_play_story_beat(15))


func test_ir87_level_1_intro_plays_once_then_not_on_retry_or_after_reopen() -> void:
	var s: Variant = open_save()
	if s == null:
		return
	assert_true(s.should_play_story_beat(1), "first attempt: the intro comic plays")
	assert_true(started(start(s, 1)))
	s.mark_story_beat_seen(1)
	s.end_attempt("fail")
	assert_false(s.should_play_story_beat(1), "retry: no comic")
	var s2: Variant = reopen()
	if s2 != null:
		assert_false(s2.should_play_story_beat(1), "still no comic after reopening")


func test_ir87_level_without_a_beat_changes_nothing() -> void:
	var s: Variant = save_with({"next_level": 16, "seen_beats": [1, 15]})
	if s == null:
		return
	assert_true(started(start(s, 16)))
	assert_false(s.should_play_story_beat(16), "no beat plays on level 16")
	assert_eq(s.seen_story_beats(), [1, 15], "the seen list is unchanged")
