# GUT tests for IR-09..IR-15, IR-44, IR-45 (hits on layers and obstacles).
# API: tests/API_CONTRACT.md. Specials are put on the board and tapped or swapped.
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


# ---------------------------------------------------------------- IR-09

func test_ir09_special_hits_bramble_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	board.add_content("OB02", 5, 3, 2)
	MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(board.content_hp(5, 3), 1)


func test_ir09_piece_on_goo_is_cleared_and_goo_takes_the_hit() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	BB.put(board, "R", [[2, 3]])
	board.set_underlay(2, 3, "OB10", 2)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 3))
	assert_true(EV.cleared(events).has(Vector2i(2, 3)), "piece cleared")
	assert_eq(board.underlay_hp(2, 3), 1)


func test_ir09_piece_under_moss_hp1_is_cleared_and_moss_removed() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	BB.put(board, "Y", [[6, 3]])
	board.set_overlay(6, 3, "OB03", 1)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 3))
	assert_true(EV.cleared(events).has(Vector2i(6, 3)))
	assert_eq(board.overlay_hp(6, 3), 0)


func test_ir09_top_layer_only_goo_under_moss_is_not_hit() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	BB.put(board, "B", [[4, 3]])
	board.set_overlay(4, 3, "OB03", 1)
	board.set_underlay(4, 3, "OB10", 1)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 3))
	assert_true(EV.cleared(events).has(Vector2i(4, 3)))
	assert_eq(board.overlay_hp(4, 3), 0)
	assert_eq(board.underlay_hp(4, 3), 1)


func test_ir09_overlay_that_survives_keeps_the_cell_covered_and_refills() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	BB.put(board, "Y", [[6, 3]])
	board.set_overlay(6, 3, "OB03", 2)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 3))
	assert_true(EV.cleared(events).has(Vector2i(6, 3)), "Y cleared")
	assert_eq(board.overlay_hp(6, 3), 1, "moss hp 2 -> 1")
	assert_eq(board.get_color(6, 3), BB.filler_color(6, 2), "the piece from (6,2) fell into (6,3), under the moss")
	assert_eq(board.overlay_hp(6, 3), 1, "and the moss is still on it")


# ---------------------------------------------------------------- IR-10

func test_ir10_column_pillar_takes_one_hit_from_a_column_rocket() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R|", [[4, 8]])
	board.add_content("OB06", 4, 0, 3, 1, 4)
	MatchResolver.tap(board, Vector2i(4, 8))
	assert_eq(board.content_hp(4, 0), 2)
	assert_eq(board.content_hp(4, 3), 2, "all cells of the pillar share one hp")


func test_ir10_square_pillar_takes_one_hit_from_a_firecracker() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 5]])
	board.add_content("OB06", 3, 3, 3, 2, 2)
	MatchResolver.tap(board, Vector2i(4, 5))
	assert_eq(board.content_hp(3, 3), 2)


func test_ir10_square_pillar_takes_one_hit_from_a_row_rocket() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	board.add_content("OB06", 3, 3, 3, 2, 2)
	MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(board.content_hp(3, 3), 2)


func test_ir10_square_pillar_takes_one_hit_from_a_rocket_firecracker_combo() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[5, 6]])
	BB.put(board, "RF", [[5, 5]])
	board.add_content("OB06", 3, 3, 3, 2, 2)
	MatchResolver.swap(board, Vector2i(5, 6), Vector2i(5, 5))
	assert_eq(board.content_hp(3, 3), 2)


# ---------------------------------------------------------------- IR-11

func test_ir11_moss_is_hit_once_per_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 2]])
	for x in [2, 3, 4, 5]:
		board.set_overlay(x, 2, "OB03", 1)
	MatchResolver.tap(board, Vector2i(0, 2))
	for x in [2, 3, 4, 5]:
		assert_eq(board.overlay_hp(x, 2), 0, "moss at (%d,2) removed" % x)


func test_ir11_two_by_two_shrine_is_multi_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 3]])
	board.add_content("OB05", 3, 3, 3, 2, 2)
	MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(board.content_hp(3, 3), 2, "one hit, not two")


# ---------------------------------------------------------------- IR-12

func test_ir12_firecracker_hits_bramble_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	board.add_content("OB02", 5, 4, 2)
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.content_hp(5, 4), 1)


func test_ir12_firecracker_hits_frozen_idol_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	board.add_content("OB12", 3, 3, 2)
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.content_hp(3, 3), 1)


func test_ir12_goo_under_a_piece_takes_one_hit_across_both_blasts() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "R", [[4, 5]])
	board.set_underlay(4, 5, "OB10", 2)
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.underlay_hp(4, 5), 1)


func test_ir12_moss_hit_by_blast_one_then_goo_hit_by_blast_two() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "Y", [[3, 3]])
	board.set_overlay(3, 3, "OB03", 1)
	board.set_underlay(3, 3, "OB10", 1)
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.overlay_hp(3, 3), 0, "moss removed by blast 1")
	assert_eq(board.underlay_hp(3, 3), 0, "goo hit by blast 2 (not hit before)")


# ---------------------------------------------------------------- IR-13

func _match_below_idol(board: BoardModel) -> void:
	BB.put(board, "R", [[3, 5], [5, 5], [4, 6]])
	MatchResolver.swap(board, Vector2i(4, 6), Vector2i(4, 5))


func test_ir13_adjacent_match_is_one_hit_on_idol() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB12", 4, 4, 2)
	_match_below_idol(board)
	assert_eq(board.content_hp(4, 4), 1)


