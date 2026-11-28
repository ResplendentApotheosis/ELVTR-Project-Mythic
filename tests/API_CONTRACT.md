# API contract for the MatchResolver tests

The tests in `tests/match_resolver/` call exactly this API. godot-engineer implements it under `src/`; do not edit `tests/`. If a rule needs a change here, tell test-engineer.

Style: GDScript, static types, `class_name` on each class, no scenes/awaits/tweens/sounds. Coordinates are `(x, y)`, `x` = column, `y` = row, row 0 on top. Colours are plain strings: the four game colours are `"R"`, `"Y"`, `"B"`, `"G"`; a colour may be **any other string** (tests use unique filler colours like `"f3_4"`; the resolver treats every distinct string as its own colour; for Orb ties R, Y, B, G come first in that order, then any others).

## 1. Files and classes

| File | Class (`class_name`, extends `RefCounted`) |
|---|---|
| `src/board/board_model.gd` | `BoardModel` |
| `src/board/board_event.gd` | `BoardEvent` |
| `src/match/match_resolver.gd` | `MatchResolver` (static functions only) |
| `src/obstacles/ob02_withered_bramble.gd` etc. | one behaviour per script, internal (tests never touch them) |

## 2. BoardModel

```gdscript
func _init(width: int, height: int, seed_value: int = 1) -> void
var width: int
var height: int
var moves: int = 30
var auto_shuffle: bool = true      # false: the resolver never shuffles (tests set false except IR-33)
var goals: Array = []              # goal ids still wanted, e.g. ["OB02", "fragment"]; used by the Crane (IR-49)
var exit_columns: Array = []       # column numbers; empty = every column collects drop items (IR-30)
var spawners: Array = []           # Vector2i cells (not used by the first tests, OQ-35)
var palette: Array = ["R","Y","B","G"]   # colours used for refills
var rng: RandomNumberGenerator     # seeded from seed_value; the ONLY source of randomness
```

Setup (tests build boards with these; all start with every cell playable and empty):

```gdscript
func set_playable(x: int, y: int, playable: bool) -> void     # false also removes whatever is in the cell
func set_piece(x: int, y: int, kind: String, color: String = "") -> void   # kind "" = empty cell
func set_drop_item(x: int, y: int, item: String) -> void      # kind becomes "drop"; item "OB11" (lost hatchling) or "fragment"
func add_content(id: String, x: int, y: int, hp: int, w: int = 1, h: int = 1, fragment: bool = false) -> void
func set_overlay(x: int, y: int, id: String, hp: int) -> void    # e.g. "OB03" creep moss; keeps the piece in the cell
func set_underlay(x: int, y: int, id: String, hp: int) -> void   # e.g. "OB10" creep goo; keeps the piece
```

- Piece **kinds**: `""` (empty), `"plain"`, `"rocket_row"`, `"rocket_col"`, `"firecracker"`, `"crane"`, `"orb"`, `"drop"`. Rockets, Firecrackers and Cranes carry a colour; the Orb and drops have colour `""`.
- `add_content` = a content blocker/container (layer 2): `OB02` bramble (hp = layers), `OB05` shrine, `OB06` pillar, `OB07` cocoon/creature (`fragment = true` means a fragment is sealed inside), `OB12` idol. It occupies the whole `w x h` rectangle starting at `(x, y)` (top-left), removes pieces there, and the rectangle shares ONE hp. A cell holding content has kind `""` and is not "empty" for refill.
- `queue_refill` is deliberately **not** part of the contract: refills come from `board.rng` and `palette`, and **a refill must never create a match** (re-draw the colour if it would complete a 3-line or 2x2 with pieces already placed). This keeps tests deterministic without scripting colours.

Queries:

```gdscript
func is_playable(x: int, y: int) -> bool          # false when out of bounds too
func get_kind(x: int, y: int) -> String           # "" for empty, blocked, unplayable or out of bounds
func get_color(x: int, y: int) -> String
func get_drop_item(x: int, y: int) -> String      # "" if the cell is not a drop item
func content_id(x: int, y: int) -> String         # "" if none
func content_hp(x: int, y: int) -> int            # 0 if none (also 0 once cleared)
func overlay_hp(x: int, y: int) -> int            # 0 if none
func underlay_hp(x: int, y: int) -> int           # 0 if none
func collected_count(key: String) -> int          # keys: "fragment", "OB11", and any obstacle id freed/cleared as a goal, e.g. "OB07"
```

`collected_count("fragment")` goes up when a cocoon with a fragment is freed (IR-29) or a fragment drop item is collected; `"OB11"` when a hatchling is collected; `"OB07"` when a creature without a fragment is freed.

## 3. MatchResolver (all `static`, all instant, no awaits)

```gdscript
static func swap(board: BoardModel, from: Vector2i, to: Vector2i) -> Array[BoardEvent]
static func tap(board: BoardModel, cell: Vector2i) -> Array[BoardEvent]
static func settle(board: BoardModel) -> Array[BoardEvent]
static func has_possible_move(board: BoardModel) -> bool
```

