# Zodiac Forest: open rules questions

Questions the GDD (`docs/gdd/zodiac-forest-gdd-final.md`) doesn't answer, or where two parts disagree. Each lists 2 options; **the owner decides**. When answered, the owner writes the answer under "Decision" (or updates the GDD), and the Rules Keeper turns it into an IR rule.

Status: `OPEN` / `ANSWERED`. "Blocks" names the rules whose tests can't be written until it is answered.

**Summary (27 Nov 2026, after GDD commit a94a7e4):** OQ-01 to OQ-38 ANSWERED, all now in GDD › Rules clarifications (OQ-23 to OQ-38 were first given in chat; the owner has since written them into the GDD, so quotes below marked "Owner decision (chat …)" now read "GDD › Rules clarifications › OQ-xx" with the same meaning).

**Update (27 Nov 2026, later):** OQ-39 to OQ-50 ANSWERED by the owner in chat (not yet in the GDD; cited as "Owner decision, chat 27 Nov 2026 › OQ-xx"). OQ-46, OQ-47, OQ-48 and OQ-50 are trial decisions: revisit after playtest. OPEN: OQ-51 (continue offer after a quit) and OQ-52 to OQ-55 (parts the new answers don't settle). GDD lines to add for OQ-39 to OQ-50: see "GDD text to update (round 2)" at the end.

**Update (27 Nov 2026, round 3):** Owner in chat: "Q39 and Q40 is correct. Q51: A, Q52: A, Q53: A, Q54: A, Q55: A, Q56:A, Q57:A, Q58:A". OQ-39's "2nd–5th cost 500" reading is confirmed; OQ-40 confirmed; OQ-51 to OQ-58 ANSWERED (Option A each), cited as "Owner decision, chat 27 Nov 2026 › OQ-xx". OPEN: OQ-59 (lantern shrine parts OQ-55 A doesn't settle) and OQ-60 (finale Rocket parts OQ-58 A doesn't settle). GDD lines to add: see "GDD text to update (round 3)" at the end.

**Update (27 Nov 2026, round 4):** Owner in chat: "59:A, 60:A, 61: A". OQ-59, OQ-60 and OQ-61 ANSWERED (Option A each, every sub-part settled), cited as "Owner decision, chat 27 Nov 2026 › OQ-xx". No question is open. GDD lines to add: see "GDD text to update (round 4)" at the end.

**Update (27 Nov 2026, round 5, GoalTracker build):** OQ-62 to OQ-70 OPEN: goal units (62), the last move (63), when win/fail is checked (64), fragment goal entry (65), dew targets and seeds (66), boosters and moves (67), colour goals (68), goal counts on easy/medium levels (69), lives after a continue (70). They block parts of IR-56, IR-57, IR-59, IR-60 (new) and IR-49.

**Update (28 Nov 2026, round 6, GoalTracker answers):** Owner in chat: OQ-62 A (trial, "for now"), 63 A, 64 B (trial, "for now"), 65 B ("Basically fragment is part of the goal and must be completed to pass"), 67 A, 68 A, 69 A, 70 A; cited as "Owner decision, chat 28 Nov 2026 › OQ-xx". OQ-62 and OQ-64 are trial decisions: revisit after playtest. OPEN: OQ-66 (the owner asked what seed cells are; see the note under OQ-66), OQ-71 (which cocoon or drop item holds the fragment in the level file) and OQ-72 (how much of the winning step still happens). Also recorded: Nian's Eye (OB09) is not in levels 1–50 (owner decision, matches the GDD's level 61). GDD and brief lines to add: see "GDD and brief text to update (round 5, owner only)" at the end.

**Update (28 Nov 2026, LevelLoader check):** OQ-62 to OQ-74 are all ANSWERED (see each entry). New and OPEN: OQ-75 (OB07/OB03 debut levels: GDD vs plan), OQ-76 (same pieces on a retry?), OQ-77 (shrine colours in the file), OQ-78 (OB08 in the file and its layers), OQ-79 (when and where drop items appear), OQ-80 (`fixed_tiles` names and colours), OQ-81 (smaller schema gaps), OQ-82 (pre-level booster and streak-chest placement). None blocks building LevelLoader's core; OQ-77, OQ-78 and OQ-79 block loading OB05, OB08 and OB11.

