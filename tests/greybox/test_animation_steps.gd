# GUT tests for AnimationSteps (events -> animation steps). Pure logic. Also IR-16 (a wait before each finale Rocket).
# API: tests/API_CONTRACT.md section 13. Check: run the GUT suite.
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")


func _ev(type: String, cells: Array = [], cell: Vector2i = Vector2i(-1, -1)) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new(type)
	for c in cells:
		e.cells.append(c)
	e.cell = cell
	return e


func _types(steps: Array[Dictionary]) -> Array:
	var out: Array = []
	for s in steps:
		out.append(s.type)
	return out


func _build(events: Array[BoardEvent], board: BoardModel = null) -> Array[Dictionary]:
	var b: BoardModel = board if board != null else BB.blank(4, 4)
	return AnimationSteps.build(events, BoardSnapshot.piece_grid(b), b)


func test_empty_events_gives_only_sync() -> void:
	var steps: Array[Dictionary] = _build([] as Array[BoardEvent])
	assert_eq(_types(steps), ["sync"])


func test_steps_follow_event_order_and_match_makes_no_step() -> void:
	var evs: Array[BoardEvent] = [
		_ev("swap", [Vector2i(0, 0), Vector2i(1, 0)]),
		_ev("match", [Vector2i(0, 0)]),
		_ev("clear", [Vector2i(0, 0)]),
		_ev("fall"),
		_ev("refill", [Vector2i(0, 0)]),
	]
	assert_eq(_types(_build(evs)), ["swap", "clear", "fall", "spawn", "sync"])


func test_invalid_swap_step() -> void:
	var evs: Array[BoardEvent] = [_ev("invalid_swap", [Vector2i(0, 0), Vector2i(1, 0)])]
	var steps: Array[Dictionary] = _build(evs)
	assert_eq(_types(steps), ["invalid_swap", "sync"])
	assert_eq(steps[0].duration, AnimationSteps.INVALID_SWAP)


func test_GDD_timings() -> void:
	assert_eq(AnimationSteps.SWAP, 0.15)
	assert_eq(AnimationSteps.INVALID_SWAP, 0.2)
	assert_eq(AnimationSteps.CLEAR, 0.12)
	assert_eq(AnimationSteps.SPECIAL, 0.25)
	assert_eq(AnimationSteps.BLAST, 0.2)
	assert_eq(AnimationSteps.FINALE_GAP, 0.15)


func test_IR16_finale_rocket_gets_wait_before_it() -> void:
	var a: BoardEvent = _ev("special_created", [], Vector2i(1, 1))
	a.kind = "rocket_row"
	a.color = "R"
	a.data = {"finale": true}
	var b: BoardEvent = _ev("special_created", [], Vector2i(2, 2))
	b.kind = "rocket_col"
	b.color = "R"
	b.data = {"finale": true}
	var evs: Array[BoardEvent] = [a, _ev("rocket_fire", [Vector2i(1, 1)]), b, _ev("rocket_fire", [Vector2i(2, 2)])]
	assert_eq(_types(_build(evs)), ["wait", "special", "fire", "wait", "special", "fire", "sync"])


func test_ordinary_special_has_no_wait() -> void:
	var a: BoardEvent = _ev("special_created", [], Vector2i(1, 1))
	a.kind = "firecracker"
	a.color = "Y"
	var steps: Array[Dictionary] = _build([a] as Array[BoardEvent])
	assert_eq(_types(steps), ["special", "sync"])
	assert_eq(steps[0].look.kind, "firecracker")
	assert_eq(steps[0].look.color, "Y")


func test_win_and_fail_end_with_outcome_then_sync() -> void:
	for t in ["win", "fail"]:
		var e: BoardEvent = _ev(t)
		e.data = {"moves_left": 2}
		var steps: Array[Dictionary] = _build([e] as Array[BoardEvent])
		assert_eq(_types(steps), ["outcome", "sync"])
		assert_eq(steps[0].name, t)
		assert_eq(steps.back().type, "sync")


func test_hit_and_obstacle_cleared_and_collected_steps() -> void:
	var h: BoardEvent = _ev("hit", [], Vector2i(2, 2))
	h.data = {"layer": "overlay", "id": "OB03", "hp": 0}
	var c: BoardEvent = _ev("obstacle_cleared", [], Vector2i(2, 2))
	c.data = {"id": "OB03"}
	var k: BoardEvent = _ev("collected", [], Vector2i(0, 3))
	k.data = {"item": "OB11"}
	var steps: Array[Dictionary] = _build([h, c, k] as Array[BoardEvent])
	assert_eq(_types(steps), ["hit", "obstacle_cleared", "collect", "sync"])
	assert_eq(steps[0].layer, "overlay")
	assert_eq(steps[0].hp, 0)
	assert_eq(steps[2].item, "OB11")


func test_shrine_lit_becomes_obstacle_cleared() -> void:
	var s: BoardEvent = _ev("shrine_lit", [], Vector2i(1, 1))
	assert_eq(_types(_build([s] as Array[BoardEvent])), ["obstacle_cleared", "sync"])


func test_fire_events_make_fire_steps() -> void:
	var evs: Array[BoardEvent] = [_ev("rocket_fire", [Vector2i(0, 0)]), _ev("orb_fire"), _ev("combo"), _ev("crane_target", [], Vector2i(1, 1)), _ev("blast", [Vector2i(1, 1)], Vector2i(1, 1))]
	assert_eq(_types(_build(evs)), ["fire", "fire", "fire", "fire", "fire", "sync"])


func test_unknown_event_makes_no_step() -> void:
	assert_eq(_types(_build([_ev("booster")] as Array[BoardEvent])), ["sync"])


