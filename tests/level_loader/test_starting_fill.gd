# LevelLoader tests for moves and colours (IR-68), the starting board (IR-69) and fixed tiles (IR-76).
# Contract: tests/API_CONTRACT.md section 11. Check: run the GUT suite; the names carry the IR id.
extends "res://tests/level_loader/level_loader_test_base.gd"

const SEEDS: int = 200


func _full_level(overrides: Dictionary = {}) -> Dictionary:
	# 9x9: bramble (0,6); pillar 1x4 at (1,0); moss (3,4); goo (6,6); dew seed (7,7)
	var under: Array = LF.with_char(LF.with_char(LF.rows(9, 9, "."), 6, 6, "1"), 7, 7, "s")
	var d: Dictionary = LF.level(30, {"underlay": under, "objects": [
		{"type": "OB02", "x": 0, "y": 6, "hp": 1},
		{"type": "OB06", "x": 1, "y": 0, "w": 1, "h": 4, "hp": 3},
		{"type": "OB03", "x": 3, "y": 4, "hp": 1}]})
	for k in overrides:
		d[k] = overrides[k]
	return d


# ---------------------------------------------------------------- IR-68

func test_IR68_attempt_starts_with_the_files_moves() -> void:
	var a: Variant = load_attempt(LF.level(26, {"moves": 26}), {"seed": 1})
	if a == null:
		return
	assert_eq(a.board.moves, 26)


func _refill_many(board: BoardModel, times: int) -> void:
	var pick: RandomNumberGenerator = RandomNumberGenerator.new()
	pick.seed = 99
	for i in range(times):
		board.set_piece(pick.randi_range(0, board.width - 1), pick.randi_range(0, board.height - 1), "")
		MatchResolver.settle(board)


func test_IR68_four_colour_level_uses_only_r_y_b_g_also_after_50_refills() -> void:
	var a: Variant = load_attempt(LF.level(12, {"colors": 4}), {"seed": 7})
	if a == null:
		return
	var b: BoardModel = a.board
	for c in LF.plain_colors(b).keys():
		assert_true(LF.FOUR.has(c), "starting colour %s" % c)
	_refill_many(b, 50)
	for c in LF.plain_colors(b).keys():
		assert_true(LF.FOUR.has(c), "colour after refills %s" % c)


func test_IR68_three_colour_intro_level_has_no_yellow_also_after_50_refills() -> void:
	var a: Variant = load_attempt(LF.level(28, {"tier": "intro", "colors": 3, "color_set": ["red", "blue", "green"]}), {"seed": 7})
	if a == null:
		return
	var b: BoardModel = a.board
	var first: Dictionary = LF.plain_colors(b)
	assert_false(first.has("Y"), "no yellow at the start")
	assert_eq(first.size(), 3, "all three colours appear on a 9x9 board")
	_refill_many(b, 50)
	assert_false(LF.plain_colors(b).has("Y"), "no yellow after 50 refills")


# ---------------------------------------------------------------- IR-69

func test_IR69_every_free_cell_gets_a_piece_and_the_board_is_playable() -> void:
	var a: Variant = load_attempt(_full_level(), {"seed": 42})
	if a == null:
		return
	var b: BoardModel = a.board
	for c in [Vector2i(0, 6), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]:
		assert_eq(b.get_kind(c.x, c.y), "", "no piece at obstacle cell %s" % c)
	for c in [Vector2i(3, 4), Vector2i(6, 6), Vector2i(7, 7)]:
		assert_eq(b.get_kind(c.x, c.y), "plain", "a plain piece at %s (under moss / on an underlay)" % c)
	assert_eq(LF.count_kind(b, "plain"), 76, "81 cells minus bramble and the 4-cell pillar")
	no_match_and_three_swaps(b, "seed 42")


func test_IR69_200_seeds_all_give_a_no_match_board_with_three_swaps() -> void:
	for s in range(1, SEEDS + 1):
		var a: Variant = load_attempt(_full_level(), {"seed": s})
		if a == null:
			return
		var b: BoardModel = a.board
		if BB.has_match(b) or LF.swaps_that_match(b, 3) < 3:
			fail_test("seed %d: match on the board or fewer than 3 matching swaps" % s)
			return
	pass_test("200 seeds fine")


