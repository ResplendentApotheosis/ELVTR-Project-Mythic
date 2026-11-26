# Review Moderator — Synthesis

Document: *Zodiac Forest — Match-3 GDD (MVP)*, dated 2026-11-25
Board: systems-designer (SD), narrative-critic (NC), player-psychologist (PP), feasibility-lead (FL), adversarial-qa (QA), business-analyst (BA)
Method: six isolated reviews, then cross-examination, then this synthesis. Everything below traces to the review files.

---

## 1. Top 5 issues (ranked by severity × confidence)

### #1 — BLOCKING — The rules never say whether a soul fragment must be collected to win, so "Rat restored at exactly level 50" can fail
- **Problem.** Winning only requires "all goals done". Nothing covers a win where the fragment was left uncollected, whether board clears (Orb + Orb, Rockets) collect or destroy it, or whether won levels can be replayed. If the fragment becomes an extra goal, hard levels and finales go over their 3–4 / 4 goal caps.
- **Flagged by:** SD #1, QA #1 (found independently in Round 1). In Round 2: FL (goal slot is the cheapest build), PP A1, NC N1.
- **Cross-examination: STRENGTHENED.**
  - **Script breaks too.** The level-30 and level-40 story beats assume the fragment was collected (NC N1, QA).
  - **Specials depend on it.** The Crane targets "goal tiles", and only goals are protected from hazard beams (SD X1).
  - **Fix converging.** SD, FL and QA favour making the fragment take one of the tier's existing goal slots. PP adds a condition: a fragment must never be lost on a win or destroyed by the player's own specials. QA adds that the replay rule must be stated.

### #2 — BLOCKING (contested) — The difficulty walls sit on the two story payoffs, and the bot that tunes them is uncalibrated and probably optimistic
- **Problem.** Finales 25 (temple reveal) and 50 (Rat restored) target 25–35% first-try wins, with 5 lives refilling at 1 per 20 minutes. About 12–24% of players run out of lives on each of them. The unlimited-lives window only opens *after* the finale is beaten.
- **The bot.** All tuning relies on a headless bot whose play policy and mapping to human win rates are undefined. "Never above" the target can be read two opposite ways.
- **Flagged by:** SD #3, PP #1, FL #4a. In Round 2: NC N4, BA Connection 1, QA (replay farming).
- **Cross-examination: STRENGTHENED overall, but one part WEAKENED.**
  - **The bot error has a direction.** No level teaches combos, so a combo-using bot will overstate human win rates (PP B2, SD X2, FL). SD's estimate: lock-out at a finale rises from about 17% to about 33%.
  - **Calibration can't reach the hard tiers.** The week-9 testers only play levels 1–10 (PP B2, FL).
  - **Weakened part.** PP withdrew "the continue is almost never affordable": a player who hasn't used a continue reaches level 25 with about 1,400 coins. PP downgraded the finding to MAJOR, while SD upgraded it to BLOCKING. See Disagreement A.

### #3 — BLOCKING — The 20-week solo plan doesn't fit the build list, there is no cut list, and an undefined "Act 1" sentence grows the scope
- **Problem.** Weeks 1–3 go to learning Godot. That leaves about 6 weeks to build:
  - a custom 4-layer board core and the MatchResolver;
  - the animation and SFX queues;
  - the level bot, save system and story player;
  - GUT tests and the AI-art pipeline.

  Then 60 levels have to be built and tuned. Meanwhile "The scope grows from 60 levels to the story-complete Act 1" contradicts the Overview's 1–60 MVP, and "Act 1" is defined nowhere.
- **Flagged by:** FL #1, BA #1. In Round 2: NC N6, SD X5, QA.
- **Cross-examination: SURVIVED intact, and corroborated by two lenses.**
  - **Deleting the sentence isn't enough.** The 1–60 plan is already overcommitted without it, so a cut list is still needed (FL).
  - **The sentence contradicts the ending.** The story ends on a cliffhanger at 60, not a complete act (NC N6).
  - **Agreed cuts.** FL's revised cut list: the Crane + special combo, OB09 (Nian's Eye), the 70/30 random drops and pity rule, the shared profile, and the Act 1 sentence. BA, SD, PP and NC support most of it. The exceptions: keep the Paper Crane itself and the level-25 and level-50 posters (BA, NC, PP).

