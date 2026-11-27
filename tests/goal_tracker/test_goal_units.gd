# GUT tests for what counts toward a goal: IR-61 (one unit = one obstacle fully gone), IR-31 (fragment goal),
# IR-59 (goals per tier), IR-14, IR-29, IR-30, IR-26, IR-48, IR-49 (hits vs units), IR-53, IR-55.
# API: tests/API_CONTRACT.md section 10. Pending placeholders name the open question (OQ) that blocks a case.
extends "res://tests/helpers/goal_test_base.gd"

const FRAGMENT_LEVELS: Array = [26, 30, 33, 35, 38, 40, 45, 50]
const SOME_OBSTACLES: Array = ["OB02", "OB03", "OB05", "OB06", "OB07", "OB10"]


func _goals_of(n: int, with_fragment: bool = false) -> Array:
	var goals: Array = []
	for i in range(n):
		goals.append(obstacle_goal(SOME_OBSTACLES[i], 1))
	if with_fragment:
		goals.append(obstacle_goal("OB07", 1, true))
	return goals


func _errors(level: int, tier: String, goals: Array) -> Array:
	var result: Variant = tracker_static("goal_errors", [level, tier, goals])
	if result == null:
		return ["missing"]
	return result


func _valid(level: int, tier: String, goals: Array) -> bool:
	var result: Variant = tracker_static("goal_errors", [level, tier, goals])
	return result != null and result.is_empty()


# ---------------------------------------------------------------- IR-61 (units)

func test_ir61_bramble_counts_only_when_its_last_layer_is_gone() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 4, 3, 3)
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	swap_row_match(board, 4, 4)
	swap_row_match(board, 4, 4)
	assert_eq(board.content_hp(4, 3), 1, "1 layer left after two matches")
	assert_eq(units(t, 0), 0, "goal 0/1")
	var events: Array[BoardEvent] = swap_row_match(board, 4, 4)
	assert_eq(board.content_hp(4, 3), 0, "bramble gone")
	assert_eq(units(t, 0), 1, "goal 1/1")
	assert_eq(EV.count(events, "win"), 1)


func test_ir61_pillar_counts_only_when_ground_down_completely() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB06", 4, 4, 3, 2, 2)
	var t: Variant = track(board, [obstacle_goal("OB06", 1)])
	if t == null:
		return
	BB.put(board, "R-", [[0, 4]])
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.content_hp(4, 4), 2, "hp 2")
	assert_eq(units(t, 0), 0, "goal 0/1")
	board.set_piece(0, 4, "rocket_row", "R")
	MatchResolver.tap(board, Vector2i(0, 4))
	board.set_piece(0, 4, "rocket_row", "R")
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.content_hp(4, 4), 0, "pillar gone")
	assert_eq(units(t, 0), 1, "goal 1/1")
	assert_eq(EV.count(events, "win"), 1)


func test_ir61_moss_counts_each_cell_removed() -> void:
	var board: BoardModel = BB.blank()
	board.set_overlay(1, 1, "OB03", 2)
	board.set_overlay(6, 6, "OB03", 1)
	BB.put(board, "R-", [[1, 6], [1, 7]])
	var t: Variant = track(board, [obstacle_goal("OB03", 2)])
	if t == null:
		return
	# Rocket + Rocket centred on (1,6): column 1 covers (1,1), row 6 covers (6,6).
	MatchResolver.swap(board, Vector2i(1, 7), Vector2i(1, 6))
	assert_eq(board.overlay_hp(1, 1), 1, "(1,1) hp 1")
	assert_eq(board.overlay_hp(6, 6), 0, "(6,6) removed")
	assert_eq(units(t, 0), 1, "goal 1/2")


func test_ir61_goo_counts_when_cleared() -> void:
	var board: BoardModel = BB.blank()
	board.set_underlay(3, 5, "OB10", 2)
	var t: Variant = track(board, [obstacle_goal("OB10", 1)])
	if t == null:
		return
	swap_row_match(board, 3, 5)
	assert_eq(board.underlay_hp(3, 5), 1, "hp 1")
	assert_eq(units(t, 0), 0, "goal 0/1")
	var events: Array[BoardEvent] = swap_row_match(board, 3, 5)
	assert_eq(board.underlay_hp(3, 5), 0, "cleared")
	assert_eq(units(t, 0), 1, "goal 1/1")
	assert_eq(EV.count(events, "win"), 1)


