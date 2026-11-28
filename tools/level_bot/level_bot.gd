# Command line level bot: plays a level N times with LevelBot and writes the results as JSON.
# Usage: "$GODOT_BIN" --headless -s res://tools/level_bot/level_bot.gd -- levels/level_026.json --runs 500 --seed 1
#        [--out path]   (default out: reports/balance/level_NNN_bot.json). Prints a one-line summary; exit 0
#        (1 if the arguments or the level file are bad).
extends SceneTree


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty() or args[0].begins_with("--"):
		print("usage: -- <level path> --runs N --seed S [--out path]")
		quit(1)
		return
	var path: String = _resolve(args[0])
	var runs: int = int(_option(args, "--runs", "500"))
	var seed_value: int = int(_option(args, "--seed", "1"))
	if LevelLoader.load_file(path, {"seed": seed_value}) == null:
		print("cannot play %s: %s" % [args[0], LevelLoader.last_errors if FileAccess.file_exists(path) else "file not found"])
		quit(1)
		return
	var report: Dictionary = LevelBot.run(path, maxi(runs, 1), seed_value)
	var out: String = _option(args, "--out", "res://reports/balance/level_%03d_bot.json" % int(report["level"]))
	out = _resolve(out)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()))
	var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if f == null:
		print("cannot write %s" % out)
		quit(1)
		return
	f.store_string(JSON.stringify(report, "\t"))
	f.close()
	print("level %d (%s): %d/%d wins (%.1f%%), avg moves left on win %.2f, avg goal progress on fail %.2f -> %s" % [
		int(report["level"]), report["tier"], int(report["wins"]), int(report["runs"]),
		100.0 * float(report["win_rate"]), float(report["avg_moves_left_on_win"]),
		float(report["avg_goal_progress_on_fail"]), out])
	quit(0)


## The value after `name` (e.g. "--runs 500"), or `fallback`.
func _option(args: PackedStringArray, name: String, fallback: String) -> String:
	var i: int = args.find(name)
	if i >= 0 and i + 1 < args.size():
		return args[i + 1]
	return fallback


## A relative path like levels/level_026.json is read from the project root (res://).
func _resolve(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://") or path.is_absolute_path():
		return path
	return "res://" + path
