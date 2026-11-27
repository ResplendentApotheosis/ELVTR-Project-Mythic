# The board's rules engine: swaps, taps, matches, specials, damage, gravity, refill, cascades and the win finale.
# Everything resolves instantly and returns Array[BoardEvent] for the presentation to play later.
# Check: "$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
class_name MatchResolver
extends RefCounted

const NO_CELL: Vector2i = Vector2i(-1, -1)
const MAX_CASCADES: int = 200


## The player drags the piece at `from` into `to` (IR-01, IR-18, IR-22..27, IR-39, IR-52).
static func swap(board: BoardModel, from: Vector2i, to: Vector2i) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	if not _can_swap(board, from, to):
		events.append(_invalid(from, to, "refused"))
		return events
	var from_special: bool = board.is_special(from.x, from.y)
	var to_special: bool = board.is_special(to.x, to.y)
	board.swap_pieces(from, to)
	if not from_special and not to_special:
		var groups: Array[MatchGroup] = MatchFinder.find_groups(board)
		if groups.is_empty():
			board.swap_pieces(from, to)   # snap back: nothing changes, no move used (IR-01)
			events.append(_invalid(from, to, "no_match"))
			return events
		_accept(board, from, to, events)
		_resolve_matches(board, groups, from, to, [] as Array[FireOrder], events)
	elif from_special and to_special:
		_accept(board, from, to, events)
		ComboFiring.fire(board, from, to, events)
	else:
		_accept(board, from, to, events)
		_special_with_piece(board, from, to, to if from_special else from, events)
	_stabilise(board, events)
	return events


## Tapping a special fires it and uses a move; anything else does nothing (IR-02).
static func tap(board: BoardModel, cell: Vector2i) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	if not board.is_special(cell.x, cell.y):
		return events
	board.moves -= 1
	var queue: Array[FireOrder] = [FireOrder.new(board.get_kind(cell.x, cell.y), board.get_color(cell.x, cell.y), cell, true)]
	SpecialFiring.run(board, queue, events)
	_stabilise(board, events)
	return events


## Resolves a board as it stands, using no move: falls, refills and cascade matches until stable,
## then a free shuffle if there is no possible move and board.auto_shuffle is on (IR-32, IR-33).
static func settle(board: BoardModel) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	_stabilise(board, events)
	return events


## Win finale (IR-16, IR-05): each leftover move becomes one Bamboo Rocket, fired one after another,
## each fully resolved (fall, refill, cascades) before the next; board.moves ends at 0.
## Owner decision OQ-40 (chat 27 Nov 2026): each Rocket's direction is one board.rng draw, unless
## `directions[i]` ("rocket_row" / "rocket_col") overrides it (a test seam).
## Open question OQ-53 (provisional): each direction is an independent 50/50 pick.
## Not in the spec (our choice): each Rocket replaces a random uncovered plain piece (a second
## board.rng draw); with no such piece it fires from the board's middle cell.
static func fire_finale(board: BoardModel, directions: Array = []) -> Array[BoardEvent]:
	var events: Array[BoardEvent] = []
	var index: int = 0
	while board.moves > 0:
		var kind: String = ""
		if index < directions.size():
			kind = String(directions[index])
		else:
			kind = "rocket_row" if board.rng.randi_range(0, 1) == 0 else "rocket_col"
		board.moves -= 1
		index += 1
		var order: FireOrder = _place_finale_rocket(board, kind, events)
		_fire_waiting(board, [order] as Array[FireOrder], events)
		cascade(board, events)
	return events


static func _place_finale_rocket(board: BoardModel, kind: String, events: Array[BoardEvent]) -> FireOrder:
	var options: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == "plain" and not board.is_locked(x, y):
				options.append(Vector2i(x, y))
	if options.is_empty():
		return FireOrder.new(kind, "", Vector2i(board.width / 2, board.height / 2), false)
	var cell: Vector2i = options[board.rng.randi_range(0, options.size() - 1)]
	board.set_piece(cell.x, cell.y, kind, "")
	var made: BoardEvent = BoardEvent.new("special_created")
	made.cell = cell
	made.kind = kind
	made.data = {"finale": true}
	events.append(made)
	return FireOrder.new(kind, "", cell, true)


