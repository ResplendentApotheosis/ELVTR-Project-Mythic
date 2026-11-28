# GUT tests for IR-36 (a booster sets off a special, OQ-106 B; Hoof Tap on a Jade Orb = Orb tap counted after the fall, OQ-107 B, OQ-112 B)
# with OQ-108..OQ-111 Option A and OQ-113 A (provisional: the Orb's own cell is not counted or cleared).
# Hoof Tap on a Rocket / Firecracker / Crane / Orb, covered specials, wins, Tail Slam and Bamboo Dash on specials.
# API: tests/API_CONTRACT.md 10.6 and 10.10. Check: run the GUT suite.
extends "res://tests/helpers/goal_test_base.gd"

const ORB: Vector2i = Vector2i(4, 4)


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


# ---------------------------------------------------------------- Jade Orb (OQ-107 B, OQ-112 B: an Orb tap counted after the fall)

## Reserved cells of the Orb boards: the Orb at (4,4) and a unique filler at (4,3), so the piece that
## falls into the Orb's cell is a filler (never counted, never cleared: OQ-113 A) and the counts below
## are exactly the counts on the refilled board. The refill adds only colours that are not R/Y/B/G.
func _reserved(extra: Dictionary = {}) -> Dictionary:
	var reserved: Dictionary = {ORB: "O", Vector2i(4, 3): "."}
	for k in extra:
		reserved[k] = extra[k]
	return reserved


func _orb_board(counts: Dictionary, extra: Dictionary = {}) -> BoardModel:
	var board: BoardModel = BB.with_counts(counts, _reserved(extra))
	board.palette = BB.spread_palette()
	board.moves = 10
	return board


## Runs Hoof Tap on the Orb at (4,4), trying board seeds 1..80 until no cascade ("match" event) follows
## (only where exact board-state asserts need it). Deterministic. `setup` takes the board (obstacles etc.).
## Returns {"board", "events", "seed"} or {} (test failed).
func _calm_run(counts: Dictionary, extra: Dictionary, setup: Callable) -> Dictionary:
	for seed_value in range(1, 81):
		var board: BoardModel = BB.with_counts(counts, _reserved(extra), 9, 9, seed_value)
		board.palette = BB.spread_palette()
		board.moves = 10
		if setup.is_valid():
			setup.call(board)
		var events: Variant = booster("hoof_tap", [board, ORB])
		if events == null:
			return {}
		if EV.count(events, "match") == 0:
			return {"board": board, "events": events, "seed": seed_value}
	fail_test("no cascade-free seed found in 1..80 for this board")
	return {}


## Colour of the single orb_fire event, or a note saying how many there were.
func _orb_colour(events: Array) -> String:
	var fires: Array = EV.of_type(events, "orb_fire")
	if fires.size() != 1:
		return "<%d orb_fire events>" % fires.size()
	return String(fires[0].color)


## 17 R, 17 Y, 16 B, 16 G; the palette starts with `want` (then the 12 spread colours), and seeds 1..600
## are tried until the one new piece that enters the top of the Orb's column is `want` and no cascade
## follows. Returns {"events", "seed"} or {} (test failed).
func _colour_change_run(want: String) -> Dictionary:
	var counts: Dictionary = {"R": 17, "Y": 17, "B": 16, "G": 16}
	for seed_value in range(1, 601):
		var board: BoardModel = BB.with_counts(counts, _reserved(), 9, 9, seed_value)
		board.palette = [want] + BB.spread_palette()
		board.moves = 10
		var events: Variant = booster("hoof_tap", [board, ORB])
		if events == null:
			return {}
		var fires: Array = EV.of_type(events, "orb_fire")
		if fires.size() == 1 and String(fires[0].color) == want and fires[0].cells.size() == 18 and EV.count(events, "match") == 0:
			return {"events": events, "seed": seed_value}
	fail_test("no seed in 1..600 gives a new %s piece in the Orb's column without a cascade" % want)
	return {}


