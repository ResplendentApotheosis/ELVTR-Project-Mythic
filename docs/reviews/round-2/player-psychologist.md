# Player Psychologist — Round 1

Scope: what a real player goes through, mostly in the first session and the first week. Five findings, ranked most severe first.

---

## 1. The lives system can lock players out, and in the MVP they have no way back in — BLOCKING

**Problem.** The MVP has no monetization, but it still has a lives gate: 5 lives, and one life back every 20 minutes. When a player runs out, they can't do anything. Coins can't buy lives, there are no ads and there is no shop, so the only option is to wait up to 100 minutes. In a game that makes money, lives give players something to buy. Here they bring in nothing and only push players to quit. That hurts the one thing the MVP is measuring, D1 and D7 retention.

**How likely it is.** It's likely. Medium levels target a 60–70% first-try win rate, which works out to about 0.5 expected failures per level. Hard levels (15 and 20) target 35–45%, about 1.5 failures each. Over levels 1–25, that adds up to roughly 8–10 lost lives against a regen of 3 per hour. A player who plays steadily for 45–60 minutes will probably hit zero somewhere around levels 15–22. That is the end of their first session, which is exactly what D1 measures. Failing a finale costs no life, but levels 15 and 20 are not finales.

**Source.**
- Meta & economy, Lives: "5 max; lose one on fail … refill 1 per 20 min".
- Coins: "Spent on the continue and on hero boosters". Nothing buys lives.
- Overview, Monetization: "None in MVP".
- The level tiers table gives the win targets above.
- The doc sees the risk ("track how many players quit within 2 sessions after running out of lives on levels 15, 20 or 25") but only plans to measure it, not to prevent it.
- The pitch's "generous lives" isn't backed by any number. 5 lives at 20 minutes each is the genre's standard, not generous.

**Suggested direction.** For the retention test, either remove lives or make them much softer: for example, failing a hard level costs no life, or coins can buy a refill. Otherwise D1 measures the lives wall, not the game.

---

## 2. "Every fragment visibly brings a guardian closer to waking" has nothing designed to show it — MAJOR

**Problem.** Soul fragments are the main long-term reward, and they're in both the pitch and the pillars. But the doc never says where a player sees progress like "Rat 5/8". After the reveal, the Rat needs 8 fragments spread over 25 levels, with long gaps between them (26 → 30 → 33 → 35 → 38 → 40 → 45 → 50). If nothing shows the statue changing between fragments, collecting them feels the same as collecting coins, and the payoff at level 50 is too far away to keep players going.

**Source.**
- Pitch and pillars: "Every soul fragment visibly brings a guardian closer to waking."
- Fairness rules: "After a win, at most 2 screens; any other reward … shows as a badge on the map." There's no room in the win flow for a guardian progress beat.
- Assets list only "Rat statue + restored" and "a glowing cracked-statue stage for the reveal". There are no in-between stages.
- The only feedback for a freed fragment is a hero quip ("One more piece of the Rat's soul"). The one visible change, "begins to glow", is a single story line at level 30.
- The save data "already tracks … fragments", but no UI reads it.

**Suggested direction.** Specify a guardian meter (x/8) on the map or level card, and statue art that changes visibly every 2 fragments or so. Let the fragment-collect moment count as one of the 2 allowed post-win screens.

---

## 3. Levels 1–25 have no long-term goal, so the hook arrives after most first sessions end — MAJOR

**Problem.** The game's progression hooks (soul fragments, guardians, the "we'll wake them ourselves" goal) all start at levels 25–30. Before that, a player gets coins, a few short story lines (levels 1, 10, 15, 20) and a new background every 10 levels. The forest restoration meta, the one system that could fill those levels, is handed off without a design ("You design the wider meta … Owner: you"). It's also listed as a ticked open question while the doc still asks it as a question. On top of that, coins have almost nothing to buy until the first booster unlocks at 11 (only the 300-coin continue). D1 depends on whether the first session gives players a reason to come back, and right now that reason is only "more levels".

**Source.**
- Soul fragments: "Fragments start at level 26."
- Story beats table: nothing from 2–9 or 11–14.
- Meta & economy: "You design the wider meta (forest restoration); this section fixes only the numbers the levels depend on."
- Open questions: "[x] (ticked) … Plus the forest restoration meta". It's marked done but nothing in the doc answers it.
- Milestone week 6 requires "Every item under Open questions is answered".

