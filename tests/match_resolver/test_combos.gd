# GUT tests for IR-22..IR-27 and IR-46 (swapping two specials).
# API: tests/API_CONTRACT.md. Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


func _cross(x: int, y: int) -> Dictionary:
	return EV.union([EV.row_cells(y), EV.col_cells(x)])


func _bands(x: int, y: int) -> Dictionary:
	return EV.union([EV.rect_cells(0, y - 1, 8, y + 1), EV.rect_cells(x - 1, 0, x + 1, 8)])


# ---------------------------------------------------------------- IR-22

func test_ir22_rocket_rocket_clears_row_and_column_through_the_target() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "R|", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var cleared: Dictionary = EV.cleared(events)
	assert_eq(cleared.size(), 17)
	assert_true(EV.same_set(cleared, _cross(4, 4)))
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "combo"), 1, "a combo event is returned")


func test_ir22_crossing_cell_goo_is_hit_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "R|", [[4, 5]])
	board.set_underlay(4, 4, "OB10", 2)
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.underlay_hp(4, 4), 1)


# ---------------------------------------------------------------- IR-23

func test_ir23_rocket_firecracker_clears_three_wide_row_and_column() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[3, 4]])
	BB.put(board, "R-", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 4), Vector2i(4, 4))
	var cleared: Dictionary = EV.cleared(events)
	assert_eq(cleared.size(), 45)
	assert_true(EV.same_set(cleared, _bands(4, 4)))


func test_ir23_obstacle_inside_both_bands_is_hit_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[3, 4]])
	BB.put(board, "R-", [[4, 4]])
	board.add_content("OB02", 3, 3, 2)
	MatchResolver.swap(board, Vector2i(3, 4), Vector2i(4, 4))
	assert_eq(board.content_hp(3, 3), 1)


# ---------------------------------------------------------------- IR-24

func test_ir24_firecracker_firecracker_first_blast_is_five_by_five() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4], [4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var blasts: Array = EV.of_type(events, "blast")
	assert_eq(blasts.size(), 2, "double blast")
	if blasts.size() >= 1:
		assert_true(EV.same_set(EV.to_set(blasts[0].cells), EV.to_set(EV.rect_cells(2, 2, 6, 6))))


func test_ir24_frozen_idol_in_the_area_is_hit_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4], [4, 5]])
	board.add_content("OB12", 2, 2, 2)
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.content_hp(2, 2), 1)


