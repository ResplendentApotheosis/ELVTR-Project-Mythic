# GUT tests for the grey box's debug-only shortcuts (owner, 28 Nov 2026): jump-to-level, "Play again" and the
# debug "moves" override work ONLY when the debug gate is on (never in an exported release build). No game rule
# changes: lives, offers (IR-37), prices and coins behave as normal while the override is on.
# Rules touched (unchanged): IR-37, IR-60, IR-81. API: tests/API_CONTRACT.md section 13 (DebugGate, LevelSession debug_*).
# Check: run the GUT suite. OS.is_debug_build() itself is not tested.
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")
const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"

class FakeClock:
	extends RefCounted
	var now: int = 1700000000

	func read() -> int:
		return now


var _clock: FakeClock
var _file: String = ""
var _scratch: String = ""
var _save: SaveService


func before_each() -> void:
	_clock = FakeClock.new()
	_file = "user://zf_debuggate_save_%d.json" % Time.get_ticks_usec()
	_scratch = ""
	_save = SaveService.new(_file, Callable(_clock, "read"))
	_save.debug_set({"next_level": 12})


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak", _scratch]:
		if f != "" and FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


# ---------------------------------------------------------------- helpers

func _session(is_debug: bool) -> LevelSession:
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	s.debug_enabled = is_debug
	return s


func _arrange(s: LevelSession) -> Array[Vector2i]:
	var b: BoardModel = s.board()
	var moves: int = b.moves
	for y in range(b.height):
		for x in range(b.width):
			if b.is_playable(x, y) and b.get_content(x, y) == null:
				b.set_piece(x, y, "plain", BB.filler_color(x, y))
	b.set_piece(5, 7, "plain", "R")
	b.set_piece(6, 7, "plain", "R")
	b.set_piece(7, 8, "plain", "R")
	b.auto_shuffle = false
	b.moves = moves
	return [Vector2i(7, 7), Vector2i(7, 8)] as Array[Vector2i]


## One valid, non-winning swap (keeps the moves the board has, then uses one).
func _spend_move(s: LevelSession) -> Array[BoardEvent]:
	var sw: Array[Vector2i] = _arrange(s)
	return s.swap(sw[0], sw[1])


func _fail_and_decline(s: LevelSession) -> void:
	_spend_move(s)
	assert_eq(s.state, LevelSession.OFFER)
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)


func _bramble_level() -> String:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	d["objects"] = [{"type": "OB02", "x": 5, "y": 6, "hp": 1}]
	d["goals"] = [{"obstacle": "OB02", "count": 1}]
	_scratch = "user://zf_debuggate_level_%d.json" % Time.get_ticks_usec()
	var f: FileAccess = FileAccess.open(_scratch, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()
	return _scratch


# ---------------------------------------------------------------- the gate itself

func test_gate_follows_the_flag() -> void:
	assert_true(DebugGate.enabled(true))
	assert_false(DebugGate.enabled(false))


func test_session_gate_starts_from_the_gate_default() -> void:
	var s: LevelSession = LevelSession.new(FIXTURE, _save)
	assert_eq(s.debug_enabled, DebugGate.enabled(), "default = DebugGate.enabled() with its default flag")


# ---------------------------------------------------------------- jump to level

func test_jump_to_level_works_with_the_gate_on() -> void:
	var s: LevelSession = _session(true)
	assert_true(s.debug_jump_to_level(30))
	assert_eq(_save.next_level(), 30)


func test_jump_to_level_does_nothing_with_the_gate_off() -> void:
	var s: LevelSession = _session(false)
	assert_false(s.debug_jump_to_level(30))
	assert_eq(_save.next_level(), 12, "save untouched")
	assert_eq(SaveService.new(_file, Callable(_clock, "read")).next_level(), 12, "and nothing written")


func test_jump_to_level_refuses_a_level_outside_1_to_50() -> void:
	var s: LevelSession = _session(true)
	assert_false(s.debug_jump_to_level(0))
	assert_false(s.debug_jump_to_level(51))
	assert_eq(_save.next_level(), 12)


# ---------------------------------------------------------------- Play again

func test_play_again_after_a_win_replays_the_level_with_the_gate_on() -> void:
	var s: LevelSession = LevelSession.new(_bramble_level(), _save)
	s.debug_enabled = true
	assert_true(s.start({"seed": 7}), s.last_error)
	var sw: Array[Vector2i] = _arrange(s)
	s.swap(sw[0], sw[1])
	assert_eq(s.state, LevelSession.WON)
	assert_eq(_save.next_level(), 13)
	assert_true(s.debug_play_again({"seed": 8}), s.last_error)
	assert_eq(s.state, LevelSession.PLAYING)
	assert_eq(s.level_id(), 12)
	assert_eq(_save.next_level(), 12, "the grey-box save was moved back to the level")


func test_play_again_does_nothing_with_the_gate_off() -> void:
	var s: LevelSession = LevelSession.new(_bramble_level(), _save)
	s.debug_enabled = true
	assert_true(s.start({"seed": 7}), s.last_error)
	var sw: Array[Vector2i] = _arrange(s)
	s.swap(sw[0], sw[1])
	assert_eq(s.state, LevelSession.WON)
	s.debug_enabled = false
	assert_false(s.debug_play_again({"seed": 8}))
	assert_eq(s.state, LevelSession.WON, "still on the win screen")
	assert_eq(_save.next_level(), 13, "next_level unchanged")
	assert_eq(SaveService.new(_file, Callable(_clock, "read")).next_level(), 13, "save untouched")


func test_normal_start_does_not_need_the_gate() -> void:
	var s: LevelSession = _session(false)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(s.moves_left(), 26)


# ---------------------------------------------------------------- debug moves

func test_debug_moves_off_by_default() -> void:
	var s: LevelSession = _session(true)
	assert_eq(s.debug_moves, 0)
	assert_true(s.start({"seed": 7}))
	assert_eq(s.moves_left(), 26)


func test_debug_moves_one_next_start_has_one_move_then_fail_offer_300() -> void:
	_save.debug_set({"coins": 1000, "lives": 5})
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}), s.last_error)
	assert_eq(s.moves_left(), 1)
	var ev: Array[BoardEvent] = _spend_move(s)
	assert_eq(ev.back().type, "fail")
	assert_eq(s.state, LevelSession.OFFER)
	assert_eq(s.offer_price(), 300)


