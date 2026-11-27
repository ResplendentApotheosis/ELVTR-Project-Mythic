# One match found on the board: the cells of one colour joined by lines of 3+ and 2x2 squares.
# MatchFinder fills it in; it also works out which special the match makes (IR-04..IR-08).
# Check: test_matches_and_specials_creation.gd.
class_name MatchGroup
extends RefCounted

var color: String = ""
var cells: Array[Vector2i] = []
var h_runs: Array = []      # each an Array[Vector2i], left to right, length >= 3
var v_runs: Array = []      # each an Array[Vector2i], top to bottom, length >= 3
var squares: Array = []     # each an Array[Vector2i] of 4 cells


func has_cell(c: Vector2i) -> bool:
	return cells.has(c)


## The special this match makes, by shape priority Orb > Firecracker > Rocket > Crane (IR-08).
## "" means no special (a plain 3-line).
func special_kind() -> String:
	for run in h_runs + v_runs:
		if (run as Array).size() >= 5:
			return "orb"
	if crossing_cell() != Vector2i(-1, -1):
		return "firecracker"
	for run in h_runs:
		if (run as Array).size() == 4:
			return "rocket_row"
	for run in v_runs:
		if (run as Array).size() == 4:
			return "rocket_col"
	if not squares.is_empty():
		return "crane"
	return ""


## The cell shared by a row line and a column line (an L or T, IR-06), or (-1, -1).
## Open question OQ-28: a "+" (both lines crossing in the middle) is treated like an L/T here.
func crossing_cell() -> Vector2i:
	for h in h_runs:
		for v in v_runs:
			for c in h:
				if (v as Array).has(c):
					return c
	return Vector2i(-1, -1)


## A short shape name for the match event.
func shape_name() -> String:
	match special_kind():
		"orb": return "line5"
		"firecracker": return "l_or_t"
		"rocket_row", "rocket_col": return "line4"
		"crane": return "square"
	return "line3"


## Where a cascade match puts its special: the crossing cell for an L/T, otherwise the
## lowest, then left-most cell (IR-40).
func cascade_cell() -> Vector2i:
	if special_kind() == "firecracker":
		return crossing_cell()
	var best: Vector2i = cells[0]
	for c in cells:
		if c.y > best.y or (c.y == best.y and c.x < best.x):
			best = c
	return best
