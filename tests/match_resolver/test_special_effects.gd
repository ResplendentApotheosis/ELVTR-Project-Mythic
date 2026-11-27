# GUT tests for IR-16..IR-21, IR-41, IR-47, IR-48, IR-49 (what each special does).
# API: tests/API_CONTRACT.md. Orb count boards come from BoardBuilder.with_counts.
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


func _orb_board(counts: Dictionary, extra: Dictionary = {}) -> BoardModel:
	var reserved: Dictionary = {Vector2i(4, 4): "O"}
	for k in extra:
		reserved[k] = extra[k]
	var board: BoardModel = BB.with_counts(counts, reserved)
	board.moves = 10
	return board


# ---------------------------------------------------------------- IR-16

func test_ir16_row_rocket_clears_its_whole_row() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.row_cells(4))), "exactly row 4 cleared")


func test_ir16_column_rocket_clears_its_whole_column() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.col_cells(4))), "exactly column 4 cleared")


func _all_fires_have_kind(events: Array[BoardEvent], kind: String) -> void:
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_true(fires.size() >= 1, "converted Rockets fired")
	for f in fires:
		assert_eq(f.kind, kind, "every converted Rocket copies the swapped Rocket's direction")


func test_ir16_orb_plus_column_rocket_makes_only_column_rockets() -> void:
	var board: BoardModel = BB.with_counts({"R": 20, "Y": 18, "B": 17, "G": 16},
		{Vector2i(4, 4): "O", Vector2i(4, 5): "z|"})
	board.moves = 10
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	_all_fires_have_kind(events, "rocket_col")


func test_ir16_orb_plus_row_rocket_makes_only_row_rockets() -> void:
	var board: BoardModel = BB.with_counts({"R": 20, "Y": 18, "B": 17, "G": 16},
		{Vector2i(4, 4): "O", Vector2i(4, 5): "z-"})
	board.moves = 10
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	_all_fires_have_kind(events, "rocket_row")


func test_ir16_pending_finale_rockets() -> void:
	pending("OQ-40: direction of the win-finale Rockets (leftover moves)")


# ---------------------------------------------------------------- IR-17

func test_ir17_firecracker_blasts_twice_with_the_board_settling_between() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(EV.count(events, "blast"), 2)
	assert_eq(EV.cleared_total(events), 18, "9 pieces per blast, 18 in total")
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	var i_fall: int = EV.index_after(events, "fall", i_b1)
	var i_refill: int = EV.index_after(events, "refill", i_b1)
	assert_true(i_b1 >= 0 and i_b2 > i_b1, "two blasts")
	assert_true(i_fall > i_b1 and i_fall < i_refill and i_refill < i_b2, "order: blast 1, fall, refill, blast 2")
	var area: Dictionary = EV.to_set(EV.rect_cells(3, 3, 5, 5))
	if i_b2 < 0 or i_refill < 0:
		return
	assert_true(EV.same_set(EV.to_set(events[i_b1].cells), area))
	assert_true(EV.same_set(EV.to_set(events[i_b2].cells), area), "same centre cell both times")
	assert_true(EV.same_set(EV.to_set(events[i_refill].cells), EV.to_set(EV.rect_cells(3, 0, 5, 2))), "9 new pieces enter at (3-5, 0-2)")
	var moved: Dictionary = {}
	for m in events[i_fall].data.get("moves", []):
		moved[m["to"]] = m["from"]
	for x in [3, 4, 5]:
		for y in [3, 4, 5]:
			assert_true(moved.has(Vector2i(x, y)), "a piece fell into (%d,%d)" % [x, y])


func test_ir17_firecracker_in_the_corner_is_clipped_to_the_board() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[0, 0]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 0))
	var blasts: Array = EV.of_type(events, "blast")
	assert_eq(blasts.size(), 2)
	for b in blasts:
		assert_true(EV.same_set(EV.to_set(b.cells), EV.to_set(EV.rect_cells(0, 0, 1, 1))))


