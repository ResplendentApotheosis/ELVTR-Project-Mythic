# Level Design Agent Brief: Zodiac Match-3 (levels 1–100)

Public slim version: sections 3–6 of the full brief only. The background research is kept privately in the owner's Project.

How to use this file:
1. The level agent follows **sections 3–6** below.
2. The agent gets `levels_1_100_plan.csv`, one level (or one 5-level block) at a time.
3. The agent returns one Godot JSON file per level, in the schema in section 5.

Obstacles use **neutral behaviour IDs (OB02–OB17)**. Their Zodiac Forest names, looks and debut levels are in the GDD's obstacle table, which wins over this file and the plan.

---

## 3. Agent role (paste this into the agent)

You are the level designer for an original zodiac-themed match-3 game built in Godot 4. For each level in the plan you receive, produce one level JSON file that follows the schema below. Follow the plan's tier, moves, goals, new obstacle and board-shape intent. Then check the level against the validation rules before outputting it. You may adjust goal counts by ±20% and moves by ±2 if the board needs it; record every change in `designer_notes`. Do not invent new obstacle types. Use only IDs that have already been introduced (`new_obstacle` up to this level).

## 4. Design rules

**Teaching**
- Intro level: the new obstacle is the only goal. Place it where the first 2–3 obvious matches touch it. Keep the board simple and open, with fewer than 30% of cells blocked.
- The 3–5 levels after an intro should each include the newest obstacle, paired with one or two familiar ones.

**Rhythm**
- Every 5th level from 15 is `hard`; 25/50/75/100 are `finale`.
- The level after a hard level is easy (relief), and new obstacles debut there.

**Fair difficulty**
- Hard and finale boards are wide and open: no dead corners, no 1-cell-wide pockets that hold goals, and every goal reachable by normal matches.
- Make levels harder by raising goal counts and adding goals. Never starve moves below 16.

**Goals**
- Goal count must equal what is placed on the board (or what generators can produce). One unit = one obstacle fully gone (not one hit).
- Levels 1–50 have no colour goals: every goal is an obstacle goal.
- OB04 goal: every playable cell is a target, and seed cells (`s`) count from the start. The count must not exceed 90% of playable cells and must be more than the number of seed cells, so at least one new dew cell is needed.
- Drop items (OB11) need a clear fall path to a bottom exit.

