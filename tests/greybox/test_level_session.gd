# GUT tests for LevelSession (the glue that plays one level using the real loader, resolver, tracker and save).
# Checked against the spec: IR-37 (offers), IR-56 (win), IR-57 (fail), IR-58/IR-71 (retry), IR-60 (lives), IR-80 (coins),
# IR-81 (retry choices). API: tests/API_CONTRACT.md section 13. Check: run the GUT suite.
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")
const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const T0: int = 1700000000

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
	_file = "user://zf_session_save_%d.json" % Time.get_ticks_usec()
	_scratch = ""
	_save = SaveService.new(_file, Callable(_clock, "read"))
	_save.debug_set({"next_level": 12})


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak", _scratch]:
		if f != "" and FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


# ---------------------------------------------------------------- helpers

func _session(path: String = FIXTURE) -> LevelSession:
	return LevelSession.new(path, _save)


func _started(coins: int = 500, lives: int = 5) -> LevelSession:
	_save.debug_set({"coins": coins, "lives": lives})
	var s: LevelSession = _session()
	assert_true(s.start({"seed": 7}), "start works: " + s.last_error)
	return s


## A scratch copy of the fixture with one bramble (OB02, hp 1) at (5,6) as the only goal.
func _bramble_level() -> String:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	d["objects"] = [{"type": "OB02", "x": 5, "y": 6, "hp": 1}]
	d["goals"] = [{"obstacle": "OB02", "count": 1}]
	_scratch = "user://zf_session_level_%d.json" % Time.get_ticks_usec()
	var f: FileAccess = FileAccess.open(_scratch, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()
	return _scratch


## Fills every free cell with a unique filler and sets up one move: swap (7,7)<->(7,8) makes R R R in row 7
## at x 5..7 (touching the bramble at (5,6)). Returns the swap.
func _arrange(s: LevelSession, moves: int) -> Array[Vector2i]:
	var b: BoardModel = s.board()
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


func _spend_move(s: LevelSession, moves: int = 1) -> Array[BoardEvent]:
	var sw: Array[Vector2i] = _arrange(s, moves)
	return s.swap(sw[0], sw[1])


func _type_index(events: Array[BoardEvent], type: String) -> int:
	for i in range(events.size()):
		if events[i].type == type:
			return i
	return -1


# ---------------------------------------------------------------- starting

func test_start_builds_attempt_and_hud() -> void:
	var s: LevelSession = _started()
	assert_eq(s.state, LevelSession.PLAYING)
	assert_eq(s.level_id(), 12)
	assert_eq(s.moves_left(), 26)
	assert_eq(s.coins(), 500, "IR-80 new save starts with 500")
	assert_eq(s.lives(), 5)
	var rows: Array[Dictionary] = s.goal_rows()
	assert_eq(rows.size(), 2)
	assert_eq(rows[0].id, "OB06")
	assert_eq(rows[0].total, 1)
	assert_eq(rows[0].done, 0)
	assert_eq(rows[1].id, "OB02")
	assert_false(rows[0].fragment)


func test_start_missing_file_fails() -> void:
	var s: LevelSession = _session("res://does_not_exist.json")
	assert_false(s.start())
	assert_eq(s.state, LevelSession.NOT_STARTED)
	assert_ne(s.last_error, "")


func test_cannot_start_twice_while_playing() -> void:
	var s: LevelSession = _started()
	assert_false(s.start())
	assert_eq(s.state, LevelSession.PLAYING)


func test_IR81_start_refused_at_zero_lives() -> void:
	_save.debug_set({"lives": 0})
	var s: LevelSession = _session()
	assert_false(s.start())
	assert_eq(s.state, LevelSession.RETRY)
	assert_ne(s.last_error, "")


func test_IR02_tap_on_non_special_uses_no_move() -> void:
	var s: LevelSession = _started()
	_arrange(s, 5)
	var ev: Array[BoardEvent] = s.tap(Vector2i(3, 3))
	assert_eq(ev.size(), 0)
	assert_eq(s.moves_left(), 5)
	assert_eq(s.state, LevelSession.PLAYING)


# ---------------------------------------------------------------- IR-57 fail and IR-37 offers

func test_IR57_last_move_with_goal_open_is_fail_and_offer_300() -> void:
	var s: LevelSession = _started(500)
	var ev: Array[BoardEvent] = _spend_move(s)
	assert_gt(ev.size(), 0, "the swap was a valid move")
	assert_eq(ev.back().type, "fail")
	assert_eq(s.moves_left(), 0)
	assert_eq(s.state, LevelSession.OFFER)
	assert_eq(s.offer_price(), 300)
	assert_eq(s.offer_message(), "", "500 coins can pay 300")
	assert_true(s.can_accept_offer())


func test_IR57_no_fail_while_moves_remain() -> void:
	var s: LevelSession = _started()
	var ev: Array[BoardEvent] = _spend_move(s, 2)
	assert_eq(_type_index(ev, "fail"), -1)
	assert_eq(s.state, LevelSession.PLAYING)
	assert_eq(s.moves_left(), 1)


func test_IR37_no_moves_while_offer_is_up() -> void:
	var s: LevelSession = _started()
	_spend_move(s)
	var sw: Array[Vector2i] = _arrange(s, 0)
	assert_eq(s.swap(sw[0], sw[1]).size(), 0)
	assert_eq(s.tap(Vector2i(0, 0)).size(), 0)


func test_IR37_five_offers_300_then_500_then_none_on_sixth() -> void:
	var s: LevelSession = _started(3000)
	var prices: Array = [300, 500, 500, 500, 500]
	var coins_after: Array = [2700, 2200, 1700, 1200, 700]
	for i in range(5):
		_spend_move(s)
		assert_eq(s.state, LevelSession.OFFER, "offer %d shown" % (i + 1))
		assert_eq(s.offer_price(), prices[i])
		assert_true(s.accept_offer())
		assert_eq(s.coins(), coins_after[i])
		assert_eq(s.moves_left(), 5, "accepting gives +5 moves")
		assert_eq(s.state, LevelSession.PLAYING)
	_spend_move(s)
	assert_eq(s.state, LevelSession.RETRY, "6th run-out: no offer, retry screen")
	assert_eq(s.offer_price(), 0)
	assert_eq(s.coins(), 700)
	assert_eq(_save.coins(), 700)


func test_IR37_decline_goes_to_retry_coins_unchanged() -> void:
	var s: LevelSession = _started(1000)
	_spend_move(s)
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)
	assert_eq(s.coins(), 1000)
	assert_eq(_save.coins(), 1000)
	assert_eq(s.moves_left(), 0, "no moves added")
	assert_false(s.accept_offer(), "no second offer for this fail")


