# Placeholder vector art for the board floor and the obstacles of levels 1-15 (bramble, moss, dew, goo,
# lantern shrine, petrified pillar), drawn with simple shapes. The layers a player must still remove
# (bramble rings, moss blankets, pillar blocks, shrine needs) are drawn from the obstacle's hp and needs.
# Check: F5 the greybox scene and load level 11 (debug key L); or run tests/greybox/test_obstacle_theme.gd.
class_name ObstacleArt
extends RefCounted

const FLOOR_A: Color = Color(0.20, 0.42, 0.27)
const FLOOR_B: Color = Color(0.23, 0.46, 0.30)
const DEW: Color = Color(0.55, 0.85, 1.0, 0.50)
const DEW_DROP: Color = Color(0.75, 0.93, 1.0)
const GOO: Color = Color(0.55, 0.25, 0.65, 0.65)
const MOSS: Color = Color(0.50, 0.55, 0.14)
const BRAMBLE_BASE: Color = Color(0.27, 0.17, 0.10)
const BRAMBLE_VINE: Color = Color(0.58, 0.40, 0.20)
const STONE: Color = Color(0.62, 0.63, 0.68)
const STONE_DARK: Color = Color(0.30, 0.30, 0.34)
const SHRINE_STONE: Color = Color(0.46, 0.45, 0.50)
const WINDOW_GLOW: Color = Color(1.0, 0.85, 0.40)
const OUTLINE: Color = Color(0.10, 0.10, 0.12)
const WHITE: Color = Color(1, 1, 1)


static func draw_floor(canvas: CanvasItem, rect: Rect2, x: int, y: int) -> void:
	canvas.draw_rect(rect, FLOOR_A if (x + y) % 2 == 0 else FLOOR_B)


## Underlays sit under the piece: dew (light-blue wash with drops) and goo (purple blob).
static func draw_underlay(canvas: CanvasItem, rect: Rect2, id: String, _hp: int) -> void:
	var r: Rect2 = rect.grow(-1.0)
	if id == "OB04":
		canvas.draw_rect(r, DEW)
		canvas.draw_rect(r, DEW_DROP, false, 2.0)
		var d: float = rect.size.x * 0.11
		for corner in [Vector2(0.2, 0.22), Vector2(0.8, 0.22), Vector2(0.2, 0.78), Vector2(0.8, 0.78)]:
			_drop(canvas, rect.position + rect.size * (corner as Vector2), d)
	elif id == "OB10":
		canvas.draw_rect(r, GOO)
		for i in range(5):
			var p: Vector2 = rect.position + rect.size * Vector2(0.2 + 0.15 * i, 0.3 if i % 2 == 0 else 0.7)
			canvas.draw_circle(p, rect.size.x * 0.11, Color(0.70, 0.40, 0.80, 0.8))
	else:
		canvas.draw_rect(r, Color(0.8, 0.5, 0.2, 0.6))


## Overlays sit over the piece: moss is a blanket per layer, so more hp = a thicker, darker cover.
static func draw_overlay(canvas: CanvasItem, rect: Rect2, id: String, hp: int, font: Font) -> void:
	if id != "OB03":
		canvas.draw_rect(rect.grow(-2.0), Color(0.55, 0.95, 0.55), false, 4.0)
		canvas.draw_string(font, rect.position + Vector2(0, 12), "%s %d" % [id, hp], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 10, WHITE)
		return
	for layer in range(maxi(hp, 1)):
		var inset: float = 3.0 + layer * 7.0
		var shade: float = 1.0 - 0.18 * layer
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = Color(MOSS.r * shade, MOSS.g * shade, MOSS.b * shade, 0.20)
		box.border_color = Color(0.30, 0.38, 0.06, 0.95)
		box.set_border_width_all(3)
		box.set_corner_radius_all(14)
		canvas.draw_style_box(box, rect.grow(-inset))
	var s: float = rect.size.x
	for i in range(7):   # fuzz dots
		var p: Vector2 = rect.position + Vector2(s * (0.18 + 0.64 * fmod(i * 0.37, 1.0)), s * (0.2 + 0.6 * fmod(i * 0.61, 1.0)))
		canvas.draw_circle(p, s * 0.04, Color(0.78, 0.85, 0.35, 0.9))


