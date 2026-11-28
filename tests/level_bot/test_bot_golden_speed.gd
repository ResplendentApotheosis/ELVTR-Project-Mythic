# GUT tests: the bot's speed-up must not change its results (golden file recorded from the bot BEFORE the
# speed-up) and the bot must be fast per move. Rules touched: none. API: API_CONTRACT.md 16.3 / 16.4.
# Check: run the GUT suite. The golden file is tests/level_bot/fixtures/golden_fixture_012_runs5_seed1.json
# (made with: level_bot.gd -- tests/level_loader/fixtures/level_fixture_012.json --runs 5 --seed 1).
# Re-recorded 28 Nov 2026 after IR-40 (Firecracker and Crane made by a swap also appear on a swapped cell):
# run 0 now uses 3 moves, average moves left 23.8 (was 24.0).
extends GutTest

const FIXTURE: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
const GOLDEN: String = "res://tests/level_bot/fixtures/golden_fixture_012_runs5_seed1.json"
const MAX_SECONDS_PER_MOVE: float = 0.10   # loose bound; the target is 0.05


## Both sides go through JSON, so ints and floats compare the way the file does.
func _normalised(d: Dictionary) -> Variant:
	return JSON.parse_string(JSON.stringify(d))


func test_bot_results_match_the_golden_file_exactly() -> void:
	var golden: Variant = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	assert_true(golden is Dictionary, "golden file is readable")
	var got: Dictionary = LevelBot.run(FIXTURE, 5, 1)
	assert_eq(_normalised(got), golden, "the full dictionary, per-run results included, is unchanged")


func test_bot_per_run_results_match_the_golden_file() -> void:
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var results: Array = golden["results"]
	for i in range(results.size()):
		var r: Variant = _normalised(LevelBot.play_once(FIXTURE, 1 + i))
		assert_eq(r, results[i], "run %d (seed %d)" % [i, 1 + i])


func test_bot_average_time_per_move_is_under_a_tenth_of_a_second() -> void:
	var moves: int = 0
	var start: int = Time.get_ticks_usec()
	for s in range(1, 7):
		var r: Dictionary = LevelBot.play_once(FIXTURE, s)
		moves += int(r["moves_used"])
	var seconds: float = float(Time.get_ticks_usec() - start) / 1000000.0
	assert_gt(moves, 0, "the bot made moves")
	var per_move: float = seconds / float(maxi(moves, 1))
	gut.p("bot speed: %.4f s per move (%d moves in %.3f s; target 0.05, limit %.2f)" % [
		per_move, moves, seconds, MAX_SECONDS_PER_MOVE])
	assert_lt(per_move, MAX_SECONDS_PER_MOVE, "average seconds per bot move")
