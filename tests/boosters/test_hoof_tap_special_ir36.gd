# GUT tests for IR-36 (a booster sets off a special it hits, OQ-106 B) with Option A of OQ-107..OQ-110 (provisional).
# Hoof Tap on a Rocket / Firecracker / Crane / Orb, covered specials, wins, Tail Slam and Bamboo Dash on specials.
# API: tests/API_CONTRACT.md 10.6 and 10.10. Check: run the GUT suite.
extends "res://tests/helpers/goal_test_base.gd"


func _board(moves: int = 10) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = moves
	return board


## Indices of events of these types, in order (to compare positions).
func _fire_indices(events: Array, type: String) -> Array:
	var out: Array = []
	for i in range(events.size()):
		if events[i].type == type:
			out.append(i)
	return out


func _no_fail(events: Array) -> void:
	assert_eq(EV.count(events, "fail"), 0, "a booster never causes a fail (IR-62)")


# ---------------------------------------------------------------- Rocket

func test_IR36_hoof_tap_on_a_rocket_lifts_it_then_it_fires_from_its_cell() -> void:
	var board: BoardModel = _board()
	BB.put(board, "R-", [[4, 4]])
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(board.moves, 10, "IR-62: no move used")
	assert_eq(EV.count(events, "rocket_fire"), 1)
	var fire: BoardEvent = EV.of_type(events, "rocket_fire")[0]
	assert_eq(fire.cell, Vector2i(4, 4))
	assert_eq(fire.kind, "rocket_row")
	assert_true(EV.same_set(EV.to_set(fire.cells), EV.to_set(EV.row_cells(4))), "row 4")
	# booster clear (4,4), fall, refill, Rocket fire (row 4), clear, fall, refill
	var seq: Array = EV.sequence(events, ["clear", "fall", "refill", "rocket_fire"])
	assert_eq(seq.slice(0, 4), ["clear", "fall", "refill", "rocket_fire"], "the Rocket is lifted; fall and refill come BEFORE it fires")
	assert_eq(seq.slice(4), ["clear", "fall", "refill"], "then the Rocket's own clear, fall, refill")
	var first_clear: BoardEvent = EV.of_type(events, "clear")[0]
	assert_eq(first_clear.source, "booster")
	assert_true(first_clear.cells.has(Vector2i(4, 4)), "the booster's clear is the tapped cell")
	assert_eq(first_clear.cells.size(), 1)
	_no_fail(events)


func test_IR36_hoof_tap_on_a_rocket_chains_into_another_rocket() -> void:
	var board: BoardModel = _board()
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "Y|", [[6, 4]])
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 2)
	if fires.size() < 2:
		return
	assert_eq(fires[0].cell, Vector2i(4, 4))
	assert_eq(fires[0].kind, "rocket_row")
	assert_eq(fires[1].cell, Vector2i(6, 4), "the set-off column Rocket fires from where it was hit")
	assert_eq(fires[1].kind, "rocket_col")
	var idx: Array = _fire_indices(events, "rocket_fire")
	assert_gt(EV.count_between(events, "fall", int(idx[0]), int(idx[1])), 0, "a fall between the two (IR-41)")
	assert_gt(EV.count_between(events, "refill", int(idx[0]), int(idx[1])), 0, "a refill between the two")
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- Firecracker

func test_IR36_hoof_tap_on_a_firecracker_blasts_twice_and_the_bramble_takes_one_hit() -> void:
	var board: BoardModel = _board()
	BB.put(board, "RF", [[4, 4]])
	board.add_content("OB02", 5, 4, 2)
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(board.moves, 10)
	assert_eq(EV.blast_centres(events, 1), [Vector2i(4, 4)], "blast 1 on the Firecracker's cell")
	assert_eq(EV.blast_centres(events, 2), [Vector2i(4, 4)], "blast 2 on the same cell (IR-17)")
	assert_eq(board.content_hp(5, 4), 1, "two blasts are one hit (IR-12): 2 layers -> 1")
	var seq: Array = EV.sequence(events, ["clear", "fall", "refill", "blast"])
	assert_eq(seq.slice(0, 4), ["clear", "fall", "refill", "blast"], "lifted, fall, refill, then blast 1")
	_no_fail(events)


# ---------------------------------------------------------------- Crane

func test_IR36_hoof_tap_on_a_crane_flies_to_the_only_obstacle() -> void:
	var board: BoardModel = _board()
	BB.put(board, "RC", [[4, 4]])
	board.add_content("OB02", 7, 7, 1)
	board.goals = ["OB02"]
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(EV.cells_of(events, "crane_target"), [Vector2i(7, 7)])
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 4)], "take-off from where it was hit")
	assert_eq(EV.cells_of(events, "crane_landing"), [Vector2i(7, 7)])
	assert_eq(board.content_hp(7, 7), 0, "bramble removed")
	assert_eq(board.moves, 10)
	var i_booster_clear: int = EV.index_of_clear(events, "booster")
	assert_gte(i_booster_clear, 0)
	assert_gt(EV.index_of(events, "crane_takeoff"), EV.index_of(events, "fall"), "fall and refill before the take-off")
	_no_fail(events)


func test_IR36_hoof_tap_on_a_crane_prefers_the_fragment_cocoon_over_a_bramble() -> void:
	var board: BoardModel = _board()
	BB.put(board, "RC", [[4, 4]])
	board.add_content("OB02", 7, 7, 1)
	board.add_content("OB07", 2, 1, 3, 1, 1, true)
	board.goals = ["OB02", "fragment"]
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(EV.cells_of(events, "crane_target"), [Vector2i(2, 1)], "IR-49: the cocoon first")
	assert_eq(board.content_hp(7, 7), 1, "the bramble was not touched")
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- Jade Orb (OQ-107 A)

