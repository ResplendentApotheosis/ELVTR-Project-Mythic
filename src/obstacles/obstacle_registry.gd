# Finds the behaviour script for an obstacle id (OB02, OB07...). Unknown ids get the default.
# One behaviour per OB ID lives in src/obstacles/obNN_<name>.gd.
# Check: test_damage_and_obstacles.gd (any obstacle test goes through here).
class_name ObstacleRegistry
extends RefCounted

const SCRIPTS: Dictionary = {
	"OB02": preload("res://src/obstacles/ob02_withered_bramble.gd"),
	"OB03": preload("res://src/obstacles/ob03_creep_moss.gd"),
	"OB05": preload("res://src/obstacles/ob05_lantern_shrine.gd"),
	"OB06": preload("res://src/obstacles/ob06_petrified_pillar.gd"),
	"OB07": preload("res://src/obstacles/ob07_mummified_creature.gd"),
	"OB10": preload("res://src/obstacles/ob10_creep_goo.gd"),
	"OB12": preload("res://src/obstacles/ob12_frozen_idol.gd"),
}

static var _cache: Dictionary = {}


static func behaviour(id: String) -> ObstacleBehaviour:
	if not _cache.has(id):
		var script: GDScript = SCRIPTS.get(id, null)
		_cache[id] = script.new() if script != null else ObstacleBehaviour.new()
	return _cache[id]
