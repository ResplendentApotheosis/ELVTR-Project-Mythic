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
var goal_tracker: GoalTracker = null   # null = no goals tracked (the resolver behaves as before)
# Drop items for this attempt (IR-75), set by LevelLoader from spawn.drop_items.
var drop_total: int = 0            # items that appear in the whole attempt (0 = no drop items)
var drop_max_on_board: int = 0
var drop_fragment_item: int = 0    # the n-th item spawned carries the fragment (0 = none, IR-31)
var drop_spawned: int = 0          # items placed so far in this attempt (the starting ones count)

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
var _dew_target: Array[bool] = []   # cells the dew goal wants covered with dew (OB04)
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
		_dew_target.append(false)
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
		_dew_target[i] = false


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


## Marks a cell as a target of the healing-dew goal (OB04).
func set_dew_target(x: int, y: int) -> void:
	if in_bounds(x, y):
		_dew_target[_i(x, y)] = true


## Sets what a lantern shrine (OB05) at this cell still needs, e.g. {"R": 3, "B": 1}.
func set_shrine_needs(x: int, y: int, needs: Dictionary) -> void:
	var c: BoardContent = get_content(x, y)
	if c != null:
		c.needs = needs.duplicate()


## Sets the colour of the paper-screen lantern (OB08) at this cell, e.g. "R".
func set_content_color(x: int, y: int, color: String) -> void:
	var c: BoardContent = get_content(x, y)
	if c != null:
		c.color = color


# ---------------------------------------------------------------- queries (contract)

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


# Speed note: the level bot calls these few functions millions of times, so they check the bounds and
# work out the cell index themselves instead of calling in_bounds() / _i(). Same answers, fewer calls.

