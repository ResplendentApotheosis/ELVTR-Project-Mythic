# GUT tests for the win-finale Rockets of IR-16 / IR-05 (leftover moves become Rockets with random direction, OQ-40).
# API: MatchResolver.fire_finale(board, directions) from tests/API_CONTRACT.md section 7. The call goes
# through load() so a missing function fails these tests instead of breaking the script.
# Odds and mix (OQ-53) are pending.
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


func test_ir16_finale_rockets_fire_one_after_another_with_the_board_settling() -> void:
	var board: BoardModel = _board(5, 2)
	var events: Array[BoardEvent] = _finale(board, ["rocket_row", "rocket_row"])
	var i1: int = EV.index_of(events, "rocket_fire", 0)
	var i2: int = EV.index_of(events, "rocket_fire", 1)
	assert_true(i1 >= 0 and i2 > i1, "two fires")
	var i_fall: int = EV.index_after(events, "fall", i1)
	var i_refill: int = EV.index_after(events, "refill", i_fall)
	assert_true(i_fall > i1 and i_refill > i_fall and i_refill < i2, "fall and refill between the two Rockets")
	assert_false(BB.has_match(board), "the board ends stable")
	assert_eq(BB.empty_cells(board).size(), 0)


func test_ir16_pending_finale_odds_and_mix() -> void:
	pending("OQ-53: odds of row vs column, and whether a finale with 2+ Rockets must contain both")