- `swap(from, to)`: `from` is the start cell, `to` is the swap's target cell. Rules IR-01, IR-18, IR-22..27, IR-39, IR-52. Refused or snapped-back swaps change nothing, use no move, and return exactly one `invalid_swap` event. An accepted swap uses 1 move, then resolves everything (matches, specials, falls, refills, cascades) before returning.
- `tap(cell)`: IR-02. Tapping a non-special returns an empty array and changes nothing. A special tap uses 1 move.
- `settle(board)`: resolves a board that is already set up, with no move used: finds any existing matches (treated as cascade matches, IR-40/IR-42 placement), falls and refills, repeats until stable, then (only if `board.auto_shuffle`) shuffles if `has_possible_move` is false (IR-33). Tests use it to build cascade situations; cells set to `"X"` (empty) simply get filled.
- `has_possible_move(board)`: true if some swap would be accepted (makes a match, or involves a special) or any special is tappable.
- Obstacles never fall. Drop items and pieces fall straight down, with diagonal slides where a blocker stops a fill (IR-51); the order of slides is open (OQ-35), so tests only check "nothing playable is left empty".
- Any drop item that comes to rest on the bottom playable cell of its column (and the column is in `exit_columns` when that list is non-empty) is collected immediately (IR-30): count goes up, the cell empties, a `collected` event is returned.

## 4. BoardEvent

```gdscript
class_name BoardEvent extends RefCounted
var type: String
var cell: Vector2i = Vector2i(-1, -1)
var cells: Array[Vector2i] = []
var color: String = ""
var kind: String = ""
var source: String = ""
var data: Dictionary = {}
```

Events are returned in the order things happened. Types:

| type | fields | meaning |
|---|---|---|
| `swap` | `cells` = [from, to] | an accepted swap |
| `invalid_swap` | `cells` = [from, to], `data.reason` = `"no_match"` or `"refused"` | snap-back or refusal |
| `match` | `cells` = every piece in one match (including the piece that becomes a special), `color`, `data.shape` | one match found |
| `special_created` | `cell`, `kind`, `color` | a new special placed (position when created, before any fall) |
| `combo` | `cell` = target cell, `cells` = covered, `data.name` | two swapped specials made a combo (IR-22..26). Never emitted for Crane + special (IR-27) |
| `rocket_fire` | `cell` = rocket cell, `kind`, `cells` = every playable cell covered | a Rocket fires |
| `blast` | `cell` = centre, `cells` = every playable cell covered, `data.index` = 1 or 2 | one Firecracker blast |
| `orb_fire` | `cell`, `color` = colour cleared, `cells` | an Orb clears a colour |
| `crane_target` / `crane_takeoff` / `crane_landing` | `cell` | Crane flight, in this order; target and landing share the cell; take-off is the Crane's start cell |
| `clear` | `cells` = pieces removed, `source` = `"match"`, `"special"`, `"combo"`, `"orb"`, `"crane"` | pieces leaving the board. Includes the firing special's own cell when covered, the used-up Orb, and the Crane's start cell. Never lists fragments or drop items (IR-28) |
| `fall` | `data.moves` = Array of `{"from": Vector2i, "to": Vector2i}` | pieces fell |
| `refill` | `cells` | new pieces entered |
| `collected` | `cell`, `data.item` = `"fragment"`, `"OB11"` | a goal item collected |
| `shuffle` | - | free shuffle |

Hit events are optional; tests read hits from the board (`content_hp`, `overlay_hp`, `underlay_hp`).

## 5. Rules the tests assume (so they are not guesses)

- Specials made by a swap or a settle are placed after the match clears, at the cell given by IR-40; they may then fall like any piece, so tests read the position from `special_created`.
- Orb tap and Orb + plain swap clear only pieces whose colour matches (plain pieces; coloured-special handling is OQ-33, not tested).
- Crane target choice (IR-49): goal list is `board.goals`; a goal id is "unfinished" while an obstacle with that id (or, for `"fragment"`, a cocoon with a fragment; for `"OB11"`, a hatchling drop item) is on the board. Hits left = sum of `content_hp` of that goal's obstacles. With no unfinished goal, the nearest remaining obstacle of ANY layer (overlay such as moss, content blocker, or underlay such as goo) is aimed at (IR-49 spec text; tests currently only cover a content blocker); with none, a piece chosen with `board.rng`. "Closest" is only tested where every distance measure agrees (OQ-34). A Crane tapped or swapped with a plain piece uses `board.goals`; a Crane landing on a target hits it like a special (IR-09 / IR-48).
- Rules of damage (IR-09..15, 44, 45) are applied as written in `spec/interaction_rules.md`.

## 6. Test helpers (written and owned by test-engineer)

