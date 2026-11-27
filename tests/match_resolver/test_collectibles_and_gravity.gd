# GUT tests for IR-28, IR-29, IR-30 (fragments, drop items) and IR-32, IR-33, IR-51 (gravity, shuffle).
# API: tests/API_CONTRACT.md. IR-31 belongs to GoalTracker/LevelLoader, not this module.
# Pending placeholders name the open question (OQ) that blocks a case.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")


# ---------------------------------------------------------------- IR-28

func test_ir28_row_rocket_does_not_destroy_a_fragment_drop_item() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[0, 4]])
	BB.put(board, "Q", [[4, 4]])
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(BB.find_drop(board, "fragment").size(), 1, "fragment still on the board")
	assert_eq(board.collected_count("fragment"), 0, "not collected by a Rocket")
	assert_false(EV.cleared(events).has(Vector2i(4, 4)))


func test_ir28_firecracker_does_not_destroy_a_hatchling() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 5]])
	BB.put(board, "H", [[4, 4]])
	MatchResolver.tap(board, Vector2i(4, 5))
	assert_eq(BB.find_drop(board, "OB11").size(), 1)
	assert_eq(board.collected_count("OB11"), 0)


# ---------------------------------------------------------------- IR-29

func test_ir29_freed_cocoon_collects_its_fragment_at_once() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	BB.put(board, "R", [[3, 5], [5, 5], [4, 6]])
	MatchResolver.swap(board, Vector2i(4, 6), Vector2i(4, 5))
	assert_eq(board.collected_count("fragment"), 1)
	assert_eq(board.content_hp(4, 4), 0)
	assert_eq(BB.find_drop(board, "fragment").size(), 0, "no fragment piece remains")


func test_ir29_special_hitting_the_cocoon_frees_it_and_collects() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB07", 4, 4, 1, 1, 1, true)
	BB.put(board, "R-", [[0, 4]])
	MatchResolver.tap(board, Vector2i(0, 4))
	assert_eq(board.collected_count("fragment"), 1)
	assert_eq(board.content_hp(4, 4), 0)


# ---------------------------------------------------------------- IR-30

func test_ir30_hatchling_reaching_the_bottom_is_collected() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "H", [[4, 7]])
	BB.put(board, "X", [[4, 8]])
	MatchResolver.settle(board)
	assert_eq(board.collected_count("OB11"), 1)


func test_ir30_bottom_playable_cell_counts_when_the_last_row_is_a_hole() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "#", [[3, 8]])
	BB.put(board, "H", [[3, 6]])
	BB.put(board, "X", [[3, 7]])
	MatchResolver.settle(board)
	assert_eq(board.collected_count("OB11"), 1)


func test_ir30_only_exit_columns_collect() -> void:
	var board: BoardModel = BB.blank()
	board.exit_columns = [2, 6]
	BB.put(board, "H", [[4, 7], [2, 7]])
	BB.put(board, "X", [[4, 8], [2, 8]])
	MatchResolver.settle(board)
	assert_eq(board.collected_count("OB11"), 1, "only the column-2 hatchling")
	assert_eq(BB.find_drop(board, "OB11"), [Vector2i(4, 8)] as Array[Vector2i], "column 4 hatchling stays at the bottom")


func test_ir30_firecracker_covering_a_hatchling_does_not_collect_it() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "H", [[4, 2]])
	BB.put(board, "RF", [[4, 3]])
	MatchResolver.tap(board, Vector2i(4, 3))
	assert_eq(board.collected_count("OB11"), 0)
	assert_eq(BB.find_drop(board, "OB11").size(), 1)


func test_ir30_crane_landing_collects_a_hatchling() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "H", [[4, 2]])
	BB.put(board, "GC", [[0, 0]])
	board.goals = ["OB11"]
	MatchResolver.tap(board, Vector2i(0, 0))
	assert_eq(board.collected_count("OB11"), 1)


# ---------------------------------------------------------------- IR-32

func test_ir32_pieces_fall_and_new_ones_refill_the_column() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "X", [[4, 6], [4, 7], [4, 8]])
	MatchResolver.settle(board)
	for y in range(6):
		assert_eq(board.get_color(4, y + 3), BB.filler_color(4, y), "piece from (4,%d) now at (4,%d)" % [y, y + 3])
	assert_eq(BB.empty_cells(board).size(), 0, "no empty cells")
	for y in range(3):
		assert_ne(board.get_kind(4, y), "", "new piece at (4,%d)" % y)