func test_IR36_OQ112_B_hoof_tap_on_a_jade_orb_clears_the_cell_then_falls_then_clears_the_most_common_colour() -> void:
	var counts: Dictionary = {"R": 20, "Y": 18, "B": 17, "G": 16}
	var run: Dictionary = _calm_run(counts, {}, Callable())
	if run.is_empty():
		return
	var start: BoardModel = BB.with_counts(counts, _reserved(), 9, 9, int(run["seed"]))
	var reds: Array[Vector2i] = BB.find_color(start, "R")
	var board: BoardModel = run["board"]
	var events: Array = run["events"]
	var seq: Array = EV.sequence(events, ["clear", "fall", "refill", "orb_fire"])
	assert_eq(seq, ["clear", "fall", "refill", "orb_fire", "clear", "fall", "refill"],
		"booster clear (4,4), fall, refill, orb_fire, red clear, fall, refill (OQ-112 B)")
	var first_clear: BoardEvent = EV.of_type(events, "clear")[0]
	assert_eq(first_clear.source, "booster")
	assert_eq(first_clear.cells, [ORB] as Array[Vector2i], "the booster's own clear is the Orb's cell only")
	assert_eq(_orb_colour(events), "R", "colour-clear event for red")
	var fire: BoardEvent = EV.of_type(events, "orb_fire")[0]
	assert_eq(fire.cells.size(), 20, "all 20 red cleared")
	assert_false(fire.cells.has(ORB), "the colour clear never covers the Orb's own cell (OQ-112 B, OQ-113 A)")
	var colour_clear: BoardEvent = EV.of_type(events, "clear")[1]
	assert_eq(colour_clear.source, "orb")
	assert_eq(colour_clear.cells.size(), 20)
	# the reds in column 4 above the Orb fell one cell before they were cleared
	var cleared_by_orb: Dictionary = EV.to_set(colour_clear.cells)
	for c in reds:
		var where: Vector2i = c + Vector2i(0, 1) if (c.x == 4 and c.y < 4) else c
		assert_true(cleared_by_orb.has(where), "red from %s cleared (at %s on the refilled board)" % [c, where])
	for c in ["Y", "B", "G"]:
		assert_eq(BB.find_color(board, c).size(), int(counts[c]), "all %s stay" % c)
	assert_eq(BB.find_color(board, "R").size(), 0, "no red left (the refill uses other colours)")
	assert_eq(BB.find_kind(board, "orb").size(), 0, "the Orb is gone")
	assert_eq(board.moves, 10, "IR-62: no move used")
	_no_fail(events)


func test_IR36_OQ112_B_orb_colour_is_counted_after_the_fall_yellow_enters_the_column() -> void:
	var run: Dictionary = _colour_change_run("Y")
	if run.is_empty():
		return
	var events: Array = run["events"]
	assert_eq(_orb_colour(events), "Y", "18 Y vs 17 R on the refilled board: yellow, not red")
	assert_eq(EV.of_type(events, "orb_fire")[0].cells.size(), 18)
	assert_gt(EV.index_of(events, "orb_fire"), EV.index_of(events, "refill"), "counted after the first refill")
	# the same board with a refill that brings no R/Y/B/G piece: the tie goes to red (IR-47)
	var same: BoardModel = BB.with_counts({"R": 17, "Y": 17, "B": 16, "G": 16}, _reserved(), 9, 9, int(run["seed"]))
	same.palette = BB.spread_palette()
	same.moves = 10
	var other: Variant = booster("hoof_tap", [same, ORB])
	if other == null:
		return
	assert_eq(_orb_colour(other), "R", "without the new yellow piece the old tie would have drawn red")


func test_IR36_OQ112_B_orb_colour_is_counted_after_the_fall_red_enters_the_column() -> void:
	var run: Dictionary = _colour_change_run("R")
	if run.is_empty():
		return
	var events: Array = run["events"]
	assert_eq(_orb_colour(events), "R", "18 R vs 17 Y on the refilled board")
	assert_eq(EV.of_type(events, "orb_fire")[0].cells.size(), 18)


func test_IR36_OQ107_B_orb_tie_goes_to_red_by_ir47() -> void:
	var board: BoardModel = _orb_board({"R": 18, "Y": 18, "B": 17, "G": 16})
	var events: Variant = booster("hoof_tap", [board, ORB])
	if events == null:
		return
	assert_eq(_orb_colour(events), "R", "tie: R, Y, B, G order (IR-47)")


func test_IR36_OQ107_B_orb_picks_yellow_when_yellow_and_blue_tie_above_the_rest() -> void:
	var board: BoardModel = _orb_board({"R": 10, "Y": 19, "B": 19, "G": 10})
	var events: Variant = booster("hoof_tap", [board, ORB])
	if events == null:
		return
	assert_eq(_orb_colour(events), "Y", "tie Y/B: Y first (IR-47)")


