# Systems Designer — Round 1

Lane: core loop, progression, pacing, difficulty curve, economy math.
Overall: the level-tier and fragment systems are carefully specified on their own, but several of them are calibrated in isolation and do not account for each other. The biggest gap is that free per-level powers are handed out on top of a difficulty curve tuned as if they did not exist.

---

## 1. Free per-level powers are not in the difficulty calibration — BLOCKING

**Problem.** From level 30 every player gets a free Monkey's Staff charge on every level, and from level 50 a free Rat's Nibble charge as well. These are strong board-clearing tools. The level bot and every win target leave them out, so the tier bands for levels 30–60 will not match what players actually experience. Hard levels tuned to 35–45% will play much easier for anyone who uses a charge that costs them nothing.

**Source.**
- Meta & economy, booster table: Monkey's Staff (30) "Removes one layer from every cell of one multi-cell obstacle — 1 free charge every level". Rat's Nibble (50) "Rat gnaws through a whole row of obstacles — 1 free charge every level".
- Technical design, tools/level_bot: plays "no boosters and no continues".
- Level progression: "Every win target is a human first-try rate without boosters or continues."
- Fairness rules: the rate must "sit inside its tier's band and never below it". This only guards the floor, so nothing catches levels that are too easy.
- Bot calibration: the second calibration (week 14) uses levels 15–30, which is before either free charge exists.
- Other unmodelled power: the win-streak chest ("a free Rocket and Crane onto the next board" after 6 wins) and the 16 pre-level boosters.

**Impact.** Staff is close to an auto-clear on obstacles that "fill whole areas" (Creep moss, OB03) and on multi-cell pillars (OB06). That covers most of the goal load the curve relies on, since "difficulty rises through goal counts". Chapter 2's hard levels and the level-50 finale, the arc's climax, will likely feel flat. A slip also makes this worse: the cut list drops the Staff first, which would quietly change the difficulty of 30–60 back again.

**Fix direction.** Decide whether free charges are part of baseline play. If they are, the bot must use them (with a usage policy) when it tunes levels 30+. Also add a ceiling check to the fairness rule, not just a floor.

---

## 2. 60 levels with no replay and no live ops will run out before D7 — MAJOR

**Problem.** The D7 ≥ 12% bar is measured on a game that an engaged player can finish in about 2–4 days. After that there is nothing left to come back for.

**Source.**
- Overview: "Levels 1–60 are the whole MVP scope."
- Soul fragments: "Won levels cannot be replayed in the MVP."
- Fairness rules: live ops only "after launch". The MVP has no daily or event loop, and level 60 ends on a cliffhanger whose follow-up (61) does not exist.
- Lives: 5 max, refill 1 per 20 min.

**Rough math from the doc's own targets.** Expected fails per level are about 1/p − 1:
- Intro: ~0.05
- Easy: ~0.15
- Medium: ~0.5
- Hard: ~1.2–1.9

A 5-level block therefore costs about 2.5–3 lives, or roughly 30 lives for the whole MVP (finales are free). Five lives plus about 3 per hour of refill gives a player with two sessions a day well over 10 attempts per day. So the lives gate slows players by a day or two, not a week. Players who reach day 7 will mostly be players who already finished.

**Impact.** The test cannot tell "finished and liked it" apart from "churned". Its decision branch ("D1 met, D7 missed: fix the pacing of levels 20–60") would send the fix to the wrong place.

**Also.** The lives-wall metric lists level 25, but "on chapter finales … a fail costs no life", so that data point measures nothing.

**Fix direction.** Do at least one of these:
- Model the expected playthrough length and the day-by-day level distribution.
- Add one evergreen return loop to the MVP (for example the daily puzzle already named).
- Read D7 only for players who have not finished the content.

---

## 3. The finale tuning rule contradicts the tier bands — MAJOR

**Problem.** The finale rule cannot be met without breaking the floor of the hard-level band.

**Source.** Level progression:
- Hard levels are tuned to 35–45%.
- Finales are tuned to 25–35%.
- "The story finales at 25 and 50 are tuned to the top of the finale band (35%) and are never the hardest board in their chapter."
- Fairness rules: a level's first-try rate must "never [sit] below" its tier band.

