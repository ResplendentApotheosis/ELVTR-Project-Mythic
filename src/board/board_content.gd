# One content-layer obstacle (layer 2): a blocker or container such as a bramble or a pillar.
# A multi-cell obstacle is ONE BoardContent shared by every cell it covers, so it has one hp.
# Check: tests/match_resolver/test_damage_and_obstacles.gd (IR-10 pillar tests).
class_name BoardContent
extends RefCounted

var id: String = ""
var hp: int = 0
var rect: Rect2i = Rect2i()      # top-left cell and size in cells
var fragment: bool = false       # true = a soul fragment is sealed inside (cocoon, IR-29)


func _init(content_id: String = "", content_hp: int = 0, area: Rect2i = Rect2i(), has_fragment: bool = false) -> void:
	id = content_id
	hp = content_hp
	rect = area
	fragment = has_fragment


## Every cell this obstacle covers.
func cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			out.append(Vector2i(x, y))
	return out
