# Player Psychologist — Round 1

Scope: what a real player goes through, from the first hour up to the end of the MVP (level 60). Each finding cites the GDD passage it comes from, or the gap it points to.

---

## 1. Lives can lock players out right before the two biggest story payoffs, and the continue is almost never affordable — BLOCKING

**Problem.** The GDD says it fixes MV's "lives lock-out" complaint, but the numbers bring it back at the worst moments. Finales target a 25–35% first-try win rate, and hard levels target 35–45%. A player has 5 lives that refill at 1 per 20 minutes. At a 30% win rate, about 17% of players (0.7^5) lose all 5 lives on the level 25 finale alone. Many arrive with fewer than 5, because hard levels 15 and 20 come just before it. Level 25 holds the temple reveal, the Monkey, and the start of soul fragments, so it is the main hook of the first session, and it sits behind a wait of up to 100 minutes. Level 50 (Rat restored) has the same problem. The "30 min of unlimited lives" comes *after* a finale is beaten, so it doesn't help the player who is stuck on one.

The continue doesn't help either. It costs 300 coins. Players start with 500, and a win pays 20 + 5 per leftover-move rocket, so about 40–60 coins. After the first continue, a player needs roughly 5–8 more wins to afford another. The "one optional continue" is really a one-time thing.

**Source.** Level tiers table (Hard 35–45%, Finale 25–35%). Currencies: "Lives 5 max… refill 1 per 20 min; 30 min of unlimited lives after each chapter finale", "Continue… 300 coins", "Coins Start 500. Win = 20 + 5 per finale rocket". Research table: "lives lock-out" is a top complaint to fix. Monetization: "prove retention first".

**Suggested direction.** Don't take a life on finales, or on the first fail of a hard level. Or grant the unlimited-lives window when the player *reaches* a finale, not after beating it. Bring the continue cost in line with coin income.

---

## 2. Something new on nearly every early level, and the 6 combos are never taught — MAJOR

**Problem.** Levels 1–7 each introduce a new concept: bramble (1), Rocket (2), Firecracker (3), dew (4), Crane (5), Jade Orb (6), moss (7). There is no level just for practice. More arrive soon after: lantern shrine at 10, Firecracker Pop booster at 11, pillar at 13, first hard level at 15, pre-level boosters at 16, mummified creature at 17. A new player is still taking in the swap feel while the rules keep growing, which leads to overload and "I don't know what I'm supposed to do" quits.

The combo table has six combos, including the signature Crane carry and the Orb + Orb board clear, but no level teaches any of them. The design leans on "Feel first" and big combo moments, yet most players will only find combos by accident, if at all. Hard levels are tuned by a bot that may use combos humans never learned, so they could feel harder for real players than the bot's win rates suggest.

Related: the doc says new obstacles debut "on the relief level right after a hard level", but the debut table puts them at 17, 22 and 28, two levels after the hard levels at 15, 20 and 25. Level 22 is also a booster unlock, so two new things land on the same level.

**Source.** "four special pieces (taught on levels 2, 3, 5 and 6)". Obstacle debuts at 1, 4, 7, 10, 13, 17, 22. Booster unlocks at 11, 16, 22. Combos table, with no tutorial level listed. "New obstacles debut on the relief level right after a hard level." The doc never describes how a tutorial actually works (forced first move, pointer, whether it can be skipped).

**Suggested direction.** Space the special tutorials around the obstacle debuts and leave at least one level with nothing new between them. Add 2–3 combo tutorial moments, at least Rocket + Rocket and Crane + special. Specify the tutorial UX.

---

## 3. The rewards that carry over don't pay off inside the MVP, and levels 1–25 have little to chase — MAJOR

