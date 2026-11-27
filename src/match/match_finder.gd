# Finds matches: 3+ same-colour pieces in a row or column, and 2x2 squares (IR-03, IR-04),
# joined into one MatchGroup when they share cells. Coloured specials match too; the Orb never (IR-50).
# Check: test_matches_and_specials_creation.gd.
class_name MatchFinder
extends RefCounted


## Colour a cell offers for matching, or "" (empty, Orb, drop item, blocked).
static func match_color(board: BoardModel, x: int, y: int) -> String:
	var kind: String = board.get_kind(x, y)
	if kind == "" or kind == "orb" or kind == "drop":
		return ""
	return board.get_color(x, y)


## Every match on the board, in reading order of their first shape.
static func find_groups(board: BoardModel) -> Array[MatchGroup]:
	var shapes: Array = []        # each: {"color": String, "type": "h"/"v"/"sq", "cells": Array[Vector2i]}
	# Row lines
	for y in range(board.height):
		var x: int = 0
		while x < board.width:
			var c: String = match_color(board, x, y)
			var end: int = x + 1
			while c != "" and end < board.width and match_color(board, end, y) == c:
				end += 1
			if c != "" and end - x >= 3:
				var run: Array[Vector2i] = []
				for i in range(x, end):
					run.append(Vector2i(i, y))
				shapes.append({"color": c, "type": "h", "cells": run})
			x = end
	# Column lines
	for x in range(board.width):
		var y: int = 0
		while y < board.height:
			var c: String = match_color(board, x, y)
			var end: int = y + 1
			while c != "" and end < board.height and match_color(board, x, end) == c:
				end += 1
			if c != "" and end - y >= 3:
				var run: Array[Vector2i] = []
				for i in range(y, end):
					run.append(Vector2i(x, i))
				shapes.append({"color": c, "type": "v", "cells": run})
			y = end
	# 2x2 squares
	for y in range(board.height - 1):
		for x in range(board.width - 1):
			var c: String = match_color(board, x, y)
			if c != "" and match_color(board, x + 1, y) == c and match_color(board, x, y + 1) == c and match_color(board, x + 1, y + 1) == c:
				var sq: Array[Vector2i] = [Vector2i(x, y), Vector2i(x + 1, y), Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]
				shapes.append({"color": c, "type": "sq", "cells": sq})
	return _join(shapes)


## True if the piece at this cell is part of any line of 3 or 2x2 square.
static func has_match_at(board: BoardModel, cell: Vector2i) -> bool:
	var c: String = match_color(board, cell.x, cell.y)
	if c == "":
		return false
	return would_match(board, cell, c)


## True if a piece of `color` at `cell` would complete a line of 3 or a 2x2 with pieces already there.
static func would_match(board: BoardModel, cell: Vector2i, color: String) -> bool:
	var x: int = cell.x
	var y: int = cell.y
	var left: int = _count(board, cell, Vector2i.LEFT, color)
	var right: int = _count(board, cell, Vector2i.RIGHT, color)
	if left + right >= 2:
		return true
	var up: int = _count(board, cell, Vector2i.UP, color)
	var down: int = _count(board, cell, Vector2i.DOWN, color)
	if up + down >= 2:
		return true
	for d in [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
		if match_color(board, x + d.x, y) == color and match_color(board, x, y + d.y) == color and match_color(board, x + d.x, y + d.y) == color:
			return true
	return false


static func _count(board: BoardModel, cell: Vector2i, step: Vector2i, color: String) -> int:
	var n: int = 0
	var p: Vector2i = cell + step
	while match_color(board, p.x, p.y) == color:
		n += 1
		p += step
	return n


## Joins shapes of one colour that share a cell into one MatchGroup.
static func _join(shapes: Array) -> Array[MatchGroup]:
	var group_of: Array[int] = []
	for i in range(shapes.size()):
		group_of.append(i)
	for i in range(shapes.size()):
		for j in range(i + 1, shapes.size()):
			if shapes[i]["color"] != shapes[j]["color"]:
				continue
			if _share_cell(shapes[i]["cells"], shapes[j]["cells"]):
				var a: int = _root(group_of, i)
				var b: int = _root(group_of, j)
				if a != b:
					group_of[maxi(a, b)] = mini(a, b)
	var by_root: Dictionary = {}
	var out: Array[MatchGroup] = []
	for i in range(shapes.size()):
		var r: int = _root(group_of, i)
		if not by_root.has(r):
			var g: MatchGroup = MatchGroup.new()
			g.color = shapes[i]["color"]
			by_root[r] = g
			out.append(g)
		var group: MatchGroup = by_root[r]
		var shape_cells: Array[Vector2i] = shapes[i]["cells"]
		for c in shape_cells:
			if not group.cells.has(c):
				group.cells.append(c)
		match String(shapes[i]["type"]):
			"h": group.h_runs.append(shape_cells)
			"v": group.v_runs.append(shape_cells)
			"sq": group.squares.append(shape_cells)
	return out


static func _root(group_of: Array[int], i: int) -> int:
	while group_of[i] != i:
		i = group_of[i]
	return i


static func _share_cell(a: Array[Vector2i], b: Array[Vector2i]) -> bool:
	for c in a:
		if b.has(c):
			return true
	return false