func test_ir24_piece_counts_and_events_between_the_two_5x5_blasts() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4], [4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	assert_true(i_b1 >= 0 and i_b2 > i_b1, "two blasts")
	assert_eq(EV.cleared_total(events), 50, "25 pieces per blast, 50 in total")
	var i_fall: int = EV.index_after(events, "fall", i_b1)
	var i_refill: int = EV.index_after(events, "refill", i_b1)
	assert_true(i_fall > i_b1 and i_refill > i_fall and i_refill < i_b2, "order: blast 1, fall, refill, blast 2")
	if i_refill < 0 or i_fall < 0:
		return
	assert_true(EV.same_set(EV.to_set(events[i_refill].cells), EV.to_set(EV.rect_cells(2, 0, 6, 4))), "25 new pieces enter at (2-6, 0-4)")
	var targets: Dictionary = {}
	for m in events[i_fall].data.get("moves", []):
		targets[m["to"]] = true
	assert_eq(targets.size(), 10, "10 pieces fell")
	for x in range(2, 7):
		assert_true(targets.has(Vector2i(x, 5)) and targets.has(Vector2i(x, 6)), "the pieces from (%d,0-1) landed on (%d,5-6)" % [x, x])


func test_ir24_cascade_match_resolves_between_the_two_5x5_blasts() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4], [4, 5]])
	BB.put(board, "R", [[0, 6], [1, 6], [2, 1]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	var i_match: int = EV.index_after(events, "match", i_b1)
	assert_true(i_b1 >= 0 and i_b2 > i_b1, "two blasts")
	assert_true(i_match > i_b1 and i_match < i_b2, "the cascade match R (0,6),(1,6),(2,6) happens between the blasts")
	if i_match >= 0:
		var m: Dictionary = EV.to_set(events[i_match].cells)
		for c in [Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6)]:
			assert_true(m.has(c), "cascade match includes %s" % c)


# ---------------------------------------------------------------- IR-25

const ORB_PLUS_COUNTS: Dictionary = {"R": 20, "Y": 18, "B": 17, "G": 16}


func test_ir25_pending_converted_pieces_fire_from_their_own_cells() -> void:
	pending("OQ-48: do converted specials fire from the cell they were converted in, or from where they have fallen to")


# Kept for when OQ-48 is answered (pins Option A: fire from the converted cell). Not run.
func _blocked_oq48_orb_plus_firecracker_turns_every_common_piece_into_a_firecracker() -> void:
	var board: BoardModel = BB.with_counts(ORB_PLUS_COUNTS, {Vector2i(4, 4): "O", Vector2i(4, 5): "zF"})
	board.moves = 10
	var reds: Array[Vector2i] = BB.find_color(board, "R")
	assert_eq(reds.size(), 20)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "combo"), 1)
	var centres: Dictionary = EV.to_set(EV.blast_centres(events, 1))
	for c in reds:
		assert_true(centres.has(c), "the converted Firecracker at %s fires" % c)
	var cleared: Dictionary = EV.cleared(events)
	assert_true(cleared.has(Vector2i(4, 4)) and cleared.has(Vector2i(4, 5)), "the Orb and the swapped Firecracker are used up")


func test_ir25_pillar_inside_several_converted_blasts_takes_one_hit() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "O", [[0, 8]])
	BB.put(board, "zF", [[1, 8]])
	BB.put(board, "R", [[2, 3], [5, 4], [3, 6]])
	board.add_content("OB06", 3, 3, 3, 2, 2)
	MatchResolver.swap(board, Vector2i(1, 8), Vector2i(0, 8))
	assert_eq(board.content_hp(3, 3), 2, "one combo = one hit, though two converted blasts cover the pillar")


func test_ir25_converted_firecrackers_fire_lowest_then_leftmost() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 1], [6, 1], [2, 7]])
	BB.put(board, "Y", [[0, 0], [8, 8]])
	BB.put(board, "B", [[0, 8], [8, 0]])
	BB.put(board, "G", [[4, 0], [4, 8]])
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "zF", [[4, 5]])
	var keep: Dictionary = EV.to_set([Vector2i(2, 1), Vector2i(6, 1), Vector2i(2, 7), Vector2i(0, 0), Vector2i(8, 8),
		Vector2i(0, 8), Vector2i(8, 0), Vector2i(4, 0), Vector2i(4, 8), Vector2i(4, 4), Vector2i(4, 5)])
	for y in range(9):
		for x in range(9):
			if not keep.has(Vector2i(x, y)):
				board.add_content("OB02", x, y, 9)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.blast_centres(events, 1), [Vector2i(2, 7), Vector2i(2, 1), Vector2i(6, 1)], "(2,7) lowest, then (2,1) before (6,1)")


func test_ir25_pending_red_rockets_not_converted_fire_from_own_cells() -> void:
	pending("OQ-48: this case asserts converted pieces fire from their converted cells")


# Kept for when OQ-48 is answered (pins Option A). Not run.
func _blocked_oq48_red_rockets_are_neither_counted_nor_converted() -> void:
	var board: BoardModel = BB.with_counts({"R": 18, "Y": 19, "B": 17, "G": 16},
		{Vector2i(4, 4): "O", Vector2i(4, 5): "zF", Vector2i(0, 0): "R-", Vector2i(8, 0): "R-", Vector2i(0, 8): "R-"})
	board.moves = 10
	assert_false(BB.has_match(board), "precondition: the set-up board has no match")
	var yellows: Array[Vector2i] = BB.find_color(board, "Y")
	assert_eq(yellows.size(), 19)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var centres: Dictionary = EV.to_set(EV.blast_centres(events, 1))
	for c in yellows:
		assert_true(centres.has(c), "yellow piece at %s was converted and fired" % c)
	for c in [Vector2i(0, 0), Vector2i(8, 0), Vector2i(0, 8)]:
		assert_false(centres.has(c), "the red Rocket at %s was not converted into a Firecracker" % c)


