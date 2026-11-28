# GUT tests for SaveService.cancel_attempt (IR-88): a cancelled attempt costs nothing and leaves no trace.
# Not tested (OQ-97 open): pre-level booster / chest refund, hero unlocks, the screen after. API: API_CONTRACT.md 15.1.
# Check: run the GUT suite; this file shows pass/fail per rule.
extends GutTest

const GOALS: Array = [{"obstacle": "OB06", "count": 1}]

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
	_file = "user://zf_cancel_save_%d.json" % Time.get_ticks_usec()
	_save = _open()
	_save.debug_set({"next_level": 12, "lives": 5, "streak": 3, "coins": 1000})


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


func _open() -> SaveService:
	return SaveService.new(_file, Callable(_clock, "read"))


func _start(level: int = 12) -> Dictionary:
	return _save.start_attempt(level, GoalTracker.new(GOALS, level))


func test_IR88_cancel_costs_nothing() -> void:
	assert_true(bool(_start().get("ok", false)))
	_cancel()
	assert_eq(_save.lives(), 5, "no life lost")
	assert_eq(_save.streak(), 3, "streak unchanged")
	assert_eq(_save.coins(), 1000)
	assert_eq(_save.next_level(), 12)
	assert_eq(_save.attempt_log().size(), 0, "no attempt-log entry")
	assert_eq(_save.life_log().size(), 0)


func test_IR88_cancelled_level_is_not_tried_so_next_start_is_first_try() -> void:
	assert_true(bool(_start().get("first_try", false)))
	_cancel()
	var r: Dictionary = _start()
	assert_true(bool(r.get("ok", false)), "can start again at once")
	assert_true(bool(r.get("first_try", false)), "still the first try")


func test_IR88_open_attempt_is_cleared() -> void:
	_start()
	_cancel()
	_save.end_attempt("quit")   # nothing is open, so this does nothing
	assert_eq(_save.lives(), 5)
	assert_eq(_save.attempt_log().size(), 0)


func test_IR88_next_launch_does_not_treat_it_as_a_killed_attempt() -> void:
	_start()
	_cancel()
	var again: SaveService = _open()
	assert_eq(again.lives(), 5, "IR-38 recovery does not fire")
	assert_eq(again.streak(), 3)
	assert_eq(again.attempt_log().size(), 0)
	assert_true(bool(again.start_attempt(12, GoalTracker.new(GOALS, 12)).get("first_try", false)))


func test_IR88_cancel_with_no_open_attempt_is_a_no_op() -> void:
	_cancel()
	assert_eq(_save.lives(), 5)
	assert_eq(_save.attempt_log().size(), 0)
	assert_eq(_save.streak(), 3)


func test_IR88_cancel_works_for_a_start_with_no_tracker_yet() -> void:
	var r: Dictionary = _save.start_attempt(12, null, [])
	assert_true(bool(r.get("ok", false)))
	_cancel()
	assert_eq(_save.lives(), 5)
	assert_eq(_save.attempt_log().size(), 0)
	assert_true(bool(_save.start_attempt(12, null, []).get("first_try", false)))


func test_IR88_cancel_at_one_life_does_not_log_lives_ran_out() -> void:
	_save.debug_set({"lives": 1})
	_start()
	_cancel()
	assert_eq(_save.lives(), 1)
	assert_eq(_save.life_log().size(), 0, "no lives_ran_out")
	assert_true(_save.can_start(12))


func test_IR88_cancel_leaves_earlier_log_entries_and_try_marks_alone() -> void:
	_start()
	_save.end_attempt("quit")   # level 12 tried once, life 4
	assert_eq(_save.lives(), 4)
	var r: Dictionary = _start()
	assert_false(bool(r.get("first_try", true)), "second start is not a first try")
	_cancel()
	assert_eq(_save.lives(), 4)
	assert_eq(_save.attempt_log().size(), 1, "only the quit")
	assert_false(bool(_start().get("first_try", true)), "still tried")


func test_IR88_after_a_cancel_the_next_attempt_is_logged_as_first_try_win_and_streak_grows() -> void:
	_start()
	_cancel()
	_start()
	_save.end_attempt("win", 0)
	var entries: Array = _save.attempt_log()
	assert_eq(entries.size(), 1)
	var e: Dictionary = entries[0]
	assert_eq(int(e.get("level", 0)), 12)
	assert_true(bool(e.get("won", false)))
	assert_false(bool(e.get("quit", true)))
	assert_true(bool(e.get("first_try", false)))
	assert_eq(_save.streak(), 4)


## Calls cancel_attempt by name so a missing method FAILS a test instead of breaking the whole file.
func _cancel() -> void:
	if not _save.has_method("cancel_attempt"):
		fail_test("SaveService.cancel_attempt() is missing (API_CONTRACT.md 15.1)")
		return
	_save.call("cancel_attempt")