## Content blockers fill their rectangle: bramble, shrine, pillar. Anything else is a labelled stone block.
static func draw_content(canvas: CanvasItem, rect: Rect2, content: Dictionary, font: Font) -> void:
	var id: String = String(content.get("id", ""))
	var hp: int = int(content.get("hp", 1))
	match id:
		"OB02":
			_bramble(canvas, rect, hp)
		"OB05":
			_shrine(canvas, rect, content, hp, font)
		"OB06":
			_pillar(canvas, rect, hp)
		_:
			canvas.draw_rect(rect, STONE_DARK)
			canvas.draw_rect(rect, OUTLINE, false, 2.0)
			canvas.draw_string(font, rect.position + Vector2(0, 20), "%s %d" % [id, hp], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, WHITE)
	if bool(content.get("fragment", false)):
		var gem_h: float = minf(rect.size.x, rect.size.y) * 0.17
		canvas.draw_set_transform(Vector2(rect.end.x - gem_h - 4.0, rect.position.y + gem_h + 4.0))
		PieceArt.draw_drop(canvas, "fragment", gem_h)
		canvas.draw_set_transform(Vector2.ZERO)


# ---------------------------------------------------------------- bramble

## One ring of thorny vine per layer left, outermost first; the centre shows the same number as dots.
static func _bramble(canvas: CanvasItem, rect: Rect2, hp: int) -> void:
	canvas.draw_rect(rect, BRAMBLE_BASE)
	canvas.draw_rect(rect, OUTLINE, false, 2.0)
	var layers: int = maxi(hp, 1)
	for i in range(layers):
		var ring: Rect2 = rect.grow(-(5.0 + i * 7.0))
		var tone: float = 0.75 + 0.25 * float(i) / float(layers)
		var vine: Color = Color(BRAMBLE_VINE.r * tone, BRAMBLE_VINE.g * tone, BRAMBLE_VINE.b * tone)
		canvas.draw_rect(ring, vine, false, 3.0)
		for corner in [ring.position, ring.position + Vector2(ring.size.x, 0), ring.end, ring.position + Vector2(0, ring.size.y)]:
			var c: Vector2 = corner
			var out: Vector2 = (c - ring.get_center()).normalized()
			canvas.draw_colored_polygon(PackedVector2Array([c + out * 6.0, c + out.rotated(1.1) * 2.0, c + out.rotated(-1.1) * 2.0]), Color(0.85, 0.8, 0.6))
	canvas.draw_line(rect.position + Vector2(6, 6), rect.end - Vector2(6, 6), BRAMBLE_VINE, 2.0)
	canvas.draw_line(rect.position + Vector2(rect.size.x - 6, 6), rect.position + Vector2(6, rect.size.y - 6), BRAMBLE_VINE, 2.0)
	for i in range(layers):
		canvas.draw_circle(rect.get_center() + Vector2((i - (layers - 1) / 2.0) * 9.0, 0), 3.2, Color(0.95, 0.9, 0.6))


# ---------------------------------------------------------------- pillar

## A stone column cut into one block per hp left (blocks run along its long side) with a crack across it.
static func _pillar(canvas: CanvasItem, rect: Rect2, hp: int) -> void:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = STONE
	box.border_color = OUTLINE
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	canvas.draw_style_box(box, rect)
	var n: int = maxi(hp, 1)
	var vertical: bool = rect.size.y >= rect.size.x
	for i in range(1, n):
		var t: float = float(i) / float(n)
		if vertical:
			canvas.draw_line(rect.position + Vector2(2, rect.size.y * t), rect.position + Vector2(rect.size.x - 2, rect.size.y * t), STONE_DARK, 2.0)
		else:
			canvas.draw_line(rect.position + Vector2(rect.size.x * t, 2), rect.position + Vector2(rect.size.x * t, rect.size.y - 2), STONE_DARK, 2.0)
	var c: Vector2 = rect.get_center()
	var u: float = minf(rect.size.x, rect.size.y) * 0.2
	canvas.draw_polyline(PackedVector2Array([c + Vector2(-u, -1.6 * u), c + Vector2(0.3 * u, -0.5 * u), c + Vector2(-0.4 * u, 0.4 * u), c + Vector2(u, 1.6 * u)]), STONE_DARK, 2.5)


