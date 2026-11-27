# Base class for one obstacle's behaviour (one script per OB ID extends this).
# Defaults: hit by adjacent matches; when cleared, its id is counted for goals.
# Check: tests/match_resolver/test_damage_and_obstacles.gd (IR-13, IR-14).
class_name ObstacleBehaviour
extends RefCounted


## True if a match next to this obstacle gives it a hit (IR-14).
func takes_adjacent_match_hits() -> bool:
	return true


## Called once when the obstacle's last hp is gone. Counts the goal and returns any events.
func on_cleared(board: BoardModel, id: String, cell: Vector2i, _content: BoardContent) -> Array[BoardEvent]:
	board.add_collected(id)
	var e: BoardEvent = BoardEvent.new("obstacle_cleared")
	e.cell = cell
	e.data = {"id": id}
	return [e]
