# LevelLoader tests for the attempt seed (IR-72) and for a retry rebuilding the attempt from the level file (IR-71).
# Fragment retry cases (IR-58) are in test_level_loader_fragment_retry.gd. Contract: tests/API_CONTRACT.md section 11.
# Check: run the GUT suite; the names carry the IR id.
extends "res://tests/level_loader/level_loader_test_base.gd"

const TMP_PATH: String = "user://ir71_level_fixture.json"


func _fail_attempt(a: Variant) -> void:
	a.board.moves = 0
	a.tracker.moves_ran_out(a.board)
	a.tracker.decline_offer()


func _cleared(id: String) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new("obstacle_cleared")
	e.data = {"id": id}
	return e


func _bramble_level(count: int) -> Dictionary:
	var objects: Array = []
	for i in range(count):
		objects.append({"type": "OB02", "x": i % 9, "y": 6 + floori(i / 9.0), "hp": 1 + (i % 2)})
	return LF.level(2, {"moves": 26, "objects": objects, "goals": [{"obstacle": "OB02", "count": count}]})


# ---------------------------------------------------------------- IR-72

func test_IR72_attempt_remembers_the_seed_it_was_given() -> void:
	var a: Variant = load_attempt(LF.level(12), {"seed": 1234})
	if a == null:
		return
	assert_eq(a.seed_value, 1234)


func test_IR72_same_seed_same_board_and_same_refills_after_5_swaps() -> void:
	var level: Dictionary = LF.level(12)
	var a: Variant = load_attempt(level, {"seed": 1234})
	var b: Variant = load_attempt(level, {"seed": 1234})
	if a == null or b == null:
		return
	assert_eq(BB.snapshot(a.board), BB.snapshot(b.board), "same starting board")
	for i in range(5):
		var swap: Array = LF.first_matching_swap(a.board)
		if swap.is_empty():
			fail_test("no plain swap found on step %d" % i)
			return
		MatchResolver.swap(a.board, swap[0], swap[1])
		MatchResolver.swap(b.board, swap[0], swap[1])
		assert_eq(BB.snapshot(a.board), BB.snapshot(b.board), "same board after swap %d (same refills)" % (i + 1))


func test_IR72_different_seeds_give_different_boards() -> void:
	var level: Dictionary = LF.level(12)
	var a: Variant = load_attempt(level, {"seed": 1})
	var b: Variant = load_attempt(level, {"seed": 2})
	if a == null or b == null:
		return
	assert_ne(BB.snapshot(a.board), BB.snapshot(b.board))


func test_IR72_same_seed_same_finale_rocket_directions_and_cells() -> void:
	var level: Dictionary = LF.level(12)
	var runs: Array = []
	for i in range(2):
		var a: Variant = load_attempt(level, {"seed": 1234})
		if a == null:
			return
		a.board.moves = 3
		var events: Array[BoardEvent] = MatchResolver.fire_finale(a.board)
		var fired: Array = []
		for e in EV.of_type(events, "rocket_fire"):
			fired.append([(e as BoardEvent).kind, (e as BoardEvent).cell])
		runs.append(fired)
	assert_eq((runs[0] as Array).size(), 3, "3 finale Rockets")
	assert_eq(runs[0], runs[1], "same directions and cells both times")


func test_IR72_no_seed_given_means_a_new_seed_each_time() -> void:
	var a: Variant = load_attempt(LF.level(12))
	var b: Variant = load_attempt(LF.level(12))
	if a == null or b == null:
		return
	assert_ne(a.seed_value, b.seed_value)


func test_IR72_retry_gets_a_new_seed_and_a_different_starting_board() -> void:
	var a: Variant = load_attempt(LF.level(12), {"seed": 77})
	if a == null:
		return
	_fail_attempt(a)
	var r: Variant = retry(a)
	if r == null:
		return
	assert_ne(r.seed_value, 77, "attempt 2 has its own seed")
	assert_ne(BB.snapshot(a.board), BB.snapshot(r.board), "new random starting pieces")
	var pinned: Variant = retry(a, {"seed": 500})
	if pinned == null:
		return
	assert_eq(pinned.seed_value, 500, "a seed passed in is used")


# ---------------------------------------------------------------- IR-71

func test_IR71_retry_brings_back_moves_goal_and_all_17_brambles_with_file_layers() -> void:
	var level: Dictionary = _bramble_level(17)
	var a: Variant = load_attempt(level, {"seed": 3})
	if a == null:
		return
	for i in range(9):
		var c: Vector2i = Vector2i(i % 9, 6)
		a.board.remove_content(a.board.get_content(c.x, c.y))
		a.tracker.observe(_cleared("OB02"))
	assert_eq(a.tracker.goal_units_done(0), 9)
	_fail_attempt(a)
	assert_eq(a.board.moves, 0)
	var r: Variant = retry(a)
	if r == null:
		return
	assert_eq(r.board.moves, 26, "the file's moves")
	assert_eq(r.tracker.goal_units_done(0), 0, "goal back to 0/17")
	assert_eq(r.tracker.goal_units_total(0), 17)
	for i in range(17):
		var x: int = i % 9
		var y: int = 6 + floori(i / 9.0)
		assert_eq(r.board.content_id(x, y), "OB02", "bramble %d back at (%d,%d)" % [i, x, y])
		assert_eq(r.board.content_hp(x, y), 1 + (i % 2), "its file layers")


