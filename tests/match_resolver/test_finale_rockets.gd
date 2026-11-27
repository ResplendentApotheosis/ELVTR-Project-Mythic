# GUT tests for the win-finale Rockets of IR-16 / IR-05 (leftover moves become Rockets with random direction, OQ-40).
# API: MatchResolver.fire_finale(board, directions) from tests/API_CONTRACT.md section 7. The call goes
# through load() so a missing function fails these tests instead of breaking the script.
# Odds (OQ-53 A), placement (OQ-58 A), the fallback cell and one-at-a-time settling (OQ-60 A) are tested.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


func _finale(board: BoardModel, directions: Array = [], cells: Array = []) -> Array[BoardEvent]:
	var out: Array[BoardEvent] = []
	var script: GDScript = load("res://src/match/match_resolver.gd")
	if not script.has_method("fire_finale"):
		return out
	var result: Array = script.call("fire_finale", board, directions, cells) if not cells.is_empty() else script.call("fire_finale", board, directions)
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


# ---------------------------------------------------------------- OQ-60 A: fallback cell and settling

# Every cell holds a Jade Orb (a special, so no uncovered plain piece), except what the test then puts in (1,1).
func _no_plain_board(moves: int) -> BoardModel:
	var board: BoardModel = _board(5, moves)
	board.palette = BB.spread_palette()
	for y in range(9):
		for x in range(9):
			BB.put(board, "O", [[x, y]])
	return board


func test_ir16_fallback_rocket_sets_off_a_firecracker_instead_of_replacing_it() -> void:
	var board: BoardModel = _no_plain_board(1)
	BB.put(board, "RF", [[1, 1]])
	var events: Array[BoardEvent] = _finale(board, ["rocket_row"], [Vector2i(1, 1)])
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 1, "one finale Rocket")
	if fires.size() == 1:
		assert_eq(fires[0].cell, Vector2i(1, 1), "fires from the stubbed fallback cell")
		assert_eq(fires[0].kind, "rocket_row")
		assert_true(EV.same_set(EV.to_set(fires[0].cells), EV.to_set(EV.row_cells(1))), "along row 1")
	for e in EV.of_type(events, "special_created"):
		assert_false(e.data.get("finale", false), "the fallback Rocket replaces nothing, so no placement event")
	assert_eq(EV.blast_centres(events, 1), [Vector2i(1, 1)], "the Firecracker was set off: blast 1 at (1,1)")
	assert_eq(EV.blast_centres(events, 2), [Vector2i(1, 1)], "and blast 2 at (1,1) after the fall")


func test_ir16_fallback_rocket_leaves_a_fragment_drop_item_on_the_board() -> void:
	var board: BoardModel = _no_plain_board(1)
	BB.put(board, "Q", [[1, 1]])
	var events: Array[BoardEvent] = _finale(board, ["rocket_row"], [Vector2i(1, 1)])
	assert_eq(EV.count(events, "rocket_fire"), 1, "the Rocket fires along row 1")
	assert_eq(board.get_kind(1, 1), "drop", "the fragment is still on the board")
	assert_eq(board.get_drop_item(1, 1), "fragment", "still the fragment (IR-28)")
	assert_eq(board.collected_count("fragment"), 0, "the Rocket does not collect it")


func test_ir16_fallback_rocket_hits_the_moss_over_its_cell_once() -> void:
	var board: BoardModel = _no_plain_board(1)
	BB.put(board, "Y", [[1, 1], [1, 0]])
	board.set_overlay(1, 1, "OB03", 2)
	var events: Array[BoardEvent] = _finale(board, ["rocket_row"], [Vector2i(1, 1)])
	assert_eq(EV.count(events, "rocket_fire"), 1)
	assert_eq(board.overlay_hp(1, 1), 1, "moss hp 2 -> 1 (one hit)")
	assert_eq(board.get_kind(1, 1), "plain", "the piece that fell in is there, still covered")
	assert_eq(board.overlay_id(1, 1), "OB03", "still covered")


func test_ir16_fallback_rocket_hits_a_bramble_layer() -> void:
	var board: BoardModel = _no_plain_board(1)
	board.add_content("OB02", 1, 1, 2)
	var events: Array[BoardEvent] = _finale(board, ["rocket_row"], [Vector2i(1, 1)])
	assert_eq(EV.count(events, "rocket_fire"), 1)
	assert_eq(board.content_hp(1, 1), 1, "bramble 2 layers -> 1")
	var cleared: Dictionary = EV.cleared(events)
	assert_true(cleared.has(Vector2i(0, 1)) and cleared.has(Vector2i(8, 1)), "the rest of row 1 is cleared as usual")


func test_ir16_finale_rockets_settle_completely_one_at_a_time() -> void:
	var board: BoardModel = _board(5, 2)
	board.palette = BB.spread_palette()
	BB.put(board, "RF", [[7, 4]])
	var events: Array[BoardEvent] = _finale(board, ["rocket_row", "rocket_row"], [Vector2i(4, 4), Vector2i(4, 6)])
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 2, "two Rockets")
	if fires.size() != 2:
		return
	assert_eq(fires[0].cell, Vector2i(4, 4))
	assert_eq(fires[1].cell, Vector2i(4, 6))
	var i_f1: int = EV.index_of(events, "rocket_fire", 0)
	var i_f2: int = EV.index_of(events, "rocket_fire", 1)
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	assert_true(i_f1 < i_b1 and i_b1 < i_b2 and i_b2 < i_f2, "Rocket 1, blast 1, blast 2, then Rocket 2 (got %s)" % [EV.sequence(events, ["rocket_fire", "blast"])])
	var fall_after_f1: int = EV.index_after(events, "fall", i_f1)
	assert_true(fall_after_f1 > i_f1 and fall_after_f1 < i_b1, "fall before blast 1")
	var refill_after_b2: int = EV.index_after(events, "refill", i_b2)
	assert_true(refill_after_b2 > i_b2 and refill_after_b2 < i_f2, "blast 2's fall and refill come before Rocket 2")


func test_ir16_second_finale_rocket_uses_the_settled_board() -> void:
	# 3x3 of Jade Orbs with one plain Y at (1,1). Rocket 1 (row) replaces the Y and clears row 1; the
	# Orbs above fall and row 0 refills with plain pieces. Only row 0 holds plain pieces when Rocket 2
	# is drawn, so it must appear in row 0 (before settling, no cell could be chosen but (1,1)).
	for s in range(1, 11):
		var board: BoardModel = BB.blank(3, 3, s)
		board.palette = BB.spread_palette()
		board.moves = 2
		for y in range(3):
			for x in range(3):
				BB.put(board, "O", [[x, y]])
		BB.put(board, "Y", [[1, 1]])
		var events: Array[BoardEvent] = _finale(board, ["rocket_row", "rocket_row"])
		var fires: Array = EV.of_type(events, "rocket_fire")
		assert_eq(fires.size(), 2, "seed %d: two Rockets" % s)
		if fires.size() == 2:
			assert_eq(fires[0].cell, Vector2i(1, 1), "seed %d: Rocket 1 replaces the only plain piece" % s)
			assert_eq(fires[1].cell.y, 0, "seed %d: Rocket 2 is on a refilled plain piece in row 0, got %s" % [s, fires[1].cell])
