# GUT tests: when the board fails to build after the attempt started, LevelSession cancels the attempt (IR-88).
# The bad fixture has a valid id (12) but fails LevelLoader validation, so no board may be built from it.
# Not tested (OQ-97): booster / chest refund, hero unlocks, the screen after. API: API_CONTRACT.md 15.1.
# Check: run the GUT suite.
extends GutTest

const GOOD: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const BAD: String = "res://tests/greybox/fixtures/level_fixture_bad_012.json"

class FakeClock:
	extends RefCounted
	var now: int = 1700000000

	func read() -> int:
		return now


var _clock: FakeClock
var _file: String = ""
var _save: SaveService


func before_each() -> void:
	_clock = FakeClock.new()
	_file = "user://zf_session_cancel_%d.json" % Time.get_ticks_usec()
	_save = SaveService.new(_file, Callable(_clock, "read"))
	_save.debug_set({"next_level": 12, "lives": 5, "streak": 3, "coins": 1000})


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


func test_IR88_fixture_really_fails_validation() -> void:
	var level: Variant = LevelLoader.read_level_file(BAD)
	assert_true(level is Dictionary)
	assert_eq(int((level as Dictionary).get("id", 0)), 12)
	assert_false(LevelLoader.validate(level as Dictionary, 12).is_empty())


func test_IR88_failed_build_cancels_the_attempt_with_no_penalty() -> void:
	var s: LevelSession = LevelSession.new(BAD, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(s.state, LevelSession.NOT_STARTED)
	assert_ne(s.last_error, "", "the reason is kept")
	assert_eq(_save.lives(), 5, "no life lost")
	assert_eq(_save.streak(), 3)
	assert_eq(_save.coins(), 1000)
	assert_eq(_save.next_level(), 12)
	assert_eq(_save.attempt_log().size(), 0, "no log entry")
	assert_eq(_save.life_log().size(), 0)


func test_IR88_no_fail_result_offer_or_retry_screen() -> void:
	var s: LevelSession = LevelSession.new(BAD, _save)
	assert_false(s.start({"seed": 7}))
	assert_ne(s.state, LevelSession.RETRY)
	assert_ne(s.state, LevelSession.OFFER)
	assert_eq(s.attempt, null, "no board was kept")


func test_IR88_no_open_attempt_is_left_behind() -> void:
	var s: LevelSession = LevelSession.new(BAD, _save)
	assert_false(s.start({"seed": 7}))
	var again: SaveService = SaveService.new(_file, Callable(_clock, "read"))
	assert_eq(again.lives(), 5, "next launch finds no killed attempt")
	assert_eq(again.attempt_log().size(), 0)
	# the session can try again: the save does not think an attempt is still running
	assert_false(s.start({"seed": 8}))
	assert_eq(s.last_error.find("already running"), -1)


func test_IR88_the_next_attempt_that_builds_is_a_first_try() -> void:
	var bad: LevelSession = LevelSession.new(BAD, _save)
	assert_false(bad.start({"seed": 7}))
	var good: LevelSession = LevelSession.new(GOOD, _save)
	assert_true(good.start({"seed": 7}), good.last_error)
	_save.end_attempt("quit")
	var entries: Array = _save.attempt_log()
	assert_eq(entries.size(), 1)
	assert_true(bool((entries[0] as Dictionary).get("first_try", false)))


func test_IR88_good_level_still_builds() -> void:
	var s: LevelSession = LevelSession.new(GOOD, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(s.state, LevelSession.PLAYING)
