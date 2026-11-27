# Pure board data: a grid of cells, each with a 4-layer stack (floor = playable, underlay,
# content, overlay) plus the piece in the cell. No nodes, no visuals, no rules.
# Check: run the GUT suite; every resolver test builds boards with this class (API: tests/API_CONTRACT.md §2).
class_name BoardModel
extends RefCounted

const SPECIAL_KINDS: Array[String] = ["rocket_row", "rocket_col", "firecracker", "crane", "orb"]

var width: int
var height: int
var moves: int = 30
var auto_shuffle: bool = true
var goals: Array = []
var exit_columns: Array = []
var spawners: Array = []
var palette: Array = ["R", "Y", "B", "G"]
var rng: RandomNumberGenerator

# One entry per cell, index = y * width + x.
var _playable: Array[bool] = []
var _kind: PackedStringArray = PackedStringArray()
var _color: PackedStringArray = PackedStringArray()
var _drop: PackedStringArray = PackedStringArray()
var _content: Array[BoardContent] = []
var _overlay_id: PackedStringArray = PackedStringArray()
var _overlay_hp: PackedInt32Array = PackedInt32Array()
var _underlay_id: PackedStringArray = PackedStringArray()
var _underlay_hp: PackedInt32Array = PackedInt32Array()
var _collected: Dictionary = {}


func _init(board_width: int, board_height: int, seed_value: int = 1) -> void:
	width = board_width
	height = board_height
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var n: int = width * height
	for i in range(n):
		_playable.append(true)
		_content.append(null)
	_kind.resize(n)
	_color.resize(n)
	_drop.resize(n)
	_overlay_id.resize(n)
	_overlay_hp.resize(n)
	_underlay_id.resize(n)
	_underlay_hp.resize(n)


# ---------------------------------------------------------------- setup

func set_playable(x: int, y: int, playable: bool) -> void:
	if not in_bounds(x, y):
		return
	var i: int = _i(x, y)
	_playable[i] = playable
	if not playable:
		clear_piece(x, y)
		_content[i] = null
		_overlay_id[i] = ""
		_overlay_hp[i] = 0
		_underlay_id[i] = ""
		_underlay_hp[i] = 0


func set_piece(x: int, y: int, kind: String, color: String = "") -> void:
	if not in_bounds(x, y):
		return
	var i: int = _i(x, y)
	_kind[i] = kind
	_color[i] = color if kind != "" else ""
	_drop[i] = ""


func set_drop_item(x: int, y: int, item: String) -> void:
	if not in_bounds(x, y):
		return
	var i: int = _i(x, y)
	_kind[i] = "drop"
	_color[i] = ""
	_drop[i] = item


func add_content(id: String, x: int, y: int, hp: int, w: int = 1, h: int = 1, fragment: bool = false) -> void:
	var content: BoardContent = BoardContent.new(id, hp, Rect2i(x, y, w, h), fragment)
	for c in content.cells():
		if in_bounds(c.x, c.y):
			clear_piece(c.x, c.y)
			_content[_i(c.x, c.y)] = content


func set_overlay(x: int, y: int, id: String, hp: int) -> void:
	if not in_bounds(x, y):
		return
	_overlay_id[_i(x, y)] = id if hp > 0 else ""
	_overlay_hp[_i(x, y)] = maxi(hp, 0)


func set_underlay(x: int, y: int, id: String, hp: int) -> void:
	if not in_bounds(x, y):
		return
	_underlay_id[_i(x, y)] = id if hp > 0 else ""
	_underlay_hp[_i(x, y)] = maxi(hp, 0)


# ---------------------------------------------------------------- queries (contract)

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


func is_playable(x: int, y: int) -> bool:
	return in_bounds(x, y) and _playable[_i(x, y)]


func get_kind(x: int, y: int) -> String:
	if not is_playable(x, y) or _content[_i(x, y)] != null:
		return ""
	return _kind[_i(x, y)]


func get_color(x: int, y: int) -> String:
	if get_kind(x, y) == "":
		return ""
	return _color[_i(x, y)]


