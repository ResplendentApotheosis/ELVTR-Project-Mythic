# Zodiac Forest — Match-3 GDD (MVP)

2026-11-25 · @Angeline

## Overview

Zodiac Forest is a 2D chibi match-3 where four friends clear a spreading curse from their forest, free mummified creatures, and recover the scattered souls of the 12 Zodiac guardians. The MVP ships levels 1–60: the journey to the Jade Temple, the Proboscis Monkey's revelation, and the full restoration of the first guardian, the Rat, at level 50.

**Pitch:** Royal Match-grade feel and layered boards, wrapped in a Chinese-zodiac rescue story whose rewards (soul fragments) carry into every future game in the Zodiac world.

**Design pillars**

1. **Feel first.** Every swap, fall and blast is fast, bouncy and loud; feel is measured, not guessed.
2. **Every board is a rescue.** Goals are framed as freeing creatures and dispelling creep, never "collect 30 blue".
3. **Layers make the puzzle.** Underlays, overlays and blockers turn colour-matching into small spatial puzzles.
4. **Story as reward.** A story beat on every hard level (every 5th from 15) and a chapter card every 25 levels.
5. **Souls carry forward.** Soul fragments are the shared currency of the whole Zodiac world (Part 2 games and PvP).

| Item | MVP decision |
|---|---|
| Levels | 1–60 (Rat restored at 50; 51–60 tease the Ox) |
| Platforms | Web (itch.io) and Android first; iOS later |
| Engine | Godot 4.7.x stable, GDScript |
| Art | 2D chibi, primary colours (tbc) |
| Monetization | None in MVP; prove retention first |
| Budget | Option A (lean, about US$210) until live feedback |
| Out of scope | Sort games, The Great Race and other Part 2 ideas (kept in the project's Part 2 backlog) |

## Research basis

This GDD now follows your Match Villains research pack (118 levels of footage plus a sound analysis): we copy MV's measured rhythm and feel, keep regular levels lighter than MV, and fix its top complaints. All MV names, art, characters and UI stay out.

**Research files (Mythic project, `research/match-villains/`)**

| File | Used in |
|---|---|
| `README.md` | Benchmarks, market context, design stance |
| `level_agent_brief.md` | Obstacle IDs OB02–OB17, level design rules, level JSON schema, validation checklist |
| `levels_1_100_plan.csv` | The level plan for 1–100 (tier, moves, goals, unlocks, board shape, target win rate) |
| `mv_level_log_1_40.md`, `mv_level_log_41_118.md` | Pacing benchmarks, debut levels, hardest levels |
| `mv_sound_analysis.md` | Feel, juice & sound |

**What the footage showed, and what we do with it**

| MV finding | Mythic decision |
|---|---|
| 4 tile colours through all 118 levels | 4 colours throughout (primary colours for the chibi style) |
| Moves 16–39, mostly 20–26 after level 26 | Moves 30 early, 24–26 mid, 21–25 later; never below 16 |
| New obstacle every 3–5 levels early, then every ~10, debuting on the level after a hard one | Same rhythm: 12 obstacles by level 56, 16 by level 96 |
| Hard level every 5th from 15, 3–5 goals | Hard every 5th from 15 with 3–4 goals; finales at 25/50/75/100 |
| Difficulty from goal load, not move starvation; hardest levels are open boards | Regular levels stay at 1–3 goals (MV's 4–5-goal regular levels caused its stalls at 59, 67, 87, 98) |
| Boosters unlock one at a time with free uses (11, 16, 22, 29) | Same unlock levels, themed to the story |
| Three-layer move sound; cascades every ~160 ms; shard-style breaks | Sound spec in Feel, juice & sound |
| Top complaints: pay-to-pass difficulty, 8–9 pop-ups before Play, double-pressure fail flow, lives lock-out, misleading ads | One optional continue, generous lives, a clean lobby, honest store video |
| 14-day "100 new levels" cycle and ~20 event types | Not feasible solo; at most 3 evergreen live-ops loops after launch |

**Market context (AppMagic estimates via the pack):** MV launched November 2024; ad-free, IAP-only; roughly US$25–36m lifetime IAP by end-2025. We copy design lessons, not its user-acquisition spend.

## Story & world

The Nian has cursed Zodiac Forest: a creeping decay spreads across it and wraps its creatures like mummies. Four friends set out for the Jade Temple to ask the 12 Zodiac guardians for help, only to learn the guardians have already fallen.

**Cast**

| Character | Role | Notes |
|---|---|---|
| 4 protagonists | Player's party; narrate levels and posters | Names, bios and designs from you; each needs a personality, catchphrase and colour |
| Proboscis Monkey | Guardian of the Jade Temple; guide from level 25 | Comic mentor with a big nose and bigger opinions |
| The Nian | Main villain | Folklore beast that fears red, fire and loud noise; never fought directly in the MVP |
| Nian's forces | Faces of the hard levels, shown in story cards | e.g. a Creep Wraith at 20, a Stone Golem at 40 |
| 12 Zodiac guardians | Turned to stone (or ice); souls shattered into fragments | Restored one by one; Rat first |
| Mummified creatures | Forest friends wrapped in creep | Freeing them is the most common level goal |

**How the folklore shapes play:** because the Nian fears red, fire and noise, the player's best tools are themed that way: firecracker specials, red lanterns that burn away creep, drum combos that shake loose stone.

**Story beats, levels 1–60**

| Level | Beat | Delivered as |
|---|---|---|
| 1 | Home is decaying; friends are being wrapped by creep. The four set out | Intro comic (4–6 panels) |
| 10 | First freed creature tells of a dark beast at the river | Short dialogue |
| 20 | First mid-boss guards the temple road; party breaks through | Hard level + story card |
| 25 | Jade Temple. Proboscis Monkey: the Nian defeated all 12 guardians; their bodies are stone, their souls scattered | Poster (big reveal); soul fragments unlock |
| 30 | Monkey joins as guide; the Rat fragment found at 26 begins to glow | Dialogue |
| 40 | Hard level: Nian's Stone Golem tries to smash the Rat's statue | Boss level |
| 50 | Rat guardian restored: the statue cracks, the Rat wakes and gives the party its blessing (first super power) | Poster + celebration |
| 51–60 | The Rat sniffs out the Ox's trail; first random fragments of other guardians | Dialogue; cliffhanger at 60 |

**Story choices to confirm** are listed under Open questions at the end of this doc.

## Core gameplay

Standard swap-to-match on a board up to 9×9 with 4 colours, four special pieces (taught on levels 2, 3, 5 and 6), and rescue-themed goals inside a move limit that never drops below 16.

**Rules**

- Swap two adjacent pieces; a swap that makes no match snaps back (no move used).
- 3+ in a row or column clears. Pieces fall, new ones drop from the top, cascades chain automatically.
- **4 colours** on every level (3 only on a very cramped intro level), as in MV's first 118 levels.
- Every level starts with at least 3 valid moves, no pre-made matches, and one area where a special is easy to make.
- No possible move: free shuffle with a short animation.
- Specials fire when matched, swapped or tapped (tap costs a move).
- Win: all goals done before moves run out. Leftover moves become Bamboo Rockets that fire for bonus coins ("Forest Festival" finale).
- **Fail flow (one step, no pressure):** one optional "+5 moves" for coins, then the retry screen. No "you'll lose event progress" warning.

**Pieces (4 colours):** red peach, yellow bell, blue fan, green leaf. Shapes differ as well as colours, for colour-blind players.

**Special pieces**

| Made by | Special | Tutorial level | Effect |
|---|---|---|---|
| 4 in a line | Bamboo Rocket | 2 | Clears its full row or column |
| L or T shape (5) | Firecracker | 3 | 3×3 blast, twice (noise scares the Nian) |
| 2×2 square | **Paper Crane** (signature) | 5 | Flies to a goal tile; its target is shown with a dotted path before it flies |
| 5 in a line | Jade Orb | 6 | Clears every piece of the colour it's swapped with |

The Paper Crane is the one "signature, telegraphed" twist the research recommends: always helpful, and always shows where it will land.

**Combos (swap two specials)**

| Combo | Result |
|---|---|
| Rocket + Rocket | Row and column cross |
| Rocket + Firecracker | 3-wide row and 3-wide column |
| Firecracker + Firecracker | 5×5 double blast |
| Crane + any special | Crane carries that special to a goal tile |
| Jade Orb + special | Every piece of the most common colour becomes that special and fires |
| Jade Orb + Jade Orb | Clears the whole board |

**Goals per level:** 1 on intro levels, 1–3 on regular levels, 3–4 on hard levels, 4 on finales. Goals are always obstacles to clear, free or collect (see the obstacle table); "collect N red" style goals are only used in tutorials.

## Board layers & obstacles

Obstacles use the research pack's neutral behaviour IDs (OB02–OB17), each given an original Zodiac Forest look and one of four element families. 12 debut in the MVP (levels 1–60) and 4 more by level 96, following `levels_1_100_plan.csv`.

**Cell layer model (top to bottom)**

| Layer | Holds | Cleared by |
|---|---|---|
| 3 · Overlay | Cover clusters, shutters | Adjacent matches |
| 2 · Content | A piece, a blocker, a container or a drop item | Matching / adjacent matches / specials |
| 1 · Underlay | Creep goo, healing dew | Matching on top of it |
| 0 · Floor | Open cell, no cell, spawner, exit | Fixed by level design |

**Element families (look and sound):** Earth = stone, wood, roots (deep knocks) · Water = ice, dew, goo (pitch glides) · Fire = lanterns, embers (crackle shards) · Air = feathers, chimes (whooshes, glassy ticks). These can later tie to the guardians' elements.

**Obstacle set**

| Debut | ID · behaviour | Mythic obstacle | Element | Rule |
|---|---|---|---|---|
| 1 | OB02 · breakable, layered | Withered bramble | Earth | Match next to it; up to 3 layers |
| 4 | OB04 · spread goal | Healing dew | Water | Matches made on dew spread it; cover the target cells (heals the forest) |
| 7 | OB03 · cover cluster | Creep moss | Earth | Match next to it to clear; fills whole areas |
| 10 | OB05 · colour lock | Lantern shrine | Fire | Collect the colours it shows to light it |
| 13 | OB06 · tall column | Petrified pillar | Earth | Ground down by adjacent matches |
| 17 | OB07 · container release | **Mummified creature** | Earth | Match next to it to unwrap and free the creature (the core rescue goal) |
| 22 | OB08 · shutter + colour | Paper-screen lantern | Fire | Open the screen, then match its colour to light it |
| 28 | OB10 · underlay clear | Creep goo | Water | Make a match on top to clear it |
| 34 | OB11 · drop item | **Soul fragment** (and lost hatchlings) | Air | Bring it to the bottom row to collect it |
| 41 | OB12 · two-hit | Frozen idol | Water | Needs 2 adjacent matches |
| 46 | OB09 · hazard, beam | Nian's Eye | Fire | Hit 3 times with specials; its visible beam destroys specials that cross it |
| 56 | OB15 · specials only | Terracotta minion | Earth | Only specials can damage it |
| 66 | OB14 · spreader source | Dew spring | Water | 3 adjacent matches make it spread dew |
| 76 | OB16 · multi-release | Bamboo nest | Air | Adjacent matches release many collectibles |
| 86 | OB13 · hazard, trap | Nian's Jar | Fire | Catches specials; needs 4 special hits |
| 96 | OB17 · generator (optional) | Wind chime | Air | 3 adjacent matches make it produce collectibles |

**Rules from the research brief**

- Intro level: the new obstacle is the only goal, placed where the first 2–3 obvious matches touch it; under 30% of cells blocked.
- The 3–5 levels after an intro each include it, paired with one or two familiar obstacles.
- New obstacles debut on the relief level right after a hard level.
- At most one hazard type (OB09 or OB13) per level; never put a goal behind a hazard's beam or range; the beam is always visible.
- Hazards arrive later than in MV (46 and 86) because they are MV's most-complained-about obstacles.

## Feel, juice & sound

Every move should sound and feel physical: a quiet input, a loud impact, then a brighter tail, with cascades landing on a steady ~160 ms pulse. The sound numbers below are measured from MV footage (`mv_sound_analysis.md`); the visual timings are starting targets until the video frames are measured.

**Every move is three sounds**

| Layer | When | Level | Character |
|---|---|---|---|
| Swap tick | 100–300 ms before the move registers | 10–12 dB below the hit | Soft, low (~400 Hz), ~115 ms decay |
| Match hit | 0–150 ms after | Loudest | Short, punchy (~570 Hz), ~90 ms decay |
| Collect ring | 250–300 ms after | Nearly as loud as the hit | Brighter (~970 Hz), ~200 ms tail as pieces fly to the goal counter |

Each layer is pitched above the last, so every move resolves upwards; the quiet swap means it can play hundreds of times without fatigue.

**Rhythm and materials**

- Cascade hits every 120–180 ms; if several land within ~40 ms, delay or drop some.
- Breaks are 3–7 tiny randomised "shard" hits 60–120 ms apart, never one sample.
- Randomise every sound: ±1–2 semitones, ±2 dB, 4–6 variants.
- Material by element: Earth = deep dry knocks with some resonance; Water = viscous pitch glides (rising when dew spreads, falling when goo clears); Fire = crackle-and-snap shards with an airy tail; Air = swept whooshes and glassy ticks.
- Big combos build in stages: a shimmer bed → rhythmic zaps → one big release → a separate final pop. The Paper Crane gets a rising charge and one crystalline ping.

**Visual timing (starting targets)**

| Moment | Target |
|---|---|
| Swap | 0.15 s, ease-out; invalid swap bounces back in 0.2 s |
| Match clear | Pop to 120%, gone in 0.12 s, particle burst in the piece's colour |
| Fall | Accelerating, columns staggered 0.03 s; land with 10% squash and one small bounce |
| Special created | 0.25 s merge and glow |
| Firecracker | 0.2 s blast, 4 px screen shake, short phone haptic |
| Combo callouts | "Great!" / "Amazing!" / "Festival!" at 3 / 5 / 8 cascades, plus a protagonist quip |
| Win finale | Leftover moves fire as rockets 0.15 s apart |
| Idle hint | After 5 s, a valid swap wiggles |

**Godot setup:** a pool of 8–12 `AudioStreamPlayer` voices; one `AudioStreamRandomizer` per sound family; separate SFX and Music buses, with music ducked 3–6 dB during big combos; shard sequences scheduled by a small timer queue. Record real objects for sources (ceramic cups, a wooden box, stirring honey, a cork pop): free, and they sound more ASMR than synthesised tones.

**Rule:** game logic resolves instantly; a separate animation and sound queue plays the results.

## Level progression

Levels follow `levels_1_100_plan.csv`: 25-level chapters with finales at 25, 50, 75 and 100, a hard level every 5th level from 15, and a relief level after each hard one where new obstacles debut. The MVP covers chapters 1–2 and the start of chapter 3 (levels 1–60).

*[Chart: Level progression · story trails and guardian restorations, levels 1–200]*

**Level tiers (from the plan and brief)**

| Tier | When | Moves | Goals | First-try win target |
|---|---|---|---|---|
| Intro | New obstacle debuts | 30 early, 25–26 later | 1 (the new obstacle) | 95% |
| Easy (relief) | After intros and hard levels | 28 early, 23–24 later | 1–2 | 85–90% |
| Medium | Between | 26 early, 21–22 later | 2–3 | 60–70% |
| Hard | Every 5th from 15 | 30 early, 24–25 later | 3–4 | 35–45% |
| Finale | 25, 50, 75, 100 | 32 / 27 / 26 / 26 | 4 | 25–35% |

**Fair difficulty:** hard and finale boards are wide and open (no dead corners or 1-cell pockets holding goals), so failing feels like bad luck, not confusion. Difficulty rises through goal counts, never by starving moves below 16. No two consecutive levels share a board shape.

**Chapters:** 1 (1–25) Journey to the Jade Temple · 2 (26–50) Rat's trail · 3 (51–75) Ox's trail begins · 4 (76–100) deeper forest. Each finale ends with a chapter story card; each hard level carries a mini story beat. A new backdrop every chapter.

**Your 20/50-level upgrade milestones** can sit on top of this; see Open questions on whether to align them to the 25-level chapters.

## Soul fragments

Fragments start at level 26, right after the temple reveal. The Rat's 8 fragments are scripted so it is restored at exactly level 50. After that, every hard level and about 1 in 5 other levels carry a fragment, weighted toward one "trail" guardian at a time, so 3 guardians are restored by about level 200 and the other 8 come later.

**Rules**

- A fragment level shows a glowing fragment icon on the map and level card, so players know before they play.
- Levels 26–33: the fragment is sealed in a creep cocoon (OB07 behaviour) and freed by adjacent matches. From level 34 (when drop items debut) it can also be an OB11 drop item that must reach the bottom row. Fail the level and the fragment stays for the retry.
- The Rat needs 8 fragments; every other guardian needs 12.
- **Trail guardian:** after 50, the story points to one guardian at a time. Each drop has a 70% chance of being for the trail guardian and 30% for a random other guardian.
- **Pity rule:** if 4 drops in a row miss the trail guardian, the next one is guaranteed for it.
- **No waste:** fragments for a guardian who is already restored become Soul Dust, used for hero upgrades in Part 2.
- Hard and finale levels always carry a fragment; intro levels never do (they teach one thing only), and the trail moves to the next guardian the moment one is restored.

**Schedule (target; tune with the level bot)**

| Levels | Fragment levels | Who they're for | Outcome |
|---|---|---|---|
| 1–25 | None | — | Journey to the temple |
| 26–50 | 26, 30, 33, 35, 38, 40, 45, 50 (scripted) | Rat 8/8 | **Rat restored at 50** |
| 51–110 | ~20 (12 hard + ~8 others) | Trail: Ox | **Ox restored around 110** |
| 111–165 | ~18 | Trail: Rabbit | **Rabbit restored around 165** |
| 166–200 | ~12 | Trail: Dog (already holds ~3 from random drops) | **Dog restored around 200** |
| 201+ | Continues, plus events and Part 2 games | Other 8 guardians (each already holding ~2 of 12 from the random 30%) | One guardian every ~50–60 levels |

**Arithmetic check:** about 55 drops from levels 51–200 × 70% ≈ 38 trail fragments, enough for 3 guardians (36). The remaining ~17 random drops leave each of the other 8 guardians at about 2 of 12, which keeps the later guardians back-ended.

## Meta & economy

The MVP economy is small and fair: coins, generous lives, boosters that unlock one at a time with free uses, and guardian powers as the big rewards. It deliberately avoids MV's top complaints. You design the wider meta (forest restoration); this section fixes only the numbers the levels depend on.

**Currencies and limits (starting values, tune in playtests)**

| Item | Rule |
|---|---|
| Coins | Start 500. Win = 20 + 5 per finale rocket |
| Lives | 5 max; lose one on fail; refill 1 per 20 min; 30 min of unlimited lives after each chapter finale |
| Continue | One optional "+5 moves" for 300 coins per attempt; no second pop-up |
| Win streak | 3 wins in a row: a chest drops a free Rocket and Crane onto the next board |
| Soul fragments | Not spendable; restore guardians |
| Soul Dust | From duplicate fragments; stored for Part 2 hero upgrades |

**Booster unlocks (MV's proven levels, our themes)**

| Unlock | Booster | Type | Effect | Free uses |
|---|---|---|---|---|
| 11 | Firecracker Pop | In-level | Smash one cell | 3 |
| 16 | Pre-level boosters | Pre-level | Start with a Rocket + Crane, or a Firecracker | 1 each |
| 22 | Bamboo Sweep | In-level | Clear one column | 1 |
| 25 | Monkey's Staff (story gift) | In-level | Remove one layer from any obstacle | 1 |
| 29 | Wind Fan | In-level | Shuffle the board | 1 |
| 50 | **Rat's Nibble** (first guardian power) | In-level | Rat gnaws through a whole row of obstacles | 3 |
| ~110 / ~165 / ~200 | Ox's Charge / Rabbit's Hop / Dog's Fetch | In-level | Column smash ignoring stone / swap any two pieces / pull a goal item to the counter | Post-MVP |

**Fairness rules (from the research)**

- At most one pop-up between the lobby and Play.
- No "pay to pass" spikes: hard levels are tuned by the level bot to their win targets, never above.
- After launch, at most 3 evergreen live-ops loops (for example a daily puzzle, a weekly event and a collection).

**Owner: you.** Forest restoration meta, collections and the protagonists' upgrade flow. The research recommends passive story cards over decoration chores; the save data already tracks levels, fragments and restored guardians.

## Art & audio direction

The art is 2D chibi characters with bright primary colours (tbc), set against a forest that visibly shifts from grey, creep-covered decay to lush colour as the player wins. That contrast is the core visual story.

| Area | Direction |
|---|---|
| Characters | Chibi, about 2.5 heads tall, thick clean outlines, each protagonist owning one primary colour |
| Guardians | Stone (or ice) statue version + restored version for each of the 12; a glowing cracked-statue stage for the reveal |
| Board pieces | 4 icons in primary colours (red peach, yellow bell, blue fan, green leaf), distinct shapes as well as colours, readable at 48 px |
| Obstacles | Creep: purple-grey goo with eyes; wraps: grubby bandage over a peeking creature; stone: carved jade-grey |
| Backgrounds | One per 10-level chapter; decayed and restored versions |
| UI | Rounded, chunky buttons; red and gold accents for the festival feel |
| Music | Pentatonic, upbeat loops: map, play, boss, win |
| SFX | Physical, layered sounds by element family (see Feel, juice & sound) |

**AI art pipeline:** generate 20–30 approved samples → train one Scenario style model → generate every asset through it → clean up in Krita. Log which tool made each asset (for store disclosure).

**Asset count for the MVP:** 4 protagonists (6 poses each), Monkey (6 poses), Rat statue + restored, Ox statue, the Nian and 2 of its forces (story cards), 4 pieces, 4 specials, 12 obstacles, 6 backgrounds × 2 states, 3 story posters (20, 25, 50).

## Technical design

Build our own board core in Godot around the 4-layer cell model, with logic separate from animation and sound. Levels use the research brief's JSON schema and are produced by a level-design agent, then checked by a bot. Kenney's Starter Kit Match-3 is a learning and feel reference only.

**Code structure**

| Module | Responsibility |
|---|---|
| `BoardModel` | Pure data: grid of cells, each a layer stack. No visuals |
| `MatchResolver` | Matches, specials, damage to layers, gravity, refill; returns a list of events |
| `ObstacleBehaviours` | One script per OB ID (OB02–OB17); looks and names come from a theme file |
| `AnimationQueue` + `SfxQueue` | Plays events with the timings in Feel, juice & sound |
| `GoalTracker` | Goals and moves; win or fail |
| `LevelLoader` | Reads `res://levels/level_NNN.json` |
| `SaveService` | One player profile shared by every Zodiac game |
| `StoryPlayer` | Dialogues and story cards from `data/story/*.json` |
| `tools/level_bot` | Headless bot: plays each level 500× and reports first-try win rate |

**Level format:** exactly the schema in `level_agent_brief.md` section 5 (`id`, `chapter`, `tier`, `moves`, `colors`, `cells`, `underlay`, `objects` by OB ID, `fixed_tiles`, `spawn`, `goals`, `story_beat`, `designer_notes`), plus one Mythic field: `"fragment": {"guardian": "rat", "scripted": true}` on fragment levels.

**Level pipeline**

1. Level agent (Claude) gets sections 3–6 of the brief as instructions and one 5-level block of the plan at a time.
2. It returns one JSON file per level and runs the brief's validation checklist.
3. The level bot plays it; if the win rate misses the tier target, adjust goal counts (±20%) or moves (±2) and note why in `designer_notes`.
4. You playtest the intro, hard and finale levels yourself.

**Player profile (shared by every Zodiac game)**

```json

```

**Testing:** GUT unit tests for `MatchResolver` (every special and combo) and each OB behaviour; the level bot runs on every level before it ships.

## MVP milestones, budget & open questions

The MVP keeps the 20-week plan and Option A budget (about US$210) until live players give feedback. The scope grows from 60 levels to the story-complete Act 1.

| Week | Milestone | Done when |
|---|---|---|
| 3 | Godot basics + GDD signed off | You can explain this GDD's layer model |
| 9 | Grey-box core (no art) | 5 testers play levels 1–10 and ask for more |
| 14 | Art style locked; levels 1–30 built | Bot win rates within target; temple reveal playable |
| 18 | Levels 31–60; Rat restoration live | Rat restored at 50 in a full playthrough |
| 20 | Public on web + Android | Tracking day-1 return and level fail rates |

**Budget (Option A):** Claude Pro US$20/mo × 6, Scenario Starter US$15/mo × 3, music ~US$20, Google Play US$25 ≈ **US$210**. Revisit after live feedback.

**Open questions**

- [ ] Protagonists: names, bios and colours for the 4 friends
- [ ] Is the Proboscis Monkey the zodiac Monkey guardian (the one who escaped), or a separate temple guardian?
- [ ] Guardians turned to stone, ice, or a mix by element?
- [ ] Temple arrival at level 25 (recommended) or 20/30?
- [ ] Order of the "easier" guardians after Rat: Ox → Rabbit → Dog is proposed
- [ ] Element families: should each guardian belong to Fire, Earth, Water or Air (ties obstacles to heroes for Part 2)?
- [ ] Your upgrade flow: keep milestones at every 20/50 levels, or align them to the 25-level chapters (25/50/75/100)? Plus the forest restoration meta

