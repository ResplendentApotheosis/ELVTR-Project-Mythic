# Technical Feasibility Lead — Round 1

Scope assumed from the document: a solo developer ("Not feasible solo" on live-ops; "You playtest..."; "Owner: you") who is still learning the engine (week 3 milestone is "Godot basics"), 20 weeks, about US$210, Godot 4 / GDScript, web + Android.

## 1. Most of the engineering risk sits before week 9, and the cut list cannot touch it — BLOCKING

**Problem.** Between "Godot basics" (week 3) and the week-9 grey-box, the plan needs a custom 4-layer BoardModel, a MatchResolver for 4 specials and 5 combos, behaviour scripts for the 11 MVP obstacles, GUT tests for "every special and combo, and every row of Interaction rules", and a working headless level bot. The bot has to exist by week 9 because "the week-9 testers' results on levels 1–10 set a first bot-to-human offset". The same window also has to close every open question and lock the hero designs (week 6), and level 1–10 JSON has to be generated and validated. A new Godot developer working alone would struggle to do that in about 6 weeks. Match-3 cascade, gravity and refill logic with layered obstacles is where most of the hard bugs in this genre come from.

**Passage / omission.** Milestones table (weeks 3, 6, 9); Technical design ("Build our own board core... Kenney's Starter Kit Match-3 is a learning and feel reference only"); "If a milestone slips, cut from the list below instead of moving the date." The cut list removes Monkey's Staff, the OB15 minion, the level-60 card art, and levels 51–60. All of these are late, content-side items. Nothing on the list reduces the week-3-to-9 engineering load: no fallback to Kenney's kit as a base, no deferral of the level bot, no cut of combos, the three-layer audio system, or the Paper Crane's targeting. A slip at week 9 would therefore push every later date, and the cut list is designed not to allow that.

**Ask.** Add engineering cuts to the list, or allow the Kenney kit to be forked. Some candidates: defer Jade Orb + special and Firecracker + Firecracker, simplify the Crane's targeting to "nearest goal", ship the bot after week 9, and use a single-layer SFX fallback.

## 2. The Interaction rules table has to be "finished before the week-9 grey-box," but it has gaps and contradictions — MAJOR

**Problem.** The table is the single spec that MatchResolver, the GUT tests and the level bot all read from. It does not yet settle several cases that code must handle:
- **Crane + Jade Orb.** "Crane + special is held back until after the MVP", but "Jade Orb + special: every piece of the most common colour becomes that special and fires" does not exclude the Crane. Separately, nothing says what happens in the MVP when a player swaps a Crane with another special: no combo, a normal swap, or each special fires on its own.
- **Firecracker.** It is a "3×3 blast, twice", but "Obstacles bigger than one cell: take at most one hit per special". Does the second blast count as a second hit on a frozen idol or a pillar?
- **Boosters and gifts are missing from the table.** Tail Slam ("one hit to every cell") against the multi-cell rule; Monkey's Staff ("every cell of one multi-cell obstacle", but no list says which OBs count as multi-cell); Rat's Nibble ("gnaws through a whole row of obstacles": how many hits, which layer, and does it skip fragments?); Bamboo Dash's diagonal, which is the only diagonal clear in the game and needs its own geometry and tests.
- **Win-streak chest.** It "drops a free Rocket and Crane onto the next board", with no placement rule. That conflicts with "no pre-made matches" and with the generator's 3-valid-moves guarantee.
- **Hoof Tap** "removes ... the top layer of one cell". On a fragment cocoon or drop item, does that free or collect it?

**Passage.** Interaction rules section; Combos note; Booster unlocks table; Win streak row.

**Why it matters.** Every unresolved row is a bug that may be invisible to the bot or a ruling made in code that the GDD never records. Both outcomes undermine the plan to have the level agent and bot work from a single source of truth.

## 3. Bot calibration and the "never below its band" fairness rule are not measurable with the planned testers — MAJOR

**Problem.** All difficulty tuning depends on a bot-to-human offset, and that offset comes from "5 testers play levels 1–10" at week 9. The week-14 round on hard levels 15–30 gives no tester count. Five people on ten easy levels cannot tell an 85–90% band apart from a 95% band, and they say nothing about hard levels with 35–45% targets. Meanwhile the fairness rule promises that "every level's human first-try win rate must sit inside its tier's band and never below it." Before launch, there is no plan to collect anything close to enough human attempts per level to check that. The bot's "greedy, human-like policy" is also undefined, and the offset is likely to vary by tier and obstacle mix.

**Passage.** "Bot calibration" paragraph; tools/level_bot row; Fairness rules ("No 'pay to pass' spikes"); Level tiers table.

**Ask.** Relabel the bands as bot-derived targets until live data arrives. Name the week-14 tester count. Record per-level attempt and win telemetry in the build that goes to the closed test, so that the 16–20 week window produces real human rates.