func test_IR36_OQ107_B_covered_pieces_and_specials_do_not_count_and_stay() -> void:
	var covered: Array = [Vector2i(0, 0), Vector2i(8, 0), Vector2i(0, 8)]
	var extra: Dictionary = {Vector2i(8, 8): "RF"}
	for c in covered:
		extra[c] = "R"
	var board: BoardModel = _orb_board({"R": 17, "Y": 18, "B": 16, "G": 16}, extra)
	for c in covered:
		board.set_overlay(c.x, c.y, "OB03", 1)
	var events: Variant = booster("hoof_tap", [board, ORB])
	if events == null:
		return
	assert_eq(_orb_colour(events), "Y", "17 uncovered R < 18 Y: covered R and the Firecracker do not count")
	for c in covered:
		assert_eq(board.get_color(c.x, c.y), "R", "covered R at %s stays" % c)
		assert_eq(board.overlay_hp(c.x, c.y), 1, "its moss is not hit")
	assert_eq(EV.count(events, "blast"), 0, "the Firecracker does not fire (IR-19)")
	assert_eq(board.get_kind(8, 8), "firecracker", "the Firecracker stays")
	assert_eq(board.moves, 10)


func test_IR36_OQ107_B_orb_on_goo_hp2_takes_one_booster_hit_and_cleared_red_on_goo_is_hit() -> void:
	var setup: Callable = func(b: BoardModel) -> void:
		b.set_underlay(4, 4, "OB10", 2)
		b.set_underlay(6, 6, "OB10", 1)
	var run: Dictionary = _calm_run({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(6, 6): "R"}, setup)
	if run.is_empty():
		return
	var board: BoardModel = run["board"]
	var events: Array = run["events"]
	assert_eq(_orb_colour(events), "R")
	assert_eq(board.underlay_hp(4, 4), 1, "the booster's one hit; the colour clear does not cover the Orb's cell")
	assert_eq(board.underlay_hp(6, 6), 0, "a red piece on goo hp 1 is cleared: its goo is hit and removed (IR-09)")
	assert_eq(board.moves, 10)


func test_IR36_OQ107_B_orb_on_moss_hp2_takes_exactly_one_hit() -> void:
	var setup: Callable = func(b: BoardModel) -> void:
		b.set_overlay(4, 4, "OB03", 2)
	var run: Dictionary = _calm_run({"R": 20, "Y": 18, "B": 17, "G": 16}, {}, setup)
	if run.is_empty():
		return
	var board: BoardModel = run["board"]
	assert_eq(board.overlay_hp(4, 4), 1, "one hit, not two (the Orb's effect does not hit its own cell)")
	assert_eq(_orb_colour(run["events"]), "R", "red still cleared")
	assert_eq(board.moves, 10)


func test_IR36_OQ107_B_orb_under_moss_hp1_loses_the_moss_then_the_colour_is_cleared_OQ108_A() -> void:
	var board: BoardModel = _orb_board({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(2, 6): "O"})
	board.set_overlay(2, 6, "OB03", 1)
	var events: Variant = booster("hoof_tap", [board, Vector2i(2, 6)])
	if events == null:
		return
	assert_eq(board.overlay_hp(2, 6), 0, "the moss is removed (the booster's hit)")
	assert_eq(_orb_colour(events), "R", "the covered Orb acts as a tapped Orb")
	var seq: Array = EV.sequence(events, ["clear", "fall", "refill", "orb_fire"])
	assert_eq(seq.slice(0, 4), ["clear", "fall", "refill", "orb_fire"], "cell clear, fall, refill, then the colour (OQ-112 B)")
	assert_eq(board.moves, 10)


func test_IR36_OQ107_B_orb_hoof_tap_can_win_after_the_board_settles_IR56() -> void:
	var board: BoardModel = _orb_board({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(6, 6): "R"})
	board.add_content("OB02", 6, 6, 1)
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	var events: Variant = booster("hoof_tap", [board, ORB])
	if events == null:
		return
	assert_eq(_orb_colour(events), "R")
	assert_eq(board.content_hp(6, 6), 0, "bramble under the cleared red is removed")
	assert_eq(EV.count(events, "goal_done"), 1)
	assert_eq(EV.count(events, "win"), 1)
	assert_eq(events[events.size() - 1].type, "win", "win last, after the board settles (IR-56)")
	assert_gt(EV.index_of(events, "orb_fire"), EV.index_of(events, "refill"), "the colour is counted after the first refill")
	assert_gt(EV.index_of(events, "goal_done"), EV.index_of(events, "orb_fire"), "the goal is reached by the colour clear")
	assert_eq(board.moves, 10, "IR-62")


func test_IR36_OQ107_B_orb_hoof_tap_does_not_destroy_a_hatchling() -> void:
	var board: BoardModel = _orb_board({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(4, 5): "H"})
	var events: Variant = booster("hoof_tap", [board, ORB])
	if events == null:
		return
	assert_eq(_orb_colour(events), "R")
	assert_eq(BB.find_drop(board, "OB11").size(), 1, "the hatchling is not destroyed (IR-28); it may fall when pieces below it clear")
	for e in EV.of_type(events, "clear"):
		assert_false(e.cells.has(Vector2i(4, 5)), "the hatchling cell is never cleared")