func test_total_duration_adds_steps() -> void:
	var evs: Array[BoardEvent] = [_ev("swap", [Vector2i(0, 0), Vector2i(1, 0)]), _ev("clear", [Vector2i(0, 0)])]
	var steps: Array[Dictionary] = _build(evs)
	assert_almost_eq(AnimationSteps.total_duration(steps), AnimationSteps.SWAP + AnimationSteps.CLEAR, 0.0001)


func test_apply_fall_moves_in_order() -> void:
	var grid: Dictionary = {Vector2i(0, 0): 1, Vector2i(0, 1): 2}
	AnimationSteps.apply_fall(grid, [
		{"from": Vector2i(0, 1), "to": Vector2i(0, 2)},
		{"from": Vector2i(0, 0), "to": Vector2i(0, 1)},
	])
	assert_eq(grid, {Vector2i(0, 2): 2, Vector2i(0, 1): 1})


func test_new_piece_that_stays_gets_its_final_look() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	var before: Dictionary = BoardSnapshot.piece_grid(board)
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _ev("refill", [Vector2i(0, 0)])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_eq(looks[1].size(), 1)
	assert_eq(looks[1][0].cell, Vector2i(0, 0))
	assert_eq(looks[1][0].look.color, "R", "looks like the cell on the final board")


func test_new_piece_destroyed_before_end_is_unknown() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	board.clear_piece(0, 0)
	var before: Dictionary = BoardSnapshot.piece_grid(BB.from_rows(["R Y", "B G"]))
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _ev("refill", [Vector2i(0, 0)]), _ev("clear", [Vector2i(0, 0)])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_eq(looks[1][0].look, AnimationSteps.UNKNOWN_LOOK)


func test_new_piece_matched_away_takes_match_colour() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	board.clear_piece(0, 0)
	var before: Dictionary = BoardSnapshot.piece_grid(BB.from_rows(["R Y", "B G"]))
	var m: BoardEvent = _ev("match", [Vector2i(0, 0)])
	m.color = "G"
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _ev("refill", [Vector2i(0, 0)]), m, _ev("clear", [Vector2i(0, 0)])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_eq(looks[1][0].look.color, "G")


# ---------------------------------------------------------------- refill events carry colours (owner, 28 Nov 2026)
# The three tests above build refill events WITHOUT data.colors: they now check the safe fallback for old/foreign events.

func _refill(cells: Array, colors: Variant = null) -> BoardEvent:
	var e: BoardEvent = _ev("refill", cells)
	if colors != null:
		e.data = {"colors": colors}
	return e


func test_refill_colour_comes_from_the_event() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	var before: Dictionary = BoardSnapshot.piece_grid(board)
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _refill([Vector2i(0, 0)], ["B"])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_eq(looks[1][0].look.color, "B", "the event's colour wins over the final board's R")
	assert_eq(looks[1][0].look.kind, "plain")


func test_refill_destroyed_later_is_not_unknown_when_the_event_has_colours() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	board.clear_piece(0, 0)
	var before: Dictionary = BoardSnapshot.piece_grid(BB.from_rows(["R Y", "B G"]))
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _refill([Vector2i(0, 0)], ["Y"]), _ev("clear", [Vector2i(0, 0)])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_ne(looks[1][0].look, AnimationSteps.UNKNOWN_LOOK)
	assert_eq(looks[1][0].look.color, "Y")


func test_refill_several_cells_each_get_their_own_colour() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	board.clear_piece(0, 0)
	board.clear_piece(1, 0)
	var before: Dictionary = BoardSnapshot.piece_grid(BB.from_rows(["R Y", "B G"]))
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0), Vector2i(1, 0)]), _refill([Vector2i(0, 0), Vector2i(1, 0)], ["G", "B"]), _ev("clear", [Vector2i(0, 0), Vector2i(1, 0)])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_eq(looks[1][0].look.color, "G")
	assert_eq(looks[1][1].look.color, "B")


func test_refill_with_colours_of_the_wrong_length_falls_back_safely() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	board.clear_piece(0, 0)
	var before: Dictionary = BoardSnapshot.piece_grid(BB.from_rows(["R Y", "B G"]))
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _refill([Vector2i(0, 0)], []), _ev("clear", [Vector2i(0, 0)])]
	var looks: Dictionary = AnimationSteps.new_piece_looks(evs, before, board)
	assert_eq(looks[1][0].look, AnimationSteps.UNKNOWN_LOOK, "no usable colour data: the old fallback")


func test_spawn_step_uses_the_refill_colour() -> void:
	var board: BoardModel = BB.from_rows(["R Y", "B G"])
	board.clear_piece(0, 0)
	var evs: Array[BoardEvent] = [_ev("clear", [Vector2i(0, 0)]), _refill([Vector2i(0, 0)], ["B"]), _ev("clear", [Vector2i(0, 0)])]
	var steps: Array[Dictionary] = AnimationSteps.build(evs, BoardSnapshot.piece_grid(BB.from_rows(["R Y", "B G"])), board)
	assert_eq(_types(steps), ["clear", "spawn", "clear", "sync"])
	assert_eq(steps[1].pieces[0].look.color, "B")


func test_real_move_never_gives_a_grey_question_mark_for_a_refill() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	board.moves = 10
	var before: Dictionary = BoardSnapshot.piece_grid(board)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var looks: Dictionary = AnimationSteps.new_piece_looks(events, before, board)
	var seen: int = 0
	for i in looks:
		if events[i].type != "refill":
			continue
		for p in looks[i]:
			seen += 1
			assert_ne(p.look.color, "?", "refill piece at %s has a real colour" % p.cell)
	assert_gt(seen, 0)
