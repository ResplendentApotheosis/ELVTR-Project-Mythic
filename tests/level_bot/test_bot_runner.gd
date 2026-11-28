# GUT tests for LevelBot (tools/level_bot/bot_runner.gd): a greedy bot that plays a level file with the real
# LevelLoader and MatchResolver, never takes a continue and never touches SaveService or boosters.
# Rules touched: none (it only calls the rules); relies on IR-37 (it declines the offer), IR-71/72 (seed -> board).
# API: tests/API_CONTRACT.md 15.3. Check: run the GUT suite. The CLI test runs only when GODOT_BIN is set.
extends GutTest

const BB = preload("res://tests/helpers/board_builder.gd")
const BOT_PATH: String = "res://tools/level_bot/bot_runner.gd"
const CLI_PATH: String = "res://tools/level_bot/level_bot.gd"
const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const RESULT_KEYS: Array = ["won", "moves_used", "moves_left", "goal_progress"]
const RUN_KEYS: Array = ["level", "tier", "runs", "seed", "wins", "win_rate", "avg_moves_left_on_win",
	"avg_goal_progress_on_fail", "results"]

var _scratch: Array[String] = []


func after_each() -> void:
	for f in _scratch:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
	_scratch.clear()


func _bot() -> GDScript:
	if not ResourceLoader.exists(BOT_PATH):
		fail_test("LevelBot missing: " + BOT_PATH + " (API_CONTRACT.md 15.3)")
		return null
	var script: GDScript = load(BOT_PATH)
	for m in ["play_once", "run", "choose_move"]:
		if not script.has_script_method(m):
			fail_test("LevelBot.%s is missing (API_CONTRACT.md 15.3)" % m)
			return null
	return script