**Hazards**
- Use at most one hazard type per level.
- Never place a hazard where a goal can only be reached through its beam or range.
- The OB09 beam must be visible: it must not be covered by any cell layer.
- OB09 (Nian's Eye) is not used in levels 1–50.

**Openings**
- Leave at least 3 valid matches available at the start, and no pre-made matches.
- Start the player with at least one area where a power-up is easy to make.

**Colours**
- Use 4 tile colours by default. Only use 3 on an intro level, if the board is very cramped. A 3-colour level names its colours, e.g. `"color_set": ["red", "yellow", "blue"]`; a 4-colour level must not have `color_set`.

**Variety**
- Don't repeat the same board shape in two consecutive levels.
- Mirror or rotate earlier shapes rather than copying them.

**Targets**
- Aim for these first-try win rates: intro 95%, easy 85–90%, medium 60–70%, hard 35–45%, finale 25–35%. These are design targets; your playtests decide the final moves.

## 5. Godot level JSON schema

```json
{
  "id": 15,
  "chapter": 1,
  "tier": "hard",
  "moves": 30,
  "colors": 4,
  "width": 9,
  "height": 9,
  "cells": [
    "#########",
    "#########",
    "#########",
    "#########",
    "#########",
    "#########",
    "#########",
    "#########",
    "#########"
  ],
  "underlay": [
    ".........", ".........", ".........", ".........", ".........",
    ".........", ".........", ".........", "........."
  ],
  "objects": [
    {"type": "OB06", "x": 1, "y": 0, "w": 1, "h": 4, "hp": 4},
    {"type": "OB06", "x": 7, "y": 0, "w": 1, "h": 4, "hp": 4},
    {"type": "OB02", "x": 0, "y": 6, "hp": 1},
    {"type": "OB03", "x": 3, "y": 4, "hp": 1}
  ],
  "fixed_tiles": [],
  "spawn": {"drop_items": null, "generators": null},
  "goals": [
    {"obstacle": "OB06", "count": 2},
    {"obstacle": "OB02", "count": 1},
    {"obstacle": "OB03", "count": 1}
  ],
  "story_beat": "mini",
  "designer_notes": "Columns flank the board so side matches grind them; blockers are spread evenly to keep it open."
}
```

**Field meanings**
- `cells`: `#` = playable cell, `.` = no cell. Row 0 is the top row.
- `underlay`: `.` = none; `1`–`3` = OB10 with that many hp; `s` = OB04 already covering that cell (a seed). No underlay on a `.` cell.
- `objects`: one entry per blocker. Multi-cell objects (OB05, OB06, OB16) use `w`/`h`, with `x`/`y` as the top-left cell. `hp` is 1–3 for OB03, OB05, OB07 and OB08, and 1–4 for OB06.
    - OB05 (lantern shrine) needs `"needs"`: a count per colour, e.g. `{"red": 2, "blue": 1}`. It is required, names at least one colour, every count is at least 1, and the colours are among the level's colours.
    - OB08 (paper-screen lantern) is a one-cell content obstacle with no piece: `{"type": "OB08", "x": 4, "y": 3, "hp": 2, "color": "red"}`. `hp` (the screen) is 1–3; `"color"` is required and one of the level's colours (trial).
- `fixed_tiles`: optional pre-placed colours or power-ups, e.g. `{"x":4,"y":8,"tile":"line_h"}`. Tile names: `red`, `yellow`, `blue`, `green`, `line_h`, `line_v`, `firecracker`, `crane`, `orb`. A Rocket, Firecracker or Crane takes an optional `"color"` (seeded random if absent); an `orb` tile has no `"color"`. Only on cells that would hold a piece; under moss is allowed (trial).
- No spawner cells in levels 1–50.
- `spawn.drop_items`: e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6]}`. On a fragment level whose fragment rides a drop item, add `"fragment_item": n` (the n-th item spawned carries it), e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6],"fragment_item":2}`. The first `max_on_board` items start in the top playable cells of different columns (seeded), only in columns whose top playable cell holds an uncovered plain piece, numbered left to right; every item collected in a move is replaced in the next refill, each in a different column (seeded) among the columns that get a new piece in that refill, until `total` have appeared (trial).
- Fragment levels: the fragment's cocoon is the OB07 entry in `objects` with `"fragment": true`, and `goals` lists the fragment as `{"obstacle": "OB07", "count": 1, "fragment": true}` (or `"OB11"` for a drop item). The fragment's cocoon or item also counts toward a plain OB07 / OB11 goal on the same level.
- `spawn.generators`: generator settings, e.g. for OB17.
- `story_beat`: `null`, `"mini"` (on hard levels) or `"chapter"` (on finales).

**Loading in Godot 4**
```gdscript
var level: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_%03d.json" % id))
```

## 6. Validation checklist (the agent runs this before outputting)
- [ ] Every row in `cells` and `underlay` has length `width`, and there are `height` rows.
- [ ] No object overlaps another object or a `.` cell, and multi-cell objects fit inside the board.
- [ ] Each obstacle goal's count equals the number of those obstacles placed; spawned items meet the goal; number of seed cells < OB04 count ≤ 90% of playable cells.
- [ ] On a fragment level, exactly one OB07 entry has `"fragment": true`, or `spawn.drop_items` has a `fragment_item` between 1 and `total`; a plain OB07 / OB11 goal's count includes the fragment's cocoon or item.
- [ ] Only introduced obstacle IDs are used, and there is at most one hazard type. Obstacles debut as in the GDD table (moss 7, creature 17).
- [ ] OB05 `needs`, OB08 `color` and fixed-tile colours are among the level's colours; OB05 `needs` is present, names at least one colour, and every count is at least 1.
- [ ] No underlay on a `.` cell; `hp` is within the limits above; `color_set` only on a 3-colour level; no `"color"` on an `orb` tile.
- [ ] Hard/finale boards have no isolated pockets: every playable cell connects to the main area through at least 2 neighbours.
- [ ] Drop items have an unblocked path to an exit column.
- [ ] Moves are within ±2 of the plan; any change is explained in `designer_notes`.
