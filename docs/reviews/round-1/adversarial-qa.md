# Adversarial QA — Round 1

## 1. The scripted Rat restoration at level 50 can fail, because no rule makes collecting the fragment necessary to win — BLOCKING

**Problem:** The doc promises that the Rat "is restored at exactly level 50" through 8 scripted fragments (26, 30, 33, 35, 38, 40, 45, 50). But nothing says the fragment counts as a goal. "Win: all goals done before moves run out" ends the level as soon as the listed goals are met. A player can clear the other goals while the fragment is still wrapped in its cocoon (OB07) or still above the bottom row (OB11). The doc never says what happens to that fragment. It only covers failure: "Fail the level and the fragment stays for the retry." Nothing covers a win where the fragment was never collected.

Related cases nobody has planned for:
- Can board-wide effects destroy the fragment before it is collected? This covers Jade Orb + Jade Orb ("Clears the whole board"), Rocket row clears, and Firecracker blasts. A drop item is a piece in the content layer, and specials clear pieces.
- Can a fragment level be replayed after a win? If it can't, a missed fragment is lost for good. Then the level-50 restoration, the story beat at 50, Rat's Nibble at 50, and the week-18 milestone "Rat restored at 50 in a full playthrough" all break.
- Level 50 is a finale with "4 goals." If the fragment is one of them, it takes a goal slot, and the bot tuning has to account for that.

**Source:** Soul fragments › Rules ("Fail the level and the fragment stays for the retry"); Core gameplay › Rules ("Win: all goals done…"); Combos ("Jade Orb + Jade Orb — Clears the whole board"); Milestones, week 18. Omission: whether the fragment is a mandatory goal, and whether specials can destroy it.

## 2. The random fragment system can be exploited, and its own arithmetic doesn't add up — MAJOR

**Problem:**
- **Reroll exploit.** "Each drop has a 70% chance of being for the trail guardian and 30% for a random other guardian." The doc doesn't say *when* the roll happens: when the level is generated, when the player enters it, or when they win. The map and level card show the fragment icon "so players know before they play." If that icon reveals which guardian the fragment is for, and the roll happens on entry, a player can quit and re-enter until they get the guardian they want. Quitting also needs a rule: does it cost a life? Replaying won levels to farm fragments, and the leftover-move coins ("Win = 20 + 5 per finale rocket"), is never mentioned.
- **The numbers don't reconcile.** The arithmetic check spreads "~17 random drops" so that "each of the other 8 guardians" ends at about 2 of 12. But the random 30% goes to "a random other guardian," which also includes Rat (already restored), Rabbit and Dog. The schedule separately says Dog "already holds ~3 from random drops." 8 guardians × ~2, plus Dog's ~3, is about 19, which is more than 17. On top of that, some of the 17 drops go to Rat and become Soul Dust.
- **A non-trail guardian can be restored out of order.** Random drops plus 30% luck can complete a guardian that isn't on the trail, such as Rabbit before Ox. The doc says "the trail moves to the next guardian the moment one is restored." That is ambiguous: does the trail jump even when the guardian just restored wasn't the trail guardian? And what happens to that guardian's power, which is scheduled at "~110 / ~165 / ~200", and to its story beats?
- **The pity rule's edge cases.** Does a scripted drop, or a drop on a level the player failed, count toward the "4 in a row"?

**Source:** Soul fragments › Rules (trail guardian, pity, no waste); Schedule table; Arithmetic check; Meta & economy › Coins. Omission: roll timing, replay rules, whether Rat and the next trail guardians are in the random pool.

## 3. The level and fragment rules contradict the schedules they come with — MAJOR

**Problem:** The level agent receives both the rules and the plan, so its validation will fail or produce inconsistent results.
- **Debut timing.** The rules say "New obstacles debut on the relief level right after a hard level" (also in Level progression: "a relief level after each hard one where new obstacles debut"). Hard levels are 15, 20, 25, 30, 35, 40, 45, 50, 55, so the relief levels are 16, 21, 26, 31, 36, 41, 46, 51, 56. But the obstacle table debuts OB07 at **17**, OB08 at **22**, OB10 at **28** and OB11 at **34**. None of those follows a hard level. Only 41, 46 and 56 match the rule. Level 26 is a relief level with no debut at all.
- **Fragments on hard levels.** "Hard and finale levels always carry a fragment" contradicts "1–25: None". That covers hard levels 15 and 20 and finale 25. If 25 is exempt as the reveal, the rule needs to say so.
- **Fragments on intro levels.** "Intro levels never do [carry fragments]" holds for 26–50 only because the scripted list happens to avoid 28, 34, 41 and 46. After 50, about 1 in 5 levels gets a fragment, including OB15's debut at 56. Nothing stops the weighted placement from landing on an intro level. The level bot or the validation checklist needs an explicit exclusion.