### #4 — BLOCKING — Interaction rules between specials, obstacles and layers are undefined, and the worst case lands on the level-50 climax
- **Problem.** There is no damage-and-targeting table. Open questions include:
  - **Overlapping shapes.** No priority when one match qualifies for two specials (for example, a 5-in-line inside a T).
  - **Tapped Jade Orb.** It has no swap colour, so its effect is undefined.
  - **Crane vs. beam.** Nothing says whether the Crane's path, or a special it carries, crosses the Nian's Eye beam.
  - **Hits on the Eye.** Nothing says whether a special the beam destroys counts as one of the Eye's 3 hits.
  - **Crane targets.** "Goal tile" is undefined for dew, drop items or shrines.

  The Nian's Eye (debut 46, which per the doc's rules then appears through 47–50) is the most-complained-about hazard type, and it lands on the Rat finale.
- **Flagged by:** FL #3, QA #4, PP #4. In Round 2: SD X1/X6, NC N3.
- **Cross-examination: STRENGTHENED.**
  - **Upgrade.** FL upgraded this to BLOCKING: MatchResolver can't pass its own tests without a shape-priority rule, so the gap blocks the week-9 grey-box.
  - **Level 50.** QA would rate it BLOCKING if OB09 stays in the 47–50 window.
  - **Fix converging.** Five reviewers support moving OB09 out of the MVP or past level 50. NC adds that debuting it after the Rat is restored gives the villain a story escalation and the level-60 cliffhanger something to build toward.

### #5 — BLOCKING — The MVP can't answer its one stated question: "prove retention"
- **Problem.** There is no target audience, no D1/D7 bar, and no decision rule for what happens if the build misses.
  - **Android is likely late.** Week-20 public Android ignores Google Play's 14-day closed-test requirement for new accounts, so the live data will probably come only from itch.io web, which BA flags as the wrong audience.
  - **D1 is confounded.** The lives wall at 25 means day-1 return partly measures tuning error.
  - **D1 can mislead.** A 100-minute lives timer *causes* returns, so frustrated players count as day-1 returns.
- **Flagged by:** BA #3, FL #5. In Round 2: PP B1, SD X3, NC N7.
- **Cross-examination: STRENGTHENED.** Both BA #3 and FL #5 were upgraded from MAJOR to BLOCKING in Round 2, once the lives wall, the Play gate and the audience gap were combined (BA Connection 1, FL's BA connection). PP adds a fix: track a quit funnel after lives run out on levels 15, 20, 25 and 50, not raw D1 alone.