func test_ir17_cascade_match_resolves_between_the_two_blasts() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 5], [2, 5], [3, 2]])
	BB.put(board, "Y", [[3, 5]])
	BB.put(board, "RF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	var i_fall1: int = EV.index_after(events, "fall", i_b1)
	var i_refill1: int = EV.index_after(events, "refill", i_b1)
	var i_match: int = EV.index_after(events, "match", i_b1)
	assert_true(i_b1 >= 0 and i_b2 > i_b1, "two blasts")
	assert_true(i_fall1 > i_b1 and i_refill1 > i_fall1, "blast 1, fall, refill")
	assert_true(i_match > i_refill1 and i_match < i_b2, "the cascade match comes after the refill and BEFORE blast 2")
	if i_match >= 0:
		var m: Dictionary = EV.to_set(events[i_match].cells)
		for c in [Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5)]:
			assert_true(m.has(c), "cascade match includes %s" % c)
	var i_clear: int = EV.index_after(events, "clear", i_match)
	var i_fall2: int = EV.index_after(events, "fall", i_match)
	var i_refill2: int = EV.index_after(events, "refill", i_match)
	assert_true(i_clear > i_match and i_fall2 > i_clear and i_refill2 > i_fall2 and i_refill2 < i_b2, "match clear, fall, refill, then blast 2")


# ---------------------------------------------------------------- IR-18

func test_ir18_orb_swapped_with_a_plain_piece_clears_that_colour() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 7], [7, 2], [8, 8]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	var cleared: Dictionary = EV.cleared(events)
	# after the swap the B is at (4,4) and the Orb at (5,4)
	for c in [Vector2i(4, 4), Vector2i(1, 7), Vector2i(7, 2), Vector2i(8, 8), Vector2i(5, 4)]:
		assert_true(cleared.has(c), "cell %s cleared (every B, plus the used-up Orb)" % c)
	assert_eq(board.moves, 14)
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].color, "B")


func test_ir18_orb_hits_goo_under_a_cleared_piece() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 1]])
	board.set_underlay(1, 1, "OB10", 1)
	MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	assert_eq(board.underlay_hp(1, 1), 0)


func test_ir18_orb_does_not_hit_obstacles_next_to_cleared_pieces() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [2, 3]])
	board.add_content("OB02", 2, 2, 2)
	MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	assert_eq(board.content_hp(2, 2), 2)


func test_ir18_orb_leaves_coloured_specials_of_that_colour_alone() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 15
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 7], [7, 2]])
	BB.put(board, "B-", [[6, 6]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	var cleared: Dictionary = EV.cleared(events)
	for c in [Vector2i(4, 4), Vector2i(1, 7), Vector2i(7, 2)]:
		assert_true(cleared.has(c), "plain B at %s cleared" % c)
	assert_false(cleared.has(Vector2i(6, 6)), "the blue Rocket is not cleared by the Orb")
	assert_eq(EV.count(events, "rocket_fire"), 0, "and does not fire")
	assert_eq(BB.find_kind(board, "rocket_row").size(), 1, "the Rocket is still on the board")


func test_ir18_orb_swapped_with_a_hatchling_acts_as_a_tap() -> void:
	var board: BoardModel = BB.with_counts({"R": 20, "Y": 18, "B": 17, "G": 16},
		{Vector2i(4, 4): "O", Vector2i(4, 5): "H"})
	board.moves = 15
	var expected: Array[Vector2i] = BB.find_color(board, "R")
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(expected.size(), 20)
	var cleared: Dictionary = EV.cleared(events)
	for c in expected:
		assert_true(cleared.has(c), "R at %s cleared" % c)
	assert_eq(BB.find_drop(board, "OB11").size() + board.collected_count("OB11"), 1, "hatchling not destroyed")
	assert_eq(board.moves, 14)


func test_ir18_pending_plain_pieces_under_an_overlay() -> void:
	pending("OQ-42: are plain pieces under an overlay cleared (and counted) by the Orb")


# ---------------------------------------------------------------- IR-19

func test_ir19_tapped_orb_clears_the_most_common_colour() -> void:
	var board: BoardModel = _orb_board({"R": 20, "Y": 18, "B": 17, "G": 16})
	var expected: Array[Vector2i] = BB.find_color(board, "R")
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(expected.size(), 20)
	var cleared: Dictionary = EV.cleared(events)
	for c in expected:
		assert_true(cleared.has(c), "R at %s cleared" % c)
	assert_eq(board.moves, 9)


func test_ir19_tie_goes_to_red() -> void:
	var board: BoardModel = _orb_board({"R": 18, "B": 18, "Y": 17, "G": 17})
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].color, "R")


