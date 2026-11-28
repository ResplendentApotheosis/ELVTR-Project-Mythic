# One attempt at a level: the starting board, its goal tracker and the seed it was built from (IR-71, IR-72).
# Plain data; LevelLoader fills it in. Check: tests/level_loader/test_seed_and_retry.gd.
class_name LevelAttempt
extends RefCounted

var level_id: int = 0
var seed_value: int = 0                 # this attempt's seed; board.rng is seeded from it (IR-72)
var level: Dictionary = {}              # the level data this attempt was built from
var source_path: String = ""            # the level file, or "" when built from a Dictionary
var board: BoardModel = null            # the starting board
var tracker: GoalTracker = null         # this attempt's goals; board.goal_tracker is the same object
var story_beat: String = ""             # "intro" | "mini" | "chapter"; "" when the level has none (IR-63)
var tutorial: Dictionary = {}           # the level's swap hint {teach, hint_cells}; {} when none (IR-89)
var fragment_guardian: String = ""      # "rat" on a level with a "fragment" field, else ""
