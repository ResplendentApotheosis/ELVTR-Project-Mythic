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


func test_ir24_pending_piece_counts_between_blasts() -> void:
	pending("OQ-32: timing of the second 5x5 blast and what happens between blasts (piece-count tests)")


# ---------------------------------------------------------------- IR-25

func test_ir25_pending_orb_plus_special() -> void:
	pending("OQ-24 (converted Rocket direction), OQ-27 (firing order), OQ-33 (what counts as most common colour); also OQ-32 for converted Firecrackers")


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


func test_ir26_pending_stacked_moss_over_goo() -> void:
	pending("OQ-37: Orb + Orb on a cell holding moss over goo (one hit to the top layer, or one to each)")


func test_ir26_pending_other_specials_on_the_board() -> void:
	pending("OQ-27: whether other specials cleared by Orb + Orb fire")


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
	var i_last_blast: int = -1
	for i in range(events.size()):
		if events[i].type == "blast":
			i_last_blast = i
	assert_eq(EV.count(events, "blast"), 2)
	assert_true(i_last_blast < EV.index_of(events, "crane_target"), "every Firecracker event before the Crane")


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


func test_ir27_pending_firing_cell_and_crane_crane() -> void:
	pending("OQ-26 (cell the other special fires from) and OQ-34 (which Crane goes first in Crane + Crane)")


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
