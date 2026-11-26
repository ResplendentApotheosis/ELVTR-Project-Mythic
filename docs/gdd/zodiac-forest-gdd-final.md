# Zodiac Forest — Match-3 GDD (MVP)

Nov 25, 2026 · @Angeline

## Overview

Zodiac Forest is a 2D chibi match-3 where four animal friends (Kancil the mouse-deer, Binturong, Red Panda and Peafowl) clear a spreading curse from their forest, free mummified creatures, and recover the scattered souls of the 12 Zodiac guardians. The MVP ships levels 1–50: the journey to the Jade Temple, the Proboscis Monkey's revelation, and the full restoration of the first guardian, the Rat, at level 50. Levels 1–50 are the whole MVP scope, ending on the Rat's restoration; nothing is added to it before launch.

**Pitch:** Fast, physical match-3 feel (to the measured timings in Feel, juice & sound) and layered boards, wrapped in a Chinese-zodiac rescue story told by four Asian forest animals, each of whom is also a booster. Every soul fragment visibly brings a guardian closer to waking.

**Design pillars**

1. **Feel first.** Every swap, fall and blast is fast, bouncy and loud; feel is measured, not guessed.
2. **Every board is a rescue.** Goals are framed as freeing creatures and dispelling creep, never "collect 30 blue".
3. **Layers make the puzzle.** Underlays, overlays and blockers turn colour-matching into small spatial puzzles.
4. **Story as reward.** A story beat on every hard level (every 5th from 15) and a chapter card every 25 levels.
5. **Souls restore the world.** Every fragment the player frees visibly brings a guardian closer to waking. Carrying fragments into Part 2 games and PvP is a post-MVP goal, not an MVP feature.

| Item | MVP decision |
| --- | --- |
| Levels | 1–50, ending on the Rat's restoration (51–60 move to the first update) |
| Audience | Casual mobile players aged 18–45 and the wider Lunar New Year audience who enjoy cute animals and folklore; new match-3 players are welcome (proposed, confirm) |
| Why switch to it | Four named animal heroes who talk, quip and act as the boosters; the Paper Crane; a fair lives and pop-up model. Full launch timed to a Lunar New Year with a community push |
| Success test | Android D1 ≥ 35% and D7 ≥ 12% (see Retention test) |
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
| --- | --- |
| `README.md` | Benchmarks, market context, design stance |
| `level_agent_brief.md` | Obstacle IDs OB02–OB17, level design rules, level JSON schema, validation checklist |
| `levels_1_100_plan.csv` | The level plan for 1–100 (tier, moves, goals, unlocks, board shape, target win rate) |
| `mv_level_log_1_40.md`, `mv_level_log_41_118.md` | Pacing benchmarks, debut levels, hardest levels |
| `mv_sound_analysis.md` | Feel, juice & sound |

**What the footage showed, and what we do with it**