## 4. The Android release chain has no slack, and the success test depends on it — MAJOR

**Problem.** The document's own numbers make the timeline tight. The closed test starts in week 16 and needs 12+ testers opted in for 14 consecutive days, so production access can be requested at end of week 18 at the earliest (which is what the plan schedules). Google then has to review that application and the production release before week 20. If any tester drops out and the count falls below 12, the 14-day clock can restart. The MVP's pass/fail test is "Android decides", and a D7 reading needs at least 7 days after public launch. So the retention verdict cannot arrive inside the 20 weeks even in the best case, and a review delay pushes it further. That has a budget effect too: Claude Pro is costed for 6 months, and Scenario for only 3.

**Passage.** Milestones weeks 16, 18 and 20 ("Android public once Google approves"); Retention test ("Android decides because new personal Play accounts must run a closed test..."); Budget line.

**Ask.** Start the closed test earlier (week 14, with the grey-box or art-in-progress build) and recruit about 20 testers. State plainly that the retention verdict lands around week 22 or later, and budget for the extra subscription months that implies.

## 5. Art and content scope is undercounted, and "closed" decisions are still open — MINOR

**Problem.** The MVP asset count leaves out items the story table requires:
- the 4-panel level-1 intro comic;
- a "first mid-boss" at level 20, which is not one of the "2 of its forces";
- level 40 delivered as a "Boss level", with no boss mechanic among the obstacles or interaction rules;
- per-state art for 3-layer brambles, pillar heights, colour variants for shrines and lanterns, and different creatures inside the cocoons;
- booster-action art for the Staff and Nibble;
- the map screen, the store video, and the 4 music loops (only "~US$20" is budgeted for music).

Every item in Open questions is ticked "[x]", yet the document still says "Art: primary colours (tbc)" and "Audience ... (proposed, confirm)". Stone-vs-ice guardians and the element families are not answered anywhere. The hero designs and the style model depend on these at week 6, and Scenario is paid for only 3 months.

**Passage.** Asset count paragraph; Story beats rows for 1, 20 and 40; Overview table; Open questions; Budget.

**Ask.** Record the actual answers next to the ticked boxes. Define the level-40 "boss level" as either a story card or a mechanic. If it is a mechanic, it needs interaction rules and probably a place on the cut list. Then recount the assets against the Scenario subscription window.

## Round 2 — Cross-examination

Files read: player-psychologist, systems-designer, narrative-critic, business-analyst (plus my own). I could not find the sixth review file by name, and this round was limited to Read, so I could not list the folder. My cross-examination covers these four.

### Business Analyst

**CONFLICT: BA #5, "the cut list cuts the wrong things."** We agree the cut list is mis-ranked, but we rank it differently. BA puts the coin economy, pre-level boosters, win streak, quip matrix and sound library at the top of the cut list and labels the level bot "decorative". I disagree about the bot. A solo developer cannot hand-tune 60 levels against a 35–45% hard band without automated play. The bot is what makes "levels 1–60" achievable at all, so it is the last tool I would remove. What can be cut is the **two human calibration rounds** and the "human-like policy" polish. A plain greedy bot with tier bands relabelled as bot targets (my R1 #3) gets most of the value. On the coin and streak cuts, BA is right, and there is an engineering benefit BA does not mention: cutting the win-streak chest also removes my R1 #2 placement-rule contradiction, and cutting pre-level boosters removes 16 booster-on-board spawn cases from the Interaction table and the GUT suite. My remaining disagreement is about order. The quip matrix and recorded sound library are late, parallelisable content work, so cutting them does not relieve the week-3-to-9 crunch. The cuts that help first are combos, Crane targeting and bot calibration. BA's list and mine should be merged, ranked by **when** each item's cost falls, not only by how large it is.

**CONNECTION: BA #1 (contaminated, unsized cohort) + my R1 #4 (Android chain).** My Ask was to start the closed test early with about 20 testers. Under BA's finding, those testers must be **excluded** from D1/D7. That means the public cohort is everything the retention test has. A new personal Play account with no UA budget, launching around week 20 (mid-April 2027, which also confirms BA #2's Lunar New Year gap), will get a trickle of organic installs. So the timeline problem is worse than I said. The verdict does not just land at about week 22. It lands whenever enough non-tester installs reach D7, which could be months away, while Claude Pro and Scenario keep billing. Even a small UA line is a schedule item, not just a marketing one.

### Systems Designer

**CONFLICT: SD #1, "the bot must use free charges (with a usage policy)."** The diagnosis is correct. The proposed fix is the expensive option. Teaching the bot when to spend a Staff or Nibble charge is a search or heuristic problem added to a tool that is already due in my overloaded week-9 window. It also can't be built yet, because the rules for those charges are undefined (my R1 #2: which OBs are "multi-cell", how many hits a Nibble applies, whether it skips fragments). The cheaper fix, and the one I'd argue for, is to stop making them free every level. Grant them as limited charges, as other boosters are, so the "no boosters" bot baseline stays valid. Or move them onto the cut list ahead of levels 51–60, which also addresses BA's point that free powers undercut later paid boosters. SD's observation that cutting the Staff silently re-tunes levels 30–60 is also a feasibility point: a cut that changes balance is not a free cut, and the cut list should say so.

