# Production/Business Analyst — Round 1

Scope: feature creep, load-bearing vs decorative features, market positioning, audience clarity. Story logic and systems math are left to other reviewers.

## 1. The success test cannot produce a trustworthy go/no-go decision — BLOCKING

**Problem.** The whole post-MVP plan hangs on one gate: "Android D1 ≥ 35% and D7 ≥ 12%" decides whether to "plan monetisation and the next 40 levels", "fix the pacing of levels 20–60" or "rework the first session". The document never says where the measured players come from or how many are needed.
- **No acquisition plan or budget.** The Option A budget (Claude Pro, Scenario, music, Play fee ≈ US$210) has no marketing or user-acquisition line. The Overview's "community push" is never defined or costed. With no ads, no IAP and no UA spend, the cohort will be small and organic, so a D7 of 12% on a few dozen installs is noise.
- **The cohort is contaminated.** The first Android players are the 12–15+ closed-test opt-ins (week 16), who are usually friends and recruited testers. Nothing says they are left out of the D1/D7 numbers.
- **D7 is confounded with running out of content.** The MVP has 60 levels, no live ops, no events and no replay ("Won levels cannot be replayed in the MVP"). Lives are rarely a wall: 5 lives, refills every 20 minutes, and most tiers sit at 60–95% first-try win rates. An engaged player can plausibly finish 60 levels in the first few days. A missed D7 would then mean the content ran out, but the decision tree reads it as a pacing problem in levels 20–60 and sends the team to fix the wrong thing.

**Source.** Overview table ("Success test", "Budget", "Why switch to it … community push"); Retention test; MVP milestones (week 16 closed test); Soul fragments ("Won levels cannot be replayed"); Level tiers win targets.

**Fix direction.** Set a minimum cohort size and a defined player source (and budget, even a small one) for the test. Leave closed-test accounts out of the numbers. Track how many players reach level 60 by D7 next to D7 itself, and add a branch to the decision tree for "players ran out of content".

## 2. The Lunar New Year hook has no date and the schedule cannot hit the next one — MAJOR

**Problem.** "Full launch timed to a Lunar New Year with a community push" is listed as a reason to switch, and the audience includes "the wider Lunar New Year audience". The GDD is dated 2026-11-25 and runs a 20-week plan, so public launch lands around mid-April 2027. That is about two months after Lunar New Year 2027 (6 February). The next one is late January 2028, more than a year away. The document never says which Lunar New Year it means. It also never says what happens between an April 2027 MVP and a 2028 "full launch": monetisation, the next 40 levels and iOS would all have to fit in that gap. Nor does it explain how a seasonal hook works for an evergreen game whose MVP has no seasonal content.

The audience is also left unexplored. The Lunar New Year players it implies are largely in East and Southeast Asia, and the cast draws on Malay/Indonesian folklore (Sang Kancil). Yet localisation, target countries and store languages are never mentioned, and iOS is "later".

**Source.** Overview table ("Why switch to it", "Audience", "Platforms"); document date; MVP milestones (20 weeks).

**Fix direction.** Name the target Lunar New Year. State that the MVP is a retention test, not the seasonal launch. List the target markets and languages, or explicitly limit the launch to English-speaking markets and drop "Lunar New Year audience" from the audience line.

## 3. The audience and open questions are marked closed but not resolved — MAJOR

**Problem.**
- **The audience contradicts itself.** "New match-3 players are welcome" sits next to a "Why switch to it" row, which only makes sense for people already playing another match-3. The design is also benchmarked against Match Villains' cadence for its existing audience.
- **Unresolved items are ticked as answered.** All six Open questions carry [x] (ticked), but no answers are written down, and the body still shows them open: Audience "(proposed, confirm)", retention bars "(proposed bars)", Art "primary colours (tbc)" in two places, guardians "Stone (or ice)", guardian order "Ox → Rabbit → Dog is proposed", and the upgrade-flow question still pointed at from Level progression.
- **The week-6 gate cannot be checked.** The week-6 milestone ("Every item under Open questions is answered") is either already passed on paper or impossible to verify. The audience decision affects tone, difficulty curve, store page and the success bars, so it should not be left implicit.

