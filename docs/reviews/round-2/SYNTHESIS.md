# Review Moderator — Synthesis (second review)

Document: *Zodiac Forest — Match-3 GDD (MVP)*, rev 208 (after the first review's fixes and the owner's edits)
Board: systems-designer (SD), narrative-critic (NC), player-psychologist (PP), feasibility-lead (FL), adversarial-qa (QA), business-analyst (BA)
Note on process: FL's Round 2 covers four colleagues, not five. It couldn't locate adversarial-qa.md with Read-only tools.

Compared with the first review, no reviewer flagged these again:
- whether a fragment is a goal;
- the "Act 1" scope growth;
- the Nian's Eye beam;
- the shared cross-game profile;
- the random-drop arithmetic.

The blockers are now narrower. They're about the edges of the new systems (boosters, free gifts, the retention test), not the core loop.

---

## 1. Top 5 issues (severity × confidence)

### #1 — BLOCKING — Interaction rules still miss the swap and the tools the MVP itself hands players
- **The problem.** "Crane + special is held back", but the swap is still possible. The level-16 pre-level booster ("Start with a Rocket + Crane") and the 6-win streak chest put both pieces on the board on purpose. The table has no row for that swap.
- **Boosters and gifts are outside the table.** Fragment protection covers only "any special, combo or board clear". So:
  - Hoof Tap can remove a drop-item fragment and leave the level unwinnable.
  - Rat's Nibble ("a whole row of obstacles") arguably includes OB11 fragments.
  - Tail Slam, Bamboo Dash's diagonal and Feather Fan have no rows.
- **Firecracker hit count.** Its "3×3 blast, twice" can be read as one hit or two on multi-cell and two-hit obstacles.
- **Flagged by:** QA #1, #2; FL #2. In Round 2: PP N1, N3; SD connection 1; BA N1.
- **Outcome: STRENGTHENED.**
  - **The swap will happen in real play.** The idle hint advertises combos, and the bot never makes the swap, so human and bot rates diverge (QA).
  - **Refusing it isn't a fix for players.** A refused special-special swap breaks the rule the game teaches (PP).
  - **Unwinnable levels get worse.** The fail flow still offers a 300-coin continue on a level with a deleted fragment, so players pay for moves that can't win (SD).
  - **Severity.** FL rates the gap MAJOR; QA and PP rate it BLOCKING. QA would drop to MAJOR if the pre-level booster and streak chest are cut.

### #2 — BLOCKING (contested) — Free every-level powers sit outside the difficulty calibration, and the fairness check only catches levels that are too hard
- **The problem.** The Monkey's Staff (from 30/31) and Rat's Nibble (from 51) are free every level. The streak chest and pre-level freebies add more. Yet the bot plays "no boosters", and every target is "without boosters".
- **Why calibration can't catch it.** The week-14 calibration covers levels 15–30, before the Staff exists. The fairness rule only flags rates *below* the band, so drift upward is never caught.
- **Flagged by:** SD #1, QA #5. In Round 2: BA N1, FL (on the fix), NC (Golem/Staff), PP N5.
- **Outcome: STRENGTHENED, severity contested.**
  - **Upgrades.** QA moved MINOR → MAJOR. SD kept BLOCKING but narrowed it to the build of levels 31–60.
  - **Story cost.** NC adds that a free Staff strips the stone obstacles the Stone Golem (40–45) represents.
  - **Two difficulty curves.** PP adds that players who forget the free charge and players who use it play different curves.
  - **Moss question.** QA argues the impact hinges on an undefined "multi-cell" list: if Creep moss is many one-cell obstacles, the Staff barely helps.

