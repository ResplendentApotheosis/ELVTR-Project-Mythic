# OB05 lantern shrine (multi-cell content). Owner decisions OQ-50 and OQ-55 (chat 27 Nov 2026):
# matches next to it fill its needed colours, a special lowers its hp by 1 (once per special), a Crane
# landing counts as one piece and takes no hp; it is lit (a `shrine_lit` event) at no needs or hp 0.
# Check: test_damage_and_obstacles.gd test_ir55_* and test_special_effects.gd test_ir49_shrine_* tests.
extends ObstacleBehaviour


## Open question OQ-59 (b) (provisional): a match next to the shrine fills colours but doesn't lower its hp.
func takes_adjacent_match_hits() -> bool:
	return false


## Open question OQ-59 (c) (provisional): a lit shrine stays on the board as a blocker nothing can hit.
func can_be_hit(content: BoardContent) -> bool:
	return not content.lit


## A special's hit (OQ-50): hp goes down; at hp 0 the shrine is lit but stays on the board (OQ-59 (c), provisional).
func after_content_hit(board: BoardModel, content: BoardContent, events: Array[BoardEvent]) -> void:
	check_lit(board, content, events)


## Pieces the shrine still needs in total (its hp if no needs were set). A lit shrine needs nothing.
static func pieces_needed(content: BoardContent) -> int:
	if content.lit:
		return 0
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


## A Crane landing: one piece of the most-needed colour goes in (IR-49). Owner decision OQ-55 (c)
## (chat 27 Nov 2026): it does not lower the shrine's hp.
static func take_one_piece(board: BoardModel, content: BoardContent, events: Array[BoardEvent]) -> void:
	if content.lit:
		return
	var color: String = most_needed_color(board, content)
	if color != "":
		content.needs[color] = int(content.needs[color]) - 1
	check_lit(board, content, events)


## A match of `color` was made: each of `pieces` whose own cell is up/down/left/right of a shrine cell
## fills one need of that colour (owner decision OQ-55 (a), chat 27 Nov 2026; IR-55).
## Open question OQ-59 (a) (provisional): match pieces that don't themselves touch the shrine fill nothing.
## Open question OQ-61 (provisional): the caller passes only the plain pieces the match clears, so a
## lifted coloured special in the match fills nothing.
static func fill_from_match(board: BoardModel, pieces: Array[Vector2i], color: String, events: Array[BoardEvent]) -> void:
	for content in board.all_contents():
		if content.id != "OB05" or content.lit:
			continue
		for p in pieces:
			if int(content.needs.get(color, 0)) <= 0:
				break
			if _touches(content, p):
				content.needs[color] = int(content.needs[color]) - 1
		check_lit(board, content, events)


## Lights the shrine once, when every needed colour is in (if it had needs) or its hp is 0 (OQ-55 (b)).
## Lighting counts the OB05 goal once.
static func check_lit(board: BoardModel, content: BoardContent, events: Array[BoardEvent]) -> void:
	if content.lit:
		return
	var all_in: bool = not content.needs.is_empty()
	for k in content.needs:
		if int(content.needs[k]) > 0:
			all_in = false
	if not all_in and content.hp > 0:
		return
	content.lit = true
	board.add_collected(content.id)
	var e: BoardEvent = BoardEvent.new("shrine_lit")
	e.cell = content.rect.position
	events.append(e)


## True if `cell` is outside the shrine and orthogonally next to one of its cells (OQ-08: no diagonals).
static func _touches(content: BoardContent, cell: Vector2i) -> bool:
	if content.rect.has_point(cell):
		return false
	for n in [cell + Vector2i.UP, cell + Vector2i.DOWN, cell + Vector2i.LEFT, cell + Vector2i.RIGHT]:
		if content.rect.has_point(n):
			return true
	return false