**Source.** Overview table (Audience, Success test, Art); Art & audio direction (Guardians row); Soul fragments schedule; Level progression ("see Open questions"); Open questions list; week-6 milestone.

**Fix direction.** Write each answer next to its question and remove the "(proposed)", "(tbc)" and "(or ice)" qualifiers. Choose a primary audience: new or lapsed casual players, or switchers from Match Villains-style games. Set the on-ramp and the "why switch" pitch for that group.

## 4. The "why switch" differentiators are thin for the MVP that will actually ship — MAJOR

**Problem.** The three stated reasons to switch are the four heroes, the Paper Crane, and "a fair lives and pop-up model".
- **The fair model proves nothing yet.** "Monetization: None in MVP" means there is nothing to sell, so there is no pressure to resist. Any free, ad-free MVP has a clean lobby, and the fairness claim is only tested once monetisation arrives after the MVP.
- **The Paper Crane is not new.** It is a 2×2-square special that homes in on a goal, which is a standard special in current top match-3s. The document itself calls it the research's recommended "telegraphed" twist, not something unique.
- **The heroes are mostly reskins.** The real distinctive elements are the heroes as boosters and the rescue story, but the boosters are standard (single tile, 3×3, line, shuffle). The heroes reach the board one at a time only from levels 11–36.
- **The design is close to Match Villains.** The research approach is to "copy MV's measured rhythm and feel", using MV's obstacle behaviour IDs and MV's booster unlock levels ("MV's proven levels, our themes"). The result is a well-tuned MV-shaped game with a new skin. That is a fine production strategy, but the document should not present it as a reason for players to switch.

**Source.** Overview ("Why switch to it", Monetization); Core gameplay ("The Paper Crane is the one 'signature, telegraphed' twist the research recommends"); Research basis; Booster unlocks heading.

**Fix direction.** State one hook that a player sees in the first session and that no competitor has. The four-hero, Yunnan-forest rescue story plus the hero quips is the strongest candidate, so bring a hero onto the board before level 11. Treat "fair model" as a promise for after the MVP, not a selling point for the MVP.

## 5. Post-MVP systems and decorative extras crowd a solo 20-week MVP, and the cut list protects them — MAJOR

**Problem.** The MVP is meant to be "levels 1–60, nothing added". The developer is learning Godot at the same time (week 3: "Godot basics"), and the document itself says a live-ops cadence is "not feasible solo". Yet the GDD is several games at once:
- **Designing systems that won't ship.** Much of the design covers systems that do not exist in the MVP: random 70/30 fragment rolls, a pity rule, a fragment schedule out to level 201+, three post-MVP guardian powers, Nian's Eye and Jar rules, 16 obstacles by level 96, element families "for Part 2", PvP, Part 2 games and a shared cross-game profile. In the MVP every fragment is scripted, so the fragment system is just a progress bar.
- **Decorative extras that cost real work.** Several features inside the MVP add work without being load-bearing for "feel + rescue boards + 60 levels":
  - a full coin economy with priced boosters and pre-level boosters in a build with no monetisation;
  - a win-streak chest;
  - two free-every-level powers (Monkey's Staff, Rat's Nibble);
  - a 4-hero × 7-moment quip matrix with combo callouts;
  - a hand-recorded material sound library;
  - an AI style-model art pipeline;
  - a level bot with two human calibration rounds.

  The free-every-level powers also undercut the paid boosters the "plan monetisation" branch will later rely on.
