# Test helper: small queries over the Array[BoardEvent] a MatchResolver call returns.
# Contract: tests/API_CONTRACT.md (event types and fields). Pure logic, no scenes.
# Check: used by every resolver test.
extends RefCounted


static func of_type(events: Array, type: String) -> Array:
	var out: Array = []
	for e in events:
		if e.type == type:
			out.append(e)
	return out


static func count(events: Array, type: String) -> int:
	return of_type(events, type).size()


## Index in the event list of the nth (0-based) event of this type, or -1.
static func index_of(events: Array, type: String, nth: int = 0) -> int:
	var seen: int = 0
	for i in range(events.size()):
		if events[i].type == type:
			if seen == nth:
				return i
			seen += 1
	return -1


## Set (Dictionary Vector2i -> true) of every cell listed by "clear" events.
static func cleared(events: Array) -> Dictionary:
	var out: Dictionary = {}
	for e in events:
		if e.type == "clear":
			for c in e.cells:
				out[c] = true
	return out


## Total number of cells listed by "clear" events (a cell cleared twice counts twice).
static func cleared_total(events: Array) -> int:
	var n: int = 0
	for e in events:
		if e.type == "clear":
			n += e.cells.size()
	return n


## Set of every cell listed by "match" events.
static func matched(events: Array) -> Dictionary:
	var out: Dictionary = {}
	for e in events:
		if e.type == "match":
			for c in e.cells:
				out[c] = true
	return out


static func to_set(cells: Array) -> Dictionary:
	var out: Dictionary = {}
	for c in cells:
		out[c] = true
	return out


static func row_cells(y: int, w: int = 9) -> Array:
	var out: Array = []
	for x in range(w):
		out.append(Vector2i(x, y))
	return out


static func col_cells(x: int, h: int = 9) -> Array:
	var out: Array = []
	for y in range(h):
		out.append(Vector2i(x, y))
	return out


## Cells x0..x1, y0..y1 inclusive.
static func rect_cells(x0: int, y0: int, x1: int, y1: int) -> Array:
	var out: Array = []
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			out.append(Vector2i(x, y))
	return out


static func same_set(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for k in a:
		if not b.has(k):
			return false
	return true


## Rows/columns union helper: all cells in every given cell list.
static func union(lists: Array) -> Dictionary:
	var out: Dictionary = {}
	for l in lists:
		for c in l:
			out[c] = true
	return out


## The `cell` of every event of this type, in order (untyped Array of Vector2i).
static func cells_of(events: Array, type: String) -> Array:
	var out: Array = []
	for e in events:
		if e.type == type:
			out.append(e.cell)
	return out


## The `cell` of every blast event with this data.index (1 or 2), in order.
static func blast_centres(events: Array, index: int) -> Array:
	var out: Array = []
	for e in events:
		if e.type == "blast" and int(e.data.get("index", 0)) == index:
			out.append(e.cell)
	return out


## Index of the first event of this type after position `after`, or -1.
static func index_after(events: Array, type: String, after: int) -> int:
	for i in range(after + 1, events.size()):
		if events[i].type == type:
			return i
	return -1


## Index of the first `clear` event with the given source, or -1.
static func index_of_clear(events: Array, source: String) -> int:
	for i in range(events.size()):
		if events[i].type == "clear" and events[i].source == source:
			return i
	return -1


## Destination cell -> source cell for every move in one `fall` event (Dictionary Vector2i -> Vector2i).
static func fall_map(event: BoardEvent) -> Dictionary:
	var out: Dictionary = {}
	for m in event.data.get("moves", []):
		out[m["to"]] = m["from"]
	return out


## Number of events of this type between index `from_i` (exclusive) and `to_i` (exclusive).
static func count_between(events: Array, type: String, from_i: int, to_i: int) -> int:
	var n: int = 0
	for i in range(from_i + 1, mini(to_i, events.size())):
		if events[i].type == type:
			n += 1
	return n


## Event types of `events` that are in `wanted`, in order (to assert an exact event order).
static func sequence(events: Array, wanted: Array) -> Array:
	var out: Array = []
	for e in events:
		if wanted.has(e.type):
			out.append(e.type)
	return out
