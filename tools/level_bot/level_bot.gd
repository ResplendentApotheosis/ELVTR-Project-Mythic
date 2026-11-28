# Command line level bot: plays a level N times with LevelBot and writes the results as JSON.
# One level:  "$GODOT_BIN" --headless -s res://tools/level_bot/level_bot.gd -- levels/level_026.json --runs 500 --seed 1 [--out file]
# Several:    ... -- --levels 1-5 --jobs 5 [--dir levels] [--runs N] [--seed S] [--out folder]   (same seed for every level)
# Default out: reports/balance/level_NNN_bot.json. Prints one summary line per level; exit 0 (1 if an argument or a level is bad).
extends SceneTree


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.has("--levels"):
		quit(_run_levels(args))
		return
	if args.is_empty() or args[0].begins_with("--"):
		print("usage: -- <level path> --runs N --seed S [--out path]")
		print("   or: -- --levels 1-5 --jobs 5 [--dir path] [--runs N] [--seed S] [--out folder]")
		quit(1)
		return
	var path: String = _resolve(args[0])
	var runs: int = int(_option(args, "--runs", "500"))
	var seed_value: int = int(_option(args, "--seed", "1"))
	var problem: String = LevelBot.cannot_play(path, seed_value)
	if problem != "":
		print(problem)
		quit(1)
		return
	var report: Dictionary = LevelBot.run(path, maxi(runs, 1), seed_value)
	var out: String = _option(args, "--out", "res://reports/balance/level_%03d_bot.json" % int(report["level"]))
	if not _write(report, _resolve(out)):
		quit(1)
		return
	quit(0)


## --levels: every level in the range, `--jobs` at a time, each written to <out folder>/level_NNN_bot.json.
func _run_levels(args: PackedStringArray) -> int:
	var dir: String = _resolve(_option(args, "--dir", "res://levels"))
	var paths: Array[String] = LevelBot.level_paths(_option(args, "--levels", ""), dir)
	if paths.is_empty():
		print("--levels needs a level number or a range like 1-5")
		return 1
	var runs: int = maxi(int(_option(args, "--runs", "500")), 1)
	var seed_value: int = int(_option(args, "--seed", "1"))
	var jobs: int = maxi(int(_option(args, "--jobs", "1")), 1)
	var out_dir: String = _resolve(_option(args, "--out", "res://reports/balance"))
	var code: int = 0
	var reports: Array[Dictionary] = LevelBot.run_many(paths, runs, seed_value, jobs)
	for i in range(reports.size()):
		var report: Dictionary = reports[i]
		if report.has("error"):
			print("level %s: %s" % [paths[i].get_file().get_basename().trim_prefix("level_"), report["error"]])
			code = 1
			continue
		if not _write(report, out_dir.trim_suffix("/") + "/level_%03d_bot.json" % int(report["level"])):
			code = 1
	return code


## Writes the report as JSON and prints its summary line. False if the file can't be written.
func _write(report: Dictionary, out: String) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()))
	var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if f == null:
		print("cannot write %s" % out)
		return false
	f.store_string(JSON.stringify(report, "\t"))
	f.close()
	print("level %d (%s): %d/%d wins (%.1f%%), avg moves left on win %.2f, avg goal progress on fail %.2f -> %s" % [
		int(report["level"]), report["tier"], int(report["wins"]), int(report["runs"]),
		100.0 * float(report["win_rate"]), float(report["avg_moves_left_on_win"]),
		float(report["avg_goal_progress_on_fail"]), out])
	return true


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
