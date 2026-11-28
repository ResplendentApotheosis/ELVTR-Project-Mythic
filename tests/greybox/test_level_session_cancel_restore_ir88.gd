# GUT tests: after a failed build LevelSession is back in the state it started from and shows the player the
# message "This level couldn't be loaded" (IR-88, OQ-97 A); boosters, chest and hero unlocks come back.
# API: API_CONTRACT.md 16.2 (`notice`). Check: run the GUT suite.
extends GutTest

const GOOD: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const BAD: String = "res://tests/greybox/fixtures/level_fixture_bad_012.json"
const MESSAGE: String = "This level couldn't be loaded"

class FakeClock:
	extends RefCounted
	var now: int = 1700000000

	func read() -> int:
		return now


var _clock: FakeClock
var _file: String = ""
var _level_file: String = ""
var _save: SaveService


func before_each() -> void:
	_clock = FakeClock.new()
	_file = "user://zf_session_restore_%d.json" % Time.get_ticks_usec()
	_level_file = "user://zf_session_level_%d.json" % Time.get_ticks_usec()
	_save = SaveService.new(_file, Callable(_clock, "read"))


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak", _level_file]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


## Writes the level file this test's session reads: a copy of the good or the bad fixture with this id.
func _write_level(source: String, id: int) -> void:
	var text: String = FileAccess.get_file_as_string(source).replace("\"id\": 12,", "\"id\": %d," % id)
	var f: FileAccess = FileAccess.open(_level_file, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _notice(s: LevelSession) -> String:
	if not ("notice" in s):
		fail_test("LevelSession.notice is missing (API_CONTRACT.md 16.2)")
		return ""
	return String(s.get("notice"))


func _has_kind(board: BoardModel, kind: String) -> bool:
	for y in range(board.height):
		for x in range(board.width):
			if board.has_item(x, y) and board.get_kind(x, y) == kind:
				return true
	return false


func test_IR88_notice_is_the_exact_message_and_last_error_stays_technical() -> void:
	_save.debug_set({"next_level": 12})
	var s: LevelSession = LevelSession.new(BAD, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(_notice(s), MESSAGE)
	assert_ne(s.last_error, "")
	assert_ne(s.last_error, MESSAGE, "last_error keeps the technical text")


func test_IR88_notice_is_empty_before_any_start_and_after_a_good_start() -> void:
	_save.debug_set({"next_level": 12})
	var s: LevelSession = LevelSession.new(GOOD, _save)
	assert_eq(_notice(s), "")
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(_notice(s), "")


func test_IR88_notice_is_cleared_by_the_next_successful_start() -> void:
	_save.debug_set({"next_level": 12})
	_write_level(BAD, 12)
	var s: LevelSession = LevelSession.new(_level_file, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(_notice(s), MESSAGE)
	_write_level(GOOD, 12)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(_notice(s), "")


func test_IR88_other_refusals_do_not_show_the_build_message() -> void:
	_save.debug_set({"next_level": 12, "lives": 0})
	var s: LevelSession = LevelSession.new(GOOD, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(s.state, LevelSession.RETRY)
	assert_ne(_notice(s), MESSAGE, "the save refused, the board was never built")


func test_IR88_fresh_start_failure_goes_back_to_not_started() -> void:
	_save.debug_set({"next_level": 12, "lives": 5, "streak": 3, "coins": 1000})
	var s: LevelSession = LevelSession.new(BAD, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(s.state, LevelSession.NOT_STARTED, "the screen it started from")
	assert_eq(_notice(s), MESSAGE)


func test_IR88_failed_retry_goes_back_to_the_retry_screen() -> void:
	_save.debug_set({"next_level": 12, "lives": 5, "coins": 1000, "streak": 0})
	_write_level(GOOD, 12)
	var s: LevelSession = LevelSession.new(_level_file, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	# moves run out and the offer is declined: a fail, the retry screen
	s.attempt.board.moves = 0
	s.attempt.tracker.moves_ran_out(s.attempt.board)
	s.state = LevelSession.OFFER
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)
	assert_eq(_save.lives(), 4)
	assert_eq(_save.attempt_log().size(), 1)
	_write_level(BAD, 12)
	assert_false(s.retry({"seed": 8}))
	assert_eq(s.state, LevelSession.RETRY, "back on the screen the attempt was started from")
	assert_eq(_notice(s), MESSAGE)
	assert_eq(_save.lives(), 4, "no second life lost")
	assert_eq(_save.attempt_log().size(), 1, "no new entry")
	# the retry screen still works once the file is fixed
	_write_level(GOOD, 12)
	assert_true(s.retry({"seed": 9}), s.last_error)
	assert_eq(_notice(s), "")


func test_IR88_free_pre_level_booster_comes_back_after_a_failed_start() -> void:
	_save.debug_set({"next_level": 18, "coins": 500, "pre_unlocked": true,
		"pre_free": {"rocket_crane": 1, "firecracker": 1}})
	_write_level(BAD, 18)
	var s: LevelSession = LevelSession.new(_level_file, _save)
	assert_false(s.start({"seed": 7, "pre_boosters": ["firecracker"]}))
	assert_eq(s.state, LevelSession.NOT_STARTED)
	assert_eq(_save.pre_free_uses("firecracker"), 1)
	assert_eq(_save.coins(), 500)
	assert_eq(_notice(s), MESSAGE)


func test_IR88_paid_booster_coins_come_back_and_next_attempt_pays_again() -> void:
	_save.debug_set({"next_level": 18, "coins": 500, "pre_unlocked": true,
		"pre_free": {"rocket_crane": 0, "firecracker": 1}})
	_write_level(BAD, 18)
	var s: LevelSession = LevelSession.new(_level_file, _save)
	assert_false(s.start({"seed": 7, "pre_boosters": ["rocket_crane"]}))
	assert_eq(_save.coins(), 500)
	assert_eq(_save.pre_free_uses("rocket_crane"), 0)
	_write_level(GOOD, 18)
	assert_true(s.start({"seed": 7, "pre_boosters": ["rocket_crane"]}), s.last_error)
	assert_eq(_save.coins(), 350)


func test_IR88_chest_waits_again_and_is_placed_on_the_next_board_that_builds() -> void:
	_save.debug_set({"next_level": 22, "streak": 0, "chest_waiting": true})
	_write_level(BAD, 22)
	var s: LevelSession = LevelSession.new(_level_file, _save)
	assert_false(s.start({"seed": 7}))
	assert_true(_save.chest_waiting())
	assert_eq(_save.streak(), 0)
	_write_level(GOOD, 22)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_false(_save.chest_waiting(), "used up by the attempt that built")
	assert_true(_has_kind(s.attempt.board, "crane"), "the chest's Crane is on the board")
	assert_true(_has_kind(s.attempt.board, "rocket_row") or _has_kind(s.attempt.board, "rocket_col"),
		"and its Rocket")


func test_IR88_level_11_hero_booster_locked_again_then_unlocks_on_the_next_real_start() -> void:
	_save.debug_set({"next_level": 11, "coins": 500})
	_write_level(BAD, 11)
	var s: LevelSession = LevelSession.new(_level_file, _save)
	assert_false(s.start({"seed": 7}))
	assert_false(_save.hero_unlocked("hoof_tap"))
	assert_eq(_save.hero_free_uses("hoof_tap"), 0)
	_write_level(GOOD, 11)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_true(_save.hero_unlocked("hoof_tap"))
	assert_eq(_save.hero_free_uses("hoof_tap"), 3)
	assert_true(_save.use_hero_booster("hoof_tap"), "usable in that attempt")
