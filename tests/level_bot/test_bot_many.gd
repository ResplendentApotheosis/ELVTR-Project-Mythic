# GUT tests: running several levels at once: LevelBot.level_paths, LevelBot.run_many (same results whatever the
# number of jobs) and the CLI `--levels 1-3 --jobs 2`. Small fixture levels level_001..003.json are used.
# Rules touched: none. API: API_CONTRACT.md 16.4. Check: run the GUT suite (the CLI test needs GODOT_BIN).
extends GutTest

const BOT_PATH: String = "res://tools/level_bot/bot_runner.gd"
const CLI_PATH: String = "res://tools/level_bot/level_bot.gd"
const FIX_DIR: String = "res://tests/level_bot/fixtures"
const SEED: int = 4

var _scratch_dirs: Array[String] = []


func after_each() -> void:
	for d in _scratch_dirs:
		var dir: DirAccess = DirAccess.open(d)
		if dir != null:
			for f in dir.get_files():
				DirAccess.remove_absolute(ProjectSettings.globalize_path(d + "/" + f))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(d))
	_scratch_dirs.clear()


func _bot() -> GDScript:
	var script: GDScript = load(BOT_PATH)
	for m in ["level_paths", "run_many"]:
		if not script.has_script_method(m):
			fail_test("LevelBot.%s is missing (API_CONTRACT.md 16.4)" % m)
			return null
	return script


func _fixture_paths() -> Array[String]:
	return [FIX_DIR + "/level_001.json", FIX_DIR + "/level_002.json", FIX_DIR + "/level_003.json"]


func _godot() -> String:
	return OS.get_environment("GODOT_BIN")


# ---------------------------------------------------------------- level_paths

func test_level_paths_range_gives_numbered_files_in_order() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var p: Array = bot.call("level_paths", "1-5")
	assert_eq(p, ["res://levels/level_001.json", "res://levels/level_002.json", "res://levels/level_003.json",
		"res://levels/level_004.json", "res://levels/level_005.json"])


func test_level_paths_single_level() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	assert_eq(bot.call("level_paths", "7"), ["res://levels/level_007.json"])


func test_level_paths_uses_the_given_dir() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	assert_eq(bot.call("level_paths", "2-3", FIX_DIR), [FIX_DIR + "/level_002.json", FIX_DIR + "/level_003.json"])


func test_level_paths_bad_text_gives_nothing() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	for text in ["", "abc", "1-x", "x-3", "1-2-3", "-"]:
		assert_eq((bot.call("level_paths", text) as Array).size(), 0, "'%s' gives no paths" % text)


# ---------------------------------------------------------------- run_many

func test_run_many_gives_one_run_dict_per_path_in_order() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var out: Array = bot.call("run_many", _fixture_paths(), 2, SEED, 1)
	assert_eq(out.size(), 3)
	for i in range(3):
		var d: Dictionary = out[i]
		assert_eq(int(d["level"]), i + 1, "path order kept")
		assert_eq(int(d["runs"]), 2)
		assert_eq(int(d["seed"]), SEED, "every level uses the same seed")


func test_run_many_each_level_equals_a_plain_run_with_the_same_seed() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var paths: Array[String] = _fixture_paths()
	var out: Array = bot.call("run_many", paths, 2, SEED, 1)
	for i in range(paths.size()):
		assert_eq(JSON.parse_string(JSON.stringify(out[i])),
			JSON.parse_string(JSON.stringify(LevelBot.run(paths[i], 2, SEED))), paths[i])


func test_run_many_result_does_not_depend_on_jobs() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var one: Array = bot.call("run_many", _fixture_paths(), 2, SEED, 1)
	var two: Array = bot.call("run_many", _fixture_paths(), 2, SEED, 2)
	var many: Array = bot.call("run_many", _fixture_paths(), 2, SEED, 8)
	assert_eq(JSON.stringify(two), JSON.stringify(one), "jobs 2 equals jobs 1")
	assert_eq(JSON.stringify(many), JSON.stringify(one), "jobs 8 equals jobs 1")


func test_run_many_missing_level_gives_an_error_entry() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var paths: Array[String] = [FIX_DIR + "/level_001.json", FIX_DIR + "/level_099.json"]
	var out: Array = bot.call("run_many", paths, 1, SEED, 2)
	assert_eq(out.size(), 2)
	assert_false((out[0] as Dictionary).has("error"))
	assert_true((out[1] as Dictionary).has("error"), "the missing level says why")
	assert_ne(String((out[1] as Dictionary)["error"]), "")


func test_run_many_no_paths_gives_no_results() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var none: Array[String] = []
	assert_eq((bot.call("run_many", none, 1, SEED, 2) as Array).size(), 0)


# ---------------------------------------------------------------- CLI

func test_cli_levels_with_jobs_writes_one_report_per_level_and_a_line_each() -> void:
	if _godot() == "" or not FileAccess.file_exists(CLI_PATH):
		pending("GODOT_BIN not set or CLI missing")
		return
	var out_dir: String = "user://zf_bot_many_%d" % Time.get_ticks_usec()
	_scratch_dirs.append(out_dir)
	var output: Array = []
	var args: PackedStringArray = [
		"--headless", "--path", ProjectSettings.globalize_path("res://"), "-s", CLI_PATH, "--",
		"--levels", "1-3", "--jobs", "2", "--runs", "2", "--seed", str(SEED),
		"--dir", ProjectSettings.globalize_path(FIX_DIR), "--out", ProjectSettings.globalize_path(out_dir),
	]
	assert_eq(OS.execute(_godot(), args, output, true), 0)
	var expected: Array[String] = _fixture_paths()
	for i in range(3):
		var report: String = out_dir + "/level_%03d_bot.json" % (i + 1)
		assert_true(FileAccess.file_exists(report), "report for level %d" % (i + 1))
		var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(report))
		assert_true(d is Dictionary)
		assert_eq(int((d as Dictionary).get("level", 0)), i + 1)
		assert_eq(int((d as Dictionary).get("seed", 0)), SEED, "same seed for every level")
		assert_eq(JSON.stringify(d), JSON.stringify(JSON.parse_string(JSON.stringify(LevelBot.run(expected[i], 2, SEED)))),
			"same numbers as a plain run")
	var text: String = "\n".join(PackedStringArray(output))
	for n in ["level 1 ", "level 2 ", "level 3 "]:
		assert_true(text.contains(n), "a summary line for '%s'" % n.strip_edges())
