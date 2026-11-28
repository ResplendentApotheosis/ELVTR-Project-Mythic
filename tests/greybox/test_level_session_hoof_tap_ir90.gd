# GUT tests for IR-90 (using Hoof Tap in a level) through LevelSession, with Option A of OQ-102..OQ-106 (provisional).
# Case labels T1..T16 follow the order of the "Test cases" bullets in spec/interaction_rules.md IR-90.
# API wanted from LevelSession: tests/API_CONTRACT.md section 17. Check: run the GUT suite.
extends GutTest

const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const BAD: String = "res://tests/greybox/fixtures/level_fixture_bad_012.json"
const BB = preload("res://tests/helpers/board_builder.gd")
const API: Array[String] = [
	"hero_booster_state", "arm_hero_booster", "cancel_hero_booster", "armed_hero_booster",
	"use_hero_booster", "set_busy",
]
const CELL: Vector2i = Vector2i(3, 3)

class FakeClock:
	extends RefCounted
	var now: int = 1700000000

	func read() -> int:
		return now


var _clock: FakeClock
var _file: String = ""
var _scratch: Array[String] = []
var _save: SaveService


func before_each() -> void:
	_clock = FakeClock.new()
	_file = "user://zf_hoof_save_%d.json" % Time.get_ticks_usec()
	_scratch = []
	_save = SaveService.new(_file, Callable(_clock, "read"))
	_save.debug_set({"next_level": 12})


func after_each() -> void:
	var files: Array[String] = [_file, _file + ".tmp", _file + ".bak"]
	files.append_array(_scratch)
	for f in files:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


# ---------------------------------------------------------------- helpers

## A scratch copy of the fixture with its own id, moves, objects and goals.
func _level_file(id: int, moves: int = 26, objects: Array = [], goals: Array = []) -> String:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	d["id"] = id
	d["moves"] = moves
	if not objects.is_empty():
		d["objects"] = objects
		d["goals"] = goals
	var path: String = "user://zf_hoof_level_%d_%d.json" % [id, Time.get_ticks_usec()]
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()
	_scratch.append(path)
	return path


## Hoof Tap unlocked on the save with `free` free uses and `coins` coins (level 12 next), then a session.
func _hoof_save(coins: int, free: int) -> void:
	_save.debug_set({"next_level": 12, "coins": coins, "lives": 5, "hero_unlocked": ["hoof_tap"], "hero_free": {"hoof_tap": free}})


## A started level-12 session (fixture board, 26 moves) with every free cell a unique filler: nothing can match.
func _playing(coins: int, free: int, path: String = FIXTURE) -> Variant:
	_hoof_save(coins, free)
	var s: Variant = LevelSession.new(path, _save)
	assert_true(s.start({"seed": 7}), "start works: " + s.last_error)
	if not _api_ok(s):
		return null
	_freeze(s)
	return s


func _api_ok(s: Variant) -> bool:
	var missing: Array[String] = []
	for m in API:
		if not s.has_method(m):
			missing.append(m)
	assert_true(missing.is_empty(), "LevelSession lacks (API_CONTRACT 17): %s" % str(missing))
	return missing.is_empty()


func _freeze(s: LevelSession) -> void:
	var b: BoardModel = s.board()
	for y in range(b.height):
		for x in range(b.width):
			if b.is_playable(x, y) and b.get_content(x, y) == null:
				b.set_piece(x, y, "plain", BB.filler_color(x, y))
	b.auto_shuffle = false


func _snap(s: LevelSession) -> String:
	return str(BoardSnapshot.piece_grid(s.board())) + str(BoardSnapshot.obstacle_grid(s.board()))


func _type_index(events: Array, type: String) -> int:
	for i in range(events.size()):
		if (events[i] as BoardEvent).type == type:
			return i
	return -1


## Uses Hoof Tap on a cell: arms (asserting it armed), then taps. Returns the result Dictionary.
func _arm_and_use(s: Variant, cell: Vector2i = CELL) -> Dictionary:
	assert_true(s.arm_hero_booster("hoof_tap"), "armed")
	return s.use_hero_booster(cell)