**Just below the cut-off (MAJOR, strong consensus):** the "Souls carry forward" cross-game layer has no technical design, budget or MVP payoff.
- **Unbuildable as written:** there is no backend for the shared profile (FL #2).
- **The numbers don't add up:** the random-drop arithmetic double-counts (SD #4, QA #2).
- **Exploitable:** fragments can be rerolled or farmed through replays (QA #2).
- **Felt as filler:** players get Soul Dust and off-trail fragments that do nothing in the MVP (PP #3).
- **Premature:** the pillar depends on games that are out of scope (BA #2).

---

## 2. Unresolved disagreements (escalated to the designer)

**A. How severe the lives wall is, and the right fix.**
- **SD (BLOCKING):** the bot is optimistic, so lock-outs at the story finales are worse than the targets imply. They undermine both the payoff and the retention test. Fix: start the unlimited-lives window when the player enters the finale, or make story finales easier than mechanical ones. BA supports the finale-entry window.
- **PP (MAJOR):** players who haven't used a continue can afford several, so the wall mainly hits players who already spent continues. Fix: don't take a life on a finale fail.
- **QA:** a window that starts on finale entry can be exploited: enter, quit, then spend 30 minutes of unlimited lives elsewhere. QA backs the no-life-loss option.
- **Decision escalated:** which lives fix to adopt, and whether the finale tier stays at 25–35% for the story finales.

**B. How to make guardian powers and boosters last.**
- **SD:** give powers a renewable charge meter. NC adds a story argument: a guardian's blessing that disappears after 3 taps contradicts the restoration theme.
- **FL and BA:** a charge meter is a new system the schedule can't absorb. Use a fixed number of uses per level or a coin price on the existing booster bar instead.
- **Decision escalated:** whether to add a new system or reuse existing data.

**C. The "Souls carry forward" pillar.**
- **BA:** demote it to a post-MVP note.
- **NC:** inside the MVP, fragments *are* the plot. Rewrite the pillar as an in-game promise and drop only the cross-game plumbing.
- **PP:** cutting the system leaves levels 51–60 with nothing to earn. Add a near-term payoff, such as 8–10 fragments for the Ox or a mid-trail Ox reward at 60.
- **Decision escalated:** the pillar's wording, and what players earn in levels 51–60.

**D. The background count.**
- **SD:** keep 6 backgrounds (one per 10 levels). It is the only progression signal in levels 1–25.
- **BA:** the asset budget is about 2× too high and doubles Krita cleanup.
- **FL:** must be decided before the Scenario model is trained.
- **Decision escalated:** pacing value vs. asset hours.

**E. How to fix the obstacle-debut rule** (debuts at 17/22/28/34 instead of on the levels after hard levels).
- **SD:** renumber the early debuts to 16/21/26/31.
- **QA:** renumbering can't work. Level 26 is a scripted fragment level and intro levels may never carry fragments. Level 16 is already the booster unlock. Only an explicit exemption works ("the rule applies from level 41").
- **Severity is disputed too.** For the level-10 "freed creature" beat that comes before the rescue mechanic exists, NC holds MAJOR and SD and QA hold MINOR. All three agree on moving OB07 earlier.

---

## 3. Quick wins

1. **Delete the "story-complete Act 1" sentence** and confirm levels 1–60 as the MVP (BA #1, FL, NC N6, SD X5).
2. **Ship levels 51–60 with Ox-only fragment drops and hide Soul Dust**, using a versioned local save. This removes the reroll exploit, the pity edge cases, the random-pool arithmetic and the empty shared-profile spec from the MVP in one change (SD C2, FL, QA, PP #3, BA #2).
3. **Fix the cheap document contradictions in one pass:**
   - **Move the rescue earlier:** swap OB07 to level 7 with moss, so freeing creatures exists before the level-10 "freed creature" beat (SD, PP B6, NC C4).
   - **Settle the Monkey:** he arrives at level 30, the Monkey's Staff gift moves to 30, and he is confirmed as a separate temple guardian. This also takes one pop-up out of level 25 (NC C3/N2, PP B5).
   - **Swap the level-20 poster for a story card** (BA #5, NC C1, PP A3).

---

## 4. Verdict

The document is not ready to drive production. It is detailed and well researched, but its central promise (the Rat restored at exactly level 50, as the payoff of a 25-level fragment trail) rests on an undefined fragment rule. That promise sits behind a difficulty wall tuned by an uncalibrated bot, on a level where the special-interaction rules are also undefined. All of it runs on a 20-week solo schedule the Feasibility Lead says is already overcommitted, without the unbounded "Act 1" growth. The board also found that the MVP, even if built as written, could not answer its own question about retention: it has no audience, no D1/D7 bar, and a likely web-only launch. The single change that matters most is to **write one authoritative rule sheet before the week-9 grey-box**. It should fix the fragment's goal semantics, define what specials do to fragments and obstacles (shape priority, Orb tap, Crane vs. beam), and settle the bot's play policy against human testers. Three of the five top issues depend on it, and the rest of the reviews' fixes assume it exists.
