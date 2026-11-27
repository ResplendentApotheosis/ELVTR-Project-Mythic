# Production/Business Analyst — Round 1

## 1. The MVP scope is contradicted inside the document and has no fixed endpoint. Severity: BLOCKING

**Problem:** The Overview, the MVP decision table and the Level progression section all set the MVP at levels 1–60, with the Rat restored at 50 and an Ox tease in 51–60. The milestones section then says "The scope grows from 60 levels to the story-complete Act 1." Nothing in the document defines "Act 1". The word appears nowhere else, and the chapters are numbered 1–4 with no act structure. The 20-week plan and the roughly US$210 budget stay the same, and the week-18 milestone still reads "Levels 31–60". A solo developer who is still learning Godot (the week-3 milestone is "Godot basics") cannot absorb an open-ended scope increase on a fixed timeline and budget. This is the single sentence most likely to make the project slip.

**Source:** "## MVP milestones, budget & open questions": "The MVP keeps the 20-week plan and Option A budget ... The scope grows from 60 levels to the story-complete Act 1." This contradicts the Overview ("The MVP ships levels 1–60") and the Item / MVP decision table ("Levels: 1–60").

**Fix direction:** Remove the sentence, or define Act 1 as a level count and re-plan the weeks. Do not do both in the same document.

## 2. The MVP is designed around games that do not exist yet: Part 2, PvP and a shared Zodiac profile. Severity: MAJOR

**Problem:** One of the five design pillars ("Souls carry forward") and the pitch itself ("rewards ... carry into every future game in the Zodiac world") depend on Part 2 games and PvP. The same Overview table marks those as out of scope. The MVP also carries several pieces of cross-game plumbing that serve no purpose inside the MVP:
- Soul Dust is "stored for Part 2 hero upgrades".
- SaveService is "one player profile shared by every Zodiac game".
- The "Player profile (shared by every Zodiac game)" subsection is an empty heading.

Inside the MVP, fragments are load-bearing only up to level 50, because they drive the Rat restoration. From level 51 to 60, players collect Ox fragments and "first random fragments of other guardians" that can pay off only after the MVP ends (the Ox is restored around level 110). For an MVP whose stated goal is to "prove retention first", this is a franchise meta bolted onto a game that has not yet shown anyone wants to come back. A pillar should describe the game being shipped.

**Source:** Design pillars ("Souls carry forward ... Part 2 games and PvP"); Pitch; Out of scope ("The Great Race and other Part 2 ideas"); Soul fragments ("No waste ... Soul Dust, used for hero upgrades in Part 2"); Technical design (SaveService, empty Player profile heading); Story beats 51–60.

**Fix direction:** Demote "Souls carry forward" from a pillar to a post-MVP note. Keep the save schema extensible but out of the MVP's critical path.

## 3. No target audience, and no definition of what "prove retention" means. Severity: MAJOR

**Problem:**
- **Audience:** The document never names its target player (age range, match-3 experience, region, or why they would care about a Chinese-zodiac story). The chibi art, the folklore story and the "ASMR" sound direction could point at very different audiences.
- **Success test:** The business strategy is "None [monetization] in MVP; prove retention first", but no retention target is defined. The week-20 milestone is "Tracking day-1 return and level fail rates". That describes measuring, not a success condition. With no D1/D7 threshold, there is no way to decide whether to continue, pivot or stop, and so no trigger to "revisit" the budget.
- **Channel:** The first channel is web on itch.io plus Android. The itch.io audience skews toward indie and PC players, not mainstream casual match-3 players, so web retention data may say little about the intended market.

**Source:** Item / MVP decision table (Monetization, Platforms); Milestones week 20; Budget ("Revisit after live feedback"); no audience statement anywhere in the Overview.

**Fix direction:** Add one audience sentence, a numeric retention bar (for example, D1 and D7 targets on Android), and the decision that follows if the build misses it.

## 4. The market positioning is "Match Villains with a new skin", and the pitch claims a feel the budget cannot plausibly deliver. Severity: MAJOR

**Problem:** The pitch promises "Royal Match-grade feel". The Research basis says "we copy MV's measured rhythm and feel" and adopts MV's colour count, move ranges, obstacle cadence, hard-level rhythm and booster unlock levels almost one for one. The market-context note cites MV's US$25–36m in IAP revenue, then concedes "we copy design lessons, not its user-acquisition spend". That concession hides the problem: in a genre that is won by spending on user acquisition, the document never says how a US$210, ad-free, IAP-free game finds players at all. The stated differentiators are the zodiac theme, fairness fixes (fewer pop-ups, one continue) and the Paper Crane. Fairness fixes are worth having, but players do not discover a game because it lacks annoyances. Nothing states why a Royal Match or MV player would switch, or why a non-match-3 player would start.

**Source:** Pitch; "## Research basis" ("we copy MV's measured rhythm and feel"), the MV finding / Mythic decision table, and the market context paragraph; Budget (no marketing or UA line).