- `tests/helpers/board_builder.gd`: `blank(w, h, seed)` (every cell a unique filler colour, `auto_shuffle` off), `from_rows([...])`, `put(board, token, [[x, y], ...])`, `with_counts({...}, reserved)`, plus `snapshot`, `find_kind`, `find_drop`, `find_color`, `empty_cells`, `has_match`. Token legend is in that file's header.
- `tests/helpers/event_utils.gd`: queries over event arrays.

Run: `"$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` (run `"$GODOT_BIN" --headless --import` once so `class_name`s register).

## 2b. Round 2 additions (OQ-23..OQ-38 answers: IR-53, IR-54 and changed IRs)

New or newly relied-on `BoardModel` members (everything else in section 2 is unchanged):

```gdscript
func underlay_id(x: int, y: int) -> String        # already exists; now part of the contract. "" if none
func overlay_id(x: int, y: int) -> String         # already exists; now part of the contract
func set_dew_target(x: int, y: int) -> void       # NEW: marks a dew-goal target cell (OB04 goal)
func dew_targets_left() -> int                    # NEW: target cells that do not have dew yet
func set_shrine_needs(x: int, y: int, needs: Dictionary) -> void   # NEW: lantern shrine (OB05) at that cell still needs e.g. {"R": 3, "B": 1}
func shrine_needs(x: int, y: int) -> Dictionary   # NEW: what it still needs (zero entries may be missing)
```

- **Healing dew (OB04)** is an underlay: `set_underlay(x, y, "OB04", 1)`. "Has dew" = `underlay_id == "OB04"` and `underlay_hp > 0`. A match or special that clears a piece on dew sets the same underlay (id "OB04", hp 1) on every cell it cleared (IR-53). Dew is never damaged. A Crane landing on an uncovered target cell sets dew there. A target cell counts as covered once it has dew. Goal id for the Crane: `"OB04"`.
- **Shrine goal** id `"OB05"`: hits left = sum of `shrine_needs`. A Crane landing takes one piece off the colour needed most (tie: OQ-43, not tested). Tests create it with `add_content("OB05", x, y, total_needs, w, h)` then `set_shrine_needs`.
- **Hatchling goal** `"OB11"`: hits left = drop items still on the board (OQ-34); **dew goal** `"OB04"`: uncovered target cells (counted by `dew_targets_left`).
- **Locked pieces (IR-54):** a piece in a cell with `overlay_hp > 0` is refused by `swap` (either side), never falls, but can be matched. An emptied cell under a surviving overlay is refilled by normal falling.
- **Spawners:** `board.spawners` (Array of Vector2i) are extra entry points; every column still refills at its top playable cell (IR-51).
- **Event meaning for firing order** (no new event types): `rocket_fire.cell`, `blast.cell` (centre, `data.index` 1 or 2), `crane_takeoff.cell` and `orb_fire.cell` are the cell the special fires from: after a swap with a plain piece, its NEW cell (IR-39); for a set-off special, the cell where it was hit (IR-41); in Crane + special, the Crane's cell after the swap. `rocket_fire.kind` is `"rocket_row"` or `"rocket_col"` (also for Rockets converted by Orb + Rocket). Events appear in firing order: the swap's match (`match`, `clear`, `special_created`), then the swapped special, then set-off specials lowest cell first then left-most, each fully (fire events, then `clear`, `fall`, `refill`) before the next.
- **Firecracker timing (IR-17, IR-24):** `blast(1)`, `clear`, `fall`, `refill`, then every cascade (`match`, `clear`, `fall`, `refill`...) until stable, then `blast(2)`. Same for the 5x5 combo.
- **Orb + Orb (IR-26, IR-41):** other specials are cleared with no `rocket_fire` / `blast` / `crane_*` events; a set-off Orb is removed with no `orb_fire` event.
- **Orb counting (IR-18/19/25/47):** only plain pieces are counted, cleared or converted; coloured specials are left alone. Orb + drop item behaves as an Orb tap. Plain pieces under an overlay: OQ-42 (not tested).
- **Crane take-off (IR-48):** counts as a special covering its start cell, so the underlay under the Crane takes one hit when there is no overlay or blocker.

## 7. Round 3 additions (OQ-39..OQ-50 answers: IR-16 finale, IR-25, IR-41, IR-49, IR-53, IR-55)

New API (one function; everything else in sections 2 to 2b is unchanged):

```gdscript
static func fire_finale(board: BoardModel, directions: Array = []) -> Array[BoardEvent]   # on MatchResolver
```

- **Win finale (IR-16, IR-05):** the level was just won; `board.moves` leftover moves each become one Bamboo Rocket and fire one after another, each fully resolved (fire, `clear`, `fall`, `refill`, cascades) before the next. `board.moves` is 0 afterwards. With 0 moves left it returns no events.
- Each Rocket's direction is **row or column, picked from `board.rng`** (one draw per Rocket, in firing order). The same seed gives the same list. Odds and mix are OQ-53 (not tested).
- `directions` is the test seam for "the direction pick is stubbed": when not empty, element `i` (`"rocket_row"` or `"rocket_col"`) is used for the `i`-th Rocket instead of the RNG. Missing entries fall back to the RNG.
- Each Rocket emits a normal `rocket_fire` event: `kind` = `"rocket_row"` / `"rocket_col"`, `cell` = where it fires from, `cells` = the whole row or column. Where a finale Rocket is placed is the implementation's choice (not tested; the spec doesn't say).