**Problem.** The pitch says soul fragments are rewards that "carry into every future game". Inside the MVP, though:
- Levels 1–25 drop no fragments. The meta ("forest restoration") isn't designed yet ("Owner: you"). Coins have one listed use, the continue. In the first hour, the only rewards are coins, story beats at levels 1, 10 and 20, and a background that changes over time. For a build meant to measure day-1 return, that is a thin loop.
- After level 50, 30% of fragment drops go to random guardians the player can't restore for 50–150+ levels. Duplicate fragments become Soul Dust, "stored for Part 2 hero upgrades", in a game that doesn't exist yet. Players get loot that does nothing now, so the reward reads as filler.
- Boosters come with a fixed number of free uses. The doc never says how a player gets more, so once a player uses them up, the booster unlocks stop meaning anything.

**Source.** Soul fragments: "Fragments start at level 26", "70% trail / 30% random", "Soul Dust, used for hero upgrades in Part 2". Meta: "You design the wider meta… Owner: you". Booster table "Free uses" with no way to get more. Milestones: "Tracking day-1 return".

**Suggested direction.** Put a visible progression goal in levels 1–25, even a minimal forest-restoration bar. Give coins a booster sink. In the MVP, hide or delay random off-trail fragments and Soul Dust until they can do something.

---

## 4. The most-hated obstacle debuts just before the level 50 climax — MAJOR

**Problem.** The GDD admits hazards are "MV's most-complained-about obstacles". Nian's Eye has a beam that destroys specials crossing it, so it wipes out pieces the player worked to build, the very thing the "Feel first" pillar celebrates. It debuts at level 46. Per the rule that "the 3–5 levels after an intro each include it", it then shows up across 47–50. Level 50 is the finale with 4 goals and a 25–35% win target, and it gates the Rat's restoration, the MVP's emotional payoff. Players will meet the most frustrating mechanic while it is still new, on the hardest level, at the story's peak. Rage-quits are likely here. The obstacle-spacing rules don't address the timing (the brief only bans goals inside the beam, not specials crossing it).

**Source.** Obstacle table: "46 · OB09 · Nian's Eye… its visible beam destroys specials that cross it". Rules: "The 3–5 levels after an intro each include it"; "Hazards arrive later than in MV (46 and 86) because they are MV's most-complained-about obstacles." Finale at 50 (4 goals, 25–35%).

**Suggested direction.** Leave the hazard off the level 50 finale. Or move its debut past 50 (e.g. 51–56, into the Ox chapter), so the Rat climax is a clean, fair fight.

---

## 5. Milestone levels pile up pop-ups, going against the doc's own "one pop-up" rule — MINOR

**Problem.** The fairness rule allows "at most one pop-up between the lobby and Play", but the story and unlock schedule stack several on the same levels. At level 25, a player sees: the finale win, a chapter story card, the big-reveal poster, the soul fragment unlock, the Monkey's Staff booster gift, and the unlimited-lives grant. Level 50 is similar: poster, celebration, chapter card, Rat's Nibble unlock, unlimited lives. Level 1 opens with a 4–6 panel comic before the first swap. The rule only covers lobby-to-Play, so the post-win flow and the level 1 start aren't covered. These are the moments where 8–9 interruptions in a row (an MV complaint) would hurt most. Pacing a big reveal well helps; a queue of modals the player taps through to dismiss does not.

**Source.** Fairness rules: "At most one pop-up between the lobby and Play". Story beats table (1: intro comic; 25: poster + fragments unlock; 50: poster + celebration). "Each finale ends with a chapter story card." Booster unlocks at 25 and 50. Lives: "30 min of unlimited lives after each chapter finale". Research: "8–9 pop-ups before Play".

**Suggested direction.** Define a sequencing rule for after a win, e.g. at most 2 screens, with the rest delivered as passive map badges. Make the level 1 comic short and skippable, or put the first swap before it.

---

## Round 2 — Cross-examination

I read all five colleague reviews and re-checked `gdd.txt`. Below are the points where I disagree, connections that show up only when two lenses are combined, and changes to my own Round 1.

### A. CONFLICTS