## Moves 1 and a swap that makes a match but no win: the last move, so the continue offer shows (as test_level_session.gd).
func _spend_last_move(s: LevelSession) -> void:
	var b: BoardModel = s.board()
	b.set_piece(5, 7, "plain", "R")
	b.set_piece(6, 7, "plain", "R")
	b.set_piece(7, 8, "plain", "R")
	b.moves = 1
	s.swap(Vector2i(7, 7), Vector2i(7, 8))


func _creature_level() -> String:
	return _level_file(12, 10, [{"type": "OB07", "x": 4, "y": 4, "hp": 1}], [{"obstacle": "OB07", "count": 1}])


# ---------------------------------------------------------------- (a) the button: locked, free uses, price

func test_IR90_T1_locked_before_level_11_is_started() -> void:
	_save.debug_set({"next_level": 10, "coins": 500, "lives": 5})
	var s: Variant = LevelSession.new(_level_file(10), _save)
	if not _api_ok(s):
		return
	assert_true(s.start({"seed": 7}), s.last_error)
	var st: Dictionary = s.hero_booster_state("hoof_tap")
	assert_false(bool(st.get("unlocked", true)), "locked")
	assert_eq(int(st.get("free_uses", -1)), 0, "free uses 0 (locked)")
	assert_false(bool(st.get("usable", true)))
	assert_false(s.arm_hero_booster("hoof_tap"), "tapping a locked button arms nothing")
	assert_eq(s.armed_hero_booster(), "")
	assert_false(bool(s.hero_booster_state("hoof_tap").get("armed", true)))


func test_IR90_T1_level_11_first_attempt_unlocks_with_3_free_uses() -> void:
	_save.debug_set({"next_level": 11, "coins": 500, "lives": 5})
	var s: Variant = LevelSession.new(_level_file(11), _save)
	if not _api_ok(s):
		return
	assert_false(bool(s.hero_booster_state("hoof_tap").get("unlocked", true)), "locked before the start")
	assert_true(s.start({"seed": 7}), s.last_error)
	var st: Dictionary = s.hero_booster_state("hoof_tap")
	assert_true(bool(st.get("unlocked", false)))
	assert_eq(int(st.get("free_uses", -1)), 3)
	assert_eq(int(st.get("price", -1)), 100)
	assert_false(bool(st.get("armed", true)))
	assert_true(bool(st.get("usable", false)), "usable while playing")


func test_IR90_T1_cancelled_start_locks_it_again() -> void:
	_save.debug_set({"next_level": 12, "coins": 500, "lives": 5})
	var s: Variant = LevelSession.new(BAD, _save)
	if not _api_ok(s):
		return
	assert_false(s.start({"seed": 7}), "the board fails to build (IR-88)")
	var st: Dictionary = s.hero_booster_state("hoof_tap")
	assert_false(bool(st.get("unlocked", true)), "locked again")
	assert_eq(int(st.get("free_uses", -1)), 0, "3 free uses not given")


func test_IR90_T2_price_shows_when_no_free_uses_are_left() -> void:
	var s: Variant = _playing(500, 0)
	if s == null:
		return
	var st: Dictionary = s.hero_booster_state("hoof_tap")
	assert_true(bool(st.get("unlocked", false)))
	assert_eq(int(st.get("free_uses", -1)), 0)
	assert_eq(int(st.get("price", -1)), 100)


func test_IR90_T2_free_uses_show_instead_of_the_price() -> void:
	var s: Variant = _playing(500, 2)
	if s == null:
		return
	assert_eq(int(s.hero_booster_state("hoof_tap").get("free_uses", -1)), 2)


func test_IR90_T2_with_90_coins_the_price_still_shows_and_arming_works() -> void:
	var s: Variant = _playing(90, 0)
	if s == null:
		return
	var st: Dictionary = s.hero_booster_state("hoof_tap")
	assert_eq(int(st.get("price", -1)), 100)
	assert_true(bool(st.get("usable", false)), "arming is free, so it is usable")
	assert_true(s.arm_hero_booster("hoof_tap"))
	assert_eq(s.armed_hero_booster(), "hoof_tap")
	assert_eq(s.coins(), 90, "nothing charged for arming")


