# The level bot: plays a level file like a greedy, fairly good human, using the REAL LevelLoader, MatchResolver
# and GoalTracker (it tries each move on a copy of the board, never re-implements a rule). No boosters, no
# pre-level boosters, no streak chest, no continues, no SaveService, and only the specials and combos the level
# has taught. Check: GUT tests/level_bot/test_bot_runner.gd, or the CLI tools/level_bot/level_bot.gd.
class_name LevelBot
extends RefCounted

# When each special and combo is taught (GDD > Core gameplay > Special pieces / Combos). Before its level the
# bot never taps it or swaps it on purpose. Combos not listed (Firecracker + Firecracker, Jade Orb + special,
# Orb + Orb, and Crane + special, which is not a combo) are never taught, so the bot never swaps them on purpose.
const SPECIAL_TAUGHT_AT: Dictionary = {"rocket_row": 2, "rocket_col": 2, "firecracker": 3, "crane": 5, "orb": 6}
const COMBO_TAUGHT_AT: Dictionary = {"rocket+rocket": 8, "firecracker+rocket": 12}

# How much each thing a move does is worth. Bigger tiers always win over smaller ones in practice.
const SCORE_GOAL_FINISHED: float = 100000.0   # a goal done by this move
const SCORE_GOAL_UNIT: float = 1000.0          # one goal unit (one obstacle fully gone, one item collected)
const SCORE_GOAL_HIT: float = 200.0            # one hit on a goal obstacle (a layer, a shrine need, a dew cell)
const SCORE_SPECIAL_MADE: float = 100.0        # a taught special created
const SCORE_TAUGHT_COMBO: float = 100.0        # a taught combo swapped
const SCORE_PIECE_CLEARED: float = 1.0         # each piece cleared
const NOISE: float = 6.0                       # random 0..NOISE added, so it is good but not perfect


# ---------------------------------------------------------------- public API

## Plays one attempt with this seed (board seed and bot seed). Never accepts a continue: the first time moves
## run out the run is a loss. Returns {"won", "moves_used", "moves_left", "goal_progress"}.
static func play_once(path: String, seed_value: int) -> Dictionary:
	var attempt: LevelAttempt = LevelLoader.load_file(path, {"seed": seed_value})
	if attempt == null:
		return {"won": false, "moves_used": 0, "moves_left": 0, "goal_progress": 0.0,
			"error": "could not build %s %s" % [path, LevelLoader.last_errors]}
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var start_moves: int = attempt.board.moves
	var won: bool = false
	while attempt.board.moves > 0:
		var move: Dictionary = choose_move(attempt, rng)
		if move.is_empty():
			break   # no legal move at all (should not happen: the resolver shuffles a stuck board)
		var events: Array[BoardEvent] = _apply(attempt.board, move)
		if events.is_empty():
			break
		var last: String = (events.back() as BoardEvent).type
		if last == "win":
			won = true
			break
		if last == "fail":
			break   # the continue offer is declined: a loss
	var left: int = attempt.board.moves if won else 0
	return {
		"won": won,
		"moves_used": start_moves - left,
		"moves_left": left,
		"goal_progress": _goal_progress(attempt.tracker),
	}


## Plays `runs` attempts; run i uses seed_value + i. Returns the summary and every result.
static func run(path: String, runs: int, seed_value: int) -> Dictionary:
	var level: Variant = LevelLoader.read_level_file(path)
	var info: Dictionary = level if level is Dictionary else {}
	var results: Array = []
	var wins: int = 0
	var left_on_win: float = 0.0
	var progress_on_fail: float = 0.0
	for i in range(runs):
		var r: Dictionary = play_once(path, seed_value + i)
		results.append(r)
		if bool(r["won"]):
			wins += 1
			left_on_win += float(r["moves_left"])
		else:
			progress_on_fail += float(r["goal_progress"])
	var fails: int = runs - wins
	return {
		"level": LevelLoader.as_int(info.get("id"), 0),
		"tier": String(info.get("tier", "")),
		"runs": runs,
		"seed": seed_value,
		"wins": wins,
		"win_rate": float(wins) / float(runs) if runs > 0 else 0.0,
		"avg_moves_left_on_win": left_on_win / wins if wins > 0 else 0.0,
		"avg_goal_progress_on_fail": progress_on_fail / fails if fails > 0 else 0.0,
		"results": results,
	}