func test_debug_moves_does_not_touch_continues_accept_adds_5() -> void:
	_save.debug_set({"coins": 1000, "lives": 5})
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	_spend_move(s)
	assert_true(s.accept_offer())
	assert_eq(s.moves_left(), 5, "IR-37: +5, not the override")
	assert_eq(s.coins(), 700)
	assert_eq(_save.coins(), 700)


func test_debug_moves_all_five_offers_then_retry_screen() -> void:
	_save.debug_set({"coins": 3000, "lives": 5})
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	var prices: Array = [300, 500, 500, 500, 500]
	for i in range(5):
		s.board().moves = 1   # a continue gave +5; run the board down to its last move
		_spend_move(s)
		assert_eq(s.state, LevelSession.OFFER, "offer %d" % (i + 1))
		assert_eq(s.offer_price(), prices[i])
		assert_true(s.accept_offer())
		assert_eq(s.moves_left(), 5)
	s.board().moves = 1
	_spend_move(s)
	assert_eq(s.state, LevelSession.RETRY, "IR-37: no sixth offer")
	assert_eq(s.coins(), 700)
	assert_eq(s.lives(), 4, "IR-60: one life for the whole attempt")


func test_debug_moves_declined_offer_costs_one_life_IR60() -> void:
	_save.debug_set({"coins": 1000, "lives": 5})
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	_fail_and_decline(s)
	assert_eq(s.lives(), 4)
	assert_eq(s.coins(), 1000)


func test_debug_moves_persist_across_retries_until_cleared() -> void:
	_save.debug_set({"coins": 1000, "lives": 5})
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	_fail_and_decline(s)
	assert_true(s.retry({"seed": 8}), s.last_error)
	assert_eq(s.moves_left(), 1, "first retry")
	_fail_and_decline(s)
	assert_true(s.retry({"seed": 9}), s.last_error)
	assert_eq(s.moves_left(), 1, "second retry")
	_fail_and_decline(s)
	s.set_debug_moves(0)
	assert_true(s.retry({"seed": 10}), s.last_error)
	assert_eq(s.moves_left(), 26, "cleared: the file's moves again")


func test_debug_moves_set_during_an_attempt_applies_to_the_next_one() -> void:
	_save.debug_set({"coins": 1000, "lives": 5})
	var s: LevelSession = _session(true)
	assert_true(s.start({"seed": 7}))
	s.set_debug_moves(2)
	assert_eq(s.moves_left(), 26, "the running attempt is not changed")
	s.attempt.board.moves = 0
	s.attempt.tracker.moves_ran_out(s.attempt.board)
	s.state = LevelSession.OFFER
	s.decline_offer()
	assert_true(s.retry({"seed": 8}))
	assert_eq(s.moves_left(), 2)


func test_debug_moves_negative_means_off() -> void:
	var s: LevelSession = _session(true)
	s.set_debug_moves(-3)
	assert_true(s.start({"seed": 7}))
	assert_eq(s.moves_left(), 26)
	assert_eq(s.debug_moves, 0, "a negative value is stored as off")


func test_debug_moves_ignored_with_the_gate_off() -> void:
	var s: LevelSession = _session(false)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	assert_eq(s.moves_left(), 26, "file moves are used")
	s.attempt.board.moves = 0
	s.attempt.tracker.moves_ran_out(s.attempt.board)
	s.state = LevelSession.OFFER
	s.decline_offer()
	assert_true(s.retry({"seed": 8}))
	assert_eq(s.moves_left(), 26, "also on retry")


func test_debug_moves_gate_checked_when_the_attempt_starts() -> void:
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	s.debug_enabled = false
	assert_true(s.start({"seed": 7}))
	assert_eq(s.moves_left(), 26)


func test_debug_moves_zero_lives_screen_after_the_last_life() -> void:
	_save.debug_set({"coins": 1000, "lives": 1})
	var s: LevelSession = _session(true)
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	_fail_and_decline(s)
	assert_eq(s.lives(), 0)
	assert_eq(s.retry_choices(), ["wait", "buy_lives"])
	assert_false(s.retry(), "IR-81: no retry at 0 lives, the override does not help")


func test_debug_moves_a_win_with_override_pays_as_normal() -> void:
	var s: LevelSession = LevelSession.new(_bramble_level(), _save)
	s.debug_enabled = true
	s.set_debug_moves(1)
	assert_true(s.start({"seed": 7}))
	var sw: Array[Vector2i] = _arrange(s)
	s.swap(sw[0], sw[1])
	assert_eq(s.state, LevelSession.WON, "finishing the goal on the last move is a win")
	assert_eq(s.win_coins, 20)
	assert_eq(_save.lives(), 5)