func test_ir19_coloured_specials_are_not_counted_and_not_cleared() -> void:
	# Pinned layout: the Firecrackers sit in the bottom corners and every neighbour that could
	# form a line or 2x2 with them is a unique filler. Fillers never clear or move, so no
	# cascade (refill included) can ever match a Firecracker.
	var board: BoardModel = _orb_board({"R": 17, "Y": 18, "B": 16, "G": 16}, {
		Vector2i(0, 8): "RF", Vector2i(8, 8): "RF",
		Vector2i(1, 8): ".", Vector2i(2, 8): ".", Vector2i(0, 7): ".", Vector2i(0, 6): ".", Vector2i(1, 7): ".",
		Vector2i(7, 8): ".", Vector2i(6, 8): ".", Vector2i(8, 7): ".", Vector2i(8, 6): ".", Vector2i(7, 7): "."})
	assert_false(BB.has_match(board), "precondition: the set-up board has no match")
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].color, "Y", "Y wins: the red Firecrackers do not count towards R")
	assert_eq(EV.count(events, "blast"), 0, "the Firecrackers do not fire")
	assert_eq(BB.find_kind(board, "firecracker").size(), 2, "both Firecrackers stay on the board")


func test_ir19_pending_plain_pieces_under_an_overlay() -> void:
	pending("OQ-42: are plain pieces under an overlay counted for 'most common' and cleared")


# ---------------------------------------------------------------- IR-20

func test_ir20_crane_goes_for_the_unfreed_fragment_first() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 1, 1, 1)
	board.add_content("OB07", 7, 7, 3, 1, 1, true)
	board.goals = ["OB02", "fragment"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var targets: Array = EV.of_type(events, "crane_target")
	assert_eq(targets.size(), 1)
	if targets.size() == 1:
		assert_eq(targets[0].cell, Vector2i(7, 7), "the cocoon, not the bramble with fewer hits")


func test_ir20_crane_events_come_in_order_target_takeoff_landing() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var i_target: int = EV.index_of(events, "crane_target")
	var i_off: int = EV.index_of(events, "crane_takeoff")
	var i_land: int = EV.index_of(events, "crane_landing")
	assert_true(i_target >= 0 and i_off >= 0 and i_land >= 0, "all three events exist")
	assert_true(i_target < i_off and i_off < i_land, "order: target, take-off, landing")
	if i_target < 0 or i_off < 0 or i_land < 0:
		return
	assert_eq(events[i_off].cell, Vector2i(4, 4), "take-off from the Crane's cell")
	assert_eq(events[i_target].cell, events[i_land].cell, "lands on the target")


# ---------------------------------------------------------------- IR-21

func test_ir21_firecracker_in_a_match_fires_after_the_match_clears() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 5]])
	BB.put(board, "RF", [[3, 4]])
	BB.put(board, "Y", [[2, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 5), Vector2i(2, 4))
	assert_eq(EV.count(events, "blast"), 2, "the matched Firecracker fires")
	var i_clear: int = EV.index_of_clear(events, "match")
	assert_true(i_clear >= 0 and i_clear < EV.index_of(events, "blast", 0), "the match's clear event comes before the blasts")


func test_ir21_match_makes_a_rocket_that_the_firecracker_then_sets_off() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[1, 4], [2, 4], [3, 5]])
	BB.put(board, "Y", [[3, 4]])
	BB.put(board, "RF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 5), Vector2i(3, 4))
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_made: int = EV.index_of(events, "special_created")
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	var i_rocket: int = EV.index_of(events, "rocket_fire")
	assert_true(i_clear >= 0 and i_made > i_clear, "match clear, then the Rocket is created")
	assert_true(i_b1 > i_made and i_b2 > i_b1, "then the Firecracker's two blasts")
	assert_true(i_rocket > i_b2, "the Rocket it set off fires after the second blast")
	if i_made >= 0:
		assert_eq(events[i_made].kind, "rocket_row")
		assert_eq(events[i_made].cell, Vector2i(3, 4))
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(4, 4), Vector2i(4, 4)], "centred on (4,4)")
	if i_rocket >= 0:
		assert_eq(events[i_rocket].cell, Vector2i(3, 4), "the Rocket fires from where it was hit")
		assert_true(EV.same_set(EV.to_set(events[i_rocket].cells), EV.to_set(EV.row_cells(4))), "along row 4")