func is_playable(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= width or y >= height:
		return false
	return _playable[y * width + x]


func get_kind(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= width or y >= height:
		return ""
	var i: int = y * width + x
	if not _playable[i] or _content[i] != null:
		return ""
	return _kind[i]


func get_color(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= width or y >= height:
		return ""
	var i: int = y * width + x
	if not _playable[i] or _content[i] != null or _kind[i] == "":
		return ""
	return _color[i]


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
	if x < 0 or y < 0 or x >= width or y >= height:
		return 0
	var i: int = y * width + x
	return _overlay_hp[i] if _playable[i] else 0


func underlay_hp(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return 0
	var i: int = y * width + x
	return _underlay_hp[i] if _playable[i] else 0


func collected_count(key: String) -> int:
	return int(_collected.get(key, 0))


## Dew-goal target cells that do not have dew yet.
func dew_targets_left() -> int:
	var n: int = 0
	for y in range(height):
		for x in range(width):
			if is_uncovered_dew_target(x, y):
				n += 1
	return n


## Colour of the paper-screen lantern (OB08) at this cell as "R", "Y", "B" or "G"; "" otherwise.
func content_color(x: int, y: int) -> String:
	var c: BoardContent = get_content(x, y)
	return c.color if c != null and c.id == "OB08" else ""


## What the lantern shrine at this cell still needs ({} if there is no shrine).
func shrine_needs(x: int, y: int) -> Dictionary:
	var c: BoardContent = get_content(x, y)
	return c.needs.duplicate() if c != null else {}


# ---------------------------------------------------------------- helpers used by the resolver

func overlay_id(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= width or y >= height:
		return ""
	var i: int = y * width + x
	return _overlay_id[i] if _playable[i] else ""


func underlay_id(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= width or y >= height:
		return ""
	var i: int = y * width + x
	return _underlay_id[i] if _playable[i] else ""


func set_overlay_hp(x: int, y: int, hp: int) -> void:
	set_overlay(x, y, overlay_id(x, y), hp)


func set_underlay_hp(x: int, y: int, hp: int) -> void:
	set_underlay(x, y, underlay_id(x, y), hp)


## True if the cell has healing dew (an "OB04" underlay with hp left).
func has_dew(x: int, y: int) -> bool:
	return underlay_id(x, y) == "OB04" and underlay_hp(x, y) > 0


func give_dew(x: int, y: int) -> void:
	if is_playable(x, y):
		set_underlay(x, y, "OB04", 1)


func is_uncovered_dew_target(x: int, y: int) -> bool:
	return is_playable(x, y) and _dew_target[_i(x, y)] and not has_dew(x, y)


## A piece under an overlay is locked: it can't be swapped and doesn't fall (IR-54).
func is_locked(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= width or y >= height:
		return false
	var i: int = y * width + x
	return _playable[i] and _content[i] == null and _kind[i] != "" and _overlay_hp[i] > 0


func get_content(x: int, y: int) -> BoardContent:
	if x < 0 or y < 0 or x >= width or y >= height:
		return null
	var i: int = y * width + x
	return _content[i] if _playable[i] else null


## Removes a content obstacle from every cell it covers (its cells become empty).
func remove_content(content: BoardContent) -> void:
	for c in content.cells():
		if in_bounds(c.x, c.y) and _content[_i(c.x, c.y)] == content:
			_content[_i(c.x, c.y)] = null


## Every content obstacle on the board, each listed once (reading order of its top-left cell).
func all_contents() -> Array[BoardContent]:
	var out: Array[BoardContent] = []
	for i in range(_content.size()):   # index order = reading order (y, then x)
		var c: BoardContent = _content[i]
		if c != null and _playable[i] and not out.has(c):
			out.append(c)
	return out


## True if the cell holds a piece, a special or a drop item (something that can fall).
func has_item(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= width or y >= height:
		return false
	var i: int = y * width + x
	return _playable[i] and _content[i] == null and _kind[i] != ""


func is_special(x: int, y: int) -> bool:
	return SPECIAL_KINDS.has(get_kind(x, y))


## A playable cell with no content and no item: gravity should fill it.
func is_empty(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= width or y >= height:
		return false
	var i: int = y * width + x
	return _playable[i] and _content[i] == null and _kind[i] == ""


## True if any cell is empty (is_empty). Lets gravity skip its work on a full board.
func has_empty_cell() -> bool:
	for i in range(_kind.size()):
		if _playable[i] and _content[i] == null and _kind[i] == "":
			return true
	return false


## Every cell's kind as get_kind() would give it (index = y * width + x), in one pass. For fast scans.
func kind_grid() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	out.resize(_kind.size())
	for i in range(_kind.size()):
		if _playable[i] and _content[i] == null:
			out[i] = _kind[i]
	return out


## Every cell's colour as get_color() would give it (index = y * width + x), in one pass. For fast scans.
func color_grid() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	out.resize(_kind.size())
	for i in range(_kind.size()):
		if _playable[i] and _content[i] == null and _kind[i] != "":
			out[i] = _color[i]
	return out


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


## A full, independent copy of this board (every layer, piece, counter and the rng's exact state), for
## trying a move without touching the real board (the level bot). `goal_tracker` is NOT copied: it is
## left null, so the caller decides (e.g. GoalTracker.copy_for(copy)).
func copy() -> BoardModel:
	var b: BoardModel = BoardModel.new(width, height, 1)
	b.moves = moves
	b.auto_shuffle = auto_shuffle
	b.goals = goals.duplicate(true)
	b.exit_columns = exit_columns.duplicate(true)
	b.spawners = spawners.duplicate(true)
	b.palette = palette.duplicate(true)
	b.rng.seed = rng.seed
	b.rng.state = rng.state
	b.drop_total = drop_total
	b.drop_max_on_board = drop_max_on_board
	b.drop_fragment_item = drop_fragment_item
	b.drop_spawned = drop_spawned
	b._playable = _playable.duplicate()
	b._kind = _kind.duplicate()
	b._color = _color.duplicate()
	b._drop = _drop.duplicate()
	b._overlay_id = _overlay_id.duplicate()
	b._overlay_hp = _overlay_hp.duplicate()
	b._underlay_id = _underlay_id.duplicate()
	b._underlay_hp = _underlay_hp.duplicate()
	b._dew_target = _dew_target.duplicate()
	b._collected = _collected.duplicate(true)
	# A multi-cell obstacle is ONE object shared by its cells, so each one is copied once.
	var copies: Dictionary = {}
	for i in range(_content.size()):
		var c: BoardContent = _content[i]
		if c == null:
			continue
		if not copies.has(c):
			var n: BoardContent = BoardContent.new(c.id, c.hp, c.rect, c.fragment)
			n.needs = c.needs.duplicate(true)
			n.lit = c.lit
			n.color = c.color
			copies[c] = n
		b._content[i] = copies[c]
	return b


func _i(x: int, y: int) -> int:
	return y * width + x
