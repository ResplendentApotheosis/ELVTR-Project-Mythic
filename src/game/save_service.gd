# The player's save: progress, coins, lives, boosters, streak chest, fragments, story beats, logs (IR-78 to IR-87).
# Every change is written at once; an attempt left open (app killed) ends as a quit on the next open (IR-38).
# Time comes from the clock Callable. A refused start or purchase returns {"ok": false, "reason": ...}, no change.
# Check: run the GUT suite; tests/save_service/ must pass.
class_name SaveService
extends RefCounted

var _path: String
var _clock: Callable
var _data: Dictionary
var _tracker: GoalTracker = null   # the open attempt's tracker; its coins are the live balance


func _init(save_path: String, clock: Callable) -> void:
	_path = save_path
	_clock = clock
	_data = SaveFile.read(_path)
	var open: Dictionary = _data.open_attempt
	if not open.is_empty():
		_finish_attempt(int(open.get("level", 0)), bool(open.get("first_try", false)), "quit", 0)


# ---------------------------------------------------------------- progress and attempts (IR-79, IR-38, IR-86)

func next_level() -> int:
	return int(_data.level)


func can_start(level: int) -> bool:
	if level < 1 or level > MetaRules.LAST_LEVEL or level != next_level():
		return false
	return lives() > 0 or unlimited_lives_active() or GoalTracker.FINALE_LEVELS.has(level)


func retry_choices(level: int) -> Array:
	return ["retry"] if can_start(level) else ["wait", "buy_lives"]


## Opens an attempt. Refused ({"ok": false, "reason": ...}) changes nothing. Accepted returns
## {"ok": true, "first_try": bool, "pre_specials": Array} for LevelLoader (IR-77).
## `tracker` may be null: the board is built after the save says yes, then bind_tracker(tracker) is called.
func start_attempt(level: int, tracker: GoalTracker = null, pre_boosters: Array = []) -> Dictionary:
	var reason: String = _start_refusal(level, pre_boosters)
	if reason != "":
		return {"ok": false, "reason": reason}
	_unlock_boosters(level)
	var pre_specials: Array = []
	if pre_boosters.size() == 1:
		var pre_name: String = String(pre_boosters[0])
		if int(_data.pre_boosters[pre_name]) > 0:
			_data.pre_boosters[pre_name] = int(_data.pre_boosters[pre_name]) - 1
		else:
			_data.coins = coins() - MetaRules.PRE_BOOSTER_PRICE
		pre_specials.append_array(MetaRules.PRE_BOOSTERS[pre_name])
	if bool(_data.chest_waiting):
		_data.chest_waiting = false
		pre_specials.append_array(MetaRules.CHEST_SPECIALS)
	var first_try: bool = not (_data.tried_levels as Array).has(level)
	if first_try:
		(_data.tried_levels as Array).append(level)
	_data.open_attempt = {"level": level, "first_try": first_try}
	_tracker = null
	_save()
	if tracker != null:
		bind_tracker(tracker)
	return {"ok": true, "first_try": first_try, "pre_specials": pre_specials}


## Links the open attempt's tracker to the save: from now on its coins are the live balance (a continue
## spends them there). Gives the tracker the save's lives and coins at once.
func bind_tracker(tracker: GoalTracker) -> void:
	_tracker = tracker
	if tracker == null:
		return
	tracker.lives = lives()
	tracker.coins = coins()


## Writes the open attempt's coins (the tracker's, after a continue) into the save.
func sync_attempt() -> void:
	if _data.open_attempt.is_empty():
		return
	_take_tracker_coins()
	_save()


## Ends the open attempt: "win", "fail" or "quit". Does nothing if no attempt is open.
func end_attempt(outcome: String, finale_rockets: int = 0) -> void:
	var open: Dictionary = _data.open_attempt
	if open.is_empty():
		return
	_take_tracker_coins()
	var tracker: GoalTracker = _tracker
	_finish_attempt(int(open.level), bool(open.first_try), outcome, finale_rockets)
	if tracker != null:
		tracker.lives = lives()
		tracker.coins = coins()


# ---------------------------------------------------------------- coins and lives (IR-80, IR-81)

func coins() -> int:
	return int(_data.coins)