# ---------------------------------------------------------------- IR-41

func test_ir41_rocket_sets_off_another_rocket_after_it_finishes_and_falls() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[1, 4]])
	BB.put(board, "R|", [[6, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 4))
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 2)
	if fires.size() < 2:
		return
	assert_true(EV.same_set(EV.to_set(fires[0].cells), EV.to_set(EV.row_cells(4))), "row 4 first")
	assert_true(EV.same_set(EV.to_set(fires[1].cells), EV.to_set(EV.col_cells(6))), "then column 6")
	assert_eq(fires[1].cell, Vector2i(6, 4), "the set-off Rocket fires from the cell where it was hit")
	var i1: int = EV.index_of(events, "rocket_fire", 0)
	var i2: int = EV.index_of(events, "rocket_fire", 1)
	var fall_between: bool = false
	var clear_between: bool = false
	for i in range(i1 + 1, i2):
		if events[i].type == "fall":
			fall_between = true
		if events[i].type == "clear":
			clear_between = true
	assert_true(clear_between, "the first rocket's clear comes before the second fires")
	assert_true(fall_between, "pieces fall before the set-off Rocket fires")


func test_ir41_set_off_rocket_hits_obstacles_in_its_line() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[1, 4]])
	BB.put(board, "R|", [[6, 4]])
	board.add_content("OB02", 6, 7, 2)
	MatchResolver.tap(board, Vector2i(1, 4))
	assert_eq(board.content_hp(6, 7), 1)


func test_ir41_rocket_sets_off_a_crane_that_flies_from_the_hit_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 0]])
	BB.put(board, "GC", [[4, 6]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 0))
	var i_fire: int = EV.index_of(events, "rocket_fire")
	var i_off: int = EV.index_of(events, "crane_takeoff")
	assert_true(i_fire >= 0 and i_off > i_fire, "the Crane fires after the Rocket")
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 6)], "take-off from (4,6)")


func test_ir41_two_firecrackers_in_a_column_fire_lowest_first() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 0]])
	BB.put(board, "RF", [[4, 2], [4, 6]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 0))
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(4, 6), Vector2i(4, 6), Vector2i(4, 2), Vector2i(4, 2)],
		"(4,6) fires both blasts, then (4,2)")


func test_ir41_two_rockets_in_a_row_fire_leftmost_first() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 4]])
	BB.put(board, "R|", [[6, 4], [2, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(EV.cells_of(events, "rocket_fire"), [Vector2i(0, 4), Vector2i(2, 4), Vector2i(6, 4)])


func test_ir41_a_set_off_orb_is_removed_without_effect() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 4]])
	BB.put(board, "O", [[5, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(EV.count(events, "orb_fire"), 0, "no colour-clear event")
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.row_cells(4))), "only row 4 was cleared")
	assert_eq(BB.find_kind(board, "orb").size(), 0, "the Orb is gone")


func test_ir41_firecracker_lifts_a_rocket_which_fires_once_after_blast_two() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "R-", [[5, 5]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 1, "fires exactly once")
	if fires.size() != 1:
		return
	assert_eq(fires[0].cell, Vector2i(5, 5))
	assert_true(EV.same_set(EV.to_set(fires[0].cells), EV.to_set(EV.row_cells(5))), "along row 5")
	assert_true(EV.index_of(events, "rocket_fire") > EV.index_of(events, "blast", 1), "after blast 2")


func test_ir41_pending_cascades_before_a_set_off_special_fires() -> void:
	pending("OQ-44: whether cascade matches resolve before or after the set-off specials fire")


func test_ir41_pending_chain_inside_a_chain_order() -> void:
	pending("OQ-47: when a set-off special sets off another, does it join the same waiting list or fire before the others")


# ---------------------------------------------------------------- IR-47

func _tap_orb_colour(counts: Dictionary, extra: Dictionary = {}) -> String:
	var board: BoardModel = _orb_board(counts, extra)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var fires: Array = EV.of_type(events, "orb_fire")
	if fires.size() != 1:
		return "<no orb_fire event>"
	return fires[0].color


func test_ir47_red_yellow_tie_goes_to_red() -> void:
	assert_eq(_tap_orb_colour({"R": 18, "Y": 18, "B": 17, "G": 16}), "R")


