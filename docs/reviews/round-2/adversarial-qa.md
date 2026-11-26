# Adversarial QA — Round 1

## 1. Crane + special combo is out of scope but players can trigger it, and the MVP hands them the pieces (BLOCKING)

**Problem:** The doc defers the Paper Crane + special combo, but nothing stops a player from doing it. Specials "fire when matched, swapped or tapped", so any Crane next to a Rocket, Firecracker or Orb can be swapped with it. The MVP also sets this up on purpose:
- The level-16 pre-level booster is "Start with a Rocket + Crane".
- The 6-win streak chest "drops a free Rocket and Crane onto the next board".

MatchResolver, the GUT tests and the level bot all have no rule for that swap. There are three ways it could resolve: the swap is refused, the specials fire one after the other, or the result is undefined. The doc picks none of them.

**Source:** Core gameplay: "Crane + special is held back until after the MVP." Interaction rules: "Every special, obstacle and layer follows this one table… it must be finished before the week-9 grey-box." The table has no Crane + special row. Testing: "GUT unit tests for MatchResolver (every special and combo…)". Meta & economy: the level-16 booster row and the win-streak row.

**Fix needed:** Add a row to Interaction rules. For example: "Crane swapped with a special: both fire separately, Crane first." Or block the swap explicitly. Also state whether "Jade Orb + special" turns pieces into Cranes.

## 2. Boosters and guardian powers are missing from Interaction rules, so a required soul fragment could be destroyed (MAJOR)

**Problem:** Fragment protection only covers "any special, combo or board clear". Boosters are none of those. The Hoof Tap removes "a piece, or the top layer of one cell", and a drop-item fragment is the content (top) layer of its cell. Nothing says the Tap cannot delete it. A fragment is always a required goal, and won levels cannot be replayed, so deleting it makes the level unwinnable. The player then has to fail, losing a life, and retry.

Other boosters and powers have the same gap:
- **Rat's Nibble** "gnaws through a whole row of obstacles". The doc doesn't say whether that is one hit per cell, all layers, or whether it damages the Terracotta minion, which is "only specials can damage it".
- **Bamboo Dash** clears a "diagonal". No special does that, so the one-hit-per-multi-cell-obstacle rule has never been applied to diagonals.
- **Tail Slam** on a drop item or cocoon: does it collect the item, destroy it, or skip it?
- **Feather Fan** reshuffle: does it move drop items, such as moving a fragment away from the bottom row?

**Source:** Interaction rules: "Soul fragments and drop items: Never destroyed by any special, combo or board clear". Booster table: the effects of Hoof Tap, Nibble, Bamboo Dash and Tail Slam. Soul fragments: "Won levels cannot be replayed in the MVP."

**Fix needed:** Add a "Boosters and powers" block to Interaction rules. It should cover hits per cell, which layers are hit, specials-only obstacles, and say that fragments and drop items are always immune or collected, never deleted.

## 3. The level-34 intro must use a soul fragment as its only goal, but intro levels are forbidden from carrying fragments (MAJOR)

**Problem:** OB11 debuts at level 34, and the obstacle table names it "Soul fragment (and lost hatchlings)". Intro rules say the new obstacle is the level's only goal. Fragment rules say intro levels never carry a fragment and the validation checklist rejects one. Level 34 is also missing from the Rat schedule (26, 30, 33, 35, 38…). So the level agent gets a brief where the obvious build fails validation, and the only workaround, hatchlings, is mentioned in parentheses and never specified. The Soul fragments section adds to the confusion by tying fragment drop items to "level 34 (when drop items debut)", even though the first scheduled drop-item fragment would be at 35.

**Source:** Obstacle set: "34 · OB11 · drop item · Soul fragment (and lost hatchlings)". Research rules: "Intro level: the new obstacle is the only goal". Soul fragments: "Intro levels never do… the validation checklist rejects a fragment placed on one."

**Fix needed:** Say that level 34 teaches OB11 with lost hatchlings, and that the first drop-item fragment appears at 35 or later.

## 4. The win-rate targets for the 25 and 50 finales can't all be met (MAJOR)