# ---------------------------------------------------------------- shrine

## A stone lantern; under it one small colour shape and a count per colour it still needs (or flames = hp).
static func _shrine(canvas: CanvasItem, rect: Rect2, content: Dictionary, hp: int, font: Font) -> void:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = SHRINE_STONE
	box.border_color = OUTLINE
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	canvas.draw_style_box(box, rect)
	var a: Rect2 = rect.grow(-4.0)
	var lantern_area: Rect2 = Rect2(a.position, Vector2(a.size.x, a.size.y * 0.62))
	var l: float = minf(lantern_area.size.y, lantern_area.size.x * 0.9)
	var cx: float = a.get_center().x
	var top: float = lantern_area.position.y
	var glow: Color = PieceArt.COLORS.get(String(content.get("color", "")), WINDOW_GLOW)
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(cx - l * 0.55, top + l * 0.30), Vector2(cx, top), Vector2(cx + l * 0.55, top + l * 0.30)]), STONE_DARK)
	canvas.draw_rect(Rect2(cx - l * 0.32, top + l * 0.30, l * 0.64, l * 0.50), glow)
	canvas.draw_rect(Rect2(cx - l * 0.32, top + l * 0.30, l * 0.64, l * 0.50), OUTLINE, false, 2.0)
	canvas.draw_line(Vector2(cx, top + l * 0.30), Vector2(cx, top + l * 0.80), OUTLINE, 2.0)
	canvas.draw_rect(Rect2(cx - l * 0.42, top + l * 0.80, l * 0.84, l * 0.16), STONE_DARK)
	var needs: Dictionary = content.get("needs", {}) as Dictionary
	var kinds: Array[String] = []
	for k in ["R", "Y", "B", "G"]:
		if int(needs.get(k, 0)) > 0:
			kinds.append(k)
	var row: Rect2 = Rect2(a.position.x, a.position.y + a.size.y * 0.66, a.size.x, a.size.y * 0.34)
	if kinds.is_empty():
		for i in range(maxi(hp, 1)):
			canvas.draw_circle(Vector2(row.get_center().x + (i - (maxi(hp, 1) - 1) / 2.0) * 12.0, row.get_center().y), 4.0, WINDOW_GLOW)
		return
	var slot: float = row.size.x / kinds.size()
	var h: float = minf(slot * 0.28, row.size.y * 0.42)
	var font_size: int = int(clampf(h * 1.5, 10.0, 22.0))
	for i in range(kinds.size()):
		var center: Vector2 = Vector2(row.position.x + slot * (i + 0.3), row.get_center().y)
		PieceArt.draw_shape(canvas, kinds[i], center, h, 1.5, false)
		var text: String = str(int(needs[kinds[i]]))
		var pos: Vector2 = Vector2(center.x + h + 2.0, center.y + font_size * 0.36)
		canvas.draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, OUTLINE)
		canvas.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, WHITE)


# ---------------------------------------------------------------- bits

static func _drop(canvas: CanvasItem, center: Vector2, h: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([center + Vector2(0, -h * 1.4)])
	for i in range(13):   # round bottom, from the tip's right side round to its left side
		var ang: float = -PI / 2.0 + 0.9 + (TAU - 1.8) * i / 12.0
		pts.append(center + Vector2(0, h * 0.2) + Vector2.from_angle(ang) * h)
	canvas.draw_colored_polygon(pts, DEW_DROP)
	canvas.draw_polyline(pts, Color(0.2, 0.5, 0.75), 1.5)
