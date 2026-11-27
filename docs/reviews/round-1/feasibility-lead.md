# Technical Feasibility Lead — Round 1

Era note: the document is dated 2026-11-25 and targets Godot 4.7.x, Web (itch.io) and Android, built by a solo developer (the GDD itself says the 14-day live-ops cycle is "Not feasible solo") on a ~US$210 budget. Judged against current-day tools and store rules.

## 1. 20-week plan does not fit the build list for one person who is still learning Godot — BLOCKING

**Passage:** Milestones: "3 · Godot basics + GDD signed off", "9 · Grey-box core (no art)", "14 · Art style locked; levels 1–30 built", "18 · Levels 31–60; Rat restoration live", "20 · Public on web + Android". Also: "Build our own board core in Godot around the 4-layer cell model"; and "The scope grows from 60 levels to the story-complete Act 1."

**Problem:** Weeks 1–3 go to learning the engine. That leaves about 6 weeks (weeks 4–9) to build everything in the Code structure table from scratch: a custom 4-layer board core, MatchResolver with 4 specials and 6+ combo types, a separate animation and SFX event queue, GoalTracker, LevelLoader, StoryPlayer, SaveService, a headless level bot, and GUT tests "for every special and combo and each OB behaviour". In the same period the developer also has to make the art pipeline work: 20–30 approved samples, then a trained Scenario style model, then Krita cleanup of roughly 70+ assets (4×6 protagonist poses, Monkey poses, statues, 12 obstacles, 6 backgrounds × 2 states, posters). They also have to integrate 12 obstacle behaviours, including the two hardest (OB09 beam hazard at 46 and OB15 at 56) in the final 4-week block. Weeks 18–20 hold release, store setup and web/Android QA with no buffer.

The document never says what gets cut if a milestone slips. Instead, the last section *adds* scope ("grows … to the story-complete Act 1") with no definition, while the Overview locks the MVP at 1–60. A cut list is needed: candidates are the Crane-carry combo, OB09 hazard, the posters and the shared cross-game profile. So is a decision on whether the Act 1 line is real.

## 2. "Shared by every Zodiac game" profile has no backend, no budget and an empty spec — MAJOR

**Passage:** Pitch: rewards "carry into every future game in the Zodiac world". SaveService: "One player profile shared by every Zodiac game". The heading "Player profile (shared by every Zodiac game)" has no content under it. Soul Dust is "stored for Part 2 hero upgrades".

**Problem:** On web plus Android, separate games can only share a profile through accounts and a server. Separate Android apps cannot read each other's local save, and itch.io browser storage belongs to one game page. The budget line (Claude, Scenario, music, Google Play) has no backend, auth or hosting cost, and the spec section is blank. The core long-term promise of the pitch therefore has no technical design. Either specify the account and sync approach and its cost now, or state that the MVP saves locally and that cross-game transfer is a Part 2 problem. Even then, define a versioned save schema now so fragments and Soul Dust can be migrated later.

## 3. The special × obstacle × layer interaction rules are not specified, but the code, the bot and the tests all depend on them — MAJOR

**Passage:** The layer table gives only coarse "Cleared by" entries ("Adjacent matches", "Matching / adjacent matches / specials"). The Paper Crane "Flies to a goal tile". "Crane + any special: Crane carries that special to a goal tile". "Jade Orb + special: Every piece of the most common colour becomes that special and fires". Nian's Eye: "its visible beam destroys specials that cross it". Nian's Jar "Catches specials".

**Problem:** Feature interdependency is the main technical risk in a layered match-3, and the document leaves it undefined. The doc does not answer any of these:
- Does a Rocket hit both the overlay and the content in a cell, or only the top layer?
- Does a 3×3 Firecracker blast damage a Petrified pillar once or once per covered cell?
- What counts as a "goal tile" for the Crane when the goal is spreading dew, a drop item, or a colour-lock shrine?
- Does a Crane flight path, or a carried special, "cross" the Nian's Eye beam and get destroyed?
- Do the six specials that a Jade Orb combo creates feed into Nian's Jar?
- Does a "two-hit" Frozen idol count a combo as one hit or two?

