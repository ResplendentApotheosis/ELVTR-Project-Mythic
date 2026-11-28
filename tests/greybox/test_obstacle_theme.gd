# Tests the placeholder art skin (ObstacleTheme, PieceArt, ObstacleArt): colour-blind-safe pieces, colour lookup,
# background colour, and a draw smoke test over every piece kind and obstacle. No rule is tested here.
# Check: run the GUT suite; this file is tests/greybox/test_obstacle_theme.gd.
extends GutTest

const PLAIN: Array[String] = ["R", "Y", "B", "G"]

var _draw_calls: int = 0
var _draw_done: int = 0


func _node_with_draw(body: Callable) -> Node2D:
	var node: Node2D = Node2D.new()
	add_child_autofree(node)
	_draw_calls = 0
	_draw_done = 0
	node.draw.connect(func() -> void:
		_draw_calls += 1
		body.call(node)
		_draw_done += 1)
	node.queue_redraw()
	return node


func _run_draw(body: Callable) -> void:
	_node_with_draw(body)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gt(_draw_calls, 0, "the draw callback ran")
	assert_eq(_draw_done, _draw_calls, "every draw callback finished without stopping early")


# ---------------------------------------------------------------- (1) colour-blind distinctness

func test_four_plain_colours_have_distinct_colours() -> void:
	var seen: Array[Color] = []
	for c in PLAIN:
		var col: Color = ObstacleTheme.piece_color(c)
		assert_false(seen.has(col), "colour of %s is unique" % c)
		seen.append(col)
	assert_eq(seen.size(), 4)


func test_four_plain_colours_have_distinct_shapes() -> void:
	var outlines: Array[PackedVector2Array] = []
	var counts: Array[int] = []
	for c in PLAIN:
		var pts: PackedVector2Array = PieceArt.shape_points(c, 40.0)
		assert_gte(pts.size(), 3, "%s has a real outline" % c)
		for other in outlines:
			assert_ne(pts, other, "%s outline differs from the others" % c)
		outlines.append(pts)
		counts.append(pts.size())
	var unique_counts: Dictionary = {}
	for n in counts:
		unique_counts[n] = true
	assert_eq(unique_counts.size(), 4, "four different vertex counts (circle/diamond/rounded square/triangle): %s" % str(counts))


# ---------------------------------------------------------------- (2) piece_color

func test_piece_color_returns_art_colours_and_grey_for_unknown() -> void:
	for c in PLAIN:
		assert_eq(ObstacleTheme.piece_color(c), PieceArt.COLORS[c], "piece_color(%s)" % c)
	assert_eq(ObstacleTheme.piece_color("?"), PieceArt.UNKNOWN)
	assert_eq(ObstacleTheme.piece_color("zzz"), PieceArt.UNKNOWN)
	assert_eq(ObstacleTheme.piece_color(""), PieceArt.UNKNOWN)
	var u: Color = PieceArt.UNKNOWN
	assert_almost_eq(u.r, u.g, 0.01, "unknown is grey")
	assert_almost_eq(u.g, u.b, 0.01, "unknown is grey")


# ---------------------------------------------------------------- (3) background

func test_background_is_green_dominant() -> void:
	var bg: Color = ObstacleTheme.BACKGROUND
	assert_gt(bg.g, bg.r)
	assert_gt(bg.g, bg.b)


# ---------------------------------------------------------------- (4) draw smoke tests

func test_draw_piece_every_kind() -> void:
	var looks: Array[Dictionary] = []
	for c in PLAIN:
		looks.append({"kind": "plain", "color": c})
	for k in ["rocket_row", "rocket_col", "firecracker", "crane"]:
		looks.append({"kind": k, "color": "R"})
	looks.append({"kind": "orb", "color": ""})
	looks.append({"kind": "drop", "color": "", "item": "fragment"})
	looks.append({"kind": "drop", "color": "", "item": "OB11"})
	looks.append({"kind": "plain", "color": "?"})
	await _run_draw(func(node: Node2D) -> void:
		for look in looks:
			ObstacleTheme.draw_piece(node, look, 64.0))


func test_draw_underlays() -> void:
	await _run_draw(func(node: Node2D) -> void:
		var rect: Rect2 = Rect2(0, 0, 64, 64)
		for id in ["OB04", "OB10", "OB99"]:
			for hp in [1, 2, 3]:
				ObstacleTheme.draw_underlay(node, rect, id, hp)
		ObstacleTheme.draw_floor(node, rect, 0, 0)
		ObstacleTheme.draw_floor(node, rect, 1, 0))


func test_draw_overlays() -> void:
	await _run_draw(func(node: Node2D) -> void:
		var rect: Rect2 = Rect2(0, 0, 64, 64)
		var font: Font = ThemeDB.fallback_font
		for hp in [1, 2, 3]:
			ObstacleTheme.draw_overlay(node, rect, "OB03", hp, font)
		ObstacleTheme.draw_overlay(node, rect, "OB99", 1, font))


func test_draw_contents() -> void:
	await _run_draw(func(node: Node2D) -> void:
		var rect: Rect2 = Rect2(0, 0, 64, 64)
		var font: Font = ThemeDB.fallback_font
		for hp in [1, 2, 3]:
			ObstacleTheme.draw_content(node, rect, {"id": "OB02", "hp": hp}, font)
			ObstacleTheme.draw_content(node, rect, {"id": "OB03", "hp": hp}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB04", "hp": 1}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB10", "hp": 1}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB05", "hp": 2, "needs": {"R": 2, "Y": 1}}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB05", "hp": 2, "needs": {}}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB05", "hp": 1}, font)
		var tall: Rect2 = Rect2(0, 0, 64, 128)
		for hp in [1, 2, 3, 4]:
			ObstacleTheme.draw_content(node, tall, {"id": "OB06", "hp": hp}, font)
			ObstacleTheme.draw_content(node, Rect2(0, 0, 128, 64), {"id": "OB06", "hp": hp}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB02", "hp": 2, "fragment": true}, font)
		ObstacleTheme.draw_content(node, rect, {"id": "OB77", "hp": 1}, font)
		ObstacleTheme.draw_content(node, rect, {}, font))


# ---------------------------------------------------------------- (5) textures and icon

func test_textures_empty_today() -> void:
	assert_eq(ObstacleTheme.TEXTURES.size(), 0, "no final art yet; placeholders are used")


func test_hoof_icon_null_or_texture() -> void:
	var icon: Texture2D = ObstacleTheme.hoof_icon()
	if icon == null:
		pass_test("hoof icon not available in this environment (allowed)")
	else:
		assert_true(icon is Texture2D)
		assert_gt(icon.get_width(), 0)
		assert_gt(icon.get_height(), 0)
