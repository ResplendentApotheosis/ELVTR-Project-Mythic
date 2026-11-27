# A special waiting to fire: its kind, colour and cell. `on_board` = it is still sitting in that
# cell (tapped or swapped); false = it already left the board (matched or set off by a chain).
# Check: used by SpecialFiring; see test_special_effects.gd IR-41 chain tests.
class_name FireOrder
extends RefCounted

var kind: String = ""
var color: String = ""
var cell: Vector2i = Vector2i(-1, -1)
var on_board: bool = false


func _init(special_kind: String = "", special_color: String = "", at: Vector2i = Vector2i(-1, -1), still_on_board: bool = false) -> void:
	kind = special_kind
	color = special_color
	cell = at
	on_board = still_on_board
