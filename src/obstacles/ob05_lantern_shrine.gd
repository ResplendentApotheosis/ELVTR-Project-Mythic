# OB05 lantern shrine (multi-cell content). Open question OQ-50 (provisional): a special lowers its hp
# by 1 (one hit per special, IR-10, IR-11) without changing the colours it needs; matches don't fill it
# yet. A Crane landing on it counts as one piece of the colour it needs most (IR-49).
# Check: test_special_effects.gd test_ir49_shrine_goal_counts_pieces_still_needed_and_takes_the_most_needed_colour.
extends ObstacleBehaviour


## Open question OQ-50 (provisional): matches next to the shrine don't hit or fill it.
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


## The colour the shrine needs most. Open question OQ-43 (provisional): a tie goes R, Y, B, G,
## then other colours A-Z.
static func most_needed_color(content: BoardContent) -> String:
	var order: Array[String] = ["R", "Y", "B", "G"]
	var others: Array[String] = []
	for k in content.needs:
		if not order.has(String(k)):
			others.append(String(k))
	others.sort()
	order.append_array(others)
	var best: String = ""
	var best_n: int = 0
	for c in order:
		var n: int = int(content.needs.get(c, 0))
		if n > best_n:
			best = c
			best_n = n
	return best


## A Crane landing: one piece of the most-needed colour goes in (IR-49), which is one hit.
static func take_one_piece(board: BoardModel, content: BoardContent, hitset: Dictionary, events: Array[BoardEvent]) -> void:
	var color: String = most_needed_color(content)
	if color != "":
		content.needs[color] = int(content.needs[color]) - 1
	BoardDamage.hit_content(board, content, hitset, events)