func test_ir47_yellow_blue_tie_goes_to_yellow() -> void:
	assert_eq(_tap_orb_colour({"R": 10, "Y": 19, "B": 19, "G": 10}), "Y")


func test_ir47_blue_green_tie_goes_to_blue() -> void:
	assert_eq(_tap_orb_colour({"R": 12, "Y": 12, "B": 20, "G": 20}), "B")


func test_ir47_a_yellow_rocket_is_not_counted() -> void:
	assert_eq(_tap_orb_colour({"R": 18, "Y": 18, "B": 17, "G": 16}, {Vector2i(0, 8): "Y-"}), "R")


func test_ir47_pending_plain_pieces_under_an_overlay() -> void:
	pending("OQ-42: are plain pieces under an overlay counted when breaking colour ties")


# ---------------------------------------------------------------- IR-48

func test_ir48_crane_hits_its_target_and_clears_its_start_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.content_hp(6, 2), 1)
	assert_true(EV.cleared(events).has(Vector2i(1, 7)), "take-off clears the start cell")
	assert_eq(BB.find_kind(board, "crane").size(), 0, "the Crane is used up")


func test_ir48_crane_collects_a_drop_item() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	BB.put(board, "H", [[5, 3]])
	board.goals = ["OB11"]
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.collected_count("OB11"), 1, "collected, not destroyed")


func test_ir48_crane_freeing_a_cocoon_collects_the_fragment() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	board.add_content("OB07", 4, 1, 1, 1, 1, true)
	board.goals = ["fragment"]
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.content_hp(4, 1), 0)
	assert_eq(board.collected_count("fragment"), 1)


func test_ir48_takeoff_clears_goo_hp1_under_the_crane() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	board.set_underlay(1, 7, "OB10", 1)
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.underlay_hp(1, 7), 0, "take-off hits the goo under the Crane")
	assert_eq(board.content_hp(6, 2), 1, "and the bramble is hit by the landing")


func test_ir48_takeoff_takes_one_layer_off_goo_hp2() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	board.set_underlay(1, 7, "OB10", 2)
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.underlay_hp(1, 7), 1)


func test_ir48_landing_on_an_uncovered_dew_target_gives_it_dew() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[1, 7]])
	BB.set_dew_target(board, 6, 2)
	board.goals = ["OB04"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(EV.cells_of(events, "crane_landing"), [Vector2i(6, 2)])
	assert_true(BB.has_dew(board, 6, 2), "the target cell now has dew")


func test_ir48_set_off_crane_takeoff_clears_the_piece_that_fell_into_its_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 0]])
	BB.put(board, "GC", [[4, 6]])
	board.set_underlay(4, 6, "OB10", 2)
	board.add_content("OB02", 6, 2, 2)
	board.goals = ["OB02"]
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 0))
	var i_off: int = EV.index_of(events, "crane_takeoff")
	assert_true(i_off >= 0, "the set-off Crane takes off")
	if i_off < 0:
		return
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 6)], "take-off from (4,6)")
	# The column Rocket hit goo once (hp 2 -> 1); the Crane is lifted and a piece falls into (4,6).
	var cleared_after: bool = false
	for i in range(i_off + 1, events.size()):
		if events[i].type == "clear" and events[i].cells.has(Vector2i(4, 6)):
			cleared_after = true
	assert_true(cleared_after, "take-off clears the piece that fell into (4,6)")
	assert_eq(board.underlay_hp(4, 6), 0, "take-off gives the goo its second hit (removed)")
	assert_eq(board.content_hp(6, 2), 1, "then the Crane lands on its target")


func test_ir48_pending_crane_landing_on_dew_target_clears_the_piece() -> void:
	pending("OQ-49: does a Crane landing on an uncovered dew target also clear the piece there")


# ---------------------------------------------------------------- IR-49

func _crane_target(board: BoardModel) -> Vector2i:
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var targets: Array = EV.of_type(events, "crane_target")
	if targets.size() != 1:
		return Vector2i(-99, -99)
	return targets[0].cell


func test_ir49_fewest_hits_left_goal_wins() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 1, 1, 3)
	board.add_content("OB02", 7, 7, 3)
	board.add_content("OB07", 6, 2, 1)
	board.goals = ["OB02", "OB07"]
	assert_eq(_crane_target(board), Vector2i(6, 2))


