# The GDD's meta numbers in one place: starting coins, lives, prices, booster unlock levels, story beat levels.
# SaveService reads them from here (spec section K: "tune in playtests", so they live in one file).
# Check: tests/save_service/ (the tests hold the same numbers and fail if one drifts).
class_name MetaRules
extends RefCounted

const LAST_LEVEL: int = 50                 # the MVP ends at level 50 (IR-79)
const START_COINS: int = 500               # IR-80
const MAX_LIVES: int = 5                   # IR-81
const REFILL_SECONDS: int = 20 * 60        # one life back every 20 minutes (IR-81)
const UNLIMITED_SECONDS: int = 10 * 60     # unlimited lives after winning a chapter finale (IR-81)
const BUY_LIVES_PRICE: int = 150           # buy all 5 lives back (IR-80, IR-81)
const STREAK_FOR_CHEST: int = 6            # IR-84
const RAT_FRAGMENTS_NEEDED: int = 8        # IR-85

# Hero boosters (IR-82): level that unlocks it, free uses given once, price per use after that.
const HERO_BOOSTERS: Dictionary = {
	"hoof_tap": {"level": 11, "free": 3, "price": 100},
	"tail_slam": {"level": 23, "free": 2, "price": 200},
	"bamboo_dash": {"level": 29, "free": 2, "price": 150},
	"feather_fan": {"level": 36, "free": 2, "price": 100},
}

# Pre-level boosters (IR-83): name -> the specials LevelLoader places (IR-77).
const PRE_BOOSTERS: Dictionary = {
	"rocket_crane": ["rocket", "crane"],
	"firecracker": ["firecracker"],
}
const PRE_BOOSTER_LEVEL: int = 16
const PRE_BOOSTER_FREE: int = 1
const PRE_BOOSTER_PRICE: int = 150
const CHEST_SPECIALS: Array[String] = ["rocket", "crane"]   # the streak chest's gift (IR-84)

# Levels with a story beat (IR-87).
const STORY_BEAT_LEVELS: Array[int] = [1, 15, 17, 20, 25, 30, 35, 40, 45, 50]
