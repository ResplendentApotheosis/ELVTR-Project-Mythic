# Zodiac Forest: decision and authorship log

Who decided what, and who made what: the owner (human) or AI. Newest first. Use it for store AI-disclosure, course write-ups and tracing why a rule exists.

**Decided by** says who made the call. **Made by** says who produced the work.

| Label | Meaning |
|---|---|
| Human | The owner (Angeline) decided or did it |
| AI | Claude decided or did it, without a separate owner decision |
| AI → Human | AI drafted or proposed it; the owner approved it (unchanged unless noted) |
| Human ← AI options | The owner chose from options AI wrote |
| Human (AI-guided) | The owner did it by hand, following AI instructions |

"AI" means Claude: the crew agents (rules-keeper, test-engineer, godot-engineer, level-designer, balance-analyst) in Claude Code on the owner's PC, or Claude in claude.ai (chat, the live GDD, the cloud setup session).

## Log

| Date | What | Decided by | Made by | Where |
|---|---|---|---|---|
| 2026-11-28 | LevelLoader code choices the spec doesn't settle, provisional until checked: a fixed special with no colour gets its colour before the fill draws; if too few columns can take starting drop items, place as many as fit (IR-75 gap); unknown `pre_specials` names are ignored; non-null `spawn.generators` rejected; the validator builds its check board with seed 1; up to 200 fill re-draws | AI | godot-engineer | `src/game/` |
| 2026-11-28 | LevelLoader built: loads a level into a seeded starting board and goals, rebuilds on retry with a new seed, and `LevelLoader.validate` reports errors by IR ID. 495 tests: 492 pass, 0 fail, 3 pending (SaveService) | AI | rules-keeper, test-engineer, godot-engineer | branch `build/level-loader` |
| 2026-11-28 | LevelLoader test API (contract section 11) and its test-side choices: retry keeps only lives and coins; loading never validates; load draw order is shape, underlay, objects, fixed tiles, fill, drop items, pre-level specials | AI | test-engineer | `tests/API_CONTRACT.md`, `tests/level_loader/` |
| 2026-11-28 | Answers to OQ-83 to OQ-88: level 10 creature beat moves to 17; paper-screen lantern details (lit = removed; a colour match that opens it also lights it; specials and the Crane light an open one; hp 1–3); drop-item placement details; Rocket tie = seeded 50/50, targets counted once per obstacle; pillar hp 1–4; colour-field and shrine `needs` errors rejected. All the owner's picks follow AI's recommendations | Human ← AI options | Options and rules: rules-keeper | `spec/open_questions.md`, `spec/interaction_rules.md` |
| 2026-11-28 | Answers to OQ-75 to OQ-82: moss debuts at 7 and creature at 17 (plan stands; GDD to change); new seed every attempt; shrine `needs` as a count per colour; 78 lantern as a content obstacle (trial); 79 drop items on the board at the start (trial); 80 fixed-tile names with an optional colour (trial); 81 A; 82 A with the owner's change: the Rocket points along the line with more targets. 75, 76, 77 and 81 follow AI's recommendation | Human ← AI options | Options: rules-keeper | `spec/open_questions.md` |
| 2026-11-28 | Level-file rules IR-63 to IR-77 added to the spec, with 13 existing rules updated to match the owner's answers (rule text not yet reviewed by the owner) | AI | rules-keeper | `spec/interaction_rules.md` |
| 2026-11-28 | Level plan without Nian's Eye: level 46 becomes an easy relief level (cracked idol ×20, paper-screen lantern ×12); OB09 removed from 47 and 48; finale 50 gets healing dew as a 4th obstacle goal. AI advised against 50 B because the fragment also takes a goal slot; the owner chose it. The dew count (×70, within the 90% limit) was set by AI | Human ← AI options | AI (edited the plan) | `research/match-villains/levels_1_100_plan.csv` |
| 2026-11-28 | Merged PR #4 (GoalTracker, 398 tests passing) into `main` | Human | AI | GitHub |
| 2026-11-28 | GDD (repo and live) and level brief updated with OQ-62 to OQ-74 (rounds 5–7): goal units, the winning move, dew goals, fragment fields in level files, boosters use no move, lives after continues; brief example goals fixed | AI → Human | AI | GDD; `research/match-villains/level_agent_brief.md` |
| 2026-11-28 | godot-engineer's folder note changed from `src/game/` to `src/goals/` for GoalTracker | AI → Human | AI | `.claude/agents/godot-engineer.md` |
| 2026-11-28 | Nian's Eye (OB09) is not in levels 1–50, replacing the 27 Nov "keep it at 46–50 for now"; plans for levels 46 and 50 still to decide | Human | — | GDD (already at 61); `levels_1_100_plan.csv` not yet changed |
| 2026-11-28 | The winning move plays out in full before the win, for player satisfaction (OQ-72, changing the trial answer to OQ-64) | Human (own wording) | — | GDD › Core gameplay; row 72 |
| 2026-11-28 | Answers to OQ-62 to OQ-74; OQ-62 and OQ-66 are trial decisions to revisit after playtesting | Human ← AI options | Options: rules-keeper | `spec/open_questions.md` |
| 2026-11-28 | GoalTracker built: 398 tests pass, 0 fail, 7 pending until LevelLoader and SaveService exist | AI | rules-keeper, test-engineer, godot-engineer | branch `build/goal-tracker` |
| 2026-11-27 | Merged PR #3 (MatchResolver, 257 tests passing) into `main` | Human | AI | GitHub |
| 2026-11-27 | GDD (repo and live claude.ai doc) updated with OQ-39 to OQ-61: continue offer, quitting, win finale, lantern shrine, locked pieces, dew, chain timing, Jade Orb; 23 new clarification rows | AI → Human | AI | GDD › Core gameplay, Special pieces, Combos, Interaction rules, Board layers, Feel, Meta |
| 2026-11-27 | Wording for the win-finale timing: "each launches 0.15 s after the board settles from the last". The crew flagged that the owner should word it; AI drafted this wording | AI (owner to confirm) | AI | GDD › Feel › Win finale |
| 2026-11-27 | MatchResolver finished: 257 tests pass, none pending, no open questions | AI | rules-keeper, test-engineer, godot-engineer | branch `build/match-resolver` |
| 2026-11-27 | Trial decisions to revisit after playtesting: OQ-46 (dew from specials), OQ-47 (chain order), OQ-48 (Orb + special waiting), OQ-50 (specials on shrines) | Human | — | GDD rows marked *trial* |
| 2026-11-27 | Continue offer: up to 5 per attempt, 300 then 500 coins; shown without enough coins but only Decline works; never after quitting (OQ-39, OQ-51, OQ-52) | Human (OQ-39 in the owner's own wording; OQ-51 and OQ-52 chosen from AI options) | — | GDD › Interaction rules, Meta |
| 2026-11-27 | Answers to OQ-40 to OQ-61 (finale Rockets random 50/50 row or column, shrine filling and hp, locked pieces, holes in columns, dew vs goo, waiting-special timing) | Human ← AI options (OQ-40 in the owner's own wording) | Options: rules-keeper | `spec/open_questions.md` |
| 2026-11-27 | 23 more open questions, OQ-39 to OQ-61, raised while applying earlier answers and checking for gaps | AI | rules-keeper, godot-engineer | `spec/open_questions.md`; all answered |
| 2026-11-27 | Started this log | Human | AI | `DECISION_LOG.md`, `CLAUDE.md` |
| 2026-11-27 | GDD (repo and live claude.ai doc) updated with OQ-23 to OQ-38 and the continue-offer change: 14 edits plus a 38-row "Rules clarifications" table | AI → Human | AI | GDD › Interaction rules, Core gameplay, Special pieces, Meta & economy |
| 2026-11-27 | Continue offer: shown after every fail, at least twice per attempt, whatever the board state. Reverses the GDD's "one optional continue, no second pop-up"; AI flagged the conflict with the fairness pitch and the owner confirmed | Human | — | OQ-23; count, price and decline flow still open (OQ-39) |
| 2026-11-27 | Answers to OQ-24 to OQ-38: gravity, chain order, locked pieces under overlays, dew, Crane details, Orb + Orb top layer only, Hoof Tap | Human ← AI options | Options: rules-keeper | `spec/open_questions.md` |
| 2026-11-27 | 12 new open questions, OQ-39 to OQ-50; 4 of them (OQ-47 to OQ-50) come from provisional choices godot-engineer made in code | AI | rules-keeper, godot-engineer | `spec/open_questions.md`; still OPEN |
| 2026-11-27 | MatchResolver build: rules IR-01 to IR-54, 203 GUT tests (183 pass, 0 fail, 20 pending), BoardModel, MatchResolver, obstacle behaviours | AI | rules-keeper, test-engineer, godot-engineer | branch `build/match-resolver` (not merged) |
| 2026-11-27 | Pushed the crew's work to GitHub as a review branch instead of `main` | AI → Human | Human (AI-guided) | branch `build/match-resolver` |
| 2026-11-27 | GDD "Rules clarifications" section (OQ-01 to OQ-22) written into the repo GDD; the guard on `docs/` was overridden once with the owner's explicit permission | AI → Human | AI | GDD › Interaction rules |
| 2026-11-27 | Answers to OQ-01 to OQ-22: Rocket direction, special placement, chains, cascades, Crane targeting, gravity, swapping, shuffle and more | AI → Human (approved unchanged) | AI | GDD › Rules clarifications |
| 2026-11-27 | First rules pass: 38 rules from the GDD and 23 open questions | AI | rules-keeper | `spec/` |
| 2026-11-27 | Run the first build on Opus, with Sonnet for routine work | Human ← AI options | — | Claude Code session |
| 2026-11-27 | Guard on `docs/`, `research/` and `addons/gut/` changed from a Node.js hook to built-in deny rules, after the hook failed on Windows | AI | AI | `.claude/settings.json` |
| 2026-11-27 | `GODOT_BIN` set to the owner's Godot 4.7.2 console executable | AI | AI | `.claude/settings.json` |
| 2026-11-27 | Installed Git, cloned the repo, created the Godot project ("Zodiac Forest", Compatibility renderer), installed and enabled GUT, moved Godot to Program Files, pushed the project | Human | Human (AI-guided) | repo root, `addons/gut/` |
| 2026-11-27 | Merged PR #1 (GDD and reviews) and PR #2 (crew) into `main` | Human | AI | GitHub |
| 2026-11-27 | `CREW.md`: architecture, data-flow and workflow diagrams | Human (asked) | AI | `CREW.md` |
| 2026-11-27 | Keep Nian's Eye at levels 46–50 in the level plan for now (the GDD still says 61; the crew stops and asks there) | Human | — | `levels_1_100_plan.csv` unchanged |
| 2026-11-27 | Found 3 conflicts between the level plan and the GDD (levels 7/17 swapped, Nian's Eye at 46–50, booster labels) | AI | AI | flagged in chat |
| 2026-11-27 | Public repo gets a slim research pack only (brief sections 3–6 and the 1–100 plan); Match Villains logs and sound analysis stay private | Human ← AI options | AI (trimmed the brief) | `research/match-villains/` |
| 2026-11-27 | Crew set-up: run in the repo with Claude Code, start with the core five agents, short code headers instead of long explanations | Human ← AI options | — | `CLAUDE.md` |
| 2026-11-27 | Crew design: five agents, write limits per agent, "no agent checks its own work", `/build` and `/level-block` workflows, `CLAUDE.md` | AI → Human | AI | `.claude/`, `CLAUDE.md` |
| 2026-11-26 | Handoff brief for the crew thread | Human (asked) | AI | Project › `claude/zodiac-forest-handoff.md` |
| 2026-11-26 | Owner decisions in the handoff brief: MVP = levels 1–50; lives (5, 20 min, 150 coins); Monkey's Staff and Rat's Nibble cut; coin economy and prices; guardians stone only; order Ox → Rabbit → Dog; upgrade milestones at 20 and 50; retention bars D1 35% / D7 12%; the cut list | Human | — | GDD; handoff brief |
| 2026-11-25 to 26 | GDD v1 to final, and two design-review rounds by six AI reviewer roles (systems, narrative, player psychology, feasibility, adversarial QA, business) | Human (direction and decisions) | AI (writing and reviews) | GDD; `docs/reviews/` |
| 2026-11-25 | Research pack: level brief, 1–100 level plan, level logs and sound analysis, made from the owner's Match Villains footage | Human (footage and direction) | AI (analysis and writing) | Project › `research/match-villains/` |

Entries before 27 Nov come from the handoff brief and the repo history, not from a live record. Correct anything that's wrong.
