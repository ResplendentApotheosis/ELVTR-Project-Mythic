# GUT test (IR-40, IR-89): on the REAL level files 2, 3, 5 and 6, swapping the two tutorial.hint_cells
# (both drag directions, seeds 1..20) is a legal swap that makes the special the level teaches, placed on
# one of the two swapped cells (the cell the piece moved into if it is in the match, else the start cell).
# Check: run the GUT suite; a failure names the level, seed, direction and what happened instead.
extends GutTest

const SEEDS: int = 20
const TAUGHT: Dictionary = {
	"rocket": ["rocket_row", "rocket_col"], "firecracker": ["firecracker"], "crane": ["crane"], "orb": ["orb"],
}


func _check_level(id: int) -> void:
	var failures: Array[String] = []
	var hint: Dictionary = {}
	for s in range(1, SEEDS + 1):
		var probe: LevelAttempt = LevelLoader.load_file(LevelLoader.level_path(id), {"seed": s})
		assert_not_null(probe, "level %d loads (seed %d)" % [id, s])
		if probe == null:
			return
		hint = probe.tutorial
		var cells: Array = hint["hint_cells"]
		var a: Vector2i = Vector2i(int(cells[0][0]), int(cells[0][1]))
		var b: Vector2i = Vector2i(int(cells[1][0]), int(cells[1][1]))
		for dir in range(2):
			var from: Vector2i = a if dir == 0 else b
			var to: Vector2i = b if dir == 0 else a
			var attempt: LevelAttempt = LevelLoader.load_file(LevelLoader.level_path(id), {"seed": s})
			var problem: String = _swap_problem(attempt.board, from, to, String(hint["teach"]))
			if problem != "":
				failures.append("seed %d %s->%s: %s" % [s, from, to, problem])
	assert_eq(failures.size(), 0, "level %d teach=%s hint_cells=%s; %d failures, first: %s" % [
		id, hint.get("teach"), hint.get("hint_cells"), failures.size(), failures.slice(0, 3)])


## "" when fine, else what went wrong.
func _swap_problem(board: BoardModel, from: Vector2i, to: Vector2i, teach: String) -> String:
	for c in [from, to]:
		if board.get_kind(c.x, c.y) != "plain":
			return "hint cell %s is %s, not a plain piece" % [c, board.get_kind(c.x, c.y)]
	var events: Array[BoardEvent] = MatchResolver.swap(board, from, to)
	var swapped: bool = false
	var last_match: Array[Vector2i] = []
	for e in events:
		if e.type == "invalid_swap":
			return "swap refused (%s)" % e.data.get("reason")
		if e.type == "swap":
			swapped = true
		elif e.type == "match":
			last_match = e.cells
		elif e.type == "special_created":
			if not (TAUGHT[teach] as Array).has(e.kind):
				return "first special made is %s at %s, expected %s" % [e.kind, e.cell, teach]
			var expected: Vector2i = to if last_match.has(to) else from
			if not last_match.has(from) and not last_match.has(to):
				return "special made at %s from a match touching neither swapped cell" % e.cell
			if e.cell != expected:
				return "%s made at %s, expected %s (match %s)" % [e.kind, e.cell, expected, last_match]
			return ""
	if not swapped:
		return "no swap event"
	return "no special made; match events: %s" % [last_match]


func test_IR40_level_002_rocket_hint_swap_makes_a_rocket_on_a_swapped_cell() -> void:
	_check_level(2)


func test_IR40_level_003_firecracker_hint_swap_makes_a_firecracker_on_a_swapped_cell() -> void:
	_check_level(3)


func test_IR40_level_005_crane_hint_swap_makes_a_crane_on_a_swapped_cell() -> void:
	_check_level(5)


func test_IR40_level_006_orb_hint_swap_makes_an_orb_on_a_swapped_cell() -> void:
	_check_level(6)
