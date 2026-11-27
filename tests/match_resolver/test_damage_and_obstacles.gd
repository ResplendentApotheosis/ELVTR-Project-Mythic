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



# ---------------------------------------------------------------- IR-14 / IR-15 with covered pieces (OQ-41 A)

func test_ir14_match_next_to_a_moss_cell_hits_the_moss() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[3, 4], [5, 4], [4, 5]])
	BB.put(board, "Y", [[4, 3]])
	board.set_overlay(4, 3, "OB03", 2)
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.overlay_hp(4, 3), 1, "the match (3,4),(4,4),(5,4) touches the moss from below")
	assert_eq(board.get_color(4, 3), "Y", "the covered piece is not part of the match and stays")


func test_ir15_match_through_a_covered_piece_hits_the_moss_and_not_the_goo_below() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	board.set_overlay(3, 4, "OB03", 1)
	board.set_underlay(3, 4, "OB10", 1)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var cleared: Dictionary = EV.cleared(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(cleared.has(c), "match cell %s cleared" % c)
	assert_eq(board.overlay_hp(3, 4), 0, "moss removed")
	assert_eq(board.underlay_hp(3, 4), 1, "the goo below is not hit while the overlay was there")


# ---------------------------------------------------------------- IR-55 (OQ-50 A, trial)

func _shrine_board() -> BoardModel:
	var board: BoardModel = BB.blank()
	BB.add_shrine(board, 3, 3, {"R": 2, "B": 1}, 2, 2)
	return board


func _assert_shrine_needs_unchanged(board: BoardModel) -> void:
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 2, "still needs 2 R")
	assert_eq(BB.shrine_need(board, 3, 3, "B"), 1, "still needs 1 B")


func test_ir55_row_rocket_lowers_the_shrine_hp_but_not_its_needs() -> void:
	var board: BoardModel = _shrine_board()
	assert_eq(board.content_hp(3, 3), 3, "precondition: hp 3")
	BB.put(board, "R-", [[0, 3]])
	MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(board.content_hp(3, 3), 2, "one hit although the Rocket covers (3,3) and (4,3)")
	_assert_shrine_needs_unchanged(board)


func test_ir55_firecracker_double_blast_is_one_hit_on_the_shrine() -> void:
	var board: BoardModel = _shrine_board()
	BB.put(board, "RF", [[5, 4]])
	MatchResolver.tap(board, Vector2i(5, 4))
	assert_eq(board.content_hp(3, 3), 2, "both blasts cover (4,3),(4,4) but give one hit")
	_assert_shrine_needs_unchanged(board)


func test_ir55_rocket_rocket_combo_is_one_hit_on_the_shrine() -> void:
	var board: BoardModel = _shrine_board()
	BB.put(board, "R-", [[4, 5]])
	BB.put(board, "R|", [[4, 6]])
	MatchResolver.swap(board, Vector2i(4, 6), Vector2i(4, 5))
	assert_eq(board.content_hp(3, 3), 2, "column 4 covers (4,3),(4,4): one hit for the combo")
	_assert_shrine_needs_unchanged(board)


## OQ-59 A (c): a lit shrine is removed; its cells are ordinary open cells that fill by falling.
func _assert_shrine_removed_and_open(board: BoardModel, cells: Array) -> void:
	for c in cells:
		assert_eq(board.content_id(c[0], c[1]), "", "no shrine at (%d,%d)" % [c[0], c[1]])
		assert_eq(board.get_kind(c[0], c[1]), "plain", "(%d,%d) holds a plain piece after the board settles" % [c[0], c[1]])
	assert_eq(BB.empty_cells(board).size(), 0, "no playable cell is left empty")


func _lit_events(events: Array[BoardEvent]) -> Array:
	return EV.of_type(events, "shrine_lit")


# Matches next to a shrine fill its colours (OQ-55 A). A 3-match is made by swapping R (x,5)->(x,4) style.
func _three_r_below(board: BoardModel, x0: int) -> Array[BoardEvent]:
	# R at (x0,4),(x0+1,4); Y at (x0+2,4); R at (x0+2,5). Swap (x0+2,5)->(x0+2,4).
	BB.put(board, "R", [[x0, 4], [x0 + 1, 4], [x0 + 2, 5]])
	BB.put(board, "Y", [[x0 + 2, 4]])
	return MatchResolver.swap(board, Vector2i(x0 + 2, 5), Vector2i(x0 + 2, 4))


func _flat_shrine_board(needs: Dictionary) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.add_shrine(board, 3, 3, needs, 3, 1, 3)
	return board


func test_ir55_match_next_to_the_shrine_fills_needed_colours_one_per_piece() -> void:
	var board: BoardModel = _flat_shrine_board({"R": 2, "B": 1})
	var events: Array[BoardEvent] = _three_r_below(board, 3)
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 0, "two R pieces fill both red needs; the third fills nothing")
	assert_eq(BB.shrine_need(board, 3, 3, "B"), 1, "still needs 1 B")
	assert_eq(board.content_hp(3, 3), 3, "a match never lowers hp (OQ-59 A b)")
	assert_eq(_lit_events(events).size(), 0, "not lit")


