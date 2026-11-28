# Turns the Array[BoardEvent] a move returned into a list of simple animation steps (plain Dictionaries),
# in the same order, each with its duration in seconds. Pure logic: no nodes, no tweens; AnimationQueue plays the steps.
# It also works out what each new piece looks like: a refill's colours come from the event (data.colors),
# a shuffle's (or an old event's without colours) are followed through to the final board.
# Check: GUT tests for AnimationSteps.build (test-engineer); F5 runs the greybox scene that plays them.
class_name AnimationSteps
extends RefCounted

# Durations in seconds. GDD › Feel, juice & sound › Visual timing gives swap 0.15, invalid swap 0.2,
# match clear 0.12, special created 0.25, Firecracker 0.2, and 0.15 between finale Rockets.
# The rest are greybox guesses (provisional) until the video frames are measured.
const SWAP: float = 0.15
const INVALID_SWAP: float = 0.2
const CLEAR: float = 0.12
const SPECIAL: float = 0.25
const BLAST: float = 0.2
const FINALE_GAP: float = 0.15
const FALL: float = 0.15          # provisional
const SPAWN: float = 0.15         # provisional
const FIRE: float = 0.15          # provisional: Rocket, Orb, combo and Crane flashes
const HIT: float = 0.1            # provisional
const OBSTACLE_GONE: float = 0.1  # provisional
const COLLECT: float = 0.25       # provisional (the GDD's collect ring is 250-300 ms)
const SHUFFLE: float = 0.3        # provisional

## A new piece whose colour can't be known from the events (it was refilled, then destroyed by a special
## before the move ended). The view draws it as a grey "?".
const UNKNOWN_LOOK: Dictionary = {"kind": "plain", "color": "?", "item": ""}

const FIRE_EVENTS: Array[String] = ["rocket_fire", "orb_fire", "combo", "crane_target", "crane_takeoff", "crane_landing"]


## The steps for one list of events. `before` = BoardSnapshot.piece_grid(board) taken BEFORE the move;
## `after` = the board after the move (used to colour new pieces that are still there at the end).
## Step types: swap, invalid_swap, clear, special, fall, spawn, fire, hit, obstacle_cleared, collect,
## shuffle, wait, goal_done, outcome, and a final sync (the view then matches the real board exactly).
static func build(events: Array[BoardEvent], before: Dictionary, after: BoardModel) -> Array[Dictionary]:
	var new_pieces: Dictionary = new_piece_looks(events, before, after)
	var steps: Array[Dictionary] = []
	for i in range(events.size()):
		var e: BoardEvent = events[i]
		match e.type:
			"swap":
				steps.append({"type": "swap", "from": e.cells[0], "to": e.cells[1], "duration": SWAP})
			"invalid_swap":
				steps.append({"type": "invalid_swap", "from": e.cells[0], "to": e.cells[1], "duration": INVALID_SWAP})
			"clear":
				steps.append({"type": "clear", "cells": e.cells.duplicate(), "duration": CLEAR})
			"special_created":
				if bool(e.data.get("finale", false)):
					steps.append({"type": "wait", "duration": FINALE_GAP})
				var look: Dictionary = {"kind": e.kind, "color": e.color, "item": ""}
				steps.append({"type": "special", "cell": e.cell, "look": look, "duration": SPECIAL})
			"fall":
				steps.append({"type": "fall", "moves": (e.data.get("moves", []) as Array).duplicate(true), "duration": FALL})
			"refill":
				steps.append({"type": "spawn", "pieces": new_pieces.get(i, []), "duration": SPAWN})
			"blast":
				steps.append({"type": "fire", "name": e.type, "cell": e.cell, "cells": e.cells.duplicate(), "duration": BLAST})
			"hit":
				steps.append({"type": "hit", "cell": e.cell, "layer": String(e.data.get("layer", "")),
					"id": String(e.data.get("id", "")), "hp": int(e.data.get("hp", 0)), "duration": HIT})
			"obstacle_cleared":
				steps.append({"type": "obstacle_cleared", "cell": e.cell, "id": String(e.data.get("id", "")), "duration": OBSTACLE_GONE})
			"shrine_lit":
				steps.append({"type": "obstacle_cleared", "cell": e.cell, "id": "OB05", "duration": OBSTACLE_GONE})
			"collected":
				steps.append({"type": "collect", "cell": e.cell, "item": String(e.data.get("item", "")), "duration": COLLECT})
			"shuffle":
				steps.append({"type": "shuffle", "pieces": new_pieces.get(i, []), "duration": SHUFFLE})
			"goal_done":
				# No time of its own: the HUD marks the goal done at once while later steps still play (IR-56).
				steps.append({"type": "goal_done", "goal": int(e.data.get("goal", -1)), "id": String(e.data.get("id", "")),
					"fragment": bool(e.data.get("fragment", false)), "duration": 0.0})
			"win", "fail":
				steps.append({"type": "outcome", "name": e.type, "data": e.data.duplicate(), "duration": 0.0})
			_:
				if FIRE_EVENTS.has(e.type):
					var cells: Array[Vector2i] = e.cells.duplicate()
					if cells.is_empty() and e.cell != Vector2i(-1, -1):
						cells.append(e.cell)
					steps.append({"type": "fire", "name": e.type, "cell": e.cell, "cells": cells, "duration": FIRE})
				# Anything else ("match", whose "clear" follows; "booster"; new types) has no step.
	steps.append({"type": "sync", "duration": 0.0})
	return steps