func test_ir61_idol_with_hits_left_does_not_count() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB12", 4, 4, 2)
	var t: Variant = track(board, [obstacle_goal("OB12", 1)])
	if t == null:
		return
	BB.put(board, "R-", [[0, 4]])
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.content_hp(4, 4), 1, "1 hit left")
	assert_eq(units(t, 0), 0, "goal 0/1")


func test_ir61_shrine_counts_when_lit() -> void:
	var board: BoardModel = BB.blank()
	BB.add_shrine(board, 3, 3, {"R": 2}, 1, 1, 3)
	var t: Variant = track(board, [obstacle_goal("OB05", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 3, 4)
	assert_eq(EV.count(events, "shrine_lit"), 1)
	assert_eq(units(t, 0), 1, "goal 1/1 (IR-55)")
	assert_eq(EV.count(events, "win"), 1)


func test_ir61_validator_goal_count_must_equal_the_pillars_placed_not_their_hp() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB06", 0, 0, 4, 2, 2)
	board.add_content("OB06", 4, 4, 4, 2, 2)
	var ok: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB06", 2)], board])
	var too_many: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB06", 4)], board])
	var too_few: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB06", 1)], board])
	if ok == null or too_many == null or too_few == null:
		return
	assert_true(ok.is_empty(), "count 2 with 2 pillars is valid")
	assert_false(too_many.is_empty(), "count 4 (the hp) is rejected")
	assert_false(too_few.is_empty(), "count 1 is rejected")


func test_ir61_validator_goal_count_must_equal_the_brambles_placed() -> void:
	var board: BoardModel = BB.blank()
	for i in range(17):
		board.add_content("OB02", i % 9, i / 9, 1 + i % 3)
	var ok: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB02", 17)], board])
	var low: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB02", 16)], board])
	var high: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB02", 18)], board])
	if ok == null or low == null or high == null:
		return
	assert_true(ok.is_empty(), "17 with 17 placed is valid")
	assert_false(low.is_empty(), "16 is rejected")
	assert_false(high.is_empty(), "18 is rejected")


func test_ir61_colour_goals_are_rejected() -> void:
	var goals: Array = [obstacle_goal("OB02", 1), {"color": "red", "count": 20}]
	var errors: Array = _errors(12, "easy", goals)
	assert_false(errors.is_empty(), "a colour goal is rejected")
	var mentions_colour: bool = false
	for e in errors:
		if String(e).to_lower().contains("color") or String(e).to_lower().contains("colour"):
			mentions_colour = true
	assert_true(mentions_colour, "the error names the colour goal: %s" % [errors])


func test_ir61_dew_goal_counts_seed_cells_from_the_start() -> void:
	# OQ-66 (trial): seeds under (1,1), (2,1), (3,1) count at the start: 3/10.
	var board: BoardModel = BB.blank()
	for x in [1, 2, 3]:
		BB.set_dew(board, x, 1)
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 10)])
	if t == null:
		return
	assert_eq(units(t, 0), 3, "goal 3/10 at the start")
	assert_false(t.is_goal_done(0))


func test_ir61_dew_goal_reaches_its_count_as_more_cells_get_dew() -> void:
	# 3 seeds in row 1. A row Rocket along row 1 gives all 9 cells dew (9/10); a column Rocket through a dew cell
	# of column 4 adds 8 more cells: the goal is done and the move wins.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	for x in [1, 2, 3]:
		BB.set_dew(board, x, 1)
	BB.put(board, "R-", [[0, 1]])
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 10)])
	if t == null:
		return
	var e1: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 1))
	assert_eq(units(t, 0), 9, "9 cells of row 1 have dew: 9/10")
	assert_eq(EV.count(e1, "win"), 0, "not yet")
	board.set_piece(4, 0, "rocket_col", "R")
	var e2: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 0))
	assert_true(t.is_goal_done(0), "goal done")
	assert_eq(EV.count(e2, "win"), 1, "the move wins")


