# GUT tests for IR-01, IR-02, IR-39, IR-52 (swaps, taps, what can be swapped).
# API: tests/API_CONTRACT.md. Run: see CLAUDE.md "Run all tests".
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


# ---------------------------------------------------------------- IR-01

func test_ir01_swap_that_makes_a_match_clears_it_and_uses_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(matched.has(c), "cell %s should be in the match" % c)
	assert_eq(board.moves, 19, "a matching swap uses one move")


func test_ir01_swap_with_no_match_snaps_back_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(0, 0), Vector2i(1, 0))
	assert_eq(BB.snapshot(board), before, "board identical after snap-back")
	assert_eq(board.moves, 20)
	assert_eq(EV.count(events, "invalid_swap"), 1, "an invalid_swap event is returned")


func test_ir01_hatchling_swap_with_no_match_snaps_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "H", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(BB.snapshot(board), before, "hatchling still at (4,4), Y still at (4,5)")
	assert_eq(board.moves, 20)
	assert_eq(EV.count(events, "invalid_swap"), 1)


func test_ir01_hatchling_swap_that_makes_a_match_uses_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "H", [[4, 4]])
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(matched.has(c), "cell %s should match" % c)
	assert_eq(board.moves, 19)


func test_ir01_two_hatchlings_swapped_with_no_match_snap_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 20
	BB.put(board, "H", [[4, 4], [5, 4]])
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(5, 4))
	assert_eq(BB.snapshot(board), before)
	assert_eq(EV.count(events, "invalid_swap"), 1)


# ---------------------------------------------------------------- IR-02

func test_ir02_tapping_a_firecracker_fires_it_and_costs_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(EV.count(events, "blast"), 2, "Firecracker blasts twice (IR-17)")
	assert_eq(board.moves, 9)


func test_ir02_tapping_a_plain_piece_does_nothing() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(events.size(), 0, "no events for a plain tap")
	assert_eq(BB.snapshot(board), before)
	assert_eq(board.moves, 10)



func test_ir02_tapping_a_special_under_an_overlay_does_nothing() -> void:
	# OQ-57 A: a covered special is locked and can't be tapped.
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R-", [[2, 6]])
	board.set_overlay(2, 6, "OB03", 1)
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(2, 6))
	assert_eq(EV.count(events, "rocket_fire"), 0, "no fire event")
	assert_eq(BB.snapshot(board), before, "board unchanged")
	assert_eq(board.moves, 10, "no move used")


# ---------------------------------------------------------------- IR-39

func test_ir39_rocket_swapped_with_plain_fires_from_its_new_cell() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R-", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "never snapped back")
	assert_eq(board.moves, 9)
	assert_eq(EV.cells_of(events, "rocket_fire"), [Vector2i(4, 5)], "fires once, from (4,5)")
	assert_true(EV.same_set(EV.cleared(events), EV.to_set(EV.row_cells(5))), "all of row 5 and nothing in row 4")


func test_ir39_firecracker_swapped_with_plain_is_never_snapped_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "Y", [[5, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(5, 4), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "no snap-back")
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "blast"), 2, "exactly one Firecracker fire = two blast events")
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(5, 4), Vector2i(5, 4)], "centred on its new cell (5,4)")


func test_ir39_match_resolves_first_then_the_firecracker_fires_from_its_new_cell() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "YF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_blast: int = EV.index_of(events, "blast", 0)
	assert_true(i_clear >= 0 and i_blast >= 0, "a match clear and a blast exist")
	assert_true(i_clear < i_blast, "the match's clear event comes first")
	if i_clear >= 0:
		var first: Dictionary = EV.to_set(events[i_clear].cells)
		for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
			assert_true(first.has(c), "R match cleared cell %s" % c)
		assert_false(first.has(Vector2i(4, 5)), "IR-50: the lifted Firecracker (now at (4,5)) is not in the match's clear event")
	var blasts: Array = EV.of_type(events, "blast")
	assert_eq(blasts.size(), 2)
	for b in blasts:
		assert_eq(b.cell, Vector2i(4, 5), "centred on (4,5), where the Firecracker now sits")
		assert_true(EV.same_set(EV.to_set(b.cells), EV.to_set(EV.rect_cells(3, 4, 5, 6))), "area x 3-5, y 4-6")


func test_ir39_crane_swapped_with_plain_fires_from_its_new_cell() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "G", [[4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 0)
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "crane_target"), 1, "the Crane fires (IR-49)")
	assert_eq(EV.cells_of(events, "crane_takeoff"), [Vector2i(4, 3)], "take-off from (4,3)")


