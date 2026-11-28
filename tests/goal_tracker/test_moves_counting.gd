# GUT tests for the "moves used / not used" cases GoalTracker counts: IR-01, IR-02, IR-18, IR-22..IR-27,
# IR-32, IR-33, IR-34..IR-36, IR-39, IR-52, IR-62. A tracker is attached, so every action also has to
# leave the move count right and raise no win/fail by mistake. API: tests/API_CONTRACT.md section 10.
extends "res://tests/helpers/goal_test_base.gd"

# Same dead board as tests/match_resolver/test_collectibles_and_gravity.gd (no swap makes a match). Rows are y = 0..7.
const DEAD_ROWS: Array = [
	"B B G G R Y G #",
	"R Y R Y R G # H",
	"G G B Y Y B B #",
	"B Y R G G R R B",
	"B B Y R Y B G Y",
	"G R G B R G B R",
	"R R Y G B Y R G",
	"G Y B R Y B G B",
]


## A blank board with `moves` moves and a goal that no test here finishes (5 brambles, none placed).
func _tracked(moves: int, board: BoardModel = null) -> Array:
	var b: BoardModel = board if board != null else BB.blank()
	b.moves = moves
	var t: Variant = track(b, [obstacle_goal("OB02", 5)])
	return [b, t]


# ---------------------------------------------------------------- IR-01

func test_ir01_swap_that_makes_a_match_uses_one_move() -> void:
	var pair: Array = _tracked(20)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "Y", [[4, 4]])
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 19)


func test_ir01_swap_with_no_match_snaps_back_and_uses_no_move() -> void:
	var pair: Array = _tracked(20)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	var before: String = BB.snapshot(board)
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(0, 0), Vector2i(1, 0))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 20)
	assert_eq(BB.snapshot(board), before)


func test_ir01_hatchling_swap_with_no_match_snaps_back_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(4, 4, "OB11")
	var pair: Array = _tracked(20, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 20)
	assert_eq(board.get_drop_item(4, 4), "OB11", "hatchling still at (4,4)")


func test_ir01_hatchling_swap_that_makes_a_match_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(4, 4, "OB11")
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	var pair: Array = _tracked(20, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 19)


# ---------------------------------------------------------------- IR-02

func test_ir02_tapping_a_firecracker_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(board.moves, 9)


func test_ir02_tapping_a_plain_piece_uses_no_move() -> void:
	var pair: Array = _tracked(10)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_eq(events.size(), 0)
	assert_eq(board.moves, 10)


func test_ir02_tapping_a_special_under_moss_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[2, 6]])
	board.set_overlay(2, 6, "OB03", 1)
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(2, 6))
	assert_eq(EV.count(events, "rocket_fire"), 0, "no fire event")
	assert_eq(board.moves, 10)


# ---------------------------------------------------------------- IR-18

func test_ir18_orb_swapped_with_a_plain_piece_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "O", [[4, 4]])
	BB.put(board, "B", [[5, 4], [1, 1]])
	var pair: Array = _tracked(15, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(5, 4), Vector2i(4, 4))
	assert_eq(board.moves, 14)


# ---------------------------------------------------------------- IR-22 .. IR-27

func test_ir22_rocket_plus_rocket_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4], [4, 5]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)


func test_ir23_rocket_plus_firecracker_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[3, 4]])
	BB.put(board, "R-", [[4, 4]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(3, 4), Vector2i(4, 4))
	assert_eq(board.moves, 9)


func test_ir24_firecracker_plus_firecracker_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4], [4, 5]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9, "one move for the whole combo, whatever cascades follow")


func test_ir25_orb_plus_firecracker_uses_one_move() -> void:
	var board: BoardModel = BB.with_counts({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(4, 4): "O", Vector2i(4, 5): "zF"})
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)


func test_ir26_orb_plus_orb_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "O", [[4, 4], [4, 5]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)


func test_ir27_crane_plus_special_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "GC", [[4, 4]])
	BB.put(board, "RF", [[4, 5]])
	var pair: Array = _tracked(12, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "never refused")
	assert_eq(board.moves, 11, "one move, although the Firecracker and the Crane both fire")


# ---------------------------------------------------------------- IR-32 / IR-33

func test_ir32_cascades_use_no_move() -> void:
	var board: BoardModel = cascade_board(5)
	var t: Variant = track(board, [obstacle_goal("OB02", 5)])
	if t == null:
		return
	var events: Array[BoardEvent] = swap_cascade(board)
	assert_eq(EV.count(events, "match"), 2, "the swap's match and one cascade match")
	assert_eq(board.moves, 4, "only the swap used a move")
	assert_false(BB.has_match(board), "the board ends with no match")


func test_ir33_free_shuffle_uses_no_move() -> void:
	var board: BoardModel = BB.from_rows(DEAD_ROWS)
	board.auto_shuffle = true
	var pair: Array = _tracked(8, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.count(events, "shuffle"), 1)
	assert_eq(board.moves, 8)
	assert_eq(EV.count(events, "fail"), 0)


# ---------------------------------------------------------------- IR-34 .. IR-36 (boosters use no move)