func test_ir25_pending_plain_pieces_under_an_overlay() -> void:
	pending("OQ-42: are plain pieces under an overlay counted and converted by Orb + special")


# ---------------------------------------------------------------- IR-26

func _orb_orb_board() -> BoardModel:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "O", [[4, 4], [4, 5]])
	BB.put(board, "H", [[3, 2]])
	BB.put(board, "Q", [[6, 1]])
	board.add_content("OB02", 1, 1, 3)
	board.add_content("OB06", 6, 6, 3, 2, 2)
	return board


func test_ir26_orb_orb_collects_drop_items_and_fragments() -> void:
	var board: BoardModel = _orb_orb_board()
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.collected_count("OB11"), 1)
	assert_eq(board.collected_count("fragment"), 1)
	var cleared: Dictionary = EV.cleared(events)
	assert_false(cleared.has(Vector2i(3, 2)), "hatchling is collected, not destroyed")
	assert_false(cleared.has(Vector2i(6, 1)), "fragment is collected, not destroyed")


func test_ir26_orb_orb_hits_every_obstacle_once() -> void:
	var board: BoardModel = _orb_orb_board()
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.content_hp(1, 1), 2)
	assert_eq(board.content_hp(6, 6), 2)


func test_ir26_orb_orb_clears_every_plain_piece() -> void:
	var board: BoardModel = _orb_orb_board()
	var expected: Array[Vector2i] = BB.find_kinds(board, ["plain", "orb"])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var cleared: Dictionary = EV.cleared(events)
	for c in expected:
		assert_true(cleared.has(c), "cell %s cleared" % c)


func test_ir26_orb_orb_hits_single_layer_moss_and_goo_once() -> void:
	var board: BoardModel = _orb_orb_board()
	board.set_overlay(2, 5, "OB03", 2)
	board.set_underlay(7, 5, "OB10", 2)
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.overlay_hp(2, 5), 1, "moss alone loses 1 hit")
	assert_eq(board.underlay_hp(7, 5), 1, "goo alone loses 1 hit")


func test_ir26_orb_orb_hits_only_the_top_layer_of_moss_over_goo() -> void:
	var board: BoardModel = _orb_orb_board()
	BB.put(board, "R", [[2, 4]])
	board.set_overlay(2, 4, "OB03", 1)
	board.set_underlay(2, 4, "OB10", 1)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_true(EV.cleared(events).has(Vector2i(2, 4)), "the piece is cleared")
	assert_eq(board.overlay_hp(2, 4), 0, "moss removed")
	assert_eq(board.underlay_hp(2, 4), 1, "goo under the moss untouched")


func test_ir26_orb_orb_clears_other_specials_without_firing_them() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "O", [[4, 4], [4, 5]])
	BB.put(board, "R-", [[2, 2]])
	BB.put(board, "RF", [[6, 6]])
	board.add_content("OB02", 7, 2, 3)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var cleared: Dictionary = EV.cleared(events)
	assert_true(cleared.has(Vector2i(2, 2)) and cleared.has(Vector2i(6, 6)), "both specials cleared")
	assert_eq(EV.count(events, "rocket_fire"), 0, "the Rocket does not fire")
	assert_eq(EV.count(events, "blast"), 0, "the Firecracker does not fire")
	assert_eq(board.content_hp(7, 2), 2, "the bramble takes only the Orb + Orb hit")


# ---------------------------------------------------------------- IR-27

