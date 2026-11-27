# OB05 lantern shrine (multi-cell content): takes one hit per special (IR-10, IR-11).
# Adjacent matches do not hit it; it is filled by pieces of colours it needs (not built yet).
# Check: test_damage_and_obstacles.gd test_ir11_two_by_two_shrine_is_multi_cell.
extends ObstacleBehaviour


func takes_adjacent_match_hits() -> bool:
	return false