func test_IR37_250_coins_message_and_cannot_accept() -> void:
	var s: LevelSession = _started(250)
	_spend_move(s)
	assert_eq(s.state, LevelSession.OFFER, "offer still shown")
	assert_eq(s.offer_message(), "you have less than 300 coins")
	assert_false(s.can_accept_offer())
	assert_false(s.accept_offer())
	assert_eq(s.coins(), 250)
	assert_eq(s.moves_left(), 0)
	assert_eq(s.state, LevelSession.OFFER)
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)


func test_IR37_exactly_300_can_accept() -> void:
	var s: LevelSession = _started(300)
	_spend_move(s)
	assert_true(s.can_accept_offer())
	assert_eq(s.offer_message(), "")
	assert_true(s.accept_offer())
	assert_eq(s.coins(), 0)
	assert_eq(s.moves_left(), 5)


func test_IR37_700_coins_second_offer_message_names_500() -> void:
	var s: LevelSession = _started(700)
	_spend_move(s)
	assert_true(s.accept_offer())
	assert_eq(s.coins(), 400)
	_spend_move(s)
	assert_eq(s.offer_price(), 500)
	assert_eq(s.offer_message(), "you have less than 500 coins")
	assert_false(s.can_accept_offer())
	assert_false(s.accept_offer())
	assert_eq(s.coins(), 400)
	assert_eq(s.moves_left(), 0)
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)
	assert_eq(s.coins(), 400)