Behaviour changes the tests now expect (no new members):

- **OQ-42 B:** the Orb (tap, swap, Orb + Rocket/Firecracker, tie-break counting) ignores plain pieces in a cell with `overlay_hp > 0`: not counted, not cleared (not in `orb_fire.cells`), not converted; their overlay is not hit.
- **OQ-43 B:** a Crane landing on a shrine with tied colour needs picks the colour with `board.rng` (not a fixed order). The tests only check "one of the tied colours", "same seed, same pick", and "both colours occur across seeds".
- **OQ-44 A:** for a swapped or matched special, `fall` and `refill` events come after the match's `clear` and before the special's first fire event; cascade `match` events come only after every waiting special has fired (set-off chains and converted Orb specials included).
- **OQ-46 B:** a special or match that clears a piece on dew sets dew (id `"OB04"`, hp 1) on every playable cell it covers, including cells with a content blocker (e.g. a bramble) and cells holding a drop item or fragment.
- **OQ-47 A:** one shared waiting list; the lowest, then left-most waiting special always fires next.
- **OQ-48 A:** Orb + Rocket/Firecracker: every converted piece leaves the board at once, its cell refills, and each fires from the cell it was converted in, lowest then left-most, each finishing (fall and refill included) before the next.
- **OQ-49 B:** a Crane landing on an uncovered dew target clears the piece there (it appears in a `clear` event with `source` `"crane"`) and the cell gets dew.
- **OQ-50 A (IR-55):** a special covering any cell of a lantern shrine lowers its hp (`content_hp`) by 1, at most once per special; `shrine_needs` does not change.

## 8. Round 4 additions (OQ-51..OQ-58 answers: IR-02, IR-16, IR-39, IR-48, IR-50, IR-53, IR-54, IR-55)

New API: one event type.

| type | fields | meaning |
|---|---|---|
| `shrine_lit` | `cell` = the shrine's top-left cell | a lantern shrine (OB05) became lit: it needs no more colours, or its hp reached 0 (OQ-55 A). Emitted once per shrine, in the resolve that lit it |

Behaviour changes the tests now expect (no new members):

- **OQ-54 A (IR-39, IR-50, IR-48):** when a swap makes a match, the swapped Rocket/Firecracker/Crane is lifted off the board at the moment the match clears (like a set-off special). Its cell is empty in the fall, so a column loses one extra piece (IR-39: column 4 pieces from (4,0)-(4,3) land in (4,2)-(4,5)) and the new pieces include that cell. It then fires from the cell it sat in right after the swap (`rocket_fire.cell`, `blast.cell`, `crane_takeoff.cell`), so a swapped row Rocket fires along the row of the cell it moved INTO. Event order: `match`/`clear`, `fall`, `refill`, fire events, then cascades. A swap that makes no match keeps the old behaviour (the special fires at once, no lifting). Matched specials were already lifted; the match `clear` event is expected to list only the matched PLAIN pieces: IR-50 counts 2 + 9 = 11 cleared pieces, so the lifted special's own cell is not counted in the match clear (code currently also lists it: 12).
- **OQ-55 A (IR-55, IR-48, IR-49, IR-14):** each piece of a colour the shrine still needs, in a match, with its own cell orthogonally next to a shrine cell, lowers `shrine_needs[colour]` by one; colours not needed fill nothing; a Crane landing takes one piece off the most-needed colour and does NOT lower `content_hp`; a special lowers `content_hp` by 1 (once per special). Lit = all needs 0 or `content_hp` 0: emit `shrine_lit`. What a lit shrine does on the board afterwards, whether matches also lower hp, and whether non-touching pieces of the match count: OQ-59 (settled in section 9).
- **OQ-56 A (IR-53, IR-15):** dew spreading onto a cell with goo: the goo takes its hit from that match or special first; the cell gets dew only if the goo was removed; otherwise the goo stays (`underlay_id` "OB10", reduced hp) and the cell gets no dew. A cell with moss over goo: moss takes the hit, goo untouched, no dew.
- **OQ-57 A (IR-02, IR-33, IR-40, IR-54):** a special created or lying in a cell with an overlay is locked: `swap` refuses it (either side), `tap` returns no events and uses no move, it never falls, `has_possible_move` does not count it. It still fires when another special covers it or when it is matched by colour.
- **OQ-53 A / OQ-58 A (IR-16 finale):** each Rocket's direction is one `board.rng.randi_range(0, 1)`-style draw (the FIRST draw of that Rocket; `0` = row; the test accepts `randi_range(0,1)` or `randf() < 0.5`, either mapping, as long as it is the first call on `board.rng` in `fire_finale`); then the cell is a second draw among uncovered `plain` pieces. A `directions[i]` stub replaces the direction (it may or may not consume a draw: not tested). Odds 48-52% over seeds 1-1000 x 10 Rockets (3x3 board, 12-colour palette). Coins (20 + 5 per Rocket) are not computed by MatchResolver and are not tested here. The fallback cell and settling between Rockets: OQ-60 (pending).

