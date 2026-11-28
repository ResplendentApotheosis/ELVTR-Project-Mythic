# Reads and writes the save Dictionary as JSON with a "schema_version" (IR-78). Writes are atomic: the JSON goes
# to "<path>.tmp" first and is then renamed over the save, so a killed app never leaves a half-written file.
# Check: tests/save_service/test_save_roundtrip_ir78.gd.
class_name SaveFile
extends RefCounted

const SCHEMA_VERSION: int = 1


## A brand-new player's save.
static func new_save() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"level": 1,                      # the next level to play (1..50; 51 once level 50 is won)
		"coins": MetaRules.START_COINS,
		"lives": MetaRules.MAX_LIVES,
		"refill_started_at": 0,          # unix seconds; 0 = no refill countdown running
		"unlimited_until": 0,            # unix seconds; unlimited lives run while the clock is before this
		"streak": 0,
		"chest_waiting": false,
		"fragments": {"rat": 0, "ox": 0},
		"restored": [],
		"boosters": {"hoof_tap": 0, "tail_slam": 0, "bamboo_dash": 0, "feather_fan": 0},   # free uses left
		"boosters_unlocked": [],
		"pre_boosters_unlocked": false,
		"pre_boosters": {"rocket_crane": 0, "firecracker": 0},   # free uses left
		"tried_levels": [],              # levels with at least one attempt started (for "first try")
		"seen_beats": [],
		"attempt_log": [],
		"life_log": [],
		"open_attempt": {},              # {"level": int, "first_try": bool} while an attempt runs, else {}
	}


## Loads the save at `path`. Missing or unreadable = a new player. If only the temp file survived an
## interrupted write, it is used.
static func read(path: String) -> Dictionary:
	var raw: Variant = _parse(path)
	if raw == null:
		raw = _parse(path + ".tmp")
	if raw == null:
		return new_save()
	return _fill_in(migrate(raw as Dictionary))


## Migration hook: turns an older save into the current schema. Version 1 is the first, so nothing to do yet.
static func migrate(data: Dictionary) -> Dictionary:
	var version: int = int(data.get("schema_version", 1))
	# when SCHEMA_VERSION goes up, add one step per version here, e.g. `if version < 2: ...; version = 2`
	data.schema_version = maxi(version, SCHEMA_VERSION)
	return data


## Writes `data` to `path` atomically (temp file, then rename). Returns true on success.
static func write(path: String, data: Dictionary) -> bool:
	var tmp: String = path + ".tmp"
	var f: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("SaveFile: cannot write %s" % tmp)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var from: String = ProjectSettings.globalize_path(tmp)
	var to: String = ProjectSettings.globalize_path(path)
	if DirAccess.rename_absolute(from, to) == OK:
		return true
	# some platforms refuse to rename over an existing file: remove it first (read() falls back to .tmp)
	DirAccess.remove_absolute(to)
	if DirAccess.rename_absolute(from, to) != OK:
		push_error("SaveFile: cannot rename %s to %s" % [tmp, path])
		return false
	return true


static func _parse(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	# JSON.new().parse() reports a bad file through its return code, without the engine error that
	# JSON.parse_string() prints (an invalid save is normal here: it means "start a new player")
	var json: JSON = JSON.new()
	if json.parse(f.get_as_text()) != OK:
		return null
	var parsed: Variant = json.data
	if not (parsed is Dictionary):
		return null
	return parsed


## Starts from a new save and copies in every known field whose type matches; JSON numbers come back as
## floats, so whole numbers are turned back into ints.
static func _fill_in(raw: Dictionary) -> Dictionary:
	var data: Dictionary = new_save()
	for key in data:
		if raw.has(key):
			var value: Variant = _ints(raw[key])
			if typeof(value) == typeof(data[key]):
				data[key] = value
	return data


static func _ints(value: Variant) -> Variant:
	if value is float and is_equal_approx(value, roundf(value)):
		return int(value)
	if value is Array:
		var out: Array = []
		for v in value:
			out.append(_ints(v))
		return out
	if value is Dictionary:
		var out_d: Dictionary = {}
		for k in value:
			out_d[k] = _ints(value[k])
		return out_d
	return value