**Source:** Board layers › Rules from the research brief; Obstacle set debut column; Level progression intro paragraph; Soul fragments › Rules and Schedule.

## 4. Specials and the Nian's Eye beam conflict, and some special inputs have no defined result — MAJOR

**Problem:**
- **Crane vs. beam.** The Paper Crane is "always helpful, and always shows where it will land." But the Nian's Eye's "visible beam destroys specials that cross it." The hazard rule only protects goal *positions* ("never put a goal behind a hazard's beam"). It doesn't protect flight *paths*. Can a Crane's dotted path cross the beam? If so, it dies on the way, which breaks the signature promise. The same question applies to "Crane carries that special to a goal tile", which carries a Rocket or Firecracker across the beam. Do Rocket row and column sweeps count as "crossing"? Does a Jade Orb + special conversion that turns pieces under the beam into specials destroy them as they appear?
- **Tapping a Jade Orb.** "Specials fire when matched, swapped or tapped (tap costs a move)." The Jade Orb "clears every piece of the colour it's swapped with." A tapped Orb has no swap partner, so its effect is undefined. Either tapping an Orb is disallowed, or it picks a colour (random, or most common).
- **Overlapping shapes.** A single cascade can match a shape that qualifies for more than one special: a 5-in-line that is also part of a T, or a 2×2 square inside an L. The doc doesn't say which special wins. MatchResolver needs a priority order, and the GUT tests "every special and combo" can't be written without one.
- **Hits on the Nian's Eye.** It needs "Hit 3 times with specials," but its beam destroys specials. Does a special destroyed by the beam count as a hit?

**Source:** Core gameplay › Special pieces, Combos, and the Crane note; Obstacle set OB09; Board layers rule on hazards. Omission: path rules, Orb tap behaviour, shape priority.

## 5. Story, content and asset counts contradict the level structure — MINOR

**Problem:**
- **The first freed creature comes before freeing exists.** The level-10 beat is "First freed creature tells of a dark beast", but the mummified creature (OB07) only debuts at **17**. Level 10 is also the OB05 debut, and that intro's "only goal" is the lantern shrine. The pillar "Every board is a rescue" and "Freeing them is the most common level goal" also can't hold for levels 1–16.
- **Chapter length conflicts.** Art direction gives "Backgrounds: One per 10-level chapter," and the asset list budgets "6 backgrounds × 2 states". Everywhere else, chapters are 25 levels with "A new backdrop every chapter." That would be 3 backgrounds for levels 1–60, not 6.
- **Hard-level story beats are missing.** The pillar and Level progression promise "a story beat on every hard level" and "each hard level carries a mini story beat." The beats table has nothing for hard levels 15, 35, 45 or 55, and only 2 Nian's-forces faces are budgeted (20 and 40). That leaves 10 hard levels in 15–60 with 2 villain faces between them.
- **The 3-colour exception contradicts its own sentence.** "4 colours on every level (3 only on a very cramped intro level)" can't both be true, and the research table says "4 colours throughout."
- **Rat's Nibble timing is unclear.** It unlocks at 50, the level the Rat is restored *by winning*. Is it usable on level 50 itself, or only from 51?

**Source:** Story beats table (10, 20, 40); Obstacle set (OB07 at 17); Design pillars; Art direction › Backgrounds; Asset count; Level progression › Chapters; Core gameplay › Rules; Booster unlocks.

## Round 2 — Cross-examination

### Systems Designer

**CONFLICT: the proposed debut fix can't be applied, because the rules contradict each other.** Systems #5 (and my own Round 1 #3) suggest shifting the early debuts to 16/21/26/31. Level 26 can't take a debut. It is a scripted Rat fragment level (26, 30, 33, …), and Soul fragments › Rules says "intro levels never do" carry fragments. So "debut on the relief level after a hard level" and "intro levels never carry a fragment" can't both hold at 26 under the current schedule. Level 16 has its own problem. It is the pre-level booster unlock, so a debut there piles two new things onto one level (see Player Psychologist below). The level agent is told to run the brief's validation checklist. With these inputs, no valid plan for 26 exists. The fix has to be an explicit exemption ("debut rule applies from 41"), not a renumbering. Of Systems' two options, only "state that the rule applies only from level 41" works.

