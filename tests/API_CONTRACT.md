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