# ---------------------------------------------------------------- (b) arm, tap a cell, cancel

func test_IR90_T3_armed_tap_on_a_cell_is_one_use_then_disarmed() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	var r: Dictionary = _arm_and_use(s, CELL)
	assert_true(bool(r.get("ok", false)), str(r))
	assert_ne(s.board().get_color(3, 3), "f3_3", "the piece at (3,3) was cleared (a unique filler fell in)")
	assert_eq(s.board().get_color(3, 3), "f3_2")
	assert_gt((r.get("events", []) as Array).size(), 0)
	assert_gte(_type_index(r.events, "booster"), 0, "a booster event is returned for the animation")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)
	assert_eq(s.armed_hero_booster(), "", "one tap, one use")
	assert_false(bool(s.hero_booster_state("hoof_tap").armed))
	var before: String = _snap(s)
	var r2: Dictionary = s.use_hero_booster(Vector2i(4, 4))
	assert_false(bool(r2.get("ok", true)), "a second cell tap does nothing")
	assert_eq(r2.get("reason", ""), "not_armed")
	assert_eq((r2.get("events", []) as Array).size(), 0)
	assert_eq(_snap(s), before)
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)


func test_IR90_T4_button_tapped_again_cancels_with_nothing_spent() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	var before: String = _snap(s)
	var moves: int = s.moves_left()
	assert_true(s.arm_hero_booster("hoof_tap"))
	s.cancel_hero_booster()   # the second tap on the button
	assert_eq(s.armed_hero_booster(), "")
	assert_false(bool(s.hero_booster_state("hoof_tap").armed))
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)
	assert_eq(_snap(s), before)
	assert_eq(s.moves_left(), moves)
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)), "cancelled: a cell tap is not a use")


func test_IR90_T4_tap_outside_the_board_cancels_with_nothing_spent() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	assert_true(s.arm_hero_booster("hoof_tap"))
	# the scene sees no cell under the pointer and calls cancel (a non-cell area)
	s.cancel_hero_booster()
	assert_eq(s.armed_hero_booster(), "")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)


func test_IR90_T4_arming_is_free() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	var before: String = _snap(s)
	assert_true(s.arm_hero_booster("hoof_tap"))
	assert_eq(s.armed_hero_booster(), "hoof_tap")
	assert_true(bool(s.hero_booster_state("hoof_tap").armed))
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)
	assert_eq(_save.coins(), 500)
	assert_eq(_snap(s), before)


# ---------------------------------------------------------------- (c) payment at the moment of use

func test_IR90_T5_free_use_first_coins_untouched() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)
	assert_eq(s.coins(), 500, "never a free use and coins for the same use")
	assert_eq(_save.coins(), 500)


func test_IR90_T5_no_free_uses_costs_100() -> void:
	var s: Variant = _playing(500, 0)
	if s == null:
		return
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(s.coins(), 400)
	assert_eq(_save.coins(), 400)
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 0)


func test_IR90_T5_exactly_100_coins_goes_to_0() -> void:
	var s: Variant = _playing(100, 0)
	if s == null:
		return
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(s.coins(), 0)
	assert_eq(_save.coins(), 0)


func test_IR90_T6_refused_for_lack_of_coins_changes_nothing() -> void:
	var s: Variant = _playing(90, 0)
	if s == null:
		return
	var before: String = _snap(s)
	var moves: int = s.moves_left()
	var r: Dictionary = _arm_and_use(s, CELL)
	assert_false(bool(r.get("ok", true)), "refused")
	assert_eq(r.get("reason", ""), "not_enough_coins", "the player sees why")
	assert_eq((r.get("events", []) as Array).size(), 0, "no events from the board")
	assert_eq(s.coins(), 90)
	assert_eq(_save.coins(), 90)
	assert_eq(_snap(s), before, "the piece at (3,3) and every other cell unchanged")
	assert_eq(s.moves_left(), moves)
	assert_eq(s.state, LevelSession.PLAYING)


