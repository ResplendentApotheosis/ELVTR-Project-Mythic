# One thing that happened on the board (a match, a clear, a fall...). MatchResolver returns a
# list of these in order; AnimationQueue and SfxQueue play them later. Fields: tests/API_CONTRACT.md §4.
# Check: every test in tests/match_resolver/ reads these events.
class_name BoardEvent
extends RefCounted

var type: String = ""
var cell: Vector2i = Vector2i(-1, -1)
var cells: Array[Vector2i] = []
var color: String = ""
var kind: String = ""
var source: String = ""
var data: Dictionary = {}


func _init(event_type: String = "") -> void:
	type = event_type