func test_ir49_tie_goes_to_the_leftmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 2, 4, 1)
	board.add_content("OB07", 6, 4, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(2, 4))


func test_ir49_tie_goes_to_the_topmost_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 4, 1, 1)
	board.add_content("OB07", 4, 7, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(4, 1))


func test_ir49_closest_cell_beats_reading_order() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 5, 4, 1)
	board.add_content("OB07", 1, 4, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(5, 4))


func test_ir49_distance_is_straight_line_not_steps() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB07", 6, 6, 1)
	board.add_content("OB07", 4, 1, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(6, 6), "(6,6) is 2.83 away, (4,1) is 3 away")


func test_ir49_no_goal_left_aims_at_the_nearest_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.add_content("OB02", 4, 2, 1)
	board.add_content("OB02", 0, 8, 1)
	board.goals = ["OB07"]
	assert_eq(_crane_target(board), Vector2i(4, 2))


func test_ir49_no_obstacle_left_uses_the_seeded_random_piece() -> void:
	var first: Vector2i = Vector2i(-1, -1)
	var second: Vector2i = Vector2i(-2, -2)
	for run in range(2):
		var board: BoardModel = BB.blank(9, 9, 777)
		BB.put(board, "GC", [[4, 4]])
		var t: Vector2i = _crane_target(board)
		if run == 0:
			first = t
		else:
			second = t
	assert_eq(first, second, "same seed, same target")
	assert_true(first.x >= 0 and first.x < 9 and first.y >= 0 and first.y < 9, "target is on the board")


func test_ir49_no_goal_left_goo_counts_as_an_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.set_underlay(4, 5, "OB10", 1)
	board.add_content("OB02", 4, 1, 1)
	board.goals = []
	assert_eq(_crane_target(board), Vector2i(4, 5), "goo is closer than the bramble")
	assert_eq(board.underlay_hp(4, 5), 0, "goo removed")
	assert_eq(board.content_hp(4, 1), 1, "bramble untouched")


func test_ir49_no_goal_left_moss_counts_as_an_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	board.set_overlay(1, 1, "OB03", 1)
	board.goals = []
	assert_eq(_crane_target(board), Vector2i(1, 1))
	assert_eq(board.overlay_hp(1, 1), 0, "moss removed")


func test_ir49_no_goal_left_uncovered_dew_target_counts_as_an_obstacle() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	BB.set_dew_target(board, 4, 6)
	board.add_content("OB02", 4, 1, 1)
	board.goals = []
	assert_eq(_crane_target(board), Vector2i(4, 6), "dew target at distance 2 beats the bramble at 3")
	assert_true(BB.has_dew(board, 4, 6), "the landing gives the cell dew")


func test_ir49_dew_goal_counts_uncovered_target_cells_as_hits_left() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	BB.set_dew_target(board, 1, 1)
	BB.set_dew_target(board, 7, 7)
	board.add_content("OB02", 6, 1, 3)
	board.goals = ["OB04", "OB02"]
	assert_eq(_crane_target(board), Vector2i(1, 1), "2 dew cells left < 3 bramble hits; equal distance, top-most")
	assert_true(BB.has_dew(board, 1, 1))


func test_ir49_hatchling_goal_counts_items_still_to_collect() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "H", [[2, 2]])
	board.add_content("OB02", 6, 6, 2)
	board.goals = ["OB11", "OB02"]
	assert_eq(_crane_target(board), Vector2i(2, 2), "1 hatchling to collect < 2 bramble hits")
	assert_eq(board.collected_count("OB11"), 1, "hatchling collected")


func test_ir49_shrine_goal_counts_pieces_still_needed_and_takes_the_most_needed_colour() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	BB.add_shrine(board, 1, 1, {"R": 3, "B": 1})
	board.add_content("OB02", 6, 6, 5)
	board.goals = ["OB05", "OB02"]
	assert_eq(_crane_target(board), Vector2i(1, 1), "4 pieces needed < 5 bramble hits")
	assert_eq(BB.shrine_need(board, 1, 1, "R"), 2, "the landing counts as one red piece")
	assert_eq(BB.shrine_need(board, 1, 1, "B"), 1)


func test_ir49_pending_shrine_colour_tie() -> void:
	pending("OQ-43: a shrine that needs two colours equally; which colour a Crane landing counts as")
