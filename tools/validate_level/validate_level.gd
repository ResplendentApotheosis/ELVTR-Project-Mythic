# Command line level validator: prints one line per failed check, exits 0 on pass and 1 on fail.
# Usage: "$GODOT_BIN" --headless -s res://tools/validate_level/validate_level.gd -- levels/level_026.json
# The checks themselves live in LevelFileCheck (which calls the real LevelLoader.validate).
extends SceneTree


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		print("usage: -- <level path>")
		quit(1)
		return
	var path: String = _resolve(args[0])
	var errors: Array[String] = LevelFileCheck.check(path)
	for e in errors:
		print(e)
	if errors.is_empty():
		print("PASS %s" % args[0])
		quit(0)
	else:
		print("FAIL %s (%d failed checks)" % [args[0], errors.size()])
		quit(1)


## A relative path like levels/level_026.json is read from the project root (res://).
func _resolve(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://") or path.is_absolute_path():
		return path
	return "res://" + path