**Why it conflicts.** A finale at 35% can be "not the hardest" only if some hard level in the chapter is below 35%. That is forbidden. The best possible result is a tie, which the bot's 500-run noise will turn into a coin flip.

**Related.** The bot's tuning lever "adjust goal counts (±20%)" is ambiguous. On a 3–4-goal level, ±20% of the goal count is less than one goal. If it means goal quantities, the doc should say so, because tier goal counts are fixed elsewhere.

**Fix direction.** Either put story finales at 30–35% and allow hard levels to share that number, or rephrase the rule as "no harder than the hardest hard level". Also clarify what the ±20% applies to.

---

## 4. The coin economy has no real loop, and its numbers don't hold — MAJOR

**Problem.** Coins are earned and spent, but nothing in the game depends on them, and the income estimate does not fit the levels' own tuning.

**Source.** Meta & economy:
- "Win = 20 + 5 per finale rocket (about 40 a win)."
- Continue costs 300 coins.
- Boosters cost 100–200 coins.
- "Win targets assume no boosters, so a player who never buys one must still be able to hit every target."
- "Hero booster prices and coin income: confirm once the economy sheet is built." This is ticked [x] as answered, but no sheet exists in the doc.

**Why the numbers don't hold.**
- **Income.** "About 40 a win" assumes about 4 leftover moves per win. Hard and finale levels are tuned to 25–45% win rates, and wins at those rates usually end with 0–2 moves left. Real income where players need coins most is closer to 20–30 per win.
- **Total supply.** The whole MVP supply is about 500 + 60 × ~35 ≈ 2,600 coins.
- **Continue price.** One continue is about 8–15 wins of income, so most players will rarely be able to use it, even though it is the advertised "fair" fail-flow option.
- **Coins aren't needed.** Free charges (Staff, Nibble, streak chest) and the no-booster win targets mean nothing ever requires coins.

**Impact.** The doc promises "coins with real things to spend on", but in practice coins are a number that goes up. That is acceptable for an MVP with no monetisation, but then the D1/D7 test is not testing an economy at all. The "plan monetisation" branch would start from untested prices.

**Fix direction.**
- Build the per-5-level-block income/spend sheet now and untick the open question until it exists.
- Base income estimates on expected leftover moves per tier.
- Price the continue as a share of expected income on a hard level.

---

## 5. Soul-fragment progress for levels 51–60 is not specified — MINOR

**Problem.** The fragment system is fully scripted for 26–50 but not for the last ten MVP levels. The Ox's progress at the cliffhanger is undefined.

**Source.** Soul fragments:
- "In the MVP, every fragment from 51–60 is an Ox fragment."
- "From level 26, hard and finale levels always carry a fragment."
- "About 1 in 5 other levels" applies only "after the MVP".
- The schedule row "51–110: ~20" gives no MVP count.

**What can be pinned down.** Only levels 55 and 60 are guaranteed, so the Ox may sit at 2/12 when the MVP ends. That does little for the pillar "every fragment visibly brings a guardian closer". Separately, the doc's own arithmetic check already concedes that the Ox lands "nearer level 100 than 110", so the post-60 schedule is not internally consistent yet.

**Fix direction.** Script the 51–60 fragment levels the way 26–50 are scripted, for example 4/12 by level 60, and correct the 51–110 row before levels 61+ are planned.

---

## Round 2 — Cross-examination

### CONFLICTS

**Player Psychologist #1 (lives lock-out, BLOCKING) vs. my #2 and Business Analyst #1 ("lives are rarely a wall").**
The arithmetic is not actually in dispute. My per-tier fail rates give the same ~8–10 lost lives across levels 1–25 that the Psychologist computes (7 intros ≈ 0.35, ~6 easy ≈ 0.9, ~9 medium ≈ 4.5, hard 15 and 20 ≈ 3; finale 25 free). Against 5 lives plus ~3/hour, a single 45–60-minute first session can plausibly bottom out around 15–22. So the Psychologist is right about the *session* scale, and the Business Analyst's "rarely a wall" is too strong. Where I hold my ground is the *week* scale: ~30 lives for all 60 levels is 2–4 days of play for a twice-daily player, so lives do not stop content exhaustion. The real conflict is in the fixes. "Remove lives or make them much softer" removes the only throttle on how fast players get through the content. That turns a D1 problem into a worse D7 problem (my #2), and the decision tree would then read a content cliff as a pacing failure. Softening lives is only safe *together with* a return loop or a D7 cohort limited to players who have not finished. If coins are allowed to buy a refill, as the Psychologist suggests, that is the one change that would give my #4 coin economy a real sink. I prefer that option to removing lives.
One small correction to the Psychologist: the 500 starting coins pay for exactly one 300-coin continue, so the first wall comes about one attempt later than their estimate. The overall picture does not change.