**Suggested direction.** Before week 9, decide which visible, persistent thing changes in the first 20 minutes. Possible options are a forest-healing map that clears per level, or the first mummified creature joining a visible "rescued friends" collection. Put it in the GDD rather than leaving it undocumented.

---

## 4. The first 13 levels teach something new on almost every level, and the core "rescue" fantasy waits until level 7 — MAJOR

**Problem.** Collecting the debuts from the tables gives this schedule:

- 1 bramble
- 2 Rocket
- 3 Firecracker
- 4 dew
- 5 Paper Crane
- 6 Jade Orb
- 7 mummified creature
- 8 Rocket+Rocket combo
- 10 Lantern shrine
- 11 Hoof Tap booster
- 12 Rocket+Firecracker combo
- 13 Petrified pillar

That's 12 new things in 13 levels, and only level 9 teaches nothing. The research the doc cites says a new obstacle every 3–5 levels early on. Every new idea also comes with the 4 heroes' lines, so new and returning players will forget the earlier lessons before they've practised them. There's a second problem. The pillar says goals are "never 'collect 30 blue'", but the special tutorials on levels 2–6 are where "collect N red" goals are allowed. And the mummified creature, "the core rescue goal", doesn't appear until level 7. So in the first five minutes, the player isn't rescuing anyone.

**Source.**
- Special pieces table: tutorial levels 2, 3, 5, 6.
- Obstacle set: debuts 1, 4, 7, 10, 13.
- Combos: "Rocket + Rocket at level 8 and Rocket + Firecracker at level 12".
- Booster unlock at 11.
- MV research row: "New obstacle every 3–5 levels early".
- Pillar "Every board is a rescue".
- Goals rule: "'collect N red' style goals are only used in tutorials."
- Audience: "new match-3 players are welcome".

**Suggested direction.** Move the mummified creature to level 1–2 so the rescue fantasy starts right away, and frame special tutorials as rescues (for example, "free the hedgehog with a Rocket"). Spread the specials out, or group the 4 specials more loosely so that at least one practice level follows each new idea.

---

## 5. Won levels can't be replayed and skipped story can't be rewatched — MINOR