## The level files for "1-5" (level_001.json .. level_005.json in `dir`, in order) or "7" (one file).
## Any other text ("", "abc", "1-x", "1-2-3", "-", "5-1") gives []. It does not check that the files exist.
static func level_paths(range_text: String, dir: String = "res://levels") -> Array[String]:
	var out: Array[String] = []
	var parts: PackedStringArray = range_text.strip_edges().split("-")
	if parts.size() < 1 or parts.size() > 2:
		return out
	for p in parts:
		if not p.is_valid_int() or int(p) < 1:
			return out
	var first: int = int(parts[0])
	var last: int = int(parts[parts.size() - 1])
	if last < first:
		return out
	for n in range(first, last + 1):
		out.append(dir.trim_suffix("/") + "/level_%03d.json" % n)
	return out


## run() for every path, in path order, all with the SAME seed. `jobs` above 1 runs that many levels at
## once, each in its own Godot process (the CLI below, one level each); the results are the same whatever
## `jobs` is, because every result goes through JSON in both cases. A level that can't be played gives
## {"path": ..., "error": "..."} in its place; the others still run.
static func run_many(paths: Array[String], runs: int, seed_value: int, jobs: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var to_spawn: Array[int] = []   # indexes of the levels a child process will play
	for i in range(paths.size()):
		var problem: String = cannot_play(paths[i], seed_value)
		if problem != "":
			out.append({"path": paths[i], "error": problem})
		elif jobs <= 1:
			out.append(_through_json(run(paths[i], runs, seed_value)))
		else:
			out.append({})
			to_spawn.append(i)
	if not to_spawn.is_empty():
		_run_in_processes(paths, to_spawn, runs, seed_value, jobs, out)
	return out


## "" if this level can be built and played; else why not (e.g. "file not found").
static func cannot_play(path: String, seed_value: int) -> String:
	if not FileAccess.file_exists(path):
		return "cannot play %s: file not found" % path
	if LevelLoader.load_file(path, {"seed": seed_value}) == null:
		return "cannot play %s: %s" % [path, LevelLoader.last_errors]
	return ""


## Plays the levels at `indexes` in child Godot processes, at most `jobs` at a time, and puts each one's
## result (read back from the JSON file it wrote) into `out`. Separate processes, not threads, because
## LevelLoader and the validator keep static variables that threads would share.
static func _run_in_processes(paths: Array[String], indexes: Array[int], runs: int, seed_value: int, jobs: int,
		out: Array[Dictionary]) -> void:
	var work_dir: String = "user://level_bot_jobs_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(work_dir))
	var waiting: Array[int] = indexes.duplicate()
	var running: Dictionary = {}   # pid -> index
	while not waiting.is_empty() or not running.is_empty():
		while not waiting.is_empty() and running.size() < jobs:
			var i: int = waiting.pop_front()
			var pid: int = OS.create_process(OS.get_executable_path(), _child_args(paths[i], runs, seed_value,
				_job_file(work_dir, i)))
			if pid <= 0:
				out[i] = {"path": paths[i], "error": "could not start a bot process for %s" % paths[i]}
			else:
				running[pid] = i
		for pid in running.keys():
			if not OS.is_process_running(pid):
				var i: int = running[pid]
				running.erase(pid)
				out[i] = _read_job(paths[i], _job_file(work_dir, i))
		if not running.is_empty():
			OS.delay_msec(20)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(work_dir))


static func _child_args(path: String, runs: int, seed_value: int, out_file: String) -> PackedStringArray:
	return PackedStringArray([
		"--headless", "--path", ProjectSettings.globalize_path("res://"),
		"-s", "res://tools/level_bot/level_bot.gd", "--",
		ProjectSettings.globalize_path(path), "--runs", str(runs), "--seed", str(seed_value),
		"--out", ProjectSettings.globalize_path(out_file),
	])


static func _job_file(work_dir: String, index: int) -> String:
	return work_dir + "/job_%03d.json" % index


## The run() dictionary a child process wrote (the file is deleted after reading).
static func _read_job(path: String, job_file: String) -> Dictionary:
	var parsed: Variant = null
	if FileAccess.file_exists(job_file):
		parsed = JSON.parse_string(FileAccess.get_file_as_string(job_file))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(job_file))
	if parsed is Dictionary:
		return _counts_as_ints(parsed)
	return {"path": path, "error": "the bot process for %s wrote no result" % path}


## A dictionary as it reads back from a JSON file, so in-process and child-process results compare equal.
static func _through_json(d: Dictionary) -> Dictionary:
	return _counts_as_ints(JSON.parse_string(JSON.stringify(d)))