**Adversarial QA #4 (finale band) fix vs. the fairness rule.** QA and I found the same contradiction (my #3), but QA's fix, "lift the story finales above the floor of the hard band (for example 40%)", moves a finale-tier level outside the finale band of 25–35%. That breaks the same "inside its tier's band" rule from the other side. Any real fix has to change a band or the rule, not only the target. Either let the finale band reach 40% for story finales, or define "hardest" by expected attempts or goal load, which is QA's second option and the better one. QA's extra point makes the case stronger: level 50 has 4 goals including the final Rat fragment, so on goal load (the doc's own difficulty lever) it is *structurally* the hardest board in chapter 2. The rule therefore fails on the doc's own definition of difficulty as well as on win-rate numbers.

**Adversarial QA #5 (free powers, MINOR) vs. my #1 (BLOCKING).** I keep BLOCKING, with a narrower scope. QA treats this as target drift. I treat it as the curve for half the MVP (30–60, including the level-50 climax that the whole Rat arc builds to) being tuned to a game nobody will play. It blocks the week-14–18 build of levels 31–60, because every one of those levels goes through the bot. Retuning 30 levels after they are built costs more than deciding the bot policy first. I accept QA's correction on timing: the Nibble is granted at the end of level 50, so it applies from 51, and the Staff is likewise effectively from 31 (the doc's "joins as guide at 30" leaves it unclear whether level 30 itself gets it). That makes the bot policy *more* urgent, not less, because QA rightly notes that no human calibration round can include the Staff (week 14 covers 15–30).

**Feasibility Lead #1 (cut list should include engineering cuts) — partial conflict.** I support part of the proposal. Cutting Jade Orb + special and Firecracker + Firecracker costs nothing in balance, because the bot uses "only taught specials and combos" and only Rocket+Rocket and Rocket+Firecracker are taught, so those cuts leave every win target unchanged. I object to "simplify the Crane's targeting to nearest goal". The Crane's target rule ("fewest hits left; an unfreed soul fragment always comes first") is a difficulty lever on every level that has goals. Changing it after calibration would shift every tier band at once. Do it before week 9 or not at all.

**Business Analyst #5 (cut the coin economy) vs. my #4 fix.** I asked for the economy sheet to be built. The Analyst says to cut the economy. My own numbers support the Analyst: coins are never required and the supply is about 2,600 for the whole MVP. So I am changing my fix direction (see Revisions). One caution: coins also pay for the 300-coin continue, which is the stated "fair" fail flow, and the leftover-moves rocket finale pays out coins. Cutting coins means redesigning the fail flow and the win finale, so it is not free.

**Player Psychologist #4 (12 new things in 13 levels) — partial pushback.** The research cadence "new obstacle every 3–5 levels" applies to *obstacles*, and the obstacle debuts (1, 4, 7, 10, 13) follow it exactly. The doc also requires that "the 3–5 levels after an intro each include it", so practice is built in. Counting specials, combos and a booster alongside obstacles inflates the count. I would rate this MINOR-to-MAJOR, not a clear MAJOR. The part I fully agree with is that rescue goals only start at level 7. That is a gap in the goal mix, and nothing in the goal rules requires a creature until OB07 debuts.

### CONNECTIONS

1. **QA #2 (Hoof Tap can delete a fragment) + my #4 economy = a paid dead state.** If a Tap removes a drop-item fragment, the level cannot be won, but the fail flow still offers the 300-coin "+5 moves" continue. A player could pay about 8–15 wins of income for moves that cannot win the level, then lose a life as well. The interaction gap is also an economy trap. The fix needs one more rule: the continue offer is suppressed when the remaining goals are unreachable.