func test_ir61_dew_a_match_over_a_cell_that_already_has_dew_is_not_counted_twice() -> void:
	# 9 cells have dew; the match on (3,5) (dew) gives dew to (2,5) and (4,5) as well: 11 cells, goal 10 done.
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
	assert_eq(BB.dew_cells(board).size(), 11, "11 cells have dew: (3,5) was not counted twice")
	assert_true(t.is_goal_done(0), "goal done")
	assert_eq(EV.count(events, "win"), 1)
	# Progress past the count and the seed rule: tests/goal_tracker/test_dew_goal_cap.gd (OQ-73, OQ-74).


func test_ir61_validator_dew_goal_count_at_most_90_percent_of_a_9x9_board() -> void:
	var board: BoardModel = BB.blank()
	var ok: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB04", 72)], board])
	var high: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB04", 73)], board])
	if ok == null or high == null:
		return
	assert_true(ok.is_empty(), "72 of 81 cells (72 <= 72.9) is valid")
	assert_false(high.is_empty(), "73 is rejected")


func test_ir61_validator_dew_goal_count_at_most_90_percent_of_70_playable_cells() -> void:
	var board: BoardModel = BB.blank()
	var removed: int = 0
	for y in range(9):
		for x in range(9):
			if removed < 11 and (x + y) % 7 == 3:
				board.set_playable(x, y, false)
				removed += 1
	assert_eq(removed, 11, "precondition: 70 playable cells")
	var ok: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB04", 63)], board])
	var high: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB04", 64)], board])
	if ok == null or high == null:
		return
	assert_true(ok.is_empty(), "63 = 90% of 70 is valid")
	assert_false(high.is_empty(), "64 is rejected")


func test_ir61_validator_plain_ob07_goal_includes_the_fragment_cocoon() -> void:
	# Fragment level, goals: fragment OB07 count 1 + plain OB07 count 3; 3 OB07 entries, one marked fragment.
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	board.add_content("OB07", 1, 2, 1)
	board.add_content("OB07", 7, 2, 1)
	var ok: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 3)], board])
	var low: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 2)], board])
	if ok == null or low == null:
		return
	assert_true(ok.is_empty(), "plain count 3 includes the fragment's cocoon: valid")
	assert_false(low.is_empty(), "plain count 2 leaves the fragment's cocoon out: rejected")


func test_ir61_validator_plain_ob11_goal_includes_the_fragment_item() -> void:
	# goal_count_errors(goals, board, spawn): `spawn` is the level file's "spawn" object.
	var board: BoardModel = BB.blank()
	var spawn: Dictionary = {"drop_items": {"type": "OB11", "total": 2, "max_on_board": 1, "fragment_item": 1}}
	var ok: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 2)], board, spawn])
	var low: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 1)], board, spawn])
	if ok == null or low == null:
		return
	assert_true(ok.is_empty(), "plain count 2 = total 2 (the fragment item included): valid")
	assert_false(low.is_empty(), "plain count 1 rejected")


# ---------------------------------------------------------------- IR-59

func test_ir59_intro_has_exactly_one_goal() -> void:
	assert_true(_valid(12, "intro", _goals_of(1)), "1 goal is valid")
	assert_false(_valid(12, "intro", _goals_of(2)), "2 goals are rejected")


func test_ir59_easy_has_one_or_two_goals() -> void:
	assert_true(_valid(12, "easy", _goals_of(1)), "1")
	assert_true(_valid(12, "easy", _goals_of(2)), "2")
	assert_false(_valid(12, "easy", _goals_of(3)), "3 rejected")


func test_ir59_medium_has_two_or_three_goals() -> void:
	assert_false(_valid(12, "medium", _goals_of(1)), "1 rejected")
	assert_true(_valid(12, "medium", _goals_of(2)), "2")
	assert_true(_valid(12, "medium", _goals_of(3)), "3")
	assert_false(_valid(12, "medium", _goals_of(4)), "4 rejected")


func test_ir59_hard_has_three_or_four_goals() -> void:
	assert_false(_valid(12, "hard", _goals_of(2)), "2 rejected")
	assert_true(_valid(12, "hard", _goals_of(3)), "3")
	assert_true(_valid(12, "hard", _goals_of(4)), "4")
	assert_false(_valid(12, "hard", _goals_of(5)), "5 rejected")


func test_ir59_finale_has_exactly_four_goals() -> void:
	assert_false(_valid(25, "finale", _goals_of(3)), "3 rejected")
	assert_true(_valid(25, "finale", _goals_of(4)), "4")