| MV finding | Mythic decision |
| --- | --- |
| 4 tile colours through all 118 levels | 4 colours throughout (primary colours for the chibi style) |
| Moves 16–39, mostly 20–26 after level 26 | Moves 30 early, 24–26 mid, 21–25 later; never below 16 |
| New obstacle every 3–5 levels early, then every \~10, debuting on the level after a hard one | Same rhythm: 10 obstacles in the MVP (the last at 41), 16 by level 96; Nian's Eye moves to 61 |
| Hard level every 5th from 15, 3–5 goals | Hard every 5th from 15 with 3–4 goals; finales at 25/50/75/100 |
| Difficulty from goal load, not move starvation; hardest levels are open boards | Regular levels stay at 1–3 goals (MV's 4–5-goal regular levels caused its stalls at 59, 67, 87, 98) |
| Boosters unlock one at a time with free uses (11, 16, 22, 29) | Unlocks at 11, 16, 23, 29 and 36, each a hero booster; none shares a level with an obstacle debut |
| Three-layer move sound; cascades every \~160 ms; shard-style breaks | Sound spec in Feel, juice & sound |
| Top complaints: pay-to-pass difficulty, 8–9 pop-ups before Play, double-pressure fail flow, lives lock-out, misleading ads | One optional continue, generous lives, a clean lobby, honest store video |
| 14-day "100 new levels" cycle and \~20 event types | Not feasible solo; at most 3 evergreen live-ops loops after launch |

**Market context (AppMagic estimates via the pack):** MV launched November 2024; ad-free, IAP-only; roughly US$25–36m lifetime IAP by end-2025. We copy design lessons, not its user-acquisition spend.

## Story & world

The Nian has cursed Zodiac Forest: a creeping decay spreads across it and wraps its creatures like mummies. Kancil the mouse-deer and three friends set out for the Jade Temple to ask the 12 Zodiac guardians for help, only to learn the guardians have already fallen. At level 30 they choose to restore the guardians themselves, one soul at a time.

**Cast**

| Character | Role | Notes |
| --- | --- | --- |
| 4 heroes: Kancil, Binturong, Red Panda, Peafowl | Player's party, led by Kancil; they narrate levels and posters, and each one is a booster | Cute chibi animals; profiles, voices and boosters in The four heroes below |
| Proboscis Monkey | Guardian of the Jade Temple, not one of the 12 zodiac guardians; gives the reveal at 25 and joins as guide at 30 | Sage mentor with a big nose and bigger opinions |
| The Nian | Main villain | Folklore beast that fears red, fire and loud noise; never fought directly in the MVP |
| Nian's forces | Faces of the hard levels, shown in story cards | Two forces in the MVP, the Creep Wraith (from 15) and the Stone Golem (from 40), reused across every hard-level story card |
| 12 Zodiac guardians | Turned to stone; souls shattered into fragments | Restored one by one; Rat first |
| Mummified creatures | Forest friends wrapped in creep | Freeing them is the most common level goal |

**How the folklore shapes play:** because the Nian fears red, fire and noise, the player's best tools are themed that way: firecracker specials, red lanterns that burn away creep, drum combos that shake loose stone. Fire, red and noise belong only to the player's side; the Nian's own hazards use a separate Curse family.

**Story beats, levels 1–50 (51–60 kept as the post-MVP plan)**

| Level | Beat | Delivered as |
| --- | --- | --- |
| 1 | Home is decaying; friends are being wrapped by creep. The four set out | Intro comic (4 panels, skippable; see The four heroes) |
| 10 | First freed creature tells of a dark beast at the river | Short dialogue |
| 15 | Hard level: a Creep Wraith blocks the river crossing. Binturong asks how to get past; Kancil tricks it into chasing its own shadow | Story card (text over existing art) |
| 20 | The Creep Wraith, the first mid-boss, guards the temple road; party breaks through | Hard level + story card |
| 25 | Jade Temple. Proboscis Monkey: the Nian defeated all 12 guardians; their bodies are stone, their souls scattered. He survived only because the temple's red lanterns kept the Nian out; the guardians fell because the Nian caught them away from the temple. But a soul can be gathered again, and a guardian whose soul is whole will wake | Poster (big reveal); soul fragments unlock |
| 30 | Monkey joins as guide. Binturong asks who will save the forest now; Kancil's answer: the four will wake the guardians themselves. The Rat fragment freed at 26 begins to glow | Dialogue |
| 35 | Hard level: the Creep Wraith returns to snatch the next Rat fragment; Red Panda spots it from the treetops | Story card (text over existing art) |
| 40 | Hard level: Nian's Stone Golem tries to smash the Rat's statue in the bamboo grove; Kancil tricks it into smashing a boulder instead | Story card (text over existing art) |
| 45 | Hard level: the Stone Golem stirs again; Peafowl's loud call warns the party just in time | Story card (text over existing art) |
| 50 | Rat guardian restored: the statue cracks, the Rat wakes, blesses the party and sniffs the wind toward the Ox's valley. Kancil: "One guardian down. Eleven to go." End of the MVP | Poster + celebration |
| 51 (post-MVP) | The Rat sniffs out the Ox's trail; every fragment in 51–60 is an Ox fragment | Dialogue |
| 55 (post-MVP) | Hard level: the Ox's statue lies half-buried in stone; Binturong asks whether the Ox can hear them, and the Rat says yes | Story card (text over existing art) |
| 60 (post-MVP) | Cliffhanger: the Nian notices the Rat has woken. Its great Eye opens over the Ox's valley. Kancil: "Then we just have to be quicker than it." | Dialogue + cliffhanger card (Nian's Eye reaches the board at 61, after the MVP) |

**Story choices to confirm** are listed under Open questions at the end of this doc.

## The four heroes

Kancil the mouse-deer leads and narrates the story. Binturong asks the questions that set up Kancil's ideas, and Red Panda and Peafowl chip in with one short line each. All four are real animals whose ranges meet around Yunnan and northern Myanmar, which anchors the forest's look. Each hero is also an in-level booster, so the cast appears on the board and not only in cutscenes.

| Hero | Real animal | Role | Personality | Colour | Booster (unlock level) |
| --- | --- | --- | --- | --- | --- |
| **Kancil** | Lesser mouse-deer, one of the smallest hoofed mammals (about 2 kg); the clever trickster Sang Kancil of Malay and Indonesian folklore | Lead narrator; brings the ideas and solutions | Quick, cheeky, calm under pressure; wins by thinking, not fighting | Yellow | Hoof Tap: removes one single tile (11) |
| **Binturong** | Bearcat with a bushy, prehensile tail; its musk smells like popcorn | Second lead; asks the questions | Big, slow, gentle and curious; always a little hungry | Blue | Tail Slam: smashes a 3×3 block (23) |
| **Red Panda** | Tree-dwelling bamboo eater with a ringed tail; stands on its hind legs to play-fight | Supporting; the scout who acts first | Bold, bouncy, impatient, loyal | Red | Bamboo Dash: clears one full line in any direction (29) |
| **Peafowl** | Green peafowl: iridescent green, a long eyespot train and a loud "ki-wao" call | Supporting; the lookout and the show-off | Proud, dramatic and loud, but secretly kind | Green | Feather Fan: reshuffles the board (36) |

