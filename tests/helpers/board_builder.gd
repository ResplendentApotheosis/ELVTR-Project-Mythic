# Test helper: builds BoardModel boards from short text tokens and inspects them.
# Used by every test under tests/. Contract: tests/API_CONTRACT.md. No scenes, no sound.
# Check: the tests that use it run (blank() boards must contain no match).
extends RefCounted

# Token legend (see API_CONTRACT.md):
#   R Y B G = plain piece      .  = unique filler (can never match anything)
#   R- R|   = row / column Bamboo Rocket of that colour
#   RF      = Firecracker (colour letter + F)    RC = Paper Crane (colour letter + C)
#   O = Jade Orb    H = lost hatchling drop item (OB11)    Q = fragment drop item
#   X = empty playable cell    # = not playable

static func filler_color(x: int, y: int) -> String:
	return "f%d_%d" % [x, y]


## A w x h board where every cell holds a unique filler piece. Fillers never match
## each other, even after pieces fall. auto_shuffle is OFF (turn it on for IR-33).
static func blank(w: int = 9, h: int = 9, seed_value: int = 1) -> BoardModel:
	var board: BoardModel = BoardModel.new(w, h, seed_value)
	board.auto_shuffle = false
	for y in range(h):
		for x in range(w):
			board.set_piece(x, y, "plain", filler_color(x, y))
	return board


## Rows of space-separated tokens, row 0 first. Returns a board with auto_shuffle OFF.
static func from_rows(rows: Array, seed_value: int = 1) -> BoardModel:
	var h: int = rows.size()
	var w: int = String(rows[0]).split(" ", false).size()
	var board: BoardModel = BoardModel.new(w, h, seed_value)
	board.auto_shuffle = false
	for y in range(h):
		var tokens: PackedStringArray = String(rows[y]).split(" ", false)
		assert(tokens.size() == w, "row %d has %d tokens, expected %d" % [y, tokens.size(), w])
		for x in range(w):
			apply_token(board, x, y, tokens[x])
	return board


## Put one token on many cells: put(board, "R", [[1, 2], [2, 2]]).
static func put(board: BoardModel, token: String, cells: Array) -> void:
	for c in cells:
		apply_token(board, int(c[0]), int(c[1]), token)


static func apply_token(board: BoardModel, x: int, y: int, token: String) -> void:
	match token:
		".":
			board.set_piece(x, y, "plain", filler_color(x, y))
		"X":
			board.set_piece(x, y, "", "")
		"#":
			board.set_playable(x, y, false)
		"O":
			board.set_piece(x, y, "orb", "")
		"H":
			board.set_drop_item(x, y, "OB11")
		"Q":
			board.set_drop_item(x, y, "fragment")
		_:
			var color: String = token.substr(0, 1)
			var suffix: String = token.substr(1)
			var kind: String = "plain"
			match suffix:
				"": kind = "plain"
				"-": kind = "rocket_row"
				"|": kind = "rocket_col"
				"F": kind = "firecracker"
				"C": kind = "crane"
				_: assert(false, "unknown board token: " + token)
			board.set_piece(x, y, kind, color)


## Board with exact counts of R/Y/B/G plain pieces, e.g. {"R": 20, "Y": 18, "B": 17, "G": 16}.
## Cells not needed for counts hold unique fillers. `reserved` maps Vector2i -> token for
## cells that must hold something else (an Orb, a Crane...). No match exists at the start.
static func with_counts(counts: Dictionary, reserved: Dictionary = {}, w: int = 9, h: int = 9, seed_value: int = 1) -> BoardModel:
	var grid: Dictionary = color_grid(w, h, counts, reserved, seed_value)
	var board: BoardModel = blank(w, h, seed_value)
	for pos in grid:
		var p: Vector2i = pos
		var token: String = grid[pos]
		if token != ".":
			apply_token(board, p.x, p.y, token)
	for pos in reserved:
		var p2: Vector2i = pos
		apply_token(board, p2.x, p2.y, reserved[pos])
	return board