## Buys all 5 lives for 150 coins. Returns {"ok": true}, or {"ok": false, "reason": String, "message": String}
## with nothing changed: "already_full" at 5 lives (IR-81), "not_enough_coins" below 150 coins (IR-80).
func buy_all_lives() -> Dictionary:
	if lives() >= MetaRules.MAX_LIVES:
		return {"ok": false, "reason": "already_full", "message": "You already have 5 lives"}
	if coins() < MetaRules.BUY_LIVES_PRICE:
		return {"ok": false, "reason": "not_enough_coins", "message": "Not enough coins"}
	_data.coins = coins() - MetaRules.BUY_LIVES_PRICE
	LivesClock.fill(_data)
	(_data.life_log as Array).append("lives_bought")
	_save()
	return {"ok": true}


func lives() -> int:
	if LivesClock.refresh(_data, _now()):
		_save()
	return int(_data.lives)


func unlimited_lives_active() -> bool:
	return _now() < int(_data.unlimited_until)


# ---------------------------------------------------------------- hero and pre-level boosters (IR-82, IR-83)

func hero_unlocked(booster: String) -> bool:
	return (_data.boosters_unlocked as Array).has(booster)


func hero_free_uses(booster: String) -> int:
	return int(_data.boosters.get(booster, 0)) if hero_unlocked(booster) else 0


## Spends a free use, else pays the price. False (nothing spent) when locked or unaffordable.
func use_hero_booster(booster: String) -> bool:
	if not _data.open_attempt.is_empty():
		_take_tracker_coins()
	var ok: bool = false
	if hero_unlocked(booster) and MetaRules.HERO_BOOSTERS.has(booster):
		var price: int = int(MetaRules.HERO_BOOSTERS[booster].price)
		if hero_free_uses(booster) > 0:
			_data.boosters[booster] = hero_free_uses(booster) - 1
			ok = true
		elif coins() >= price:
			_data.coins = coins() - price
			ok = true
	_save()
	if _tracker != null and not _data.open_attempt.is_empty():
		_tracker.coins = coins()
	return ok


func pre_boosters_unlocked() -> bool:
	return bool(_data.pre_boosters_unlocked)


func pre_free_uses(booster: String) -> int:
	return int(_data.pre_boosters.get(booster, 0)) if pre_boosters_unlocked() else 0


# ---------------------------------------------------------------- streak, fragments, logs, story (IR-84 to IR-87)

func streak() -> int:
	return int(_data.streak)


func chest_waiting() -> bool:
	return bool(_data.chest_waiting)


func fragments(guardian: String) -> int:
	return int(_data.fragments.get(guardian, 0))


func restored() -> Array:
	return (_data.restored as Array).duplicate()


func attempt_log() -> Array:
	return (_data.attempt_log as Array).duplicate(true)


func life_log() -> Array:
	return (_data.life_log as Array).duplicate()


func should_play_story_beat(level: int) -> bool:
	return MetaRules.STORY_BEAT_LEVELS.has(level) and not (_data.seen_beats as Array).has(level)


func mark_story_beat_seen(level: int) -> void:
	var seen: Array = _data.seen_beats
	if not seen.has(level):
		seen.append(level)
		seen.sort()
		_save()


func seen_story_beats() -> Array:
	return (_data.seen_beats as Array).duplicate()


# ---------------------------------------------------------------- test seam (not for game code)

## Sets the listed fields and writes the save. Keys: tests/API_CONTRACT.md section 12.9.
func debug_set(values: Dictionary) -> void:
	for key in values:
		var v: Variant = values[key]
		match key:
			"next_level": _data.level = int(v)
			"coins": _data.coins = int(v)
			"lives":
				_data.lives = int(v)
				_data.refill_started_at = _now() if int(v) < MetaRules.MAX_LIVES else 0
			"refill_started_at": pass   # applied after "lives", below
			"unlimited_until": _data.unlimited_until = int(v)
			"streak": _data.streak = int(v)
			"chest_waiting": _data.chest_waiting = bool(v)
			"fragments_rat": _data.fragments.rat = int(v)
			"restored": _data.restored = (v as Array).duplicate()
			"hero_unlocked": _data.boosters_unlocked = (v as Array).duplicate()
			"hero_free":
				for b in v:
					_data.boosters[b] = int(v[b])
			"pre_unlocked": _data.pre_boosters_unlocked = bool(v)
			"pre_free":
				for b in v:
					_data.pre_boosters[b] = int(v[b])
			"seen_beats":
				_data.seen_beats = (v as Array).duplicate()
				(_data.seen_beats as Array).sort()
			_: push_error("SaveService.debug_set: unknown key '%s'" % key)
	if values.has("refill_started_at"):
		_data.refill_started_at = int(values.refill_started_at)
	_save()


