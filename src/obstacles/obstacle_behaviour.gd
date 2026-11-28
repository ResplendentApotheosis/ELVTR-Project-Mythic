# Base class for one obstacle's behaviour (one script per OB ID extends this).
# Defaults: takes hits, is hit by adjacent matches, is removed at 0 hp, and when cleared its id is counted for goals.
# Check: tests/match_resolver/test_damage_and_obstacles.gd (IR-13, IR-14).
class_name ObstacleBehaviour
extends RefCounted


## False for layers that are never damaged, like healing dew (OB04).
func takes_hits() -> bool:
	return true


## True if a match next to this obstacle gives it a hit (IR-14).
func takes_adjacent_match_hits() -> bool:
	return true


## False if this content obstacle can't take a hit right now (e.g. a lit lantern shrine).
func can_be_hit(_content: BoardContent) -> bool:
	return true


## Called after a content obstacle lost 1 hp. Default: at 0 hp it leaves the board and is counted.
func after_content_hit(board: BoardModel, content: BoardContent, events: Array[BoardEvent]) -> void:
	if content.hp <= 0:
		board.remove_content(content)
		events.append_array(on_cleared(board, content.id, content.rect.position, content))
		GoalHook.announce(board, events)


## Called once when the obstacle's last hp is gone. Counts the goal and returns any events.
func on_cleared(board: BoardModel, id: String, cell: Vector2i, _content: BoardContent) -> Array[BoardEvent]:
	board.add_collected(id)
	var e: BoardEvent = BoardEvent.new("obstacle_cleared")
	e.cell = cell
	e.data = {"id": id}
	return [e]