Test helper change: `BB.add_shrine(board, x, y, needs, w, h, hp)` takes an optional hp (default: total needs). New `EV.fall_map`, `EV.count_between`, `EV.sequence` in `tests/helpers/event_utils.gd`.

## 9. Round 5 additions (OQ-59..OQ-61 answers: IR-14, IR-16, IR-49, IR-50, IR-55)

New API: an optional third argument on the finale (test stub, like `directions`).

```
static func fire_finale(board: BoardModel, directions: Array = [], cells: Array = []) -> Array[BoardEvent]   # on MatchResolver
```

`cells[i]` (a `Vector2i`) replaces Rocket i's placement cell: the replaced plain piece in the normal case, or the fallback cell when no uncovered plain piece is left. Like `directions`, a stub may or may not consume an RNG draw (not tested).

Behaviour the tests now expect:

- **A lit shrine is removed (OQ-59 A c).** When `shrine_lit` is emitted, `content_id(x, y)` is `""` for every cell of the shrine rectangle and `content_hp` is 0. Those cells are ordinary playable cells: after the board settles each holds a `plain` piece that can be swapped, and none is empty. A removed shrine is not an unfinished `"OB05"` goal, so the Crane never targets its old cells. The `shrine_lit` event is still emitted once, at the shrine's top-left cell, BEFORE the `fall` that fills its cells (a match that lights it: `clear`, `shrine_lit`, `fall`, `refill`, then any lifted special's fire).
- **Matches fill the shrine through any touching piece (OQ-59 A a).** If at least one piece of a match is orthogonally next to a shrine cell, every piece of that match whose colour the shrine still needs fills one need (non-touching pieces included; colours not needed fill nothing). Matches never lower `content_hp` (IR-14).
- **Lifted coloured specials count (OQ-61 A).** A Rocket/Firecracker/Crane that is part of the match counts as a piece of its colour for the shrine, although it is lifted and not listed in the match `clear`.
- **Fallback finale Rocket (OQ-60 A a).** With no uncovered plain piece, the Rocket appears on a (seeded) playable cell replacing nothing: no `special_created` event with `data.finale`; it fires from that cell; a piece there is cleared, a Firecracker/Rocket/Crane there is set off, a fragment or drop item stays, the top layer (moss overlay or bramble layer) takes one hit.
- **One Rocket at a time (OQ-60 A b).** The whole resolution of Rocket i (fire, `clear`, `fall`, `refill`, set-off specials and their blasts, cascades) comes before any event of Rocket i+1; Rocket i+1's direction and cell are drawn on the settled board.

## 10. GoalTracker (round 6: IR-56, IR-57, IR-59, IR-60, IR-61, IR-62 and the goal parts of IR-14, 16, 29, 30, 31, 49, 53, 55)

Tests: `tests/goal_tracker/`, helpers `tests/helpers/goal_test_base.gd`. The tests load the classes by path, so a missing file fails a test with a clear message. Nothing here changes a MatchResolver call that has no tracker attached: every existing test must keep passing.

### 10.1 Files and classes

| File | Class (`extends RefCounted`) |
|---|---|
| `src/goals/goal_tracker.gd` | `GoalTracker` |
| `src/boosters/booster_service.gd` | `BoosterService` (static functions only; only the four calls in 10.6 are assumed) |

### 10.2 GoalTracker (instance)

```gdscript
func _init(goals: Array, level: int = 1) -> void
    # goals: Array of Dictionary, e.g. {"obstacle": "OB07", "count": 1, "fragment": true}; "fragment" is optional (default false)
var lives: int          # the attempt's lives (SaveService loads and saves it); the tracker lowers it on a fail
var coins: int          # coins available for continues (SaveService wires it)
func observe(event: BoardEvent) -> void      # MatchResolver / BoosterService feed every event they append (see 10.4)
func goal_units_done(index: int) -> int      # units finished for goals[index] (0..count)
func goal_units_total(index: int) -> int     # goals[index].count
func is_goal_done(index: int) -> bool
func is_won() -> bool                        # every goal done (the fragment goal included)
func moves_ran_out(board: BoardModel) -> void   # called by the resolver when board.moves hits 0 and the level is not won (10.4, 10.5)
func offer_price() -> int                    # price of the continue offer shown now: 300 (1st), 500 (2nd..5th); 0 = no offer
func accept_offer(board: BoardModel) -> bool # false if no offer or coins < price; else coins -= price, board.moves += 5
func decline_offer() -> void                 # attempt ends as a fail
func quit() -> void                          # attempt ends as a fail, no offer (IR-38)
```

