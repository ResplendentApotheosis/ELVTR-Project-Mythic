# Builds level dictionaries (the brief's section 5 schema) for the LevelLoader tests, and small board
# queries they share. Pure data, no LevelLoader calls. Check: tests/level_loader/test_fixture_sanity.gd.
extends RefCounted

const PLAN_PATH: String = "res://research/match-villains/levels_1_100_plan.csv"
const FRAGMENT_LEVELS: Array[int] = [26, 30, 33, 35, 38, 40, 45, 50]
const FOUR: Array[String] = ["R", "Y", "B", "G"]

static var _plan: Dictionary = {}


## Plan row for a level: {"tier": String, "moves": int}.
static func plan(id: int) -> Dictionary:
	if _plan.is_empty():
		var text: String = FileAccess.get_file_as_string(PLAN_PATH)
		for line in text.split("\n", false):
			var cols: PackedStringArray = line.split(",")
			if cols.size() > 4 and cols[0].is_valid_int():
				_plan[int(cols[0])] = {"tier": cols[2], "moves": int(cols[3])}
	return _plan.get(id, {"tier": "easy", "moves": 28})


static func rows(width: int, height: int, ch: String) -> Array:
	var out: Array = []
	for y in range(height):
		out.append(ch.repeat(width))
	return out


## Replaces one character of a row list (returns the new list).
static func with_char(grid: Array, x: int, y: int, ch: String) -> Array:
	var out: Array = grid.duplicate()
	var row: String = String(out[y])
	out[y] = row.substr(0, x) + ch + row.substr(x + 1)
	return out


## A loader-test level: 9x9, all playable, no underlay, no objects, no goals worth checking.
## The loader never validates, so this is not necessarily a valid level (see valid()).
static func level(id: int = 12, overrides: Dictionary = {}) -> Dictionary:
	var d: Dictionary = {
		"id": id, "chapter": 1 if id <= 25 else 2, "tier": "medium", "moves": 26, "colors": 4,
		"width": 9, "height": 9,
		"cells": rows(9, 9, "#"), "underlay": rows(9, 9, "."),
		"objects": [], "fixed_tiles": [],
		"spawn": {"drop_items": null, "generators": null},
		"goals": [{"obstacle": "OB02", "count": 1}],
		"story_beat": "intro" if id == 1 else ("mini" if id == 17 else null),
	}
	for k in overrides:
		d[k] = overrides[k]
	return d


## A level the validator must accept (plan tier and moves, goals sized to the tier, counts equal to what is
## placed). `overrides` replace whole keys. Fragment levels carry a marked OB07 cocoon (fragment goal in a slot).
static func valid(id: int, overrides: Dictionary = {}) -> Dictionary:
	var p: Dictionary = plan(id)
	var tier: String = String(p["tier"])
	var slots: int = {"intro": 1, "easy": 1, "medium": 2, "hard": 3, "finale": 4}[tier]
	var fragment: bool = FRAGMENT_LEVELS.has(id)
	var goals: Array = []
	var objects: Array = []
	var pool: Array = ["OB02"]
	if id >= 7:
		pool.append("OB03")
	if id >= 13:
		pool.append("OB06")
	if id >= 17:
		pool.append("OB07")
	var plain_slots: int = slots - (1 if fragment else 0)
	for i in range(plain_slots):
		match String(pool[i]):
			"OB02":
				goals.append({"obstacle": "OB02", "count": 3})
				for x in range(3):
					objects.append({"type": "OB02", "x": x, "y": 6, "hp": 2})
			"OB03":
				goals.append({"obstacle": "OB03", "count": 2})
				for x in range(4, 6):
					objects.append({"type": "OB03", "x": x, "y": 4, "hp": 1})
			"OB06":
				goals.append({"obstacle": "OB06", "count": 1})
				objects.append({"type": "OB06", "x": 7, "y": 0, "w": 1, "h": 3, "hp": 3})
			"OB07":
				goals.append({"obstacle": "OB07", "count": 2})
				objects.append({"type": "OB07", "x": 6, "y": 8, "hp": 1})
				objects.append({"type": "OB07", "x": 7, "y": 8, "hp": 1})
	var d: Dictionary = {
		"id": id, "chapter": 1 if id <= 25 else 2, "tier": tier, "moves": int(p["moves"]), "colors": 4,
		"width": 9, "height": 9, "cells": rows(9, 9, "#"), "underlay": rows(9, 9, "."),
		"objects": objects, "fixed_tiles": [], "spawn": {"drop_items": null, "generators": null},
		"goals": goals,
		"story_beat": "intro" if id == 1 else ("mini" if (tier == "hard" or id == 17) else ("chapter" if tier == "finale" else null)),
	}
	if fragment:
		d["fragment"] = {"guardian": "rat", "scripted": true}
		goals.append({"obstacle": "OB07", "count": 1, "fragment": true})
		objects.append({"type": "OB07", "x": 8, "y": 8, "hp": 1, "fragment": true})
	for k in overrides:
		d[k] = overrides[k]
	return d


