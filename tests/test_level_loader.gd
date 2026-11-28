# Placeholders for the LevelLoader module (not built yet): how a level file marks the fragment (IR-31, OQ-71)
# and how a retry rebuilds it (IR-58). Each is pending, not failing; turn them into real tests when LevelLoader exists.
# Check: run the GUT suite; these show as Pending.
extends GutTest


func test_ir31_loader_marks_the_fragment_in_the_cocoon_whose_entry_has_fragment_true() -> void:
	pending("Needs LevelLoader: `objects` has OB07 at (2,2), (4,4), (6,6), only (4,4) with \"fragment\": true -> the fragment is in the cocoon at (4,4); (2,2) and (6,6) hold none")


func test_ir31_loader_spawns_the_fragment_on_the_nth_drop_item() -> void:
	pending("Needs LevelLoader: spawn.drop_items {\"type\":\"OB11\",\"total\":3,\"max_on_board\":1,\"fragment_item\":2} -> items 1 and 3 are plain hatchlings, item 2 carries the fragment")


func test_ir58_retry_level_26_puts_the_fragment_back_in_the_marked_cocoon() -> void:
	pending("Needs LevelLoader: level 26 fails with the fragment freed and fragments.rat 0 (SaveService); the retry has the fragment back in the cocoon whose entry has \"fragment\": true; fragment goal not done")


func test_ir58_retry_level_38_counts_drop_items_again_from_1() -> void:
	pending("Needs LevelLoader: level 38 with \"fragment_item\": 2, fragments.rat 3; the 2nd item is collected, the attempt fails, rat stays 3; on the retry the 2nd item spawned carries the fragment again; goal not done")