**Fix direction:** State one concrete differentiator and one acquisition channel. For example: the zodiac / Lunar New Year audience, timed to Chinese New Year with a community and social plan. Soften "Royal Match-grade" to a measurable feel target.

## 5. The MVP document carries post-MVP content, and the asset count does not match the chapter structure. Severity: MINOR

**Problem:**
- **Out-of-scope detail:** Much of the document specifies content outside levels 1–60, including:
  - obstacles debuting at 66/76/86/96
  - chapter 4
  - guardian powers at about 110/165/200
  - a fragment schedule out to level 201+
  - live-ops loops

  This is decorative for the MVP. It dilutes review attention and invites building systems early, such as the full 70/30 trail logic with a pity rule when MVP players will only ever see the Ox trail.
- **Asset count:** The art table says "Backgrounds: One per 10-level chapter", but chapters are 25 levels long elsewhere ("A new backdrop every chapter"). The MVP asset list budgets "6 backgrounds × 2 states", which matches 10-level chapters, not 2.4 chapters of 25. Either the art budget is about 2× too high, or the chapter definition is wrong.
- **Posters:** The asset list includes a poster at level 20, but the story table delivers level 20 as a "story card", not a poster.

**Source:** Board layers & obstacles (debuts 66–96); Soul fragments schedule (51–201+); Booster unlocks ("Post-MVP" row); Art & audio direction (Backgrounds row; Asset count line); Level progression ("A new backdrop every chapter"); Story beats (level 20).

**Fix direction:** Move post-60 content into an appendix or the Part 2 backlog. Reconcile the background count with the chapter length before art is commissioned in weeks 9–14.

## Round 2 — Cross-examination

### Conflicts

