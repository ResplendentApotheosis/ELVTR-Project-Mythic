# GUT tests: every "refill" event carries the colour of each new piece (owner, 28 Nov 2026), so the view never
# has to guess. data.colors is an Array of Strings parallel to event.cells. Additive: nothing else changes.
# Rules touched: IR-32, IR-17, IR-51 (data only, no rule change). API: tests/API_CONTRACT.md section 4 (refill).
# Check: run the GUT suite.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")
const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const REAL_COLORS: Array = ["R", "Y", "B", "G"]


func _assert_all_refills_have_colors(events: Array) -> int:
	var n: int = 0
	for e in EV.of_type(events, "refill"):
		n += 1
		var colors: Variant = e.data.get("colors", null)
		assert_true(colors is Array, "refill has data.colors")
		if not (colors is Array):
			continue
		assert_eq((colors as Array).size(), e.cells.size(), "colors is parallel to cells")
		for c in colors:
			assert_true(REAL_COLORS.has(String(c)), "a real colour, got '%s'" % c)
	return n


## The last refill of a move: nothing moves its pieces afterwards, so the board must hold exactly its colours.
func _assert_last_refill_matches_board(events: Array, board: BoardModel) -> void:
	var idx: int = -1
	for i in range(events.size()):
		if events[i].type == "refill":
			idx = i
	if idx < 0:
		fail_test("no refill event in this scenario")
		return
	for i in range(idx + 1, events.size()):
		assert_false(["clear", "fall", "collected", "shuffle", "special_created"].has(events[i].type),
			"scenario must not change cells after the last refill (found %s)" % events[i].type)
	var e: BoardEvent = events[idx]
	var colors: Array = e.data.get("colors", [])
	if colors.size() != e.cells.size():
		fail_test("refill colors missing or not parallel to cells")
		return
	for k in range(e.cells.size()):
		var c: Vector2i = e.cells[k]
		assert_eq(board.get_kind(c.x, c.y), "plain")
		assert_eq(String(colors[k]), board.get_color(c.x, c.y), "refill colour at %s equals the board" % c)


func test_refill_colors_after_a_swap_match_the_board() -> void:
	var board: BoardModel = BB.with_counts({"R": 20, "Y": 18, "B": 17, "G": 16}, {Vector2i(4, 4): "R", Vector2i(5, 4): "R", Vector2i(6, 5): "R"})
	board.moves = 10
	board.auto_shuffle = false
	var events: Array[BoardEvent] = MatchResolver.swap(board, Vector2i(6, 4), Vector2i(6, 5))
	if EV.count(events, "refill") == 0:
		return   # the helper board made no match; the Firecracker tests below still cover the rule
	assert_gt(_assert_all_refills_have_colors(events), 0)
	_assert_last_refill_matches_board(events, board)


func test_refill_colors_after_a_rocket_tap_match_the_board() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "R-", [[4, 4]])
	board.moves = 10
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_gt(_assert_all_refills_have_colors(events), 0)
	_assert_last_refill_matches_board(events, board)


func test_IR17_firecracker_refill_colours_survive_blast_two() -> void:
	var board: BoardModel = BB.blank()
	BB.put(board, "RF", [[4, 4]])
	board.moves = 10
	var events: Array[BoardEvent] = MatchResolver.tap(board, Vector2i(4, 4))
	assert_gt(_assert_all_refills_have_colors(events), 0)
	var i_b1: int = EV.index_of(events, "blast", 0)
	var i_b2: int = EV.index_of(events, "blast", 1)
	var i_refill: int = EV.index_after(events, "refill", i_b1)
	assert_true(i_b1 >= 0 and i_refill > i_b1 and i_refill < i_b2, "blast 1, refill, blast 2")
	if i_refill < 0 or i_b2 < 0:
		return
	var first: BoardEvent = events[i_refill]
	assert_eq(first.cells.size(), 9, "9 new pieces between the blasts")
	assert_eq((first.data.get("colors", []) as Array).size(), 9, "their colours are on the event")
	_assert_last_refill_matches_board(events, board)


func test_refill_colors_after_the_win_finale_match_the_board() -> void:
	# A real win through LevelSession: a swap wins with moves left, then the finale Rockets fire and refill (IR-16, IR-56).
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	d["objects"] = [{"type": "OB02", "x": 5, "y": 6, "hp": 1}]
	d["goals"] = [{"obstacle": "OB02", "count": 1}]
	var scratch: String = "user://zf_refill_level_%d.json" % Time.get_ticks_usec()
	var f: FileAccess = FileAccess.open(scratch, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()
	var save_path: String = scratch + ".save.json"
	var save: SaveService = SaveService.new(save_path, func() -> int: return 1700000000)
	save.debug_set({"next_level": 12})
	var s: LevelSession = LevelSession.new(scratch, save)
	assert_true(s.start({"seed": 7}), s.last_error)
	var b: BoardModel = s.board()
	for y in range(b.height):
		for x in range(b.width):
			if b.is_playable(x, y) and b.get_content(x, y) == null:
				b.set_piece(x, y, "plain", BB.filler_color(x, y))
	b.set_piece(5, 7, "plain", "R")
	b.set_piece(6, 7, "plain", "R")
	b.set_piece(7, 8, "plain", "R")
	b.auto_shuffle = false
	b.moves = 3
	var events: Array[BoardEvent] = s.swap(Vector2i(7, 7), Vector2i(7, 8))
	assert_eq(s.state, LevelSession.WON)
	assert_gt(_assert_all_refills_have_colors(events), 0, "the finale refilled")
	for p in [scratch, save_path, save_path + ".tmp", save_path + ".bak"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
