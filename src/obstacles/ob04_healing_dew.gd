# OB04 healing dew (underlay): never damaged. When a match or a special clears a piece on dew,
# every playable cell that same match or special covers gets dew too (IR-53). Dew goal: cover target cells.
# Check: tests/match_resolver/test_dew_and_locked_pieces.gd (IR-53).
extends ObstacleBehaviour


func takes_hits() -> bool:
	return false


func takes_adjacent_match_hits() -> bool:
	return false


## If any of `cleared` (cells whose piece was cleared) has dew, every cell in `covered` gets dew (IR-53).
## Owner decision OQ-46 (chat 27 Nov 2026, trial, revisit after playtest): `covered` is every
## playable cell the match or special covers, including obstacle, fragment and drop-item cells.
## Open question OQ-56 (provisional): dew given to a goo cell replaces the goo.
static func spread(board: BoardModel, cleared: Array[Vector2i], covered: Array[Vector2i]) -> void:
	var any_dew: bool = false
	for c in cleared:
		if board.has_dew(c.x, c.y):
			any_dew = true
			break
	if not any_dew:
		return
	for c in covered:
		board.give_dew(c.x, c.y)