func test_IR36_OQ107_B_orb_set_off_by_another_special_is_still_removed_without_effect_IR41() -> void:
	var board: BoardModel = _orb_board({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(0, 4): "Y-"})
	var events: Variant = booster("hoof_tap", [board, Vector2i(0, 4)])
	if events == null:
		return
	assert_eq(EV.count(events, "rocket_fire"), 1)
	assert_eq(EV.count(events, "orb_fire"), 0, "a set-off Orb has no colour effect (IR-41)")
	for e in EV.of_type(events, "clear"):
		assert_ne(e.source, "orb")
	assert_eq(BB.find_kind(board, "orb").size(), 0, "the Orb in the Rocket's row is removed")
	assert_eq(board.moves, 10)


## A 9x9 grid where only the listed cells are playable.
func _shape(cells: Array) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	for y in range(9):
		for x in range(9):
			if not cells.has(Vector2i(x, y)):
				BB.put(board, "#", [[x, y]])
	return board


func test_IR36_OQ111_A_orb_with_no_plain_piece_after_the_refill_clears_nothing_and_the_use_goes_through() -> void:
	# 3 cells: the Orb at (1,1) and a Rocket on each side; the refill puts a plain piece only in the Orb's cell (not counted, OQ-113 A).
	var board: BoardModel = _shape([Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)])
	BB.put(board, "R-", [[0, 1]])
	BB.put(board, "O", [[1, 1]])
	BB.put(board, "Y|", [[2, 1]])
	var events: Variant = booster("hoof_tap", [board, Vector2i(1, 1)])
	if events == null:
		return
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1, "orb_fire is still sent")
	if fires.size() == 1:
		assert_eq(String(fires[0].color), "", "with no colour")
		assert_true(fires[0].cells.is_empty(), "nothing cleared")
		assert_gt(EV.index_of(events, "orb_fire"), EV.index_of(events, "refill"), "judged after the fall and refill")
	assert_eq(EV.count(events, "clear"), 1, "only the booster's own clear")
	assert_eq(EV.count(events, "rocket_fire"), 0, "the Rockets do not fire")
	assert_eq(board.get_kind(0, 1), "rocket_row", "the Rockets stay")
	assert_eq(board.get_kind(2, 1), "rocket_col")
	assert_eq(BB.find_kind(board, "orb").size(), 0, "the Orb is removed")
	assert_eq(board.get_kind(1, 1), "plain", "a new piece is in the Orb's cell")
	assert_eq(board.moves, 10)
	_no_fail(events)


func test_IR36_OQ111_A_orb_with_only_covered_pieces_left_clears_nothing() -> void:
	var board: BoardModel = _shape([ORB, Vector2i(4, 5)])
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "R", [[4, 5]])
	board.set_overlay(4, 5, "OB03", 2)
	board.set_underlay(4, 4, "OB10", 2)
	var events: Variant = booster("hoof_tap", [board, ORB])
	if events == null:
		return
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(String(fires[0].color), "", "no colour (OQ-111 A)")
		assert_true(fires[0].cells.is_empty())
	assert_eq(BB.find_kind(board, "orb").size(), 0, "the Orb is removed")
	assert_eq(board.underlay_hp(4, 4), 1, "the booster's hit on the cell happens")
	assert_eq(board.get_color(4, 5), "R", "the covered piece stays")
	assert_eq(board.overlay_hp(4, 5), 2, "and its moss is not hit")
	assert_eq(board.moves, 10)
	_no_fail(events)


func test_IR36_OQ111_A_no_plain_piece_before_the_fall_but_one_after_is_counted_and_cleared() -> void:
	# Column 1: Rocket (1,0), Orb (1,1), Rocket (1,2). After the clear the top Rocket falls into (1,1) and the
	# refill puts a red piece at (1,0): the only uncovered plain piece on the refilled board.
	var board: BoardModel = _shape([Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)])
	board.palette = ["R"]
	BB.put(board, "R-", [[1, 0]])
	BB.put(board, "O", [[1, 1]])
	BB.put(board, "Y|", [[1, 2]])
	var events: Variant = booster("hoof_tap", [board, Vector2i(1, 1)])
	if events == null:
		return
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(String(fires[0].color), "R", "no plain piece before the fall, one after: that colour is cleared")
		assert_eq(fires[0].cells, [Vector2i(1, 0)] as Array[Vector2i])
	assert_eq(EV.count(events, "rocket_fire"), 0, "the Rockets do not fire")
	assert_eq(board.get_kind(1, 1), "rocket_row", "the Rocket that fell into the Orb's cell stays")
	assert_eq(board.get_kind(1, 2), "rocket_col")
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