MatchResolver, all 16 ObstacleBehaviours scripts, the GUT tests and the level bot need one authoritative damage-and-targeting table. Without it, behaviour gets decided ad hoc in code, and bot results change every time a rule changes. The doc points to level_agent_brief.md for obstacle IDs but not for these interaction rules.

## 4. The level pipeline relies on an uncalibrated bot and gets contradictory inputs — MAJOR

**Passage:** "Headless bot: plays each level 500× and reports first-try win rate". "If the win rate misses the tier target, adjust goal counts (±20%) or moves (±2)". "Hard levels are tuned by the level bot to their win targets, never above". Rule: "New obstacles debut on the relief level right after a hard level."

**Problem (a), bot calibration:** All difficulty tuning depends on the bot's win rate standing in for a human's first-try win rate. The doc does not define the bot's move policy (random, greedy, or special-seeking), how it handles tap-to-fire specials and Crane targeting, or how it is calibrated against the 5 grey-box testers. A greedy bot can be far stronger or weaker than players. If so, every target in the tier table (95% / 85–90% / 60–70% / 35–45% / 25–35%) ends up tuned to the wrong value, and the "no pay-to-pass" fairness claim goes untested. Bot runtime is not costed either: 500 playthroughs × 60 levels × repeated iterations, in GDScript, with full cascade resolution.

**Problem (b), contradictory instructions:** The doc gives the level agent conflicting instructions:
- **Obstacle debuts:** Hard levels fall at 15, 20, 25, 30, 35…, so relief levels are 16, 21, 26, 31, 36. The obstacle table debuts at 17, 22, 28 and 34. These do not follow the stated debut rule, and 28 and 34 do not follow it under any reading.
- **Fragments on hard levels:** "Hard and finale levels always carry a fragment" conflicts with "Fragments start at level 26", which leaves hard levels 15 and 20 and finale 25 without one.
- **Backgrounds:** Art says "One per 10-level chapter" and the asset count gives 6 backgrounds. Level progression says chapters are 25 levels with "a new backdrop every chapter", which works out to 3 backgrounds.

An automated agent that is given conflicting rules produces levels that fail its own validation checklist. These conflicts need to be resolved before generation starts.

## 5. The Android public launch at week 20 ignores Google Play's testing gate for new accounts, and the platform audio and timing spec is not checked against the targets — MAJOR

**Passage:** "20 · Public on web + Android". The budget lists only "Google Play US$25". The feel spec gives millisecond targets: "Cascade hits every 120–180 ms; if several land within ~40 ms, delay or drop some", music ducking on buses, and a pool of 8–12 AudioStreamPlayer voices.

**Problem:**
- **Google Play testing gate:** New personal Google Play developer accounts must run a closed test with a minimum number of opted-in testers for 14 consecutive days before they can apply for production access. Google then reviews the application. The schedule has no slot for recruiting testers or for this wait. The week-20 Android "public" date is therefore not achievable unless the closed test starts by about week 17 with a build that is ready by then. The plan should either start the closed test at week 18 or earlier, or launch web first and treat Android as a closed test at week 20.
- **Audio and timing on target platforms:** "Feel is measured, not guessed" is a pillar, but the plan does not check the timing targets on the actual platforms. Android audio output latency varies a lot between devices. Godot web exports have their own audio playback and threading constraints, and itch.io needs the right export and threading settings. Either of these can blur 40–160 ms layering. The plan needs a device and browser check of the SFX queue in the grey-box milestone (week 9), not after art lock.

## Round 2 — Cross-examination

### Business Analyst

**CONFLICT: BA #1 says the "Act 1" sentence is the single most likely cause of a slip. I disagree. It is the most visible cause, not the root one.** BA's fix is "Remove the sentence, or define Act 1 as a level count and re-plan the weeks". Even if the sentence is deleted, my #1 still holds. Weeks 4–9 must deliver a custom 4-layer core, MatchResolver, AnimationQueue + SfxQueue, GoalTracker, LevelLoader, StoryPlayer, SaveService, the level bot and GUT tests. That is roughly six weeks of build from someone whose week-3 exit test is "You can explain this GDD's layer model". The 1–60 plan is already overcommitted before any Act 1 growth. The board should treat deleting the sentence as necessary but not sufficient, and still require a cut list.

