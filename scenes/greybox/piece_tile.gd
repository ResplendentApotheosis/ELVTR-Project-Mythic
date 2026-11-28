# Drawing of one piece on the board: a coloured shape, a special's symbol or a drop item, all drawn by
# ObstacleTheme (placeholder art today, final art later). Drawn around its own centre so it can scale in place.
# Check: F5 the greybox scene; every piece on the board is one of these.
class_name GreyboxPieceTile
extends Node2D

var look: Dictionary = {"kind": "plain", "color": "", "item": ""}
var size: float = 56.0


func set_look(new_look: Dictionary) -> void:
	look = new_look.duplicate()
	queue_redraw()


func _draw() -> void:
	ObstacleTheme.draw_piece(self, look, size)