func test_IR90_T6_OQ103_A_refused_use_leaves_the_button_armed() -> void:
	var s: Variant = _playing(90, 0)
	if s == null:
		return
	assert_false(bool(_arm_and_use(s, CELL).get("ok", true)))
	assert_eq(s.armed_hero_booster(), "hoof_tap", "OQ-103 A (provisional): stays armed")


func test_IR90_T7_locked_booster_is_refused_and_changes_nothing() -> void:
	_save.debug_set({"next_level": 10, "coins": 500, "lives": 5})
	var s: Variant = LevelSession.new(_level_file(10), _save)
	if not _api_ok(s):
		return
	assert_true(s.start({"seed": 7}), s.last_error)
	_freeze(s)
	var before: String = _snap(s)
	var moves: int = s.moves_left()
	assert_false(s.arm_hero_booster("hoof_tap"))
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)))
	assert_eq((r.get("events", []) as Array).size(), 0)
	assert_eq(s.coins(), 500)
	assert_eq(_save.coins(), 500)
	assert_eq(_snap(s), before)
	assert_eq(s.moves_left(), moves)


# ---------------------------------------------------------------- (d) which cells

func test_IR90_T8_plain_piece_is_a_use() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	assert_true(bool(_arm_and_use(s, Vector2i(2, 5)).get("ok", false)))
	assert_eq(s.board().get_color(2, 5), "f2_4")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)


func test_IR90_T8_piece_on_goo_hp2_is_a_use_and_goo_takes_one_hit() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.board().set_underlay(3, 3, "OB10", 2)
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(s.board().underlay_hp(3, 3), 1, "IR-36: goo hp 2 -> 1")
	assert_eq(s.board().get_color(3, 3), "f3_2", "the piece was cleared too")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)


func test_IR90_T8_piece_under_moss_is_a_use_top_layer_only() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.board().set_overlay(3, 3, "OB03", 1)
	s.board().set_underlay(3, 3, "OB10", 1)
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(s.board().overlay_hp(3, 3), 0, "moss removed")
	assert_eq(s.board().underlay_hp(3, 3), 1, "goo underneath untouched (IR-36)")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)


func test_IR90_T8_obstacle_only_cell_is_a_use() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.board().add_content("OB02", 5, 5, 2)   # a 2-layer bramble
	assert_true(bool(_arm_and_use(s, Vector2i(5, 5)).get("ok", false)))
	assert_eq(s.board().content_hp(5, 5), 1, "IR-36: bramble 2 layers -> 1")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)


func test_IR90_T8_hatchling_is_collected_and_is_a_use() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.board().set_drop_item(4, 2, "OB11")
	var r: Dictionary = _arm_and_use(s, Vector2i(4, 2))
	assert_true(bool(r.get("ok", false)))
	assert_gte(_type_index(r.events, "collected"), 0, "IR-34: collected, never deleted")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2, "it counts as a use")


func test_IR90_T8_hatchling_with_no_free_uses_costs_100() -> void:
	var s: Variant = _playing(500, 0)
	if s == null:
		return
	s.board().set_drop_item(4, 2, "OB11")
	assert_true(bool(_arm_and_use(s, Vector2i(4, 2)).get("ok", false)))
	assert_eq(s.coins(), 400)


func test_IR90_T9_non_playable_cell_is_not_a_use_and_disarms() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	var before: String = _snap(s)
	var moves: int = s.moves_left()
	assert_false(s.board().is_playable(0, 0), "(0,0) is a hole of the fixture's shape")
	var r: Dictionary = _arm_and_use(s, Vector2i(0, 0))
	assert_false(bool(r.get("ok", true)))
	assert_eq(r.get("reason", ""), "non_playable_cell")
	assert_eq((r.get("events", []) as Array).size(), 0)
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)
	assert_eq(_snap(s), before)
	assert_eq(s.moves_left(), moves)
	assert_eq(s.armed_hero_booster(), "", "OQ-104 A (provisional): a hole counts as a non-cell area, so it disarms")


func test_IR90_T9_cell_outside_the_grid_is_not_a_use() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	var r: Dictionary = _arm_and_use(s, Vector2i(-1, 12))
	assert_false(bool(r.get("ok", true)))
	assert_eq(r.get("reason", ""), "non_playable_cell")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)


