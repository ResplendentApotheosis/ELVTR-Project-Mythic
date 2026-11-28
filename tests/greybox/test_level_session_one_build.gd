# GUT tests: LevelSession builds the board ONCE, with the chest / pre-level specials already in (owner, 28 Nov 2026).
# The save decides the attempt first (no tracker), LevelLoader builds once, then the tracker is bound to the save.
# Rules touched: IR-77, IR-83, IR-84, IR-80, IR-81. API: tests/API_CONTRACT.md 12.2, 11.2 (build_count), 13.
# Check: run the GUT suite.
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")
const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const SPECIAL_KINDS: Array[String] = ["rocket_row", "rocket_col", "firecracker", "crane"]

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
	_file = "user://zf_session_onebuild_%d.json" % Time.get_ticks_usec()
	_save = SaveService.new(_file, Callable(_clock, "read"))
	_save.debug_set({"next_level": 12})


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


func _specials(board: BoardModel) -> Array[Vector2i]:
	return BB.find_kinds(board, SPECIAL_KINDS)


## The board LevelLoader builds for the fixture with these specials (resets the counter afterwards).
func _expected_grid(pre_specials: Array) -> Dictionary:
	var a: LevelAttempt = LevelLoader.load_file(FIXTURE, {"seed": 7, "pre_specials": pre_specials})
	return BoardSnapshot.piece_grid(a.board)


func test_plain_start_builds_the_board_once() -> void:
	LevelLoader.build_count = 0
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(LevelLoader.build_count, 1)


func test_IR84_waiting_chest_board_built_once_with_rocket_and_crane() -> void:
	_save.debug_set({"chest_waiting": true})
	var expected: Dictionary = _expected_grid(["rocket", "crane"])
	LevelLoader.build_count = 0
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(LevelLoader.build_count, 1, "one build, no second build with the specials")
	assert_eq(_specials(s.board()).size(), 2, "one Rocket and one Crane are on the board")
	assert_eq(BoardSnapshot.piece_grid(s.board()), expected, "same board as LevelLoader with pre_specials and the same seed")
	assert_false(_save.chest_waiting(), "the chest was used up")


func test_IR83_pre_level_booster_board_built_once_with_a_firecracker() -> void:
	_save.debug_set({"pre_unlocked": true, "pre_free": {"firecracker": 1, "rocket_crane": 0}, "coins": 500})
	var expected: Dictionary = _expected_grid(["firecracker"])
	LevelLoader.build_count = 0
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7, "pre_boosters": ["firecracker"]}), s.last_error)
	assert_eq(LevelLoader.build_count, 1)
	assert_eq(BB.find_kind(s.board(), "firecracker").size(), 1)
	assert_eq(BoardSnapshot.piece_grid(s.board()), expected)
	assert_eq(_save.coins(), 500, "a free use costs nothing")


func test_IR83_IR84_booster_and_chest_together_built_once() -> void:
	_save.debug_set({"chest_waiting": true, "pre_unlocked": true, "pre_free": {"firecracker": 0, "rocket_crane": 0}, "coins": 500})
	var expected: Dictionary = _expected_grid(["firecracker", "rocket", "crane"])
	LevelLoader.build_count = 0
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7, "pre_boosters": ["firecracker"]}), s.last_error)
	assert_eq(LevelLoader.build_count, 1)
	assert_eq(_specials(s.board()).size(), 3)
	assert_eq(BoardSnapshot.piece_grid(s.board()), expected)
	assert_eq(_save.coins(), 350, "the booster costs 150, the chest nothing")
	assert_eq(s.coins(), 350, "the tracker shows the coins after the payment")


func test_tracker_lives_and_coins_match_the_save_after_start() -> void:
	_save.debug_set({"lives": 3, "coins": 777})
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(s.attempt.tracker.lives, 3)
	assert_eq(s.attempt.tracker.coins, 777)
	assert_eq(s.lives(), 3)
	assert_eq(s.coins(), 777)


func test_tracker_is_the_one_the_board_uses() -> void:
	_save.debug_set({"chest_waiting": true})
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_same(s.board().goal_tracker, s.attempt.tracker)


func test_a_continue_after_a_chest_start_still_reaches_the_save() -> void:
	_save.debug_set({"chest_waiting": true, "coins": 1000})
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	s.attempt.board.moves = 0
	s.attempt.tracker.moves_ran_out(s.attempt.board)
	s.state = LevelSession.OFFER
	assert_true(s.accept_offer())
	assert_eq(SaveService.new(_file, Callable(_clock, "read")).coins(), 700, "IR-38")


func test_refused_start_builds_no_board_and_keeps_the_chest() -> void:
	_save.debug_set({"lives": 0, "chest_waiting": true})
	LevelLoader.build_count = 0
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(s.state, LevelSession.RETRY)
	assert_eq(LevelLoader.build_count, 0, "the save said no, so nothing is built")
	assert_true(_save.chest_waiting())
	assert_eq(s.level_id(), 12, "the retry screen still knows the level")


func test_refused_start_then_buy_lives_then_retry_works() -> void:
	_save.debug_set({"lives": 0, "coins": 500})
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_false(s.start({"seed": 7}))
	assert_eq(s.retry_choices(), ["wait", "buy_lives"])
	assert_true(bool(s.buy_lives().get("ok", false)))
	assert_true(s.retry({"seed": 8}), s.last_error)
	assert_eq(s.state, LevelSession.PLAYING)
	assert_eq(s.moves_left(), 26)


func test_retry_builds_once_too() -> void:
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_true(s.start({"seed": 7}), s.last_error)
	s.attempt.board.moves = 0
	s.attempt.tracker.moves_ran_out(s.attempt.board)
	s.state = LevelSession.OFFER
	s.decline_offer()
	LevelLoader.build_count = 0
	assert_true(s.retry({"seed": 9}), s.last_error)
	assert_eq(LevelLoader.build_count, 1)
	assert_eq(s.attempt.tracker.lives, _save.lives())
	assert_eq(s.attempt.tracker.coins, _save.coins())