**Update (28 Nov 2026, SaveService check):** OQ-75 to OQ-88 are all ANSWERED. New and OPEN: OQ-89 (lives refill clock and a new player's lives), OQ-90 (starting with 0 lives; finales), OQ-91 (unlimited lives after a finale), OQ-92 (app closed or killed mid-level), OQ-93 (booster unlock moment and paid uses), OQ-94 (win streak after the chest), OQ-95 (what the 20/50 milestones give), OQ-96 (story beats on a retry). None blocks SaveService's core (save/load, coins, lives lost, fragments, progress, attempt log); they block parts of IR-81 to IR-84.

**Update (28 Nov 2026, round 9, SaveService answers):** Owner in chat: "Yes, all of them" (89 A, 90 B, 91 A, 92 A, 93 A all parts, 94 A all parts, 95 A, 96 A), plus two confirmed readings now owner decisions: levels are played in order with no skipping (IR-79); no purchase of any kind without enough coins, coins never below 0 (IR-80). Cited as "Owner decision, chat 28 Nov 2026 › OQ-xx". No question is open. Minor edge cases left are marked "Not yet specified" in IR-38, IR-81, IR-83, IR-84 and IR-87; none blocks SaveService. GDD lines to add: see "GDD text to update (round 9, owner only)" at the end.

**Update (28 Nov 2026, board build failure):** OQ-97 opened, then ANSWERED by the owner in chat (Option A), cited as "Owner decision, chat 28 Nov 2026 › OQ-97". Now in IR-88. No question is open.

---

### OQ-01 · Bamboo Rocket: row or column? — ANSWERED
Decision: GDD › Rules clarifications › OQ-01: a horizontal 4 makes a row Rocket, a vertical 4 a column Rocket; the icon shows the direction. Now in IR-05, IR-16. (Rockets not made from a line: OQ-24.)

GDD says: Special pieces › "4 in a line | Bamboo Rocket | Clears its full row or column". Nothing says which one a given Rocket clears.
- Option A: The direction comes from the match: a horizontal 4 makes a Rocket that clears its column, a vertical 4 one that clears its row (or the reverse; owner picks).
- Option B: The direction comes from the player's swap (horizontal swap → row Rocket, vertical swap → column Rocket); cascade-made Rockets follow the match direction.
Blocks: IR-05, IR-16, IR-25.

### OQ-02 · Which cell does a new special appear on? — ANSWERED
Decision: GDD › Rules clarifications › OQ-02: the swap's target cell; in cascades the lowest then left-most cell (the crossing cell for an L or T). Now in IR-40. (Player match not containing the target cell: OQ-25.)

GDD says: Special pieces table gives the shape that makes each special, but not where the special is placed.
- Option A: On the cell the player moved into with the swap; for matches made by cascades, on a fixed cell of the shape (e.g. the lowest, then leftmost).
- Option B: Always on a fixed cell of the shape, whoever made it.
Blocks: IR-04 to IR-07.

### OQ-03 · Special swapped with a plain piece that makes no match — ANSWERED
Decision: GDD › Rules clarifications › OQ-03: the special fires and the swap costs a move; snap-back only for two plain pieces; Orb + plain piece clears that colour. Now in IR-01, IR-18, IR-39. (Where the special fires from: OQ-26.)

Two parts of the GDD could be read against each other: "a swap that makes no match snaps back" vs "Specials fire when matched, swapped or tapped".
- Option A: Any swap of a Rocket, Firecracker or Crane with an adjacent plain piece is valid, uses a move, and the special fires.
- Option B: Such a swap snaps back unless it also makes a match.
Blocks: IR-01, IR-21.

### OQ-04 · Is a special hit by another special set off (chain)? — ANSWERED
Decision: GDD › Rules clarifications › OQ-04: it fires too, after the first special finishes. Now in IR-41, IR-21. (Details: OQ-27.)

- Option A: A special inside another special's area fires too (a chain), after the first one finishes.
- Option B: A special inside another special's area is simply removed without firing.
Blocks: IR-21, IR-25.

### OQ-05 · Do cascade matches make specials? — ANSWERED
Decision: GDD › Rules clarifications › OQ-05: yes, by the same rules as player matches. Now in IR-42, IR-32.

- Option A: Yes: any match, player-made or cascade, makes a special by the same shape rules.
- Option B: No: only the player's swap can make a special.
Blocks: IR-32.

### OQ-06 · Shapes the table doesn't name (6+ in a line, plus/cross) — ANSWERED
Decision: GDD › Rules clarifications › OQ-06: 6+ in a line makes a Jade Orb; mixed shapes follow shape priority. Now in IR-07, IR-08, IR-06. (The "+" shape is still not named: OQ-28.)

- Option A: Use the strongest shape the match contains: any line of 5+ is a Jade Orb; a "+" or bigger L/T counts as an L/T.
- Option B: Only the exact named shapes make a special.
Blocks: IR-06, IR-07 edge cases.

### OQ-07 · One swap makes two separate matches — ANSWERED
Decision: GDD › Rules clarifications › OQ-07: both resolve and each can make its own special. Now in IR-43. (Placement of the second special: OQ-25.)

- Option A: Each match is judged on its own; each can make its own special.
- Option B: Only one special per swap.
Blocks: two-match swap tests.

### OQ-08 · How many hits does one adjacent match give? — ANSWERED
Decision: GDD › Rules clarifications › OQ-08: one hit to that obstacle; only up, down, left and right count as "next to". Now in IR-14, IR-13.

- Option A: One hit per match per obstacle, however many pieces or cells touch; orthogonal only.
- Option B: One hit per touching piece (multi-cell capped at one); orthogonal only.
Blocks: IR-13, IR-14.

### OQ-09 · A special over a piece that sits on an underlay, or under an overlay — ANSWERED
Decision: GDD › Rules clarifications › OQ-09: pieces are not obstacle layers; a special clears the piece and hits the top obstacle layer (underlay if no overlay or blocker); a Jade Orb covers every cell whose piece it clears. Now in IR-09, IR-15, IR-18. (Follow-ons: OQ-29 covered pieces, OQ-31 dew, OQ-36 boosters.)

- Option A: Literal: the special hits the top layer only.
- Option B: A piece cleared by a special also gives the underlay one hit.
Blocks: IR-09, IR-15, IR-18.

### OQ-10 · Do pieces cleared by a special hit obstacles next to them? — ANSWERED
Decision: GDD › Rules clarifications › OQ-10: no; only matches hit neighbours. Now in IR-44, IR-14.

- Option A: No: a special only hits the cells it covers.
- Option B: Yes: each obstacle next to a cleared cell takes one hit.
Blocks: IR-14 with specials.

### OQ-11 · Firecracker: when and where is the second blast? — ANSWERED
Decision: GDD › Rules clarifications › OQ-11: same centre cell, after pieces have fallen; an obstacle hit by the first blast takes no hit from the second. Now in IR-17, IR-12. (What happens between the blasts: OQ-32.)

- Option A: Both blasts straight away, before pieces fall.
- Option B: The second blast after pieces fall, on the same 3×3.
Blocks: IR-17, IR-24.

### OQ-12 · Is a combo one "special" for the one-hit rules? — ANSWERED
Decision: GDD › Rules clarifications › OQ-12: a combo counts as one special. Now in IR-45, IR-10, IR-22 to IR-25.

- Option A: A combo counts as one special.
- Option B: Each special in the combo counts on its own.
Blocks: IR-10, IR-22, IR-23, IR-24.

### OQ-13 · Where is a combo centred? — ANSWERED
Decision: GDD › Rules clarifications › OQ-13: on the cell the player moved the special into. Now in IR-46, IR-22 to IR-24.

- Option A: The swap's target cell.
- Option B: The swap's start cell.
Blocks: IR-22, IR-23, IR-24.

### OQ-14 · "Most common colour" tie — ANSWERED
Decision: GDD › Rules clarifications › OQ-14: fixed order red, yellow, blue, green. Now in IR-47, IR-19, IR-25, IR-27. (Which pieces are counted: OQ-33.)

- Option A: Fixed order (red, yellow, blue, green); only plain pieces counted.
- Option B: Seeded random; only plain pieces counted.
Blocks: IR-19, IR-25 tie cases.

### OQ-15 · Jade Orb swapped with a Crane: which colour does the Orb clear? — ANSWERED
Decision: GDD › Rules clarifications › OQ-15: the most common colour (as for a tap), then the Crane flies. Now in IR-27.

- Option A: As if tapped: most common colour.
- Option B: The Crane's colour.
Blocks: IR-27 Orb case.

### OQ-16 · What does the Paper Crane do when it lands? — ANSWERED
Decision: GDD › Rules clarifications › OQ-16: one hit to the target cell, or collects the fragment or drop item there; it also clears its own starting cell on take-off. Now in IR-48, IR-30. (Take-off and underlays: OQ-34.)

- Option A: One hit on the target cell only (collect drop items / fragments).
- Option B: Target cell plus its 4 neighbours.
Blocks: IR-20, IR-27, IR-30.

### OQ-17 · Crane target: goal type or single obstacle, and ties — ANSWERED
Decision: GDD › Rules clarifications › OQ-17: one obstacle cell of the goal with the fewest hits left (fragment first); ties closest, then top-most, then left-most; no goal → nearest obstacle; none → seeded random piece. Now in IR-49, IR-20. (Distance measure and non-hit goals: OQ-34.)

- Option A: Single obstacle with fewest hits; reading-order ties; random fallback.
- Option B: Goal line with fewest total hits, nearest instance; Crane clears its own cell if no goal.
Blocks: IR-20.

### OQ-18 · Do specials have a colour and match like pieces? — ANSWERED
Decision: GDD › Rules clarifications › OQ-18: Rockets, Firecrackers and Cranes keep their colour and match like normal pieces; the Jade Orb has no colour. Now in IR-50, IR-21.

- Option A: Rocket, Firecracker, Crane keep their colour; the Orb has none.
- Option B: No special has a colour.
Blocks: IR-21.

### OQ-19 · Gravity around blockers and gaps — ANSWERED
Decision: GDD › Rules clarifications › OQ-19: straight down; diagonal slides where a blocker stops filling from above; refill at the top of each column or at spawner cells. Now in IR-51, IR-32. (Details: OQ-35.)

- Option A: Straight down only.
- Option B: Straight down, then diagonal slides.
Blocks: IR-32 with blockers or gaps.

### OQ-20 · Drop items: "bottom row" or "exit columns"? — ANSWERED
Decision: GDD › Rules clarifications › OQ-20: on reaching the bottom playable cell of their column; if the level lists `exit_columns`, only those columns collect. Now in IR-30.

- Option A: Any column's lowest playable cell.
- Option B: Only listed exit columns.
Blocks: IR-30.

### OQ-21 · What can be swapped? — ANSWERED
Decision: GDD › Rules clarifications › OQ-21: any two orthogonally adjacent pieces, including specials and drop items; not obstacles, cocooned fragments or empty cells. Now in IR-52. (Covered pieces: OQ-29; drop item no-match swaps: OQ-30.)

- Option A: Orthogonal; plain pieces and uncovered specials only.
- Option B: Orthogonal; drop items swappable too.
Blocks: IR-01 negative swap tests.

### OQ-22 · What does the free auto-shuffle move? — ANSWERED
Decision: GDD › Rules clarifications › OQ-22: only plain pieces and specials; must leave at least one valid move and no ready-made matches. Now in IR-33.

- Option A: Only plain pieces.
- Option B: Plain pieces and specials.
Blocks: IR-33 details.

### OQ-23 · Continue offer: what is "can no longer be reached"? — ANSWERED
Decision: GDD › Rules clarifications › OQ-23 (first given in chat 27 Nov 2026): "Always after a fail, whether or not the goals can still be reached, at least twice per attempt". Neither option: the offer is never hidden. Interaction rules, Fail flow, Meta › Continue and the competitor table now say the same. Now in IR-37. (Unsettled parts: OQ-39, OQ-51.)

GDD says: Interaction rules › "Continue offer: Not shown when the remaining goals can no longer be reached". Meta › "+5 moves for 300 coins".
- Option A: Hidden only when a goal is impossible at any number of moves (e.g. not enough goal items left on the board or still to spawn).
- Option B: Hidden when the remaining goals clearly can't be done in 5 more moves (e.g. remaining hits needed > a set number per move, tuned with the bot).
Blocks: IR-37 hidden-offer test (GoalTracker, not MatchResolver).

---

## New questions found while applying OQ-01 to OQ-22 (27 Nov 2026)

### OQ-24 · Direction of Rockets that aren't made from a line — ANSWERED
Decision: GDD › Rules clarifications › OQ-24 (Option A; first given in chat 27 Nov 2026): Rockets made by Jade Orb + Rocket copy the direction of the Rocket that was swapped with the Orb. Now in IR-16, IR-25, IR-05. The option left the win-finale Rockets' direction for the owner to pick: still open as OQ-40.

GDD says: Rules clarifications › OQ-01 "Fires along the line it was made from: a horizontal 4 clears its row, a vertical 4 clears its column". Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires". Core gameplay › "Leftover moves become Bamboo Rockets". Rockets made by Jade Orb + Rocket, or in the win finale, are not made from a line.
- Option A: They copy the direction of the Rocket that was swapped with the Orb (finale Rockets: the owner picks one fixed direction).
- Option B: Each one's direction is picked by the level's seeded random number generator (row or column, 50/50), so bot runs stay repeatable.
Blocks: IR-16, IR-25 (which cells the converted Rockets clear).

### OQ-25 · Where does a special appear if the player's match doesn't include the target cell? — ANSWERED
Decision: GDD › Rules clarifications › OQ-25 (Option B; first given in chat 27 Nov 2026): that special uses the cascade placement: the lowest, then left-most cell of its match (the crossing cell for an L, T or "+"). Now in IR-40, IR-43.

GDD says: Rules clarifications › OQ-02 "On the cell the player moved into"; OQ-07 "Both resolve, and each can make its own special". In a two-match swap (IR-43) the second match runs through the swap's start cell, not the cell the player moved into.
- Option A: On the swap's start cell (the other swapped cell, which that match always contains).
- Option B: Use the cascade placement: the lowest, then left-most cell of that match (crossing cell for an L or T).
Blocks: IR-40, IR-43 (position of the second special only).

### OQ-26 · Swapped specials that don't combo: firing cell and order with matches — ANSWERED
Decision: GDD › Rules clarifications › OQ-26 (Option A; first given in chat 27 Nov 2026): the swap completes and each special fires from the cell it sits in after the swap; any match the swap makes resolves first (clears, neighbour hits, new specials), then the special fires, and it may set off a special that match has just made. Now in IR-39, IR-21, IR-27, IR-50. (Whether pieces fall between the match and the special firing: OQ-44.)

GDD says: Rules clarifications › OQ-03 "The special fires and the swap costs a move"; OQ-13 gives a centre only for combos ("The cell the player moved the special into"); OQ-18 specials "match like normal pieces". Not covered: (a) after a special + plain swap (or Crane + special swap), does the special fire from the cell it now sits in, or from the swap's target cell? It matters for which row/column a Rocket clears and where a Firecracker blasts. (b) When a swap fires a special and also makes a match, or a match includes a coloured special, which happens first, and can the special hit a special that same match has just created?
- Option A: The swap completes and each special fires from the cell it sits in after the swap; matches made by the swap resolve first (clears, neighbour hits, new specials), then the special fires, and it may set off (IR-41) a special just made.
- Option B: The special fires from the swap's target cell (as for combos); it fires first, then matches resolve, and a special made by that match is placed afterwards and is never hit by it.
Blocks: IR-39, IR-27 (firing cell), IR-21, IR-50 (order).

### OQ-27 · Chain details — ANSWERED
Decision: GDD › Rules clarifications › OQ-27 and the amended OQ-04 row (Option B; first given in chat 27 Nov 2026): (a) set-off specials fire lowest first, then left-most; (b) a set-off special is lifted off the board when hit and fires from that cell after the fall; (c) a set-off Jade Orb is removed without doing anything; (d) Jade Orb + Jade Orb clears other specials without firing them. Now in IR-41, IR-25 (firing order of converted specials), IR-26, IR-19, IR-21. (Whether cascades resolve before set-off specials fire: OQ-44.)

GDD says: Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes"; OQ-11 the Firecracker's second blast comes "after pieces have fallen"; Interaction rules › Jade Orb + Jade Orb "Clears the whole board … and hits every obstacle once". Not covered: (a) the order when one special sets off several; (b) a special hit by a Firecracker's first blast waits until after the second blast; is it removed and refilled over, or does it stay put through the fall, and which cell does it fire from; (c) what a set-off Jade Orb clears; (d) whether specials cleared by Jade Orb + Jade Orb fire (which would add hits beyond "hits every obstacle once").
- Option A: Set-off specials fire in the order they were hit (same moment: top-most, then left-most); a set-off special stays in its cell and doesn't fall until it fires; a set-off Orb acts as if tapped (IR-19); specials cleared by Orb + Orb fire too.
- Option B: Set-off specials fire lowest, then left-most first; a set-off special is lifted off the board when hit and fires from that cell after the fall; a set-off Orb is removed without effect; Orb + Orb clears other specials without firing them.
Blocks: IR-41 (multi-chain and Firecracker-chain tests), IR-25 (firing order), IR-26 (specials on the board).

### OQ-28 · The "+" shape — ANSWERED
Decision: GDD › Rules clarifications › OQ-28 (Option A; first given in chat 27 Nov 2026): a "+" counts as an L/T and makes a Firecracker (on the crossing cell in cascades). Now in IR-06, IR-40.

GDD says: Special pieces › "L or T shape (5) | Firecracker"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule". A "+" (a line of 3 and a line of 3 crossing in the middle of both) is neither an L nor a T and contains no 4-line or 2×2.
- Option A: A "+" counts as an L/T and makes a Firecracker (crossing cell in cascades).
- Option B: A "+" makes no special; its 5 pieces just clear.
Blocks: IR-06 ("+" test only).

### OQ-29 · Pieces under an overlay (creep moss, shutters) — ANSWERED
Decision: GDD › Rules clarifications › OQ-29, with OQ-19 and OQ-21 amended (Option A; first given in chat 27 Nov 2026): a covered piece is locked: it can't be swapped and doesn't fall, but it can be part of a match; a cell emptied under a surviving overlay refills by normal falling. Now in IR-54 (new), IR-52, IR-51, IR-09. (Not settled by the option: what a match through a covered piece does to the piece and layers, the shuffle, and filling the cell below a locked piece: OQ-41.)

GDD says: Rules clarifications › OQ-09 "A special clears the piece and gives one hit to the top obstacle layer in that cell"; OQ-21 lists what can be swapped but not covered pieces; Cell layer model › "3 · Overlay … Cleared by Adjacent matches". Read literally, a special clears a piece under moss hp 2 and leaves the moss (hp 1) over an empty cell. Not covered: can a covered piece be swapped, fall, or be part of a match; and does an empty cell under a surviving overlay refill?
- Option A: A covered piece is locked: it can't be swapped and doesn't fall, but it can be part of a match; an emptied cell under a surviving overlay refills by normal falling.
- Option B: A covered cell is inert until its overlay is gone: its piece can't be swapped, matched or fall; an emptied cell under a surviving overlay stays empty and pieces slide past it like a blocker.
Blocks: IR-09 (overlay hp ≥ 2), IR-52 (covered pieces), IR-51 (gravity with overlays).

### OQ-30 · Drop item swaps that make no match, or with a special — ANSWERED
Decision: GDD › Rules clarifications › OQ-30, with OQ-03 amended (Option A; first given in chat 27 Nov 2026): a drop item swap that makes no match snaps back (no move used), like two plain pieces; a Rocket, Firecracker or Crane swapped with a drop item fires as with a plain piece; a Jade Orb swapped with a drop item acts as an Orb tap. Now in IR-01, IR-39, IR-18, IR-52.

GDD says: Rules clarifications › OQ-21 drop items can be swapped; OQ-03 "Snap-back applies only to two plain pieces"; "A Jade Orb swapped with a plain piece clears that piece's colour". Read literally, a drop item + plain piece swap with no match would not snap back and would cost a move. A drop item has no colour, so Orb + drop item is undefined, and Rocket/Firecracker/Crane + drop item isn't covered by "special swapped with a plain piece".
- Option A: A drop item swap with no match snaps back (like two plain pieces); a special swapped with a drop item fires as with a plain piece (IR-39); Orb + drop item acts as an Orb tap.
- Option B: Any accepted drop item swap uses a move (literal reading); swaps between a special and a drop item are refused.
Blocks: IR-52 (drop item swap tests), IR-01, IR-18.

### OQ-31 · Healing dew: what does a hit or a match on dew do? — ANSWERED
Decision: GDD › Rules clarifications › OQ-31 (Option A; first given in chat 27 Nov 2026): when a match or special clears a piece on a dew cell, every cell cleared by that same match or special gets dew; a Crane landing on an uncovered target cell gives it dew. Now in IR-53 (new), IR-15, IR-48. (Cells in a special's area that held no piece: OQ-46.)

GDD says: Obstacle set › OB04 "Matches made on dew spread it; cover the target cells"; Rules clarifications › OQ-09 "the underlay (goo or dew) takes the hit"; Interaction rules › Crane "Dew goal: an uncovered target cell". Where dew spreads to, and what "a hit" on dew means, aren't given.
- Option A: When a match or special clears a piece on a dew cell, every cell cleared by that same match or special gets dew; a Crane landing on an uncovered target cell gives it dew.
- Option B: When a dew cell takes a hit (match on top or special), dew spreads to its 4 orthogonal neighbours; a Crane landing on an uncovered target cell gives it dew.
Blocks: IR-09, IR-15, IR-48 (dew cases), and the OB04 obstacle module.

### OQ-32 · What happens between the Firecracker's two blasts? — ANSWERED
Decision: GDD › Rules clarifications › OQ-32 (Option B; first given in chat 27 Nov 2026): after the first blast, pieces fall, new pieces refill and all cascade matches resolve fully; then the second blast; Firecracker + Firecracker uses the same timing. Now in IR-17, IR-24.

GDD says: Rules clarifications › OQ-11 "Hits the same centre cell after pieces have fallen"; Combos › "Firecracker + Firecracker | 5×5 double blast". Not covered: do new pieces drop in from the top before the second blast, do matches formed by that fall resolve before the second blast, and does the 5×5 combo follow the same timing?
- Option A: Fall and refill, then the second blast; matches formed by the fall wait until after the second blast; Firecracker + Firecracker uses the same timing.
- Option B: Fall, refill and all cascades resolve fully, then the second blast; Firecracker + Firecracker uses the same timing.
Blocks: IR-17 (tests near the top rows or where a match forms between blasts), IR-24 (piece-count tests).

### OQ-33 · Which pieces count as "of a colour" for the Jade Orb? — ANSWERED
Decision: GDD › Rules clarifications › OQ-33, with the Jade Orb row of Special pieces amended (Option A; first given in chat 27 Nov 2026): only plain pieces count toward "most common colour" and only plain pieces are cleared; coloured specials (Rockets, Firecrackers, Cranes) are left alone. Now in IR-18, IR-19, IR-25, IR-47. (Option A doesn't say whether plain pieces under an overlay count: OQ-42.)

GDD says: Special pieces › Orb "Clears every piece of the colour it's swapped with"; Interaction rules › "most common colour on the board"; Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces". Not covered: whether coloured specials (and pieces under an overlay) count toward the most common colour, and whether the Orb clears (and so sets off) coloured specials of that colour.
- Option A: Only plain pieces count and are cleared; coloured specials are left alone.
- Option B: Every piece with that colour counts and is cleared, including coloured specials, which then fire as a chain (IR-41); covered pieces count too.
Blocks: IR-18, IR-19, IR-25, IR-47 (boards that hold coloured specials or covered pieces).

### OQ-34 · Paper Crane details — ANSWERED
Decision: GDD › Rules clarifications › OQ-34 (Option B; first given in chat 27 Nov 2026): (a) "closest" = straight-line distance; (b) hits left: dew = uncovered target cells left, lantern shrine = pieces still needed, drop items = items still to collect; (c) a shrine landing counts as the colour the shrine needs most of; (d) take-off counts as a special covering the Crane's own cell (the top obstacle layer there, e.g. goo underneath, takes one hit); (e) in Crane + Crane, the Crane the player dragged flies first. Now in IR-49, IR-48, IR-27. (A shrine needing two colours equally: OQ-43.)

GDD says: Rules clarifications › OQ-16 "It also clears its own starting cell when it takes off"; OQ-17 "the goal with the fewest hits left … Ties: closest to the Crane"; Interaction rules › "Dew goal: an uncovered target cell. Lantern shrine: counts as one piece of a colour it still needs"; "Crane swapped with another special … the other special fires first". Not covered: (a) how "closest" is measured; (b) how "hits left" is counted for dew, lantern-shrine and drop-item goals; (c) which colour a shrine landing counts as if the shrine still needs several; (d) whether take-off gives an underlay under the Crane a hit; (e) in Crane + Crane, which Crane is "the other special".
- Option A: (a) Steps along rows and columns (|dx| + |dy|); (b) dew = uncovered target cells left, shrine = pieces still needed, drop items = items still to collect; (c) the first needed colour in the order red, yellow, blue, green; (d) take-off clears the Crane only, no hit; (e) the Crane the player did not drag fires first.
- Option B: (a) Straight-line distance; (b) same as A; (c) the colour the shrine needs most of; (d) take-off counts as a special covering that cell (IR-09: underlay hit); (e) the dragged Crane fires first.
Blocks: IR-49 (distance, non-hit goals, shrine), IR-48 (take-off), IR-27 (Crane + Crane).

### OQ-35 · Gravity details — ANSWERED
Decision: GDD › Rules clarifications › OQ-35 (Option A; first given in chat 27 Nov 2026): (a) straight falls first, then diagonal slides, trying the upper-left before the upper-right; (b) every column refills at its top playable cell, and spawners add extra entry points; (c) a column whose top cell is not playable gets new pieces at its top playable cell. Now in IR-51. (Columns with a non-playable cell in the middle: OQ-45.)

GDD says: Rules clarifications › OQ-19 "a piece may slide in diagonally. New pieces drop in at the top of each column, or at spawner cells where the level has them". Not covered: (a) which diagonal is tried first (from the upper-left or the upper-right) and whether slides happen only after all straight falls; (b) on a level with spawners, do columns without a spawner still refill from the top; (c) where new pieces enter a column whose top cell is not playable.
- Option A: (a) Straight falls first, then slides, upper-left before upper-right; (b) yes, every column refills at its top playable cell and spawners add extra entry points; (c) at the column's top playable cell.
- Option B: (a) Straight falls first, then slides, alternating left and right column by column; (b) no, on spawner levels only spawner cells create pieces; (c) a column whose top cell is not playable gets no new pieces except by sliding.
Blocks: IR-51 (slide direction, spawner and gap tests).

### OQ-36 · Hoof Tap and other boosters on a cell with a piece and an obstacle layer — ANSWERED
Decision: GDD › Rules clarifications › OQ-36, with Meta & economy › Hoof Tap rewritten (Option A; first given in chat 27 Nov 2026): every booster (Hoof Tap included) follows IR-09 exactly: it clears the piece and gives the top obstacle layer one hit. Now in IR-36, IR-09.

Two parts of the GDD now read against each other:
- Meta & economy › Hoof Tap "Removes one single tile of the player's choice (a piece, or the top layer of one cell)"; Interaction rules › boosters "Like a special: one hit per cell, top layer only".
- Rules clarifications › OQ-09 "Pieces are not obstacle layers. A special clears the piece and gives one hit to the top obstacle layer in that cell".
For a piece on goo or under moss: does Hoof Tap (or Tail Slam / Bamboo Dash) clear only one thing, or the piece and one obstacle hit, as a special does?
- Option A: All boosters follow IR-09 exactly: clear the piece and give the top obstacle layer one hit.
- Option B: Tail Slam and Bamboo Dash follow IR-09; Hoof Tap removes only one thing: the top obstacle layer if there is one, otherwise the piece.
Blocks: IR-36 (cells holding both a piece and an obstacle layer).

---

## New questions from the MatchResolver build (27 Nov 2026)

### OQ-37 · Jade Orb + Jade Orb on a cell with two obstacle layers — ANSWERED
Decision: GDD › Rules clarifications › OQ-37, with both Orb + Orb rows amended (Option B; first given in chat 27 Nov 2026): top layer only, as for any special: moss over goo → the moss loses 1 and the goo is untouched. Now in IR-26. (The provisional code used Option A and must change.)

Two parts of the GDD read against each other:
- Interaction rules › "Jade Orb + Jade Orb | Clears the whole board, collects every collectible goal item (fragments included) and hits every obstacle once". Read literally, goo (OB10) under moss (OB03) is a second obstacle in that cell and also takes a hit.
- Interaction rules › "What a special hits | Each cell it covers takes one hit, on the top layer only (overlay, then content, then underlay)" with Rules clarifications › OQ-12 "A combo counts as one special". Read this way, only the moss is hit and the goo is untouched.
- Option A: Every obstacle on the board takes one hit, on every layer (moss over goo: both lose 1). A multi-cell obstacle still takes one hit in total.
- Option B: Top layer only, as for any special (moss over goo: moss loses 1, goo untouched).
Blocks: IR-26 (stacked-layer cells only). godot-engineer currently uses Option A provisionally.

### OQ-38 · Crane with no goal left: does healing dew count as a "remaining obstacle"? — ANSWERED
Decision: GDD › Rules clarifications › OQ-38 (Option B; first given in chat 27 Nov 2026): uncovered dew target cells count as remaining obstacles for a Crane with no goal left; the Crane landing there gives the cell dew. Now in IR-49, IR-53.

GDD says: Rules clarifications › OQ-17 "No goal left: the nearest remaining obstacle"; Obstacle set › OB04 "Healing dew … Matches made on dew spread it; cover the target cells" (listed as an obstacle, but it is something the player spreads, not removes); Interaction rules › "Dew goal: an uncovered target cell". Creep moss and creep goo clearly count (both are in the Obstacle set and are removed by hits); dew is not removed by hits, so "remaining" dew has no clear meaning, and what a hit on dew does is still OQ-31.
- Option A: Dew never counts as a remaining obstacle; a Crane with no goal left ignores dew cells (it may still land on one if another obstacle shares the cell).
- Option B: Uncovered dew target cells count as remaining obstacles; the Crane landing there gives the cell dew, as for a dew goal.
Blocks: IR-49 (no-goal case on boards with dew).

---

## New questions from applying the owner's answers to OQ-23 to OQ-38 (27 Nov 2026)

### OQ-39 · Continue offer: how many, what price, and what if declined? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-39 (own wording, neither option): "39a: max 5, 39: 2nd-55h 500coins, 39c: attempt ends, goes back to retry screen, 39d: yes, shown but pop up says "you have less than 300 coins" and hence cannot be accepted, eventually have decline and go back to retry screen". In plain words: (a) at most 5 offers per attempt; (b) the 1st costs 300 coins, the 2nd to 5th cost 500 each ("2nd-55h" = "2nd–5th", confirmed by the owner in chat 27 Nov 2026: "Q39 and Q40 is correct"); (c) declining ends the attempt and goes to the retry screen; (d) a player with under 300 coins still sees the offer with "you have less than 300 coins", can't accept, can only decline → retry screen. Now in IR-37. (A player with 300–499 coins at a 500-coin offer: OQ-52.)

GDD › Interaction rules › "Continue offer | Always shown after a fail, whether or not the goals can still be reached, and offered at least twice per attempt (count, price and decline flow: open question OQ-39)"; Core gameplay › Fail flow "an optional '+5 moves' for coins, offered at least twice per attempt whatever the board state, then the retry screen"; Meta & economy › Continue "Optional '+5 moves' for 300 coins, offered at least twice per attempt (exact count and later prices: OQ-39)". The GDD (a94a7e4) still lists this as open. IR-37 now uses the literal reading: offered every time moves run out, at least the first and second time in an attempt, each "+5 moves for 300 coins". Not settled:
- (a) Is there a maximum? "At least twice" sets a minimum only.
- (b) Does the second offer cost 300 coins like the first?
- (c) If the player declines an offer, does the attempt end (GDD › Fail flow "then the retry screen"), or is the offer shown a second time for the same fail ("twice after failure")?
- (d) Is the offer shown to a player with fewer than 300 coins ("regardless of situation")?
- Option A: (a) exactly two offers per attempt; (b) 300 coins each; (c) declining goes straight to the retry screen; (d) shown, but it can't be accepted without 300 coins.
- Option B: (a) no limit: an offer every time moves run out; (b) 300 coins each; (c) a declined offer is shown once more before the retry screen; (d) not shown; straight to the retry screen.
Blocks: IR-37 (third-fail, decline and low-coin tests).

### OQ-40 · Direction of the win-finale Rockets — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-40 (neither option): "can it be random rockets: some row, some column". In plain words: each finale Rocket gets its own random direction, row or column, picked by the level's seeded random number generator (so tests and bot runs repeat exactly). Confirmed by the owner in chat 27 Nov 2026 ("Q39 and Q40 is correct"). Now in IR-16, IR-05. (Odds and mix: answered in OQ-53.)

GDD says: Core gameplay › "Leftover moves become Bamboo Rockets that fire for bonus coins"; Audio › "Leftover moves fire as rockets 0.15 s apart". OQ-24's chosen Option A said "finale Rockets: the owner picks one fixed direction", but no direction was picked.
- Option A: All finale Rockets are row Rockets.
- Option B: All finale Rockets are column Rockets.
Blocks: IR-16 (finale Rockets only), the win-finale code.

### OQ-41 · Locked covered pieces: matches, shuffle and the cell below — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-41: Option A. In plain words: (a) a covered piece in a match is cleared and its overlay takes one hit; the underlay below is not hit by that match; (b) the free shuffle leaves covered pieces where they are; (c) a locked piece acts as a blocker, so the cell below it is filled by a diagonal slide. Now in IR-54, IR-14, IR-15, IR-33, IR-51.

Owner decision (chat 27 Nov 2026 › OQ-29, Option A): a covered piece "can't be swapped and doesn't fall, but it can be part of a match". Not settled:
- (a) When a covered piece is part of a match, is the piece cleared, does the overlay take a hit, and does an underlay beneath it (e.g. goo) take the "match on top" hit (IR-15)?
- (b) Does the free shuffle (IR-33) move covered pieces? (OQ-22 says the shuffle moves "plain pieces and specials".)
- (c) A cell below a locked piece is emptied: the locked piece blocks the straight fall from above. Is that cell filled by a diagonal slide as if the locked piece were a blocker (IR-51), or does it stay empty?
- Option A: (a) the piece is cleared and the overlay takes one hit; the underlay below is not hit while the overlay was there; (b) the shuffle leaves covered pieces where they are; (c) the locked piece counts as a blocker, so the cell below fills by a diagonal slide.
- Option B: (a) the piece is cleared, the overlay takes one hit and the underlay below also takes one hit; (b) the shuffle may move covered pieces (the overlay stays in its cell); (c) the cell below stays empty until the overlay is gone.
Blocks: IR-54, IR-14 (matches through covered pieces), IR-33, IR-51.

### OQ-42 · Jade Orb and plain pieces under an overlay — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-42: Option B. In plain words: the Jade Orb ignores plain pieces under an overlay: they don't count toward "most common colour", aren't cleared or converted, and their cells (overlay included) are untouched. Jade Orb + Jade Orb still clears the whole board (IR-26). Now in IR-18, IR-19, IR-25, IR-47.

Owner decision (chat 27 Nov 2026 › OQ-33, Option A): "Only plain pieces count and are cleared". The question also asked about pieces under an overlay, which Option A doesn't mention (Option B said "covered pieces count too"). Rules clarifications › OQ-09: "A Jade Orb covers every cell whose piece it clears".
- Option A: Covered plain pieces count toward "most common colour" and are cleared; the Orb then covers that cell, so the overlay takes one hit (IR-09).
- Option B: Covered plain pieces neither count nor are cleared; their cells are untouched.
Blocks: IR-18, IR-19, IR-25, IR-47 (boards with covered pieces).

### OQ-43 · Crane landing on a shrine that needs two colours equally — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-43: Option B. In plain words: if a shrine needs two or more colours equally, the level's seeded random number generator picks which one the Crane landing counts as. (The Jade Orb's colour ties keep the fixed red, yellow, blue, green order, IR-47.) Now in IR-49.

Owner decision (chat 27 Nov 2026 › OQ-34, Option B (c)): a shrine landing counts as "the colour the shrine needs most of". Not settled: a shrine that still needs, say, 2 R and 2 B.
- Option A: Ties broken in the fixed order red, yellow, blue, green (as for the Jade Orb, IR-47).
- Option B: Ties broken by the level's seeded random number generator.
Blocks: IR-49 (shrine tie test only).

### OQ-44 · Do pieces fall, and cascades resolve, before a waiting special fires? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-44: Option A. In plain words: before any waiting special fires (the swapped special, a matched special, a set-off special or a converted Orb special), pieces fall and new ones drop in, but new matches from that fall wait; they resolve only after every waiting special has fired. The Firecracker keeps its own rule: full cascades between its two blasts (IR-17). Now in IR-39, IR-41, IR-21, IR-50, IR-25. (Whether the swapped or matched special itself falls in that fall: OQ-54.)

Owner decisions (chat 27 Nov 2026): OQ-26 Option A "matches made by the swap resolve first (clears, neighbour hits, new specials), then the special fires"; OQ-27 Option B "a set-off special … fires from that cell after the fall"; OQ-32 Option B (for the Firecracker) "Fall, refill and all cascades resolve fully, then the second blast". Not settled: (a) after a swap's match clears, do pieces fall before the swapped special fires; (b) after the first special in a chain, do cascade matches resolve before the set-off specials fire, or only the fall and refill?
- Option A: Only the fall and refill happen before a waiting special fires; cascade matches resolve after it has fired (swap: match clears, fall, refill, special fires, then cascades; chain: first special, fall, refill, set-off specials fire, then cascades).
- Option B: Fall, refill and all cascades resolve fully before a waiting special fires, as between the Firecracker's blasts.
Blocks: IR-39, IR-41, IR-21 (tests where a piece below the special is cleared, or where a match forms before a set-off special fires).

### OQ-45 · Columns with a non-playable cell in the middle — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-45: Option A. In plain words: falling pieces pass straight through a non-playable cell (a hole in the board) to the playable cells below it. Now in IR-51.

GDD says: Rules clarifications › OQ-19 "Pieces fall straight down; where a cell can't be filled from above because of a blocker, a piece may slide in diagonally". Owner decision (chat 27 Nov 2026 › OQ-35, Option A) covers a column whose **top** cell isn't playable, not a gap lower down (e.g. (3,4) not playable, (3,5) emptied).
- Option A: Pieces pass straight through non-playable cells to the playable cells below them.
- Option B: A non-playable cell stops straight falls like a blocker; the cells below it fill by diagonal slides.
Blocks: IR-51 (gap tests). Note: godot-engineer's provisional code lets pieces fall through holes (Option A).

### OQ-46 · Dew spreading onto cells that held no piece — ANSWERED (trial decision, revisit after playtest)
Decision: Owner decision, chat 27 Nov 2026 › OQ-46: "lets try B first". In plain words: when dew spreads from a special, every playable cell the special covers gets dew, including cells where it only hit an obstacle (e.g. a bramble) or held a fragment or drop item. Now in IR-53.

Owner decision (chat 27 Nov 2026 › OQ-31, Option A): "every cell cleared by that same match or special gets dew". A special's area can include cells with no piece (a bramble, a pillar, a cocoon, an empty cell), where the special only hits an obstacle.
- Option A: Only cells whose piece was cleared get dew.
- Option B: Every playable cell the special covers gets dew, including cells where it only hit an obstacle.
Blocks: IR-53 (specials whose area includes obstacle cells).

---

## New questions from godot-engineer's provisional choices (27 Nov 2026)

The code already does one option of each question below (marked "provisional"). Tests for the blocked part aren't written until the owner picks; if the owner picks another option, the code changes.

### OQ-47 · A chain inside a chain: which waiting special fires next? — ANSWERED (trial decision, revisit after playtest)
Decision: Owner decision, chat 27 Nov 2026 › OQ-47: "lets go with A first". In plain words: all set-off specials share one waiting list, and the lowest, then left-most one always fires next, even if it was set off earlier than another. In the example, C fires before B. Now in IR-41. Same as the provisional code.

GDD says: Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes". Owner decision (chat 27 Nov 2026 › OQ-27, Option B): "Set-off specials fire lowest, then left-most first". Not settled: when a set-off special, while firing, sets off a further special, does that new one wait its turn with the specials already waiting, or does it fire before them?
Example: tap a row Rocket at (0,4); it sets off column Rocket A at (2,4) and column Rocket C at (6,4). A fires first (same row, left-most) and its column sets off row Rocket B at (2,1). Who fires next, C or B?
- Option A (provisional, what the code does now): one shared waiting list; the lowest, then left-most waiting special always fires next. In the example C (row 4) fires before B (row 1).
- Option B: each set-off special finishes its own chain first (the specials it set off fire, lowest then left-most, before any special that was already waiting). In the example B fires before C.
Blocks: IR-41 (chains of 3 or more specials), IR-21.

### OQ-48 · Jade Orb + Rocket/Firecracker: where are the converted specials while they wait? — ANSWERED (trial decision, revisit after playtest)
Decision: Owner decision, chat 27 Nov 2026 › OQ-48: "A first". In plain words: the converted pieces leave the board straight away and their cells refill; each converted special then fires from the cell it was converted in, lowest then left-most, one finishing (with its fall and refill) before the next; with OQ-44 A, cascade matches wait until the last one has fired. Now in IR-25. Same as the provisional code.

GDD says: Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires". Owner decisions (chat 27 Nov 2026): OQ-27 Option B "lowest, then left-most first"; OQ-32 Option B (pieces fall, refill and cascades resolve between a Firecracker's two blasts). So pieces can fall while converted specials are still waiting their turn. Not settled: can a waiting converted special be moved by those falls?
- Option A (provisional, what the code does now): every converted piece leaves the board at once (like a lifted set-off special, IR-41) and its cell refills by normal falling; each then fires from the cell it was converted in, lowest then left-most, each finishing (falls included) before the next.
- Option B: converted specials stay on the board as specials and fall like other pieces; each fires from the cell it is in when its turn comes (turn order fixed at conversion: lowest, then left-most); a blast that covers a waiting converted special doesn't set it off (it is already part of the combo).
Note: whether cascade matches resolve between converted specials follows the answer to OQ-44.
Blocks: IR-25 (any test where pieces below a converted special are cleared before it fires), IR-45 with IR-25.

### OQ-49 · Crane landing on an uncovered dew target: is the piece there cleared? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-49: Option B. In plain words: a Crane landing on an uncovered dew target acts like a special on that cell (the piece there is cleared) and also gives the cell dew. Same for the no-goal dew landing (OQ-38). Now in IR-48, IR-53, IR-49.

GDD says: Rules clarifications › OQ-16 "Gives one hit to its target cell, or collects the fragment or drop item there"; OQ-09 "A special clears the piece and gives one hit to the top obstacle layer". Owner decision (chat 27 Nov 2026 › OQ-31, Option A): "a Crane landing on an uncovered target cell gives it dew". Not settled: is the dew given instead of the normal hit (the piece there stays), or as well as it (the piece is cleared, as a special covering the cell would do)?
- Option A (provisional, what the code does now, and how IR-48's "or otherwise" currently reads): the landing gives the cell dew only; the piece there stays.
- Option B: the landing counts as a special covering the cell (the piece there is cleared, IR-09) and the cell gets dew.
Blocks: IR-48, IR-53, IR-49 (the piece in the landing cell on dew-goal and no-goal dew landings).

### OQ-50 · Lantern shrine (OB05): what do specials and matches do to it? — ANSWERED in part (trial decision, revisit after playtest)
Decision: Owner decision, chat 27 Nov 2026 › OQ-50: "A first". In plain words: (a) a special covering a shrine lowers its `hp` by 1 (once per special) and doesn't change the colours it still needs. Option A left (b), how matches fill a shrine, undecided; that part (and what lights the shrine) was then answered in OQ-55. Now in IR-55.

GDD says: Obstacle set › OB05 "Lantern shrine … Collect the colours it shows to light it"; Interaction rules › Crane "Lantern shrine: counts as one piece of a colour it still needs"; "What a special hits | Each cell it covers takes one hit"; "Which obstacles are multi-cell | … any obstacle drawn across 2 or more cells". The brief gives shrines an `hp` field. Nothing says (a) what a special's hit does to a shrine, or (b) how pieces are "collected" into it. OB05 debuts at level 10, so this blocks levels 10–12, 16, 20, 24, 25 and later.
- Option A (provisional, what the code does now for (a)): (a) a special's hit lowers the shrine's `hp` by 1 (one hit per special, IR-10) but doesn't change the colours it still needs; (b) not decided (the code doesn't fill shrines from matches yet).
- Option B: (a) a special's hit counts as one piece of the colour the shrine needs most, as for a Crane landing (IR-49); (b) each piece of a needed colour in a match next to the shrine fills it by one.
- Option C: (a) specials don't affect a shrine at all (only collected colours and the Crane landing light it); (b) every matched piece of a needed colour anywhere on the board fills it by one.
(For (b) the owner may also mix: e.g. Option A's (a) with Option B's (b).)
Blocks: the OB05 obstacle module; no IR for OB05 exists yet beyond IR-11 (multi-cell) and IR-49 (Crane landing).

---

## New question from checking the GDD update a94a7e4 (27 Nov 2026)

### OQ-51 · Is the continue offer shown after quitting mid-level? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-51: Option A. In plain words: the "+5 moves" offer appears only when moves run out; quitting goes straight to the fail result (life lost except on finales, first try used), with no offer. Now in IR-37, IR-38.

Two parts of the GDD, read together, give an odd result:
- Interaction rules › "Continue offer | Always shown after a fail, whether or not the goals can still be reached, and offered at least twice per attempt"; Rules clarifications › OQ-23 "Always after a fail, whether or not the goals can still be reached".
- Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try".
Read literally, a player who quits would be offered "+5 moves" (they may still have moves left). Core gameplay › Fail flow describes the offer only for running out of moves ("an optional '+5 moves' for coins … then the retry screen").
- Option A: The offer appears only when moves run out; quitting goes straight to the fail result (life lost, first try used), with no offer.
- Option B: Quitting also shows the offer (e.g. "Keep playing with +5 moves?") before the quit is confirmed; declining it completes the quit as a fail.
Blocks: IR-37 (which fails trigger the offer), IR-38 (quit flow).

---

## New questions from applying the owner's answers to OQ-39 to OQ-50 (27 Nov 2026)

### OQ-52 · Continue offers 2–5: a player with 300–499 coins — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-52: Option A. In plain words: a player who can't pay an offer still sees it; the message names that offer's price ("you have less than 300 coins" for the 1st, "you have less than 500 coins" for the 2nd to 5th); only Decline works, which goes to the retry screen. Now in IR-37.

Owner decision, chat 27 Nov 2026 › OQ-39: "2nd-55h 500coins" (read as 2nd–5th cost 500) and "39d: yes, shown but pop up says "you have less than 300 coins" and hence cannot be accepted, eventually have decline and go back to retry screen". The low-coin answer names 300, the price of the 1st offer. A player with, say, 400 coins at the 2nd offer can't pay 500, but "you have less than 300 coins" would be untrue. (A player under 300 at a later offer is covered: shown, can't accept, decline only; the message text is the same question.)
- Option A: The offer is shown; the message names that offer's price ("you have less than 500 coins"); only Decline works → retry screen.
- Option B: The offer is not shown when the player can't afford a 500-coin offer; the attempt goes straight to the retry screen (the low-coin pop-up is only for the 300-coin 1st offer).
Blocks: IR-37 (later-offer low-coin test only).

### OQ-53 · Win-finale Rockets: odds and mix of row and column — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-53: Option A. In plain words: each finale Rocket's direction is its own 50/50 pick from the level's seeded random number generator; a finale can by chance be all rows or all columns. Now in IR-16.

Owner decision, chat 27 Nov 2026 › OQ-40: "can it be random rockets: some row, some column". Not settled: whether each Rocket's direction is an independent 50/50 pick (so a finale could, by chance, be all rows), or whether a finale with 2 or more Rockets must contain at least one row and one column ("some row, some column").
- Option A: Each finale Rocket independently: row or column, 50/50, from the level's seeded random number generator; all-row or all-column finales can happen.
- Option B: Same seeded random picks, but a finale with 2 or more Rockets always contains at least one row and at least one column Rocket (e.g. if all picks match, the last Rocket is flipped).
Blocks: IR-16 (finale odds/mix tests only).

### OQ-54 · During the fall before a waiting special fires: do the swapped and matched specials fall? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-54: Option A. In plain words: when a swap makes a match, the swapped special, and any coloured special that is part of a match, is lifted off the board as the match resolves (like a set-off special); its cell refills in the fall, and it fires from the cell it was in right after the swap (or where it was matched). In the example the Rocket fires from (4,4). Now in IR-39, IR-50, IR-48 (a lifted Crane's take-off cell).

Owner decision, chat 27 Nov 2026 › OQ-44, Option A: "swap: match clears, fall, refill, special fires, then cascades". GDD › Rules clarifications › OQ-26 "each special fires from the cell it sits in"; OQ-04 lifts only specials *set off by another special*. Not settled:
- (a) A swapped special that is not in the swap's match, when that match clears the cell below it. Example: column Rocket at (4,5), R at (4,4), R at (2,5),(3,5). Swap (4,5)→(4,4): the Rocket is now at (4,4) and R at (2,5),(3,5),(4,5) clear. In the fall, does the Rocket drop to (4,5) (and fire along column 4 from there), or stay put? (For a column Rocket the column is the same; for a row Rocket or a Firecracker the area changes.)
- (b) A coloured special that is part of a match (IR-50): does it leave its cell when the match clears (so pieces fall into that cell before it fires), or stay on the board as a piece during the fall?
- Option A: Both are lifted off the board as the match resolves, like a set-off special (IR-41): their cells refill in the fall, and each fires from the cell it was in right after the swap.
- Option B: Both stay on the board as pieces until they fire: they fall like any piece and fire from the cell they are in when their turn comes.
Blocks: IR-39 (tests that clear a cell below the swapped special), IR-50 (piece counts for matched specials).

### OQ-55 · Lantern shrine (OB05): how matches fill it, and what lights it — ANSWERED (rest settled by OQ-59, OQ-61)
Decision: Owner decision, chat 27 Nov 2026 › OQ-55: Option A. In plain words: (a) each piece of a colour the shrine still needs, in a match next to it, fills it by one; (b) the shrine is lit when it needs no more colours or its `hp` reaches 0, whichever comes first; (c) a Crane landing counts as one piece of a needed colour and doesn't lower `hp`. Now in IR-55, IR-48, IR-49, IR-14. Parts Option A doesn't settle (which pieces of the match count, whether a match also lowers `hp`, what a lit shrine leaves on the board): OQ-59.

Owner decision, chat 27 Nov 2026 › OQ-50: Option A, whose part (b) said "not decided (the code doesn't fill shrines from matches yet)". GDD › Obstacle set › OB05 "Collect the colours it shows to light it"; Interaction rules › Crane "Lantern shrine: counts as one piece of a colour it still needs"; the shrine also has an `hp` that specials lower (IR-55). Not settled:
- (a) How a matched piece is "collected" into the shrine.
- (b) What lights (completes) the shrine: every colour collected, `hp` reaching 0, or either.
- (c) Does a Crane landing on a shrine also lower its `hp`, as a special hit (IR-48), or only count as one piece of a colour (IR-49)?
- Option A: (a) each piece of a needed colour in a match next to the shrine fills it by one; (b) the shrine is lit when every colour is collected or its `hp` reaches 0, whichever comes first; (c) the landing counts as one piece only, no `hp` loss.
- Option B: (a) every matched piece of a needed colour anywhere on the board fills it by one; (b) the shrine is lit only when every colour is collected (`hp` 0 just stops special hits from doing anything more); (c) the landing counts as one piece and also lowers `hp` by 1.
(The owner may also mix parts.)
Blocks: IR-55, IR-48 (shrine landing), the OB05 obstacle module (levels 10–12, 16, 20, 24, 25 and later).

---

## New questions from the rules-keeper's gap check (27 Nov 2026)

### OQ-56 · Healing dew spreading onto a creep goo cell — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-56: Option A. In plain words: goo blocks dew. The goo takes its hit from that match or special first; if the goo survives, the cell gets no dew this time; if the hit removed it, the cell gets dew. Now in IR-53, IR-15.

Parts that, read together, leave this open:
- GDD › Board layers & obstacles › Cell layer model › "1 · Underlay | Creep goo, healing dew | Matching on top of it" (one underlay layer per cell).
- `research/match-villains/level_agent_brief.md` › schema › "`underlay`: `.` = none; `1`–`3` = OB10 with that many hp; `s` = OB04 already covering that cell (a seed)" (one character per cell, so a cell can't start with both).
- Owner decision, chat 27 Nov 2026 › OQ-46 (Option B): "Every playable cell the special covers gets dew, including cells where it only hit an obstacle"; GDD › Rules clarifications › OQ-31 "every cell cleared by that match or special gets dew".
So a match or special that spreads dew can cover a cell that still holds goo. Not settled: does that cell get dew, and what happens to the goo? (The same match or special also hits that goo by IR-15 / IR-09, which may or may not clear it.)
- Option A: Goo blocks dew. The goo takes its hit first; if the goo survives, the cell gets no dew this time; if that hit cleared it, the cell gets dew.
- Option B: Dew replaces goo. The cell gets dew and any goo left there is removed; the removed goo counts as cleared for a goo goal.
- Option C: Both can sit in one cell during play (the one-underlay limit applies to level files only). The goo keeps its hp and stays the layer that takes hits; the cell also counts as covered for a dew goal.
Blocks: IR-53 (dew spreading onto goo cells), IR-15 (goo hit vs dew on the same cell), the OB04/OB10 obstacle modules and any level mixing dew and goo. No current test case puts dew next to goo, so no "Blocked by" line was added.

### OQ-57 · A cascade special made on a covered cell whose overlay survived — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-57: Option A. In plain words: the special appears in that cell under the overlay and is locked like any covered piece: it can't be swapped, doesn't fall and can't be tapped; another special can still set it off, and a coloured one can still be matched by colour. Now in IR-54, IR-40, IR-42, IR-43, IR-02, IR-33, IR-50.

Parts that, read together, leave this open:
- GDD › Rules clarifications › OQ-02 "in cascades, on the lowest then leftmost cell of the match (the crossing cell for an L or T)"; OQ-25 "A special whose match doesn't include the player's cell | Uses the cascade placement".
- GDD › Rules clarifications › OQ-29 "Pieces under an overlay (moss, shutter) | Locked: can't be swapped and don't fall, but can be part of a match. A cell emptied under a surviving overlay refills by normal falling".
- GDD › Core gameplay › "Specials fire when matched, swapped or tapped (tap costs a move)".
A cascade match (or a start-cell match, IR-43) can include a covered piece, and the placement cell can be that covered cell. If its overlay survives the match's hit (e.g. moss hp 2), OQ-29 says the cell refills by falling, while OQ-02 says the special appears there. Not settled: (a) does the special appear in that cell, (b) if so, is it locked like a covered piece, and (c) can the player tap it?
- Option A: The special appears there, under the overlay, locked like any covered piece: it can't be swapped, doesn't fall and can't be tapped; it can still be set off by another special (IR-41) or matched by colour (IR-50).
- Option B: The special appears there and can't be swapped or fall, but can be tapped (a tap is not a swap); tapping it costs a move as usual.
- Option C: A special never appears in a covered cell: it goes on the next cell of the match in placement order (lowest, then left-most) that has no overlay; the covered cell refills by falling as OQ-29 says. (If every cell of the match is covered, the owner would need to say what happens.)
Blocks: IR-40 (placement), IR-42 and IR-43 (cascade and start-cell specials), IR-54 (locked pieces), IR-33 (whether a covered special counts as "a special to tap" when checking for no possible move). No current test case makes a special on a covered cell, so no "Blocked by" line was added.

### OQ-58 · Win finale: where does each finale Rocket appear? — ANSWERED (rest settled by OQ-60)
Decision: Owner decision, chat 27 Nov 2026 › OQ-58: Option A. In plain words: each finale Rocket replaces an uncovered plain piece picked by the level's seeded random number generator (drawn after its direction); if none is left, it still earns its 5 coins and appears on a random playable cell (seeded). Now in IR-16, IR-05. Parts Option A doesn't settle (what the fallback Rocket does to what is in its cell; whether the board settles between finale Rockets): OQ-60.

GDD says (and nothing more about placement):
- Core gameplay › Rules › "Win: all goals done before moves run out. Leftover moves become Bamboo Rockets that fire for bonus coins ("Forest Festival" finale)."
- Feel, juice & sound › "Win finale | Leftover moves fire as rockets 0.15 s apart".
- Meta & economy › Coins › "Win = 20 + 5 per finale rocket".
- Owner decision, chat 27 Nov 2026 › OQ-40: each Rocket's direction is random (seeded). Placement was not asked.
Not settled: (a) which cell each finale Rocket appears in (and so which row or column it clears); (b) what happens if there are more leftover moves than cells that can hold one.
godot-engineer's provisional choice (in the code now) is Option A.
- Option A: Each Rocket replaces a random uncovered plain piece, picked by the level's seeded random number generator (a second draw after the direction). If no uncovered plain piece is left, the Rocket still counts for coins but appears on any random playable cell (owner to confirm).
- Option B: Each Rocket appears on a random playable cell (seeded), whatever is there: a plain piece, special, covered piece, fragment or drop item. (A special there would be set off; a fragment or drop item must never be destroyed, so these would need excluding: owner to confirm.)
- Option C: No board placement: each Rocket flies in from off the board (e.g. from the moves counter) along a random row or column (seeded), and that whole line is hit; nothing on the board is replaced.
Blocks: IR-16 (finale Rockets' firing cell and line), IR-05 (finale Rockets only), the win-finale code and its tests (`tests/match_resolver/test_finale_rockets.gd`). Coins (5 per Rocket) are the same under every option.

---

## New questions from applying the owner's answers to OQ-51 to OQ-58 (27 Nov 2026)

### OQ-59 · Lantern shrine: which match pieces count, do matches lower hp, and what a lit shrine leaves — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-59: Option A. In plain words: (a) if any piece of a match touches the shrine, every piece of a needed colour in that match fills it; (b) matches never lower the shrine's `hp`, only specials do; (c) a lit shrine is removed and its cells become open cells that fill by falling. Now in IR-55, IR-14, IR-49.

Owner decision, chat 27 Nov 2026 › OQ-55 (Option A): "(a) each piece of a needed colour in a match next to the shrine fills it by one; (b) the shrine is lit when every colour is collected or its `hp` reaches 0, whichever comes first". GDD › Board layers & obstacles › Cell layer model › "2 · Content | A piece, a blocker, a container or a drop item | Matching / adjacent matches / specials"; Obstacle set › OB05 "Collect the colours it shows to light it". Not settled:
- (a) A match where only some pieces touch the shrine (e.g. R at (2,5),(3,5),(4,5) under a 2×2 shrine at (3,3)–(4,4): (3,5) and (4,5) touch it, (2,5) doesn't). Do all 3 R count, or only the 2 that touch?
- (b) Does a match next to the shrine also lower its `hp` by 1, like any adjacent-match obstacle (IR-14)? Option A only says matches fill it; if not, `hp` falls only from specials.
- (c) Once lit, what is left on the board: is the shrine removed, so its cells become open cells that fill by normal falling, or does it stay as a lit, inert blocker?
- Option A: (a) every piece of a needed colour in the match counts, as long as at least one piece of the match touches the shrine; (b) no, matches only fill colours; `hp` falls only from specials; (c) the shrine is removed and its cells become open cells that fill by normal falling.
- Option B: (a) only pieces of a needed colour that themselves touch the shrine count; (b) yes, the match also gives the shrine one hit (`hp` −1, once per match, IR-14); (c) the shrine stays on the board as a lit blocker that nothing can hit any more.
(The owner may also mix parts.)
Blocks: IR-55 (partly-touching matches, `hp` after a match, the board after lighting), IR-14 (shrine), IR-49 (whether a lit shrine's cells can be Crane targets), the OB05 module.

### OQ-60 · Win finale: the fallback Rocket's cell, and settling between finale Rockets — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-60: Option A. In plain words: (a) the fallback Rocket replaces nothing; it fires from its cell and whatever is there is treated like any cell a special hits (IR-09: piece cleared, special set off, fragment or drop item stays, top layer hit); (b) finale Rockets go one at a time, and the board settles fully before the next Rocket is drawn. Now in IR-16.

Owner decision, chat 27 Nov 2026 › OQ-58 (Option A): "If no uncovered plain piece is left, the Rocket still counts for coins but appears on any random playable cell"; GDD › Interaction rules › "Soul fragments and drop items | Never destroyed by any special, combo or board clear"; Feel, juice & sound › "Win finale | Leftover moves fire as rockets 0.15 s apart". Not settled:
- (a) The fallback cell may hold a special, a covered piece, a fragment, a drop item or an obstacle, or be empty. What happens to it? (A fragment or drop item must never be destroyed, IR-28.)
- (b) With 2 or more leftover moves: is each Rocket placed and fired, and the board settled (fall, refill, cascades, set-off specials) before the next Rocket's draws, or are all Rockets placed first and then fired 0.15 s apart?
- Option A: (a) the Rocket doesn't replace anything: it fires from that cell, and whatever is there is treated as IR-09 says (piece cleared, special set off, fragment or drop item stays, top layer hit); (b) one at a time: each Rocket is drawn, placed and fired, and the board settles fully, before the next Rocket's draws.
- Option B: (a) the fallback draw skips cells holding a fragment, drop item or obstacle; a special or covered piece there is replaced without firing (the overlay stays); (b) all Rockets are drawn and placed first (in order), then fire one after another; the board settles only after the last one.
Blocks: IR-16 (fallback cell; finale tests with 2+ leftover moves that check cells or pieces), the win-finale code.

### OQ-61 · Lantern shrine: does a coloured special in a match next to it fill the shrine? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › OQ-61: Option A. In plain words: a coloured special in a match next to the shrine counts like a plain piece of its colour (in the example the shrine fills by 3), even though it is lifted rather than cleared. Now in IR-55, IR-50. IR-50's piece count (11) is unchanged.

GDD › Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces"; OQ-33 (Jade Orb only) "Only plain pieces count towards the most common colour, and only plain pieces are cleared". Owner decision, chat 27 Nov 2026 › OQ-54 (Option A): matched specials are "lifted off the board as the match resolves, like a set-off special"; OQ-55 (Option A): "each piece of a needed colour in a match next to the shrine fills it by one". Settled: a lifted special is not a cleared piece (IR-50, IR-41, IR-09). Not settled: e.g. R at (2,5), red row Rocket at (3,5), R at (4,5), next to a shrine that needs 3 R: does the shrine fill by 3 or by 2?
- Option A: The lifted special counts: every piece of a needed colour in the match, specials included, fills the shrine by one (shrine fills by 3).
- Option B: Only the plain pieces that are cleared count; a lifted special fills nothing (shrine fills by 2).
Blocks: IR-55 (matches containing a coloured special next to a shrine), the OB05 module. Doesn't block the IR-50 piece count (11).

---

## New questions from the GoalTracker build (27 Nov 2026)

### OQ-62 · What is one unit of a goal's count? — ANSWERED (trial decision, revisit after playtest)
Decision: Owner decision, chat 28 Nov 2026 › OQ-62: Option A, "for now". In plain words: one unit of a goal = one obstacle fully gone (a bramble with no layers left, a moss cell removed, a goo cell cleared, a pillar ground down completely, a creature freed, an idol cleared, a shrine lit, a drop item collected, a cell given dew); a goal's count must equal the number placed. Now in IR-61 (new), IR-56, IR-49. (Dew goals still wait for OQ-66.)

Parts that read against each other:
- GDD › Core gameplay › "Goals are always obstacles to clear, free or collect (see the obstacle table)".
- `level_agent_brief.md` §4 Goals › "Goal count must equal what is placed on the board (or what generators can produce)."
- `level_agent_brief.md` §6 › "Each goal count is achievable: placed hp/items ≥ the goal".
- `level_agent_brief.md` §5 example: two OB06 pillars with `"hp": 4` each, and the goal `{"obstacle": "OB06", "count": 4}` (2 pillars, 8 hp: matches neither reading). Plan: level 13 "OB06 x2", level 10 "OB05 x1", level 1 "OB02 x17".
"Must equal what is placed" reads as counting obstacles; "placed hp ≥ the goal" reads as counting hits. GoalTracker can't count progress until this is fixed.
- Option A: One unit = one obstacle fully gone: a bramble cell with no layers left, a moss cell removed, a goo cell cleared, a pillar ground down completely, a creature freed, an idol cleared, a shrine lit, a drop item collected, a cell given dew. The count must equal the number placed.
- Option B: One unit = one hit removed: each bramble layer, moss hp, goo hp, pillar hp, creature wrap and idol hit counts 1; a shrine lit, a drop item collected and a cell given dew count 1 each. The count may be lower than the total hp placed; the goal is done when the count is reached.
Blocks: IR-56, IR-57 (tests with obstacles of hp ≥ 2), IR-49 ("hits left" for obstacle goals), GoalTracker, the validator and every level file.

### OQ-63 · Goals finished by the last move — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-63: Option A. In plain words: everything a move does (its matches, cascades and specials) counts for that move; finishing the goals on the last move is a win with 0 finale Rockets (win coins 20). Now in IR-56, IR-57, IR-16.

GDD › Core gameplay › Rules › "Win: all goals done before moves run out." A move is used when the swap or tap is accepted (IR-01, IR-02), so while the last move's matches and cascades resolve, moves left is already 0. If that last move finishes the last goal, have the goals been done "before moves run out"?
- Option A: Yes: everything a move does (its matches, cascades and specials) counts for that move; finishing the goals on the last move is a win with 0 finale Rockets (win coins 20).
- Option B: No (literal reading): the goals must be done while at least one move is left; finishing them on the last move is a fail and the continue offer is shown.
Blocks: IR-56, IR-57.

### OQ-64 · When are win and fail checked during a resolve? — ANSWERED (CHANGED by the owner, 28 Nov 2026)
Decision (current): Owner decision, chat 28 Nov 2026 › OQ-72, changing OQ-64: "I would like the whole match to apply and the rest continued because that is the satisfaction level." In effect Option A for the win: when the last goal is done, the whole winning match or special applies, and the rest of that move's resolve continues (falls, refills, waiting specials, second blasts, cascades, free shuffle); the win is declared only once the move has fully settled, and then the finale starts on that settled board. The fail is still checked only after the move has fully settled. No longer a trial decision. Now in IR-56, IR-57, IR-16, IR-49.
History: earlier the same day the owner chose Option B "for now" (trial): the win declared the moment the last goal is done, the rest of the resolve dropped, the finale starting on the board as it was. That answer is replaced; the IR changes are in the CHANGELOG (28 Nov 2026).

GDD › Core gameplay › Rules › "Win: all goals done before moves run out"; Feel, juice & sound › "Rule: game logic resolves instantly; a separate animation and sound queue plays the results". One move's resolve can have many steps (cascades, set-off specials, a Firecracker's second blast, a free shuffle: IR-17, IR-32, IR-33, IR-41). Not settled:
- (a) If the last goal is done part-way through a resolve, does the rest of that resolve (waiting specials, second blasts, cascades) still happen before the win and the finale?
- (b) Is the fail (moves 0, a goal not done) checked only after the last move's resolve has fully settled, including any free shuffle?
- Option A: Both are checked only once the move's resolve has fully settled; the rest of the resolve always plays out (e.g. a waiting Crane still flies, aiming as IR-49's no-goal case says), then the win or fail follows.
- Option B: The win is declared the moment the last goal is done: the rest of that resolve is dropped and the finale starts on the board as it is; the fail is checked once the resolve has fully settled.
Blocks: IR-56, IR-57 (event order), the finale start (IR-16).

### OQ-65 · How the fragment is written in `goals`, and does it also count for another goal? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-65: Option B ("Basically fragment is part of the goal and must be completed to pass"). In plain words: (a) the fragment is an obstacle goal entry with a flag, e.g. `{"obstacle": "OB07", "count": 1, "fragment": true}`; (b) freeing the fragment's cocoon (or collecting its drop item) also counts toward a plain OB07 (or OB11) goal on the same level. The brief's schema is owner-only, so the schema line is in the round-5 update list. Now in IR-31, IR-56, IR-61. (Which cocoon or drop item holds the fragment in the level file: OQ-71.)

- GDD › Technical design › Level format › "plus one Mythic field: `"fragment": {"guardian": "rat", "scripted": true}` on fragment levels. A fragment level also lists the fragment in goals, inside the tier's goal count."
- `level_agent_brief.md` §5 › goals are only `{"obstacle": "OB06", "count": 4}`.
- GDD › Soul fragments › "sealed in a creep cocoon (OB07 behaviour) … it can also be an OB11 drop item". Plan: level 26 (fragment level) "OB07 x25"; level 45 "OB11 x1".
Not settled: (a) what the fragment's goal entry looks like and how it says where the fragment is; (b) whether freeing the fragment's cocoon also counts toward an OB07 creature goal on the same level (and a fragment drop item toward an OB11 hatchling goal).
- Option A: (a) its own entry, e.g. `{"fragment": "rat", "count": 1}`, with the cocoon or drop item placed through `objects` / `spawn` marked as the fragment; (b) no: the fragment counts only for the fragment goal.
- Option B: (a) an obstacle entry with a flag, e.g. `{"obstacle": "OB07", "count": 1, "fragment": true}`; (b) yes: it also counts toward a plain OB07 or OB11 goal on the same level.
(The owner may mix parts. The brief is owner-only, so any schema change is the owner's edit.)
Blocks: IR-31, IR-56 (fragment goals), IR-58, LevelLoader, the validator, levels 26, 30, 33, 35, 38, 40, 45, 50.

### OQ-66 · Dew goal: which cells are targets, and do seed cells count? — ANSWERED (trial decision, revisit after playtest)
Decision: Owner decision, chat 28 Nov 2026 › OQ-66: Option A, "let's try A for now". In plain words: every playable cell is a dew target; a dew goal's progress is the number of playable cells that have dew, and seed cells (`s`) count from the start. For the Crane, a dew goal's "hits left" is the number of playable cells without dew. Now in IR-61, IR-53, IR-49. (New gaps from it: OQ-73, OQ-74.)

Earlier note (28 Nov 2026): the owner asked what seed cells are. In plain words: a **seed cell** is a cell that already has healing dew under it when the level starts. The level file marks it with `s` in the `underlay` rows (brief §5: "`s` = OB04 already covering that cell (a seed)"). Dew spreads outward from these cells when matches or specials clear pieces on them (IR-53). The question is whether those starting cells already count toward a dew goal like "cover 51 cells" (Option A) or only cells that get dew during play count (Option B). Dew-goal tests stay blocked.

- GDD › Obstacle set › OB04 "Matches made on dew spread it; cover the target cells"; Interaction rules › Crane "Dew goal: an uncovered target cell".
- `level_agent_brief.md` §5 › "`s` = OB04 already covering that cell (a seed)"; §4 › "OB04 spread goals must not exceed 90% of playable cells". Plan: "OB04 x51".
The schema has no field marking target cells. Not settled: is every playable cell a target, and do seed cells count toward the goal from the start?
- Option A: Every playable cell is a target; progress = playable cells that have dew, seed cells included from the start.
- Option B: Every playable cell is a target, but only cells that get dew during play count; seed cells don't.
Blocks: GoalTracker (dew goals), IR-49 (dew "uncovered target cells left"), the validator's 90% check, levels 4–6, 12, 30, 38, 40, 44, 45.

### OQ-67 · Does using a hero booster use a move? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-67: Option A. In plain words: using Hoof Tap, Tail Slam, Bamboo Dash or Feather Fan uses no move. Now in IR-62 (new), IR-34, IR-35, IR-36, IR-56, IR-57.

GDD › Meta & economy › Booster unlocks gives each booster's effect and price but says nothing about moves; Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)" covers specials only.
- Option A: Using Hoof Tap, Tail Slam, Bamboo Dash or Feather Fan uses no move.
- Option B: Each booster use costs one move, like a tap.
Blocks: IR-34, IR-35, IR-36 (moves after a booster), IR-57 (can a booster at 1 move cause a fail), GoalTracker.

### OQ-68 · Colour goals ("collect N red") in the MVP — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-68: Option A. In plain words: no colour goals in levels 1–50; GoalTracker supports obstacle goals only (one of which may carry the fragment flag, OQ-65). Now in IR-61.

GDD › Core gameplay › "'collect N red' style goals are only used in tutorials". The brief's schema has only obstacle goals, and the plan lists only obstacle goals for levels 1–50, including the special tutorials (levels 2, 3, 5, 6).
- Option A: No colour goals in levels 1–50; GoalTracker supports obstacle goals (and the fragment goal) only.
- Option B: GoalTracker supports colour goals (e.g. `{"color": "red", "count": 20}`, one per matched piece of that colour); the owner names the levels that use them.
Blocks: GoalTracker goal types, LevelLoader.

### OQ-69 · How many goals on easy and medium levels? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-69: Option A. In plain words: use the tier table: easy levels have 1–2 goals, medium levels 2–3. Now in IR-59.

- GDD › Core gameplay › "Goals per level: 1 on intro levels, 1–3 on regular levels, 3–4 on hard levels, 4 on finales".
- GDD › Level progression › Level tiers › Easy "1–2", Medium "2–3".
An easy level with 3 goals is allowed by the first and refused by the second; so is a medium level with 1 goal.
- Option A: Use the tier table: easy 1–2, medium 2–3.
- Option B: Any regular level (easy or medium) may have 1–3.
Blocks: IR-59 (easy with 3, medium with 1), the validator.

### OQ-70 · Moves run out and a continue is accepted: is a life lost? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-70: Option A. In plain words: a life is lost only when the attempt ends in a fail (a declined offer, moves out a 6th time, or a quit); at most one life per attempt; an attempt won after continues costs no life. Now in IR-60.

- GDD › Meta & economy › Lives "lose one on fail, except on chapter finales".
- GDD › Interaction rules › "Continue offer | Always shown after a fail" (so running out of moves is called a fail even before the offer); Core gameplay › Fail flow "an optional '+5 moves' for coins … then the retry screen".
Not settled: does the life go when moves first run out (even if the player buys +5 moves and then wins), or only when the attempt ends on the retry screen?
- Option A: Only when the attempt ends in a fail (declined offer, moves out a 6th time, or a quit): at most one life per attempt; an attempt won after continues costs no life.
- Option B: One life the first time moves run out in an attempt, even if a continue is accepted and the level is then won; later run-outs in the same attempt cost nothing more.
Blocks: IR-60 (accept-then-win and accept-then-fail tests), SaveService.

---

## New questions from applying the owner's answers to OQ-62 to OQ-70 (28 Nov 2026)

### OQ-71 · Which cocoon or drop item holds the fragment in the level file? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-71: Option A. In plain words: the fragment's cocoon is one of the OB07 entries in `objects`, with `"fragment": true`; for a fragment drop item, `spawn.drop_items` gets `"fragment_item": n` (the n-th item spawned carries it). The brief's schema is owner-only, so the schema lines are in the round-6 update list below. Now in IR-31, IR-61, IR-58.

Parts that, read together, leave this open:
- GDD › Technical design › Level format › "plus one Mythic field: `"fragment": {"guardian": "rat", "scripted": true}` on fragment levels".
- `level_agent_brief.md` §5 › "`objects`: one entry per blocker"; "`spawn.drop_items`: e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6]}`".
- Owner decision, chat 28 Nov 2026 › OQ-65 (Option B): the goal entry is `{"obstacle": "OB07", "count": 1, "fragment": true}`, and the fragment's cocoon or drop item also counts toward a plain OB07 / OB11 goal.
The goal entry says what kind of obstacle holds the fragment, not which one. Level 26 is planned with "OB07 x25", so LevelLoader can't tell which cocoon holds the fragment; from level 38, which spawned drop item carries it is also not said. (The schema is in the owner-only brief.)
- Option A: Mark the object itself: the fragment's cocoon is one of the OB07 entries in `objects`, with `"fragment": true`; for a fragment drop item, `spawn.drop_items` gets e.g. `"fragment_item": n` (the n-th item spawned carries it).
- Option B: Put the position in the level's `fragment` field, e.g. `"fragment": {"guardian": "rat", "scripted": true, "x": 4, "y": 4}` (the OB07 entry in `objects` at that cell holds it); for a drop item, e.g. `"fragment": {…, "drop_item": n}`.
Blocks: LevelLoader, the validator (a plain OB07 / OB11 goal's count with the fragment's cocoon or item included, IR-31, IR-61), levels 26, 30, 33, 35, 38, 40, 45, 50. GoalTracker tests are not blocked (they set the fragment up directly).

### OQ-72 · The win "moment": does the rest of the winning step still happen? — ANSWERED (beyond Option A; changes OQ-64)
Decision: Owner decision, chat 28 Nov 2026 › OQ-72: "I would like the whole match to apply and the rest continued because that is the satisfaction level." In plain words: more than Option A: the whole match or special that finishes the last goal applies, and everything after it in that move (falls, refills, waiting specials, second blasts, cascades, free shuffle) still happens; the win comes once the move has fully settled. This replaces the trial answer to OQ-64. Now in IR-56, IR-16, IR-57, IR-49.

Question as asked: Owner decision, chat 28 Nov 2026 › OQ-64 (Option B, trial): "The win is declared the moment the last goal is done: the rest of that resolve is dropped and the finale starts on the board as it is". A single step of a resolve can do several things at once: one match clears 3+ pieces, gives neighbour hits to several obstacles and may make a special (IR-14, IR-40); one special (or one Firecracker blast) covers many cells (IR-09). Not settled: if the last goal is done by one part of such a step (e.g. a row Rocket's cell (2,4) frees the last creature, and the Rocket also covers (3,4)–(8,4)), does the rest of that same step still happen before the win?
- Option A: The step finishes: the whole match (its clears, neighbour hits and any special it makes) or the whole special or blast is applied, then the win is declared; everything after that step (falls, refills, waiting specials, second blasts, cascades) is dropped.
- Option B: The win is declared at the exact hit or collection that finishes the last goal; the rest of that match or special is not applied (its other cells keep their pieces and layers).
Blocks: IR-56 and IR-16 tests where the step that finishes the last goal also covers other cells or obstacles (board state at the finale start). No current test case depends on it.

---

## New questions from applying OQ-66, OQ-71 and OQ-72 (28 Nov 2026)

### OQ-73 · Can a goal's progress go past its count, and what does the goal counter show? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-73: Option A. In plain words: progress stops at the count: GoalTracker reports e.g. 72/72 and the counter shows the goal as done; extra dew is not counted. Now in IR-61, IR-53, IR-56.

Parts that, read together, leave this open:
- Owner decision, chat 28 Nov 2026 › OQ-66 (Option A, trial): dew progress = "playable cells that have dew, seed cells included from the start"; `level_agent_brief.md` §4 › "OB04 spread goals must not exceed 90% of playable cells". So a dew goal's count is below the number of cells that can get dew.
- Owner decision, chat 28 Nov 2026 › OQ-72: after the last goal is done "the rest continued", so more dew can spread in the same move after the goal is met (and one dew-spreading match or special can pass the count by itself).
- GDD › Feel, juice & sound › "Collect ring … as pieces fly to the goal counter" says there is a counter, not what it shows once a goal is done.
Example: goal OB04 count 72; 70 cells have dew; a row Rocket on dew gives 5 more cells dew. For other goals the count equals the number placed (IR-61), so they can't pass it. Whether the level is won is the same either way (the owner: "it shouldn't matter for a win").
- Option A: Progress stops at the count: GoalTracker reports 72/72 and the counter shows the goal as done; extra dew is not counted.
- Option B: Progress keeps counting: GoalTracker reports 75/72 (done = progress ≥ count); the counter shows the goal as done (e.g. a tick) rather than the number.
Blocks: GoalTracker's progress value for dew goals past the count, the goal counter UI. Not the win (IR-56).

### OQ-74 · A dew goal already met by its seed cells at the start — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-74: Option A. In plain words: the validator rejects a dew goal whose count is not more than the number of seed cells, so the count must need at least one new dew cell. Now in IR-61, IR-53, IR-56. The brief's §4/§6 needs a matching line (round-7 list below).

Parts that, read together, leave this open:
- Owner decision, chat 28 Nov 2026 › OQ-66 (Option A, trial): seed cells count toward the dew goal from the start.
- `level_agent_brief.md` §4 › "OB04 spread goals must not exceed 90% of playable cells" (a top limit only); §6 › "OB04 count ≤ 90% of playable cells". Nothing sets a bottom limit.
- GDD › Core gameplay › Rules › "Win: all goals done before moves run out" (a win comes after a move, IR-56).
Example: 5 seed cells and a goal OB04 count 4: the goal is done before the first move. Nothing says whether the validator allows this.
- Option A: Validator rejects a dew goal whose count is not more than the number of seed cells (the count must need at least one new dew cell).
- Option B: Allowed: the dew goal simply starts done; the level is won once the other goals are done (or, if it is the only goal, after the first move settles).
Blocks: the validator's dew check (bottom limit), GoalTracker on a goal that is done at the start. Not the current dew tests (all start below the count).

---

## New questions from the LevelLoader check (28 Nov 2026)

Found while checking `level_agent_brief.md` §5 (the level JSON schema) against the spec for the LevelLoader build. IR-63 to IR-71 hold what the GDD and brief do settle.

### OQ-75 · Which obstacle debuts at level 7 and which at 17: creature (OB07) or moss (OB03)? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-75: Option B (2026-11-28). In plain words: the plan stands: moss (OB03) debuts at 7, creature (OB07) at 17; the owner will change the GDD's Debut column to match (round-8 list below). Now in IR-67. New question from this: OQ-83 (the level 10 story beat).

Parts that disagree:
- GDD › Board layers & obstacles › Obstacle set › "7 | OB07 · container release | Mummified creature" and "17 | OB03 · cover cluster | Creep moss".
- `levels_1_100_plan.csv` › row 7 "7,1,intro,…,OB03 x36,OB03" and row 17 "17,1,intro,…,OB07 x24,OB07"; rows 8, 9 and 15 use OB03 and rows 18–20 use OB07.
- GDD › Board layers & obstacles › "10 debut in the MVP … following `levels_1_100_plan.csv`", while `level_agent_brief.md` intro says "debut levels are in the GDD's obstacle table, which wins over this file and the plan".
Under the GDD table, plan levels 8, 9 and 15 use moss before it debuts, and level 7 teaches the wrong obstacle.
- Option A: The GDD table stands (creature at 7, moss at 17); the owner re-plans rows 7–20 of the plan CSV.
- Option B: The plan stands (moss at 7, creature at 17); the owner changes the GDD's Debut column for OB07 and OB03.
Blocks: IR-67 tests for OB03 and OB07; level-designer for levels 7–20. Not LevelLoader.

### OQ-76 · Does a retry start with the same pieces as the last attempt? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-76: Option A (2026-11-28). In plain words: each attempt gets a new seed, so a retry shows a new random starting board and new refills; tests and the bot pass a seed in to repeat a run exactly. Now in IR-72, IR-71, IR-69.

GDD says: Core gameplay › "Every level starts with at least 3 valid moves, no pre-made matches"; several rules use "the level's seeded random number generator" (finale Rockets, Crane shrine ties, IR-16, IR-49). Nothing says where the seed comes from or whether it changes between attempts. The file lists no piece colours (only optional `fixed_tiles`), so the starting pieces are random.
- Option A: Each attempt gets a new seed: a retry shows a new random starting board (and new refills). Tests and the bot pass a seed in to repeat a run exactly.
- Option B: The seed is fixed per level (e.g. from its id): every attempt starts with the same board, and the same moves give the same refills.
Blocks: an IR-71 test on the starting pieces after a retry. Not the rest of LevelLoader.

### OQ-77 · How the level file lists the colours a lantern shrine (OB05) needs — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-77: Option A (2026-11-28). In plain words: a count per colour on the object, `"needs": {"red": 2, "blue": 1}`; the colours must be among the level's colours. Now in IR-73, IR-66, IR-55. Missing/empty `needs` or a count of 0: OQ-88 (c).

GDD says: Obstacle set › OB05 "Collect the colours it shows to light it"; IR-55 tests use shrines that "still need 2 R and 1 B". `level_agent_brief.md` §5 gives OB05 only `type`, `x`, `y`, `w`, `h`, `hp`; no field says which colours, or how many of each, it needs.
- Option A: A count per colour on the object, e.g. `{"type": "OB05", "x": 3, "y": 3, "w": 2, "h": 2, "hp": 3, "needs": {"red": 2, "blue": 1}}`.
- Option B: A list with one entry per piece needed, e.g. `"needs": ["red", "red", "blue"]`.
Either way, the colours must be among the level's `colors` (IR-68). Blocks: loading OB05 (levels 10, 11, 12, 16, 20, 24, 25, 27, 32, 33, 35, 38, 49). The rest of LevelLoader can be built.

### OQ-78 · Paper-screen lantern (OB08): how it is written in the file, and which layers it fills — ANSWERED (trial)
Decision: Owner decision, chat 28 Nov 2026 › OQ-78: Option B, "for now" (2026-11-28; trial, revisit after playtest). In plain words: the lantern is a content obstacle (no piece in its cell) with `"color"` and `hp`; adjacent matches or specials take the screen off (its hp), then an adjacent match of its colour lights it (goal +1). Now in IR-74 (new OB08 behaviour rule), IR-66, IR-14, IR-54, IR-61, IR-49. Parts this doesn't settle: OQ-84.

GDD says: Obstacle set › "22 | OB08 · shutter + colour | Paper-screen lantern | Open the screen, then match its colour to light it"; Cell layer model › "3 · Overlay | Cover clusters, shutters"; Rules clarifications › OQ-29 "Pieces under an overlay (moss, shutter)". The brief's schema has no colour field, and nothing says what is under the screen (a piece, or the lantern itself), what opens it (hits, `hp`) or what "match its colour" means once open. The spec has no OB08 behaviour rule yet (this also affects MatchResolver).
- Option A: The screen is an overlay with `hp`, over a plain piece (locked like moss, IR-54); the entry has a `"color"`; once the screen is gone, a match of that colour that includes the cell lights it (goal +1).
- Option B: The lantern is a content obstacle (no piece in its cell) with `"color"` and `hp`: adjacent matches or specials take the screen off (its `hp`), then an adjacent match of its colour lights it (goal +1).
Blocks: loading OB08 (levels 22–25, 39, 40, 43, 45–47, 49, 50) and every OB08 rule. The rest of LevelLoader can be built.

### OQ-79 · When and where drop items (OB11) appear — ANSWERED (trial)
Decision: Owner decision, chat 28 Nov 2026 › OQ-79: Option B, trial (2026-11-28): "Let's try B; if it is too easy during test, we move to A." In plain words: the first `max_on_board` items are placed in the top row at the start (seeded columns); after that each collected item is replaced at the next refill at the top of a random column (seeded), until `total` have appeared. Now in IR-75, IR-31, IR-69. Parts this doesn't settle: OQ-85.

GDD says: Obstacle set › OB11 "Bring it to the bottom row to collect it"; `level_agent_brief.md` §5 › "`spawn.drop_items`: e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6]}`". Nothing says whether any are on the board at the start, in which column a new one enters, or when (only that at most `max_on_board` are on the board and `total` appear in all).
- Option A: None at the start. Whenever fewer than `max_on_board` are on the board and fewer than `total` have appeared, the next refill brings one in at the top playable cell of a random column (seeded) in place of a new piece.
- Option B: The first `max_on_board` items are placed in the top row at the start (seeded columns); after that, each collected item is replaced at the next refill at the top of a random column (seeded), until `total` have appeared.
Blocks: loading and spawning drop items (levels 34–36, 38, 39, 45, 48, 50), IR-31's `fragment_item` spawn order in play. Not the rest of LevelLoader.

### OQ-80 · `fixed_tiles`: which tile names exist, and what colour a fixed special has — ANSWERED (trial)
Decision: Owner decision, chat 28 Nov 2026 › OQ-80: Option A, trial (2026-11-28): "move to B during test if too easy". In plain words: names `red`, `yellow`, `blue`, `green`, `line_h`, `line_v`, `firecracker`, `crane`, `orb`; a coloured special takes an optional `"color"`, random (seeded) if absent; only on cells that would hold a piece (under moss allowed). Now in IR-76, IR-69. `"color"` on an `orb`: OQ-88 (b).

`level_agent_brief.md` §5 says only: "`fixed_tiles`: optional pre-placed colours or power-ups, e.g. `{"x":4,"y":8,"tile":"line_h"}`". Rules clarifications › OQ-18: "Rockets, Firecrackers and Cranes keep the colour they were made from". So a fixed Rocket needs a colour, and the names for colours, column Rockets, Firecrackers, Cranes and Jade Orbs aren't given; nor whether a fixed tile may sit in a cell under moss or on an obstacle.
- Option A: Names `red`, `yellow`, `blue`, `green`, `line_h`, `line_v`, `firecracker`, `crane`, `orb`; a coloured special takes an extra `"color"` field, and gets a random colour (seeded) if it has none; only on cells that would hold a piece (under moss allowed).
- Option B: The same names, but `"color"` is required on every Rocket, Firecracker and Crane (the validator rejects one without it); fixed tiles never go under moss.
Blocks: loading any `fixed_tiles` entry other than the `line_h` example (and that entry's colour). The plan lists no fixed tiles in levels 1–50, so not LevelLoader's core.

### OQ-81 · Smaller schema gaps — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-81: Option A for all parts (2026-11-28). In plain words: (a) a 3-colour level names its colours, e.g. `"color_set": ["red","yellow","blue"]`; (b) underlay on a `.` cell is rejected; (c) no spawners in levels 1–50, no field yet; (d) `hp` 1–3 for OB03, OB05, OB06 and OB07. Now in IR-68, IR-65, IR-64, IR-66. Parts this doesn't settle: OQ-87 (the brief's own OB06 example has `hp` 4), OQ-88 (a) (`color_set` on a 4-colour level).

(a) Which 3 colours a 3-colour intro level uses. GDD › Core gameplay "4 colours on every level (3 only on a very cramped intro level)". (b) May `underlay` mark goo or dew on a `.` cell? Brief §6 only forbids objects on `.` cells. (c) Spawner cells: IR-51 and GDD › Rules clarifications › OQ-19 refer to "spawner cells where the level has them" and Cell layer model › "0 · Floor | … spawner, exit", but `cells` has only `#` and `.`. (d) The allowed `hp` for OB03, OB05, OB06 and OB07 (the GDD gives only OB02 "up to 3 layers", OB10 `1`–`3` and OB12 "2").
- Option A: (a) the level file says which, e.g. `"color_set": ["red", "yellow", "blue"]`; (b) no, rejected; (c) no spawners in levels 1–50, so no field is needed yet; (d) 1–3 for all four.
- Option B: (a) always red, yellow and blue (green dropped); (b) allowed but ignored; (c) add a cell character, e.g. `S` = playable spawner cell; (d) no limit beyond `hp` ≥ 1.
Blocks: (a) 3-colour levels (none in the plan for 1–50); (b), (d) validator checks; (c) any spawner level. None blocks LevelLoader's core.

### OQ-82 · Where pre-level booster and streak-chest specials appear on the starting board — ANSWERED (owner changed Option A)
Decision: Owner decision, chat 28 Nov 2026 › OQ-82: Option A, modified by the owner (2026-11-28): "Rocket's direction would be towards direction with highest number of targets". In plain words: each special replaces a random plain piece of the finished starting board (seeded), not under moss, taking that piece's colour; the board still has no match; the Rocket is a row or column Rocket, whichever of its row and its column holds more goal obstacles. A tie was not settled by the owner: the producer proposed a seeded 50/50, recorded as provisional (AI) pending owner confirmation in OQ-86. Now in IR-77. Later the same day the owner confirmed the seeded 50/50 and the target counting (OQ-86 (a) A, (b) A).

GDD says: Meta & economy › Booster unlocks › "16 | Pre-level boosters | Start with a Rocket + Crane, or a Firecracker"; Currencies › "Win streak | 6 wins in a row: a chest drops a free Rocket and Crane onto the next board". Nothing says which cells they take, their colour, or the Rocket's direction.
- Option A: Each replaces a random plain piece of the finished starting board (seeded), not under moss, taking that piece's colour; the Rocket's direction is 50/50 (seeded); the board still has no match.
- Option B: They are placed before the random fill, on random free cells (seeded) with a random colour, and the fill avoids making a match with them.
Blocks: pre-level boosters and the streak chest at load. Both are on CLAUDE.md's cut list if a milestone slips. Not LevelLoader's core.

---

## New questions from applying the owner's answers to OQ-75 to OQ-82 (28 Nov 2026)

### OQ-83 · The level 10 story beat needs a freed creature, but creatures now debut at 17 — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-83: Option A (2026-11-28). In plain words: the "First freed creature tells of a dark beast at the river" beat moves to level 17, the creature intro (owner-only GDD edit, round-8 list item 18). Noted in IR-67; no rule depends on it.

Parts that disagree:
- GDD › Story › Story beats › "10 | First freed creature tells of a dark beast at the river | Short dialogue".
- Owner decision, chat 28 Nov 2026 › OQ-75 (Option B): creature (OB07) debuts at 17; `levels_1_100_plan.csv` has no OB07 before row 17 (row 10 is "OB05 x1").
No creature can be freed in levels 1–16, so the level 10 beat can't happen as written.
- Option A: Move the beat to the first level where a creature is freed (level 17, the creature intro), with the owner's wording.
- Option B: Keep the beat at level 10 and reword it so it doesn't need a freed creature (e.g. it follows the first lantern shrine lit, which debuts at 10).
Blocks: the level 10 / 17 dialogue only. No IR and no LevelLoader test depends on it.

### OQ-84 · Paper-screen lantern (OB08): parts OQ-78's answer doesn't settle — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-84: (a) A, (b) B, (c) B, (d) B, (e) A (2026-11-28). In plain words: a lit lantern is removed and its cell fills by falling; a match of the lantern's colour that takes the screen's last hit also lights it; a special, combo, booster or Orb + Orb covering an open lantern lights it; a Crane landing is one screen hit on a closed lantern and lights an open one; `hp` 1–3 and `"color"` one of the level's colours. Now in IR-74, IR-49, IR-66. The lantern itself stays a trial (OQ-78).

Parts that, read together, leave this open:
- Owner decision, chat 28 Nov 2026 › OQ-78 (Option B, trial): "adjacent matches or specials take the screen off (its `hp`), then an adjacent match of its colour lights it (goal +1)".
- GDD › Obstacle set › OB08 "Open the screen, then match its colour to light it"; OB05 (the other lantern) "a lit shrine is removed and its cells fill by normal falling".
- GDD › Interaction rules › "Where the Paper Crane flies" and Rules clarifications › OQ-17, OQ-34 (hits left per goal type; OB08 is not named).
- `level_agent_brief.md` §5 gives `hp` ranges only for OB02, OB10 and OB12; OQ-81 (d) set 1–3 for OB03, OB05, OB06, OB07, not OB08.
(a) What a lit lantern leaves.
- Option A: It is removed and its cell fills by normal falling (like a lit shrine).
- Option B: It stays on the board, lit, as a blocker with no piece; it is no longer an obstacle (not hit, not a Crane target).
(b) The match that takes the screen's last hit is of the lantern's colour.
- Option A: It only opens the screen; a later match of its colour lights it.
- Option B: It opens the screen and lights the lantern in the same match.
(c) A special (or combo, booster, Orb + Orb) covering an open lantern.
- Option A: Nothing happens; only a match of its colour lights it.
- Option B: It lights the lantern.
(d) The Paper Crane and an OB08 goal.
- Option A: Hits left = remaining screen `hp` + 1 for each unlit lantern; a landing acts like a special covering the cell (one screen hit; on an open lantern, as (c) says).
- Option B: Like a shrine landing: on a closed lantern it is one screen hit; on an open lantern it counts as a match of its colour and lights it.
(e) Allowed values.
- Option A: `hp` 1–3; `"color"` one of the level's colours (as OB05 `needs`, IR-73).
- Option B: `hp` ≥ 1 with no top limit; `"color"` one of the level's colours.
Blocks: IR-74 tests for these parts, IR-49 for OB08 goals, the validator's OB08 checks; levels 22–25, 39, 40, 43, 45–47, 49, 50. The rest of IR-74 can be built.

### OQ-85 · Drop items (OB11): parts OQ-79's answer doesn't settle — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-85: Option A for (a), (b), (c) and (d) (2026-11-28). In plain words: starting items go in the top playable cell of different columns whose top cell holds an uncovered plain piece; a replacement enters in the same refill, in a column that gets a new piece then; items collected in the same move are all replaced in that refill, in different columns; starting items are numbered left to right. Now in IR-75, IR-76, IR-69. Left as "Not yet specified" in IR-75 (minor, level-designer avoids them): more items to replace than columns refilling; numbering of two items entering in the same refill. Fewer eligible starting columns than `max_on_board`: SETTLED, owner decision, chat 28 Nov 2026: the validator rejects the level (now in IR-75).

Parts that, read together, leave this open:
- Owner decision, chat 28 Nov 2026 › OQ-79 (Option B, trial): "The first `max_on_board` items are placed in the top row at the start (seeded columns); after that, each collected item is replaced at the next refill at the top of a random column (seeded), until `total` have appeared".
- GDD › Rules clarifications › OQ-35 "Every column refills at its top playable cell" (IR-51); `cells` may make row 0 of a column a `.` cell (IR-64); row 0 may hold an obstacle, moss or a fixed tile (IR-66, IR-76).
(a) Where the starting items go when row 0 of a column is not a plain uncovered piece.
- Option A: In each column's top playable cell; only columns whose top playable cell holds an uncovered plain piece (no obstacle, no moss, no fixed tile) can be picked.
- Option B: Only row 0 cells that are playable and hold an uncovered plain piece can be picked; the validator rejects a level with fewer such cells than `max_on_board`.
(b) Which column a replacement item may enter.
- Option A: Picked (seeded) among the columns that get a new piece in that refill, so it always enters in that refill.
- Option B: Picked (seeded) among all columns; if that column gets no new piece in that refill, the item enters at the next refill that brings a new piece into it.
(c) Two or more items collected in the same move.
- Option A: All are replaced in the same refill, each in a different column.
- Option B: One item enters per refill until the board is back to `max_on_board`.
(d) How the items placed together at the start are numbered (for `fragment_item`, IR-31).
- Option A: Left to right.
- Option B: In the order the seed draws their columns.
Blocks: IR-75 tests on these parts; `fragment_item` on levels with `max_on_board` ≥ 2. Levels with `max_on_board` 1 on a full top row are not blocked.

### OQ-86 · Pre-level / streak-chest Rocket: a tie between row and column, and what counts as a "target" — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-86: (a) A, (b) A (2026-11-28). In plain words: a tie (0 and 0 included) is a seeded 50/50, now an owner decision, no longer provisional; each goal obstacle with a cell in the line counts once, dew counts the line's playable cells without dew, each drop item counts 1. Now in IR-77.

Parts that, read together, leave this open:
- Owner decision, chat 28 Nov 2026 › OQ-82 (Option A, changed): "Rocket's direction would be towards direction with highest number of targets" (read by the producer as: row or column, whichever line holds more goal obstacles).
- GDD › Meta & economy › Booster unlocks › "Start with a Rocket + Crane, or a Firecracker"; Currencies › Win streak "a chest drops a free Rocket and Crane onto the next board". Neither says a direction.
(a) Row and column hold the same number (including 0 and 0). The producer proposed a seeded 50/50; that is a provisional AI choice, not an owner decision.
- Option A: Seeded 50/50 (the producer's proposal).
- Option B: A fixed side on a tie, e.g. always a row Rocket.
(b) What counts as a target in a line. Both options count only obstacles of the level's goals; say so if non-goal obstacles should count too.
- Option A: Each goal obstacle with at least one cell in the line counts once (a 2×2 pillar crossing the row = 1); dew goal: playable cells in the line without dew; drop items on the board: 1 each.
- Option B: Count cells: each cell in the line holding a goal obstacle counts (a 2×2 pillar with 2 cells in the row = 2); dew and drop items as in A.
Blocks: IR-77 tests on ties and on multi-cell, dew and drop-item lines. IR-77's single-cell bramble tests are not blocked.

### OQ-87 · Petrified pillar `hp`: 1–3 (OQ-81) or 4 (the brief's example)? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-87: Option B (2026-11-28). In plain words: OB06 allows `hp` 1–4; OB03, OB05 and OB07 stay 1–3; the brief's example stands. Now in IR-66.

Parts that disagree:
- Owner decision, chat 28 Nov 2026 › OQ-81 (Option A (d)): `hp` "1–3 for all four" (OB03, OB05, OB06, OB07).
- `level_agent_brief.md` §5 example › `{"type": "OB06", "x": 1, "y": 0, "w": 1, "h": 4, "hp": 4}` (both pillars in the example have `hp` 4).
OQ-81 did not quote this example (the rules-keeper missed it), so the answer may not have meant to rule it out.
- Option A: 1–3 stands for OB06; the owner changes the brief's example to `hp` 3 or less.
- Option B: OB06 allows 1–4 (OB03, OB05, OB07 stay 1–3); the example stands.
Blocks: the validator's check for OB06 `hp` 4 only. Spec tests that used the example's `hp` 4 now use 3 (valid either way).

### OQ-88 · Smaller gaps from OQ-77, OQ-80 and OQ-81 — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-88: Option A for all parts (2026-11-28). In plain words: the validator rejects a `color_set` on a 4-colour level, a `"color"` on an `orb` tile, and an OB05 entry with a missing or empty `needs` or a count of 0. Now in IR-68, IR-76, IR-73.

- OQ-81 (Option A (a)): a 3-colour level names its colours in `color_set`. (a) May a 4-colour level carry a `color_set`?
- OQ-80 (Option A): "a coloured special takes an extra `"color"` field"; IR-50: the Jade Orb has no colour. (b) What about a `"color"` on an `orb` tile?
- OQ-77 (Option A): `"needs": {"red": 2, "blue": 1}`; GDD › OB05 "Collect the colours it shows to light it". (c) An OB05 entry with no `needs`, an empty `needs`, or a colour with count 0?
- Option A: (a) rejected; (b) rejected; (c) rejected (every shrine needs at least 1 piece of each colour it names).
- Option B: (a) allowed but ignored; (b) allowed but ignored; (c) allowed: no colours means it is lit only when its `hp` reaches 0; a 0 count is ignored.
Blocks: validator checks only. Not LevelLoader for valid files.

---

## New questions from the SaveService check (28 Nov 2026)

### OQ-89 · Lives refill clock: closed game, when it starts, clock changes, a new player's lives — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-89: Option A (2026-11-28). In plain words: lives refill on real time while the game is closed; the countdown starts when lives drop below 5, each life back starts the next 20 minutes, another loss doesn't restart it, it stops at 5 or when all 5 are bought; a clock moved back gives nothing until it catches up (and never takes a life); a new player starts with 5. Now in IR-81, IR-78. Left as "Not yet specified" in IR-81 (minor): whether the countdown pauses during unlimited lives; buying all 5 at 5 lives. Both settled by the owner, chat 28 Nov 2026: the countdown does not run during unlimited lives and a fresh one starts when they end; buying at 5 lives is refused with "You already have 5 lives" (IR-81, IR-80).

GDD says: Meta & economy › Lives › "5 max; … refill 1 per 20 min, or buy all 5 back for 150 coins". CLAUDE.md › Owner decisions › "Lives: 5 max, 1 back every 20 min". Nothing says whether the 20 minutes pass while the game is closed, when a countdown starts, what a changed device clock does, or how many lives a new player starts with.
(a) Does the refill run while the game is closed? (b) When does a 20-minute countdown start? (c) The device clock is moved back or forward. (d) A new player's lives.
- Option A: (a) Yes, by real time: on opening, every full 20 minutes since the saved time gives a life (up to 5). (b) It starts when lives first drop below 5; each life that comes back starts the next 20 minutes; losing another life doesn't restart it; it stops at 5 lives (and when all 5 are bought). (c) Clock moved back: no lives come back until the clock passes the saved time again, and no life is ever taken away; clock moved forward: lives come back as the clock says. (d) 5.
- Option B: (a) No, only time with the game open counts. (b) Each life lost starts a new 20 minutes for that life. (c) Not an issue (only open-game time counts). (d) 5.
Blocks: IR-81's refill tests beyond "one life, game open"; SaveService's refill code. Not SaveService's core (saving, loading, coins, lives lost, fragments, progress).

### OQ-90 · Starting a level with 0 lives, and chapter finales — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-90: Option B (2026-11-28). In plain words: no level can be started or retried at 0 lives unless unlimited lives are running, except the finales 25 and 50, which can be played at 0 lives; at 0 lives the retry screen offers only waiting or buying all 5. Now in IR-81, IR-79.

GDD says: Meta & economy › Lives › "lose one when an attempt ends in a fail … chapter finales cost no life on a fail"; Research basis › "Top complaints: … lives lock-out"; Retention test › "Track how many players quit within 2 sessions after running out of lives on levels 15 or 20". The GDD never says that a level needs a life to start, nor whether a finale (where a fail costs nothing) does.
- Option A: No level can be started (or retried) with 0 lives unless unlimited lives are running (IR-81); finales too. At 0 lives the retry screen offers only waiting or buying all 5 for 150 coins.
- Option B: As A, except the chapter finales (25 and 50) can be started and retried with 0 lives, since a fail there costs no life.
Blocks: SaveService's "can this level start?" check and the retry screen at 0 lives. Not SaveService's core.

### OQ-91 · Unlimited lives after a chapter finale: on a win only? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-91: Option A (2026-11-28). In plain words: only winning a chapter finale gives the 10 minutes of unlimited lives, counted in real time from the win (game open or closed); a failed finale gives none. Now in IR-81, IR-60. Left as "Not yet specified" in IR-81 (minor): an attempt started during the 10 minutes that fails after they run out.

GDD says: Meta & economy › Lives › "10 min of unlimited lives after each chapter finale"; Fairness rules › "the unlimited-lives grant shows as a badge on the map". "After each chapter finale" could mean after winning it, or after any attempt at it. In the MVP only level 25 matters (after 50 there is no level to play, IR-79).
(a) What gives the 10 minutes? (b) Do they pass while the game is closed?
- Option A: (a) Only winning the finale (once, since it can't be replayed). (b) Yes, real time from the win (as OQ-89 (a) A).
- Option B: (a) Every finale attempt that ends, won or failed. (b) Only time with the game open counts.
Blocks: IR-81's unlimited-lives tests beyond "won at T, game open". Not SaveService's core.

### OQ-92 · The app is closed or killed mid-level — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-92: Option A (2026-11-28). In plain words: closing or killing the app mid-level counts as a quit: a fail, a life lost where a fail would cost one, the first try used and logged, the streak reset; on the next launch the player is on the map. Now in IR-38, IR-86, IR-84, IR-78. Left as "Not yet specified" in IR-38 (minor): a killed attempt from inside the unlimited-lives window whose next launch comes after it ended.

GDD says: Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try"; Retention test › "Log per player: … mid-level quits". It doesn't say whether closing the app, a crash, or the phone killing it in the background is a quit. Coins spent on continues and boosters used in that attempt stay spent under both options.
- Option A: It counts as a quit (IR-38): a fail, a life lost (not on finales), the streak back to 0, the first try used and logged; on the next launch the player is on the map (the level is not resumed).
- Option B: It doesn't count: no life lost, no attempt logged, streak unchanged; on the next launch the level starts fresh as if never begun (the attempt is not resumed).
Blocks: SaveService's start-of-attempt record and what it does on launch. Not the rest of SaveService's core.

### OQ-93 · Booster unlocks and paid uses — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-93: Option A for (a), (b), (c) and (d) (2026-11-28). In plain words: a booster unlocks when level N is first started (usable on N); a paid use is paid at the moment of use (nothing bought ahead; the save counts free uses left); one pre-level booster per attempt; it is spent per attempt (a retry needs another). Now in IR-82, IR-83, IR-80. Left as "Not yet specified" in IR-83 / IR-84 (minor): a pre-level booster on the streak-chest board. Settled by the owner, chat 28 Nov 2026: allowed; the chest's Rocket and Crane are placed after the booster's specials (IR-83, IR-84, IR-77).

GDD says: Meta & economy › Booster unlocks › "11 | Kancil's Hoof Tap | … | 3 free, then 100 coins each"; "16 | Pre-level boosters | Pre-level | Start with a Rocket + Crane, or a Firecracker … | 1 each free, then 150 coins each" (similar rows for 23, 29, 36); Research basis › "Boosters unlock one at a time with free uses"; Save file › `"boosters": {"hoof_tap": 3, …}` (a count per booster).
(a) When a booster "unlocks at level N". (b) Paid hero booster uses. (c) Pre-level boosters: can one attempt have both the Rocket + Crane and the Firecracker? (d) Is a pre-level booster spent per attempt or per level?
- Option A: (a) When level N is first started, so it can be used (and taught) on level N. (b) Paid at the moment of use: with no free uses left, using it costs its price then; the save's count is the free uses left. (c) One of the two per attempt. (d) Per attempt: each attempt started with one spends one (a retry needs another, free or 150 coins).
- Option B: (a) When level N is won, so it can first be used on level N + 1. (b) Bought ahead into stock, any number, and each use spends one from stock. (c) Both may be used on the same attempt. (d) Per level: one bought for a level covers its retries until it is won.
Blocks: IR-82 and IR-83 tests on the unlock level, buying and spending; BoosterService's purchase API. Not SaveService's core (it can store a count per booster under either option).

### OQ-94 · Win streak: after the chest, and a failed chest board — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-94: Option A for (a), (b) and (c) (2026-11-28). In plain words: the streak goes back to 0 when the chest drops; the chest board's attempt uses the chest up, so a failed chest board loses it; a 6th win on level 50 gives no chest. Now in IR-84, IR-78.

GDD says: Meta & economy › Currencies › "Win streak | 6 wins in a row: a chest drops a free Rocket and Crane onto the next board, placed as for pre-level boosters". It doesn't say what the streak does after a chest, or what happens to the chest if that board is failed.
(a) After the chest. (b) The next board is failed. (c) The 6th win is level 50 (no next board).
- Option A: (a) The streak goes back to 0; the next chest needs 6 more wins (12 in a row in total). (b) The chest is used up by that attempt; the retry starts without it (and the fail sets the streak to 0). (c) No chest.
- Option B: (a) The streak keeps counting; every win from the 6th on drops a chest onto the next board until a fail. (b) The chest stays for the retries until that level is won. (c) No chest.
Blocks: IR-84 tests beyond the first chest. On the cut list (item 1); not SaveService's core.

### OQ-95 · Upgrade milestones at levels 20 and 50: what they give — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-95: Option A (2026-11-28). In plain words: nothing is saved for the 20/50 milestones yet; winning 20 or 50 shows the milestone and gives nothing saved; the owner adds rewards when the upgrade flow is designed. Noted in IR-78 (no rule of its own until rewards exist).

GDD says: Level progression › "Your 20/50-level upgrade milestones can sit on top of this"; Open questions › "keep at 20/50 for now"; Meta & economy › "Owner: you. Forest restoration meta, collections and the heroes' upgrade flow". CLAUDE.md › "Upgrade milestones stay at levels 20 and 50". Nothing says what a milestone gives or what the save must keep for it.
- Option A: Not built in the MVP code yet: winning 20 and 50 shows the milestone (story card / badge) and gives nothing saved; the owner adds rewards when the upgrade flow is designed.
- Option B: The owner names the reward now (e.g. coins, free booster uses, or a hero upgrade level), and SaveService stores it.
Blocks: nothing in SaveService's core; only a milestone reward, if any.

### OQ-96 · Story beats on a retry: shown again? — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-96: Option A (2026-11-28). In plain words: each story beat plays once, the first time its level is reached; retries skip it; the save remembers which were seen. Now in IR-87 (new), IR-78. Left as "Not yet specified" in IR-87 (minor): whether a beat plays before or after its level.

GDD says: Story beats (levels 15, 20, 25, 30, 35, 40, 45, 50; level 17 after OQ-83), "Intro comic (4 panels, skippable…)"; Level progression › "each hard level carries a mini story beat"; Fairness rules › "At most one pop-up between the lobby and Play". It doesn't say whether a level's story beat plays again on each retry of that level, so whether the save must remember beats already seen.
- Option A: Each beat plays once, the first time it is reached; retries skip it (the save remembers which were seen).
- Option B: It plays on every attempt of its level (skippable); nothing to save.
Blocks: StoryPlayer and one saved list. Not SaveService's core.

---

## New question from the board-build-failure decision (28 Nov 2026)

### OQ-97 · A cancelled attempt (board failed to build): boosters, chest, unlocks and the screen after — ANSWERED
Decision: Owner decision, chat 28 Nov 2026 › OQ-97: Option A (2026-11-28). In plain words: a cancelled attempt puts the save back exactly as it was before the attempt started: the pre-level booster use or its 150 coins come back, a used streak chest is waiting again, a hero booster unlocked by that start is locked again, and the player goes back to the screen they started from with the message "This level couldn't be loaded". Now in IR-88 (Blocked-by line removed).

Owner decision, chat 28 Nov 2026 › board build failure: "If a board fails to build after an attempt has started, cancel the attempt with no penalty (no life lost, no first try used, streak kept) instead of counting it as a quit." Now in IR-88 for the three named items. It doesn't say what happens to the other things starting an attempt already did: IR-83 (OQ-93 (d) A) says a pre-level booster "is spent per attempt" and "stays spent" in an attempt that fails, is quit or is killed; IR-84 (OQ-94 (b) A) says the chest "is used up by that attempt whatever its result"; IR-82 (OQ-93 (a) A) says a hero booster unlocks "when level N is first started". A cancelled attempt is none of fail, quit or kill, so these rules don't settle it. The producer reads "no penalty" as including (a) and (b) below (provisional, not an owner decision).
(a) A pre-level booster chosen for the cancelled attempt (its free use, or the 150 coins paid). (b) A streak chest that was waiting for that board. (c) A hero booster unlocked by first starting level 11, 23, 29 or 36 in the cancelled attempt. (d) Which screen the player sees after the cancel.
- Option A: The save goes back to exactly how it was before the attempt started: (a) the free use or the 150 coins come back; (b) the chest is waiting again; (c) the booster is locked again (it unlocks, with its free uses, when the level is next started); (d) the player is back on the screen the attempt was started from (map or level-start screen), with a short "this level couldn't be loaded" message.
- Option B: Only life, first try, streak, log and open attempt are undone (IR-88): (a) the booster use or coins stay spent; (b) the chest stays used up; (c) the booster stays unlocked; (d) the player goes to the map with the same message.
Blocks: IR-88 tests for a cancelled attempt that used a pre-level booster or a chest, or first started a booster level; LevelSession's after-cancel screen. Not IR-88's core (life, first try, streak, log, open attempt).

---

## New questions from the `tutorial` and `story_beat` "intro" decisions (28 Nov 2026)

### OQ-98 · `tutorial` hint: does the validator check the swap really makes the taught special?
Owner decision, chat 28 Nov 2026 › `tutorial` field: the field and its shape checks are decided (IR-89). It says nothing on whether the validator proves the hint is correct. Provisional: Option A (the producer's reading, not an owner decision).
- Option A: No. The validator checks only the shape of the field (IR-89). The level designer pins the tiles with `fixed_tiles` so the swap makes the special; a wrong hint is found by a playtest.
- Option B: Yes. The validator plays the swap of the two hint cells on the starting board with the real MatchFinder / MatchResolver and rejects the level unless it creates the special named by `teach` (Rocket, Firecracker, Crane or Jade Orb).
Blocks: only an extra validator test for IR-89; nothing else.

### OQ-99 · Level 17's story beat has no `story_beat` value
IR-87 lists a story beat at level 17 (the first freed creature, OQ-83), and the GDD's Story table has it. `story_beat` (IR-63, the brief §5) is `"intro"` on level 1, `"mini"` on hard levels, `"chapter"` on finales and `null` on every other level, and level 17 is not a hard level (hard = 15, 20, 30, 35, 40, 45). So a level 17 file would say `null` although IR-87 says a beat plays there.
- Option A: Level 17 uses a new `story_beat` value (e.g. `"mini"`), and IR-63 lists level 17 as the one non-hard level allowed `"mini"`.
- Option B: The level 17 beat is not driven by `story_beat`; StoryPlayer plays it from a fixed list, and the file stays `null`.
Blocks: IR-63's test for level 17; StoryPlayer's source for the beat list. Not other levels.

---

## GDD text to update (owner only) — ALL DONE in a94a7e4

Checked line by line against the GDD on 27 Nov 2026. All 12 contradictions are now fixed:
1. Interaction rules › Continue offer: DONE ("Always shown after a fail, whether or not the goals can still be reached…").
2. Meta & economy › Continue: DONE ("offered at least twice per attempt").
3. Core gameplay › Fail flow: DONE ("offered at least twice per attempt whatever the board state").
4. Competitor table (line 57): DONE ("An optional continue that's never hidden").
5. Rules clarifications intro: DONE (now covers OQ-01 to OQ-38).
6. Rules clarifications › OQ-04: DONE (lifted specials, lowest then left-most, set-off Jade Orb removed without effect); Orb + Orb clearing specials without firing is in Interaction rules and OQ-27.
7. Meta & economy › Hoof Tap: DONE ("Clears the piece in one cell … and gives that cell's top obstacle layer one hit").
8. Interaction rules › Jade Orb + Jade Orb: DONE ("hits the top obstacle layer of every cell once (goo under moss is not hit)"); Combos table also updated.
9. Rules clarifications › OQ-21: DONE (adds "or pieces locked under an overlay").
10. Rules clarifications › OQ-19: DONE ("Pieces locked under an overlay (moss, shutter) don't fall").
11. Rules clarifications › OQ-03: DONE ("and to a drop item swapped with a plain piece (no move used)"; drop item + drop item is covered by OQ-30 "Drop item swaps | No match: snaps back").
12. Special pieces › Jade Orb: DONE ("Clears every plain piece of the colour it's swapped with; specials are left alone").

Additions OQ-24 to OQ-38: all present as rows 24–38.

Optional wording tidy-ups (not contradictions; the Rules clarifications rows already settle them, so nothing is blocked):
- The four heroes › Kancil › "Hoof Tap: removes one single tile (11)". A short summary that is looser than the rewritten Meta › Hoof Tap text.
- Interaction rules › "Tapping a Jade Orb | Clears every piece of the most common colour" and Combos › "Jade Orb + special | Every piece of the most common colour" still say "every piece"; OQ-33 narrows both to plain pieces.

---

## GDD text to update (round 2, owner only): decisions OQ-39 to OQ-50 (chat 27 Nov 2026)

Lines that now disagree with, or say less than, the owner's chat answers:
1. Interaction rules › Continue offer (currently "offered at least twice per attempt (count, price and decline flow: open question OQ-39)"): replace with "Always shown after a fail, whether or not the goals can still be reached; up to 5 offers per attempt: the 1st for 300 coins, the 2nd to 5th for 500 each. Declining ends the attempt (retry screen). Shown even without enough coins, with 'you have less than 300 coins'; only Decline works."
2. Core gameplay › Fail flow ("offered at least twice per attempt whatever the board state, then the retry screen"): "up to 5 times per attempt (300 coins, then 500), whatever the board state; declining goes to the retry screen".
3. Meta & economy › Continue ("Optional '+5 moves' for 300 coins, offered at least twice per attempt (exact count and later prices: OQ-39)"): "Optional '+5 moves': 300 coins for the 1st offer, 500 for the 2nd to 5th; at most 5 per attempt".
4. Rules clarifications › OQ-23 ("at least twice per attempt (details: OQ-39)"): point to the new OQ-39 row.
5. Core gameplay › Win ("Leftover moves become Bamboo Rockets…") and/or Audio › Win finale: add "each finale Rocket is randomly a row or column Rocket (seeded)".
6. Obstacle set › OB05 ("Collect the colours it shows to light it"): add "a special lowers its hp by 1 but doesn't change the colours it needs" (rest waits for OQ-55).
7. Rules clarifications › OQ-19 and OQ-29 rows: add "a locked piece counts as a blocker (the cell below fills by a diagonal slide); a match through a covered piece clears it and hits the overlay, not the underlay; pieces fall straight through non-playable cells".
8. Rules clarifications › OQ-22 (shuffle): add "never pieces locked under an overlay".
9. Rules clarifications › OQ-33 and Special pieces › Jade Orb: "uncovered plain pieces" (covered pieces neither count nor are cleared or converted).
10. Rules clarifications › OQ-34 (c): add "ties between colours: seeded random".
11. Rules clarifications › OQ-31: "every playable cell the special covers gets dew (obstacle cells included)"; "a Crane landing on an uncovered target cell clears the piece there and gives it dew".
12. Rules clarifications › OQ-04 / OQ-26 / OQ-27: "before each waiting special fires, pieces fall and refill; cascade matches wait until all waiting specials have fired (the Firecracker's two blasts keep their cascades in between). All set-off specials share one waiting list: lowest, then left-most, fires next".
13. Combos › Jade Orb + special: "converted pieces leave the board at once and their cells refill; each fires from the cell it was converted in".
14. Rules clarifications: add rows 39 to 50 (marking 46, 47, 48 and 50 as trial decisions to revisit after playtest).

---

## GDD text to update (round 3, owner only): decisions OQ-51 to OQ-58 (chat 27 Nov 2026)

Round 2 item 1 now reads, with OQ-39 confirmed and OQ-52: "…the 1st for 300 coins, the 2nd to 5th for 500 each. Declining ends the attempt (retry screen). Shown even without enough coins, with 'you have less than N coins' (N = that offer's price); only Decline works."
1. Interaction rules › Continue offer: add "Only when moves run out; never after quitting."
2. Interaction rules › Quitting mid-level ("Counts as a fail: costs a life (except on finales) and counts as that level's first try"): add "Goes straight to the fail result; no continue offer."
3. Core gameplay › Win / Feel › Win finale (round 2 item 5): "each finale Rocket is a row or column Rocket, 50/50, picked independently (seeded), and replaces a random uncovered plain piece (seeded); if none is left it still pays 5 coins and appears on a random playable cell".
4. Rules clarifications › OQ-26 / OQ-04: "When a swap makes a match, the swapped special, and any coloured special in a match, is lifted off the board as the match resolves; its cell refills in the fall and it fires from the cell it was in right after the swap (or where it was matched)."
5. Obstacle set › OB05 (round 2 item 6): "A match next to it fills it by one per piece of a colour it still needs; a special lowers its hp by 1 without changing the colours; a Crane landing counts as one piece of a needed colour and doesn't lower hp. Lit when it needs no more colours or its hp reaches 0, whichever comes first."
6. Rules clarifications › OQ-31 (round 2 item 11): "Goo blocks dew: on a goo cell the goo takes its hit first; the cell gets dew only if that hit removed the goo."
7. Rules clarifications › OQ-29 / OQ-02: "A special made in a covered cell appears there under the overlay, locked: it can't be swapped, doesn't fall and can't be tapped; another special can set it off and a coloured one can still be matched."
8. Rules clarifications: add rows 51 to 58.

---

## GDD text to update (round 4, owner only): decisions OQ-59 to OQ-61 (chat 27 Nov 2026)

1. Obstacle set › OB05 (replaces round 3 item 5): "If any piece of a match touches it (up, down, left or right), every piece of that match of a colour it still needs, coloured specials included, fills it by one. Matches never lower its hp; a special lowers its hp by 1 without changing the colours; a Crane landing counts as one piece of a needed colour and doesn't lower hp. Lit when it needs no more colours or its hp reaches 0, whichever comes first; a lit shrine is removed and its cells fill by normal falling."
2. Board layers & obstacles › Cell layer model › "2 · Content … Cleared by Matching / adjacent matches / specials": add "(lantern shrine: adjacent matches fill its colours but never lower its hp)".
3. Core gameplay › Win / Feel › Win finale (replaces round 3 item 3): "…if none is left it still pays 5 coins and fires from a random playable cell without replacing what is there (that cell is hit like any cell a special covers). Finale Rockets go one at a time: the board settles fully (fall, refill, cascades, set-off specials) before the next one." Note: "0.15 s apart" in Feel › Win finale then means 0.15 s after the board settles, not a fixed beat; owner to word it.
4. Rules clarifications › OQ-18 ("Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces"): add "and fill a lantern shrine like a piece of that colour".
5. Rules clarifications: add rows 59 to 61.

---

## GDD and brief text to update (round 5, owner only): decisions OQ-62 to OQ-70 (chat 28 Nov 2026)

GDD (`docs/gdd/zodiac-forest-gdd-final.md`):
1. Core gameplay › Rules › "Win: all goals done before moves run out": add "Everything the last move does (matches, cascades, specials) counts for it, so finishing the goals on the last move is a win with 0 finale Rockets. The win is declared the moment the last goal is done; the rest of that move is dropped and the finale starts on the board as it is (trial). The fail is checked only once the move has fully settled." (SUPERSEDED by round 6 item 1: the owner changed OQ-64 on 28 Nov 2026.)
2. Core gameplay › Goals per level ("1 on intro levels, 1–3 on regular levels, 3–4 on hard levels, 4 on finales"): replace "1–3 on regular levels" with "1–2 on easy levels, 2–3 on medium levels", to match Level progression › Level tiers.
3. Core gameplay › Goals per level ("'collect N red' style goals are only used in tutorials"): "No colour goals in levels 1–50; every goal is an obstacle goal."
4. Core gameplay › Goals per level and/or Level progression: add "One unit of a goal is one obstacle fully gone (a bramble with no layers left, a moss or goo cell cleared, a pillar ground down, a creature freed, an idol cleared, a shrine lit, a drop item collected, a cell given dew); the count equals the number placed (trial)."
5. Technical design › Level format ("A fragment level also lists the fragment in goals, inside the tier's goal count"): add "as an obstacle goal with a flag, e.g. `{"obstacle": "OB07", "count": 1, "fragment": true}`; the fragment's cocoon or drop item also counts toward a plain OB07 / OB11 goal on the same level". (Where the file says which cocoon holds it: OQ-71.)
6. Meta & economy › Booster unlocks: add "Using a booster uses no move."
7. Meta & economy › Lives ("lose one on fail, except on chapter finales"): add "A life is lost only when the attempt ends in a fail (declined offer, moves out a 6th time, or a quit): at most one per attempt; an attempt won after continues costs no life."
8. Rules clarifications: add rows 62 to 65 and 67 to 70 (marking 62 and 64 as trial decisions to revisit after playtest).

Brief and plan (`research/match-villains/`):
9. `level_agent_brief.md` §4 Goals ("Goal count must equal what is placed on the board (or what generators can produce)"): add "One unit = one obstacle fully gone (not one hit)."
10. `level_agent_brief.md` §6 ("Each goal count is achievable: placed hp/items ≥ the goal"): replace with "Each obstacle goal's count equals the number of those obstacles placed (spawned items meet the goal; OB04 count ≤ 90% of playable cells)".
11. `level_agent_brief.md` §5 example: goals `{"obstacle": "OB06", "count": 4}` with 2 pillars, and `{"obstacle": "OB03", "count": 30}` with 1 moss, no longer pass; e.g. `"count": 2` and `"count": 1` (or place more).
12. `level_agent_brief.md` §5 schema: add the goal flag `"fragment": true` (OQ-65) and, once OQ-71 is answered, how the fragment's cocoon or drop item is marked.
13. `level_agent_brief.md` §4 Hazards ("The OB09 beam must be visible") and §5: note that OB09 (Nian's Eye) is not used in levels 1–50.
14. `levels_1_100_plan.csv`: remove OB09 from levels 46–50 (owner decision, chat 28 Nov 2026: Nian's Eye comes after level 50; the GDD already puts it at level 61). Checked: OB09 is in rows 46, 47, 48 and 50 (not 49). Level 46 is OB09's intro level ("OB09 x1", new obstacle OB09), so removing it leaves level 46 with no goal and no new obstacle: the owner needs to give it a new plan (tier, goal, new obstacle or none). Levels 47, 48 and 50 then have one goal fewer (finale 50 drops to 3, below the tier's 4, IR-59; medium 48 keeps 2, OK; easy 47 keeps 1, OK).

---

## GDD and brief text to update (round 6, owner only): decisions OQ-66, OQ-71, OQ-72 and the changed OQ-64 (chat 28 Nov 2026)

GDD (`docs/gdd/zodiac-forest-gdd-final.md`):
1. Core gameplay › Rules › "Win: all goals done before moves run out" (replaces round 5 item 1): add "Everything a move does (matches, cascades, specials) counts for it, so finishing the goals on the last move is a win with 0 finale Rockets. When the last goal is done, the rest of that move still happens in full (the rest of the match or special, falls, refills, waiting specials, second blasts, cascades, any free shuffle); the win is declared once the move has fully settled, and the finale starts on that settled board. The fail is also checked only once the move has fully settled."
2. Feel, juice & sound › Win finale: add "starts once the winning move has fully settled".
3. Board layers & obstacles › Obstacle set › OB04 ("Matches made on dew spread it; cover the target cells"): add "Every playable cell is a target; progress counts the playable cells that have dew, seed cells included from the start (trial)."
4. Technical design › Level format (round 5 item 5): replace "(Where the file says which cocoon holds it: OQ-71.)" with "The fragment's cocoon is the OB07 entry in `objects` with `"fragment": true`; a fragment drop item is set by `"fragment_item": n` in `spawn.drop_items` (the n-th item spawned carries it)."
5. Rules clarifications: add rows 66 (trial), 71 and 72; row 64 shows the changed answer (no longer trial).

Brief (`research/match-villains/level_agent_brief.md`):
6. §5 schema (round 5 item 12, now complete): add `"fragment": true` on the fragment's OB07 entry in `objects`, and `"fragment_item": n` in `spawn.drop_items`, e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6],"fragment_item":2}`; plus the goal flag `"fragment": true` (OQ-65).
7. §6 checklist: add "On a fragment level, exactly one OB07 entry has `"fragment": true`, or `spawn.drop_items` has a `fragment_item` between 1 and `total`; a plain OB07 / OB11 goal's count includes the fragment's cocoon or item."
8. §4 Goals / §6: add "OB04 goal: every playable cell is a target; seed cells count from the start" (bottom limit: round 7 item 3).

---

## GDD and brief text to update (round 7, owner only): decisions OQ-73, OQ-74 (chat 28 Nov 2026)

GDD (`docs/gdd/zodiac-forest-gdd-final.md`):
1. Board layers & obstacles › Obstacle set › OB04 (round 6 item 3): add "Progress stops at the count; extra dew is not counted. The count must be more than the number of seed cells."
2. Rules clarifications: add rows 73 and 74.

Brief (`research/match-villains/level_agent_brief.md`):
3. §4 Goals ("OB04 spread goals must not exceed 90% of playable cells"): add "and must be more than the number of seed cells (`s`), so at least one new dew cell is needed".
4. §6 checklist ("OB04 count ≤ 90% of playable cells", round 5 item 10): make it "number of seed cells < OB04 count ≤ 90% of playable cells".

---

## GDD/brief text to update (owner only), round 8: decisions OQ-75 to OQ-88 (chat 28 Nov 2026)

Items 1–17 cover OQ-75 to OQ-82; items 4, 5, 7 and 15 were updated and items 18–25 added for OQ-83 to OQ-88.

GDD (`docs/gdd/zodiac-forest-gdd-final.md`):
1. Board layers & obstacles › Obstacle set › Debut column (OQ-75 B): Creep moss (OB03) "17" → "7"; Mummified creature (OB07) "7" → "17" (and move the rows so the table stays in debut order). The level 10 story beat moves to 17: item 18.
2. Board layers & obstacles › Cell layer model (OQ-78 B, trial): "3 · Overlay | Cover clusters, shutters" → "Cover clusters"; "2 · Content" add "(paper-screen lantern: adjacent matches and specials take off its screen; then an adjacent match of its colour lights it)".
3. Rules clarifications › rows 19, 21 and 29 say "(moss, shutter)": the paper-screen lantern is no longer an overlay, so "(moss)".
4. Obstacle set › OB08 ("Open the screen, then match its colour to light it"): add "A one-cell content obstacle (no piece) with a colour and a screen of `hp` hits. Each adjacent match, of any colour, or each special takes one hit off the screen; once it is open, an adjacent match of its colour lights it (trial). A match of its colour that takes the screen's last hit also lights it. A special, combo, booster or Orb + Orb covering an open lantern lights it. A Paper Crane landing is one screen hit on a closed lantern and lights an open one. A lit lantern is removed and its cell fills by normal falling. `hp` 1–3." (OQ-84.)
5. Obstacle set › OB11 ("Bring it to the bottom row to collect it"): add "The first `max_on_board` items start in the top playable cells of different columns (seeded), only in columns whose top playable cell holds an uncovered plain piece, numbered left to right; every item collected in a move is replaced in the next refill, each in a different column (seeded) among the columns that get a new piece in that refill, until `total` have appeared (trial)." (OQ-79, OQ-85.)
6. Core gameplay › Rules (or Technical design): add "Each attempt gets a new random seed, so a retry shows a new starting board and new refills; every 'seeded' draw uses the attempt's seed. Tests and the bot pass a seed in to repeat a run exactly." (OQ-76 A.)
7. Meta & economy › Booster unlocks › Pre-level boosters, and Currencies › Win streak: add "Each special replaces a random plain piece of the starting board (seeded), not under moss, and takes its colour; a Rocket points along its row or its column, whichever holds more targets, 50/50 (seeded) on a tie. Targets in a line: each goal obstacle with a cell in it counts once; for a dew goal, its playable cells without dew; each drop item, 1." (OQ-82, OQ-86.)
8. Rules clarifications: add rows 75 to 82 (marking 78, 79 and 80 as trial decisions to revisit after playtest).

Brief (`research/match-villains/level_agent_brief.md`):
9. §5 `objects`: OB05 entries get `"needs": {"red": 2, "blue": 1}` (a count per colour, colours among the level's colours) (OQ-77 A).
10. §5 `objects`: OB08 entries are `{"type": "OB08", "x": 4, "y": 3, "hp": 2, "color": "red"}`; the cell holds no piece (OQ-78 B, trial).
11. §5 `fixed_tiles`: tile names `red`, `yellow`, `blue`, `green`, `line_h`, `line_v`, `firecracker`, `crane`, `orb`; optional `"color"` on a Rocket, Firecracker or Crane (seeded random if absent); only on cells that would hold a piece, under moss allowed (OQ-80 A, trial).
12. §4 Colours and §5: a 3-colour level names its colours, e.g. `"color_set": ["red", "yellow", "blue"]` (OQ-81 A (a)).
13. §5 `underlay` and §6: "No underlay (`1`–`3`, `s`) on a `.` cell" (OQ-81 A (b)).
14. §5: "No spawner cells in levels 1–50" (OQ-81 A (c)).
15. §5 / §6: "`hp` 1–3 for OB03, OB05, OB07 and OB08; 1–4 for OB06" (OQ-81 A (d), OQ-87 B, OQ-84 (e) A); the §5 example's two OB06 entries with `"hp": 4` stand.
16. §5 `spawn.drop_items`: add the spawn behaviour of item 5 (OQ-79 B, trial).
17. §6 checklist: add "OB05 `needs`, OB08 `color` and fixed-tile colours are among the level's colours; obstacles debut as in the GDD table (moss 7, creature 17)".

Added for OQ-83 to OQ-88:

GDD (`docs/gdd/zodiac-forest-gdd-final.md`):
18. Story › Story beats › "10 | First freed creature tells of a dark beast at the river | Short dialogue": move the row to level 17 (the creature intro), with the owner's wording (OQ-83 A).
19. Interaction rules › "Where the Paper Crane flies" and Rules clarifications › OQ-17 / OQ-34 (hits left per goal type): add "paper-screen lantern: a landing is one screen hit on a closed lantern and lights an open one, so hits left = remaining screen hp + 1 for each unlit lantern" (OQ-84 (d) B; the hits-left count follows from it, as in IR-49).
20. Rules clarifications: add rows 83 to 88.

Brief (`research/match-villains/level_agent_brief.md`):
21. §5 `objects` (item 10): OB08 `hp` 1–3; `"color"` required, one of the level's colours (OQ-84 (e) A).
22. §5 `objects` (item 9) and §6: "OB05 `needs` is required, names at least one colour, and every count is at least 1" (OQ-88 A (c)).
23. §4 Colours / §5 (item 12): "Only a 3-colour level has `color_set`; a 4-colour level must not" (OQ-88 A (a)).
24. §5 `fixed_tiles` (item 11): "an `orb` tile has no `"color"`" (OQ-88 A (b)).
25. §5 `spawn.drop_items` (item 16): use item 5's wording (OQ-85 A).

---

## GDD text to update (round 9, owner only): decisions OQ-89 to OQ-96 and two confirmed readings (chat 28 Nov 2026)

GDD (`docs/gdd/zodiac-forest-gdd-final.md`):
1. Meta & economy › Currencies › Lives ("… refill 1 per 20 min, or buy all 5 back for 150 coins; 10 min of unlimited lives after each chapter finale"): add "A new player starts with 5 lives. The refill runs on real time, also while the game is closed: the 20 minutes start when lives drop below 5, each life back starts the next 20, another loss doesn't restart them, and they stop at 5 lives or when all 5 are bought. If the device clock is set back, no life comes back until it passes the saved time again, and no life is taken away (OQ-89 A)." Change "after each chapter finale" to "after winning a chapter finale, counted in real time from the win; during them a fail costs no life (OQ-91 A)".
2. Meta & economy › Lives (same row or a new line): "No level can be started or retried at 0 lives unless unlimited lives are running, except the chapter finales (25, 50), which can be played at 0 lives. At 0 lives the retry screen offers only waiting or buying all 5 (OQ-90 B)."
3. Interaction rules › "Quitting mid-level | Counts as a fail: …": add "Closing the app, a crash or the phone killing it mid-level counts as a quit (life lost where a fail costs one, first try used and logged, win streak reset); the next launch opens the map, not the level (OQ-92 A)."
4. Meta & economy › Booster unlocks (intro or table note): "A booster unlocks when its level is first started, so it can be used on that level. With no free uses left, each use costs its price at the moment of use; uses are never bought ahead. Pre-level boosters: one of the two per attempt, spent per attempt (a retry needs another, free or 150 coins) (OQ-93 A)."
5. Meta & economy › Currencies › Win streak ("6 wins in a row: a chest drops …"): add "The streak goes back to 0 when the chest drops (the next chest needs 6 more wins). The chest board's attempt uses the chest up, won or failed. A 6th win on level 50 gives no chest (OQ-94 A)." Optionally also say what ends a streak: "a fail (declined offer, moves out a 6th time, or a quit) sets it to 0; a win after continues counts".
6. Level progression › "Your 20/50-level upgrade milestones can sit on top of this" (and/or Open questions › upgrade flow row): add "MVP: winning 20 and 50 shows the milestone but gives nothing saved yet; rewards come with the upgrade flow (OQ-95 A)."
7. Story › Story beats, levels 1–50 (intro or a note under the table): "Each beat plays once, the first time its level is reached; retries skip it; the save remembers which were seen (OQ-96 A)."
8. Soul fragments › Rules ("Won levels cannot be replayed in the MVP") or Level progression: add "Levels are played in order, with no skipping" (confirmed reading, IR-79).
9. Meta & economy › Currencies › Coins: add "No purchase (continue, life refill, booster) can be made with fewer coins than its price; coins never go below 0" (confirmed reading, IR-80).
10. Technical design › Save file example: optional note that the save also keeps the life refill time, the unlimited-lives end time, which boosters are unlocked, the win streak and a waiting chest, seen story beats and an "attempt in progress" mark (field names are the engineer's choice).
11. Rules clarifications: add rows 89 to 96.

Added for five owner decisions without an OQ number (chat 28 Nov 2026):

12. Meta & economy › Currencies › Lives (with item 1): add "The refill countdown doesn't run during unlimited lives: a countdown running when they begin is dropped, and when they end, if lives are below 5, a fresh 20 minutes start then (also while the game is closed)."
13. Meta & economy › Currencies › Lives: add "Buying all 5 at 5 lives is refused (no coins charged) with the message 'You already have 5 lives'."
14. Technical design › Save file (with item 10): add "A save that can't be read, with no temporary copy, starts the player as a new player."
15. Meta & economy › Currencies › Win streak (with item 5) or Booster unlocks › 16 Pre-level boosters: add "A pre-level booster can be used on the chest board; the chest's Rocket and Crane are placed after the booster's specials."
16. Optional, Technical design › Level format or SaveService row: "In the MVP the save counts a fragment by the level number (26, 30, 33, 35, 38, 40, 45, 50); revisit when another guardian gets fragments."
17. Rules clarifications: add rows for items 12 to 16 if the owner keeps them there.

Brief (`research/match-villains/level_agent_brief.md`): nothing to change (these decisions are meta, not level files).

---

Owner decision with no IR (chat 28 Nov 2026): **Nian's Eye (OB09) is not in levels 1–50.** This matches GDD › Board layers & obstacles ("Nian's Eye moves to level 61"; "Hazards | None in the MVP") and CLAUDE.md's out-of-scope list. Note for level-designer: never place OB09 in levels 1–50, even though `levels_1_100_plan.csv` still lists it at levels 46–50 until the owner makes round 5 edit 14.