**Problem.** In the MVP, a player can't replay a level they've won, and nothing says they can rewatch a story beat or comic. Players who skip the level 1 comic by reflex (it's skippable) or tap through a story card lose the premise for good. That matters most for the level 25 reveal poster, which explains why fragments exist. It also means a player who learns a combo late can't go back and practise on a board they know, and players who just like a level can't play it again.

**Source.**
- Soul fragments: "Won levels cannot be replayed in the MVP."
- Story beats: "Intro comic (4 panels, skippable …)".
- No story log or rewatch option appears anywhere in the doc.

**Suggested direction.** A simple "Story so far" screen on the map that replays the cards and posters already shown. It reuses existing assets, so it's cheap. Replaying won levels can stay out of scope.

---

## Round 2 — Cross-examination

I read all five colleague reviews and re-checked gdd.txt. Two of them (Systems Designer #2 and Business Analyst #1) disagree directly with my top finding. After rechecking the numbers I accept part of their argument, and that changes my severity. The rest of this section argues my position where I still hold it.

### CONFLICTS

**C1. Systems Designer #2 and Business Analyst #1: "lives are rarely a wall" vs. my #1, "the lives system locks players out".**
SD calculates about 30 lives for the whole MVP and concludes the gate "slows players by a day or two, not a week". BA says "Lives are rarely a wall." Both are right over a week. Both are wrong to treat that as evidence the lives have no cost. Their numbers average over 60 levels and 7 days. A player's decision to quit happens in one session, at one level. At level 15 or 20 with a 35% first-try rate, the chance of 5 straight fails is 0.65^5, about 12%. At the band's top (45%) it is 0.55^5, about 5%. On top of that, Feasibility Lead #3 shows the band itself can't be verified before launch: 5 testers on levels 1–10 tell you nothing about hard levels. If the first hard levels really land near 25%, the 5-fail chance rises to 0.75^5, about 24%. So the lockout risk falls on a minority of players, but it lands in session 1 on exactly the levels the doc's own lives-wall metric watches.

Where I hold my ground: put SD's and BA's math next to mine and lives look worse. If they don't pace content across the week (SD's point), the only measurable thing they do in this MVP is add frustration spikes at 15 and 20. They have no revenue role and no pacing role, only a cost.

There is a real tension I have to concede. Softening lives, as I suggested, makes players run through the 60 levels faster, which makes the content-exhaustion problem SD and BA describe worse. My answer is to combine fixes rather than keep lives as a substitute for pacing. Use SD's fix: read D7 only for players who haven't finished, plus BA's "ran out of content" branch. With that in place, softening lives no longer skews the measurement. Using a frustration mechanic to stretch content is the very "lives lock-out" complaint the research pack says the game should fix (Research basis, top complaints).

**C2. Business Analyst #5, "cut the win-streak chest and the coin economy ahead of levels 51–60", vs. my #1 and #3.**
On cost, BA is right that these aren't load-bearing for the systems. From the player's side, two of the cuts take away the only things that soften my findings.
- **Coins and the continue.** The "+5 moves" continue is the only fail softener in the game. A player reaches level 15 with 500 starting coins plus about 14 wins of income, enough for 2–3 continues. Cut the coin economy and lives stay, and every hard-level fail becomes a lost life with no alternative. My condition: if the coin economy goes, lives must go too. The two decisions are linked and the cut list should say so.
- **The win-streak chest.** It is one of very few rewards in levels 1–25, which is the dead zone in my #3. A player on a run of easy and intro levels will plausibly hit 6 straight wins in the first session. I'd keep it, but only once QA #1 is fixed (see N1).

**C3. Business Analyst #4, "bring a hero onto the board before level 11", vs. my #4, onboarding overload.**
I agree with the goal: the heroes are the strongest first-session hook. But levels 1–13 already introduce 12 new things in 13 levels. An earlier Hoof Tap only helps if it replaces something rather than adding to the pile. For example, delay the Rocket+Firecracker tutorial (level 12) or the Jade Orb tutorial (level 6). Feasibility #1's proposed engineering cuts (defer Jade Orb + special and Firecracker + Firecracker) help here too, because they mean fewer combos for players to find in the early game. One more point: the heroes already appear in the first minute through quips. What is missing is a hero doing something visible on the board. The cheapest fix is the booster-action animation, shown once as part of the level-1 tutorial.

### CONNECTIONS

**N1. Adversarial QA #1 (Crane + special undefined) + my #4: this is a learnability problem, not just a spec gap.**
The game teaches players a rule: "swap two specials to make a combo" (tutorials at 8 and 12, and "the idle hint shows a combo swap whenever one exists"). Then the level-16 pre-level booster and the streak chest put a Rocket and a Crane on the board together, often next to each other. Swapping them is the most natural thing a player can do. Whatever happens, whether refused, fired one after the other, or undefined, breaks the rule the game just taught, and it does so on the signature piece. That's why I would not resolve QA #1 by blocking the swap. A refused swap of two specials will read as a bug. The player-facing fix is to give it a simple, visible combo behaviour, even a plain one like "both fire, Crane first", so the taught rule holds. I agree with BLOCKING.

**N2. Narrative Critic #2 (fragments collected before anyone says why) + Narrative #5 (the bark names the Rat for Ox fragments) + Systems Designer #5 (Ox may end at 2/12) + my #2 (no progress display).**
Taken together, these show that every point where the player touches the fragment arc is weak:
- **First fragment (26–29).** It has no on-screen meaning (Narrative #2) and no meter (mine). The pillar's first payoff is a goal icon with no explanation.
- **Middle (26–50).** No in-between statue stages, and the 2-screen post-win cap (mine).
- **Chapter 3 (51–60).** The only feedback channel, Kancil's bark, names the wrong guardian (Narrative #5).
- **End of MVP.** The last thing the player sees is the Ox at roughly 2/12 (SD #5), with no meter to make even that visible.

The pillar "every fragment visibly brings a guardian closer" fails at the start, the middle and the end. One fix covers all four: a guardian meter on the map and level card, with a line from the Monkey at level 25 saying "the souls can be gathered" (Narrative's fix). I'm raising my confidence in #2. See R2.

**N3. Adversarial QA #2 (Hoof Tap can delete a drop-item fragment) + my #1: the worst kind of frustration.**
From level 35 on, a fragment can be a drop item in the content layer. If a player uses the Hoof Tap on it, the level becomes unwinnable. The player didn't make a mistake they can see. The tool they were given removed a goal. The game then makes them play out the board or quit, lose a life, and retry. This is a "the game cheated me" moment, which damages trust far more than an ordinary fail. Level 35 is also a hard level, where lives are already under the most pressure. I agree with MAJOR and would treat it as a launch blocker if no rule is added.

**N4. Adversarial QA #3 (level-34 intro conflict) + my #4: the first drop-item fragment lands on a hard level.**
If QA's fix is adopted (34 teaches with hatchlings), the first time a player must carry a fragment to the bottom row is level 35. That is a hard level with 3–4 goals, a story beat, and a fragment they can't afford to lose. The intro rule's "the 3–5 levels after an intro each include it" gives no practice level before the spike. My suggestion is to make the level-35 fragment a cocoon and put the first drop-item fragment on 38 or later.

**N5. Systems Designer #1 / QA #5 (free Staff and Nibble charges not calibrated) + my #2 and #3: the rewards feel cheaper.**
If chapter-2 hard levels play much easier than their target because the Staff is free every level, the fragments on them come without much struggle. Fragments are the reward the game hangs its motivation on, and a reward that takes no effort feels like less of one. There's also a split in what players experience. Players who forget the Staff (it's a free charge, never explained after level 30) play the levels at target difficulty, while players who use it play much easier ones. One cohort, two difficulty curves, so D7 can't be read cleanly. This also makes SD #4 worse: free power every level leaves coins with even less to buy, which makes my #3 "nothing to spend on" stronger from level 30 on.

**N6. Narrative Critic #4 / Feasibility #5 (level-40 "Boss level" undefined) + player expectation.**
"Boss level" is a promise. If it turns out to be an ordinary hard level with a story card, players feel let down at the midpoint of chapter 2. Either deliver some visible boss presence on the board, or don't call it one anywhere players can see. Minor, but cheap to fix.

**N7. Business Analyst #1 (contaminated cohort) + my #1.**
Closed-test friends and recruited testers put up with lives walls far better than strangers from the store. If they're counted, the doc's lives-wall metric (quits within 2 sessions after running out) will under-report the problem. SD also notes that level 25 is in that metric even though finale fails cost no life, so one of its three data points measures nothing. The doc's only tool for spotting my #1 is therefore doubly weak.

### REVISIONS

**R1. #1 Lives lockout: BLOCKING → MAJOR.** My Round 1 count overstated fails. A recount by tier over levels 1–25 (7 intro, ~9 easy, ~6 medium, 2 hard, finale free) gives about 7–9 expected lost lives, not 8–10. I also left out three softeners: the 500 starting coins pay for 1–3 continues, the Hoof Tap's 3 free uses from level 11, and the free pre-level boosters at 16. All three lower real fails below the no-booster targets. SD's and BA's whole-MVP math shows lives don't create a week-long wall. What remains is a variance-driven lockout for roughly 5–25% of players at levels 15 and 20, depending on where calibration really lands, and a mechanic with no MVP purpose. That is MAJOR, not BLOCKING. My recommendation stands, now tied to C1's combined fix.

**R2. #2 No fragment progress display: stays MAJOR, higher confidence, and I now rank it as my top finding.** N2 shows the problem runs from the first fragment through to the MVP's last screen. Three colleagues found separate pieces of it without seeing the whole.

**R3. #3 No long-term goal in levels 1–25: stays MAJOR, slightly broader.** SD #4 and N5 show coins have nothing to buy for the whole MVP, not only before level 11. I'm keeping the finding's scope on the first session, but "coins as a reason to come back" has been ruled out across the game.

**R4. #4 Onboarding overload: stays MAJOR.** Two things are added: the warning in C3 against adding an early hero booster on top of the existing schedule, and N1's point that the Crane + special gap breaks a taught rule.

**R5. #5 No replay or story log: stays MINOR, with one amendment.** SD #2 and BA #1 show the 60 levels may run out before D7. Replaying won levels, which I kept out of scope, is the cheapest content extender, and it would also give players a place to practise combos. I'd now list it as a candidate fix for SD #2 rather than leaving it out of scope. That severity call belongs to SD.
