# GUT tests for the win-finale Rockets of IR-16 / IR-05 (leftover moves become Rockets with random direction, OQ-40).
# API: MatchResolver.fire_finale(board, directions) from tests/API_CONTRACT.md section 7. The call goes
# through load() so a missing function fails these tests instead of breaking the script.
# Odds (OQ-53 A) and placement (OQ-58 A) are tested; the fallback cell and settling between Rockets (OQ-60) are pending.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


func _finale(board: BoardModel, directions: Array = []) -> Array[BoardEvent]:
	var out: Array[BoardEvent] = []
	var script: GDScript = load("res://src/match/match_resolver.gd")
	if not script.has_method("fire_finale"):
		return out
	var result: Array = script.call("fire_finale", board, directions)
	for e in result:
		out.append(e)
	return out


func _kinds(events: Array[BoardEvent]) -> Array:
	var out: Array = []
	for e in EV.of_type(events, "rocket_fire"):
		out.append(e.kind)
	return out


func _board(seed_value: int, moves: int) -> BoardModel:
	var board: BoardModel = BB.blank(9, 9, seed_value)
	board.moves = moves
	return board


func test_ir16_finale_fires_one_rocket_per_leftover_move_each_row_or_column() -> void:
	var board: BoardModel = _board(5, 4)
	var events: Array[BoardEvent] = _finale(board)
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 4, "4 moves left, 4 finale Rocket fire events")
	for f in fires:
		assert_true(f.kind == "rocket_row" or f.kind == "rocket_col", "direction is row or column, got %s" % f.kind)
		if f.kind == "rocket_row":
			assert_eq(f.cells.size(), 9, "a row Rocket covers its whole row")
			for c in f.cells:
				assert_eq(c.y, f.cell.y)
		else:
			assert_eq(f.cells.size(), 9, "a column Rocket covers its whole column")
			for c in f.cells:
				assert_eq(c.x, f.cell.x)
	assert_eq(board.moves, 0, "the leftover moves are used up")


func test_ir16_finale_with_no_leftover_moves_fires_nothing() -> void:
	var script: GDScript = load("res://src/match/match_resolver.gd")
	assert_true(script.has_method("fire_finale"), "MatchResolver.fire_finale exists")
	var board: BoardModel = _board(5, 0)
	var events: Array[BoardEvent] = _finale(board)
	assert_eq(EV.count(events, "rocket_fire"), 0)


func test_ir16_finale_directions_are_repeatable_for_the_same_seed() -> void:
	var first: Array = _kinds(_finale(_board(77, 4)))
	var second: Array = _kinds(_finale(_board(77, 4)))
	assert_eq(first.size(), 4, "4 directions")
	assert_eq(first, second, "same seed, same 4 directions in the same order")


func test_ir16_finale_directions_come_from_the_seeded_rng() -> void:
	# If the direction were fixed (or not seeded), every seed would give the same list.
	var seen: Dictionary = {}
	for s in range(1, 9):
		seen[str(_kinds(_finale(_board(s, 4))))] = true
	assert_true(seen.size() >= 2, "different seeds give different direction lists")


func test_ir16_finale_with_stubbed_directions_fires_them_in_order() -> void:
	var board: BoardModel = _board(5, 3)
	var events: Array[BoardEvent] = _finale(board, ["rocket_row", "rocket_col", "rocket_col"])
	assert_eq(_kinds(events), ["rocket_row", "rocket_col", "rocket_col"])
	assert_eq(board.moves, 0)


func test_ir16_finale_with_all_row_directions_stays_all_row() -> void:
	var board: BoardModel = _board(5, 3)
	var events: Array[BoardEvent] = _finale(board, ["rocket_row", "rocket_row", "rocket_row"])
	assert_eq(_kinds(events), ["rocket_row", "rocket_row", "rocket_row"], "3 row Rockets; none is flipped to column")
	assert_eq(board.moves, 0)


func test_ir16_finale_with_all_column_directions_stays_all_column() -> void:
	var board: BoardModel = _board(5, 3)
	var events: Array[BoardEvent] = _finale(board, ["rocket_col", "rocket_col", "rocket_col"])
	assert_eq(_kinds(events), ["rocket_col", "rocket_col", "rocket_col"], "all-column finales happen too")


func _row_share(first_seed: int, last_seed: int, moves: int) -> float:
	# Counts every finale Rocket fire event. Uses a 3x3 board and a 12-colour palette: the direction draw does
	# not depend on the board size, and a 9x9 board took about 35 s and 3x3 about 5 s (still over the 2 s target; the 10,000-Rocket sample is what makes the 48-52% band safe).
	var rows: int = 0
	var total: int = 0
	for s in range(first_seed, last_seed + 1):
		var board: BoardModel = BB.blank(3, 3, s)
		board.moves = moves
		board.palette = BB.spread_palette()
		for e in EV.of_type(_finale(board), "rocket_fire"):
			total += 1
			if e.kind == "rocket_row":
				rows += 1
	return float(rows) / float(maxi(total, 1))


func test_ir16_finale_direction_is_fifty_fifty_over_ten_thousand_rockets() -> void:
	# OQ-53 A: seeds 1-1000, 10 leftover moves each = 10,000 finale Rockets; 48% to 52% are row Rockets.
	var share: float = _row_share(1, 1000, 10)
	assert_true(share >= 0.48 and share <= 0.52, "row share %.4f should be within 0.48-0.52" % share)