func test_IR90_T8_OQ106_B_hoof_tap_on_a_rocket_is_a_use_and_the_rocket_fires() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.board().set_piece(3, 3, "rocket_row", "R")
	var moves: int = s.moves_left()
	var r: Dictionary = _arm_and_use(s, CELL)
	assert_true(bool(r.get("ok", false)), str(r))
	assert_gte(_type_index(r.events, "rocket_fire"), 0, "IR-36: the Rocket fires")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2, "a use that spends a free use")
	assert_eq(s.coins(), 500)
	assert_eq(s.moves_left(), moves, "IR-62: no move used")
	assert_eq(s.state, LevelSession.PLAYING)
	assert_eq(_type_index(r.events, "fail"), -1)
	assert_eq(s.armed_hero_booster(), "")


func test_IR90_T8_OQ106_B_hoof_tap_on_a_rocket_with_no_free_uses_costs_100() -> void:
	var s: Variant = _playing(500, 0)
	if s == null:
		return
	s.board().set_piece(3, 3, "rocket_col", "Y")
	var r: Dictionary = _arm_and_use(s, CELL)
	assert_true(bool(r.get("ok", false)), str(r))
	assert_gte(_type_index(r.events, "rocket_fire"), 0)
	assert_eq(s.coins(), 400)
	assert_eq(_save.coins(), 400)


func test_IR90_T8_OQ108_A_hoof_tap_on_a_special_under_moss_is_a_use() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.board().set_piece(3, 3, "rocket_row", "R")
	s.board().set_overlay(3, 3, "OB03", 1)
	var r: Dictionary = _arm_and_use(s, CELL)
	assert_true(bool(r.get("ok", false)), str(r))
	assert_eq(s.board().overlay_hp(3, 3), 0, "moss removed")
	assert_gte(_type_index(r.events, "rocket_fire"), 0, "OQ-108 A: the covered Rocket fires")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 2)


func test_IR90_T13_OQ106_B_a_set_off_rocket_can_win_the_level() -> void:
	var s: Variant = _playing(500, 1, _creature_level())
	if s == null:
		return
	s.board().set_piece(4, 3, "rocket_col", "R")   # column 4 covers the creature at (4,4)
	var r: Dictionary = _arm_and_use(s, Vector2i(4, 3))
	assert_true(bool(r.get("ok", false)), str(r))
	var events: Array = r.get("events", [])
	var i_fire: int = _type_index(events, "rocket_fire")
	var i_goal: int = _type_index(events, "goal_done")
	var i_win: int = _type_index(events, "win")
	assert_gte(i_fire, 0, "the Rocket fires")
	assert_gt(i_goal, i_fire, "goal done event as usual")
	assert_gt(i_win, i_goal, "then the win")
	assert_eq(s.state, LevelSession.WON)
	assert_eq(s.moves_left(), 10, "IR-62")
	assert_eq(s.coins(), 570, "500 + 20 + 5 x 10")
	assert_eq(int(_save.hero_free_uses("hoof_tap")), 0)


func test_IR90_OQ104_A_tap_on_a_hole_disarms_and_spends_nothing() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	assert_true(s.arm_hero_booster("hoof_tap"))
	var r: Dictionary = s.use_hero_booster(Vector2i(0, 0))   # a hole of the fixture's shape
	assert_false(bool(r.get("ok", true)))
	assert_eq(s.armed_hero_booster(), "", "a hole counts as a non-cell area: disarmed")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)
	assert_false(bool(s.use_hero_booster(CELL).get("ok", true)), "a following tap does nothing until armed again")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)


func test_IR90_OQ103_A_refused_use_stays_armed_and_the_button_tap_disarms_it() -> void:
	var s: Variant = _playing(90, 0)
	if s == null:
		return
	var r: Dictionary = _arm_and_use(s, CELL)
	assert_eq(r.get("reason", ""), "not_enough_coins")
	assert_eq(s.armed_hero_booster(), "hoof_tap", "refused but still armed")
	assert_eq(s.coins(), 90)
	s.cancel_hero_booster()
	assert_eq(s.armed_hero_booster(), "")
	assert_eq(s.coins(), 90, "nothing spent")