**CONFLICT: one count and one proposed fix.**
- Systems #1 says "six of the eight Rat fragment levels are hard or finale levels". The list is 30, 35, 40, 45 (hard) and 50 (finale), which is five. The argument still stands, but the number is wrong.
- Their fix option "the fragment is auto-collected on any win" has a cost they don't mention. It turns OB07 cocoons (26–33) and OB11 drop items (from 34) into decoration: the player can ignore them and still collect. The level-30 beat ("the Rat fragment found at 26 begins to glow") would also be true for players who never touched the fragment. I back their other option: the fragment takes one of the tier's goal slots. I add one requirement to it. The rules must state whether board-clearing effects (Orb + Orb, Rocket sweeps) *collect* a fragment or *destroy* it. My #1 raised this, and neither fix covers it.

**CONNECTION: a non-trail guardian can be restored out of order.** Systems #4 shows the random pool includes Ox, Rabbit and Dog before their trails start. Put that next to my #2, the out-of-order restoration. The pool is wider than the document assumes, so the chance that a guardian completes off-trail (and the trail-jump ambiguity that follows) is higher than the doc's numbers suggest. Their spreadsheet fix should model restoration *order*, not just the count by level 200.

**CONNECTION: replay farming breaks the economy and the difficulty curve.** Systems #2 (coins have one sink: the 300-coin continue) and #3 (lives walls at 25 and 50) both assume players spend coins and lives only on new levels. The document never says whether won levels can be replayed. If they can:
- A level-1 replay (30 moves, 1 goal) pays 20 coins plus a rocket for each leftover move, which is enough to buy a continue in a few minutes.
- Three quick wins on old levels trigger the win-streak chest ("free Rocket and Crane onto the next board") right before a finale.
- Re-winning finale 25 re-grants "30 min of unlimited lives", which defeats the lives system entirely.

If replay is allowed, the 25–35% finale targets are not what players actually experience. If replay is banned, my #1 (a missed fragment is lost forever) gets worse. Either way, the replay rule decides whether Systems #3's lock-out numbers are real.

### Player Psychologist

**CONNECTION: the Nian's Eye on level 50 makes my Round 1 #4 a finale-blocking issue.** PP #4 points out that the rule "the 3–5 levels after an intro each include it" puts OB09 (debut 46) into 47–50. That includes the level-50 finale, which also carries the last Rat fragment. On that level, all the undefined interactions from my #4 land at once:
- A Crane flying across the beam.
- A Crane carrying a special to a goal tile.
- Whether a special the beam destroys counts as one of the Eye's 3 hits.

Add the fragment from my #1. If it is an OB11 drop item, it has to travel down to the bottom row, possibly through the beam's column. The hazard rule only bans *goals placed* behind a beam, not goals that *pass through* one. The MVP's emotional climax ends up resting on the least-specified rules in the document. I agree with PP's fix: no OB09 on 50.

**CONFLICT: PP's lives fix opens an exploit.** Their option of granting the unlimited-lives window "when the player reaches a finale" needs a definition of "reaches". If it triggers on unlocking or entering the finale, a player can enter, quit, and spend 30 unlimited minutes replaying or retrying hard levels elsewhere. Their other option has no such hole: don't take a life on a finale fail. I support that one.

**CONNECTION: the fix for my debut contradiction creates a new double unlock.** PP #2 flags 22 (debut plus booster unlock) as overload. Applying the literal debut rule moves OB07 from 17 to 16, which also lands on the pre-level booster unlock. So the obvious fix recreates the same problem one level earlier. That's more evidence the debut schedule and the booster schedule were never checked against each other.

### Feasibility Lead

**CONNECTION: the local-save exploit.** FL #2 says the shared profile has no backend, so the MVP will in practice save locally: browser storage on itch.io, local files on Android. From my lens, that means:
- Fragment counts, Soul Dust and restored guardians can be edited by hand.
- Clearing site data wipes them.

The design pillar calls fragments "the shared currency of the whole Zodiac world (Part 2 games and PvP)". A currency that will feed PvP, stored in an editable local file, is an exploit the document has built in from the start. Any later migration has to treat MVP saves as untrusted. This adds to FL's case for a versioned schema now.