# A board whose only uncovered plain piece is the Y at (6,2): every other playable cell holds a special
# (Jade Orb), a covered piece (moss hp 2), a lost hatchling or an obstacle (bramble).
func _only_one_plain_board(seed_value: int, moves: int) -> BoardModel:
	var board: BoardModel = _board(seed_value, moves)
	board.palette = BB.spread_palette()
	for y in range(9):
		for x in range(9):
			match (x + y) % 4:
				0:
					BB.put(board, "O", [[x, y]])
				1:
					board.set_overlay(x, y, "OB03", 2)
				2:
					if y < 8:
						BB.put(board, "H", [[x, y]])
					else:
						BB.put(board, "O", [[x, y]])
				3:
					board.add_content("OB02", x, y, 2)
	BB.put(board, "Y", [[6, 2]])
	return board


func test_ir16_finale_rocket_replaces_the_only_uncovered_plain_piece() -> void:
	var board: BoardModel = _only_one_plain_board(5, 1)
	assert_eq(board.overlay_hp(6, 2), 0, "precondition: (6,2) is uncovered")
	assert_eq(board.get_kind(6, 2), "plain", "precondition: (6,2) holds the Y")
	var events: Array[BoardEvent] = _finale(board, ["rocket_col"])
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_true(fires.size() >= 1, "the finale Rocket fires")
	if fires.size() >= 1:
		assert_eq(fires[0].cell, Vector2i(6, 2), "the Rocket appears at (6,2)")
		assert_eq(fires[0].kind, "rocket_col")
		assert_true(EV.same_set(EV.to_set(fires[0].cells), EV.to_set(EV.col_cells(6))), "it clears column 6")


func test_ir16_finale_rocket_cell_does_not_depend_on_the_direction() -> void:
	for s in range(1, 21):
		var events: Array[BoardEvent] = _finale(_only_one_plain_board(s, 1))
		var fires: Array = EV.of_type(events, "rocket_fire")
		assert_true(fires.size() >= 1, "seed %d: the finale Rocket fires" % s)
		if fires.size() >= 1:
			assert_eq(fires[0].cell, Vector2i(6, 2), "seed %d: only (6,2) is a legal cell" % s)


func test_ir16_finale_rocket_never_lands_on_a_special_hatchling_or_covered_piece() -> void:
	var avoid: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3)]
	var seen: Dictionary = {}
	for s in range(1, 101):
		var board: BoardModel = _board(s, 1)
		board.palette = BB.spread_palette()
		BB.put(board, "RF", [[1, 1]])
		BB.put(board, "H", [[2, 2]])
		board.set_overlay(3, 3, "OB03", 1)
		var events: Array[BoardEvent] = _finale(board)
		var fires: Array = EV.of_type(events, "rocket_fire")
		assert_true(fires.size() >= 1, "seed %d: the finale Rocket fires" % s)
		if fires.size() >= 1:
			var c: Vector2i = fires[0].cell
			seen[c] = true
			assert_false(avoid.has(c), "seed %d: finale Rocket placed on %s" % [s, c])
	assert_true(seen.size() > 10, "the cell is random across seeds (%d distinct cells)" % seen.size())


func test_ir16_finale_direction_is_drawn_before_the_cell() -> void:
	# For each seed the direction must be the FIRST draw of the level's seeded RNG. We don't know which
	# RNG call the code makes, so accept any of the usual ones (randi_range(0,1) or randf(), either
	# mapping to row) and require the same one to explain all 40 seeds. A cell drawn first would use up the
	# first draw and no pattern would fit.
	var actual: Array[bool] = []
	var candidates: Array = [[], [], [], []]
	for s in range(1, 41):
		var board: BoardModel = _board(s, 1)
		board.palette = BB.spread_palette()
		var kinds: Array = _kinds(_finale(board))
		assert_true(kinds.size() >= 1, "seed %d fired" % s)
		actual.append(kinds.size() >= 1 and kinds[0] == "rocket_row")
		var a: RandomNumberGenerator = RandomNumberGenerator.new()
		a.seed = s
		var by_range: bool = a.randi_range(0, 1) == 0
		var b: RandomNumberGenerator = RandomNumberGenerator.new()
		b.seed = s
		var by_float: bool = b.randf() < 0.5
		candidates[0].append(by_range)
		candidates[1].append(not by_range)
		candidates[2].append(by_float)
		candidates[3].append(not by_float)
	var fits: bool = false
	for c in candidates:
		if c == actual:
			fits = true
	assert_true(fits, "the direction is the first draw from board.rng (got %s)" % [actual])


func test_ir16_finale_with_no_uncovered_plain_piece_still_fires_every_rocket() -> void:
	# Win coins = 20 + 5 x finale Rockets (30 here) are counted outside MatchResolver; this checks the 2 fires.
	var board: BoardModel = _board(5, 2)
	board.palette = BB.spread_palette()
	for y in range(9):
		for x in range(9):
			BB.put(board, "O", [[x, y]])
	var events: Array[BoardEvent] = _finale(board)
	assert_eq(EV.count(events, "rocket_fire"), 2, "2 finale Rocket fire events")
	assert_eq(board.moves, 0)


func test_ir16_pending_fallback_cell_contents() -> void:
	pending("OQ-60: when no uncovered plain piece is left, what the fallback finale Rocket does to what is in its random playable cell (special, covered piece, hatchling, obstacle)")


func test_ir16_pending_settling_between_finale_rockets() -> void:
	pending("OQ-60: whether pieces fall, refill and cascades resolve between one finale Rocket and the next")