func test_ir13_second_adjacent_match_clears_the_idol() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB12", 4, 4, 1)
	_match_below_idol(board)
	assert_eq(board.content_hp(4, 4), 0)


func test_ir13_a_special_is_one_hit_on_idol() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 4]])
	board.add_content("OB12", 4, 4, 2)
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.content_hp(4, 4), 1)


func test_ir13_l_match_touching_twice_is_still_one_hit() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB12", 4, 4, 2)
	BB.put(board, "R", [[3, 3], [3, 4], [4, 5], [5, 5], [2, 5]])
	BB.put(board, "Y", [[3, 5]])
	MatchResolver.swap(board, Vector2i(2, 5), Vector2i(3, 5))
	assert_eq(board.content_hp(4, 4), 1)


# ---------------------------------------------------------------- IR-14

func test_ir14_match_next_to_bramble_hits_it() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 4, 3, 3)
	BB.put(board, "R", [[3, 4], [5, 4], [4, 5]])
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.content_hp(4, 3), 2)


func test_ir14_diagonal_contact_does_not_count() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 4, 3, 1)
	BB.put(board, "R", [[5, 4], [7, 4], [6, 5]])
	MatchResolver.swap(board, Vector2i(6, 5), Vector2i(6, 4))
	assert_eq(board.content_hp(4, 3), 1)


func test_ir14_pillar_alongside_a_match_takes_one_hit() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB06", 4, 2, 3, 1, 4)
	BB.put(board, "R", [[5, 2], [5, 3], [6, 4]])
	MatchResolver.swap(board, Vector2i(6, 4), Vector2i(5, 4))
	assert_eq(board.content_hp(4, 2), 2)


func test_ir14_one_match_hits_two_different_brambles() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 3, 3, 2)
	board.add_content("OB02", 5, 3, 2)
	BB.put(board, "R", [[3, 4], [5, 4], [4, 5]])
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.content_hp(3, 3), 1)
	assert_eq(board.content_hp(5, 3), 1)


func test_ir14_match_next_to_creature_frees_it_and_counts_the_goal() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 2, 2, 1)
	BB.put(board, "R", [[3, 1], [3, 2], [4, 3]])
	MatchResolver.swap(board, Vector2i(4, 3), Vector2i(3, 3))
	assert_eq(board.content_hp(2, 2), 0)
	assert_eq(board.collected_count("OB07"), 1)


# ---------------------------------------------------------------- IR-15

func test_ir15_goo_hp1_is_cleared_by_a_match_on_top() -> void:
	var board: BoardModel = BB.blank()
	board.set_underlay(3, 5, "OB10", 1)
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_eq(board.underlay_hp(3, 5), 0)


func test_ir15_goo_hp2_loses_one_layer_from_a_match_on_top() -> void:
	var board: BoardModel = BB.blank()
	board.set_underlay(3, 5, "OB10", 2)
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_eq(board.underlay_hp(3, 5), 1)


func test_ir15_special_with_nothing_above_hits_the_goo() -> void:
	var board: BoardModel = BB.blank()
	board.set_underlay(3, 5, "OB10", 1)
	BB.put(board, "R|", [[3, 8]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(3, 8))
	assert_true(EV.cleared(events).has(Vector2i(3, 5)), "piece cleared")
	assert_eq(board.underlay_hp(3, 5), 0)


func test_ir15_match_on_goo_hits_it_but_dew_is_not_damaged() -> void:
	# Dew is not hit like goo: a match on dew spreads it (IR-53). The dew cell keeps its dew.
	var board: BoardModel = BB.blank()
	BB.set_dew(board, 3, 5)
	BB.put(board, "R", [[2, 5], [4, 5], [3, 6]])
	MatchResolver.swap(board, Vector2i(3, 6), Vector2i(3, 5))
	assert_true(BB.has_dew(board, 3, 5), "dew stays under the cleared piece")


# ---------------------------------------------------------------- IR-44

func test_ir44_rocket_clearing_pieces_does_not_hit_neighbouring_bramble() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 4]])
	board.add_content("OB02", 4, 3, 2)
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.content_hp(4, 3), 2)


func test_ir44_firecracker_does_not_hit_creature_next_to_its_area() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 2]])
	board.add_content("OB07", 2, 2, 1)
	MatchResolver.tap(board, Vector2i(4, 2))
	assert_eq(board.content_hp(2, 2), 1)


func test_ir44_rocket_does_not_hit_moss_next_to_a_cleared_piece() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 4]])
	board.set_overlay(4, 5, "OB03", 1)
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.overlay_hp(4, 5), 1)


# ---------------------------------------------------------------- IR-45

func test_ir45_rocket_rocket_hits_the_crossing_cell_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "R|", [[4, 5]])
	board.set_underlay(4, 4, "OB10", 2)
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.underlay_hp(4, 4), 1)


func test_ir45_firecracker_firecracker_hits_an_obstacle_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4], [4, 5]])
	board.add_content("OB02", 3, 3, 3)
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.content_hp(3, 3), 2)


func test_ir45_rocket_firecracker_hits_a_square_pillar_once() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[5, 6]])
	BB.put(board, "RF", [[5, 5]])
	board.add_content("OB06", 3, 3, 3, 2, 2)
	MatchResolver.swap(board, Vector2i(5, 6), Vector2i(5, 5))
	assert_eq(board.content_hp(3, 3), 2)


# ---------------------------------------------------------------- blocked by open questions

func test_ir14_pending_match_through_a_covered_piece() -> void:
	pending("OQ-41: what a match that includes a piece under an overlay does to the piece and to the overlay")
