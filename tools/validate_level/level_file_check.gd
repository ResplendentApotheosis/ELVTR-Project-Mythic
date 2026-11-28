# Checks one level file: it exists, is a JSON object, is named level_NNN.json, and passes the REAL
# LevelLoader.validate (the brief's checklist plus the fragment checks, IR-63..IR-77). One String per failed check.
# Check: run the GUT suite (tests/validate_level/test_level_file_check.gd), or the CLI validate_level.gd.
class_name LevelFileCheck
extends RefCounted


## Every failed check on the level file at `path` (res://, user:// or an absolute path). [] = it passes.
static func check(path: String) -> Array[String]:
	var errors: Array[String] = []
	if not FileAccess.file_exists(path):
		errors.append("file not found: %s" % path)
		return errors
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		errors.append("not valid JSON (line %d: %s)" % [json.get_error_line(), json.get_error_message()])
		return errors
	if not json.data is Dictionary:
		errors.append("the JSON is not an object ({...}), so it is not a level")
		return errors
	# The file name's number. The real validator compares it with the level's id (IR-63) and names both.
	var file_id: int = file_number(path)
	if file_id < 0:
		errors.append("file name must be level_NNN.json (e.g. level_026.json), found %s" % path.get_file())
	for e in LevelLoader.validate(json.data as Dictionary, file_id):
		errors.append(String(e))
	return errors


## NNN from ".../level_NNN.json" (3 digits), or -1 if the name is not in that form.
static func file_number(path: String) -> int:
	var re: RegEx = RegEx.create_from_string("^level_([0-9]{3})[.]json$")
	var m: RegExMatch = re.search(path.get_file())
	return int(m.get_string(1)) if m != null else -1
