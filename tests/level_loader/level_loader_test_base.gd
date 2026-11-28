# Base class for the LevelLoader tests. Loads LevelLoader by path, so a missing class FAILS a test with a
# clear message instead of breaking the whole script. Contract: tests/API_CONTRACT.md section 11.
# Check: run the GUT suite; tests/level_loader/ shows the results.
extends GutTest

const BB := preload("res://tests/helpers/board_builder.gd")
const EV := preload("res://tests/helpers/event_utils.gd")
const LF := preload("res://tests/level_loader/level_fixtures.gd")
const LOADER_PATH: String = "res://src/game/level_loader.gd"


func _loader() -> Variant:
	if not ResourceLoader.exists(LOADER_PATH):
		fail_test("LevelLoader missing: " + LOADER_PATH + " (API_CONTRACT.md section 11)")
		return null
	return load(LOADER_PATH)


func _call(fn: String, args: Array) -> Variant:
	var script: Variant = _loader()
	if script == null:
		return null
	if not script.has_method(fn):
		fail_test("LevelLoader.%s() is missing (API_CONTRACT.md section 11)" % fn)
		return null
	return script.callv(fn, args)


## Loads a level dictionary; returns the LevelAttempt (Variant) or null (and a failed test).
func load_attempt(level: Dictionary, options: Dictionary = {}) -> Variant:
	var a: Variant = _call("load_level", [level, options])
	if a == null:
		fail_test("LevelLoader.load_level returned null")
	return a


func load_file(path: String, options: Dictionary = {}) -> Variant:
	var a: Variant = _call("load_file", [path, options])
	if a == null:
		fail_test("LevelLoader.load_file returned null for " + path)
	return a


func retry(previous: Variant, options: Dictionary = {}) -> Variant:
	var a: Variant = _call("retry", [previous, options])
	if a == null:
		fail_test("LevelLoader.retry returned null")
	return a


## validate() result as an Array, or null (and a failed test) when the function is missing.
func errors_of(level: Dictionary, file_id: int = -1) -> Variant:
	var e: Variant = _call("validate", [level, file_id])
	if e == null:
		fail_test("LevelLoader.validate returned null")
	return e


## Calls a method on a Variant object, failing the test (instead of crashing it) if it is missing.
func vcall(obj: Variant, fn: String, args: Array = []) -> Variant:
	if obj == null or not obj.has_method(fn):
		fail_test("%s.%s() is missing (API_CONTRACT.md section 11.3)" % [obj, fn])
		return null
	return obj.callv(fn, args)


## Reads a property of a Variant object, failing the test if it is missing.
func vget(obj: Variant, prop: String) -> Variant:
	var v: Variant = obj.get(prop)
	if v == null:
		fail_test("property %s is missing (API_CONTRACT.md section 11)" % prop)
	return v


## Passes if the level is valid; reports the errors otherwise.
func expect_valid(level: Dictionary, why: String, file_id: int = -1) -> void:
	var e: Variant = errors_of(level, file_id)
	if e == null:
		return
	assert_eq(e, [], why + " (expected no errors)")


## Passes if some error starts with one of the IR ids (a plain String or an Array of Strings).
func expect_rejected(level: Dictionary, ir: Variant, why: String, file_id: int = -1) -> void:
	var e: Variant = errors_of(level, file_id)
	if e == null:
		return
	var tags: Array = ir if ir is Array else [ir]
	var hit: int = 0
	for t in tags:
		hit += LF.count_ir(e, String(t))
	assert_gt(hit, 0, "%s (expected an error starting with %s, got %s)" % [why, tags, e])


## Passes if the validator reports at least one error of any kind.
func expect_any_error(level: Dictionary, why: String) -> void:
	var e: Variant = errors_of(level)
	if e == null:
		return
	assert_gt((e as Array).size(), 0, why + " (expected at least one error)")


func no_match_and_three_swaps(board: BoardModel, label: String) -> void:
	assert_false(BB.has_match(board), label + ": no match on the starting board")
	assert_gte(LF.swaps_that_match(board, 3), 3, label + ": at least 3 swaps make a match")
