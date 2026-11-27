# Free shuffle when a stable board has no possible move (IR-33). Moves only plain pieces and
# specials (never obstacles, fragments, drop items, or pieces under an overlay) using board.rng,
# until there is a possible move and no ready-made match. Check: test_collectibles_and_gravity.gd IR-33.
class_name BoardShuffle
extends RefCounted

const MAX_TRIES: int = 300


static func shuffle(board: BoardModel, events: Array[BoardEvent]) -> void:
	var cells: Array[Vector2i] = []
	var kinds: Array[String] = []
	var colors: Array[String] = []
	for y in range(board.height):
		for x in range(board.width):
			var kind: String = board.get_kind(x, y)
			# Open question OQ-41 (provisional): pieces under an overlay are not shuffled.
			if kind == "" or kind == "drop" or board.overlay_hp(x, y) > 0:
				continue
			cells.append(Vector2i(x, y))
			kinds.append(kind)
			colors.append(board.get_color(x, y))
	if cells.size() < 2:
		return
	for _try in range(MAX_TRIES):
		var order: Array[int] = []
		for i in range(cells.size()):
			order.append(i)
		for i in range(order.size() - 1, 0, -1):
			var j: int = board.rng.randi_range(0, i)
			var t: int = order[i]
			order[i] = order[j]
			order[j] = t
		for i in range(cells.size()):
			board.set_piece(cells[i].x, cells[i].y, kinds[order[i]], colors[order[i]])
		if MatchFinder.find_groups(board).is_empty() and MatchResolver.has_possible_move(board):
			break
	# If no try succeeded the last arrangement stays; any match in it resolves as a cascade.
	var e: BoardEvent = BoardEvent.new("shuffle")
	e.cells = cells
	events.append(e)
