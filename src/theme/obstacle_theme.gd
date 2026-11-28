# The one place the screen asks "what does this look like?": pieces, floor, obstacles, the Hoof Tap icon and the
# background colour. Today every answer is placeholder vector art (PieceArt, ObstacleArt). To use final art,
# add an entry to TEXTURES ("R", "rocket_row", "OB02"... -> a texture path) and that image is drawn instead.
# Check: F5 the greybox scene; tests/greybox/test_obstacle_theme.gd checks the lookups.
class_name ObstacleTheme
extends RefCounted

const BACKGROUND: Color = Color(0.13, 0.33, 0.19)   # plain forest green

## Final art goes here later: key -> "res://..." path. Piece keys: "R", "Y", "B", "G" (plain pieces), "rocket_row",
## "rocket_col", "firecracker", "crane", "orb", "drop". Obstacle keys: the OB id ("OB02"...). Empty = placeholders.
const TEXTURES: Dictionary = {}

const HOOF_SVG: String = '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">' \
	+ '<path d="M9 40 C6 27 11 12 22 7 C25 16 25 28 24 40 Z" fill="#f4e9d0" stroke="#3b2a1a" stroke-width="3" stroke-linejoin="round"/>' \
	+ '<path d="M27 40 C26 28 26 16 29 7 C40 12 45 27 42 40 Z" fill="#f4e9d0" stroke="#3b2a1a" stroke-width="3" stroke-linejoin="round"/></svg>'

static var _hoof_icon: Texture2D = null


## The colour of a plain piece ("R", "Y", "B", "G"); grey for anything else.
static func piece_color(color: String) -> Color:
	return PieceArt.COLORS.get(color, PieceArt.UNKNOWN)


## Draws one piece around the canvas origin. `look` is a BoardSnapshot look: {"kind", "color", "item"}.
static func draw_piece(canvas: CanvasItem, look: Dictionary, size: float) -> void:
	var kind: String = String(look.get("kind", ""))
	var key: String = String(look.get("color", "")) if kind == "plain" else kind
	if not _draw_texture(canvas, key, Rect2(-size / 2.0, -size / 2.0, size, size)):
		PieceArt.draw(canvas, look, size)


static func draw_floor(canvas: CanvasItem, rect: Rect2, x: int, y: int) -> void:
	ObstacleArt.draw_floor(canvas, rect, x, y)


static func draw_underlay(canvas: CanvasItem, rect: Rect2, id: String, hp: int) -> void:
	if not _draw_texture(canvas, id, rect):
		ObstacleArt.draw_underlay(canvas, rect, id, hp)


static func draw_content(canvas: CanvasItem, rect: Rect2, content: Dictionary, font: Font) -> void:
	if not _draw_texture(canvas, String(content.get("id", "")), rect):
		ObstacleArt.draw_content(canvas, rect, content, font)


static func draw_overlay(canvas: CanvasItem, rect: Rect2, id: String, hp: int, font: Font) -> void:
	if not _draw_texture(canvas, id, rect):
		ObstacleArt.draw_overlay(canvas, rect, id, hp, font)


## The Hoof Tap button's picture: a hoof print, rasterised once from HOOF_SVG. Null if the engine can't do it.
static func hoof_icon() -> Texture2D:
	if _hoof_icon == null:
		var image: Image = Image.new()
		if image.load_svg_from_string(HOOF_SVG, 0.75) == OK:
			_hoof_icon = ImageTexture.create_from_image(image)
	return _hoof_icon


## Draws TEXTURES[key] into `rect` and returns true; false when there is no final art for that key.
static func _draw_texture(canvas: CanvasItem, key: String, rect: Rect2) -> bool:
	var path: String = String(TEXTURES.get(key, ""))
	if path == "" or not ResourceLoader.exists(path):
		return false
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		return false
	canvas.draw_texture_rect(texture, rect, false)
	return true