**CONNECTION: no interaction table means no tests.** FL #3 overlaps with my #4. Together they show that GUT tests for "every special and combo" can't be written until three things are defined:
- A shape-priority order (5-in-line vs. T vs. 2×2).
- Tap behaviour for a Jade Orb.
- What "goal tile" means for the Crane when the goal is a fragment drop item. Does the Crane fly to the fragment and *destroy* it, or *collect* it?

That last question ties FL #3 directly to the BLOCKING fragment issue.

**Partial agreement on the cut list.** FL proposes cutting OB09. That would remove most of my #4 and PP #4, so I support it. It costs one thing they don't mention: "12 obstacles by level 56" and levels_1_100_plan.csv both assume OB09 at 46, so the level-agent plan would need to change as well.

### Narrative Critic

**CONNECTION: the Monkey's identity changes the fragment arithmetic.** NC #1 asks whether the Proboscis Monkey is the zodiac Monkey guardian who escaped. If he is, his soul was never scattered. He then shouldn't be in the 30% random pool, and "the other 8 guardians" (12 minus Rat, Ox, Rabbit and Dog) is really 7. The schedule's "~2 of 12 each" and the "3 guardians restored by about level 200" pacing both depend on a story question the document leaves open. The answer also decides whether fragments can ever drop for a guardian who is standing in front of the player.

**CONNECTION: the level-30 beat assumes the fragment was collected.** NC #1 notes the Monkey joins at 25 in the Cast table but at 30 in the beats table. Separately, the level-30 beat says "the Rat fragment found at 26 begins to glow". That beat assumes the player collected the 26 fragment, which the rules don't guarantee (my #1). A player who won 26 without it would see a story beat about an object they don't have. This is a third failure point for my BLOCKING finding, beyond the level-50 restoration and the week-18 milestone.

### Business Analyst

**CONFLICT: the trail logic is already in the MVP.** BA #5 calls the post-60 content decorative and says it "invites building systems early, such as the full 70/30 trail logic with a pity rule when MVP players will only ever see the Ox trail." I disagree with the conclusion. The 70/30 split ships in the MVP: the 51–60 beat is literally "first random fragments of other guardians", and the Soul Dust conversion is live from 51, because Rat fragments in the random pool become Dust. So roll timing (the reroll exploit) and the random-pool definition are MVP problems, not backlog. BA's point does apply to the **pity rule** and **out-of-order restoration**, and I revise those below.

**CONNECTION: "Act 1" multiplies the open fragment rules.** BA #1 shows that "Act 1" is undefined. If the scope grows past 60, every open rule in my #2 starts to bite: pity, out-of-order restoration, trail jumps, and guardian powers at ~110. On the current 60-level scope most of them never trigger. A scope decision changes my severities, so it has to come first.

### Revisions to my Round 1

- **#1 (fragment not a goal): stays BLOCKING, strengthened.** Systems found it independently. The level-30 beat (Narrative) and the possible OB09 on level 50 (Player Psychologist) add failure points. A fix has to settle three things: the fragment takes a goal slot, what board-clearing effects do to it, and whether won levels can be replayed.
- **#2 (random fragments): downgraded from MAJOR to MINOR for the MVP, except the roll-timing and replay items.** Levels 51–60 contain about 4 drops: hard levels 55 and 60, plus roughly 2 of the 8 other levels at 1 in 5. Four trail misses in a row (the pity trigger) and an off-trail restoration are essentially impossible inside the MVP. Systems #4 already covers the arithmetic. Roll timing and replay farming stay open, because they affect MVP levels 51–60 and the economy (see the Systems connection above).
- **#3 (rules vs. schedules): stays MAJOR, sharpened.** It's worse than inconsistent. The debut rule can't be met at level 26 without breaking the no-fragment-on-intro rule, and meeting it at 16 stacks two unlocks on one level. The level agent can't produce a plan that passes validation. The only fix is an explicit exemption.
- **#4 (special interactions): stays MAJOR.** The level-50 exposure Player Psychologist identified would make it BLOCKING if OB09 stays in the 47–50 window. Cutting OB09 from the finale, or from the MVP, keeps it MAJOR.
- **#5 (minor contradictions): partly withdrawn.** I withdraw the "3-colour exception" item. On a second read it's an ordinary stated exception, not a contradiction. The research row "4 colours throughout" describes MV, not this game's rule. I keep the background count, which three other reviewers also flagged, and the Rat's Nibble timing. The level-10 freed creature stays MINOR from my lens because it's a one-row fix (swap OB07 to an earlier slot). Narrative's MAJOR rating for the pillar break is reasonable within their scope.