func test_ir55_match_that_fills_the_last_need_lights_the_shrine() -> void:
	var board: BoardModel = _flat_shrine_board({"R": 3})
	var events: Array[BoardEvent] = _three_r_below(board, 3)
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 0, "it needs nothing")
	assert_eq(_lit_events(events).size(), 1, "a shrine-lit event")
	_assert_shrine_removed_and_open(board, [[3, 3], [4, 3], [5, 3]])
	# the new cells are ordinary: a swap there makes a match like anywhere else
	board.moves = 10
	BB.put(board, "R", [[3, 3], [4, 3], [5, 4]])
	BB.put(board, "Y", [[5, 3]])
	var swap_events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 4), Vector2i(5, 3))
	assert_true(EV.matched(swap_events).has(Vector2i(3, 3)), "a piece on a former shrine cell can be swapped and matched")


func test_ir55_match_of_a_colour_it_does_not_need_fills_nothing() -> void:
	var board: BoardModel = _flat_shrine_board({"Y": 1})
	BB.put(board, "G", [[3, 4], [4, 4], [5, 5]])
	BB.put(board, "B", [[5, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 5), Vector2i(5, 4))
	assert_true(EV.matched(events).has(Vector2i(3, 4)), "precondition: the G match happened")
	assert_eq(BB.shrine_need(board, 3, 3, "Y"), 1, "still needs 1 Y")
	assert_eq(_lit_events(events).size(), 0)


func test_ir55_match_touching_only_diagonally_fills_nothing() -> void:
	var board: BoardModel = _flat_shrine_board({"R": 2})
	var events: Array[BoardEvent] = _three_r_below(board, 6)
	assert_true(EV.matched(events).has(Vector2i(6, 4)), "precondition: the R match at (6,4)-(8,4) happened")
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 2, "(6,4) touches the shrine's (5,3) only diagonally")


func test_ir55_shrine_with_hp_one_is_lit_by_a_special_although_colours_are_needed() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	BB.add_shrine(board, 3, 3, {"R": 2, "B": 1}, 2, 2, 1)
	BB.put(board, "R-", [[0, 3]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(board.content_hp(3, 3), 0, "hp 1 -> 0")
	assert_eq(_lit_events(events).size(), 1, "a shrine-lit event")
	_assert_shrine_removed_and_open(board, [[3, 3], [4, 3], [3, 4], [4, 4]])


func _crane_shrine_board(needs: Dictionary, hp: int) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	BB.put(board, "GC", [[0, 7]])
	BB.add_shrine(board, 3, 3, needs, 2, 2, hp)
	board.goals = ["OB05"]
	return board


func test_ir55_crane_landing_counts_as_one_piece_and_takes_no_hp() -> void:
	var board: BoardModel = _crane_shrine_board({"R": 3}, 2)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 7))
	var landing: Array = EV.cells_of(events, "crane_landing")
	assert_eq(landing.size(), 1, "the Crane lands")
	if landing.size() == 1:
		var c: Vector2i = landing[0]
		assert_true(c.x >= 3 and c.x <= 4 and c.y >= 3 and c.y <= 4, "on a shrine cell, got %s" % c)
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 2, "needs 2 R")
	assert_eq(board.content_hp(3, 3), 2, "hp still 2")
	assert_eq(_lit_events(events).size(), 0)


func test_ir55_crane_landing_on_the_last_need_lights_the_shrine() -> void:
	var board: BoardModel = _crane_shrine_board({"B": 1}, 3)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 7))
	assert_eq(BB.shrine_need(board, 3, 3, "B"), 0, "it needs nothing")
	assert_eq(_lit_events(events).size(), 1, "a shrine-lit event")
	_assert_shrine_removed_and_open(board, [[3, 3], [4, 3], [3, 4], [4, 4]])


# ---- OQ-59 A (a): one touching piece makes the whole match count; OQ-61 A: a lifted coloured special counts.

func _board_2x2_shrine(needs: Dictionary) -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.add_shrine(board, 3, 3, needs, 2, 2, 3)
	return board


func test_ir55_match_with_a_piece_not_touching_still_counts_all_its_pieces() -> void:
	var board: BoardModel = _board_2x2_shrine({"R": 3})
	# R (2,5),(3,5), Y (4,5), R (4,6): swap makes R (2,5),(3,5),(4,5); (2,5) touches nothing.
	BB.put(board, "R", [[2, 5], [3, 5], [4, 6]])
	BB.put(board, "Y", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 6), Vector2i(4, 5))
	assert_true(EV.matched(events).has(Vector2i(2, 5)), "precondition: the 3-match happened")
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 0, "all 3 R count, the non-touching one too")
	assert_eq(_lit_events(events).size(), 1, "a shrine-lit event")