2. **Feasibility #3 (calibration not measurable) + my #3 (finale tie) + my #1.** With 500 bot runs at p≈0.35, the standard error is about 2.1 points, so a 95% interval is about ±4 points. The difference between a finale at 35% and a hard level at 35–39% is inside the bot's noise *before* the human offset is applied, and that offset comes from 5 testers on levels 1–10. The finale ordering rule and the "never below band" floor are both unmeasurable at the precision they claim. This supports Feasibility's request to relabel the bands as bot-derived targets, and it means the fairness rule should be written as a tolerance (for example "band ±5").

3. **Business Analyst #1 + Feasibility #4 + my #2 = the success test fails on three independent axes.** The cohort is small and contaminated (Analyst), the D7 reading arrives at week 22 or later (Feasibility), and engaged players will have finished the content (mine). Combined with my #1, the free powers make 30–60 *easier* than designed, so my ~30-life playthrough estimate is an upper bound. Players finish faster than my Round 1 math said. With n≈50 at D7=12%, the standard error is about 4.6 points, so "missed 12%" and "hit 12%" cannot be told apart.

4. **Player Psychologist #3 + my #2 = progression is empty at the front and runs out at the back.** Levels 1–25 have no long-term goal, and 50–60 hand the player an Ox arc that cannot progress. The meta pressure sits entirely in 26–50. D1 is measured where there is no hook, and D7 where there is no content. The undesigned forest-restoration meta ("Owner: you") is the one system that could span both, which makes it a load-bearing missing piece, not a deferral.

5. **Player Psychologist #2 + Narrative #5 + my #5 = the Ox arc has three separate gaps.** Possibly 2/12 progress (mine), no meter to show it (Psychologist), and a bark that names the wrong guardian (Narrative). Each is MINOR alone. Together, the last ten MVP levels contradict the "every fragment visibly brings a guardian closer" pillar, and those are the levels a D7 player will have just played. The cut list's own last resort ("ship 1–50 and end on the Rat") removes all three at once, which is a point in its favour.

6. **QA #3 (level-34 intro vs. fragment) + the fragment schedule.** QA's fix (34 teaches drop items with hatchlings, first drop-item fragment at 35+) fits the schedule: 35 is a hard level that already carries a scripted Rat fragment, and it satisfies "the 3–5 levels after an intro each include it". No schedule change is needed.

7. **Narrative #4 / Feasibility #5 (level 40 "Boss level") + my lens.** Level 40 is a hard tier and a scripted fragment level. If "Boss level" means any special mechanic, it is outside the tier table and the bot's policy, so it cannot be tuned to 35–45% with the current tools. It needs to become a story card or get a tier and bot rules of its own.

### REVISIONS

- **#1 Free powers: keep BLOCKING, narrower scope.** It blocks the build of levels 31–60, not week 9. Nibble timing corrected to 51+ (per QA). I add to the fix that the win-streak chest and pre-level boosters should be cut (per Business Analyst #5), because that removes two unmodelled power sources at no balance cost.
- **#2 Content exhaustion before D7: upgrade MAJOR → BLOCKING**, merged with Business Analyst #1. Three lenses reached it independently, the free powers make it worse than my Round 1 estimate, and it sends the project's only go/no-go decision the wrong way. I also add a caveat from the Psychologist: lives do bite within a session, so the D1 picture is a separate problem and not proof that pacing is fine.
- **#3 Finale contradiction: keep MAJOR; fix revised.** Do not move the target outside the band (QA's 40% option). Define "hardest" by goal load or expected attempts, and write the fairness rule with an explicit tolerance that matches the bot's noise.
- **#4 Coin economy: keep MAJOR; fix direction changed.** Instead of building a full per-block sheet, I now recommend the Business Analyst's cut. Remove priced boosters, pre-level boosters and the streak chest from the MVP. Keep coins only for the continue, priced against hard-level income, or as a lives refill if lives stay. Leave pricing to the "plan monetisation" branch. My Round 1 point that the open question is falsely ticked stands.
- **#5 Ox 51–60 progress: keep MINOR on its own**, but the combined Ox-arc cluster (Connection 5) belongs at MAJOR under the Psychologist's #2.
