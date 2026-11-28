# Hero boosters: Hoof Tap (one cell), Tail Slam (3x3), Bamboo Dash (row or column), Feather Fan (reshuffle).
# They use no move, collect drop items and fragments they cover, hit everything else like a special, then
# the board settles; they can win but never fail (IR-34, IR-35, IR-36, IR-62). Check: test_moves_counting.gd.
class_name BoosterService
extends RefCounted


## Clears the piece in one cell and gives its top layer one hit; collects a drop item there (IR-34, IR-36).
static func hoof_tap(board: BoardModel, cell: Vector2i) -> Array[BoardEvent]:
	var cells: Array[Vector2i] = []
	if board.is_playable(cell.x, cell.y):
		cells.append(cell)
	if board.is_playable(cell.x, cell.y) and board.get_kind(cell.x, cell.y) == "orb":
		return _hoof_tap_orb(board, cell)
	return _hit_cells(board, "hoof_tap", cell, cells)


## Hoof Tap on a Jade Orb acts as an Orb tap (OQ-107 B): the booster's one hit on the cell, the Orb
## goes, then every uncovered plain piece of the most common colour clears (OQ-112 A: counted before
## anything falls). With no such piece the Orb is just removed (OQ-111 A). Then one fall and refill.
static func _hoof_tap_orb(board: BoardModel, cell: Vector2i) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	GoalHook.begin(board)
	var cells: Array[Vector2i] = [cell]
	events.append(_booster_event("hoof_tap", cell, cells))
	var color: String = SpecialFiring.most_common_color(board)
	var targets: Array[Vector2i] = SpecialFiring.plain_cells_of(board, color)
	var waiting: Array[FireOrder] = []
	SpecialFiring.cover(board, cells, {}, "booster", waiting, events)
	waiting.clear()   # the tapped Orb itself is already removed and has no second effect
	if not targets.is_empty():
		var e: BoardEvent = BoardEvent.new("orb_fire")
		e.cell = cell
		e.color = color
		e.cells = targets
		events.append(e)
		SpecialFiring.cover(board, targets, {}, "orb", waiting, events)
	SpecialFiring.fire_set_offs(board, waiting, events)
	MatchResolver.stabilise(board, events)
	GoalHook.finish(board, events, false)   # a booster never causes a fail (IR-62)
	return events


## One hit to every cell of the 3x3 square around `center` (IR-36).
static func tail_slam(board: BoardModel, center: Vector2i) -> Array[BoardEvent]:
	return _hit_cells(board, "tail_slam", center, SpecialFiring.rect_cells(board, center, 1))


## One hit to every cell of a row ("row") or a column ("col") (IR-36). The diagonal form is not built yet.
static func bamboo_dash(board: BoardModel, direction: String, index: int) -> Array[BoardEvent]:
	var cells: Array[Vector2i] = SpecialFiring.row_cells(board, index) if direction == "row" else SpecialFiring.col_cells(board, index)
	var start: Vector2i = Vector2i(0, index) if direction == "row" else Vector2i(index, 0)
	return _hit_cells(board, "bamboo_dash", start, cells)


## Reshuffles the pieces; drop items and fragments stay where they are (IR-35).
static func feather_fan(board: BoardModel) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	GoalHook.begin(board)
	events.append(_booster_event("feather_fan", Vector2i(-1, -1), [] as Array[Vector2i]))
	BoardShuffle.shuffle(board, events)
	MatchResolver.stabilise(board, events)
	GoalHook.finish(board, events, false)   # a booster never causes a fail (IR-62)
	return events


## Shared by the three hitting boosters: collect drop items, then act like a special on every cell
## (one hit per obstacle per use, IR-36), fire any specials it set off (IR-41), then settle (IR-62).
static func _hit_cells(board: BoardModel, name: String, cell: Vector2i, cells: Array[Vector2i]) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	GoalHook.begin(board)
	events.append(_booster_event(name, cell, cells))
	for c in cells:
		BoardGravity.collect_drop(board, c, events)   # collected, never deleted (IR-34)
	var waiting: Array[FireOrder] = []
	SpecialFiring.cover(board, cells, {}, "booster", waiting, events)
	SpecialFiring.fire_set_offs(board, waiting, events)
	MatchResolver.stabilise(board, events)
	GoalHook.finish(board, events, false)   # a booster never causes a fail (IR-62)
	return events


## A `booster` event so the presentation can show which booster was used and where.
static func _booster_event(name: String, cell: Vector2i, cells: Array[Vector2i]) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new("booster")
	e.cell = cell
	e.cells = cells
	e.data = {"name": name}
	return e
