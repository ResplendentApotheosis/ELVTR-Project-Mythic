# Validator checks for the optional `tutorial` swap hint of a level file (IR-89).
# Does NOT check that the swap makes the taught special (OQ-98, provisional). Errors start with "IR-89: ".
# Check: tests/level_loader/test_tutorial_ir89.gd.
class_name LevelTutorialChecks
extends RefCounted

const TEACH: Array[String] = ["rocket", "firecracker", "crane", "orb"]


static func check(level: Dictionary, shape_ok: bool, errors: Array) -> void:
	var field: Variant = level.get("tutorial")
	if field == null:
		return
	if not field is Dictionary:
		errors.append("IR-89: tutorial must be null or an object")
		return
	var tut: Dictionary = field
	if not TEACH.has(str(tut.get("teach", ""))) or not tut.get("teach") is String:
		errors.append("IR-89: tutorial.teach must be one of %s, found %s" % [TEACH, tut.get("teach")])
	var cells: Variant = tut.get("hint_cells")
	if not cells is Array or (cells as Array).size() != 2:
		errors.append("IR-89: tutorial.hint_cells must be exactly 2 cells")
		return
	var points: Array[Vector2i] = []
	for c in cells:
		if not c is Array or (c as Array).size() != 2 or not _is_number(c[0]) or not _is_number(c[1]):
			errors.append("IR-89: each hint cell must be a pair of numbers [x, y]")
			return
		points.append(Vector2i(LevelLoader.as_int(c[0]), LevelLoader.as_int(c[1])))
	var gap: Vector2i = (points[0] - points[1]).abs()
	if gap.x + gap.y != 1:
		errors.append("IR-89: the two hint cells must be different, orthogonal neighbours")
	if not shape_ok:
		return
	var board: BoardModel = LevelLoader.build_layers(level, 1)
	for p in points:
		if p.x < 0 or p.y < 0 or p.x >= board.width or p.y >= board.height:
			errors.append("IR-89: hint cell (%d,%d) is outside the board" % [p.x, p.y])
		elif not board.is_playable(p.x, p.y):
			errors.append("IR-89: hint cell (%d,%d) is not a playable cell" % [p.x, p.y])
		elif board.get_content(p.x, p.y) != null:
			errors.append("IR-89: hint cell (%d,%d) holds an obstacle, not a plain piece" % [p.x, p.y])


static func _is_number(v: Variant) -> bool:
	return v is int or v is float
