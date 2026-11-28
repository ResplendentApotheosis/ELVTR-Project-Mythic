# Text for `research/match-villains/level_agent_brief.md` (owner pastes; agents can't edit `research/`)

Owner decisions, chat 28 Nov 2026. Rules: IR-63 and IR-89 in `spec/interaction_rules.md`.

## 1. §5, JSON example: add `tutorial` before `story_beat`

On a tutorial level (2, 3, 5, 6) the example fragment is:

```json
  "tutorial": {"teach": "rocket", "hint_cells": [[3, 4], [4, 4]]},
  "story_beat": null,
```

Level 1 has `"story_beat": "intro"`. A level with no hint writes `"tutorial": null` or leaves the line out.

## 2. §5, Field meanings: add this line, and replace the `story_beat` line

- `tutorial`: optional; `null` or absent = no hint. Otherwise `{"teach": "<name>", "hint_cells": [[x,y],[x,y]]}`. `teach` is `"rocket"` (4 in a row), `"firecracker"` (L/T match), `"crane"` (2×2 match) or `"orb"` (5 in a row). `hint_cells` is exactly two different, orthogonally adjacent playable cells inside the board, each holding a piece at the start (not a content obstacle): the swap the player is shown. Used on tutorial levels (2, 3, 5, 6). It changes no rule (no extra move, no booster). Pin the tiles with `fixed_tiles` so that swapping the two cells really makes the taught special; the validator does not check this (owner decision, chat 28 Nov 2026, OQ-98 Option A).
- `story_beat`: `"intro"` (level 1 only: the opening comic, plays once before the board), `"mini"` (on hard levels and on level 17, the first freed creature), `"chapter"` (on finales), otherwise `null`. `"intro"` on any other level is invalid, `"mini"` anywhere else is invalid, and level 1 or level 17 with `null` is invalid.

## 3. §6 Validation checklist: add one line

- [ ] `story_beat` is `"intro"` on level 1 only, `"mini"` on hard levels and level 17, `"chapter"` on finales, else `null`; if `tutorial` is present, `teach` is one of rocket / firecracker / crane / orb and `hint_cells` is two different, adjacent, playable cells inside the board, each holding a piece (no `.`, no content obstacle), and the swap makes the taught special.

## 4. Note for §3 or §4 (levels 2 and 3)

2-layer brambles (OB02 `hp` 2) are fine on levels 2 and 3 (OB02 debuts at level 1 and allows 1–3 layers). Level 5 may list the brambles as a second goal (OB04 ×70 and OB02 ×4): easy levels have 1 or 2 goals.