**A. Feasibility Lead #1's cut list would cut one of the few differentiators.** I agree with the BLOCKING call and with treating "Act 1" as the sentence that breaks the plan. Feasibility independently reached the same conclusion, so that finding is now confirmed by two lenses. But their candidate cuts are "the Crane-carry combo, OB09 hazard, the posters and the shared cross-game profile". Two of those are right and two are wrong from a positioning view:
- **Cut:** the shared profile (see Connection 2) and OB09. The Player Psychologist (#4) separately argues that OB09 is the most-hated MV obstacle and lands on the level-50 climax. Cutting it from the MVP removes a schedule risk and a churn risk together.
- **Keep:** the Paper Crane is one of only three differentiators the document names (see my #4), and it is the only one a player can see in a screenshot or a 15-second clip. Cut the Crane and the game really is MV with a zodiac skin. If a combo has to go, cut Crane + special rather than the Crane itself. Adversarial QA #4 shows Crane + special is also where the beam-crossing rules break.
- **Keep, but cheaper:** the posters at 25 and 50 are the story's marketing images. Keep those two. Drop the others in favour of story cards.

**B. The fixes proposed by Systems Designer #2 and Player Psychologist #3 add systems to a plan that cannot fit the ones it has.** Both colleagues are right that boosters run dry and coins have one use. Their fixes, though, are new features: a guardian-power "charge meter filled by matches" (Systems) and a "minimal forest-restoration bar" in levels 1–25 (Psychologist). The meta is still "Owner: you" and undesigned. Feasibility #1 shows weeks 4–9 already cannot hold the core. My position is to fix these gaps by reusing systems the document already has:
- **Coins:** give coins a booster price. That needs one table column and no new UI concept.
- **Levels 1–25:** move the first scripted Rat fragment earlier, rather than inventing a second meta. The fragment trail is already built, already load-bearing and already on the map.

A new restoration bar is exactly the decorative layer my Round 1 warned against.

**C. Narrative Critic #3 wants more villain faces and hard-level beats; the budget wants fewer.** Narrative is right that Pillar 4 ("a story beat on every hard level") is broken: 15, 35, 45 and 55 have nothing. But the fix is not more assets. The asset list budgets "the Nian and 2 of its forces", and Feasibility #1 already counts roughly 70+ assets for a solo artist pipeline. The business-safe fix is to rewrite the pillar to what the MVP actually delivers (beats on finales and every other hard level), or to make the missing beats text-only story cards that reuse existing portraits. An undelivered promise in a pillar is a production liability, not a reason to grow the art list.

**D. Adversarial QA #2 (reroll exploit) is MAJOR only because of a pillar I want demoted.** In an ad-free, IAP-free MVP, a player who quits and re-enters to reroll a fragment harms no one. They just spend lives. The exploit becomes a business problem only under "Souls carry forward". Fragments farmed in a free game would then carry into future PvP and monetised Part 2 games as an unbalanced currency. So QA's severity depends on my #2. If the pillar stays, QA #2 is right and is arguably understated. If the pillar is demoted and the MVP saves locally, it drops to MINOR for this build.

### Connections

**1. The retention test cannot produce a usable answer (my #3 + Psychologist #1 + Systems #3 + Feasibility #5).** Three separate findings break the MVP's only stated purpose:
- **The data is confounded.** Psychologist and Systems compute that 12–24% of players exhaust all lives on the level-25 finale, which also carries the temple reveal and is plausibly within session 1 or 2. Day-1 return is therefore measuring a lives wall, not whether players like the game. With no D1 target (my #3), the team cannot tell "the game is weak" apart from "level 25 is mistuned".
- **The data may come from the wrong audience.** Feasibility #5 shows the week-20 Android public launch ignores Google Play's 14-day closed-test gate for new accounts. If Android slips, the only live data comes from itch.io web, which is the channel I flagged as the wrong audience for casual match-3.
- **The test has no defined end.** The build "ends" at 60 on a cliffhanger whose content Narrative #4 shows is undefined.

Put together, the MVP can hit every milestone and still return no decision.

**2. The cross-game pillar is unbuildable, broken and harmful inside the MVP (my #2 + Feasibility #2 + Systems #4 + Psychologist #3).** On its own, my #2 said the pillar is premature. With colleagues' findings added:
- **Unbuildable:** there is no backend, auth or hosting in the budget, and separate Android apps and itch.io pages cannot share local saves (Feasibility #2).
- **Broken:** the fragment arithmetic does not reconcile; Dog is not restored by 200 (Systems #4, QA #2).
- **Harmful inside the MVP:** players read off-trail fragments and Soul Dust as filler (Psychologist #3).

A pillar that is unfunded, mathematically inconsistent and felt as filler by players is the clearest decorative feature in the document. That supports an upgrade (see Revisions).

**3. The theme is the main differentiator, but the first 16 levels don't show it (my #4 + Systems #5 + Narrative #2 + Narrative #4).** My #4 found the zodiac/folklore theme carries most of the positioning. Systems and Narrative both show that the rescue mechanic ("Every board is a rescue") does not exist until level 17. Narrative #4 shows the four protagonists have no names, personalities or designs. So the first-session player and any store screenshot from levels 1–16 see a generic match-3 board with unnamed characters. A theme-led game with no named heroes and no visible rescue has nothing to put on its store page and nothing for a Lunar New Year community push to rally around. Defining the protagonists is a marketing prerequisite, not only a narrative one.

**4. "Fairness" is a claimed differentiator that the document breaks at its showcase moments (my #4 + Psychologist #1 + Psychologist #5).** "Fewer pop-ups" and "fixes lives lock-out" are two of the fairness fixes the positioning relies on. Psychologist #5 counts about 6 sequential interruptions after the level-25 win. Psychologist #1 shows the lock-out returns on exactly the finales. The two moments a reviewer, streamer or word-of-mouth player is most likely to describe are where the differentiator visibly fails.

**5. Economy with no sinks gives no data for the eventual business model (my #3 + Systems #2).** Systems estimates about 2,900 coins by level 60 with the 300-coin continue as the only spend. The plan is "prove retention first, revisit monetisation later". But an economy with no sinks produces no signal on how players value boosters or continues. When IAP is added, it will be added to a different economy than the one whose retention was measured. Even without monetisation, the MVP should include at least one coin sink so that the later monetisation decision rests on observed behaviour.

### Revisions

- **#3 upgraded MAJOR → BLOCKING.** On my lens alone, the missing audience and retention bar were a planning gap. Combined with the lives wall at 25 (Psychologist #1, Systems #3) and the Google Play gate (Feasibility #5), the MVP's single stated goal is unmeasurable as designed. The fix is cheap and must come before week 9:
  - a D1/D7 bar on Android;
  - an unlimited-lives window on reaching a finale;
  - the closed test started by week 17, or a statement that web is a soft launch only.
- **#2 kept at MAJOR, strengthened.** Feasibility #2 and Systems #4 turn "premature" into "unfunded and inconsistent". It stays MAJOR rather than BLOCKING because the MVP can ship with local saves. The cost of the pillar is distraction and broken promises, not a hard stop. The fix is now concrete:
  - demote the pillar;
  - local, versioned save schema;
  - hide Soul Dust and off-trail random fragments in the MVP, which Psychologist #3 also recommends.
- **#5 partly withdrawn and corrected.** I wrote that MVP players "will only ever see the Ox trail", implying the 70/30 trail logic was post-MVP decoration. That is wrong. Random 30% drops are live in levels 51–60, and QA #2 shows they already create exploit and edge-case work inside the MVP. The finding stands as "the system ships in the MVP but its payoff does not", which folds into #2. The background-count part is now independently confirmed by Narrative #3, Feasibility #4 and QA #5. It stays MINOR on cost, because Scenario is a subscription, not a per-asset fee. It should be fixed before week 9 because it doubles Krita cleanup time.
- **#1 unchanged (BLOCKING),** now corroborated by Feasibility #1.
- **#4 unchanged (MAJOR),** but the fix is now sharper. The differentiator has to be visible by level 5 (an early rescue and named heroes), not only stated in the pitch.