func test_ir59_fragment_goal_counts_inside_the_tier_numbers() -> void:
	assert_true(_valid(35, "hard", _goals_of(2, true)), "2 goals plus the fragment entry = 3 in total: valid")
	assert_true(_valid(35, "hard", _goals_of(3, true)), "3 plus the fragment entry = 4: valid")
	assert_false(_valid(35, "hard", _goals_of(1, true)), "1 plus the fragment entry = 2: rejected")


# ---------------------------------------------------------------- IR-31

func test_ir31_validator_fragment_entry_uses_one_of_the_tier_slots() -> void:
	assert_true(_valid(35, "hard", _goals_of(3, true)), "4 goals, one of them the fragment entry: valid")
	assert_false(_valid(35, "hard", _goals_of(4, true)), "4 other goals plus the fragment entry as a 5th: rejected")


func test_ir31_validator_fragment_level_without_a_fragment_entry_is_rejected() -> void:
	for level in FRAGMENT_LEVELS:
		assert_false(_valid(int(level), "hard", _goals_of(3)), "level %d has no fragment entry" % level)


func test_ir31_fragment_cocoon_counts_for_the_fragment_goal_and_a_plain_ob07_goal() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	board.add_content("OB07", 1, 2, 1)
	board.add_content("OB07", 7, 2, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 3)], 26)
	if t == null:
		return
	var e1: Array[BoardEvent] = swap_row_match(board, 4, 5)
	assert_eq(units(t, 0), 1, "fragment goal 1/1")
	assert_eq(units(t, 1), 1, "plain OB07 goal 1/3")
	assert_true(t.is_goal_done(0))
	assert_false(t.is_goal_done(1))
	var e2: Array[BoardEvent] = swap_row_match(board, 1, 3)
	assert_eq(units(t, 0), 1, "fragment goal still 1/1")
	assert_eq(units(t, 1), 2, "plain OB07 goal 2/3")
	assert_eq(EV.count(e1, "win") + EV.count(e2, "win"), 0, "not won yet")


func test_ir31_fragment_drop_item_counts_for_the_fragment_goal_and_a_plain_ob11_goal() -> void:
	var board: BoardModel = BB.blank()
	var t: Variant = track(board, [obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 2)], 38)
	if t == null:
		return
	board.set_drop_item(4, 7, "fragment")
	board.set_piece(4, 8, "", "")
	MatchResolver.settle(board)
	assert_eq(units(t, 0), 1, "fragment goal 1/1")
	assert_eq(units(t, 1), 1, "plain OB11 goal 1/2")
	board.set_drop_item(6, 7, "OB11")
	board.set_piece(6, 8, "", "")
	MatchResolver.settle(board)
	assert_eq(units(t, 1), 2, "plain OB11 goal 2/2")
	assert_eq(units(t, 0), 1, "fragment goal unchanged")


func test_ir31_two_plain_cocoons_freed_do_not_finish_the_fragment_goal() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	board.add_content("OB07", 1, 2, 1)
	board.add_content("OB07", 7, 2, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 3)], 26)
	if t == null:
		return
	swap_row_match(board, 1, 3)
	var events: Array[BoardEvent] = swap_row_match(board, 7, 3)
	assert_eq(units(t, 1), 2, "plain OB07 goal 2/3")
	assert_eq(units(t, 0), 0, "fragment goal 0/1")
	assert_eq(EV.count(events, "win"), 0, "not won")
	assert_false(t.is_won())


func _ob07_board(marked: int) -> BoardModel:
	# Three OB07 entries; `marked` of them carry "fragment": true (the first ones).
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, marked >= 1)
	board.add_content("OB07", 1, 2, 1, 1, 1, marked >= 2)
	board.add_content("OB07", 7, 2, 1)
	return board


func test_ir31_validator_one_marked_cocoon_and_the_plain_count_includes_it() -> void:
	var goals: Array = [obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 3)]
	var ok: Variant = tracker_static("goal_count_errors", [goals, _ob07_board(1)])
	var low: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 2)], _ob07_board(1)])
	if ok == null or low == null:
		return
	assert_true(ok.is_empty(), "3 OB07 entries, one marked, plain count 3: valid")
	assert_false(low.is_empty(), "plain count 2 leaves out the fragment's cocoon: rejected")