func test_IR90_OQ105_A_a_move_starting_disarms_the_button() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	assert_true(s.arm_hero_booster("hoof_tap"))
	s.set_busy(true)
	assert_eq(s.armed_hero_booster(), "")
	assert_false(bool(s.use_hero_booster(CELL).get("ok", true)), "ignored while busy")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)


# ---------------------------------------------------------------- (e) when it can't be used

func test_IR90_T10_not_on_the_win_screen() -> void:
	var s: Variant = _playing(500, 3, _creature_level())
	if s == null:
		return
	assert_true(bool(_arm_and_use(s, Vector2i(4, 4)).get("ok", false)), "this tap wins")
	assert_eq(s.state, LevelSession.WON)
	var coins: int = s.coins()
	var free: int = int(_save.hero_free_uses("hoof_tap"))
	assert_false(s.arm_hero_booster("hoof_tap"), "nothing is armed on the win screen")
	assert_eq(s.armed_hero_booster(), "")
	assert_false(bool(s.hero_booster_state("hoof_tap").usable))
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)))
	assert_eq(r.get("reason", ""), "not_playing")
	assert_eq(s.coins(), coins)
	assert_eq(int(_save.hero_free_uses("hoof_tap")), free)


func test_IR90_T10_not_on_the_retry_screen_after_a_fail() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	_spend_last_move(s)
	assert_eq(s.state, LevelSession.OFFER)
	s.decline_offer()
	assert_eq(s.state, LevelSession.RETRY)
	assert_false(s.arm_hero_booster("hoof_tap"))
	assert_false(bool(s.hero_booster_state("hoof_tap").usable))
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)))
	assert_eq(r.get("reason", ""), "not_playing")
	assert_eq(int(_save.hero_free_uses("hoof_tap")), 3)
	assert_eq(_save.coins(), 500)


func test_IR90_T11_not_while_a_move_is_resolving() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	s.set_busy(true)   # the scene sets this while a move's events are still playing
	assert_false(s.arm_hero_booster("hoof_tap"), "button tap ignored")
	assert_false(bool(s.hero_booster_state("hoof_tap").usable))
	var before: String = _snap(s)
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)), "cell tap ignored")
	assert_eq(r.get("reason", ""), "busy")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)
	assert_eq(s.coins(), 500)
	assert_eq(_snap(s), before)
	s.set_busy(false)
	assert_true(bool(s.hero_booster_state("hoof_tap").usable), "after the move settles the button works again")
	assert_true(bool(_arm_and_use(s).get("ok", false)))


func test_IR90_T11_OQ105_A_armed_button_is_disarmed_when_a_move_starts() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	assert_true(s.arm_hero_booster("hoof_tap"))
	s.set_busy(true)
	assert_eq(s.armed_hero_booster(), "", "OQ-105 A (provisional): disarmed")
	s.set_busy(false)
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)), "not armed any more")
	assert_eq(int(s.hero_booster_state("hoof_tap").free_uses), 3)


func test_IR90_T11_OQ105_A_swap_and_tap_are_ignored_while_armed() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	var b: BoardModel = s.board()
	b.set_piece(5, 7, "plain", "R")
	b.set_piece(6, 7, "plain", "R")
	b.set_piece(7, 8, "plain", "R")
	var moves: int = s.moves_left()
	var before: String = _snap(s)
	assert_true(s.arm_hero_booster("hoof_tap"))
	assert_eq(s.swap(Vector2i(7, 7), Vector2i(7, 8)).size(), 0, "a swap while armed is ignored")
	assert_eq(s.tap(Vector2i(5, 7)).size(), 0)
	assert_eq(s.moves_left(), moves)
	assert_eq(_snap(s), before)