**A1. Systems Designer #1 / Adversarial QA #1 (fragment as goal vs. auto-collect): only one of the two fixes works for players.** Systems Designer gives the designer a free choice: the fragment uses one of the tier's goal slots, or it is auto-collected on any win. From a player's point of view these options are not equal. On hard and finale levels the fragment is the reason the player is there: the map and level card show a glowing icon "so players know before they play". If it counts as a goal, it becomes the goal the player watches most closely on the boards most likely to fail (25–35% / 35–45%). Adversarial QA also points out that Jade Orb + Jade Orb ("Clears the whole board"), Rockets and Firecrackers may destroy a drop item. If they can, the game's biggest celebration moment could erase the reward the player came for. That breaks "Feel first" in the worst possible way: the player is punished for playing well. My position: **the fragment must never be lost on a win, and specials must never destroy it.** Either auto-collect it on any win, or make it a goal that specials push toward collection, never one they destroy. If it is a goal, it must take one of the existing slots, as Systems Designer says, and must not be a 5th goal. A 5th goal on the level 50 finale would make my lockout finding (#1) worse.

**A2. Business Analyst #2 (demote "Souls carry forward"; fragments 51–60 pay off only after the MVP): I agree with the diagnosis but not the conclusion.** BA treats fragments in 51–60 as franchise plumbing to push out of the critical path. For the player, though, 51–60 is the *last thing the retention test measures*. If those levels drop Ox fragments toward a restoration about 50 levels away, plus random fragments and Soul Dust that do nothing, the MVP ends in a reward desert. Narrative Critic #4 adds that the cliffhanger at 60 is undefined. Cutting the system doesn't fix this. A **near-term payoff inside 51–60** does: Systems Designer #4's suggestion of 8–10 fragments for the next guardian, or a mid-trail Ox story reward at 60. I keep my Round 1 position that random off-trail fragments and Soul Dust should be hidden in the MVP. That also removes the reroll exploit in Adversarial QA #2, because no visible random roll exists to reroll.

**A3. Feasibility Lead #1 (cut list: Crane-carry combo, OB09 hazard, posters, shared profile): I support most of it, with one exception.** Cutting OB09 from the MVP fixes my #4 entirely, and dropping the Crane-carry combo shrinks my #2 (one fewer untaught combo). I support both. **I oppose cutting the level-25 poster.** It is the first session's main hook, and the reveal is the moment the meta loop starts. Cut the level-20 poster instead. Business Analyst #5 already notes it conflicts with the story table, which lists level 20 as a "story card". Keep 25 and 50.

**A4. Business Analyst #4 grants "fairness fixes" as a real differentiator. My #1 says the numbers undo them.** BA lists "fewer pop-ups, one continue" as the stated differentiators, judged weak for acquisition but real. My #1 and #5 show the document doesn't actually deliver two of them. Lives lockout returns on the reveal levels, and pop-ups pile up after milestone wins. If fairness is the pitch, it has to hold on levels 25 and 50, where reviewers and early players will judge it.

### B. CONNECTIONS

**B1. The retention metric can't tell frustration from return (my #1 + Business Analyst #3).** BA notes that "Tracking day-1 return" has no success threshold. Combined with the lockout math (mine, and Systems Designer #3 independently: 1 in 8 to 1 in 4 players locked out at 25 and 50), there's a worse problem. A 100-minute lives timer *causes* returns. A player locked out at level 25 who comes back once, fails again and quits counts as a day-1 return. So the one metric the MVP exists to produce can look healthy because of the frustration it should be catching. The week-20 tracking needs a funnel metric: quits within N sessions after running out of lives on levels 15/20/25/50. Raw D1 alone isn't enough.

**B2. Grey-box calibration can't reach the combos (my #2 + Systems Designer #3 + Feasibility Lead #4a).** Both colleagues ask for the bot to be calibrated against the week-9 testers. But those testers play only levels 1–10, and no level teaches a combo. So human testers in 1–10 will show near-zero combo use, while the bot (if it searches for specials) uses combos on every hard level. The bot-to-human gap is therefore *largest exactly on the hard and finale levels* that calibration never samples. Either teach 2–3 combos before level 15 or turn off combo-seeking in the bot policy. Without one of these, the tier targets on 25 and 50 are uncalibrated, and my #1's lockout numbers are optimistic.