func test_ir31_validator_fragment_goal_without_a_marked_cocoon_is_rejected() -> void:
	var goals: Array = [obstacle_goal("OB07", 1, true), obstacle_goal("OB07", 3)]
	var none: Variant = tracker_static("goal_count_errors", [goals, _ob07_board(0)])
	var two: Variant = tracker_static("goal_count_errors", [goals, _ob07_board(2)])
	if none == null or two == null:
		return
	assert_false(none.is_empty(), "no OB07 entry with fragment true: rejected")
	assert_false(two.is_empty(), "two OB07 entries with fragment true: rejected")


func _drop_spawn(total: int, fragment_item: int) -> Dictionary:
	var items: Dictionary = {"type": "OB11", "total": total, "max_on_board": 1}
	if fragment_item > 0:
		items["fragment_item"] = fragment_item
	return {"drop_items": items}


func test_ir31_validator_fragment_drop_item_goal_needs_a_fragment_item_inside_the_total() -> void:
	var board: BoardModel = BB.blank()
	var goals: Array = [obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 3)]
	var ok: Variant = tracker_static("goal_count_errors", [goals, board, _drop_spawn(3, 2)])
	var low: Variant = tracker_static("goal_count_errors", [[obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 2)], board, _drop_spawn(3, 2)])
	var no_item: Variant = tracker_static("goal_count_errors", [goals, board, _drop_spawn(3, 0)])
	var too_far: Variant = tracker_static("goal_count_errors", [goals, board, _drop_spawn(3, 4)])
	if ok == null or low == null or no_item == null or too_far == null:
		return
	assert_true(ok.is_empty(), "total 3, fragment_item 2, plain count 3: valid")
	assert_false(low.is_empty(), "plain count 2: rejected")
	assert_false(no_item.is_empty(), "no fragment_item: rejected")
	assert_false(too_far.is_empty(), "fragment_item 4 of 3 never spawns: rejected")


# ---------------------------------------------------------------- IR-14

func test_ir14_freed_creature_adds_one_to_the_goal() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 2, 3, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 2)])
	if t == null:
		return
	swap_row_match(board, 3, 4)
	assert_eq(units(t, 0), 1, "creature freed: goal +1")


func test_ir14_a_hit_that_leaves_the_obstacle_standing_adds_nothing() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 4, 3, 3)
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	swap_row_match(board, 4, 4)
	assert_eq(board.content_hp(4, 3), 2)
	assert_eq(units(t, 0), 0)


func test_ir14_a_match_next_to_a_shrine_that_is_not_lit_adds_nothing() -> void:
	var board: BoardModel = BB.blank()
	BB.add_shrine(board, 3, 3, {"B": 1}, 3, 1, 1)
	var t: Variant = track(board, [obstacle_goal("OB05", 1)])
	if t == null:
		return
	swap_row_match(board, 4, 4)   # R match under the shrine: it needs B, so nothing is filled
	assert_eq(board.content_hp(3, 3), 1, "a match never lowers a shrine's hp")
	assert_eq(units(t, 0), 0)


# ---------------------------------------------------------------- IR-29

func test_ir29_freed_cocoon_adds_the_fragment_in_the_same_resolve() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	var t: Variant = track(board, [obstacle_goal("OB07", 1, true)], 26)
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 4, 5)
	assert_eq(units(t, 0), 1, "fragment goal +1")
	assert_true(BB.find_drop(board, "fragment").is_empty(), "no fragment piece on the board")
	assert_eq(EV.count(events, "win"), 1)


func test_ir29_row_rocket_frees_the_cocoon_and_collects_the_fragment() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	BB.put(board, "R-", [[0, 4]])
	var t: Variant = track(board, [obstacle_goal("OB07", 1, true), obstacle_goal("OB02", 1)], 26)
	if t == null:
		return
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(units(t, 0), 1, "fragment goal done")
	assert_eq(units(t, 1), 0)


# ---------------------------------------------------------------- IR-30

func test_ir30_hatchling_reaching_the_bottom_counts() -> void:
	var board: BoardModel = BB.blank()
	var t: Variant = track(board, [obstacle_goal("OB11", 2)])
	if t == null:
		return
	board.set_drop_item(4, 7, "OB11")
	board.set_piece(4, 8, "", "")
	MatchResolver.settle(board)
	assert_eq(units(t, 0), 1, "goal +1")