func test_ir55_match_touching_with_one_end_only_counts_all_pieces_and_keeps_hp() -> void:
	var board: BoardModel = _board_2x2_shrine({"R": 3, "B": 1})
	# R (5,4),(6,4), Y (7,4), R (7,5): match (5,4),(6,4),(7,4); only (5,4) touches (4,4).
	BB.put(board, "R", [[5, 4], [6, 4], [7, 5]])
	BB.put(board, "Y", [[7, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(7, 5), Vector2i(7, 4))
	assert_true(EV.matched(events).has(Vector2i(7, 4)), "precondition: the 3-match happened")
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 0, "all 3 R count")
	assert_eq(BB.shrine_need(board, 3, 3, "B"), 1, "still needs 1 B")
	assert_eq(board.content_hp(3, 3), 3, "a match never lowers hp")
	assert_eq(_lit_events(events).size(), 0, "not lit")
	assert_eq(board.content_id(3, 3), "OB05", "the shrine stays")


func test_ir55_lifted_coloured_rocket_in_the_match_fills_the_shrine() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.add_shrine(board, 2, 4, {"R": 3}, 3, 1, 3)
	BB.put(board, "R", [[2, 5], [5, 5]])
	BB.put(board, "R-", [[3, 5]])
	BB.put(board, "Y", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 5), Vector2i(4, 5))
	assert_eq(BB.shrine_need(board, 2, 4, "R"), 0, "the lifted Rocket counts: 3 pieces fill 3 needs")
	assert_eq(_lit_events(events).size(), 1, "a shrine-lit event")
	var i_clear: int = EV.index_of(events, "clear", 0)
	var i_lit: int = EV.index_of(events, "shrine_lit", 0)
	var i_fall: int = EV.index_of(events, "fall", 0)
	var i_refill: int = EV.index_of(events, "refill", 0)
	var i_fire: int = EV.index_of(events, "rocket_fire", 0)
	assert_true(i_clear >= 0 and i_clear < i_lit and i_lit < i_fall and i_fall < i_refill and i_refill < i_fire, "order: match clear, shrine lit, fall, refill, Rocket fires (got %s)" % [EV.sequence(events, ["clear", "shrine_lit", "fall", "refill", "rocket_fire"])])


func test_ir55_rocket_touching_the_shrine_is_enough_then_rocket_clears_the_new_cells() -> void:
	var board: BoardModel = _board_2x2_shrine({"R": 3})
	BB.put(board, "R-", [[5, 4]])
	BB.put(board, "R", [[6, 4], [7, 5]])
	BB.put(board, "Y", [[7, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(7, 5), Vector2i(7, 4))
	assert_eq(_lit_events(events).size(), 1, "only the Rocket touches the shrine, and all 3 count: lit")
	assert_eq(BB.shrine_need(board, 3, 3, "R"), 0)
	var i_lit: int = EV.index_of(events, "shrine_lit", 0)
	var i_fall: int = EV.index_of(events, "fall", 0)
	var i_refill: int = EV.index_of(events, "refill", 0)
	var i_fire: int = EV.index_of(events, "rocket_fire", 0)
	assert_true(i_lit >= 0 and i_lit < i_fall and i_fall < i_refill and i_refill < i_fire, "order: lit, fall, refill, fire (got %s)" % [EV.sequence(events, ["shrine_lit", "fall", "refill", "rocket_fire"])])
	if i_fire >= 0:
		var fire: BoardEvent = events[i_fire]
		assert_eq(fire.kind, "rocket_row")
		assert_eq(fire.cells.size(), 9, "row 4 has 9 cells")
		var i_clear: int = EV.index_after(events, "clear", i_fire)
		assert_true(i_clear > i_fire and events[i_clear].cells.size() == 9, "the Rocket clears 9 pieces, including the ones now on (3,4) and (4,4)")
		if i_clear > i_fire:
			assert_true(events[i_clear].cells.has(Vector2i(3, 4)) and events[i_clear].cells.has(Vector2i(4, 4)))
	assert_eq(EV.count(events, "shrine_lit"), 1, "the Rocket's later fire does not light a shrine again")


# IR-14: a match next to a shrine gives it no hit (OQ-59 A b).
func test_ir14_match_next_to_a_shrine_does_not_lower_its_hp() -> void:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.add_shrine(board, 3, 3, {"B": 1}, 3, 1, 1)
	BB.put(board, "G", [[3, 4], [4, 4], [5, 5]])
	BB.put(board, "B", [[5, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 5), Vector2i(5, 4))
	assert_true(EV.matched(events).has(Vector2i(3, 4)), "precondition: the G match happened")
	assert_eq(board.content_hp(3, 3), 1, "hp still 1")
	assert_eq(BB.shrine_need(board, 3, 3, "B"), 1, "still needs 1 B")
	assert_eq(_lit_events(events).size(), 0, "not lit")
	assert_eq(board.content_id(3, 3), "OB05", "the shrine stays")