## True if some swap would be accepted (makes a match or involves a special) or a special can be tapped.
static func has_possible_move(board: BoardModel) -> bool:
	for y in range(board.height):
		for x in range(board.width):
			if board.is_special(x, y):
				return true
	for y in range(board.height):
		for x in range(board.width):
			var a: Vector2i = Vector2i(x, y)
			for b in [a + Vector2i.RIGHT, a + Vector2i.DOWN]:
				if not _can_swap(board, a, b):
					continue
				board.swap_pieces(a, b)
				var ok: bool = MatchFinder.has_match_at(board, a) or MatchFinder.has_match_at(board, b)
				board.swap_pieces(a, b)
				if ok:
					return true
	return false


# ---------------------------------------------------------------- internals

## IR-52: two orthogonally adjacent cells, each holding a piece, a special or a drop item. Owner
## decision OQ-29: a piece under an overlay is locked and can't be swapped (IR-54).
static func _can_swap(board: BoardModel, from: Vector2i, to: Vector2i) -> bool:
	if absi(from.x - to.x) + absi(from.y - to.y) != 1:
		return false
	if board.is_locked(from.x, from.y) or board.is_locked(to.x, to.y):
		return false
	return board.has_item(from.x, from.y) and board.has_item(to.x, to.y)


static func _accept(board: BoardModel, from: Vector2i, to: Vector2i, events: Array[BoardEvent]) -> void:
	board.moves -= 1
	var e: BoardEvent = BoardEvent.new("swap")
	e.cells = [from, to] as Array[Vector2i]
	events.append(e)


static func _invalid(from: Vector2i, to: Vector2i, reason: String) -> BoardEvent:
	var e: BoardEvent = BoardEvent.new("invalid_swap")
	e.cells = [from, to] as Array[Vector2i]
	e.data = {"reason": reason}
	return e


## A single special swapped with a plain piece or drop item (IR-18, IR-39). The swap is done.
## Owner decision OQ-26: matches made by the swap resolve first, then the special fires from the
## cell it now sits in. Owner decision OQ-30: an Orb swapped with a drop item acts as a tap.
## Owner decision OQ-44 (chat 27 Nov 2026): pieces fall and refill between the swap's match and
## the special firing; new matches from that fall wait until it has fired.
static func _special_with_piece(board: BoardModel, from: Vector2i, to: Vector2i, special_cell: Vector2i, events: Array[BoardEvent]) -> void:
	var other: Vector2i = from if special_cell == to else to
	var kind: String = board.get_kind(special_cell.x, special_cell.y)
	var order: FireOrder = FireOrder.new(kind, board.get_color(special_cell.x, special_cell.y), special_cell, true)
	if kind == "orb":
		var color: String = board.get_color(other.x, other.y)
		if board.get_kind(other.x, other.y) != "plain":
			color = SpecialFiring.most_common_color(board)
		var waiting: Array[FireOrder] = []
		SpecialFiring.fire_orb(board, order, color, waiting, events)
		SpecialFiring.fire_set_offs(board, waiting, events)
		return
	var groups: Array[MatchGroup] = MatchFinder.find_groups(board)
	var extra: Array[FireOrder] = [order]
	for g in groups:
		if g.has_cell(special_cell):
			extra = []   # it is in a match, so it fires as a matched special (IR-50)
	_resolve_matches(board, groups, from, to, extra, events)