func test_IR36_OQ107_A_hoof_tap_on_a_jade_orb_removes_it_without_effect() -> void:
	var board: BoardModel = BB.with_counts({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(4, 4): "O"})
	board.palette = BB.spread_palette()
	board.moves = 10
	var before: Dictionary = {}
	for c in ["R", "Y", "B", "G"]:
		before[c] = BB.find_color(board, c).size()
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(EV.count(events, "orb_fire"), 0, "no colour-clear event (row 04)")
	assert_eq(EV.count(events, "rocket_fire"), 0)
	for c in ["R", "Y", "B", "G"]:
		assert_eq(BB.find_color(board, c).size(), before[c], "all %s pieces stay" % c)
	assert_eq(BB.find_kind(board, "orb").size(), 0, "the Orb is gone")
	assert_eq(board.moves, 10)
	for e in EV.of_type(events, "clear"):
		assert_ne(e.source, "orb")
	_no_fail(events)


func test_IR36_OQ107_A_orb_alone_on_goo_hp2_leaves_goo_hp1() -> void:
	var board: BoardModel = _board()
	BB.put(board, "O", [[3, 3]])
	board.set_underlay(3, 3, "OB10", 2)
	var events: Variant = booster("hoof_tap", [board, Vector2i(3, 3)])
	if events == null:
		return
	assert_eq(board.underlay_hp(3, 3), 1, "the booster's hit on the cell still happens")
	assert_eq(EV.count(events, "orb_fire"), 0)
	assert_eq(BB.find_kind(board, "orb").size(), 0)
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- covered specials (OQ-108 A, OQ-109 A)

func test_IR36_OQ108_A_hoof_tap_on_a_rocket_under_moss_hp1_clears_it_and_it_fires() -> void:
	var board: BoardModel = _board()
	BB.put(board, "R-", [[2, 6]])
	board.set_overlay(2, 6, "OB03", 1)
	var events: Variant = booster("hoof_tap", [board, Vector2i(2, 6)])
	if events == null:
		return
	assert_eq(board.overlay_hp(2, 6), 0, "the moss is removed")
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 1, "the covered Rocket fires (OQ-108 A)")
	if fires.size() == 1:
		assert_eq(fires[0].cell, Vector2i(2, 6))
		assert_eq(fires[0].kind, "rocket_row")
		assert_true(fires[0].cells.has(Vector2i(8, 6)), "along row 6")
	assert_gt(EV.index_of(events, "rocket_fire"), EV.index_of(events, "fall"), "after the fall")
	assert_eq(board.moves, 10)


func test_IR36_OQ109_A_rocket_under_moss_hp2_takes_the_booster_hit_and_its_own() -> void:
	var board: BoardModel = _board()
	BB.put(board, "R-", [[2, 6]])
	board.set_overlay(2, 6, "OB03", 2)
	var events: Variant = booster("hoof_tap", [board, Vector2i(2, 6)])
	if events == null:
		return
	assert_eq(EV.count(events, "rocket_fire"), 1, "it fires")
	assert_eq(board.overlay_hp(2, 6), 0, "booster hit (2 -> 1) then the Rocket's own hit on its cell (1 -> 0)")
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- win

func test_IR36_hoof_tap_on_a_rocket_can_win_with_goal_done_then_win() -> void:
	var board: BoardModel = _board()
	BB.put(board, "R-", [[4, 4]])
	board.add_content("OB02", 7, 4, 1)
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(board.content_hp(7, 4), 0, "bramble removed by the Rocket")
	assert_eq(EV.count(events, "goal_done"), 1)
	var i_cleared: int = EV.index_of(events, "obstacle_cleared")
	var i_goal: int = EV.index_of(events, "goal_done")
	assert_true(i_cleared >= 0 and i_goal == i_cleared + 1, "goal done right after the clear that reached it")
	assert_gt(i_goal, EV.index_of(events, "rocket_fire"))
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(events[events.size() - 1].type, "win", "win is the last event, after the board settles (IR-56)")
	assert_eq(board.moves, 10, "IR-62")


# ---------------------------------------------------------------- Tail Slam and Bamboo Dash (OQ-110 A)

func test_IR36_OQ110_A_tail_slam_sets_off_a_special_in_its_3x3() -> void:
	var board: BoardModel = _board()
	BB.put(board, "R-", [[5, 5]])
	var events: Variant = booster("tail_slam", [board, Vector2i(4, 4)])
	if events == null:
		return
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 1, "the Rocket in the 3x3 fires (OQ-110 A)")
	if fires.size() == 1:
		assert_eq(fires[0].cell, Vector2i(5, 5))
	assert_eq(board.moves, 10)
	_no_fail(events)


func test_IR36_OQ110_A_bamboo_dash_sets_off_a_special_in_its_row() -> void:
	var board: BoardModel = _board()
	BB.put(board, "Y|", [[6, 4]])
	var events: Variant = booster("bamboo_dash", [board, "row", 4])
	if events == null:
		return
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 1, "the column Rocket in the row fires (OQ-110 A)")
	if fires.size() == 1:
		assert_eq(fires[0].cell, Vector2i(6, 4))
		assert_eq(fires[0].kind, "rocket_col")
	assert_eq(board.moves, 10)
	_no_fail(events)