func test_IR90_T12_not_during_the_continue_offer() -> void:
	var s: Variant = _playing(500, 3)
	if s == null:
		return
	_spend_last_move(s)
	assert_eq(s.state, LevelSession.OFFER)
	assert_false(s.arm_hero_booster("hoof_tap"), "OQ-105 A (provisional): can't be armed during the offer")
	assert_false(bool(s.hero_booster_state("hoof_tap").usable))
	var r: Dictionary = s.use_hero_booster(CELL)
	assert_false(bool(r.get("ok", true)))
	assert_eq(r.get("reason", ""), "not_playing")
	assert_eq(s.coins(), 500)
	assert_eq(int(_save.hero_free_uses("hoof_tap")), 3)
	assert_eq(s.state, LevelSession.OFFER, "the offer is still on screen")
	assert_true(s.accept_offer())
	assert_true(s.arm_hero_booster("hoof_tap"), "after accepting, play and the button work again")


# ---------------------------------------------------------------- (f) win and last move

func test_IR90_T13_the_use_can_finish_the_goals_and_win() -> void:
	var s: Variant = _playing(500, 1, _creature_level())
	if s == null:
		return
	var r: Dictionary = _arm_and_use(s, Vector2i(4, 4))
	assert_true(bool(r.get("ok", false)), str(r))
	var events: Array = r.get("events", [])
	var i_goal: int = _type_index(events, "goal_done")
	var i_win: int = _type_index(events, "win")
	assert_gte(i_goal, 0, "goal done event")
	assert_gt(i_win, i_goal, "then the win event once the board settles")
	assert_gte(_type_index(events, "special_created"), 0, "10 finale Rockets are in the events (IR-16)")
	assert_eq(s.state, LevelSession.WON)
	assert_eq(s.moves_left(), 10, "IR-62: no move used")
	assert_eq(s.finale_rockets, 10)
	assert_eq(s.win_coins, 70)
	assert_eq(s.coins(), 570, "500 + 20 + 5 x 10")
	assert_eq(_save.coins(), 570)
	assert_eq(int(_save.hero_free_uses("hoof_tap")), 0, "the one free use was spent")
	assert_eq(_save.next_level(), 13, "the win was saved")


func test_IR90_T14_last_move_and_a_paid_use_no_fail_no_offer() -> void:
	var s: Variant = _playing(400, 0)
	if s == null:
		return
	s.board().moves = 1
	var r: Dictionary = _arm_and_use(s)
	assert_true(bool(r.get("ok", false)))
	assert_eq(s.coins(), 300, "shown at once")
	assert_eq(s.moves_left(), 1)
	assert_eq(_type_index(r.events, "fail"), -1)
	assert_eq(s.state, LevelSession.PLAYING, "no continue offer")
	assert_eq(s.offer_price(), 0)
	# the player can still make their last move
	var b: BoardModel = s.board()
	b.set_piece(5, 7, "plain", "R")
	b.set_piece(6, 7, "plain", "R")
	b.set_piece(7, 8, "plain", "R")
	assert_gt(s.swap(Vector2i(7, 7), Vector2i(7, 8)).size(), 0)
	assert_eq(s.moves_left(), 0)


# ---------------------------------------------------------------- (g) tracker and save share one balance

func test_IR90_T15_price_is_taken_from_the_trackers_coins() -> void:
	var s: Variant = _playing(500, 0)
	if s == null:
		return
	s.attempt.tracker.coins = 200   # a continue accepted earlier, not yet synced to the save
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(_save.coins(), 100, "200 - 100, not 500 - 100")
	assert_eq(s.attempt.tracker.coins, 100)
	assert_eq(s.coins(), 100)


func test_IR90_T16_100_coins_one_use_then_the_next_is_refused() -> void:
	var s: Variant = _playing(100, 0)
	if s == null:
		return
	assert_true(bool(_arm_and_use(s).get("ok", false)))
	assert_eq(s.attempt.tracker.coins, 0)
	assert_eq(_save.coins(), 0)
	var st: Dictionary = s.hero_booster_state("hoof_tap")
	assert_eq(int(st.get("free_uses", -1)), 0)
	assert_eq(int(st.get("price", -1)), 100, "the button shows the price")
	var r: Dictionary = _arm_and_use(s, Vector2i(5, 5))
	assert_false(bool(r.get("ok", true)), "a further use is refused")
	assert_eq(r.get("reason", ""), "not_enough_coins")
	assert_eq(_save.coins(), 0)