## Clears each match, gives its hits, places its special, then fires `extra` specials and any
## specials that were in the matches (IR-21, IR-50). `from`/`to` are the swap cells, or NO_CELL in cascades.
static func _resolve_matches(board: BoardModel, groups: Array[MatchGroup], from: Vector2i, to: Vector2i,
		extra: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var queue: Array[FireOrder] = extra.duplicate()
	for g in groups:
		var m: BoardEvent = BoardEvent.new("match")
		m.cells = g.cells.duplicate()
		m.color = g.color
		m.data = {"shape": g.shape_name()}
		events.append(m)
		for c in g.cells:
			if board.is_special(c.x, c.y) and not _queued(queue, c):
				queue.append(FireOrder.new(board.get_kind(c.x, c.y), board.get_color(c.x, c.y), c, false))
			board.clear_piece(c.x, c.y)
		var clear: BoardEvent = BoardEvent.new("clear")
		clear.cells = g.cells.duplicate()
		clear.source = "match"
		events.append(clear)
		BoardDamage.hit_by_match(board, g.cells, events)
		var kind: String = g.special_kind()
		if kind != "":
			var cell: Vector2i = _special_cell(g, from, to)
			var color: String = "" if kind == "orb" else g.color
			board.set_piece(cell.x, cell.y, kind, color)
			var made: BoardEvent = BoardEvent.new("special_created")
			made.cell = cell
			made.kind = kind
			made.color = color
			events.append(made)
	_fire_waiting(board, queue, events)


## Fires the swapped and matched specials one after another (IR-21, IR-39, IR-50). Owner decision
## OQ-44 (chat 27 Nov 2026): pieces fall and refill before each one fires, and the specials each
## one sets off fire after it (IR-41); cascade matches wait until all have fired.
## Open question OQ-54 (provisional): a swapped special still on the board falls with the other
## pieces and fires from where it lands; a matched special already left the board with its match.
static func _fire_waiting(board: BoardModel, queue: Array[FireOrder], events: Array[BoardEvent]) -> void:
	var scanned: int = events.size()
	for order in queue:
		BoardGravity.apply(board, events)
		scanned = _follow_falls(events, scanned, queue)
		var waiting: Array[FireOrder] = []
		SpecialFiring.fire(board, order, waiting, events)
		SpecialFiring.fire_set_offs(board, waiting, events)
		scanned = _follow_falls(events, scanned, queue)


## Moves the cell of every still-on-board order along the `fall` events after index `start`, so
## each special fires from where it landed. Returns the new end index.
static func _follow_falls(events: Array[BoardEvent], start: int, queue: Array[FireOrder]) -> int:
	for i in range(start, events.size()):
		if events[i].type != "fall":
			continue
		for m in events[i].data.get("moves", []):
			for o in queue:
				if o.on_board and o.cell == m["from"]:
					o.cell = m["to"]
					break
	return events.size()


static func _queued(queue: Array[FireOrder], cell: Vector2i) -> bool:
	for o in queue:
		if o.cell == cell:
			return true
	return false


## IR-40: a player's match puts its special on the swap's target cell; a cascade match on its lowest,
## then left-most cell (an L/T/+ on its crossing cell). Owner decision OQ-25: a player match that
## doesn't contain the target cell uses the cascade placement too. Open question OQ-57
## (provisional): if that cell is covered by an overlay that survived, the special is still placed
## there; it is locked for swaps and falls (IR-54) but can still be tapped.
static func _special_cell(g: MatchGroup, _from: Vector2i, to: Vector2i) -> Vector2i:
	if to != NO_CELL and g.has_cell(to):
		return to
	return g.cascade_cell()


## Falls, refills and cascade matches until nothing matches (IR-32). Also used between a
## Firecracker's two blasts (owner decision OQ-32). Never shuffles.
static func cascade(board: BoardModel, events: Array[BoardEvent]) -> void:
	for _guard in range(MAX_CASCADES):
		BoardGravity.apply(board, events)
		var groups: Array[MatchGroup] = MatchFinder.find_groups(board)
		if groups.is_empty():
			return
		_resolve_matches(board, groups, NO_CELL, NO_CELL, [] as Array[FireOrder], events)


## Cascades until stable, then the free shuffle if there is no possible move (IR-32, IR-33).
static func _stabilise(board: BoardModel, events: Array[BoardEvent]) -> void:
	cascade(board, events)
	if board.auto_shuffle and not has_possible_move(board):
		BoardShuffle.shuffle(board, events)