func test_ir30_bottom_playable_cell_counts_when_the_cell_below_is_not_playable() -> void:
	var board: BoardModel = BB.blank()
	board.set_playable(3, 8, false)
	var t: Variant = track(board, [obstacle_goal("OB11", 2)])
	if t == null:
		return
	board.set_drop_item(3, 6, "OB11")
	board.set_piece(3, 7, "", "")
	MatchResolver.settle(board)
	assert_eq(units(t, 0), 1, "collected at (3,7)")


func test_ir30_only_exit_columns_collect() -> void:
	var board: BoardModel = BB.blank()
	board.exit_columns = [2, 6]
	var t: Variant = track(board, [obstacle_goal("OB11", 2)])
	if t == null:
		return
	board.set_drop_item(4, 7, "OB11")
	board.set_piece(4, 8, "", "")
	MatchResolver.settle(board)
	assert_eq(units(t, 0), 0, "column 4 is not an exit column")
	assert_eq(BB.find_drop(board, "OB11"), [Vector2i(4, 8)] as Array[Vector2i], "it stays at (4,8)")
	board.set_drop_item(2, 7, "OB11")
	board.set_piece(2, 8, "", "")
	MatchResolver.settle(board)
	assert_eq(units(t, 0), 1, "column 2 collects")


func test_ir30_a_firecracker_covering_a_hatchling_does_not_collect_it() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(4, 2, "OB11")
	BB.put(board, "RF", [[4, 3]])
	var t: Variant = track(board, [obstacle_goal("OB11", 1)])
	if t == null:
		return
	MatchResolver.tap(board, Vector2i(4, 3))
	assert_eq(units(t, 0), 0, "not collected")
	assert_eq(BB.find_drop(board, "OB11").size(), 1, "still on the board")


func test_ir30_a_crane_landing_collects_the_hatchling() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(4, 2, "OB11")
	BB.put(board, "GC", [[4, 4]])
	board.goals = ["OB11"]
	var t: Variant = track(board, [obstacle_goal("OB11", 1)])
	if t == null:
		return
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(units(t, 0), 1, "collected by the Crane")


# ---------------------------------------------------------------- IR-26

func test_ir26_orb_plus_orb_collects_the_hatchling_and_the_fragment_item() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(3, 2, "OB11")
	board.set_drop_item(6, 1, "fragment")
	BB.put(board, "O", [[4, 4], [4, 5]])
	var t: Variant = track(board, [obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 2)], 38)
	if t == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(units(t, 0), 1, "fragment goal 1/1")
	assert_eq(units(t, 1), 2, "plain OB11 goal 2/2: the hatchling and the fragment item")


# ---------------------------------------------------------------- IR-48

func test_ir48_crane_landing_on_a_cocoon_with_the_fragment_counts() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 1, 1, 1, 1, true)
	BB.put(board, "GC", [[4, 6]])
	board.goals = ["fragment"]
	var t: Variant = track(board, [obstacle_goal("OB07", 1, true)], 26)
	if t == null:
		return
	MatchResolver.tap(board, Vector2i(4, 6))
	assert_eq(units(t, 0), 1, "cocoon freed and fragment collected")


func test_ir48_crane_hit_on_a_bramble_that_survives_adds_nothing() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 6, 2, 2)
	BB.put(board, "GC", [[1, 7]])
	board.goals = ["OB02"]
	var t: Variant = track(board, [obstacle_goal("OB02", 1)])
	if t == null:
		return
	MatchResolver.tap(board, Vector2i(1, 7))
	assert_eq(board.content_hp(6, 2), 1, "bramble hp 1")
	assert_eq(units(t, 0), 0)