## Total seconds of a step list (handy for tests and for timing the HUD).
static func total_duration(steps: Array[Dictionary]) -> float:
	var t: float = 0.0
	for s in steps:
		t += float(s.get("duration", 0.0))
	return t


## For each "refill" and "shuffle" event (by index): [{"cell": Vector2i, "look": Dictionary}, ...].
## Follows every piece through the events. A new piece still on the board at the end gets the look of
## its final cell on `after`; one matched away gets the match's colour; otherwise UNKNOWN_LOOK.
## A refill event that lists its colours (data.colors, parallel to cells) gives each new piece that colour.
static func new_piece_looks(events: Array[BoardEvent], before: Dictionary, after: BoardModel) -> Dictionary:
	var grid: Dictionary = {}     # cell -> piece number
	var looks: Dictionary = {}    # piece number -> look, once known
	var next_id: int = 0
	for cell in before:
		next_id += 1
		grid[cell] = next_id
		looks[next_id] = before[cell]
	var placed: Dictionary = {}   # event index -> [[cell, piece number], ...]
	for i in range(events.size()):
		var e: BoardEvent = events[i]
		match e.type:
			"swap":
				_swap_cells(grid, e.cells[0], e.cells[1])
			"match", "orb_fire":
				for c in e.cells:
					if grid.has(c) and not looks.has(grid[c]):
						looks[grid[c]] = {"kind": "plain", "color": e.color, "item": ""}
			"clear":
				for c in e.cells:
					grid.erase(c)
			"collected":
				grid.erase(e.cell)
			"special_created":
				next_id += 1
				grid[e.cell] = next_id
				looks[next_id] = {"kind": e.kind, "color": e.color, "item": ""}
			"fall":
				apply_fall(grid, e.data.get("moves", []) as Array)
			"refill", "shuffle":
				var colors: Array = e.data.get("colors", []) as Array if e.type == "refill" else []
				var has_colors: bool = colors.size() == e.cells.size()
				var list: Array = []
				for k in range(e.cells.size()):
					var c: Vector2i = e.cells[k]
					next_id += 1
					grid[c] = next_id
					if has_colors:
						looks[next_id] = {"kind": "plain", "color": String(colors[k]), "item": ""}
					list.append([c, next_id])
				placed[i] = list
	for cell in grid:
		if not looks.has(grid[cell]):
			looks[grid[cell]] = BoardSnapshot.look_at(after, cell)
	var out: Dictionary = {}
	for i in placed:
		var pieces: Array = []
		for pair in placed[i]:
			pieces.append({"cell": pair[0], "look": looks.get(pair[1], UNKNOWN_LOOK)})
		out[i] = pieces
	return out


## Applies a fall's {"from", "to"} moves one after another, in the order listed (the order the board
## moved them; a piece may fall and then slide in the same event). Something still sitting in a "to"
## cell is replaced (e.g. a special lifted off the board by a match).
static func apply_fall(grid: Dictionary, moves: Array) -> void:
	for m in moves:
		var from: Vector2i = m["from"]
		if grid.has(from):
			grid[m["to"]] = grid[from]
			grid.erase(from)


static func _swap_cells(grid: Dictionary, a: Vector2i, b: Vector2i) -> void:
	var va: Variant = grid.get(a)
	var vb: Variant = grid.get(b)
	grid.erase(a)
	grid.erase(b)
	if vb != null:
		grid[a] = vb
	if va != null:
		grid[b] = va
