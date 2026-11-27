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
- Goal count must equal what is placed on the board (or what generators can produce).
- OB04 spread goals must not exceed 90% of playable cells.
- Drop items (OB11) need a clear fall path to a bottom exit.

**Hazards**
- Use at most one hazard type per level.
- Never place a hazard where a goal can only be reached through its beam or range.
- The OB09 beam must be visible: it must not be covered by any cell layer.

**Openings**
- Leave at least 3 valid matches available at the start, and no pre-made matches.
- Start the player with at least one area where a power-up is easy to make.

**Colours**
- Use 4 tile colours by default. Only use 3 on an intro level, if the board is very cramped.

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
    {"obstacle": "OB06", "count": 4},
    {"obstacle": "OB02", "count": 26},
    {"obstacle": "OB03", "count": 30}
  ],
  "story_beat": "mini",
  "designer_notes": "Columns flank the board so side matches grind them; blockers are spread evenly to keep it open."
}
```

**Field meanings**
- `cells`: `#` = playable cell, `.` = no cell. Row 0 is the top row.
- `underlay`: `.` = none; `1`–`3` = OB10 with that many hp; `s` = OB04 already covering that cell (a seed).
- `objects`: one entry per blocker. Multi-cell objects (OB05, OB06, OB16) use `w`/`h`, with `x`/`y` as the top-left cell.
- `fixed_tiles`: optional pre-placed colours or power-ups, e.g. `{"x":4,"y":8,"tile":"line_h"}`.
- `spawn.drop_items`: e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6]}`.
- `spawn.generators`: generator settings, e.g. for OB17.
- `story_beat`: `null`, `"mini"` (on hard levels) or `"chapter"` (on finales).

**Loading in Godot 4**
```gdscript
var level: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_%03d.json" % id))
```

## 6. Validation checklist (the agent runs this before outputting)
- [ ] Every row in `cells` and `underlay` has length `width`, and there are `height` rows.
- [ ] No object overlaps another object or a `.` cell, and multi-cell objects fit inside the board.
- [ ] Each goal count is achievable: placed hp/items ≥ the goal; spawned items meet the goal; OB04 count ≤ 90% of playable cells.
- [ ] Only introduced obstacle IDs are used, and there is at most one hazard type.
- [ ] Hard/finale boards have no isolated pockets: every playable cell connects to the main area through at least 2 neighbours.
- [ ] Drop items have an unblocked path to an exit column.
- [ ] Moves are within ±2 of the plan; any change is explained in `designer_notes`.