Static (pure, used by LevelLoader and the validator):

```gdscript
static func win_coins(finale_rockets: int) -> int                          # 20 + 5 * rockets (IR-16, IR-56)
static func goal_errors(level: int, tier: String, goals: Array) -> Array   # [] = valid (IR-59, IR-31, IR-61)
static func goal_count_errors(goals: Array, board: BoardModel, spawn: Dictionary = {}) -> Array    # [] = every goal count equals the obstacles placed (IR-61, IR-31); `spawn` = the level file's "spawn" object
```

- `tier` is `"intro"`, `"easy"`, `"medium"`, `"hard"` or `"finale"`: intro exactly 1 goal, easy 1-2, medium 2-3, hard 3-4, finale exactly 4. The fragment entry counts inside those numbers.
- `goal_errors` also rejects: a goal with a `"color"` key (the message contains "color" or "colour"), and a fragment level (26, 30, 33, 35, 38, 40, 45, 50) with no entry that has `"fragment": true`.
- `goal_count_errors` counts units, not hp: two 2x2 pillars of hp 4 are 2 OB06 units; 17 brambles are 17 OB02 units. **Round 7 rules (OQ-66, OQ-71):** (a) a dew (OB04) goal is valid when `count <= 0.9 * playable cells` (81 cells: 72 ok, 73 rejected; 70 cells: 63 ok, 64 rejected); (b) a fragment OB07 goal needs exactly one OB07 content with `fragment == true` on the board (none or two: error), and the plain OB07 goal's count includes it (3 placed OB07, one marked: plain count 3 valid, 2 rejected); (c) a fragment OB11 goal needs `spawn.drop_items.fragment_item` in `1..total` (missing or above total: error), and the plain OB11 count equals the OB11 drop items on the board plus `spawn.drop_items.total` (the fragment item is one of them). The third argument `spawn` is NEW (default `{}`); it holds `{"drop_items": {"type": "OB11", "total": 3, "max_on_board": 1, "fragment_item": 2}}`.

### 10.3 What counts as one unit (IR-61, IR-31)

`observe` maps events to goals. A goal matches by `obstacle` id (entries with `"fragment": true` are the fragment goal):

| event | counts |
|---|---|
| `obstacle_cleared` with `data.id` = `"OBxx"` (already emitted today) | +1 to every non-fragment goal with that id |
| `shrine_lit` (already emitted today) | +1 to every non-fragment `"OB05"` goal |
| `collected`, `data.item` = `"OB11"` (already emitted today) | +1 to every non-fragment `"OB11"` goal |
| `collected`, `data.item` = `"fragment"` (already emitted today) with a **new field** `data.carrier` = `"OB07"` (freed cocoon) or `"OB11"` (drop item) | +1 to the fragment goal AND +1 to every non-fragment goal whose `obstacle` equals the carrier (IR-31, IR-34) |

A goal never goes above its `count`.

### 10.4 What MatchResolver (and BoosterService) must add

1. `BoardModel.goal_tracker: GoalTracker = null`. When null, nothing below happens (old behaviour).
2. When not null: every event the resolver appends is passed to `goal_tracker.observe(event)` as it is appended (swap, tap, settle, cascades, `fire_finale` too). **CHANGED (round 7, OQ-64 changed + OQ-72): the resolver does NOT stop when the last goal gets done.** The rest of that move plays out in full (rest of the match or special, falls, refills, waiting specials, both Firecracker blasts, flying Cranes, cascades, free shuffle). Only once the move has fully settled, if `goal_tracker.is_won()`, it appends one last event, `win`, with `data.moves_left = board.moves`; `win` is the LAST event of that call. A goal done part-way stays done. Event order examples: `match, fall, refill, win`; Firecracker tap `blast, fall, refill, blast, fall, refill, win`; a lifted Firecracker swap `match, fall, refill, blast, fall, refill, blast, fall, refill, win`; a free `shuffle` comes before `win`. Coins come only from the win (`win_coins(moves_left)`), not from extra clears. `GoalHook.stopped` / early-return in `cascade`, `double_blast`, `stabilise` must go.
3. **New field** on the existing `collected` event for a fragment: `data.carrier` (see 10.3). `data.item` stays `"fragment"`. A freed non-fragment cocoon keeps emitting `obstacle_cleared` with `data.id` `"OB07"`.
4. `shrine_lit` must be emitted exactly once per shrine and `obstacle_cleared` must NOT also be emitted for the shrine (so it is not counted twice).
5. Fail: at the end of `swap` (accepted swaps only) and `tap` (special taps only), after everything has settled, if `board.moves <= 0` and the tracker is not won: call `goal_tracker.moves_ran_out(board)` and append a `fail` event with `data.offer_price = goal_tracker.offer_price()` (0 = no offer). Never emitted for `invalid_swap`, a tap that does nothing, `settle`, `fire_finale` or a booster (IR-57, IR-62).
6. The finale stays a separate call: after a `win` the caller runs `MatchResolver.fire_finale(board)` (one Rocket per leftover move, IR-16). Win coins = `GoalTracker.win_coins(moves_left)`.
7. Moves: unchanged (`board.moves` is the source of truth; an accepted swap and a special tap each use 1; cascades, snap-backs, refused swaps, shuffles and boosters use 0).