- **The cut list cuts the wrong things.** It cuts cheap items first (Staff, one obstacle, one card's art) and then jumps to the load-bearing content (levels 51–60). It never touches the expensive decorative systems: coin economy and booster pricing, pre-level boosters, win streak, quip matrix, recorded sound library.

**Source.** Overview (pillar "Souls restore the world", Out of scope); Soul fragments rules and schedule; Meta & economy (Currencies, Booster unlocks incl. ~110/~165/~200 powers); The four heroes ("How they talk" table); Feel, juice & sound (Godot setup / recording); Art pipeline; Technical design (level bot, calibration); Cut list; Research basis ("Not feasible solo").

**Fix direction.** Move the post-MVP system design out of the MVP GDD into the Part 2 backlog. Re-rank the cut list by cost, not by visibility. Put the coin economy, paid boosters, pre-level boosters and win streak ahead of levels 51–60, since the MVP has nothing to buy and the retention test does not need them.

## Round 2 — Cross-examination

### Conflicts

**C1. Player Psychologist #1 (lives wall, BLOCKING) vs my #1 ("lives are rarely a wall") and Systems Designer #2.** The Psychologist's math is right for the *first session*: 8–10 expected lost lives across 1–25 against 5 lives plus ~3/hour regen puts a steady player at zero around levels 15–22. I concede that my Round 1 line "lives are rarely a wall" was too broad. It holds over a week (Systems #2: the gate delays a player "by a day or two, not a week"), not within one sitting. But I disagree with the proposed fix, "remove lives". In this MVP, lives are the *only* thing rationing a 60-level, no-replay, no-live-ops content pool. Removing them speeds up content exhaustion and makes the D7 confound in my #1 worse. The business-correct framing: lives in this MVP are a pacing tool, not a monetisation tool, and should be tuned as one. Make hard-level fails free on 15 and 20 (as finales already are), or let coins buy a refill. That keeps the multi-day pacing and removes the session-one cliff.

**C2. Systems Designer #2's "add the daily puzzle" and Player Psychologist #2/#3's "forest-healing map / rescued-friends collection / guardian meter / Story so far" vs my #5 (feature creep).** Every colleague's fix adds a feature to a solo, Godot-learning, 20-week plan whose cut list already cannot absorb a slip (Feasibility #1). I rank these by whether they are load-bearing for the retention test:
- *Guardian meter (x/8)* and *Story so far* are load-bearing and cheap. They make the existing pillar ("every fragment visibly…") visible and reuse existing assets. Accept.
- *Daily puzzle* is a live-ops loop in disguise. It needs a generator, a date rule, rewards and a reason to return, and the doc itself rules live ops "not feasible solo". Reject for the MVP. Use the measurement fix instead (read D7 only for non-finishers, my #1 / Systems #2 third option).
- *Forest-restoration meta* is a new system with no design ("Owner: you"). Accept it only as a swap: it replaces the coin economy (see Connection N2), not on top of it.

**C3. Feasibility Lead #1 (cut engineering: combos, bot, Crane targeting) vs my #5 (cut decorative systems: coin economy, pre-level boosters, streak chest, quip matrix).** These are complementary cut lists, with one real tension: Feasibility proposes "ship the bot after week 9". But Systems #1 and Adversarial QA #5 need the bot to model the free powers, and my #1 needs trustworthy difficulty data before the go/no-go. A late or unvalidated bot weakens the test the whole plan depends on. My position: cut the decorative systems first, which also removes the bot's hardest modelling cases (free charges, streak chest). That makes the bot cheaper, so it can stay on schedule. My cuts buy back Feasibility's time without deferring the bot.

### Connections

**N1. The decorative features I flagged are the root cause of two colleagues' BLOCKING findings.** Adversarial QA #1 (undefined Crane + special swap) is triggered *only* by the level-16 pre-level booster ("Start with a Rocket + Crane") and the win-streak chest. Organic Crane-next-to-special boards are rarer, and the rule gap could be closed by one row. Systems #1 (free powers missing from calibration, BLOCKING) is caused by Monkey's Staff and Rat's Nibble, which I listed as decorative. Feasibility #2 lists the same items (Staff, Nibble, Tail Slam, streak chest) as interaction-table gaps. Cutting pre-level boosters, the streak chest and the free per-level powers from the MVP removes or shrinks three colleagues' top findings at once. Systems #1 adds that cutting the Staff later, as the current cut list does, would silently re-tune 30–60. That makes the case for cutting it *now*, before calibration, rather than as the first emergency cut.

**N2. The coin economy is both decorative and broken, so it is the cheapest big cut in the document.** Systems #4 shows that coins gate nothing: the total supply is ~2,600, a continue costs 8–15 wins, and no-booster targets mean coins are never needed. Player Psychologist #1 shows that coins can't buy the one thing players run out of, lives. Together with my #5, the coin layer costs UI, pricing, a save field and booster-purchase flows, gives the retention test no signal (Systems: "the D1/D7 test is not testing an economy at all"), and feeds untested prices into the "plan monetisation" branch. Either cut it, or repurpose it as the soft-lives fix from C1 (coins buy a refill). That gives coins one real use and fixes the psychologist's wall with no new system.

**N3. Both D1 and D7 are confounded, so the go/no-go measures the lives wall and the content wall, not the game.** My #1 covered D7 (content exhaustion), and Systems #2 independently derived the same thing with playthrough math. Player Psychologist #1 adds that D1 is confounded by the first-session lives wall. Narrative Critic #1 and the level-60 beat add a third effect: the MVP ends on a cliffhanger ("Its great Eye opens over the Ox's valley") whose payoff, level 61, does not exist. Finishers hit a dead end exactly when the story asks them to come back. All three branches of the decision tree ("rework the first session", "fix pacing of 20–60", "plan monetisation") can be triggered by artefacts of the MVP's own structure.

**N4. The differentiator I recommended is weaker than I thought.** In #4 I named the four-hero rescue story and quips as the strongest "why switch" hook. Narrative Critic #3 shows that the script breaks its own hero rules from the first comic: Kancil is outnumbered in level 1, absent from five beats, and never again "wins by thinking" after 15. Narrative #5 shows that the fixed bark names the wrong guardian on every Ox fragment. Player Psychologist #4 shows that the rescue goal itself does not appear until level 7. Combined: in the first session, the player sees no hero on the board (11+), no rescue until 7, no fragment until 26, and a lead character whose voice the script does not hold. The one hook that could separate this from a Match Villains reskin is not yet delivered in the window where D1 is decided.

**N5. The schedule slip compounds the budget and positioning gaps.** Feasibility #4 shows that the retention verdict cannot land before ~week 22. Claude Pro is budgeted for 6 months and Scenario for 3, and Feasibility #5 shows the asset count is undercounted against that Scenario window. My #1 noted the budget has no UA line. The ~US$210 budget is therefore short on both the production side (extra subscription months) and the measurement side (no players). Feasibility's "start the closed test at week 14 with ~20 testers" helps the schedule but enlarges the friends-and-recruits pool my #1 says must be excluded from D1/D7. Exclusion has to be designed in from the start (a build flag or cohort tag), not cleaned up afterwards.

### Revisions

- **#1 (success test) — stays BLOCKING, scope widened.** Systems #2 independently confirms the D7 confound. Player Psychologist #1 adds a D1 confound, and Narrative #1 adds the dead-end cliffhanger. I withdraw the sentence "Lives are rarely a wall" as written: over a week, true; in session one, false (see C1).
- **#5 (feature creep / cut list) — upgraded MAJOR → BLOCKING.** In Round 1 I argued these features were wasteful. Round 2 shows that they are dangerous: they are the direct cause of Adversarial QA #1 (BLOCKING), Systems #1 (BLOCKING) and much of Feasibility #2. And a cut list ordered as it is now would remove the Staff mid-production and break calibration (Systems #1). An unbuildable-or-untunable MVP is a go/no-go issue, not a polish one.
- **#4 (thin differentiators) — stays MAJOR, fix direction revised.** "Bring a hero onto the board before level 11" is not enough. The hook also needs the narrative fixes (Narrative #3 for Kancil's voice, #5 for the guardian-aware bark) and the rescue goal from level 1–2 (Player Psychologist #4). Until then, the document should present the MVP as "Match Villains' rhythm, our story" and not claim the heroes as a proven reason to switch.
- **#2 (Lunar New Year) — downgraded MAJOR → MINOR for this MVP.** With Feasibility #4 placing the verdict at week 22+, it is unambiguous that no Lunar New Year before 2028 is reachable, and the MVP is a retention test, not the launch. The fix (name the year, mark the MVP as a test) is a one-line edit. The localisation and target-market question stays live, but it belongs with the audience decision in #3.
- **#3 (open questions ticked but unanswered) — stays MAJOR, now cross-confirmed.** Feasibility #5, Player Psychologist #3 and Systems #4 each independently found a ticked [x] item with no answer (art colours, the forest meta, the economy sheet). Four reviewers hitting the same pattern from four lenses suggests the week-6 gate is not a real gate. I'd ask the moderator to treat this as a process finding, not an individual one.
