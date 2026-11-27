# GUT tests for IR-61 dew goals: progress stops at the count (OQ-73) and the validator needs the count
# to be more than the seed cells (OQ-74). API: tests/API_CONTRACT.md section 10. Check: run the GoalTracker tests.
extends "res://tests/helpers/goal_test_base.gd"


func _count_errors(board: BoardModel, count: int) -> Variant:
	return tracker_static("goal_count_errors", [[obstacle_goal("OB04", count)], board])


func _board_with_seeds(n: int) -> BoardModel:
	var board: BoardModel = BB.blank()
	for i in range(n):
		BB.set_dew(board, i, 0)
	return board


func test_ir61_dew_progress_stops_at_the_count_9_of_10() -> void:
	# 9 cells have dew; a 3-match on dew (3,5) gives dew to (2,5) and (4,5): 11 cells, reported 10/10.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	for x in range(8):
		BB.set_dew(board, x, 0)
	BB.set_dew(board, 3, 5)
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 10)])
	if t == null:
		return
	assert_eq(units(t, 0), 9, "9/10 at the start")
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_eq(BB.dew_cells(board).size(), 11, "11 cells have dew")
	assert_eq(units(t, 0), 10, "reported 10/10, not 11/10")
	assert_true(t.is_goal_done(0), "goal done")
	assert_eq(EV.count(events, "win"), 1, "one win event")


func test_ir61_dew_9x9_count_72_row_rocket_and_cascade_stays_72_of_72() -> void:
	# 9x9, 70 cells have dew. Bare cells: (0..4,4), (3,3), (5,3), (0,0), (1,0), (2,0), (6,0) = 11.
	var bare: Array = [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4),
			Vector2i(3, 3), Vector2i(5, 3), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(6, 0)]
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	assert_eq(BB.dew_level(board, bare), 70, "precondition: 70 cells have dew")
	# Row 4 holds a row Rocket; clearing row 4 drops row 2 onto row 3: the G line (3,3),(4,3),(5,3) is the cascade
	# on dew at (4,3), giving dew to (3,3) and (5,3).
	BB.put(board, "R-", [[0, 4]])
	BB.put(board, "G", [[3, 2], [4, 2], [5, 2]])
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 72)])
	if t == null:
		return
	assert_eq(units(t, 0), 70, "70/72 at the start")
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(BB.dew_cells(board).size(), 77, "75 after the Rocket, 77 after the cascade")
	assert_eq(units(t, 0), 72, "still 72/72")
	assert_true(t.is_goal_done(0), "goal done")
	assert_eq(EV.count(events, "win"), 1, "one win event once the move settles")


func test_ir61_validator_dew_with_5_seeds_count_4_is_rejected() -> void:
	var r: Variant = _count_errors(_board_with_seeds(5), 4)
	if r != null:
		assert_false(r.is_empty(), "count 4 < 5 seeds is rejected")


func test_ir61_validator_dew_with_5_seeds_count_5_is_rejected() -> void:
	var r: Variant = _count_errors(_board_with_seeds(5), 5)
	if r != null:
		assert_false(r.is_empty(), "count 5 = 5 seeds is rejected (OQ-74)")


func test_ir61_validator_dew_with_5_seeds_count_6_is_valid() -> void:
	var r: Variant = _count_errors(_board_with_seeds(5), 6)
	if r != null:
		assert_true(r.is_empty(), "count 6 is valid: %s" % [r])


func test_ir61_validator_dew_with_5_seeds_count_72_is_valid() -> void:
	var r: Variant = _count_errors(_board_with_seeds(5), 72)
	if r != null:
		assert_true(r.is_empty(), "count 72 is valid: %s" % [r])


func test_ir61_validator_dew_with_5_seeds_count_73_is_rejected() -> void:
	var r: Variant = _count_errors(_board_with_seeds(5), 73)
	if r != null:
		assert_false(r.is_empty(), "count 73 is above 90% of 81")


func test_ir61_validator_dew_no_seeds_count_1_is_valid() -> void:
	var r: Variant = _count_errors(BB.blank(), 1)
	if r != null:
		assert_true(r.is_empty(), "count 1 is valid: %s" % [r])


func test_ir61_validator_dew_no_seeds_count_0_is_rejected() -> void:
	var r: Variant = _count_errors(BB.blank(), 0)
	if r != null:
		assert_false(r.is_empty(), "count 0 is rejected")