## A scratch copy of the fixture with `moves` changed.
func _level_with_moves(moves: int) -> String:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	d["moves"] = moves
	var p: String = "user://zf_bot_level_%d.json" % Time.get_ticks_usec()
	var f: FileAccess = FileAccess.open(p, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()
	_scratch.append(p)
	return p


func _attempt(board: BoardModel, goals: Array) -> LevelAttempt:
	var a: LevelAttempt = LevelAttempt.new()
	a.level_id = 12
	a.board = board
	a.tracker = GoalTracker.new(goals, 12)
	board.goal_tracker = a.tracker
	a.tracker.attach(board)
	return a


func _json_files() -> Array:
	var out: Array = []
	var d: DirAccess = DirAccess.open("user://")
	if d != null:
		for f in d.get_files():
			if f.ends_with(".json") and not f.begins_with("zf_bot_level_"):
				out.append(f)
	out.sort()
	return out


# ---------------------------------------------------------------- play_once

func test_play_once_returns_the_documented_dictionary() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var r: Dictionary = bot.call("play_once", FIXTURE, 3)
	for k in RESULT_KEYS:
		assert_true(r.has(k), "result has " + k)
	assert_true(r["won"] is bool)
	assert_true(r["moves_used"] is int)
	assert_true(r["moves_left"] is int)
	assert_true(float(r["goal_progress"]) >= 0.0 and float(r["goal_progress"]) <= 1.0)


func test_play_once_never_exceeds_the_levels_moves() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	for s in range(8):
		var r: Dictionary = bot.call("play_once", FIXTURE, s)
		assert_lte(int(r["moves_used"]), 26)
		assert_gte(int(r["moves_left"]), 0)
		assert_eq(int(r["moves_used"]) + int(r["moves_left"]), 26, "moves add up (seed %d)" % s)


func test_play_once_never_accepts_a_continue() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var p: String = _level_with_moves(3)   # far too few moves to clear the goals, so it runs out
	for s in range(6):
		var r: Dictionary = bot.call("play_once", p, s)
		assert_lte(int(r["moves_used"]), 3, "no +5 moves from a continue (seed %d)" % s)
		if not bool(r["won"]):
			assert_eq(int(r["moves_used"]), 3)
			assert_eq(int(r["moves_left"]), 0, "the first run-out ends the run as a loss")


func test_play_once_goal_progress_is_one_exactly_on_wins() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	for s in range(10):
		var r: Dictionary = bot.call("play_once", FIXTURE, s)
		if bool(r["won"]):
			assert_eq(float(r["goal_progress"]), 1.0, "a win has every goal done (seed %d)" % s)
		else:
			assert_lt(float(r["goal_progress"]), 1.0, "a loss has a goal left (seed %d)" % s)


func test_play_once_is_deterministic() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	assert_eq(bot.call("play_once", FIXTURE, 11), bot.call("play_once", FIXTURE, 11))


func test_play_once_builds_exactly_one_board_with_the_real_loader() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	LevelLoader.build_count = 0
	bot.call("play_once", FIXTURE, 5)
	assert_eq(LevelLoader.build_count, 1, "one LevelLoader build per run, no retry")


func test_bot_does_not_touch_the_save_or_any_json_file_in_user() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var before: Array = _json_files()
	bot.call("run", FIXTURE, 3, 1)
	assert_eq(_json_files(), before, "the bot wrote no save file")


# ---------------------------------------------------------------- run

func test_run_returns_the_documented_dictionary() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var d: Dictionary = bot.call("run", FIXTURE, 5, 21)
	for k in RUN_KEYS:
		assert_true(d.has(k), "run has " + k)
	assert_eq(int(d["level"]), 12)
	assert_eq(String(d["tier"]), "medium")
	assert_eq(int(d["runs"]), 5)
	assert_eq(int(d["seed"]), 21)
	assert_eq((d["results"] as Array).size(), 5)
	var wins: int = 0
	for r in d["results"]:
		if bool((r as Dictionary)["won"]):
			wins += 1
	assert_eq(int(d["wins"]), wins)
	assert_almost_eq(float(d["win_rate"]), float(wins) / 5.0, 0.0001)


func test_run_averages_match_the_results() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var d: Dictionary = bot.call("run", FIXTURE, 12, 4)
	var left_sum: float = 0.0
	var wins: int = 0
	var prog_sum: float = 0.0
	var fails: int = 0
	for r in d["results"]:
		var e: Dictionary = r
		if bool(e["won"]):
			wins += 1
			left_sum += float(e["moves_left"])
		else:
			fails += 1
			prog_sum += float(e["goal_progress"])
	if wins > 0:
		assert_almost_eq(float(d["avg_moves_left_on_win"]), left_sum / wins, 0.0001)
	else:
		assert_eq(float(d["avg_moves_left_on_win"]), 0.0, "no wins: 0")
	if fails > 0:
		assert_almost_eq(float(d["avg_goal_progress_on_fail"]), prog_sum / fails, 0.0001)
	else:
		assert_eq(float(d["avg_goal_progress_on_fail"]), 0.0, "no fails: 0")


func test_run_same_path_and_seed_gives_identical_results() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	assert_eq(bot.call("run", FIXTURE, 6, 99), bot.call("run", FIXTURE, 6, 99))


func test_run_i_uses_seed_plus_i() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	var single: Dictionary = bot.call("run", FIXTURE, 1, 33 + 3)
	var five: Dictionary = bot.call("run", FIXTURE, 5, 33)
	assert_eq((single["results"] as Array)[0], (five["results"] as Array)[3])
	assert_eq((five["results"] as Array)[3], bot.call("play_once", FIXTURE, 36))


# ---------------------------------------------------------------- choose_move

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return absi(a.x - b.x) + absi(a.y - b.y) == 1


func test_choose_move_on_a_real_board_is_accepted_by_the_resolver() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	for s in range(6):
		var a: LevelAttempt = LevelLoader.load_file(FIXTURE, {"seed": s})
		var before: String = BB.snapshot(a.board)
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = s
		var m: Dictionary = bot.call("choose_move", a, rng)
		assert_eq(BB.snapshot(a.board), before, "choosing does not change the board")
		assert_true(m.has("action"))
		var moves_before: int = a.board.moves
		var events: Array[BoardEvent] = []
		if m["action"] == "swap":
			assert_true(_is_adjacent(m["from"], m["to"]), "adjacent cells")
			events = MatchResolver.swap(a.board, m["from"], m["to"])
		else:
			assert_eq(m["action"], "tap")
			events = MatchResolver.tap(a.board, m["cell"])
		var invalid: int = 0
		for e in events:
			if e.type == "invalid_swap":
				invalid += 1
		assert_eq(invalid, 0, "the resolver accepts the move (seed %d)" % s)
		assert_eq(a.board.moves, moves_before - 1, "it used a move")


## Two matches exist: a plain 3-match (Y) and a 4-match (R) that makes a special. The bot takes the 4-match.
func test_choose_move_prefers_creating_a_special_over_a_plain_match() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	for s in range(10):
		var board: BoardModel = BB.from_rows([
			". . . . . . . . .",
			"Y Y . . . . . . .",
			". . Y . . . R . .",
			". . . . R R . R .",
			". . . . . . . . .",
		])
		var a: LevelAttempt = _attempt(board, [{"obstacle": "OB06", "count": 1}])
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = s
		var m: Dictionary = bot.call("choose_move", a, rng)
		assert_eq(m.get("action"), "swap")
		assert_eq([m["from"], m["to"]].filter(func(c: Vector2i) -> bool: return c == Vector2i(6, 2)).size(), 1)
		assert_eq([m["from"], m["to"]].filter(func(c: Vector2i) -> bool: return c == Vector2i(6, 3)).size(), 1,
			"the 4-match swap, seed %d" % s)


## A plain 3-match far away vs a 3-match next to the last bramble (the only goal): the bot completes the goal.
func test_choose_move_prefers_completing_a_goal_over_a_plain_match() -> void:
	var bot: GDScript = _bot()
	if bot == null:
		return
	for s in range(10):
		var board: BoardModel = BB.blank()
		board.add_content("OB02", 4, 3, 1)
		BB.put(board, "R", [[3, 4], [5, 4], [4, 5]])   # swap (4,5)<->(4,4): R R R under the bramble
		BB.put(board, "Y", [[0, 7], [1, 7], [2, 8]])   # swap (2,8)<->(2,7): Y Y Y far away
		var a: LevelAttempt = _attempt(board, [{"obstacle": "OB02", "count": 1}])
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = s
		var m: Dictionary = bot.call("choose_move", a, rng)
		assert_eq(m.get("action"), "swap")
		var cells: Array = [m["from"], m["to"]]
		assert_true(cells.has(Vector2i(4, 5)) and cells.has(Vector2i(4, 4)),
			"the goal-completing swap, seed %d: %s" % [s, cells])


# ---------------------------------------------------------------- CLI

func _godot() -> String:
	return OS.get_environment("GODOT_BIN")


func test_cli_script_exists() -> void:
	assert_true(FileAccess.file_exists(CLI_PATH), "CLI missing: " + CLI_PATH)


func test_cli_writes_the_report_to_out() -> void:
	if _godot() == "" or not FileAccess.file_exists(CLI_PATH):
		pending("GODOT_BIN not set or CLI missing")
		return
	var out_path: String = "user://zf_bot_report_%d.json" % Time.get_ticks_usec()
	_scratch.append(out_path)
	var output: Array = []
	var args: PackedStringArray = [
		"--headless", "--path", ProjectSettings.globalize_path("res://"), "-s", CLI_PATH, "--",
		ProjectSettings.globalize_path(FIXTURE), "--runs", "3", "--seed", "5",
		"--out", ProjectSettings.globalize_path(out_path),
	]
	assert_eq(OS.execute(_godot(), args, output, true), 0)
	assert_true(FileAccess.file_exists(out_path), "report written")
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(out_path))
	assert_true(d is Dictionary)
	assert_eq(int((d as Dictionary).get("runs", 0)), 3)
	assert_eq(int((d as Dictionary).get("seed", 0)), 5)
	assert_eq(int((d as Dictionary).get("level", 0)), 12)
