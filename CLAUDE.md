# Zodiac Forest: project rules for Claude

Zodiac Forest is a 2D chibi match-3 built in **Godot 4.7 / GDScript** for web (itch.io) and Android, by one developer (the owner) on a 20-week plan. The MVP is **levels 1–50**, ending with the Rat's restoration at level 50.

The owner is learning Godot as the project goes. Write in plain English, keep answers short, and never assume the owner knows Godot jargon. Explain a term in a few words the first time you use it.

## Sources of truth (in this order)

1. **`docs/gdd/zodiac-forest-gdd-final.md`**: the GDD. It wins over everything else.
2. **`spec/interaction_rules.md`**: the GDD's Interaction rules as numbered rules (IR-01, IR-02…). The Rules Keeper derives it from the GDD and it must never contradict the GDD.
3. **`research/match-villains/level_agent_brief.md`** and **`levels_1_100_plan.csv`**: obstacle IDs, level rules, the level JSON schema and the validation checklist.
4. Everything else.

If two sources disagree, or the GDD doesn't answer a question, **stop and ask the owner**. Never guess a game rule, and never "fix" the GDD. Only the owner edits `docs/` and `research/`. A hook blocks agent edits there.

## Folder map

| Path | What | Written by |
|---|---|---|
| `docs/` | GDD and review notes | Owner only |
| `research/match-villains/` | Research pack (brief, plan CSV, MV logs, sound analysis) | Owner only |
| `spec/` | Interaction rules spec and rules questions | rules-keeper |
| `tests/` | GUT tests | test-engineer |
| `src/` | Game code (BoardModel, MatchResolver, obstacles, GoalTracker, LevelLoader, SaveService…) | godot-engineer |
| `tools/level_bot/`, `tools/validate_level/` | Headless bot and level validator | godot-engineer |
| `levels/level_NNN.json` | Level files (`NNN` = 001–050) | level-designer; balance-analyst may apply bounded tweaks |
| `reports/balance/` | Bot and validation reports | balance-analyst |
| `addons/gut/` | GUT test framework (installed once, never edited) | — |

The Godot project root is the repo root, so `levels/level_026.json` is `res://levels/level_026.json`. `docs/` and `research/` each hold a `.gdignore` file so Godot doesn't import them.

## The crew

Diagrams of how the agents connect and how data flows: `CREW.md`.

The main session acts as **producer**. It picks the right agent, passes it the task and checks the result. Agents can't call each other, so the main session runs the hand-offs below in order.

| Agent | Use it for |
|---|---|
| `rules-keeper` | Turning the GDD's rules into `spec/`, and answering any "what should happen when…?" question |
| `test-engineer` | Writing GUT tests from `spec/` **before** the code exists, and running the test suite |
| `godot-engineer` | Writing game code and tools until the tests pass |
| `level-designer` | Writing one 5-level block of level JSON |
| `balance-analyst` | Validating levels, running the bot 500× per level and checking win rates against the tier bands |

**No agent checks its own work.** Tests come from test-engineer, not from the engineer who writes the code. Win rates come from balance-analyst, not from the designer who writes the levels.

## Workflows

**Build a module** (`/build <module>`)
1. rules-keeper: confirm the rules the module needs exist in `spec/`; add any that are missing (from the GDD only).
2. test-engineer: write failing tests for those rule IDs.
3. godot-engineer: implement until the tests pass. Do not edit `tests/`.
4. test-engineer: run the full suite and report pass/fail per rule ID.

**Make a level block** (`/level-block <first>-<last>`, e.g. `/level-block 26-30`)
1. level-designer: write the 5 level files and self-check against the schema.
2. balance-analyst: run the validator, then the bot 500× per level; apply only bounded tweaks (goals ±20%, moves ±2); re-run.
3. Producer: report to the owner, listing which levels are intro, hard or finale, because the owner playtests those.

**Rules question**: ask rules-keeper. If the GDD doesn't answer it, the question goes into `spec/open_questions.md` for the owner.

## Commands

The Godot executable is set once in `.claude/settings.json` as `GODOT_BIN`.

- Run all tests: `"$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
- Validate a level: `"$GODOT_BIN" --headless -s res://tools/validate_level/validate_level.gd -- levels/level_026.json`
- Bot a level: `"$GODOT_BIN" --headless -s res://tools/level_bot/level_bot.gd -- levels/level_026.json --runs 500`

The last two scripts are built by godot-engineer. Until they exist, balance-analyst says so and runs the brief's validation checklist by hand.

## Owner decisions (from the handoff brief, 26 Nov 2026)

- MVP = levels 1–50. Levels 51–60 are the first update. Won levels can't be replayed.
- Lives: 5 max, 1 back every 20 min, or all 5 for 150 coins. A failed chapter finale costs no life. Quitting mid-level counts as a fail.
- Coins pay for the continue (300), life refills (150) and hero boosters (100–200).
- Hero boosters: Hoof Tap (level 11), Tail Slam (23), Bamboo Dash (29), Feather Fan (36). **Cut:** Monkey's Staff, Rat's Nibble, and any free per-level powers.
- Rat fragments are scripted at levels 26, 30, 33, 35, 38, 40, 45 and 50. A fragment always takes one of the level's goal slots, and no special or booster ever destroys it. Drop items debut at 34; fragments ride drop items only from 38.
- Guardians are stone only. Order after the Rat: Ox → Rabbit → Dog.
- Upgrade milestones stay at levels 20 and 50.

## Out of scope: don't build these

Levels 51+, Monkey's Staff, Rat's Nibble, Terracotta minion, the Crane + special combo (they fire separately), Nian's Eye, Nian's Jar, random fragment drops, the pity rule, Soul Dust, shared cross-game profiles, monetisation.

**Cut list if a milestone slips** (cut in this order): win-streak chest → pre-level boosters → stock sounds instead of the recorded library → one quip per moment → Jade Orb + special and Firecracker + Firecracker combos → content last.

## Milestones

| Week | Done when |
|---|---|
| 3 | Owner can explain the layer model and Interaction rules |
| 6 | Open questions closed; hero designs locked |
| 9 | Interaction rules pass their GUT tests; levels 1–10 playtested by 5 testers; first bot calibration |
| 14 | Art locked; levels 1–30 built; second bot calibration on hard levels |
| 16 | Android closed test (15+ testers) |
| 18 | Levels 31–50; Rat restored at 50 in a full playthrough |
| 20 | Public on web; Android when Google approves |

## Coding conventions

- GDScript with static types everywhere (`var moves: int = 30`, `func resolve(board: BoardModel) -> Array[BoardEvent]:`).
- **Game logic resolves instantly and returns events; AnimationQueue and SfxQueue play them afterwards.** Logic code never awaits, tweens or plays sounds.
- The level bot and validator use the real `BoardModel` and `MatchResolver`. They never re-implement rules.
- Every script starts with a 2–4 line comment saying what it does and how to check that it works.
- Small files: one obstacle behaviour per script (`src/obstacles/ob02_withered_bramble.gd`, …).

## Finishing a task

End every task with this short report for the owner:

```
Done: <what changed, one line>
Files: <paths>
Check: <the one command or click that proves it works>
Rules touched: <IR-xx list, or "none">
Needs you: <decisions or playtests, or "nothing">
```
