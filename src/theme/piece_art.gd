# Placeholder vector art for pieces (drawn with polygons, no image files): four colour shapes that differ in
# outline as well as colour (so colour-blind players can tell them apart), the specials' symbols and drop items.
# Check: F5 the greybox scene (every piece on the board is drawn here), or run tests/greybox/test_obstacle_theme.gd.
class_name PieceArt
extends RefCounted

## Okabe-Ito colour-blind-safe palette. Red = circle, Yellow = diamond, Blue = rounded square, Green = triangle.
const COLORS: Dictionary = {
	"R": Color(0.84, 0.37, 0.0),
	"Y": Color(0.94, 0.89, 0.26),
	"B": Color(0.0, 0.45, 0.70),
	"G": Color(0.0, 0.62, 0.45),
}
const NEUTRAL: Color = Color(0.93, 0.90, 0.80)
const UNKNOWN: Color = Color(0.5, 0.5, 0.5)
const OUTLINE: Color = Color(0.10, 0.10, 0.12)
const GLYPH: Color = Color(1.0, 1.0, 1.0)
const JADE_DARK: Color = Color(0.05, 0.40, 0.30)


## Draws one piece around the canvas origin; `size` is the piece's width in pixels.
static func draw(canvas: CanvasItem, look: Dictionary, size: float) -> void:
	var kind: String = String(look.get("kind", ""))
	var color: String = String(look.get("color", ""))
	var h: float = size / 2.0
	if kind == "drop":
		draw_drop(canvas, String(look.get("item", "")), h)
	elif kind == "orb":
		_draw_orb(canvas, h)
	elif kind == "rocket_row" or kind == "rocket_col" or kind == "firecracker" or kind == "crane":
		draw_shape(canvas, color, Vector2.ZERO, h, 3.0, true)
		_draw_glyph(canvas, kind, h)
	else:
		draw_shape(canvas, color, Vector2.ZERO, h, 2.5, false)
		if color == "?":
			canvas.draw_string(ThemeDB.fallback_font, Vector2(-h, h * 0.3), "?", HORIZONTAL_ALIGNMENT_CENTER, size, int(size * 0.6), GLYPH)


## The colour shape (also used small, for the shrine's needs). `special` adds a white ring.
static func draw_shape(canvas: CanvasItem, color: String, center: Vector2, h: float, line_w: float, special: bool) -> void:
	var pts: PackedVector2Array = _moved(shape_points(color, h), center)
	var fill: Color = COLORS.get(color, UNKNOWN if color == "?" else NEUTRAL)
	canvas.draw_colored_polygon(pts, fill)
	var ring: PackedVector2Array = pts.duplicate()
	ring.append(pts[0])
	if special:
		canvas.draw_polyline(ring, GLYPH, line_w + 3.0)
	canvas.draw_polyline(ring, OUTLINE, line_w)