func test_IR37_800_coins_second_offer_acceptable_down_to_zero() -> void:
	var s: LevelSession = _started(800)
	_spend_move(s)
	assert_true(s.accept_offer())
	assert_eq(s.coins(), 500)
	_spend_move(s)
	assert_true(s.accept_offer())
	assert_eq(s.coins(), 0)
	assert_eq(s.moves_left(), 5)


func test_IR38_IR80_accepted_offer_coins_are_in_the_save_at_once() -> void:
	var s: LevelSession = _started(1000)
	_spend_move(s)
	assert_true(s.accept_offer())
	var reopened: SaveService = SaveService.new(_file, Callable(_clock, "read"))
	assert_eq(reopened.coins(), 700, "written when the offer was paid")


# ---------------------------------------------------------------- IR-60 lives

func test_IR60_declined_offer_costs_one_life() -> void:
	var s: LevelSession = _started(1000, 5)
	_spend_move(s)
	assert_eq(s.lives(), 5, "offer on screen: no life lost yet")
	s.decline_offer()
	assert_eq(s.lives(), 4)


func test_IR60_sixth_run_out_costs_one_life_only() -> void:
	var s: LevelSession = _started(3000, 5)
	for i in range(5):
		_spend_move(s)
		assert_true(s.accept_offer())
		assert_eq(s.lives(), 5, "accepting costs no life")
	_spend_move(s)
	assert_eq(s.lives(), 4)


# ---------------------------------------------------------------- IR-56 win

func test_IR56_win_after_settle_then_finale_then_save() -> void:
	var s: LevelSession = _session(_bramble_level())
	_save.debug_set({"coins": 500, "lives": 5})
	assert_true(s.start({"seed": 7}), s.last_error)
	var ev: Array[BoardEvent] = _spend_move(s, 3)
	var w: int = _type_index(ev, "win")
	assert_gt(w, -1, "a win event")
	assert_eq(_type_index(ev, "fail"), -1)
	assert_eq(s.state, LevelSession.WON)
	assert_eq(s.finale_rockets, 2, "moves left become finale Rockets (IR-16)")
	assert_eq(s.win_coins, 30, "20 + 5 x 2")
	# the win comes after the move's own events and before the finale's
	for i in range(ev.size()):
		if ev[i].type == "special_created" and bool(ev[i].data.get("finale", false)):
			assert_gt(i, w, "finale Rocket comes after the win event")
	var rockets: int = 0
	for e in ev:
		if e.type == "special_created" and bool(e.data.get("finale", false)):
			rockets += 1
	assert_eq(rockets, 2)
	# the save
	assert_eq(_save.coins(), 530, "IR-80: win adds 20 + 5 per Rocket")
	assert_eq(_save.next_level(), 13, "IR-79 progress")
	assert_eq(_save.lives(), 5, "a win costs no life")
	assert_eq(s.coins(), 530)


func test_IR56_win_on_last_move_has_no_finale_rockets() -> void:
	var s: LevelSession = _session(_bramble_level())
	assert_true(s.start({"seed": 7}), s.last_error)
	var ev: Array[BoardEvent] = _spend_move(s, 1)
	assert_gt(_type_index(ev, "win"), -1)
	assert_eq(_type_index(ev, "fail"), -1, "finishing the goals on the last move is a win, not a fail")
	assert_eq(s.state, LevelSession.WON)
	assert_eq(s.finale_rockets, 0)
	assert_eq(s.win_coins, 20)
	assert_eq(_save.coins(), 520)