**CONNECTION: BA #3 (itch.io audience is unrepresentative) combined with my #5 (Play testing gate).** BA warns that web/itch.io retention data "may say little about the intended market" and names Android as the meaningful channel. My #5 shows that a new personal Play account cannot reach production until it has run a 14-day closed test with enough opted-in testers, and Google has then reviewed the application. No slot in the plan allows for that. Together the two findings mean that at week 20 the only public build is likely the web build, so the "Tracking day-1 return" milestone measures exactly the audience BA says is wrong. The MVP's stated reason to exist ("prove retention first") fails on schedule mechanics, not on game quality. Neither of us could see that alone.

**CONNECTION: BA #2 (demote "Souls carry forward") resolves most of my #2.** I accept BA's direction: local save for the MVP plus an extensible schema. Feasibility adds one condition. "Extensible" must mean a versioned save format with a migration hook written in week 4–9. Otherwise the first Part 2 game inherits an unversioned blob.

**CONNECTION: BA #5 (6 backgrounds × 2 vs 25-level chapters).** I raised this as a level-agent contradiction. BA's framing is also correct: 12 background images instead of about 6 is the largest single asset-hour swing in the art list. It has to be decided before the Scenario model is trained, and the budget buys Scenario for only 3 months.

### Systems Designer

**CONNECTION: SD #1 (fragment-as-goal undefined) is also a code-path decision, and feasibility has a preferred answer.** SD offers two fixes: the fragment uses one of the tier's goal slots, or it is auto-collected on any win. The goal-slot option reuses GoalTracker, the level JSON `goals` array, and the bot's existing win check, so it needs no new code path. Auto-collect-on-win needs a special case in GoalTracker and a separate "fragment missed but level won" state in SaveService. That state is the same per-level fragment persistence that "Fail the level and the fragment stays for the retry" already quietly requires. I argue for the goal-slot option, counted inside the 3–4 / 4 caps, because it is cheaper to build and the bot measures it for free.

**CONNECTION: SD #3 adds a fact I missed and strengthens my #4(a).** SD points out that "tuned … to their win targets, never above" can be read as two opposite constraints. A bot needs a single numeric acceptance band, so this ambiguity is not cosmetic: the pipeline step "if the win rate misses the tier target" cannot run until it is settled. SD's fix also overlaps with mine: set a bot-to-human offset from the week-9 testers. Five testers on levels 1–10 cannot calibrate hard and finale tiers, though. Those tiers do not exist until week 14. A second calibration pass belongs at week 14, and the plan has no time for it.

**CONFLICT: SD #2's fix (renewable guardian-power charge meter) adds a system the schedule cannot absorb.** A charge meter means new UI, a new GoalTracker or MatchResolver hook, new save state, and a bot that must simulate charge use or misreport win rates. SD itself notes the bot "needs to know whether players are expected to have boosters". The cheaper fix with the same effect is a fixed number of free uses per level, or a flat coin price on the existing booster bar. Both use data the save already holds. I support the problem; I oppose that particular fix for the MVP.

**CONFLICT on severity of SD #4 (fragment arithmetic) for the MVP.** The arithmetic errors are real, but inside levels 1–60 the random 30% applies only to drops in 51–60. That is hard level 55, finale-adjacent drops and about 1 in 5 others, so roughly 3 drops. For MVP feasibility this is MINOR. It is MAJOR only for the post-MVP plan.

### Adversarial QA

**CONNECTION: QA #4 confirms my #3 and extends it into missing core rules.** I listed layer and obstacle interactions. QA found gaps in the special rules themselves: a tapped Jade Orb has no swap colour, overlapping shapes (5-in-line inside a T, 2×2 inside an L) have no priority order, and a beam-destroyed special may or may not count as a hit on the Eye. MatchResolver's very first feature, "Matches, specials", cannot be finished without a shape-priority rule, so this blocks the grey-box at week 9, not just later obstacles.

**CONNECTION: QA #2 (reroll exploit) plus BA #5 (post-MVP logic in the MVP) leads to a cut.** The reroll exploit only exists because the 70/30 roll and the pity counter are built at all. In the MVP they govern about 3 drops. I propose the MVP ship 51–60 drops as 100% Ox (trail-only). That removes the exploit, the pity edge cases, the random-pool arithmetic and the save state for roll timing in one stroke, and costs nothing visible to MVP players. This goes on my cut list.