**CONNECTION: SD #3 (finale/hard band contradiction) + bot noise.** SD notes that 500-run noise turns the finale tie into a coin flip. In tooling terms, the auto-tune loop ("adjust goal counts ±20%") may **never converge** on finale levels, because no setting satisfies both constraints. The bot will oscillate or the developer will hand-override, and that time comes out of content weeks. Fix the rule before the bot is written.

**CONNECTION: SD #2 + BA #1 + my R1 #3 (content exhaustion makes D7 unreadable).** SD and BA independently show that D7 is confounded by players finishing the content. The only cheap way to separate "finished" from "churned" is the per-level progress telemetry I asked for in R1 #3. Adding a daily puzzle (SD's option) is new engineering that I would not accept in this schedule. Logging the furthest level reached and level-attempt events costs little. That makes the telemetry ask load-bearing for three findings at once (see Revisions).

### Player Psychologist

**CONFLICT (among colleagues, settled by my lens): PP #1 vs SD #2 / BA #1 on whether lives are a wall.** PP models lockout around levels 15–22 in session 1. SD and BA say lives slow players by only a day or two. Both are estimates from target win rates, and the targets are exactly what my R1 #3 says can't be validated before launch. None of these models should drive the decision. From a build standpoint, "removing lives" or "no life lost on hard levels" is the **cheapest change in the whole review**: it deletes a timer, a UI and a save field. Given the evidence can't be resolved and the change is cheap, I side with PP's direction. Soften or remove lives in the MVP, because it removes one confound from a retention test that already has too many.

**CONFLICT: PP #2 and #3 add scope.** A guardian x/8 meter, statue art at multiple stages, a forest-healing map and a "rescued friends" collection are all new assets and UI, added to a pipeline I already called undercounted (R1 #5) with Scenario paid for only 3 months. If one is adopted, I'd accept the cheapest: a numeric meter plus 2–3 statue stages reusing one base sprite. A per-level forest-healing map is a new system, and it would need its own cut-list entry.

**CONNECTION: PP #4 (move the mummified creature to level 1–2).** Feasibility has no objection, but there is a dependency. OB behaviour for the creature must then work by the week-9 grey-box (it already must for level 7), and levels 1–10 JSON must be regenerated before the week-9 testers play them. If the change is made, it has to happen before week 9, or the bot-to-human offset is measured on a curve that no longer exists.

### Narrative Critic

**CONNECTION: NC #4 + my R1 #5 (level 20 and level 40 bosses).** Two lenses independently found that the "first mid-boss" at 20 has no identity and the level-40 "Boss level" has no defined format. In narrative terms that is a lore gap. In build terms it is an unsized feature: if "Boss level" means a boss on the board, it needs a new obstacle with multi-phase behaviour, interaction rows, tests and art, none of which appears anywhere. That is why I upgrade it below.

**CONNECTION: NC #5 (bark hard-codes "Rat").** This is trivial to fix (a `{guardian}` template), but it points to a pattern worth stating: the quip matrix is written as fixed strings. Templating it now also lets BA's proposed cut of the quip matrix be partial (keep one line per moment) instead of all-or-nothing.

### Revisions

- **Upgrade R1 #3 from MAJOR to BLOCKING, narrowed to telemetry.** SD #2 and BA #1 show that D7 can't be interpreted without knowing who ran out of content, PP #1 vs SD #2 shows the lives question can't be settled without real fail data, and my bands can't be validated without it either. The MVP's only output is the retention verdict. A build without per-level attempt, win, furthest-level and lives-out events can't produce a usable verdict. The document asks for exactly one such metric (lives-out quits, which SD notes is already broken at level 25).
- **Split R1 #5: level-40 "Boss level" goes from MINOR to MAJOR**, conditional on it being a board mechanic (see NC connection). The rest of #5 stays MINOR.
- **Withdraw the win-streak-chest bullet from R1 #2** if the streak is cut as BA proposes. I'd endorse that cut over writing the placement rule. The Staff and Nibble bullets stay, and they become more important, since SD #1 depends on them.
- **Revise R1 #4's Ask.** "Recruit about 20 closed testers" holds, but they must be excluded from the retention cohort (BA #1). Add a minimum public cohort size and a small acquisition budget as dated schedule items. Severity stays MAJOR.
- **R1 #1 stays BLOCKING.** No colleague's finding reduces the week-3-to-9 load. SD #1 (a bot that uses boosters) and PP #2/#3 (new meta UI) would each add to it if adopted as written. That is why I proposed the cheaper alternatives above.