func test_ir34_hoof_tap_on_a_hatchling_collects_it_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(4, 2, "OB11")
	board.moves = 6
	var t: Variant = track(board, [obstacle_goal("OB11", 2)])
	if t == null:
		return
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 2)])
	if events == null:
		return
	assert_eq(units(t, 0), 1, "collected: goal +1")
	assert_eq(board.moves, 6)


func test_ir34_bamboo_dash_over_a_fragment_item_collects_it_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(6, 3, "fragment")
	board.moves = 6
	var t: Variant = track(board, [obstacle_goal("OB11", 1, true), obstacle_goal("OB11", 2)], 38)
	if t == null:
		return
	var events: Variant = booster("bamboo_dash", [board, "row", 3])
	if events == null:
		return
	assert_eq(units(t, 0), 1, "the fragment is collected")
	assert_eq(units(t, 1), 1, "and counts toward the plain OB11 goal too (IR-31)")
	assert_eq(board.moves, 6)


func test_ir35_feather_fan_uses_no_move_and_leaves_drop_items_where_they_are() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(2, 3, "fragment")
	board.set_drop_item(6, 1, "OB11")
	var pair: Array = _tracked(4, board)
	if pair[1] == null:
		return
	var events: Variant = booster("feather_fan", [board])
	if events == null:
		return
	assert_eq(board.moves, 4)
	assert_eq(board.get_drop_item(2, 3), "fragment")
	assert_eq(board.get_drop_item(6, 1), "OB11")


func test_ir36_bamboo_dash_uses_no_move() -> void:
	var pair: Array = _tracked(9)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	var events: Variant = booster("bamboo_dash", [board, "row", 4])
	if events == null:
		return
	assert_eq(board.moves, 9)


# ---------------------------------------------------------------- IR-39

func test_ir39_special_swapped_with_a_plain_piece_with_no_match_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0, "never snapped back")
	assert_eq(board.moves, 9)


func test_ir39_firecracker_swapped_with_a_hatchling_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	board.set_drop_item(4, 5, "OB11")
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)


func test_ir39_the_same_swap_with_two_plain_pieces_uses_no_move() -> void:
	var pair: Array = _tracked(10)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir39_special_that_fires_after_a_match_uses_one_move_in_total() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	BB.put(board, "YF", [[4, 4]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(board.moves, 9)


# ---------------------------------------------------------------- IR-52

func test_ir52_swap_with_a_bramble_is_refused_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 4, 4, 2)
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir52_diagonal_swap_is_refused_and_uses_no_move() -> void:
	var pair: Array = _tracked(10)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 3), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir52_swap_with_a_cocoon_is_refused_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 2, 2, 1, 1, 1, true)
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(3, 2), Vector2i(2, 2))
	assert_eq(EV.count(events, "invalid_swap"), 1)
	assert_eq(board.moves, 10)


func test_ir52_swap_with_a_covered_piece_is_refused_both_ways_and_uses_no_move() -> void:
	var board: BoardModel = BB.blank()
	board.set_overlay(4, 4, "OB03", 1)
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	MatchResolver.swap(board, Vector2i(4, 4), Vector2i(4, 5))
	assert_eq(board.moves, 10)


func test_ir52_hatchling_swap_that_makes_a_match_uses_one_move() -> void:
	var board: BoardModel = BB.blank()
	board.set_drop_item(4, 4, "OB11")
	BB.put(board, "R", [[2, 4], [3, 4], [4, 5]])
	var pair: Array = _tracked(10, board)
	if pair[1] == null:
		return
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(4, 5), Vector2i(4, 4))
	assert_eq(EV.count(events, "invalid_swap"), 0)
	assert_eq(board.moves, 9)


# ---------------------------------------------------------------- IR-62

func test_ir62_hoof_tap_on_a_plain_piece_uses_no_move() -> void:
	var pair: Array = _tracked(5)
	var board: BoardModel = pair[0]
	if pair[1] == null:
		return
	var events: Variant = booster("hoof_tap", [board, Vector2i(3, 3)])
	if events == null:
		return
	assert_eq(board.moves, 5)


func test_ir62_tail_slam_that_clears_no_bramble_uses_no_move_and_causes_no_fail() -> void:
	var pair: Array = _tracked(1)
	var board: BoardModel = pair[0]
	var t: Variant = pair[1]
	if t == null:
		return
	var events: Variant = booster("tail_slam", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(board.moves, 1)
	assert_eq(EV.count(events, "fail"), 0, "no fail event")
	assert_eq(int(t.offer_price()), 0, "no continue offer")


func test_ir62_booster_that_finishes_the_goal_wins_with_all_moves_left() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	board.add_content("OB07", 4, 4, 1)
	var t: Variant = track(board, [obstacle_goal("OB07", 1)])
	if t == null:
		return
	var events: Variant = booster("hoof_tap", [board, Vector2i(4, 4)])
	if events == null:
		return
	assert_eq(EV.count(events, "win"), 1, "a win event")
	assert_eq(board.moves, 10)
	assert_eq(int(events.back().data.get("moves_left", -1)), 10, "10 finale Rockets")
	assert_eq(tracker_static("win_coins", [10]), 70, "20 + 5 x 10")