### #3 — BLOCKING — The retention test can't produce a usable go/no-go
The MVP's only output is a D1/D7 verdict, and five separate problems undermine it:
- **D7 measures running out of content.** 60 levels with no replay and no live ops is about 2–4 days of play (SD #2, BA #1).
- **D1 partly measures a lives wall.** About 5–25% of players hit 5 straight fails at levels 15 and 20 (PP #1, revised).
- **The cohort is small and contaminated.** There's no player source, no user-acquisition budget and no minimum sample, and closed testers aren't excluded (BA #1).
- **The verdict comes late.** It can't land before about week 22, and Claude Pro and Scenario keep billing (FL #4).
- **No telemetry to separate causes.** There's nothing to tell "finished" from "churned": no furthest-level reached, no attempt or lives-out events. The lives-wall metric includes level 25, where a fail costs no life (FL #3 revised, SD).
- **Flagged by:** BA #1, SD #2, FL #3, #4, PP #1. In Round 2: NC (cliffhanger to a non-existent level 61), QA (quitting mid-level corrupts first-try data).
- **Outcome: STRENGTHENED.**
  - SD's content-exhaustion finding went MAJOR → BLOCKING.
  - FL's telemetry finding went MAJOR → BLOCKING.
  - PP's lives finding went BLOCKING → MAJOR: still real, but not a week-long wall.

### #4 — BLOCKING — The week 3–9 build is overloaded, and the cut list protects the wrong things
- **The workload.** In about 6 weeks after "Godot basics", one developer must build a custom 4-layer core, MatchResolver, 11 obstacle scripts, GUT tests for every rule and a headless bot.
- **The cut list doesn't help.** It drops only late content: the Staff, OB15, the level-60 art, then levels 51–60.
- **What's crowding the plan.** The GDD also carries post-MVP system design plus decorative extras: the coin economy with priced boosters, pre-level boosters, the streak chest, the quip matrix and a recorded sound library.
- **Flagged by:** FL #1, BA #5.
- **Outcome: STRENGTHENED.**
  - BA upgraded #5 to BLOCKING: the decorative features directly cause Issues #1 and #2.
  - A late Staff cut re-tunes levels 30–60, so it isn't free (SD, QA, FL).
  - FL and BA agree the list is mis-ranked but disagree on what goes first. See Disagreement D.

### #5 — MAJOR — The fragment arc isn't visible or coherent from start to finish
- **No progress display.** Nothing shows guardian progress: no x/8 meter and no in-between statue stages (PP #2, now PP's top finding).
- **Collecting before the reason.** Fragments are collected from level 26, but nobody says they can be gathered until the level-30 decision (NC #2).
- **Wrong guardian named.** Kancil's "Fragment freed" bark names the Rat on Ox fragments, and it's the only per-fragment feedback (NC #5, MINOR → MAJOR).
- **Thin ending.** The Ox may end the MVP at 2/12 (SD #5). The level-60 cliffhanger repeats stakes the levels 35–45 beats already showed (NC #1).
- **Flagged by:** PP #2, NC #1, #2, #5, SD #5. In Round 2: PP N2, NC (Psych connection), SD connection 5.
- **Outcome: STRENGTHENED.** Three reviewers each found one piece. PP N2 shows the pillar "every fragment visibly brings a guardian closer" fails at the first fragment, the middle, and the MVP's last screen.

**Process finding (BA asked the moderator to record it):** all six open questions are ticked, but no answers are written. The body still says "(proposed)", "(tbc)" and "stone (or ice)", and there's no economy sheet or forest-meta design. Four reviewers found this pattern independently (BA #3, FL #5, SD #4, PP #3). As a result, the week-6 gate ("every item answered") isn't a real gate.

---

## 2. Unresolved disagreements (escalated to the designer)

**A. Lives in a game with nothing to sell.**
- **PP and FL:** soften or remove lives. They have no revenue role, cause frustration spikes at 15 and 20, and are the cheapest change in the review (FL).
- **BA and SD:** lives are the only thing rationing 60 levels, and removing them speeds up content exhaustion. Keep lives, but make fails on hard levels 15 and 20 free, or let coins buy a refill.
- **Common ground:** all four accept reading D7 only for players who haven't finished.
- **Decision:** remove, soften, or keep lives with a coin refill.

**B. The free Staff and Nibble.**
- **SD:** teach the bot to use them with a usage policy, and add a ceiling to the fairness check.
- **FL:** that's the expensive option. Make them limited charges like other boosters, or cut them now.
- **BA:** cut them before calibration, not as the first emergency cut.
- **NC:** the Nibble is chapter 2's only playable payoff, so it should be the last gift to go.
- **Severity:** BLOCKING (SD, NC) vs MAJOR (QA).
- **Decision:** free every level, limited charges, or cut.

**C. The coin economy.**
- **BA and SD (revised):** cut priced boosters, pre-level boosters and the streak chest. Coins gate nothing, total supply is about 2,600, and a continue costs 8–15 wins.
- **PP:** the continue is the game's only fail softener, and the streak chest is one of the few rewards in levels 1–25. If coins go, lives must go too.
- **Decision:** cut the economy, or turn coins into the lives refill.

**D. What the cut list removes first.**
- **FL:** cut engineering by when its cost lands: Jade Orb + special, Firecracker + Firecracker, simpler Crane targeting, the two human calibration rounds. Keep the plain bot.
- **BA:** cut decorative systems first; that also makes the bot cheaper.
- **SD:** agrees with the combo cuts but objects to simplifying Crane targeting after calibration, because it shifts every band.
- **Decision:** how to merge the two lists into one ranking.

**E. Levels 51–60.**
- **NC:** ship 1–50 and end on the Rat's restoration as a complete arc, unless 51–60 gets a scripted Ox count, a guardian-aware bark and a reworked cliffhanger. SD's connection 5 notes this fallback removes three gaps at once.
- **The doc** keeps this as the last cut-list item.
- **Decision:** keep 51–60 with fixes, or end the MVP at 50.

---

## 3. Quick wins

1. **Complete Interaction rules with five new rows:**
   - Crane swapped with a special: both fire, Crane first. This is a visible behaviour, not a refusal (QA #1, PP N1).
   - Boosters and gifts never delete fragments or drop items; they collect them or skip them (QA #2, FL #2).
   - The Firecracker's second blast counts as one hit or two: pick one (FL #2).
   - A list of which obstacles count as "multi-cell" (QA, FL).
   - Hide the continue offer when the remaining goals can't be reached (SD connection 1).
2. **One pass of text fixes:**
   - Level 34 teaches drop items with lost hatchlings; the first drop-item fragment comes at 35 or later (QA #3; NC and SD agree; PP suggests 38).
   - Template the bark to name the right guardian (NC #5).
   - At level 25, the Monkey says the souls can be gathered (NC #2).
   - Define "hardest board" by goal load, not win rate (SD, QA, NC).
   - Name the level-20 force as the Creep Wraith, and deliver level 40 as a story card (NC #4, FL #5).
   - Drop level 25 from the lives-wall metric (SD).
3. **Make the measurement plan real:**
   - Log furthest level, attempts, wins and lives-out per player, and define what quitting mid-level does to lives (FL R2, QA new).
   - Exclude closed testers from D1/D7 and add a "ran out of content" branch (BA #1).
   - Write the answers next to the ticked open questions (BA #3, FL #5).

---

## 4. Verdict

The GDD is much stronger than in the first review: the core loop, the fragment-as-goal rule and the scope line are no longer contested. It is still not ready to hand to an agent crew that will generate and tune levels. FL #2 says the level agent and the bot are meant to work from one source of truth. Right now that source has no rules for the Crane + special swap, the boosters, the free gifts or the Firecracker's hit count (Issue #1). The bot's no-booster baseline also doesn't match what players will hold from level 30 (Issue #2). So any levels the crew tunes would be tuned to rules and a game that differ from what ships. The measurement plan (Issue #3) and the cut-list ranking (Issue #4) also need fixing before launch, but they don't block starting work. The single change that matters most: finish the Interaction rules table so it covers every booster, gift and special-on-special swap, and decide whether the free Staff and Nibble stay free (Disagreement B). Both feed directly into what the level agent and bot are told.
