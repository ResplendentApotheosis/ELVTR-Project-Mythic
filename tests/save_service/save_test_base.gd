# Base class for the SaveService tests: loads SaveService by path (a missing class or method FAILS the test
# with a clear message), gives a fake clock, a temp save file and short helpers. Contract: tests/API_CONTRACT.md
# section 12. Check: run the GUT suite; tests/save_service/ shows the results.
extends "res://tests/helpers/goal_test_base.gd"

const SAVE_SCRIPT: String = "res://src/game/save_service.gd"
const T0: int = 1700000000   # "T" in the spec's timelines (unix seconds)

# The GDD's prices and unlock levels, written once here (spec section K: "tests read them from one place").
const START_COINS: int = 500
const MAX_LIVES: int = 5
const BUY_LIVES_PRICE: int = 150
const FRAGMENT_LEVELS: Array = [26, 30, 33, 35, 38, 40, 45, 50]
const BEAT_LEVELS: Array = [1, 15, 17, 20, 25, 30, 35, 40, 45, 50]
const HERO: Dictionary = {
	"hoof_tap": {"level": 11, "free": 3, "price": 100},
	"tail_slam": {"level": 23, "free": 2, "price": 200},
	"bamboo_dash": {"level": 29, "free": 2, "price": 150},
	"feather_fan": {"level": 36, "free": 2, "price": 100},
}
const REQUIRED_METHODS: Array = [
	"next_level", "can_start", "start_attempt", "sync_attempt", "end_attempt", "coins", "lives",
	"unlimited_lives_active", "buy_all_lives", "retry_choices", "streak", "chest_waiting", "fragments",
	"restored", "hero_unlocked", "hero_free_uses", "use_hero_booster", "pre_boosters_unlocked",
	"pre_free_uses", "attempt_log", "life_log", "should_play_story_beat", "mark_story_beat_seen",
	"seen_story_beats", "debug_set",
]


class FakeClock:
	extends RefCounted
	var now: int = 0

	func read() -> int:
		return now


var clock: FakeClock
var _file: String = ""


func before_each() -> void:
	clock = FakeClock.new()
	clock.now = T0
	_file = "user://zf_test_save_%d.json" % Time.get_ticks_usec()


func after_each() -> void:
	for f in [_file, _file + ".tmp", _file + ".bak"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


## Sets the fake clock to T + minutes.
func at(minutes: int) -> void:
	clock.now = T0 + minutes * 60


## Opens the save file (new if it does not exist). Calling it again = "the game was closed and opened":
## a brand-new SaveService reads the same file. Null (and a failed test) if the class or a method is missing.
func open_save() -> Variant:
	if not ResourceLoader.exists(SAVE_SCRIPT):
		fail_test("SaveService missing: " + SAVE_SCRIPT + " (API_CONTRACT.md section 12)")
		return null
	var script: GDScript = load(SAVE_SCRIPT)
	var s: Variant = script.new(_file, Callable(clock, "read"))
	if s == null:
		fail_test("SaveService.new(path, clock) returned null")
		return null
	for m in REQUIRED_METHODS:
		if not s.has_method(m):
			fail_test("SaveService.%s() is missing (API_CONTRACT.md section 12)" % m)
			return null
	return s


func reopen() -> Variant:
	return open_save()


## A save in a chosen state (see SaveService.debug_set in API_CONTRACT.md 12.8).
func save_with(values: Dictionary) -> Variant:
	var s: Variant = open_save()
	if s == null:
		return null
	s.debug_set(values)
	return s


## Starts an attempt. Returns {"tracker": GoalTracker, "result": Dictionary}.
func start(s: Variant, level: int, pre: Array = []) -> Dictionary:
	var t: Variant = loose_tracker([obstacle_goal("OB02", 5)], level)
	var r: Variant = s.start_attempt(level, t, pre)
	return {"tracker": t, "result": r}


func started(d: Dictionary) -> bool:
	return d.result is Dictionary and bool((d.result as Dictionary).get("ok", false))


func pre_specials_of(d: Dictionary) -> Array:
	if not (d.result is Dictionary):
		return []
	return (d.result as Dictionary).get("pre_specials", [])


## Starts and wins a level (rockets = finale Rockets left).
func win(s: Variant, level: int, rockets: int = 0) -> void:
	var d: Dictionary = start(s, level)
	assert_true(started(d), "level %d can be started" % level)
	s.end_attempt("win", rockets)


## Starts a level and ends it as a fail (offer declined).
func lose(s: Variant, level: int) -> void:
	var d: Dictionary = start(s, level)
	assert_true(started(d), "level %d can be started" % level)
	s.end_attempt("fail")


## Starts a level and quits it.
func quit_level(s: Variant, level: int) -> void:
	var d: Dictionary = start(s, level)
	assert_true(started(d), "level %d can be started" % level)
	s.end_attempt("quit")


## Wins every level in order until `target` is the next level.
func play_to(s: Variant, target: int) -> void:
	while int(s.next_level()) < target:
		win(s, int(s.next_level()))


## Moves run out on the tracker's board (the offer becomes pending).
func run_out(t: Variant, board: BoardModel) -> void:
	board.moves = 0
	t.moves_ran_out(board)


func read_file_json() -> Variant:
	if not FileAccess.file_exists(_file):
		fail_test("the save file was not written: " + _file)
		return null
	var f: FileAccess = FileAccess.open(_file, FileAccess.READ)
	return JSON.parse_string(f.get_as_text())


## buy_all_lives() returns a Dictionary with "ok" (API_CONTRACT.md 12.3).
func _bought(r: Variant) -> bool:
	return r is Dictionary and bool((r as Dictionary).get("ok", false))
