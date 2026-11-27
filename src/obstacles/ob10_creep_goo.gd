# OB10 creep goo (underlay): hit by a match on top of it, or by a special when nothing is
# above it (IR-15). Underlays are never hit by matches next to them.
# Check: test_damage_and_obstacles.gd IR-15 goo tests.
extends ObstacleBehaviour


func takes_adjacent_match_hits() -> bool:
	return false