## Pure data: Vector2i -> "R"/"Y"/"B"/"G"/"." for every non-reserved cell. Deterministic.
static func color_grid(w: int, h: int, counts: Dictionary, reserved: Dictionary, seed_value: int) -> Dictionary:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var cells: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var p: Vector2i = Vector2i(x, y)
			if not reserved.has(p):
				cells.append(p)
	var tokens: Array[String] = []
	for k in counts:
		for i in range(int(counts[k])):
			tokens.append(String(k))
	assert(tokens.size() <= cells.size(), "too many coloured pieces for the board")
	while tokens.size() < cells.size():
		tokens.append(".")
	# seeded shuffle
	for i in range(tokens.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var t: String = tokens[i]
		tokens[i] = tokens[j]
		tokens[j] = t
	var grid: Dictionary = {}
	for i in range(cells.size()):
		grid[cells[i]] = tokens[i]
	# repair: swap pieces until no 3-line or 2x2 of one colour remains
	for _iter in range(20000):
		var bad: Array[Vector2i] = _find_match_cells(grid, w, h)
		if bad.is_empty():
			return grid
		var a: Vector2i = bad[rng.randi_range(0, bad.size() - 1)]
		var b: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
		var tmp: String = grid[a]
		grid[a] = grid[b]
		grid[b] = tmp
	assert(false, "could not build a match-free colour grid")
	return grid


static func _find_match_cells(grid: Dictionary, w: int, h: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c: String = _tok(grid, x, y)
			if c == "":
				continue
			if x + 2 < w and _tok(grid, x + 1, y) == c and _tok(grid, x + 2, y) == c:
				out.append(Vector2i(x, y))
			if y + 2 < h and _tok(grid, x, y + 1) == c and _tok(grid, x, y + 2) == c:
				out.append(Vector2i(x, y))
			if x + 1 < w and y + 1 < h and _tok(grid, x + 1, y) == c and _tok(grid, x, y + 1) == c and _tok(grid, x + 1, y + 1) == c:
				out.append(Vector2i(x, y))
	return out


static func _tok(grid: Dictionary, x: int, y: int) -> String:
	var p: Vector2i = Vector2i(x, y)
	if not grid.has(p):
		return ""
	var t: String = grid[p]
	if t == ".":
		return ""
	return t


# ---------------------------------------------------------------- inspection

static func snapshot(board: BoardModel) -> String:
	var s: String = "%dx%d moves=%d\n" % [board.width, board.height, board.moves]
	for y in range(board.height):
		for x in range(board.width):
			s += "%s:%s:%s:%d:%d:%d|" % [
				board.get_kind(x, y), board.get_color(x, y), board.get_drop_item(x, y),
				board.content_hp(x, y), board.overlay_hp(x, y), board.underlay_hp(x, y)]
		s += "\n"
	return s


static func find_kind(board: BoardModel, kind: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == kind:
				out.append(Vector2i(x, y))
	return out


static func find_drop(board: BoardModel, item: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.get_drop_item(x, y) == item:
				out.append(Vector2i(x, y))
	return out


## Cells holding a piece of one colour (plain pieces and coloured specials).
static func find_color(board: BoardModel, color: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.get_color(x, y) == color:
				out.append(Vector2i(x, y))
	return out


## Every cell that holds any of the given piece kinds.
static func find_kinds(board: BoardModel, kinds: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if kinds.has(board.get_kind(x, y)):
				out.append(Vector2i(x, y))
	return out


## Playable cells with no piece and no blocker (should be empty after a resolve).
static func empty_cells(board: BoardModel) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.is_playable(x, y) and board.get_kind(x, y) == "" and board.content_hp(x, y) == 0:
				out.append(Vector2i(x, y))
	return out


## True if any 3-in-a-line or 2x2 of one colour exists among pieces that have a colour.
static func has_match(board: BoardModel) -> bool:
	for y in range(board.height):
		for x in range(board.width):
			var c: String = board.get_color(x, y)
			if c == "":
				continue
			if x + 2 < board.width and board.get_color(x + 1, y) == c and board.get_color(x + 2, y) == c:
				return true
			if y + 2 < board.height and board.get_color(x, y + 1) == c and board.get_color(x, y + 2) == c:
				return true
			if x + 1 < board.width and y + 1 < board.height and board.get_color(x + 1, y) == c and board.get_color(x, y + 1) == c and board.get_color(x + 1, y + 1) == c:
				return true
	return false