**Problem:** The doc tunes the 25 and 50 finales to 35% first-try wins. The hard band is 35–45%, and no level may sit below its band, so no hard level can go under 35%. The best case is a tie at 35%, so "never the hardest board in their chapter" can't be guaranteed. The bot will either flag a violation or quietly accept a tie, and designers can't satisfy all three rules at once. Level 50 also has 4 goals including the final Rat fragment, so it will tend to be harder than the 3–4-goal hard levels.

**Source:** Level progression: "The story finales at 25 and 50 are tuned to the top of the finale band (35%) and are never the hardest board in their chapter." Tiers: Hard 35–45%, Finale 25–35%. Fairness: "never below it".

**Fix needed:** Either lift the story finales above the floor of the hard band (for example 40%), or define "hardest" by a measure other than win rate.

## 5. Free per-level powers and the streak chest aren't in the bot's calibration, so the win-rate targets drift (MINOR)

**Problem:** From level 30, every level gives a free Monkey's Staff charge, and from 51 a free Rat's Nibble. The 6-win chest drops free specials. The bot plays with "no boosters and no continues", and the targets are "without boosters". The doc never says whether these free charges count as boosters. If the bot ignores them, real players will beat the targets on every level from 30, which defeats the difficulty curve and the D1/D7 test. If the bot uses them, tester calibration from levels 1–10 and 15–30 misses them, since the Staff is only granted at the end of 30. Chapter finales also cost no life, so they can be retried for free.

**Source:** Booster table: "1 free charge every level" for the Staff and the Nibble. Meta: win streak. Technical design: bot policy, "no boosters". Level progression: "Every win target is a human first-try rate without boosters or continues."

**Fix needed:** Classify the story gifts, guardian powers and the streak chest for bot runs, and recalibrate levels 30+ to match.

## Round 2 — Cross-examination

### vs. Systems Designer