func test_ir48_crane_landing_that_lights_a_shrine_counts() -> void:
	var board: BoardModel = BB.blank()
	BB.add_shrine(board, 3, 2, {"B": 1}, 2, 2, 3)
	BB.put(board, "GC", [[4, 6]])
	board.goals = ["OB05"]
	var t: Variant = track(board, [obstacle_goal("OB05", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 6))
	assert_eq(EV.count(events, "shrine_lit"), 1)
	assert_eq(units(t, 0), 1, "goal 1/1")


# ---------------------------------------------------------------- IR-49 (hits left vs units)

func test_ir49_crane_aims_by_hits_left_but_the_goal_counts_units() -> void:
	# OB06: 1 unit left, 3 hits left. OB02: 2 units left, 2 hits left -> the Crane picks the bramble goal.
	var board: BoardModel = BB.blank()
	board.add_content("OB06", 0, 0, 3, 2, 2)
	board.add_content("OB02", 8, 7, 1)
	board.add_content("OB02", 8, 8, 1)
	BB.put(board, "GC", [[4, 4]])
	board.goals = ["OB06", "OB02"]
	var t: Variant = track(board, [obstacle_goal("OB06", 1), obstacle_goal("OB02", 2)])
	if t == null:
		return
	assert_eq(int(t.goal_units_total(1)), 2, "OB02 goal needs 2 units")
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.content_hp(8, 7), 0, "the closer bramble is removed")
	assert_eq(board.content_hp(8, 8), 1, "the other stays")
	assert_eq(board.content_hp(0, 0), 3, "pillar untouched")
	assert_eq(units(t, 1), 1, "OB02 goal 1/2")
	assert_eq(units(t, 0), 0, "OB06 goal 0/1")


func test_ir49_crane_after_the_goals_flies_by_the_no_goal_case_and_the_win_waits_for_its_landing() -> void:
	# IR-49 last case: the row Rocket frees the creature (goal done) and sets off the Crane, which still flies.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 5
	board.add_content("OB07", 2, 2, 1)
	board.add_content("OB02", 6, 6, 2)   # not a goal
	BB.put(board, "GC", [[6, 2]])
	BB.put(board, "R-", [[0, 2]])
	board.goals = ["OB07"]
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 2))
	assert_eq(units(t, 0), 1, "goal 1/1")
	var targets: Array = EV.of_type(events, "crane_target")
	assert_eq(targets.size(), 1, "the Crane flew")
	if targets.size() == 1:
		assert_eq(targets[0].cell, Vector2i(6, 6), "no goal left: the nearest remaining obstacle")
	assert_eq(board.content_hp(6, 6), 1, "bramble 1 layer")
	assert_eq(EV.count(events, "win"), 1)
	var i_win: int = EV.index_of(events, "win")
	assert_true(i_win > EV.index_of(events, "crane_landing"), "the win comes after the Crane's landing")
	assert_eq(i_win, events.size() - 1, "and after the board settled")
	assert_eq(board.moves, 4)


func test_ir49_dew_hits_left_are_cells_without_dew_not_the_goal_count_minus_progress() -> void:
	# 9x9, dew goal count 72, 70 cells have dew (goal 70/72), 11 cells without. Bramble goal with 12 hits left.
	var board: BoardModel = _crane_dew_board([Vector2i(1, 1), Vector2i(7, 7)], 12)
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 72), obstacle_goal("OB02", 4)])
	if t == null:
		return
	assert_eq(units(t, 0), 70, "dew goal 70/72")
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var targets: Array = EV.of_type(events, "crane_target")
	assert_eq(targets.size(), 1)
	if targets.size() == 1:
		assert_eq(targets[0].cell, Vector2i(1, 1), "11 dew hits left < 12 bramble hits; (1,1) and (7,7) tie: top-most")
	assert_true(BB.has_dew(board, 1, 1), "(1,1) gets dew")
	assert_eq(units(t, 0), 71, "dew goal 71/72")


func _crane_dew_board(far_bare: Array, bramble_hits: int) -> BoardModel:
	# 9x9, all playable. Bare (no dew) cells: far_bare plus 9 cells further than 4.25 from (4,4) = 11 in all.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	var bare: Array = far_bare.duplicate()
	for c in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(8, 0), Vector2i(7, 0), Vector2i(8, 1), Vector2i(0, 8), Vector2i(1, 8), Vector2i(0, 7)]:
		bare.append(c)
	BB.dew_level(board, bare)
	BB.put(board, "GC", [[4, 4]])
	var cells: Array = [Vector2i(4, 0), Vector2i(4, 8), Vector2i(0, 4), Vector2i(8, 4)]
	var hp_left: int = bramble_hits
	for c in cells:
		var hp: int = mini(3, hp_left)
		hp_left -= hp
		board.add_content("OB02", c.x, c.y, hp)
	board.goals = ["OB04", "OB02"]
	return board