func test_ir39_firecracker_swapped_with_hatchling_fires_and_spares_the_hatchling() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "RF", [[4, 4]])
	BB.put(board, "H", [[4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "accepted")
	assert_eq(board.moves, 9)
	assert_eq(EV.cells_of(events, "blast"), [Vector2i(4, 5), Vector2i(4, 5)], "centred on (4,5)")
	assert_eq(BB.find_drop(board, "OB11").size(), 1, "hatchling not destroyed")
	assert_eq(board.collected_count("OB11"), 0, "and not collected")


func test_ir39_same_setups_with_two_plain_pieces_snap_back() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "G", [[4, 4], [4, 3]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 3))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir39_swapped_firecracker_is_lifted_cells_refill_then_it_fires_from_its_new_cell() -> void:
	# OQ-44 A + OQ-54 A. R at (2,4),(3,4); yellow Firecracker at (4,4); R at (4,5).
	# After the swap the Firecracker sits at (4,5); the R match clears and lifts it; column 4 has two gaps.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "YF", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)
	assert_eq(EV.count(events, "match"), 1, "no cascade match in this set-up")
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_fall: int = EV.index_after(events, "fall", i_clear)
	var i_refill: int = EV.index_after(events, "refill", i_fall)
	var i_blast: int = EV.index_of(events, "blast", 0)
	assert_true(i_clear >= 0 and i_fall > i_clear and i_refill > i_fall and i_blast > i_refill, "events in order: match clear, fall, refill, blast 1")
	if i_fall < 0 or i_refill < 0 or i_blast < 0:
		return
	var moved: Dictionary = EV.fall_map(events[i_fall])
	assert_eq(moved.get(Vector2i(2, 4)), Vector2i(2, 3), "column 2 drops by one")
	assert_eq(moved.get(Vector2i(3, 4)), Vector2i(3, 3), "column 3 drops by one")
	for y in range(2, 6):
		assert_eq(moved.get(Vector2i(4, y)), Vector2i(4, y - 2), "column 4 drops by two: (4,%d) <- (4,%d)" % [y, y - 2])
	assert_true(EV.same_set(EV.to_set(events[i_refill].cells), EV.to_set([Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(4, 1)])), "new pieces at (2,0),(3,0),(4,0),(4,1): the lifted Firecracker's cell refilled too")
	assert_eq(events[i_blast].cell, Vector2i(4, 5), "blast 1 is centred on (4,5)")
	var i_blast_clear: int = EV.index_after(events, "clear", i_blast)
	assert_true(i_blast_clear > i_blast, "blast 1 clears something")
	if i_blast_clear > i_blast:
		var cleared: Dictionary = EV.to_set(events[i_blast_clear].cells)
		for c in [Vector2i(3, 4), Vector2i(4, 4), Vector2i(4, 5)]:
			assert_true(cleared.has(c), "blast 1 clears the piece that fell into %s" % c)
		assert_false(cleared.has(Vector2i(2, 4)), "(2,4) is outside the blast (x 3-5)")


func test_ir39_a_cascade_made_by_the_fall_waits_until_the_swapped_rocket_has_fired() -> void:
	# OQ-44 A + OQ-54 A. After the R match clears and the Rocket (now at (7,7)) is lifted, G lines up at
	# (4,6),(5,6),(6,6); that cascade resolves only after the column Rocket has fired along column 7.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "R", [[5, 6], [6, 6], [7, 7]])
	BB.put(board, "B|", [[7, 6]])
	BB.put(board, "G", [[4, 6], [5, 5], [6, 5]])
	BB.put(board, "Y", [[4, 5], [7, 5]])
	BB.put(board, "B", [[5, 4]])
	BB.put(board, "R", [[6, 4]])
	assert_false(BB.has_match(board), "precondition: no match before the swap")
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(7, 7), Vector2i(7, 6))
	assert_eq(board.moves, 9)
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_fall1: int = EV.index_after(events, "fall", i_clear)
	var i_refill1: int = EV.index_after(events, "refill", i_fall1)
	var i_fire: int = EV.index_of(events, "rocket_fire")
	var i_refill2: int = EV.index_after(events, "refill", i_fire)
	var i_match2: int = EV.index_of(events, "match", 1)
	assert_true(i_clear >= 0 and i_fall1 > i_clear and i_refill1 > i_fall1, "R match clear, fall, refill")
	assert_true(i_fire > i_refill1, "then the Rocket fires")
	assert_true(i_refill2 > i_fire, "refill after the Rocket")
	assert_true(i_match2 > i_refill2, "the G cascade match comes last")
	if i_fall1 >= 0:
		var moved: Dictionary = EV.fall_map(events[i_fall1])
		assert_eq(moved.get(Vector2i(5, 6)), Vector2i(5, 5), "column 5 drops by one")
		assert_eq(moved.get(Vector2i(6, 6)), Vector2i(6, 5), "column 6 drops by one")
		for y in range(2, 8):
			assert_eq(moved.get(Vector2i(7, y)), Vector2i(7, y - 2), "column 7 drops by two (the lifted Rocket's cell is gone): (7,%d) <- (7,%d)" % [y, y - 2])
	if i_fire >= 0:
		assert_eq(events[i_fire].cell, Vector2i(7, 7), "the Rocket fires from (7,7)")
		assert_eq(events[i_fire].kind, "rocket_col")
	if i_match2 >= 0:
		var m: Dictionary = EV.to_set(events[i_match2].cells)
		for c in [Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6)]:
			assert_true(m.has(c), "G match includes %s" % c)
	assert_eq(EV.sequence(events, ["match", "rocket_fire"]), ["match", "rocket_fire", "match"], "match, Rocket, G cascade")


