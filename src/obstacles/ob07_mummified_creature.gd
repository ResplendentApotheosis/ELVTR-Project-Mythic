# OB07 mummified creature / creep cocoon: freed by adjacent matches or specials. A cocoon with
# a soul fragment inside collects the fragment the moment it is freed (IR-29).
# Check: test_collectibles_and_gravity.gd IR-29 and test_damage_and_obstacles.gd IR-14 creature test.
extends ObstacleBehaviour


func on_cleared(board: BoardModel, id: String, cell: Vector2i, content: BoardContent) -> Array[BoardEvent]:
	if content == null or not content.fragment:
		return super.on_cleared(board, id, cell, content)
	board.add_collected("fragment")
	var e: BoardEvent = BoardEvent.new("collected")
	e.cell = cell
	e.data = {"item": "fragment", "carrier": "OB07"}   # also counts for a plain OB07 goal (IR-31)
	return [e]
