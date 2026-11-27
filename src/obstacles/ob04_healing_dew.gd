# OB04 healing dew (underlay): never damaged. When a match or a special clears a piece on dew,
# every cell that same match or special cleared gets dew too (IR-53). Dew goal: cover target cells.
# Check: tests/match_resolver/test_dew_and_locked_pieces.gd (IR-53).
extends ObstacleBehaviour


func takes_hits() -> bool:
	return false


func takes_adjacent_match_hits() -> bool:
	return false


## If any of `cleared` has dew, every cell in `cleared` gets dew (IR-53).
## Open question OQ-46 (provisional): only cells whose piece was cleared get dew, not empty or blocked cells.
static func spread(board: BoardModel, cleared: Array[Vector2i]) -> void:
	var any_dew: bool = false
	for c in cleared:
		if board.has_dew(c.x, c.y):
			any_dew = true
			break
	if not any_dew:
		return
	for c in cleared:
		board.give_dew(c.x, c.y)