## The outline of a colour: R circle, Y diamond, B rounded square, G triangle, anything else a circle.
static func shape_points(color: String, h: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	match color:
		"Y":
			pts = PackedVector2Array([Vector2(0, -h), Vector2(h, 0), Vector2(0, h), Vector2(-h, 0)])
		"B":
			var a: float = h * 0.80
			var c: float = h * 0.22
			pts = PackedVector2Array([
				Vector2(-a + c, -a), Vector2(a - c, -a), Vector2(a, -a + c), Vector2(a, a - c),
				Vector2(a - c, a), Vector2(-a + c, a), Vector2(-a, a - c), Vector2(-a, -a + c),
			])
		"G":
			pts = PackedVector2Array([Vector2(0, -h * 0.92), Vector2(h * 0.98, h * 0.78), Vector2(-h * 0.98, h * 0.78)])
		_:
			for i in range(24):
				pts.append(Vector2.from_angle(TAU * i / 24.0) * h * 0.90)
	return pts


# ---------------------------------------------------------------- specials

static func _draw_glyph(canvas: CanvasItem, kind: String, h: float) -> void:
	match kind:
		"rocket_row":
			_poly(canvas, _arrow(h * 0.95, false), GLYPH)
		"rocket_col":
			_poly(canvas, _arrow(h * 0.95, true), GLYPH)
		"firecracker":
			_draw_firecracker(canvas, h)
		"crane":
			_draw_crane(canvas, h)


## A double-headed arrow: it points the way the Rocket flies (sideways for a row, up and down for a column).
static func _arrow(s: float, vertical: bool) -> PackedVector2Array:
	var unit: Array[Vector2] = [
		Vector2(-0.70, 0), Vector2(-0.30, -0.38), Vector2(-0.30, -0.14), Vector2(0.30, -0.14), Vector2(0.30, -0.38),
		Vector2(0.70, 0), Vector2(0.30, 0.38), Vector2(0.30, 0.14), Vector2(-0.30, 0.14), Vector2(-0.30, 0.38),
	]
	var pts: PackedVector2Array = PackedVector2Array()
	for p in unit:
		pts.append(Vector2(p.y, p.x) * s if vertical else p * s)
	return pts


static func _draw_firecracker(canvas: CanvasItem, h: float) -> void:
	var s: float = h * 0.9
	_poly(canvas, _scaled([Vector2(-0.26, -0.30), Vector2(0.26, -0.30), Vector2(0.26, 0.62), Vector2(-0.26, 0.62)], s), Color(0.80, 0.12, 0.10))
	_poly(canvas, _scaled([Vector2(-0.26, 0.05), Vector2(0.26, 0.05), Vector2(0.26, 0.22), Vector2(-0.26, 0.22)], s), Color(0.98, 0.80, 0.25))
	var fuse: PackedVector2Array = _scaled([Vector2(0, -0.30), Vector2(0.05, -0.50), Vector2(0.22, -0.60)], s)
	canvas.draw_polyline(fuse, OUTLINE, 4.0)
	canvas.draw_polyline(fuse, GLYPH, 2.0)
	var spark: PackedVector2Array = PackedVector2Array()
	for i in range(8):
		spark.append(Vector2.from_angle(TAU * i / 8.0) * (0.24 if i % 2 == 0 else 0.10) * s + Vector2(0.28, -0.66) * s)
	_poly(canvas, spark, Color(1.0, 0.95, 0.30))


static func _draw_crane(canvas: CanvasItem, h: float) -> void:
	var s: float = h * 0.95
	_poly(canvas, _scaled([Vector2(-0.70, 0.12), Vector2(0.0, 0.52), Vector2(0.48, 0.10), Vector2(0.0, -0.06)], s), GLYPH)                  # body
	_poly(canvas, _scaled([Vector2(-0.20, -0.02), Vector2(0.18, -0.66), Vector2(0.36, 0.02)], s), Color(0.88, 0.94, 1.0))                    # wing
	_poly(canvas, _scaled([Vector2(0.40, 0.04), Vector2(0.66, -0.48), Vector2(0.80, -0.42), Vector2(0.54, 0.14)], s), GLYPH)                 # neck and head


static func _draw_orb(canvas: CanvasItem, h: float) -> void:
	canvas.draw_circle(Vector2.ZERO, h * 0.92, GLYPH)
	canvas.draw_circle(Vector2.ZERO, h * 0.80, Color(0.62, 0.92, 0.78))
	canvas.draw_arc(Vector2.ZERO, h * 0.80, 0.0, TAU, 32, JADE_DARK, 3.0)
	canvas.draw_arc(Vector2.ZERO, h * 0.46, 0.0, TAU, 24, JADE_DARK, 2.5)
	canvas.draw_circle(Vector2.ZERO, h * 0.16, JADE_DARK)
	var spark: PackedVector2Array = PackedVector2Array()
	for i in range(8):
		spark.append(Vector2.from_angle(TAU * i / 8.0) * (0.26 if i % 2 == 0 else 0.07) * h + Vector2(-0.38, -0.40) * h)
	canvas.draw_colored_polygon(spark, GLYPH)


# ---------------------------------------------------------------- drop items

## A drop item (acorn, or the Rat fragment) around the canvas origin; `h` is half its width.
static func draw_drop(canvas: CanvasItem, item: String, h: float) -> void:
	if item == "fragment":
		# A faceted purple shard: a piece of the Rat.
		_poly(canvas, _scaled([Vector2(0, -0.95), Vector2(0.75, -0.25), Vector2(0.45, 0.85), Vector2(-0.45, 0.85), Vector2(-0.75, -0.25)], h), Color(0.62, 0.35, 0.80))
		canvas.draw_polyline(_scaled([Vector2(-0.75, -0.25), Vector2(0.75, -0.25)], h), GLYPH, 2.0)
		canvas.draw_polyline(_scaled([Vector2(0, -0.95), Vector2(-0.2, -0.25), Vector2(-0.45, 0.85)], h), GLYPH, 2.0)
		return
	# Any other drop item: a brown acorn with a down arrow.
	canvas.draw_circle(Vector2(0, h * 0.15), h * 0.72, Color(0.70, 0.45, 0.22))
	canvas.draw_arc(Vector2(0, h * 0.15), h * 0.72, 0.0, TAU, 28, OUTLINE, 2.5)
	_poly(canvas, _scaled([Vector2(-0.8, -0.18), Vector2(0, -0.78), Vector2(0.8, -0.18)], h), Color(0.45, 0.28, 0.14))
	_poly(canvas, _scaled([Vector2(-0.22, 0.0), Vector2(0.22, 0.0), Vector2(0.22, 0.30), Vector2(0.4, 0.30), Vector2(0, 0.72), Vector2(-0.4, 0.30), Vector2(-0.22, 0.30)], h), GLYPH)


## Fills a polygon and outlines it dark (the outline is what keeps white symbols readable on yellow).
static func _poly(canvas: CanvasItem, pts: PackedVector2Array, fill: Color) -> void:
	canvas.draw_colored_polygon(pts, fill)
	var ring: PackedVector2Array = pts.duplicate()
	ring.append(pts[0])
	canvas.draw_polyline(ring, OUTLINE, 2.0)


static func _scaled(unit: Array[Vector2], s: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for p in unit:
		pts.append(p * s)
	return pts


static func _moved(pts: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for p in pts:
		out.append(p + by)
	return out