### 10.5 Continue offers and lives (IR-37 prices, IR-60)

- `moves_ran_out(board)`: if fewer than 5 offers were accepted, an offer becomes pending (`offer_price()` 300 for the first, 500 for 2 to 5). Otherwise (6th time) no offer is pending and the attempt ends in a fail at once: `lives -= 1` (not on finales, levels 25 and 50).
- `accept_offer`: see 10.2. A player with fewer coins than the price still sees the offer (`offer_price()` stays above 0) but `accept_offer` returns false and nothing changes.
- A fail (declined offer, 6th run-out, `quit()`) lowers `lives` by 1, at most once per attempt, and not at all on levels 25 and 50. Accepting an offer and winning never cost a life.
- `decline_offer()` and `quit()` clear the pending offer.

### 10.6 BoosterService (only what IR-34, IR-35, IR-36, IR-57, IR-62 need)

```gdscript
static func hoof_tap(board: BoardModel, cell: Vector2i) -> Array[BoardEvent]
static func tail_slam(board: BoardModel, center: Vector2i) -> Array[BoardEvent]
static func bamboo_dash(board: BoardModel, direction: String, index: int) -> Array[BoardEvent]   # "row" or "col" plus the row/column number (a diagonal form is not tested here)
static func feather_fan(board: BoardModel) -> Array[BoardEvent]
```

They use no move, act like specials per IR-34/36, settle the board (IR-32), feed the tracker like the resolver (a `win` event can end the call), and never emit `fail`. If boosters get their own contract later, tell test-engineer so these tests can move.

### 10.7 Test helpers

`tests/helpers/goal_test_base.gd` (`extends GutTest`): `track(board, goals, level)` (creates the tracker and sets `board.goal_tracker`), `loose_tracker`, `tracker_static`, `booster`, `prime_row_match` / `swap_row_match(board, cx, cy)` (a 3-in-a-row swap clearing (cx-1..cx+1, cy) with fillers around it), `cascade_board` / `swap_cascade` (a swap whose fall forms a cascade match next to (6,6)), `obstacle_goal(id, count, fragment)`.

### 10.8 Dew goals (round 7, OQ-66 trial) - NEW API