func test_IR56_nothing_moves_after_a_win() -> void:
	var s: LevelSession = _session(_bramble_level())
	assert_true(s.start({"seed": 7}))
	_spend_move(s, 1)
	var sw: Array[Vector2i] = _arrange(s, 5)
	assert_eq(s.swap(sw[0], sw[1]).size(), 0)
	assert_eq(s.state, LevelSession.WON)


func test_IR60_win_after_continue_costs_no_life() -> void:
	var s: LevelSession = _session(_bramble_level())
	_save.debug_set({"coins": 1000, "lives": 5})
	assert_true(s.start({"seed": 7}))
	# run out with no match touching the bramble: a swap that makes a match far from it
	var b: BoardModel = s.board()
	b.moves = 0
	s.attempt.tracker.moves_ran_out(b)
	s.state = LevelSession.OFFER
	assert_true(s.accept_offer())
	_spend_move(s, 5)
	assert_eq(s.state, LevelSession.WON)
	assert_eq(_save.lives(), 5)
	assert_eq(_save.coins(), 1000 - 300 + 20 + 5 * 4)


# ---------------------------------------------------------------- IR-58 / IR-71 retry

func test_retry_only_from_retry_screen() -> void:
	var s: LevelSession = _started()
	assert_false(s.retry())
	assert_eq(s.state, LevelSession.PLAYING)


func test_IR58_retry_resets_moves_goals_and_offer_counter() -> void:
	var s: LevelSession = _started(3000, 5)
	_spend_move(s)
	assert_true(s.accept_offer())    # offer counter now 1 (next would cost 500)
	_spend_move(s)
	assert_eq(s.offer_price(), 500)
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)
	assert_eq(s.lives(), 4)
	assert_true(s.retry({"seed": 99}), s.last_error)
	assert_eq(s.state, LevelSession.PLAYING)
	assert_eq(s.moves_left(), 26, "moves reset")
	assert_eq(s.goal_rows()[1].done, 0, "goals reset")
	assert_eq(s.coins(), 3000 - 300, "coins carry over, not reset")
	assert_eq(s.lives(), 4, "lives carry over, not reset")
	_spend_move(s)
	assert_eq(s.offer_price(), 300, "offer counter reset: first offer again")


func test_IR58_retry_gets_a_new_seed() -> void:
	var s: LevelSession = _started(1000)
	var first_seed: int = s.attempt.seed_value
	_spend_move(s)
	s.decline_offer()
	assert_true(s.retry())
	assert_ne(s.attempt.seed_value, first_seed, "IR-72 new seed")


func test_IR81_retry_choices_with_lives_and_without() -> void:
	var s: LevelSession = _started(1000, 5)
	_spend_move(s)
	s.decline_offer()
	assert_eq(s.retry_choices(), ["retry"])
	_save.debug_set({"lives": 1})
	assert_true(s.retry())
	_spend_move(s)
	s.decline_offer()
	assert_eq(s.lives(), 0)
	assert_eq(s.retry_choices(), ["wait", "buy_lives"])
	assert_false(s.retry(), "no retry at 0 lives")


func test_IR81_IR80_buy_lives_150_coins() -> void:
	var s: LevelSession = _started(1000, 1)
	_spend_move(s)
	s.decline_offer()
	var r: Dictionary = s.buy_lives()
	assert_true(r.ok)
	assert_eq(s.lives(), 5)
	assert_eq(s.coins(), 850)
	assert_true(s.retry())


func test_IR80_buy_lives_refused_without_coins() -> void:
	var s: LevelSession = _started(100, 1)
	_spend_move(s)
	s.decline_offer()
	assert_eq(s.lives(), 0)
	var r: Dictionary = s.buy_lives()
	assert_false(r.ok)
	assert_eq(s.coins(), 100)
	assert_eq(s.lives(), 0)


func test_IR81_buy_lives_refused_at_five() -> void:
	var s: LevelSession = _started(1000, 5)
	var r: Dictionary = s.buy_lives()
	assert_false(r.ok)
	assert_eq(s.coins(), 1000)