func test_ir32_a_fall_that_makes_a_match_cascades_without_a_move() -> void:
	var board: BoardModel = BB.blank()
	board.moves = 10
	BB.put(board, "R", [[0, 6], [1, 6], [2, 5]])
	BB.put(board, "X", [[2, 6]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	var matched: Dictionary = EV.matched(events)
	for c in [Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6)]:
		assert_true(matched.has(c), "cascade match includes %s" % c)
	assert_eq(board.moves, 10)
	assert_false(BB.has_match(board), "board ends stable")
	assert_eq(BB.empty_cells(board).size(), 0)


# ---------------------------------------------------------------- IR-33

# 8x8 dead board found by a seeded search: no match now, no swap makes a match, nothing
# tappable. The hatchling H at (7,1) is boxed in by # cells so no neighbour can swap with it.
# Rows are y = 0..7.
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


func _dead_board() -> BoardModel:
	var board: BoardModel = BB.from_rows(DEAD_ROWS)
	board.auto_shuffle = true
	board.moves = 8
	return board


func test_ir33_dead_board_shuffles_for_free() -> void:
	var board: BoardModel = _dead_board()
	assert_false(MatchResolver.has_possible_move(board), "precondition: no move on this board")
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.count(events, "shuffle"), 1)
	assert_eq(board.moves, 8, "a shuffle costs no move")
	assert_true(MatchResolver.has_possible_move(board), "at least one valid move after the shuffle")
	assert_false(BB.has_match(board), "no ready-made match after the shuffle")


func test_ir33_shuffle_never_moves_obstacles_or_drop_items() -> void:
	var board: BoardModel = _dead_board()
	board.add_content("OB02", 2, 2, 2)
	board.add_content("OB07", 5, 5, 1, 1, 1, true)
	var before_hatchling: Array[Vector2i] = BB.find_drop(board, "OB11")
	MatchResolver.settle(board)
	assert_eq(board.content_id(2, 2), "OB02")
	assert_eq(board.content_id(5, 5), "OB07")
	assert_eq(BB.find_drop(board, "OB11"), before_hatchling)


func test_ir33_no_shuffle_when_a_swap_exists() -> void:
	var board: BoardModel = BB.blank()
	board.auto_shuffle = true
	BB.put(board, "R", [[0, 0], [1, 0], [2, 1]])
	BB.put(board, "Y", [[2, 0]])
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.count(events, "shuffle"), 0)


func test_ir33_no_shuffle_when_a_special_can_be_tapped() -> void:
	var board: BoardModel = BB.blank()
	board.auto_shuffle = true
	BB.put(board, "RF", [[4, 4]])
	assert_true(MatchResolver.has_possible_move(board))
	var events: Array[BoardEvent] = MatchResolver.settle(board)
	assert_eq(EV.count(events, "shuffle"), 0)


func test_ir33_pending_covered_pieces_in_a_shuffle() -> void:
	pending("OQ-41: whether pieces under an overlay are shuffled")


# ---------------------------------------------------------------- IR-51

func test_ir51_blocker_stays_put_and_the_board_refills() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 3, 2, 2)
	BB.put(board, "X", [[3, 3], [3, 4], [3, 5]])
	MatchResolver.settle(board)
	assert_eq(board.content_id(3, 2), "OB02")
	assert_eq(board.content_hp(3, 2), 2, "layers unchanged")
	assert_eq(BB.empty_cells(board).size(), 0, "no playable cell left empty")


func test_ir51_slide_comes_from_the_upper_left_first() -> void:
	var board: BoardModel = BB.blank()
	board.add_content("OB02", 4, 3, 2)
	BB.put(board, "X", [[4, 4]])
	MatchResolver.settle(board)
	assert_eq(board.get_color(4, 4), BB.filler_color(3, 3), "(4,4) is filled by the piece from (3,3), the upper-left")
	assert_eq(board.get_color(5, 3), BB.filler_color(5, 3), "the piece at (5,3) did not move")
	for y in [1, 2, 3]:
		assert_eq(board.get_color(3, y), BB.filler_color(3, y - 1), "column 3 fell by one: (3,%d)" % y)
	assert_ne(board.get_kind(3, 0), "", "a new piece entered at (3,0)")
	assert_eq(board.content_hp(4, 3), 2, "the bramble did not move")
	assert_eq(BB.empty_cells(board).size(), 0)


func test_ir51_spawner_is_an_extra_entry_point_and_columns_still_refill_at_the_top() -> void:
	var board: BoardModel = BB.blank()
	board.spawners = [Vector2i(2, 0)]
	BB.put(board, "X", [[6, 8]])
	MatchResolver.settle(board)
	for y in range(8):
		assert_eq(board.get_color(6, y + 1), BB.filler_color(6, y), "piece from (6,%d) moved to (6,%d)" % [y, y + 1])
	assert_ne(board.get_kind(6, 0), "", "a new piece entered at (6,0)")
	assert_eq(BB.empty_cells(board).size(), 0)


func test_ir51_column_refills_at_its_top_playable_cell() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "#", [[5, 0], [5, 1]])
	BB.put(board, "X", [[5, 8]])
	MatchResolver.settle(board)
	for y in range(2, 8):
		assert_eq(board.get_color(5, y + 1), BB.filler_color(5, y), "piece from (5,%d) moved to (5,%d)" % [y, y + 1])
	assert_ne(board.get_kind(5, 2), "", "a new piece entered at (5,2), the top playable cell")
	assert_eq(BB.empty_cells(board).size(), 0)


func test_ir51_pending_filling_below_a_locked_piece() -> void:
	pending("OQ-41: how the cells below a locked covered piece are filled")


func test_ir51_pending_hole_in_the_middle_of_a_column() -> void:
	pending("OQ-45: columns with a non-playable cell in the middle (refill entry point)")