**CONFLICT: severity of the free-power calibration gap (their #1 BLOCKING vs. my #5 MINOR).** We both found the same gap. I now think my MINOR was too low (see Revisions), but I don't accept BLOCKING. Their impact estimate depends on a rule the doc never defines. They call the Staff "close to an auto-clear" on Creep moss (OB03) and pillars. But the Staff hits "one multi-cell obstacle", and the doc never says which OBs count as multi-cell (Feasibility #2 also flags this). Creep moss is a "cover cluster" that "fills whole areas". The doc doesn't say whether a cluster is one obstacle or many one-cell overlays. If it is many, the Staff does almost nothing to moss, and most of the "flat chapter 2" impact goes away. The fix is a single policy line plus a bot rerun, so nothing has to be rebuilt. That makes it MAJOR, not a gate on production.

**CONFLICT: their fix for the finale contradiction (their #3, my #4).** We agree on the problem, but their first fix doesn't solve it. "Put story finales at 30–35% and allow hard levels to share that number" still leaves "never the hardest board" decided by measurement noise. A 500-run bot rate at 35% has a standard error of about ±2.1 points. On top of that comes the bot-to-human offset, which is set from 5 testers (Feasibility #3) and is far noisier. A finale and a hard level both "at 35%" can't be told apart, so the rule can't be checked either way. Only a rule that doesn't depend on win rate (for example, "finale goal load ≤ the chapter's heaviest hard level") can be validated.

**CONNECTION: the fairness rule only has a floor, and free powers push rates up.** Their point that fairness "only guards the floor" combines with my #5 in a way neither of us said outright. Every unmodelled free resource (Staff, Nibble, streak chest, and the pre-level booster freebies) raises human win rates. The only automated check in the doc looks for rates that are too low. So the whole drift goes in the one direction the validation pipeline can't see. No test in the doc will ever fail on it.

**CONNECTION: levels 51–60 are unscripted (their #5) and collide with intro rules.** In 51–60, the hard levels 55 and 60 must carry fragments, and 56 is the Terracotta intro, which can't carry one. Nibble is new at 51, and OB11 drop items are now standard. Rat's Nibble "gnaws through a whole row of obstacles", and OB11 (soul fragment) is listed in the obstacle table. So under the doc's own wording, the Nibble arguably targets fragments. This is the first stretch where a free per-level power and drop-item fragments are both common, and it has no script. It is the most likely place for my #2 fragment-deletion bug to appear in real play.

### vs. Player Psychologist

**CONFLICT between colleagues that my lens can settle: lives wall (Psych #1 BLOCKING) vs. "lives are rarely a wall" (Systems #2, Business #1).** Both are right at different time scales, and the doc makes them pull against each other. Psych's math is about one session (8–10 lives lost by level 25, against 5 lives plus 3/hour). Systems' math is about the whole week (about 30 lives across the MVP). The problem is the fix. Softening lives, as Psych proposes, speeds up content exhaustion, which makes the D7 confound in Systems #2 and Business #1 worse. Keeping lives makes the D1 confound worse. The retention test can't be cleaned up by tuning lives alone. It needs the "reached level 60 by D7" metric that Business proposes **and** a lives-wall metric that actually measures something. Systems has already noted that the level-25 data point measures nothing, because "a fail costs no life" on finales.

**CONNECTION (new): quitting to dodge a life loss is unspecified.** "Lose one on fail" never says whether leaving a level mid-attempt counts as a fail. The doc does close this loophole for fragments: "the roll happens when the level is won, so quitting and re-entering cannot change it". It doesn't do the same for lives. If Psych is right that players hit zero around levels 15–22, the obvious player response is to force-close a doomed attempt to keep the life. That has two effects. It hides the lives wall the retention metric is trying to find. It also corrupts "first-try win rate" telemetry, which is what Feasibility #3 asks to collect: does an abandoned attempt count as a first try? **MAJOR** (new).

**CONNECTION: the Crane tutorial (level 5) uses a goal type the Crane can't target.** Psych #4 points out that special tutorials (levels 2, 3, 5, 6) use "collect N red" goals. The Crane's targeting rule only covers "the remaining goal with the fewest hits left", plus dew, shrines and fragments. "Hits left" means nothing for a colour-collect counter. The signature special's own tutorial level has undefined behaviour. The rule that "the 3–5 levels after an intro each include it, paired with one or two familiar obstacles" also breaks at level 2. Bramble is the only obstacle that exists by then, so there is nothing familiar to pair it with.

### vs. Technical Feasibility Lead

**CONFLICT on severity (their #2 MAJOR vs. my #1 BLOCKING).** They list Crane + special as one gap among many. I hold BLOCKING because it is a gap the shipped build will hit, not an edge case:
- The level-16 pre-level booster and the streak chest put a Crane and a Rocket on the board together, on purpose.
- The idle hint "shows a combo swap whenever one exists". If the hint code treats any two adjacent specials as a combo, the game advertises a combo the doc says doesn't exist.
- The bot "uses only taught specials and combos", so it will never make this swap, but humans will. Bot-tuned rates and human rates diverge on exactly the levels where these boosters are active.
- The week-9 gate is "Interaction rules pass their GUT tests". You can't write a passing test for a row that doesn't exist.

**CONNECTION: Firecracker "twice" plus the multi-cell and two-hit rules.** Their catch is better than anything in my #2. The Firecracker is a "3×3 blast, twice". Big obstacles take "at most one hit per special", and the Frozen idol counts "each special" as one hit. So a single Firecracker next to an idol does 1 hit or 2, and the doc can be read either way. This multiplies through combos. Jade Orb + Firecracker turns every piece of a colour into Firecrackers that each blast twice. Firecracker + Firecracker is a "5×5 double blast". The idol/pillar damage from those combos could be off by a factor of two, depending on a reading the GDD never fixes. That means the bot's numbers for every idol level (41+) depend on an unwritten choice.

**CONNECTION: the cut list interacts with my #5.** Cutting the Monkey's Staff, the first item on the list, is a tuning event, not just a content cut. If my fix is adopted (the bot plays with free charges), cutting the Staff late makes every bot rate for 30–60 wrong, and they all need a rerun. If my fix isn't adopted, cutting the Staff quietly fixes half of #5. The cut list has to say which of these is the case. Cutting levels 51–60 (the fourth item) makes the Nibble dead content, since it's earned on winning 50. That would remove the Nibble half of my #2 and #5.

### vs. Business Analyst

**CONNECTION / partial CONFLICT: their #5 cuts (pre-level boosters, win streak, coin economy) would downgrade my #1, but not to zero.** Both deliberate sources of Crane + special (the level-16 pre-level booster and the streak chest) are on their recommended cut list. If those cuts happen, my #1 drops to MAJOR. It can't be withdrawn, because natural play still makes a 2×2 square next to a 4-in-a-line. Their cut list supports my severity: the features they call decorative are the ones that create the undefined interactions.

**CONNECTION: free powers make D7 harder to read.** Their #1 (D7 confounded with running out of content) and my #5 make each other worse. If the free Staff and Nibble make levels 30–60 easier than tuned, players get through the back half faster. Content runs out sooner, and a missed D7 is even more likely to be read as "fix the pacing of levels 20–60". In fact the pacing in that range would be too easy, not too hard, so the decision tree points the fix in the wrong direction.

**CONNECTION: ticked open questions hide the real blocker.** Their #3 shows that every open question is ticked without an answer. From my side, the bigger problem is what isn't on the list. The Interaction-rules gaps (Crane + special, boosters, Firecracker double-hit, multi-cell definition) are never listed as open questions. So the week-6 gate, "every item under Open questions is answered", can pass while the table that has to be "finished before the week-9 grey-box" is still incomplete.

### vs. Narrative Critic

**CONNECTION: the level-40 "Boss level" is also a fragment level with no rules.** Narrative #4 and Feasibility #5 both point out that "Boss level" is undefined. From my side, level 40 is at the same time a hard level, a scheduled Rat fragment level, and a scene where the Golem "tries to smash the Rat's statue". The MVP has no hazards ("None in the MVP"). If "boss" means any board mechanic, it needs Interaction rules, including whether the boss can affect the fragment. If it means only a story card, the doc should say so, as it does for level 20.

**CONFLICT (mild) with Narrative #5.** I agree the bark is wrong, but it's a symptom of a bigger problem. The bark table is a fixed text matrix with no guardian variable, and SaveService "already tracks… restored guardians". The real issue is that StoryPlayer has no data binding for trail-guardian state. Fixing that one line won't stop the same bug in the post-win screens or the map badges.

### REVISIONS

- **#1 Crane + special: keep BLOCKING.** Strengthened by the idle-hint and bot-divergence points. Drop it to MAJOR only if the pre-level booster and the win streak are cut, as Business #5 proposes.
- **#2 Boosters missing from Interaction rules: keep MAJOR, broaden it.** Add the Firecracker double-hit ambiguity (from Feasibility). Add that OB11 is listed in the obstacle table, so "a whole row of obstacles" (Nibble) literally includes fragments.
- **#3 Level-34 intro contradiction: keep MAJOR.** No colleague flagged it, so it stands alone. The same validation conflict now also applies to 56 (Terracotta intro) inside the unscripted 51–60 range from Systems #5.
- **#4 Finale tuning: keep MAJOR, withdraw one sub-claim.** I withdraw "level 50 has 4 goals so it will tend to be harder". The doc sets difficulty by goal load and tuning together, so goal count alone proves nothing. In its place I add the 500-run noise argument, which makes the rule impossible to check, not just tight.
- **#5 Free powers outside calibration: upgrade MINOR → MAJOR.** Systems #1 and Feasibility #3 show that the calibration base is already weak. The floor-only fairness check means the drift can never be caught automatically. I still disagree with BLOCKING, for the reasons above. One correction: the Nibble's unlock row is level 50 (it's granted when 50 is won), so it is usable from 51. That matches my Round 1 claim, but the table should state it.
- **New (MAJOR): the doc doesn't say what quitting mid-level does to lives or to first-try telemetry.** It closes the same loophole for fragment rolls but not here.