**CONNECTION: QA #1 (board-clearing effects vs the fragment) is an instance of my missing damage table.** Whether Jade Orb + Jade Orb or a Rocket destroys an OB11 drop item is exactly a "what can damage what" row. QA's question about replaying won levels is also a SaveService schema question that the empty profile section should have answered.

### Player Psychologist

**CONFLICT: PP #2 wants Crane + special taught; I nominated the Crane-carry combo for the cut list.** If the combo stays, it needs a tutorial level (more level content), a definition of "goal tile" for every goal type (my #3), and a beam-crossing rule (QA #4). It is the most interdependent feature in the document. My position: either cut Crane + special from the MVP combo set, or keep it and accept that it must be taught, specified against every goal type, and tested against OB09 before week 14. Teaching an under-specified combo is the worst option. I still lean towards cutting it, because the Crane alone already delivers the "signature, telegraphed" twist.

**CONNECTION: PP #2 (combos never taught) plus my #4(a) means the bot is systematically optimistic.** A bot that plays combos humans never learned will report higher win rates than players get. Hard levels tuned to 35–45% on the bot will land below that for humans. This feeds directly into PP #1 and SD #3. The lives lock-out maths uses the target rates, so the real lock-out rate at 25 and 50 is likely worse than their 17–24% estimates. The bot policy must be restricted to taught actions.

**CONNECTION: PP #4 (move Nian's Eye past 50) helps my schedule risk, and there is a clean slot.** Level 51 is the relief level after finale 50, so debuting OB09 there satisfies the debut rule. It also moves the hardest obstacle out of the "Rat restoration live" week-18 critical path. Better still for feasibility, cut OB09 from the MVP entirely. Nothing in 1–60 requires it, and it carries the most open interaction questions in the document.

### Narrative Critic

**CONNECTION: NC #1 and NC #4 (Monkey identity and protagonists undefined) block the art pipeline on a date the plan never sets.** "Generate 20–30 approved samples → train one Scenario style model" cannot start until the protagonists have designs. The Cast table says "Names, bios and designs from you", and those are listed in Open questions. The protagonists account for 24 of the roughly 70 assets. The level-25 poster depends on the Monkey answer, and it is a week-14 "Done when" item ("temple reveal playable"). Open questions need a resolution deadline, by week 6 at the latest, or the week-14 art lock slips.

**CONFLICT: NC #3's fix (beats on every hard level, more villain faces) grows scope.** Filling hard levels 15, 35, 45 and 55 and giving the forces more faces means more story cards and more character art. The asset list budgets "the Nian and 2 of its forces". From feasibility, the cheaper fix is to change the pillar text to match the beats table, or to reuse the two existing forces across the hard levels. Do not add new characters in this window.

**Minor agreement with a cost note on NC #5:** re-theming Nian's hazards away from Fire costs nearly nothing, because "looks and names come from a theme file". There is no feasibility objection.

### Revisions to my Round 1

- **#3 upgraded MAJOR → BLOCKING.** Three colleagues found undefined rules (QA: shape priority, Orb tap, beam hits; SD and QA: fragment goal semantics; PP: beam vs specials). All of them land in MatchResolver and GoalTracker during weeks 4–9. MatchResolver cannot pass its own GUT tests without a shape-priority rule. This is now a pre-grey-box blocker, not a later risk.
- **#5 upgraded MAJOR → BLOCKING for the week-20 goal,** because of the BA #3 connection above. If Android is not public at week 20, the retention test runs on the wrong audience.
- **#4(b) downgraded to MINOR as a separate item.** The debut, fragment and background contradictions are independently confirmed by SD, QA, NC and BA, but each takes minutes to fix in the document. #4(a), the bot calibration, stays MAJOR and is strengthened by SD #3's "never above" ambiguity and PP #2's untaught-combo point.
- **#2 conditionally downgraded MAJOR → MINOR** if the board adopts BA #2's demotion plus a versioned local save. It stays MAJOR while the pitch keeps promising cross-game carry-over.
- **#1 stands as BLOCKING,** with an updated cut list: Crane + special combo, OB09 out of the MVP (or debut at 51), 70/30 random drops and the pity rule (trail-only in 51–60), shared cross-game profile, and the "Act 1" growth sentence.