func test_ir39_swapped_row_rocket_fires_along_the_row_of_its_cell_after_the_swap() -> void:
	# OQ-54 A. Row Rocket (B) at (4,5); R at (4,4); R at (2,5),(3,5). The Rocket moves to (4,4).
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 10
	BB.put(board, "B-", [[4, 5]])
	BB.put(board, "R", [[4, 4], [2, 5], [3, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)
	assert_eq(EV.sequence(events, ["match", "fall", "refill", "rocket_fire"]).slice(0, 4), ["match", "fall", "refill", "rocket_fire"], "match clear, fall, refill, Rocket fire")
	var i_clear: int = EV.index_of_clear(events, "match")
	var i_fall: int = EV.index_after(events, "fall", i_clear)
	var i_fire: int = EV.index_of(events, "rocket_fire")
	assert_true(i_clear >= 0 and i_fall > i_clear and i_fire > i_fall, "events found")
	if i_fall < 0 or i_fire < 0:
		return
	var moved: Dictionary = EV.fall_map(events[i_fall])
	assert_eq(moved.get(Vector2i(2, 5)), Vector2i(2, 4), "column 2 drops by one")
	assert_eq(moved.get(Vector2i(3, 5)), Vector2i(3, 4), "column 3 drops by one")
	for y in range(2, 6):
		assert_eq(moved.get(Vector2i(4, y)), Vector2i(4, y - 2), "column 4 drops by two: (4,%d) <- (4,%d)" % [y, y - 2])
	var fire: BoardEvent = events[i_fire]
	assert_eq(fire.kind, "rocket_row")
	assert_eq(fire.cell, Vector2i(4, 4), "fires from (4,4), the cell it moved into")
	assert_true(EV.same_set(EV.to_set(fire.cells), EV.to_set(EV.row_cells(4))), "all 9 cells of row 4, none of row 5")
	var i_fire_clear: int = EV.index_after(events, "clear", i_fire)
	assert_true(i_fire_clear > i_fire)
	if i_fire_clear > i_fire:
		assert_true(EV.same_set(EV.to_set(events[i_fire_clear].cells), EV.to_set(EV.row_cells(4))), "the Rocket's clear is exactly row 4, including the piece that fell from (4,2) into (4,4)")


# ---------------------------------------------------------------- IR-52

func _assert_refused(board: BoardModel, from: Vector2i, to: Vector2i) -> void:
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, from, to)
	assert_eq(BB.snapshot(board), before, "refused swap changes nothing (moves included)")
	assert_eq(board.moves, 10)
	assert_eq(EV.count(events, "invalid_swap"), 1, "refusal reports invalid_swap")


func test_ir52_swap_with_an_obstacle_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	board.add_content("OB02", 4, 4, 2)
	BB.put(board, "R", [[4, 5]])
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))


func test_ir52_diagonal_swap_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	_assert_refused(board, Vector2i(3, 3), Vector2i(4, 4))


func test_ir52_swap_with_a_cocooned_fragment_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	board.add_content("OB07", 2, 2, 1, 1, 1, true)
	BB.put(board, "Y", [[3, 2]])
	_assert_refused(board, Vector2i(3, 2), Vector2i(2, 2))


func test_ir52_swap_with_an_empty_cell_is_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "X", [[4, 4]])
	BB.put(board, "R", [[4, 5]])
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))


func test_ir52_hatchling_can_be_swapped_when_the_swap_makes_a_match() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "H", [[4, 4]])
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_true(matched.has(c), "cell %s should match" % c)
	assert_eq(board.moves, 9)
	# The swap moved the hatchling to (4,5); it then fell or was collected at the bottom (IR-51, IR-30).
	assert_eq(BB.find_drop(board, "OB11").size() + board.collected_count("OB11"), 1, "hatchling kept")


func test_ir52_covered_piece_cannot_be_swapped_either_way() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[4, 4]])
	BB.put(board, "Y", [[4, 5]])
	board.set_overlay(4, 4, "OB03", 1)
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))
	_assert_refused(board, Vector2i(4, 4), Vector2i(4, 5))


func test_ir52_covered_piece_that_would_make_a_match_is_still_refused() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	board.set_overlay(4, 5, "OB03", 1)
	_assert_refused(board, Vector2i(4, 5), Vector2i(4, 4))