## Valid level with an extra object entry appended.
static func valid_with(id: int, extra_object: Dictionary, overrides: Dictionary = {}) -> Dictionary:
	var d: Dictionary = valid(id, overrides)
	var objs: Array = (d["objects"] as Array).duplicate()
	objs.append(extra_object)
	d["objects"] = objs
	return d


## Replaces the OB03 moss / any object list: returns d with "objects" = list.
static func with_objects(d: Dictionary, list: Array) -> Dictionary:
	var out: Dictionary = d.duplicate()
	out["objects"] = list
	return out


# ---------------------------------------------------------------- board queries

## Number of plain pieces and of cells holding any piece kind.
static func count_kind(board: BoardModel, kind: String) -> int:
	var n: int = 0
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == kind:
				n += 1
	return n


## Distinct colours of plain pieces, as a Dictionary used as a set.
static func plain_colors(board: BoardModel) -> Dictionary:
	var out: Dictionary = {}
	for y in range(board.height):
		for x in range(board.width):
			if board.get_kind(x, y) == "plain":
				out[board.get_color(x, y)] = true
	return out


## How many different swaps (unordered neighbour pairs of plain, unlocked pieces) would make a match
## (3 in a line or a 2x2). Stops counting at `stop_at` (default: counts all).
static func swaps_that_match(board: BoardModel, stop_at: int = 1000000) -> int:
	var n: int = 0
	var BB: GDScript = load("res://tests/helpers/board_builder.gd")
	for y in range(board.height):
		for x in range(board.width):
			for d in [Vector2i(1, 0), Vector2i(0, 1)]:
				var a: Vector2i = Vector2i(x, y)
				var b: Vector2i = a + d
				if not _swappable(board, a) or not _swappable(board, b):
					continue
				board.swap_pieces(a, b)
				if BB.has_match(board):
					n += 1
				board.swap_pieces(a, b)
				if n >= stop_at:
					return n
	return n


static func _swappable(board: BoardModel, c: Vector2i) -> bool:
	return board.is_playable(c.x, c.y) and board.get_kind(c.x, c.y) == "plain" and not board.is_locked(c.x, c.y)


## First neighbour swap that makes a match: [from, to] or [] if none.
static func first_matching_swap(board: BoardModel) -> Array:
	var BB: GDScript = load("res://tests/helpers/board_builder.gd")
	for y in range(board.height):
		for x in range(board.width):
			for d in [Vector2i(1, 0), Vector2i(0, 1)]:
				var a: Vector2i = Vector2i(x, y)
				var b: Vector2i = a + d
				if not _swappable(board, a) or not _swappable(board, b):
					continue
				board.swap_pieces(a, b)
				var hit: bool = BB.has_match(board)
				board.swap_pieces(a, b)
				if hit:
					return [a, b]
	return []


## All cells where the board has a given drop item.
static func drops(board: BoardModel, item: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(board.height):
		for x in range(board.width):
			if board.get_drop_item(x, y) == item:
				out.append(Vector2i(x, y))
	return out


## Number of errors whose text starts with the IR id, e.g. count_ir(errors, "IR-64").
static func count_ir(errors: Array, ir: String) -> int:
	var n: int = 0
	for e in errors:
		if String(e).begins_with(ir):
			n += 1
	return n