## JSON reads every number back as a float (2 -> 2.0); the counts of a run() dictionary become ints again,
## so a report written from it looks exactly like one written straight from run().
static func _counts_as_ints(d: Dictionary) -> Dictionary:
	for key in ["level", "runs", "seed", "wins"]:
		if d.has(key):
			d[key] = int(d[key])
	for r in d.get("results", []):
		if r is Dictionary:
			for key in ["moves_used", "moves_left"]:
				if (r as Dictionary).has(key):
					r[key] = int(r[key])
	return d


## The bot's next move on this attempt's board, without changing it: {"action": "swap", "from", "to"} or
## {"action": "tap", "cell"}; {} if there is none. Every legal swap and tap is tried on a copy of the board
## with the real MatchResolver and scored: goals finished, then goal progress, then taught specials made
## (and taught combos), then pieces cleared, plus a little rng noise.
static func choose_move(attempt: LevelAttempt, rng: RandomNumberGenerator) -> Dictionary:
	var board: BoardModel = attempt.board
	var level_id: int = attempt.level_id
	var best: Dictionary = {}
	var best_score: float = -INF
	var fallback: Dictionary = {}   # any accepted move, used only if no allowed move exists
	var scratch: BoardModel = board.copy()   # used only to spot plain swaps that make no match (cheap filter)
	for move in _candidates(board, scratch):
		var allowed: bool = _is_taught_move(board, move, level_id)
		if not allowed and not fallback.is_empty():
			continue
		# Each try gets its own random refills, so the bot can't "see" the pieces that will fall in.
		var outcome: Dictionary = _try(board, attempt.tracker, move, rng.randi())
		if outcome.is_empty():
			continue   # refused or snapped back
		if not allowed:
			fallback = move
			continue
		var score: float = _score(outcome, level_id, _is_combo(board, move)) + rng.randf() * NOISE
		if score > best_score:
			best_score = score
			best = move
	return best if not best.is_empty() else fallback


# ---------------------------------------------------------------- trying a move on a copy

## Every move worth trying: swaps of neighbours (right and down) and taps on specials.
static func _candidates(board: BoardModel, scratch: BoardModel) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for y in range(board.height):
		for x in range(board.width):
			var a: Vector2i = Vector2i(x, y)
			if board.is_special(x, y) and not board.is_locked(x, y):
				out.append({"action": "tap", "cell": a})
			for b in [a + Vector2i.RIGHT, a + Vector2i.DOWN]:
				if not board.has_item(b.x, b.y) or not board.has_item(a.x, a.y):
					continue
				if board.is_special(a.x, a.y) or board.is_special(b.x, b.y) or _makes_match(scratch, a, b):
					out.append({"action": "swap", "from": a, "to": b})
	return out


## Quick filter with the real MatchFinder: does swapping these two pieces line up a match?
static func _makes_match(scratch: BoardModel, a: Vector2i, b: Vector2i) -> bool:
	scratch.swap_pieces(a, b)
	var hit: bool = MatchFinder.has_match_at(scratch, a) or MatchFinder.has_match_at(scratch, b)
	scratch.swap_pieces(a, b)
	return hit


## Plays `move` on a copy with the real resolver. {} if it was refused or used no move; else what it did.
static func _try(board: BoardModel, tracker: GoalTracker, move: Dictionary, refill_seed: int) -> Dictionary:
	var copy: BoardModel = board.copy()
	copy.rng.seed = refill_seed
	var t: GoalTracker = tracker.copy_for(copy) if tracker != null else null
	var ids: Array = _goal_ids(t, copy)
	var before_left: int = goal_left(copy, ids)
	var before_done: Array[bool] = []
	var before_units: int = 0
	if t != null:
		for i in range(t.goal_count()):
			before_done.append(t.is_goal_done(i))
			before_units += t.goal_units_done(i)
	var events: Array[BoardEvent] = _apply(copy, move)
	if events.is_empty() or copy.moves != board.moves - 1:
		return {}
	for e in events:
		if e.type == "invalid_swap":
			return {}
	var finished: int = 0
	var units: int = 0
	if t != null:
		for i in range(before_done.size()):
			if t.is_goal_done(i) and not before_done[i]:
				finished += 1
			units += t.goal_units_done(i)
	return {"events": events, "goals_finished": finished, "goal_units": units - before_units,
		"goal_hits": maxi(before_left - goal_left(copy, ids), 0)}


