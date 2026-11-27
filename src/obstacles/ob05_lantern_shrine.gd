# OB05 lantern shrine (multi-cell content). Owner decision OQ-50 (chat 27 Nov 2026, trial, revisit
# after playtest): a special lowers its hp by 1 (one hit per special, IR-55) without changing the colours
# it needs. A Crane landing on it counts as one piece of the colour it needs most (IR-49).
# Check: test_special_effects.gd test_ir49_shrine_* tests.
extends ObstacleBehaviour


## Open question OQ-55 (provisional): matches next to the shrine don't hit or fill it.
func takes_adjacent_match_hits() -> bool:
	return false


## Pieces the shrine still needs in total (its hp if no needs were set).
static func pieces_needed(content: BoardContent) -> int:
	if content.needs.is_empty():
		return content.hp
	var total: int = 0
	for k in content.needs:
		total += int(content.needs[k])
	return total


## The colour the shrine needs most. Owner decision OQ-43 (chat 27 Nov 2026): a tie is broken by
## the level's seeded board.rng (tied colours are sorted first so the same seed gives the same pick).
static func most_needed_color(board: BoardModel, content: BoardContent) -> String:
	var best_n: int = 0
	var tied: Array[String] = []
	for k in content.needs:
		var n: int = int(content.needs[k])
		if n > best_n:
			best_n = n
			tied = [String(k)]
		elif n == best_n and n > 0:
			tied.append(String(k))
	if tied.is_empty():
		return ""
	tied.sort()
	if tied.size() == 1:
		return tied[0]
	return tied[board.rng.randi_range(0, tied.size() - 1)]


## A Crane landing: one piece of the most-needed colour goes in (IR-49), which is one hit.
## Open question OQ-55 (provisional): that one hit also lowers the shrine's hp by 1.
static func take_one_piece(board: BoardModel, content: BoardContent, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	var color: String = most_needed_color(board, content)
	if color != "":
		content.needs[color] = int(content.needs[color]) - 1
	BoardDamage.hit_content(board, content, hitset, events)