func test_ir27_crane_plus_firecracker_is_no_combo_firecracker_first() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 12
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "RF", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "never refused")
	assert_eq(board.moves, 11)
	assert_eq(EV.count(events, "combo"), 0, "no combo event")
	assert_eq(EV.count(events, "crane_target"), 1, "the Crane flies exactly once")
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(4, 4), Vector2i(4, 4)], "the Firecracker, now at (4,4), blasts centred on (4,4)")
	var i_last_blast: int = -1
	for i in range(events.size()):
		if events[i].type == "blast":
			i_last_blast = i
	assert_true(i_last_blast < EV.index_of(events, "crane_target"), "every Firecracker event before the Crane")
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 5)], "the Crane, now at (4,5), takes off from there")


func test_ir27_crane_plus_rocket_rocket_fires_from_its_new_cell_first() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 12
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "R-", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 11)
	var fires: Array = EV.of_type(events, "rocket_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].cell, Vector2i(4, 4), "the Rocket fires from (4,4)")
		assert_true(EV.same_set(EV.to_set(fires[0].cells), EV.to_set(EV.row_cells(4))), "row 4, not row 5")
	assert_true(EV.index_of(events, "rocket_fire") < EV.index_of(events, "crane_takeoff"), "Rocket first, then the Crane")
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 5)], "the Crane takes off from (4,5)")


func test_ir27_firecracker_clears_the_bramble_then_the_crane_flies_to_what_is_left() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "RF", [[4, 5]])
	board.add_content("OB02", 5, 4, 1)
	board.add_content("OB07", 0, 0, 1)
	board.goals = ["OB02", "OB07"]
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.content_hp(5, 4), 0, "bramble cleared by the Firecracker")
	var targets: Array = EV.of_type(events, "crane_target")
	assert_eq(targets.size(), 1)
	if targets.size() == 1:
		assert_eq(targets[0].cell, Vector2i(0, 0))


func test_ir27_orb_swapped_with_crane_clears_most_common_colour_then_crane_flies() -> void:
	var board: BoardModel = BB.with_counts(
		{"R": 20, "Y": 18, "B": 17, "G": 16},
		{Vector2i(4, 4): "O", Vector2i(4, 5): "GC"})
	board.moves = 10
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)
	var fires: Array = EV.of_type(events, "orb_fire")
	assert_eq(fires.size(), 1)
	if fires.size() == 1:
		assert_eq(fires[0].color, "R")
	assert_eq(EV.count(events, "crane_target"), 1)
	assert_true(EV.index_of(events, "orb_fire") < EV.index_of(events, "crane_target"), "Orb first, then the Crane")
	assert_eq(EV.count(events, "combo"), 0)


func test_ir27_crane_plus_crane_the_dragged_crane_flies_first() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 12
	BB.put(board, "GC", [[4, 4], [4, 5]])
	board.add_content("OB07", 4, 0, 1)
	board.add_content("OB07", 4, 8, 1)
	board.goals = ["OB07"]
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 11)
	assert_eq(EV.count(events, "combo"), 0, "no combo")
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 4), Vector2i(4, 5)], "the dragged Crane (now at (4,4)) takes off first")
	assert_eq(EV.cells_of(events, "crane_landing"), [Vector2i(4, 0), Vector2i(4, 8)], "first lands on (4,0) (top-most of the tie), then (4,8)")


# ---------------------------------------------------------------- IR-46

func test_ir46_combo_is_centred_on_the_target_cell_row_and_column() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "R|", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_true(EV.same_set(EV.cleared(events), _cross(4, 4)), "target (4,4): row 4 + column 4")


func test_ir46_swapping_the_other_way_moves_the_centre() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "R|", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 5))
	assert_true(EV.same_set(EV.cleared(events), _cross(4, 5)), "target (4,5): row 5 + column 4")


func test_ir46_rocket_firecracker_bands_around_the_target() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[2, 3]])
	BB.put(board, "R-", [[3, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(2, 3), Vector2i(3, 3))
	assert_true(EV.same_set(EV.cleared(events), _bands(3, 3)), "rows 2-4 and columns 2-4")