**B3. The Crane's "always helpful" promise breaks during the climax window (my #4 + Adversarial QA #4 + Feasibility Lead #3).** QA and Feasibility frame Crane-vs-beam as an undefined rule. In player terms, it's a trust problem. The Crane is the one piece that "always shows where it will land". If its dotted path can cross the Nian's Eye beam and the Crane dies on the way, the player's most trusted tool betrays them for the first time on levels 46–50, during the Rat climax. QA also notes that Nian's Eye must be "hit 3 times with specials" while its beam destroys specials. A new player won't understand an obstacle that can only be hurt by the thing it destroys, so they'll hit the "I don't know what I'm supposed to do" wall at the climax. That makes my case for moving OB09's debut past 50 stronger.

**B4. Hard levels with no story payoff (my #3 + Narrative Critic #3).** Narrative shows that hard levels 15, 35, 45 and 55 have no story beat, despite the "Story as reward" pillar. For players this goes beyond consistency: **level 15 is the first hard level**, so it's the first time most players fail and lose a life. It's also where I found levels 1–25 have little to chase. The first wall in the game has no reward behind it. Add a beat at 15. It's the cheapest motivation fix in the doc.

**B5. Moving the Monkey to 30 shortens the level-25 pop-up queue (my #5 + Narrative Critic #1).** Narrative points out the Monkey "joins as guide" at 30 in the beats table but at 25 in the Cast table, and the Staff is gifted at 25. Settle it at 30 and move the Monkey's Staff gift to 30. That takes one modal out of level 25's post-win queue at no cost and gives 26–30 a payoff of its own.

**B6. The rescue goal can move earlier without adding load (my #2 + Systems Designer #5 + Narrative Critic #2).** Systems suggests swapping OB07 into slot 7 or 10. That's a swap, not an addition, so it doesn't worsen the early overload I flagged, and it makes the "Every board is a rescue" framing true in the first session, when players form their impression of what the game is about. I endorse a **swap with moss at 7** over lantern at 10, so the level-10 beat ("First freed creature…") lands after the player has freed several creatures.

### C. REVISIONS

**C1. #1 downgraded from BLOCKING to MAJOR, and the continue claim withdrawn.** Systems Designer #2 works out about 2,900 coins by level 60, with the 300-coin continue as the only coin spend. I said the continue is "really a one-time thing", but that only holds for a player who spends continues as they go. A player who hasn't used one reaches level 25 with roughly 500 + 24 × ~40 ≈ 1,400 coins, enough for 4 continues, which noticeably lowers the chance of running out of lives. I withdraw "the continue is almost never affordable". The lockout risk is still real for players who spent continues on hard levels 15 and 20, and the *timing* problem (the unlimited-lives window arrives after the finale) stands. That's a major problem with a cheap fix (start the window on finale entry), not a ship-blocker. I'm also raising a new issue: coin-buying through finales is "pay to pass" in soft currency, so the doc should say whether bot targets assume continues (Systems Designer #3 asks the same).

**C2. #4 strengthened, still MAJOR.** Given B3, a hazard that contradicts its own hit rule and breaks the Crane's promise sits in the climax window. Moving OB09's debut out of the MVP (Feasibility Lead's cut) or past 50 is now my recommended fix, rather than only keeping it off level 50.

**C3. #3 strengthened.** Systems Designer #2 confirms that boosters, including Rat's Nibble, never refill and that coins have one use. Business Analyst #2 confirms the cross-game rewards are worth nothing during the MVP. Rat's Nibble, the MVP's emotional payoff, is 3 uses and then gone. The player's reward for the whole 25-level arc disappears after three taps. It stays MAJOR, but it now ranks just below #1 in priority.

**C4. #2: the debut-timing sub-point is now covered by others.** Systems Designer, Feasibility Lead and Adversarial QA all flag the 17/22/28/34 debut inconsistency as a pipeline contradiction. My distinct contribution is the untaught combos and the B2 calibration gap. Those keep #2 at MAJOR.

**C5. #5 unchanged (MINOR).** B5 and A3 give cheap fixes that don't change its severity.