func get_drop_item(x: int, y: int) -> String:
	if get_kind(x, y) != "drop":
		return ""
	return _drop[_i(x, y)]


func content_id(x: int, y: int) -> String:
	var c: BoardContent = get_content(x, y)
	return c.id if c != null else ""


func content_hp(x: int, y: int) -> int:
	var c: BoardContent = get_content(x, y)
	return c.hp if c != null else 0


func overlay_hp(x: int, y: int) -> int:
	return _overlay_hp[_i(x, y)] if is_playable(x, y) else 0


func underlay_hp(x: int, y: int) -> int:
	return _underlay_hp[_i(x, y)] if is_playable(x, y) else 0


func collected_count(key: String) -> int:
	return int(_collected.get(key, 0))


# ---------------------------------------------------------------- helpers used by the resolver

func overlay_id(x: int, y: int) -> String:
	return _overlay_id[_i(x, y)] if is_playable(x, y) else ""


func underlay_id(x: int, y: int) -> String:
	return _underlay_id[_i(x, y)] if is_playable(x, y) else ""


func set_overlay_hp(x: int, y: int, hp: int) -> void:
	set_overlay(x, y, overlay_id(x, y), hp)


func set_underlay_hp(x: int, y: int, hp: int) -> void:
	set_underlay(x, y, underlay_id(x, y), hp)


func get_content(x: int, y: int) -> BoardContent:
	if not is_playable(x, y):
		return null
	return _content[_i(x, y)]


## Removes a content obstacle from every cell it covers (its cells become empty).
func remove_content(content: BoardContent) -> void:
	for c in content.cells():
		if in_bounds(c.x, c.y) and _content[_i(c.x, c.y)] == content:
			_content[_i(c.x, c.y)] = null


## Every content obstacle on the board, each listed once (reading order of its top-left cell).
func all_contents() -> Array[BoardContent]:
	var out: Array[BoardContent] = []
	for y in range(height):
		for x in range(width):
			var c: BoardContent = get_content(x, y)
			if c != null and not out.has(c):
				out.append(c)
	return out


## True if the cell holds a piece, a special or a drop item (something that can fall).
func has_item(x: int, y: int) -> bool:
	return get_kind(x, y) != ""


func is_special(x: int, y: int) -> bool:
	return SPECIAL_KINDS.has(get_kind(x, y))


## A playable cell with no content and no item: gravity should fill it.
func is_empty(x: int, y: int) -> bool:
	return is_playable(x, y) and get_content(x, y) == null and get_kind(x, y) == ""


func clear_piece(x: int, y: int) -> void:
	if not in_bounds(x, y):
		return
	var i: int = _i(x, y)
	_kind[i] = ""
	_color[i] = ""
	_drop[i] = ""


## Moves the item (piece, special or drop) from one cell to another; the start cell empties.
func move_piece(from: Vector2i, to: Vector2i) -> void:
	var a: int = _i(from.x, from.y)
	var b: int = _i(to.x, to.y)
	_kind[b] = _kind[a]
	_color[b] = _color[a]
	_drop[b] = _drop[a]
	clear_piece(from.x, from.y)


## Swaps the items in two cells (layers stay where they are).
func swap_pieces(a: Vector2i, b: Vector2i) -> void:
	var ia: int = _i(a.x, a.y)
	var ib: int = _i(b.x, b.y)
	var k: String = _kind[ia]
	var c: String = _color[ia]
	var d: String = _drop[ia]
	_kind[ia] = _kind[ib]
	_color[ia] = _color[ib]
	_drop[ia] = _drop[ib]
	_kind[ib] = k
	_color[ib] = c
	_drop[ib] = d


## Lowest playable row of a column, or -1 if the column has none.
func bottom_playable_y(x: int) -> int:
	for y in range(height - 1, -1, -1):
		if is_playable(x, y):
			return y
	return -1


func add_collected(key: String, amount: int = 1) -> void:
	_collected[key] = collected_count(key) + amount


func _i(x: int, y: int) -> int:
	return y * width + x