func test_ir49_bramble_goal_with_fewer_hits_than_the_dew_cells_left_is_chosen() -> void:
	var board: BoardModel = _crane_dew_board([Vector2i(1, 1), Vector2i(7, 7)], 10)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	var targets: Array = EV.of_type(events, "crane_target")
	assert_eq(targets.size(), 1)
	if targets.size() == 1:
		assert_eq(targets[0].cell, Vector2i(4, 0), "10 bramble hits < 11 dew cells: a bramble cell (all at distance 4, top-most)")
	assert_false(BB.has_dew(board, 1, 1), "no dew landing")


# ---------------------------------------------------------------- IR-53 / IR-55

func test_ir53_crane_landing_on_the_last_bare_cell_finishes_the_dew_goal() -> void:
	# 9x9, all 81 cells playable, goal OB04 count 72. The 10 cells without dew are (6,2), holding Y,
	# and all of column 0, so the goal starts at 71/72. The Crane at (6,5) is on a dew cell.
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	board.moves = 5
	BB.put(board, "Y", [[6, 2]])
	var bare: Array = [Vector2i(6, 2)]
	for y in range(9):
		bare.append(Vector2i(0, y))
	assert_eq(BB.dew_level(board, bare), 71, "precondition: 71 cells have dew")
	BB.put(board, "GC", [[6, 5]])
	board.goals = ["OB04"]
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 72)])
	if t == null:
		return
	assert_eq(units(t, 0), 71)
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(6, 5))
	assert_true(BB.has_dew(board, 6, 2), "(6,2) has dew")
	assert_true(t.is_goal_done(0), "dew goal 72/72")
	assert_eq(EV.count(events, "win"), 1)


func _seed_board() -> BoardModel:
	var board: BoardModel = BB.blank()
	board.palette = BB.spread_palette()
	for x in [1, 2, 3]:
		BB.set_dew(board, x, 1)
	return board


func test_ir53_dew_match_on_a_seed_cell_counts_each_cell_once() -> void:
	var board: BoardModel = _seed_board()
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 10)])
	if t == null:
		return
	assert_eq(units(t, 0), 3, "3/10 at the start (seed cells count, OQ-66)")
	swap_row_match(board, 4, 1)   # 3-match (3,1),(4,1),(5,1) on the seed at (3,1)
	assert_true(BB.has_dew(board, 4, 1) and BB.has_dew(board, 5, 1), "(4,1) and (5,1) get dew")
	assert_eq(units(t, 0), 5, "5/10: (3,1) already had dew and is not counted twice")


func test_ir53_dew_match_not_on_dew_adds_nothing_to_the_goal() -> void:
	var board: BoardModel = _seed_board()
	var t: Variant = track_dew(board, [obstacle_goal("OB04", 10)])
	if t == null:
		return
	swap_row_match(board, 6, 4)   # 3-match (5,4),(6,4),(7,4): none on dew
	assert_eq(BB.dew_cells(board).size(), 3, "no new dew")
	assert_eq(units(t, 0), 3, "goal still 3/10")


func test_ir55_special_that_takes_the_last_hp_lights_the_shrine_and_counts() -> void:
	var board: BoardModel = BB.blank()
	BB.add_shrine(board, 3, 3, {"R": 2, "B": 1}, 2, 2, 1)
	BB.put(board, "R-", [[0, 3]])
	var t: Variant = track(board, [obstacle_goal("OB05", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 3))
	assert_eq(EV.count(events, "shrine_lit"), 1, "lit although colours were still needed")
	assert_eq(units(t, 0), 1, "goal 1/1")


func test_ir55_shrine_still_needing_colours_does_not_count() -> void:
	var board: BoardModel = BB.blank()
	BB.add_shrine(board, 3, 3, {"R": 2, "B": 1}, 3, 1, 3)
	var t: Variant = track(board, [obstacle_goal("OB05", 1)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_row_match(board, 4, 4)   # R match under the shrine fills 2 R, B still needed
	assert_eq(EV.count(events, "shrine_lit"), 0)
	assert_eq(BB.shrine_need(board, 3, 3, "B"), 1)
	assert_eq(units(t, 0), 0, "not lit: goal 0/1")