# ---------------------------------------------------------------- helpers

func _now() -> int:
	return int(_clock.call())


func _save() -> void:
	SaveFile.write(_path, _data)


func _take_tracker_coins() -> void:
	if _tracker != null:
		_data.coins = _tracker.coins


## Why a start is refused, or "" when it can go ahead.
func _start_refusal(level: int, pre_boosters: Array) -> String:
	if not _data.open_attempt.is_empty():
		return "attempt_open"
	if not can_start(level):
		return "cannot_start"
	if pre_boosters.is_empty():
		return ""
	if pre_boosters.size() > 1:
		return "one_pre_booster_only"
	var pre_name: String = String(pre_boosters[0])
	if not MetaRules.PRE_BOOSTERS.has(pre_name):
		return "unknown_pre_booster"
	var unlocked: bool = pre_boosters_unlocked() or level >= MetaRules.PRE_BOOSTER_LEVEL
	if not unlocked:
		return "pre_boosters_locked"
	var free: int = pre_free_uses(pre_name) if pre_boosters_unlocked() else MetaRules.PRE_BOOSTER_FREE
	if free <= 0 and coins() < MetaRules.PRE_BOOSTER_PRICE:
		return "not_enough_coins"
	return ""


## Unlocks every booster whose level is <= `level`, giving its free uses once (IR-82, IR-83).
func _unlock_boosters(level: int) -> void:
	for b in MetaRules.HERO_BOOSTERS:
		if int(MetaRules.HERO_BOOSTERS[b].level) <= level and not hero_unlocked(b):
			(_data.boosters_unlocked as Array).append(b)
			_data.boosters[b] = int(MetaRules.HERO_BOOSTERS[b].free)
	if level >= MetaRules.PRE_BOOSTER_LEVEL and not pre_boosters_unlocked():
		_data.pre_boosters_unlocked = true
		for p in MetaRules.PRE_BOOSTERS:
			_data.pre_boosters[p] = MetaRules.PRE_BOOSTER_FREE


## Logs and closes the attempt, then applies the win or fail rules (IR-38, IR-58, IR-60, IR-81, IR-84, IR-85).
func _finish_attempt(level: int, first_try: bool, outcome: String, finale_rockets: int) -> void:
	var won: bool = outcome == "win"
	(_data.attempt_log as Array).append({"level": level, "won": won, "quit": outcome == "quit", "first_try": first_try})
	_data.open_attempt = {}
	_tracker = null
	if won:
		_apply_win(level, finale_rockets)
	else:
		_data.streak = 0
		var finale: bool = GoalTracker.FINALE_LEVELS.has(level)
		if not finale and not unlimited_lives_active():
			if LivesClock.lose_one(_data, _now()):
				(_data.life_log as Array).append("lives_ran_out")
	_save()


func _apply_win(level: int, finale_rockets: int) -> void:
	_data.coins = coins() + GoalTracker.win_coins(finale_rockets)
	_data.level = level + 1
	_data.streak = streak() + 1
	if streak() >= MetaRules.STREAK_FOR_CHEST:
		_data.streak = 0
		if level < MetaRules.LAST_LEVEL:
			_data.chest_waiting = true
	if GoalTracker.FRAGMENT_LEVELS.has(level):
		_data.fragments.rat = fragments("rat") + 1
		if fragments("rat") >= MetaRules.RAT_FRAGMENTS_NEEDED and not (_data.restored as Array).has("rat"):
			(_data.restored as Array).append("rat")
	if GoalTracker.FINALE_LEVELS.has(level) and level < MetaRules.LAST_LEVEL:
		# drops a running refill countdown; a fresh one starts when unlimited lives end (IR-81)
		LivesClock.start_unlimited(_data, _now(), _now() + MetaRules.UNLIMITED_SECONDS)
