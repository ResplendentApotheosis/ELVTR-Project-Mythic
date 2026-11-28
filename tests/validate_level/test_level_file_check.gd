# GUT tests for LevelFileCheck (tools/validate_level/level_file_check.gd): one String per failed check on a level
# file, [] = pass. It must use the real LevelLoader.validate (IR-63..77) and match file name NNN to the level id.
# Rules touched: IR-63 to IR-77 (through the real validator). API: tests/API_CONTRACT.md 15.2.
# Check: run the GUT suite. The CLI test runs only when the GODOT_BIN environment variable is set.
extends GutTest

const CHECK_PATH: String = "res://tools/validate_level/level_file_check.gd"
const CLI_PATH: String = "res://tools/validate_level/validate_level.gd"
const LF = preload("res://tests/level_loader/level_fixtures.gd")   # LF.valid(12) is a level the real validator accepts

var _dir: String = ""


func before_each() -> void:
	_dir = "user://zf_check_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_dir))


func after_each() -> void:
	var d: DirAccess = DirAccess.open(_dir)
	if d != null:
		for f in d.get_files():
			d.remove(f)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_dir))


## Writes `text` to <dir>/<name> and returns the path.
func _write(name: String, text: String) -> String:
	var p: String = _dir + "/" + name
	var f: FileAccess = FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	return p


func _fixture_dict(overrides: Dictionary = {}) -> Dictionary:
	var d: Dictionary = LF.valid(12)
	for k in overrides:
		d[k] = overrides[k]
	return d


func _check(path: String) -> Array:
	if not ResourceLoader.exists(CHECK_PATH):
		fail_test("LevelFileCheck missing: " + CHECK_PATH + " (API_CONTRACT.md 15.2)")
		return ["(missing)"]
	var script: GDScript = load(CHECK_PATH)
	if not script.has_script_method("check"):
		fail_test("LevelFileCheck.check(path) is missing")
		return ["(missing)"]
	return script.call("check", path)


func test_valid_level_file_passes() -> void:
	var p: String = _write("level_012.json", JSON.stringify(_fixture_dict()))
	assert_eq(_check(p), [], "a valid level with a matching file name has no failed checks")


func test_missing_file_fails() -> void:
	var r: Array = _check(_dir + "/level_012.json")
	assert_false(r.is_empty())
	assert_true(r[0] is String)


func test_file_that_is_not_json_fails() -> void:
	var r: Array = _check(_write("level_012.json", "this is { not json"))
	assert_false(r.is_empty())


func test_json_that_is_not_an_object_fails() -> void:
	var r: Array = _check(_write("level_012.json", "[1, 2, 3]"))
	assert_false(r.is_empty())


func test_file_name_number_must_match_the_level_id() -> void:
	var r: Array = _check(_write("level_013.json", JSON.stringify(_fixture_dict())))
	assert_false(r.is_empty(), "id 12 in level_013.json")
	var mentions: bool = false
	for s in r:
		if String(s).contains("13") or String(s).contains("12"):
			mentions = true
	assert_true(mentions, "the message names the two numbers: %s" % [r])


func test_a_file_name_without_a_number_fails() -> void:
	var r: Array = _check(_write("my_level.json", JSON.stringify(_fixture_dict())))
	assert_false(r.is_empty())


func test_invalid_level_reports_the_real_validators_errors() -> void:
	var level: Dictionary = _fixture_dict({"moves": 0})
	var expected: Array = LevelLoader.validate(level, 12)
	assert_false(expected.is_empty(), "the real validator rejects moves 0")
	var r: Array = _check(_write("level_012.json", JSON.stringify(level)))
	assert_gte(r.size(), expected.size())
	for e in expected:
		assert_true(r.has(String(e)) or _contains_text(r, String(e)), "reports: %s" % e)


func test_each_failed_check_is_its_own_string() -> void:
	var level: Dictionary = _fixture_dict({"moves": 0})
	var one: Array = _check(_write("level_012.json", JSON.stringify(level)))
	var two: Array = _check(_write("level_013.json", JSON.stringify(level)))
	assert_gt(two.size(), one.size(), "the wrong file name adds a failed check")
	for s in two:
		assert_true(s is String)


func test_result_is_a_typed_list_of_strings() -> void:
	var p: String = _write("level_012.json", JSON.stringify(_fixture_dict({"moves": 0})))
	var r: Array = _check(p)
	for s in r:
		assert_true(typeof(s) == TYPE_STRING)


func _contains_text(list: Array, text: String) -> bool:
	for s in list:
		if String(s).contains(text):
			return true
	return false


# ---------------------------------------------------------------- CLI (OS.execute)

func _godot() -> String:
	return OS.get_environment("GODOT_BIN")


func _run_cli(level_path: String) -> int:
	var out: Array = []
	var args: PackedStringArray = [
		"--headless", "--path", ProjectSettings.globalize_path("res://"),
		"-s", CLI_PATH, "--", ProjectSettings.globalize_path(level_path),
	]
	return OS.execute(_godot(), args, out, true)


func test_cli_script_exists() -> void:
	assert_true(FileAccess.file_exists(CLI_PATH), "CLI missing: " + CLI_PATH)


func test_cli_exit_codes() -> void:
	if _godot() == "" or not FileAccess.file_exists(CLI_PATH):
		pending("GODOT_BIN not set or CLI missing")
		return
	var ok: String = _write("level_012.json", JSON.stringify(_fixture_dict()))
	assert_eq(_run_cli(ok), 0, "a valid file exits 0")
	var bad: String = _write("level_013.json", JSON.stringify(_fixture_dict({"moves": 0})))
	assert_eq(_run_cli(bad), 1, "a failing file exits 1")
	assert_eq(_run_cli(_dir + "/level_099.json"), 1, "a missing file exits 1")