static func _score(outcome: Dictionary, level_id: int, taught_combo: bool) -> float:
	var specials: int = 0
	var cleared: int = 0
	for e in outcome["events"]:
		var ev: BoardEvent = e
		if ev.type == "special_created" and _special_taught(ev.kind, level_id):
			specials += 1
		elif ev.type == "clear":
			cleared += ev.cells.size()
	var s: float = SCORE_GOAL_FINISHED * int(outcome["goals_finished"])
	s += SCORE_GOAL_UNIT * int(outcome["goal_units"])
	s += SCORE_GOAL_HIT * int(outcome["goal_hits"])
	s += SCORE_SPECIAL_MADE * specials
	s += SCORE_TAUGHT_COMBO * (1 if taught_combo else 0)
	s += SCORE_PIECE_CLEARED * cleared
	return s


static func _apply(board: BoardModel, move: Dictionary) -> Array[BoardEvent]:
	if move["action"] == "tap":
		return MatchResolver.tap(board, move["cell"])
	return MatchResolver.swap(board, move["from"], move["to"])


# ---------------------------------------------------------------- taught specials and combos

static func _special_taught(kind: String, level_id: int) -> bool:
	return SPECIAL_TAUGHT_AT.has(kind) and level_id >= int(SPECIAL_TAUGHT_AT[kind])


## A plain match is always allowed; using a special (tap, swap with a piece) needs it taught; swapping two
## specials needs that combo taught.
static func _is_taught_move(board: BoardModel, move: Dictionary, level_id: int) -> bool:
	if move["action"] == "tap":
		var c: Vector2i = move["cell"]
		return _special_taught(board.get_kind(c.x, c.y), level_id)
	var a: Vector2i = move["from"]
	var b: Vector2i = move["to"]
	var a_special: bool = board.is_special(a.x, a.y)
	var b_special: bool = board.is_special(b.x, b.y)
	if a_special and b_special:
		var key: String = _combo_key(board, a, b)
		return COMBO_TAUGHT_AT.has(key) and level_id >= int(COMBO_TAUGHT_AT[key])
	if a_special:
		return _special_taught(board.get_kind(a.x, a.y), level_id)
	if b_special:
		return _special_taught(board.get_kind(b.x, b.y), level_id)
	return true


static func _is_combo(board: BoardModel, move: Dictionary) -> bool:
	if move["action"] != "swap":
		return false
	var a: Vector2i = move["from"]
	var b: Vector2i = move["to"]
	return board.is_special(a.x, a.y) and board.is_special(b.x, b.y)


## "rocket+rocket", "firecracker+rocket", ... (both Rocket directions count as "rocket"; sorted names).
static func _combo_key(board: BoardModel, a: Vector2i, b: Vector2i) -> String:
	var names: Array[String] = [_family(board.get_kind(a.x, a.y)), _family(board.get_kind(b.x, b.y))]
	names.sort()
	return "%s+%s" % [names[0], names[1]]


static func _family(kind: String) -> String:
	return "rocket" if kind.begins_with("rocket") else kind


# ---------------------------------------------------------------- goal progress

## Sum of goal units done / sum of goal units total (1.0 exactly when every goal is done).
static func _goal_progress(tracker: GoalTracker) -> float:
	var done: int = 0
	var total: int = 0
	for i in range(tracker.goal_count()):
		done += tracker.goal_units_done(i)
		total += tracker.goal_units_total(i)
	if total <= 0:
		return 1.0
	return float(done) / float(total)


## The goal ids to chip at: the tracker's goals ("fragment" for the fragment goal), else board.goals.
static func _goal_ids(tracker: GoalTracker, board: BoardModel) -> Array:
	if tracker == null:
		return board.goals
	var ids: Array = []
	for i in range(tracker.goal_count()):
		ids.append(tracker.goal_id(i))
	return ids


## A rough "hits still needed" count for the goals `ids`: layers / hp of goal obstacles, shrine
## needs, and dew cells still missing. Only used to prefer moves that chip at goals; the rules stay in the
## resolver. Drop items and fragments count through goal units instead.
static func goal_left(board: BoardModel, ids: Array) -> int:
	var n: int = 0
	for c in board.all_contents():
		if ids.has(c.id) or (c.fragment and ids.has("fragment")):
			n += c.hp
			for k in c.needs:
				n += int(c.needs[k])
	for y in range(board.height):
		for x in range(board.width):
			if ids.has(board.overlay_id(x, y)):
				n += board.overlay_hp(x, y)
			var under: String = board.underlay_id(x, y)
			if under != "OB04" and ids.has(under):
				n += board.underlay_hp(x, y)
	if ids.has("OB04"):
		n += board.dew_targets_left()
	return n
