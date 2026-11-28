# Grey-box drawing of one piece: a coloured square (plain), the same with a short label (specials),
# or a labelled circle (drop items). Drawn around its own centre so it can scale in place.
# Check: F5 the greybox scene; every piece on the board is one of these.
class_name GreyboxPieceTile
extends Node2D

const COLORS: Dictionary = {
	"R": Color(0.86, 0.26, 0.26),
	"Y": Color(0.95, 0.83, 0.22),
	"B": Color(0.25, 0.46, 0.90),
	"G": Color(0.30, 0.74, 0.36),
}
const NO_COLOR: Color = Color(0.85, 0.85, 0.85)      # Orb, finale Rockets
const UNKNOWN_COLOR: Color = Color(0.5, 0.5, 0.5)    # a new piece whose colour is not known ("?")
const DROP_COLOR: Color = Color(0.96, 0.92, 0.80)
const LABELS: Dictionary = {
	"rocket_row": "R-", "rocket_col": "R|", "firecracker": "FC", "crane": "CR", "orb": "ORB",
}

var look: Dictionary = {"kind": "plain", "color": "", "item": ""}
var size: float = 56.0


func set_look(new_look: Dictionary) -> void:
	look = new_look.duplicate()
	queue_redraw()


func _draw() -> void:
	var kind: String = String(look.get("kind", ""))
	var font: Font = ThemeDB.fallback_font
	var half: float = size / 2.0
	if kind == "drop":
		draw_circle(Vector2.ZERO, half, DROP_COLOR)
		var item: String = String(look.get("item", ""))
		_text(font, "FRAG" if item == "fragment" else item, Color.BLACK)
		return
	draw_rect(Rect2(-half, -half, size, size), _fill_color())
	if LABELS.has(kind):
		draw_rect(Rect2(-half, -half, size, size), Color.WHITE, false, 3.0)
		_text(font, LABELS[kind], Color.BLACK)
	elif String(look.get("color", "")) == "?":
		_text(font, "?", Color.WHITE)


func _fill_color() -> Color:
	var c: String = String(look.get("color", ""))
	if c == "?":
		return UNKNOWN_COLOR
	return COLORS.get(c, NO_COLOR)


func _text(font: Font, text: String, color: Color) -> void:
	var font_size: int = int(size * 0.32)
	draw_string(font, Vector2(-size / 2.0, font_size * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, size, font_size, color)