- A dew level: every playable cell is a dew target (`set_dew_target` on each; the LevelLoader's job; test helper `BB.dew_level(board, bare_cells)` does it and gives dew to every cell except `bare_cells`). `dew_targets_left()` = playable cells without dew.
- NEW `GoalTracker.attach(board: BoardModel) -> void`. Called by whoever starts an attempt (LevelLoader; the test helper `track_dew`). After it, `goal_units_done(i)` of an `"OB04"` goal = the number of playable cells that have dew on that board RIGHT NOW (seed cells counted from the start, no double counting, kept up to date after every move; capped or not at `count` is OQ-73, not tested), and `is_goal_done` / `is_won` use it, so a move that gives the last cells dew ends in `win`. How it reads the board (live reference, a `dew_given` event, ...) is the coder's choice.
- `track()` in `goal_test_base.gd` is unchanged; `track_dew()` = `track()` + `attach(board)`. Set the seeds on the board BEFORE `track_dew`.
- `goal_count_errors` for OB04: see 10.2.

## 11. LevelLoader (round 8: IR-63 to IR-77, IR-31 and IR-58 level-file parts)

Tests: `tests/level_loader/`, helpers `tests/level_loader/level_fixtures.gd` (level dictionaries) and `tests/level_loader/level_loader_test_base.gd` (loads the classes by path, so a missing file fails a test with a clear message). The tests use only the calls below. godot-engineer owns the code, test-engineer owns the tests.

### 11.1 Files and classes

| File | Class (`extends RefCounted`) |
|---|---|
| `src/game/level_loader.gd` | `LevelLoader` (static functions only) |
| `src/game/level_attempt.gd` | `LevelAttempt` (plain data, one attempt) |

```gdscript
class_name LevelAttempt
var level_id: int
var seed_value: int                     # the seed this attempt used (IR-72); board.rng is seeded from it
var level: Dictionary                   # the level data it was built from
var source_path: String = ""            # "" when built from a Dictionary
var board: BoardModel                   # starting board, moves = level.moves, palette = the level's colours
var tracker: GoalTracker                # built from level.goals, level id passed in; board.goal_tracker == tracker;
                                        # attach(board) already called when the level has an OB04 goal
var fragment_guardian: String = ""      # "rat" on a level with a "fragment" field, else ""
```

### 11.2 LevelLoader (all `static`)

```gdscript
static func level_path(id: int) -> String                                            # "res://levels/level_%03d.json"
static func load_level(level: Dictionary, options: Dictionary = {}) -> LevelAttempt   # never validates; assumes a valid level
static func load_file(path: String, options: Dictionary = {}) -> LevelAttempt         # JSON file (numbers arrive as floats: cast them); null if missing or not JSON
static func retry(previous: LevelAttempt, options: Dictionary = {}) -> LevelAttempt   # IR-58, IR-71
static func validate(level: Dictionary, file_id: int = -1) -> Array                   # [] = valid; else Strings (11.4)
```

`options` keys (all optional):

| key | type | meaning |
|---|---|---|
| `seed` | int | use this seed (IR-72). Absent: a new random seed |
| `pre_specials` | Array of String | `"rocket"`, `"crane"`, `"firecracker"`: pre-level / streak-chest specials placed on the finished starting board (IR-77) |
| `stub_drop_columns` | Array of int | test seam: the columns the seeded draw picks for the starting drop items, in draw order (IR-75). Items are still numbered left to right |
| `stub_special_cells` | Array of Vector2i | test seam: cell replaced by the i-th pre-level special instead of the seeded pick (IR-77) |
| `stub_tie_pick` | String | test seam: `"row"` or `"column"`: the 50/50 Rocket tie draw (IR-77, IR-86) |

`retry(previous, options)` rebuilds from `previous.source_path` (re-reads the file) when it is not empty, else from `previous.level`. The new attempt has a new seed (never `previous.seed_value`, unless `options.seed` says so) and copies `previous.tracker.lives` and `previous.tracker.coins` (those belong to SaveService, which wires them in later); every other tracker value starts fresh (offers back to the 1st, IR-71).

Level dictionary: exactly `level_agent_brief.md` section 5. Colour names `"red"`, `"yellow"`, `"blue"`, `"green"` become `"R"`, `"Y"`, `"B"`, `"G"` on the board. `colors` 4 = all four, `colors` 3 = the three in `color_set`.

### 11.3 What the loader builds (new members, everything else is the BoardModel of sections 2 and 2b)

```gdscript
# on BoardModel
func content_color(x: int, y: int) -> String     # OB08 paper-screen lantern colour as "R","Y","B","G"; "" otherwise
var drop_total: int = 0                          # spawn.drop_items.total (0 = no drop items)
var drop_max_on_board: int = 0
var drop_fragment_item: int = 0                  # spawn.drop_items.fragment_item (0 = none)
var drop_spawned: int = 0                        # drop items placed so far in this attempt (the starting ones count); MatchResolver adds to it later
```

- `cells` and `underlay` as IR-64 / IR-65: `#` playable, `.` not playable; underlay `1`-`3` = `set_underlay(x, y, "OB10", hp)`, `s` = `set_underlay(x, y, "OB04", 1)`.
- Dew goal (an `"OB04"` goal in `goals`): every playable cell is a dew target (`set_dew_target`), then `tracker.attach(board)`.
- Objects: OB02, OB05, OB06, OB07, OB08, OB12 = `add_content(id, x, y, hp, w, h, fragment)` (`w`, `h` default 1; `"fragment": true` on an OB07 entry sets the fragment flag); OB05 also `set_shrine_needs` with the `needs` colours converted to `"R"`.. letters; OB08 colour readable by `content_color`; OB03 = `set_overlay(x, y, "OB03", hp)`, keeps a plain piece under it.
- Order: shape, underlay, objects, fixed tiles, plain fill (seeded), drop items (IR-75), then pre-level specials (IR-77). So the same level and seed with and without `pre_specials` gives the same board except the cells the specials replaced.
- Fixed tiles (IR-76): `red`/`yellow`/`blue`/`green` = plain piece; `line_h` = `"rocket_row"`, `line_v` = `"rocket_col"`, `firecracker`, `crane` with the entry's `"color"` or a seeded colour; `orb` = `"orb"` (no colour).
- Starting drop items: kind `"drop"`, `get_drop_item` = `"OB11"`, or `"fragment"` for item number `fragment_item` (items numbered left to right, 1-based).
- Fragment cocoon: `board.get_content(x, y).fragment` (existing `BoardContent.fragment`).

### 11.4 Validator messages

`validate(level, file_id)` returns one String per problem. Each String starts with the IR it breaks, e.g. `"IR-64: row 3 of cells has 8 characters, width is 9"`. Problems found by `GoalTracker.goal_errors` / `goal_count_errors` (IR-59, IR-61, IR-31) are included as they are, prefixed with `"goals: "` (the tests only check that the list is not empty for these). `file_id` >= 0 is the number in the file name; a different `id` in the level is an IR-63 error. The validator builds a board with the loader (default options) only when the shape checks passed. Plan moves and plan tiers are read from `res://research/match-villains/levels_1_100_plan.csv`.
