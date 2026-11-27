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