Animal facts: [Lesser mouse-deer](https://en.wikipedia.org/wiki/Lesser_mouse-deer) · [Binturong](https://en.wikipedia.org/wiki/Binturong) · [Red panda](https://en.wikipedia.org/wiki/Red_panda) · [Green peafowl](https://en.wikipedia.org/wiki/Green_peafowl). Each hero owns one of the four piece colours, so a hero's colour on the board always points back to them.

**How they talk**

- Kancil has the plan or the closing line in every story beat, poster and chapter card; the others may speak more, but the answer is always Kancil's.
- The usual pattern: Binturong asks, Kancil answers with a plan, then Red Panda or Peafowl adds one line.
- In-level lines stay under 12 words; story-card lines stay under 25.
- Combo callouts: the hero whose colour made the combo says the quip.
- On a fail, nobody blames the player; Kancil always offers the next try.
- Using a booster shows that hero acting on the board with one line.

| Moment | Kancil | Binturong | Red Panda | Peafowl |
| --- | --- | --- | --- | --- |
| Level start | "Small hooves, big plan. Let's go." | "Wait, which one do we free first?" | "Race you there!" | "Behold. The forest awaits us." |
| Big combo | "Just as I planned. Mostly." | "Did... did we do that?" | "Again! Again!" | "Magnificent. Almost as magnificent as me." |
| Booster used | "One tap, one problem gone." | "Tail coming through!" | "Straight line, no stopping!" | "Everybody shuffle. Elegantly." |
| Few moves left | "Think first, then hop." | "Is now a good time to worry?" | "Go, go, go!" | "Do not panic. I will panic for all of us." |
| Level failed | "Every good trick needs a second try." | "Hmm. What did we learn?" | "Rematch!" | "A setback. The comeback will be legendary." |
| Level won | "Told you there was a way." | "Can we have snacks now?" | "Too easy!" | "Applause is welcome." |
| Fragment freed | "One more piece of the {guardian}'s soul." | "Is it warm? It feels warm." | "Got it!" | "It glows almost as much as I do." |

**Level 1 intro comic (4 panels, skippable; the player makes a first swap before it plays)**

1. The grey forest; creep wraps a sleeping hedgehog. Peafowl: "Our forest is fading!"
2. Binturong: "Oh no, what do we do?"
3. Kancil: "We need to get to the Zodiac guardians. They can stop this!"&#32;
4. Red Panda, already running: "The Jade Temple is upriver. We go now!"

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
| --- | --- | --- | --- |
| 4 in a line | Bamboo Rocket | 2 | Clears its full row or column |
| L or T shape (5) | Firecracker | 3 | 3×3 blast, twice (noise scares the Nian) |
| 2×2 square | **Paper Crane** (signature) | 5 | Flies to a goal tile; its target is shown with a dotted path before it flies |
| 5 in a line | Jade Orb | 6 | Clears every piece of the colour it's swapped with |

The Paper Crane is the one "signature, telegraphed" twist the research recommends: always helpful, and always shows where it will land.

**Combos (swap two specials)**

| Combo | Result |
| --- | --- |
| Rocket + Rocket | Row and column cross |
| Rocket + Firecracker | 3-wide row and 3-wide column |
| Firecracker + Firecracker | 5×5 double blast |
| Jade Orb + special | Every piece of the most common colour becomes that special and fires |
| Jade Orb + Jade Orb | Clears the whole board |

Crane + special is held back until after the MVP; a Crane swapped with another special still works, but each fires on its own (see Interaction rules). Two combos get a tutorial: Rocket + Rocket at level 8 and Rocket + Firecracker at level 12. The others are found through play, and the idle hint shows a combo swap whenever one exists.

**Goals per level:** 1 on intro levels, 1–3 on regular levels, 3–4 on hard levels, 4 on finales. Goals are always obstacles to clear, free or collect (see the obstacle table); "collect N red" style goals are only used in tutorials. On a fragment level the soul fragment is always one of the goals and uses one of the tier's slots, never an extra one, so a level cannot be won without it.

## Interaction rules

Every special, obstacle and layer follows this one table. MatchResolver, the GUT tests and the level bot all read from it, and it must be finished before the week-9 grey-box.

| Question | Rule |
| --- | --- |
| One match fits two specials | Make only the strongest: Jade Orb (5 in a line) > Firecracker (L or T) > Bamboo Rocket (4 in a line) > Paper Crane (2×2) |
| Tapping a Jade Orb | Clears every piece of the most common colour on the board; costs a move like any tap |
| What a special hits | Each cell it covers takes one hit, on the top layer only (overlay, then content, then underlay) |
| Obstacles bigger than one cell | Take at most one hit per special, however many of their cells it covers |
| Two-hit obstacles (Frozen idol) | Each adjacent match or each special counts as one hit |
| Where the Paper Crane flies | To the remaining goal with the fewest hits left; an unfreed soul fragment always comes first. Dew goal: an uncovered target cell. Lantern shrine: counts as one piece of a colour it still needs |
| Soul fragments and drop items | Never destroyed by any special, combo or board clear. A freed cocoon collects its fragment at once; a drop item still has to reach the bottom row unless a Crane or Orb + Orb collects it |
| Jade Orb + Jade Orb | Clears the whole board, collects every collectible goal item (fragments included) and hits every obstacle once |
| Hazards | None in the MVP. Nian's Eye moves to level 61 and Nian's Jar stays at 86; their beam and trap rules are written before level 61 is built |
| Crane swapped with another special (Jade Orb included) | No combo in the MVP and never refused: the other special fires first, then the Crane flies to whatever goal is left |
| Firecracker's double blast | The two blasts together count as one hit on any single obstacle |
| Which obstacles are multi-cell | Petrified pillar (OB06) and any obstacle drawn across 2 or more cells. Creep moss (OB03) is one obstacle per cell |
| Hero boosters on fragments and drop items | Never deleted. Hoof Tap, Tail Slam and Bamboo Dash collect a fragment or drop item they hit; Feather Fan moves pieces only, never fragments or drop items |
| Hero boosters on everything else | Like a special: one hit per cell, top layer only; a multi-cell obstacle takes at most one hit per use. Bamboo Dash's diagonal follows the same rule |
| Continue offer | Not shown when the remaining goals can no longer be reached |
| Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try |

## Board layers & obstacles

Obstacles use the research pack's neutral behaviour IDs (OB02–OB17), each given an original Zodiac Forest look and one of five element families. 10 debut in the MVP (levels 1–50) and 6 more by level 96, following `levels_1_100_plan.csv`.

**Cell layer model (top to bottom)**

| Layer | Holds | Cleared by |
| --- | --- | --- |
| 3 · Overlay | Cover clusters, shutters | Adjacent matches |
| 2 · Content | A piece, a blocker, a container or a drop item | Matching / adjacent matches / specials |
| 1 · Underlay | Creep goo, healing dew | Matching on top of it |
| 0 · Floor | Open cell, no cell, spawner, exit | Fixed by level design |

**Element families (look and sound):** Earth = stone, wood, roots (deep knocks) · Water = ice, dew, goo (pitch glides) · Fire = lanterns, embers (crackle shards) · Air = feathers, chimes (whooshes, glassy ticks) · Curse = the Nian's own hazards only (low drones, one heavy heartbeat), so Fire stays on the player's side. These can later tie to the guardians' elements.

**Obstacle set**

| Debut | ID · behaviour | Mythic obstacle | Element | Rule |
| --- | --- | --- | --- | --- |
| 1 | OB02 · breakable, layered | Withered bramble | Earth | Match next to it; up to 3 layers |
| 4 | OB04 · spread goal | Healing dew | Water | Matches made on dew spread it; cover the target cells (heals the forest) |
| 7 | OB07 · container release | **Mummified creature** | Earth | Match next to it to unwrap and free the creature (the core rescue goal) |
| 17 | OB03 · cover cluster | Creep moss | Earth | Match next to it to clear; fills whole areas |
| 10 | OB05 · colour lock | Lantern shrine | Fire | Collect the colours it shows to light it |
| 13 | OB06 · tall column | Petrified pillar | Earth | Ground down by adjacent matches |
| 22 | OB08 · shutter + colour | Paper-screen lantern | Fire | Open the screen, then match its colour to light it |
| 28 | OB10 · underlay clear | Creep goo | Water | Make a match on top to clear it |
| 34 | OB11 · drop item | **Lost hatchlings** (soul fragments use it from level 38) | Air | Bring it to the bottom row to collect it |
| 41 | OB12 · two-hit | Frozen idol | Water | Needs 2 adjacent matches |
| 56 (post-MVP) | OB15 · specials only | Terracotta minion | Earth | Only specials can damage it |
| 61 (post-MVP) | OB09 · hazard, beam | Nian's Eye | Curse | Hit 3 times with specials; its visible beam destroys specials that cross it |
| 66 | OB14 · spreader source | Dew spring | Water | 3 adjacent matches make it spread dew |
| 76 | OB16 · multi-release | Bamboo nest | Air | Adjacent matches release many collectibles |
| 86 | OB13 · hazard, trap | Nian's Jar | Curse | Catches specials; needs 4 special hits |
| 96 | OB17 · generator (optional) | Wind chime | Air | 3 adjacent matches make it produce collectibles |

**Rules from the research brief**

- Intro level: the new obstacle is the only goal, placed where the first 2–3 obvious matches touch it; under 30% of cells blocked.
- The 3–5 levels after an intro each include it, paired with one or two familiar obstacles.
- From level 41, new obstacles debut on the relief level right after a hard level. Earlier debuts follow the table instead, because level 26 carries a scripted fragment and level 16 is a booster unlock.
- At most one hazard type (OB09 or OB13) per level; never put a goal behind a hazard's beam or range; the beam is always visible.
- Hazards arrive later than in MV (61 and 86, both after the MVP) because they are MV's most-complained-about obstacles.

## Feel, juice & sound

Every move should sound and feel physical: a quiet input, a loud impact, then a brighter tail, with cascades landing on a steady \~160 ms pulse. The sound numbers below are measured from MV footage (`mv_sound_analysis.md`); the visual timings are starting targets until the video frames are measured.

**Every move is three sounds**

| Layer | When | Level | Character |
| --- | --- | --- | --- |
| Swap tick | 100–300 ms before the move registers | 10–12 dB below the hit | Soft, low (\~400 Hz), \~115 ms decay |
| Match hit | 0–150 ms after | Loudest | Short, punchy (\~570 Hz), \~90 ms decay |
| Collect ring | 250–300 ms after | Nearly as loud as the hit | Brighter (\~970 Hz), \~200 ms tail as pieces fly to the goal counter |

Each layer is pitched above the last, so every move resolves upwards; the quiet swap means it can play hundreds of times without fatigue.

**Rhythm and materials**

- Cascade hits every 120–180 ms; if several land within \~40 ms, delay or drop some.
- Breaks are 3–7 tiny randomised "shard" hits 60–120 ms apart, never one sample.
- Randomise every sound: ±1–2 semitones, ±2 dB, 4–6 variants.
- Material by element: Earth = deep dry knocks with some resonance; Water = viscous pitch glides (rising when dew spreads, falling when goo clears); Fire = crackle-and-snap shards with an airy tail; Air = swept whooshes and glassy ticks.
- Big combos build in stages: a shimmer bed → rhythmic zaps → one big release → a separate final pop. The Paper Crane gets a rising charge and one crystalline ping.

**Visual timing (starting targets)**

| Moment | Target |
| --- | --- |
| Swap | 0.15 s, ease-out; invalid swap bounces back in 0.2 s |
| Match clear | Pop to 120%, gone in 0.12 s, particle burst in the piece's colour |
| Fall | Accelerating, columns staggered 0.03 s; land with 10% squash and one small bounce |
| Special created | 0.25 s merge and glow |
| Firecracker | 0.2 s blast, 4 px screen shake, short phone haptic |
| Combo callouts | "Great!" / "Amazing!" / "Festival!" at 3 / 5 / 8 cascades, plus a quip from the hero whose colour made the combo (see The four heroes) |
| Win finale | Leftover moves fire as rockets 0.15 s apart |
| Idle hint | After 5 s, a valid swap wiggles |

**Godot setup:** a pool of 8–12 `AudioStreamPlayer` voices; one `AudioStreamRandomizer` per sound family; separate SFX and Music buses, with music ducked 3–6 dB during big combos; shard sequences scheduled by a small timer queue. Record real objects for sources (ceramic cups, a wooden box, stirring honey, a cork pop): free, and they sound more ASMR than synthesised tones.

**Rule:** game logic resolves instantly; a separate animation and sound queue plays the results.

## Level progression

Levels follow `levels_1_100_plan.csv`: 25-level chapters with finales at 25, 50, 75 and 100, a hard level every 5th level from 15, and a relief level after each hard one (from level 41, new obstacles debut there). The MVP covers chapters 1–2 (levels 1–50).

&#91;embedded content: Level progression · story trails and guardian restorations, levels 1–200\]

**Level tiers (from the plan and brief)**

| Tier | When | Moves | Goals | First-try win target |
| --- | --- | --- | --- | --- |
| Intro | New obstacle debuts | 30 early, 25–26 later | 1 (the new obstacle) | 95% |
| Easy (relief) | After intros and hard levels | 28 early, 23–24 later | 1–2 | 85–90% |
| Medium | Between | 26 early, 21–22 later | 2–3 | 60–70% |
| Hard | Every 5th from 15 | 30 early, 24–25 later | 3–4 | 35–45% |
| Finale | 25, 50, 75, 100 | 32 / 27 / 26 / 26 | 4 | 25–35% |

**Fair difficulty:** hard and finale boards are wide and open (no dead corners or 1-cell pockets holding goals), so failing feels like bad luck, not confusion. Difficulty rises through goal counts, never by starving moves below 16. No two consecutive levels share a board shape. The story finales at 25 and 50 are tuned to the top of the finale band (35%) and never carry more goal load than the heaviest hard level in their chapter. Every win target is a human first-try rate without boosters, pre-level boosters, streak-chest specials or continues.

**Chapters:** 1 (1–25) Journey to the Jade Temple · 2 (26–50) Rat's trail · 3 (51–75) Ox's trail begins · 4 (76–100) deeper forest. Each finale ends with a chapter story card; each hard level carries a mini story beat. A new backdrop every 10 levels (5 in the MVP), so the forest visibly heals within each chapter.

**Your 20/50-level upgrade milestones** can sit on top of this; see Open questions on whether to align them to the 25-level chapters.

## Soul fragments

Fragments start at level 26, right after the temple reveal. The Rat's 8 fragments are scripted so it is restored at exactly level 50. The MVP ends there. In the first update every fragment from 51–60 is an Ox fragment; after that, every hard level and about 1 in 5 other levels carry a fragment, weighted toward one "trail" guardian at a time, so about 3 guardians are restored by level 200 and the other 8 come later.

**Rules**

- A fragment level shows a glowing fragment icon on the map and level card, so players know before they play.
- Levels 26–33: the fragment is sealed in a creep cocoon (OB07 behaviour) and freed by adjacent matches. From level 38 it can also be an OB11 drop item (drop items debut at 34 with lost hatchlings, so players practise before a fragment rides one) that must reach the bottom row. Fail the level and the fragment stays for the retry. The fragment is one of the level's goals, so winning always collects it, and no special can destroy it (see Interaction rules). Won levels cannot be replayed in the MVP.
- The Rat needs 8 fragments; every other guardian needs 12.
- **Trail guardian:** after 50, the story points to one guardian at a time; in levels 51–60 every drop is for the trail guardian, the Ox. From level 61, each drop has a 70% chance of being for the trail guardian and 30% for a random guardian who is not yet restored. The roll happens when the level is won, so quitting and re-entering cannot change it.
- **Pity rule:** from level 61, if 4 random rolls in a row miss the trail guardian, the next drop is guaranteed for it; scripted drops don't count.
- **No waste:** restored guardians are never in the random pool, so no fragment is wasted. Soul Dust is cut from the MVP and returns only if a Part 2 game gives it a use.
- From level 26, hard and finale levels always carry a fragment. Intro levels never do (they teach one thing only), and the validation checklist rejects a fragment placed on one. The trail moves on only when the trail guardian is restored.

**Schedule (target; tune with the level bot)**

| Levels | Fragment levels | Who they're for | Outcome |
| --- | --- | --- | --- |
| 1–25 | None | — | Journey to the temple |
| 26–50 | 26, 30, 33, 35, 38, 40, 45, 50 (scripted) | Rat 8/8 | **Rat restored at 50** |
| 51–110 | \~20 (12 hard + \~8 others) | Trail: Ox (every drop in 51–60) | **Ox restored around 110** |
| 111–165 | \~18 | Trail: Rabbit | **Rabbit restored around 165** |
| 166–200 | \~12 | Trail: Dog (may already hold \~1 from random drops) | **Dog restored around 200** |
| 201+ | Continues, plus events and Part 2 games | Other 8 guardians (each holding about 1–2 of 12 from the random 30%) | One guardian every \~50–60 levels |

**Arithmetic check (redo in a spreadsheet before level 61):** the rules give about 0.36 drops per level and about 0.25 trail fragments per level, so the Ox lands nearer level 100 than 110. The \~17 random drops spread over about 10 unrestored guardians, roughly 1–2 each. Treat the dates after level 60 in this table as estimates, not commitments.

## Meta & economy

The MVP economy is small and fair: coins, generous lives, four hero boosters that unlock one at a time, and coins with real things to spend on: continues, life refills and boosters. It deliberately avoids MV's top complaints. You design the wider meta (forest restoration); this section fixes only the numbers the levels depend on.

**Currencies and limits (starting values, tune in playtests)**

| Item | Rule |
| --- | --- |
| Coins | Start 500. Win = 20 + 5 per finale rocket (about 40 a win). Spent on the continue, life refills and hero boosters; balance coin income against prices for each 5-level block in the economy sheet |
| Lives | 5 max; lose one on fail, except on chapter finales, where a fail costs no life; refill 1 per 20 min, or buy all 5 back for 150 coins; 10 min of unlimited lives after each chapter finale |
| Continue | One optional "+5 moves" for 300 coins per attempt; no second pop-up |
| Win streak | 6 wins in a row: a chest drops a free Rocket and Crane onto the next board |
| Soul fragments | Not spendable; restore guardians |
| Soul Dust | Cut from the MVP (see Soul fragments) |

**Booster unlocks (MV's proven levels, our themes)**

| Unlock | Booster | Type | Effect | Free uses, then |
| --- | --- | --- | --- | --- |
| 11 | Kancil's Hoof Tap | In-level | Removes one single tile of the player's choice (a piece, or the top layer of one cell) | 3 free, then 100 coins each |
| 16 | Pre-level boosters | Pre-level | Start with a Rocket + Crane, or a Firecracker | 1 each free, then 150 coins each |
| 23 | Binturong's Tail Slam | In-level | Smashes a 3×3 block (one hit to every cell in it) | 2 free, then 200 coins each |
| 29 | Red Panda's Bamboo Dash | In-level | Clears one full line in any direction: a row, a column or a diagonal | 2 free, then 150 coins each |
| 30 | Monkey's Staff (story gift) | In-level | Removes one layer from every cell of one multi-cell obstacle | Cut from the MVP for now |
| 36 | Peafowl's Feather Fan | In-level | Reshuffles the board (the free auto-shuffle still happens when no move exists) | 2 free, then 100 coins each |
| 50 | **Rat's Nibble** (first guardian power) | In-level | Rat gnaws through a whole row of obstacles | Post-MVP (first update) |
| \~110 / \~165 / \~200 | Ox's Charge / Rabbit's Hop / Dog's Fetch | In-level | Column smash ignoring stone / swap any two pieces / pull a goal item to the counter | Post-MVP; 1 free charge every level |

Prices are starting values for the economy sheet. Win targets assume no boosters, so a player who never buys one must still be able to hit every target.

**Fairness rules (from the research)**

- At most one pop-up between the lobby and Play. After a win, at most 2 screens; any other reward (an unlock, a gift, the unlimited-lives grant) shows as a badge on the map.
- No "pay to pass" spikes: every level's human first-try win rate must sit inside its tier's band: never below it and no more than 5 points above it, since 500 bot runs carry about ±4 points of noise. Measured without boosters or continues.
- After launch, at most 3 evergreen live-ops loops (for example a daily puzzle, a weekly event and a collection).

**Owner: you.** Forest restoration meta, collections and the heroes' upgrade flow. The research recommends passive story cards over decoration chores; the save data already tracks levels, fragments and restored guardians.

## Art & audio direction

The art is 2D chibi characters with bright primary colours, set against a forest that visibly shifts from grey, creep-covered decay to lush colour as the player wins. That contrast is the core visual story.

| Area | Direction |
| --- | --- |
| Characters | Chibi, about 2.5 heads tall, thick clean outlines, each hero owning one piece colour: Kancil yellow, Binturong blue, Red Panda red, Peafowl green |
| Guardians | Stone statue version + restored version for each of the 12; a glowing cracked-statue stage for the reveal |
| Board pieces | 4 icons in primary colours (red peach, yellow bell, blue fan, green leaf), distinct shapes as well as colours, readable at 48 px |
| Obstacles | Creep: purple-grey goo with eyes; wraps: grubby bandage over a peeking creature; stone: carved jade-grey |
| Backgrounds | One every 10 levels inside the 25-level chapters (5 in the MVP); decayed and restored versions |
| UI | Rounded, chunky buttons; rose red and gold accents for the festival feel |
| Music | Pentatonic, upbeat loops: map, play, boss, win |
| SFX | Physical, layered sounds by element family (see Feel, juice & sound) |

**AI art pipeline:** generate 20–30 approved samples → train one Scenario style model → generate every asset through it → clean up in Krita. Log which tool made each asset (for store disclosure). The four hero designs are locked by week 6, before the style model is trained.

**Asset count for the MVP:** 4 heroes (6 poses each, plus one booster action each), Monkey (6 poses), Rat statue + restored, the Nian and 2 of its forces (story cards), 4 pieces, 4 specials, 10 obstacles, 5 backgrounds × 2 states, 2 story posters (25, 50); level 20 uses a story card.

## Technical design

Build our own board core in Godot around the 4-layer cell model, with logic separate from animation and sound. Levels use the research brief's JSON schema and are produced by a level-design agent, then checked by a bot. Kenney's Starter Kit Match-3 is a learning and feel reference only.

**Code structure**

| Module | Responsibility |
| --- | --- |
| `BoardModel` | Pure data: grid of cells, each a layer stack. No visuals |
| `MatchResolver` | Matches, specials, damage to layers, gravity, refill, all as set in Interaction rules; returns a list of events |
| `ObstacleBehaviours` | One script per OB ID (OB02–OB17); looks and names come from a theme file |
| `AnimationQueue` + `SfxQueue` | Plays events with the timings in Feel, juice & sound |
| `GoalTracker` | Goals and moves; win or fail |
| `LevelLoader` | Reads `res://levels/level_NNN.json` |
| `SaveService` | A local save with a schema version and a migration hook. Sharing one profile across Zodiac games is post-MVP and needs an account server |
| `StoryPlayer` | Dialogues and story cards from `data/story/*.json` |
| `tools/level_bot` | Headless bot: plays each level 500× with a greedy, human-like policy that uses only taught specials and combos, no boosters, pre-level boosters, streak-chest specials or continues; reports first-try win rate |

**Level format:** exactly the schema in `level_agent_brief.md` section 5 (`id`, `chapter`, `tier`, `moves`, `colors`, `cells`, `underlay`, `objects` by OB ID, `fixed_tiles`, `spawn`, `goals`, `story_beat`, `designer_notes`), plus one Mythic field: `"fragment": {"guardian": "rat", "scripted": true}` on fragment levels. A fragment level also lists the fragment in goals, inside the tier's goal count.

**Level pipeline**

1. Level agent (Claude) gets sections 3–6 of the brief as instructions and one 5-level block of the plan at a time.
2. It returns one JSON file per level and runs the brief's validation checklist.
3. The level bot plays it; if the win rate misses the tier target, adjust goal counts (±20%) or moves (±2) and note why in `designer_notes`.
4. You playtest the intro, hard and finale levels yourself.

**Bot calibration:** the week-9 testers' results on levels 1–10 set a first bot-to-human offset. A second round at week 14, with testers on hard levels 15–30, sets the offset for the hard and finale tiers. Levels are tuned to the bot's rate after the offset is applied.

**Save file (local, versioned)**

```json
{
  "schema_version": 1,
  "level": 28,
  "coins": 840,
  "lives": 5,
  "fragments": {"rat": 1, "ox": 0},
  "restored": [],
  "boosters": {"hoof_tap": 3, "tail_slam": 2, "bamboo_dash": 0, "feather_fan": 0}
}
```

**Testing:** GUT unit tests for `MatchResolver` (every special and combo, and every row of Interaction rules) and each OB behaviour; the level bot runs on every level before it ships.

## MVP milestones, budget & open questions

The MVP keeps the 20-week plan and Option A budget (about US$210) until live players give feedback. Scope is fixed at levels 1–50. If a milestone slips, cut from the list below instead of moving the date.

| Week | Milestone | Done when |
| --- | --- | --- |
| 3 | Godot basics + GDD signed off | You can explain this GDD's layer model and Interaction rules |
| 6 | Open questions closed; hero designs locked | Every item under Open questions is answered |
| 9 | Grey-box core (no art) | Interaction rules pass their GUT tests; 5 testers play levels 1–10 and ask for more; sound timing checked on one Android phone and one browser |
| 14 | Art style locked; levels 1–30 built | Second bot calibration on hard levels done; temple reveal playable |
| 16 | Android closed test starts | At least 15 testers opted in (Google needs 12 for 14 days in a row, plus spares) |
| 18 | Levels 31–50; Rat restoration live | Rat restored at 50 in a full playthrough; apply for Google Play production access |
| 20 | Public on web; Android public once Google approves | Retention test running (below) |

**Budget (Option A):** Claude Pro US$20/mo × 6, Scenario Starter US$15/mo × 3, music \~US$20, Google Play US$25 ≈ **US$210**. Revisit after live feedback.

**Cut list, in this order, if a milestone slips**

1. Win-streak chest.
2. Pre-level boosters (level 16).
3. Recorded sound library: use stock sounds and keep the three-layer timing rules.
4. Hero quip table: one templated line per moment instead of four.
5. Jade Orb + special and Firecracker + Firecracker combos. Neither is taught, so tuned win rates don't change.
6. Content (levels, story beats) is cut last.

Already out of the MVP: levels 51–60, the Monkey's Staff, Rat's Nibble, the Terracotta minion, the Crane + special combo, Nian's Eye, random fragments, the pity rule, Soul Dust and the shared cross-game profile.

**Retention test**

The MVP passes if Android players reach D1 ≥ 35% and D7 ≥ 12% (proposed bars). Android decides because new personal Play accounts must run a closed test with at least 12 testers for 14 days before going public ([Google Play testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)); itch.io web numbers are reported separately.

- Leave closed-test accounts out. Read the bars only once at least 200 public Android players have installed; if organic installs fall short by week 22, run a small ad test (budget to be set).
- Read D7 only for players who haven't finished all 50 levels, and report finishers separately: 50 levels with no replay can be finished in a few days.
- Log per player: furthest level, every attempt and win, lives run out, life refills bought and mid-level quits.
- Track how many players quit within 2 sessions after running out of lives on levels 15 or 20.
- Both bars met: plan monetisation and the next levels.
- D1 met, D7 missed among non-finishers: fix the pacing of levels 20–50 and retest for 4 weeks.
- Many players finished by D7: content ran out, so build the first update (levels 51–60) before changing pacing.
- D1 missed: rework the first session before adding any content.

**Open questions**

| Question | Answer |
| --- | --- |
| Confirm the proposed audience and the D1 35% / D7 12% retention bars | Confirm |
| Hero booster prices and coin income: confirm once the economy sheet is built | Confirm for now |
| Guardians turned to stone, ice, or a mix by element? | stone only |
| Order of the "easier" guardians after Rat: Ox → Rabbit → Dog is proposed | agreed |
| Element families: should each guardian belong to Fire, Earth, Water or Air (ties obstacles to heroes for Part 2)? | yes for now |
| Your upgrade flow: keep milestones at every 20/50 levels, or align them to the 25-level chapters (25/50/75/100)? Plus the forest restoration meta | agreed |
