# GUT tests for BoardSnapshot (copies of pieces and obstacle layers for the screen).
# API: tests/API_CONTRACT.md section 13. Check: run the GUT suite.
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")


func test_piece_grid_lists_only_cells_with_pieces() -> void:
	var b: BoardModel = BB.from_rows(["R Y", "X B"])
	var g: Dictionary = BoardSnapshot.piece_grid(b)
	assert_eq(g.size(), 3)
	assert_false(g.has(Vector2i(0, 1)))
	assert_eq(g[Vector2i(1, 0)].color, "Y")
	assert_eq(g[Vector2i(1, 0)].kind, "plain")


func test_look_at_special_and_drop_item() -> void:
	var b: BoardModel = BB.from_rows(["R- H", "Q RF"])
	assert_eq(BoardSnapshot.look_at(b, Vector2i(0, 0)).kind, "rocket_row")
	assert_eq(BoardSnapshot.look_at(b, Vector2i(0, 0)).color, "R")
	assert_eq(BoardSnapshot.look_at(b, Vector2i(1, 0)).item, "OB11")
	assert_eq(BoardSnapshot.look_at(b, Vector2i(0, 1)).item, "fragment")
	assert_eq(BoardSnapshot.look_at(b, Vector2i(1, 1)).kind, "firecracker")


func _obstacle_board() -> BoardModel:
	var b: BoardModel = BB.blank(5, 5)
	b.set_overlay(1, 1, "OB03", 1)
	b.set_underlay(2, 2, "OB10", 2)
	b.add_content("OB06", 3, 0, 3, 1, 3)
	return b


func test_obstacle_grid_layers() -> void:
	var o: Dictionary = BoardSnapshot.obstacle_grid(_obstacle_board())
	assert_eq(o.overlay[Vector2i(1, 1)].id, "OB03")
	assert_eq(o.underlay[Vector2i(2, 2)].hp, 2)
	assert_eq(o.content.size(), 1, "a pillar is one entry")
	assert_true(o.content.has(Vector2i(3, 0)), "keyed by its top-left cell")
	assert_eq(o.content[Vector2i(3, 0)].hp, 3)


func test_apply_hit_lowers_hp_then_zero_removes_layer() -> void:
	var o: Dictionary = BoardSnapshot.obstacle_grid(_obstacle_board())
	BoardSnapshot.apply_hit(o, "underlay", Vector2i(2, 2), "OB10", 1)
	assert_eq(o.underlay[Vector2i(2, 2)].hp, 1)
	BoardSnapshot.apply_hit(o, "underlay", Vector2i(2, 2), "OB10", 0)
	assert_false(o.underlay.has(Vector2i(2, 2)))
	BoardSnapshot.apply_hit(o, "overlay", Vector2i(1, 1), "OB03", 0)
	assert_false(o.overlay.has(Vector2i(1, 1)))


func test_apply_hit_on_any_cell_of_a_pillar() -> void:
	var o: Dictionary = BoardSnapshot.obstacle_grid(_obstacle_board())
	BoardSnapshot.apply_hit(o, "content", Vector2i(3, 2), "OB06", 2)
	assert_eq(o.content[Vector2i(3, 0)].hp, 2)
	BoardSnapshot.apply_hit(o, "content", Vector2i(3, 1), "OB06", 0)
	assert_eq(o.content.size(), 0)


func test_apply_cleared_removes_matching_id_only() -> void:
	var o: Dictionary = BoardSnapshot.obstacle_grid(_obstacle_board())
	BoardSnapshot.apply_cleared(o, Vector2i(1, 1), "OB99")
	assert_true(o.overlay.has(Vector2i(1, 1)), "other id stays")
	BoardSnapshot.apply_cleared(o, Vector2i(1, 1), "OB03")
	assert_false(o.overlay.has(Vector2i(1, 1)))
	BoardSnapshot.apply_cleared(o, Vector2i(3, 1), "OB06")
	assert_eq(o.content.size(), 0)


func test_content_key_at() -> void:
	var o: Dictionary = BoardSnapshot.obstacle_grid(_obstacle_board())
	assert_eq(BoardSnapshot.content_key_at(o, Vector2i(3, 2)), Vector2i(3, 0))
	assert_null(BoardSnapshot.content_key_at(o, Vector2i(0, 0)))


func test_snapshot_is_a_copy() -> void:
	var b: BoardModel = _obstacle_board()
	var o: Dictionary = BoardSnapshot.obstacle_grid(b)
	BoardSnapshot.apply_hit(o, "content", Vector2i(3, 0), "OB06", 1)
	assert_eq(b.content_hp(3, 0), 3, "the real board is untouched")