func _dew_level() -> Dictionary:
	var under: Array = LF.rows(9, 9, ".")
	for c in [[0, 0], [4, 4], [8, 8]]:
		under = LF.with_char(under, c[0], c[1], "s")
	return LF.level(12, {"underlay": under, "goals": [{"obstacle": "OB04", "count": 58}]})


func test_IR71_dew_goal_starts_at_the_seed_cells_and_retry_returns_to_them() -> void:
	var a: Variant = load_attempt(_dew_level(), {"seed": 3})
	if a == null:
		return
	assert_eq(a.tracker.goal_units_done(0), 3, "seed cells count from the start (IR-61)")
	var given: int = 0
	for y in range(9):
		for x in range(9):
			if given < 37 and a.board.underlay_hp(x, y) == 0:
				a.board.give_dew(x, y)
				given += 1
	assert_eq(a.tracker.goal_units_done(0), 40, "40/58 when the attempt fails")
	_fail_attempt(a)
	var r: Variant = retry(a)
	if r == null:
		return
	assert_eq(r.tracker.goal_units_done(0), 3, "retry: 3/58")
	assert_eq(r.tracker.goal_units_total(0), 58)
	var dew: int = 0
	for y in range(9):
		for x in range(9):
			if r.board.has_dew(x, y):
				dew += 1
	assert_eq(dew, 3, "only the 3 seed cells have dew")
	assert_eq(r.board.dew_targets_left(), 78, "every playable cell is a target; 81 - 3 seeds")


func test_IR71_next_continue_offer_is_the_first_again_after_a_retry() -> void:
	var a: Variant = load_attempt(LF.level(12), {"seed": 3})
	if a == null:
		return
	a.tracker.coins = 3000
	for i in range(2):
		a.board.moves = 0
		a.tracker.moves_ran_out(a.board)
		assert_true(a.tracker.accept_offer(a.board), "offer %d accepted" % (i + 1))
	a.board.moves = 0
	a.tracker.moves_ran_out(a.board)
	assert_eq(a.tracker.offer_price(), 500, "3rd offer shown")
	a.tracker.decline_offer()
	var r: Variant = retry(a)
	if r == null:
		return
	assert_eq(r.tracker.coins, 2200, "coins carry over (3000 - 300 - 500)")
	r.board.moves = 0
	r.tracker.moves_ran_out(r.board)
	assert_eq(r.tracker.offer_price(), 300, "the offer is the 1st again")


func test_IR71_retry_keeps_the_lives_the_tracker_had() -> void:
	var a: Variant = load_attempt(LF.level(12), {"seed": 3})
	if a == null:
		return
	a.tracker.lives = 3
	var r: Variant = retry(a)
	if r == null:
		return
	assert_eq(r.tracker.lives, 3)


func test_IR71_retry_same_obstacles_hp_and_fixed_tiles_in_the_same_cells() -> void:
	var level: Dictionary = LF.level(12, {
		"objects": [{"type": "OB02", "x": 0, "y": 6, "hp": 2}, {"type": "OB03", "x": 3, "y": 4, "hp": 1},
			{"type": "OB06", "x": 7, "y": 0, "w": 1, "h": 3, "hp": 3}],
		"fixed_tiles": [{"x": 4, "y": 8, "tile": "crane"}, {"x": 2, "y": 2, "tile": "line_h"}]})
	var a: Variant = load_attempt(level)
	if a == null:
		return
	_fail_attempt(a)
	var r: Variant = retry(a)
	if r == null:
		return
	assert_ne(r.seed_value, a.seed_value, "attempt 2's seed is not attempt 1's")
	for x in range(9):
		for y in range(9):
			assert_eq(r.board.content_id(x, y), a.board.content_id(x, y), "content id at (%d,%d)" % [x, y])
			assert_eq(r.board.content_hp(x, y), a.board.content_hp(x, y), "content hp at (%d,%d)" % [x, y])
			assert_eq(r.board.overlay_hp(x, y), a.board.overlay_hp(x, y), "moss hp at (%d,%d)" % [x, y])
	assert_eq(r.board.get_kind(4, 8), "crane", "fixed tile kept by name")
	assert_eq(r.board.get_kind(2, 2), "rocket_row", "fixed tile kept by name")


func test_IR71_IR58_retry_re_reads_the_level_file() -> void:
	var level: Dictionary = LF.level(12, {"moves": 26})
	var f: FileAccess = FileAccess.open(TMP_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(level))
	f.close()
	var a: Variant = load_file(TMP_PATH, {"seed": 1})
	if a == null:
		DirAccess.remove_absolute(TMP_PATH)
		return
	assert_eq(a.board.moves, 26)
	assert_eq(a.source_path, TMP_PATH)
	level["moves"] = 24
	f = FileAccess.open(TMP_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(level))
	f.close()
	var r: Variant = retry(a)
	DirAccess.remove_absolute(TMP_PATH)
	if r == null:
		return
	assert_eq(r.board.moves, 24, "the retry was built again from the file, not copied from attempt 1")