func test_IR69_fixed_rocket_in_its_cell_and_rest_of_board_follows_the_rule() -> void:
	var a: Variant = load_attempt(LF.level(12, {"fixed_tiles": [{"x": 4, "y": 8, "tile": "line_h"}]}), {"seed": 3})
	if a == null:
		return
	var b: BoardModel = a.board
	assert_eq(b.get_kind(4, 8), "rocket_row")
	assert_true(LF.FOUR.has(b.get_color(4, 8)), "a colour of the level")
	assert_eq(LF.count_kind(b, "plain"), 80)
	no_match_and_three_swaps(b, "with a fixed Rocket")


func test_IR69_drop_item_level_200_seeds_no_match_and_three_swaps() -> void:
	var spawn: Dictionary = {"drop_items": {"type": "OB11", "total": 3, "max_on_board": 2}, "generators": null}
	for s in range(1, SEEDS + 1):
		var a: Variant = load_attempt(LF.level(36, {"spawn": spawn}), {"seed": s})
		if a == null:
			return
		var b: BoardModel = a.board
		if LF.drops(b, "OB11").size() != 2 or BB.has_match(b) or LF.swaps_that_match(b, 3) < 3:
			fail_test("seed %d: need 2 hatchlings, no match, 3 matching swaps" % s)
			return
	pass_test("200 seeds fine")


# ---------------------------------------------------------------- IR-76

func test_IR76_tile_names_blue_column_rocket_orb_and_plain_yellow() -> void:
	var a: Variant = load_attempt(LF.level(12, {"fixed_tiles": [
		{"x": 4, "y": 8, "tile": "line_v", "color": "blue"},
		{"x": 2, "y": 2, "tile": "orb"},
		{"x": 0, "y": 0, "tile": "yellow"}]}), {"seed": 3})
	if a == null:
		return
	var b: BoardModel = a.board
	assert_eq(b.get_kind(4, 8), "rocket_col")
	assert_eq(b.get_color(4, 8), "B")
	assert_eq(b.get_kind(2, 2), "orb")
	assert_eq(b.get_color(2, 2), "", "the Orb has no colour")
	assert_eq(b.get_kind(0, 0), "plain")
	assert_eq(b.get_color(0, 0), "Y")


func test_IR76_uncoloured_crane_takes_a_seeded_level_colour() -> void:
	var level: Dictionary = LF.level(12, {"fixed_tiles": [{"x": 4, "y": 8, "tile": "crane"}]})
	var a1: Variant = load_attempt(level, {"seed": 1234})
	var a2: Variant = load_attempt(level, {"seed": 1234})
	if a1 == null or a2 == null:
		return
	assert_eq(a1.board.get_kind(4, 8), "crane")
	assert_true(LF.FOUR.has(a1.board.get_color(4, 8)))
	assert_eq(a1.board.get_color(4, 8), a2.board.get_color(4, 8), "same seed, same colour")


func test_IR76_uncoloured_special_colour_follows_the_level_colours() -> void:
	# three-colour level: the seeded colour is one of the three, whatever the seed
	var level: Dictionary = LF.level(28, {"tier": "intro", "colors": 3, "color_set": ["red", "blue", "green"],
		"fixed_tiles": [{"x": 4, "y": 8, "tile": "firecracker"}]})
	for s in range(1, 41):
		var a: Variant = load_attempt(level, {"seed": s})
		if a == null:
			return
		if not ["R", "B", "G"].has(a.board.get_color(4, 8)):
			fail_test("seed %d gave colour %s" % [s, a.board.get_color(4, 8)])
			return
	pass_test("colours stay in the level's set")


func test_IR76_firecracker_under_moss_is_locked_swap_refused_tap_does_nothing() -> void:
	var a: Variant = load_attempt(LF.level(12, {
		"objects": [{"type": "OB03", "x": 3, "y": 4, "hp": 1}],
		"fixed_tiles": [{"x": 3, "y": 4, "tile": "firecracker", "color": "red"}]}), {"seed": 3})
	if a == null:
		return
	var b: BoardModel = a.board
	assert_eq(b.get_kind(3, 4), "firecracker")
	assert_eq(b.get_color(3, 4), "R")
	assert_eq(b.overlay_hp(3, 4), 1)
	var moves: int = b.moves
	var swap_events: Array[BoardEvent] = MatchResolver.swap(b, Vector2i(3, 4), Vector2i(3, 5))
	assert_eq(swap_events.size(), 1)
	assert_eq((swap_events[0] as BoardEvent).type, "invalid_swap")
	assert_eq((swap_events[0] as BoardEvent).data.get("reason"), "refused")
	assert_eq(MatchResolver.tap(b, Vector2i(3, 4)).size(), 0, "tapping does nothing")
	assert_eq(b.moves, moves, "no move used")
	assert_eq(b.get_kind(3, 4), "firecracker", "still there")
