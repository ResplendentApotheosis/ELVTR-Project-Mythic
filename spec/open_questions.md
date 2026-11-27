# Zodiac Forest: open rules questions

Questions the GDD (`docs/gdd/zodiac-forest-gdd-final.md`) doesn't answer, or where two parts disagree. Each lists 2 options; **the owner decides**. When answered, the owner writes the answer under "Decision" (or updates the GDD), and the Rules Keeper turns it into an IR rule.

Status: `OPEN` / `ANSWERED`. "Blocks" names the rules whose tests can't be written until it is answered.

**Summary (27 Nov 2026):** OQ-01 to OQ-22 ANSWERED in GDD › Rules clarifications. OPEN: OQ-23, plus OQ-24 to OQ-36 (new gaps found while applying those answers).

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

### OQ-23 · Continue offer: what is "can no longer be reached"? — OPEN
GDD says: Interaction rules › "Continue offer: Not shown when the remaining goals can no longer be reached". Meta › "+5 moves for 300 coins".
- Option A: Hidden only when a goal is impossible at any number of moves (e.g. not enough goal items left on the board or still to spawn).
- Option B: Hidden when the remaining goals clearly can't be done in 5 more moves (e.g. remaining hits needed > a set number per move, tuned with the bot).
Blocks: IR-37 hidden-offer test (GoalTracker, not MatchResolver).
Decision:

---

## New questions found while applying OQ-01 to OQ-22 (27 Nov 2026)

### OQ-24 · Direction of Rockets that aren't made from a line — OPEN
GDD says: Rules clarifications › OQ-01 "Fires along the line it was made from: a horizontal 4 clears its row, a vertical 4 clears its column". Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires". Core gameplay › "Leftover moves become Bamboo Rockets". Rockets made by Jade Orb + Rocket, or in the win finale, are not made from a line.
- Option A: They copy the direction of the Rocket that was swapped with the Orb (finale Rockets: the owner picks one fixed direction).
- Option B: Each one's direction is picked by the level's seeded random number generator (row or column, 50/50), so bot runs stay repeatable.
Blocks: IR-16, IR-25 (which cells the converted Rockets clear).
Decision:

### OQ-25 · Where does a special appear if the player's match doesn't include the target cell? — OPEN
GDD says: Rules clarifications › OQ-02 "On the cell the player moved into"; OQ-07 "Both resolve, and each can make its own special". In a two-match swap (IR-43) the second match runs through the swap's start cell, not the cell the player moved into.
- Option A: On the swap's start cell (the other swapped cell, which that match always contains).
- Option B: Use the cascade placement: the lowest, then left-most cell of that match (crossing cell for an L or T).
Blocks: IR-40, IR-43 (position of the second special only).
Decision:

### OQ-26 · Swapped specials that don't combo: firing cell and order with matches — OPEN
GDD says: Rules clarifications › OQ-03 "The special fires and the swap costs a move"; OQ-13 gives a centre only for combos ("The cell the player moved the special into"); OQ-18 specials "match like normal pieces". Not covered: (a) after a special + plain swap (or Crane + special swap), does the special fire from the cell it now sits in, or from the swap's target cell? It matters for which row/column a Rocket clears and where a Firecracker blasts. (b) When a swap fires a special and also makes a match, or a match includes a coloured special, which happens first, and can the special hit a special that same match has just created?
- Option A: The swap completes and each special fires from the cell it sits in after the swap; matches made by the swap resolve first (clears, neighbour hits, new specials), then the special fires, and it may set off (IR-41) a special just made.
- Option B: The special fires from the swap's target cell (as for combos); it fires first, then matches resolve, and a special made by that match is placed afterwards and is never hit by it.
Blocks: IR-39, IR-27 (firing cell), IR-21, IR-50 (order).
Decision:

### OQ-27 · Chain details — OPEN
GDD says: Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes"; OQ-11 the Firecracker's second blast comes "after pieces have fallen"; Interaction rules › Jade Orb + Jade Orb "Clears the whole board … and hits every obstacle once". Not covered: (a) the order when one special sets off several; (b) a special hit by a Firecracker's first blast waits until after the second blast; is it removed and refilled over, or does it stay put through the fall, and which cell does it fire from; (c) what a set-off Jade Orb clears; (d) whether specials cleared by Jade Orb + Jade Orb fire (which would add hits beyond "hits every obstacle once").
- Option A: Set-off specials fire in the order they were hit (same moment: top-most, then left-most); a set-off special stays in its cell and doesn't fall until it fires; a set-off Orb acts as if tapped (IR-19); specials cleared by Orb + Orb fire too.
- Option B: Set-off specials fire lowest, then left-most first; a set-off special is lifted off the board when hit and fires from that cell after the fall; a set-off Orb is removed without effect; Orb + Orb clears other specials without firing them.
Blocks: IR-41 (multi-chain and Firecracker-chain tests), IR-25 (firing order), IR-26 (specials on the board).
Decision:

### OQ-28 · The "+" shape — OPEN
GDD says: Special pieces › "L or T shape (5) | Firecracker"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule". A "+" (a line of 3 and a line of 3 crossing in the middle of both) is neither an L nor a T and contains no 4-line or 2×2.
- Option A: A "+" counts as an L/T and makes a Firecracker (crossing cell in cascades).
- Option B: A "+" makes no special; its 5 pieces just clear.
Blocks: IR-06 ("+" test only).
Decision:

### OQ-29 · Pieces under an overlay (creep moss, shutters) — OPEN
GDD says: Rules clarifications › OQ-09 "A special clears the piece and gives one hit to the top obstacle layer in that cell"; OQ-21 lists what can be swapped but not covered pieces; Cell layer model › "3 · Overlay … Cleared by Adjacent matches". Read literally, a special clears a piece under moss hp 2 and leaves the moss (hp 1) over an empty cell. Not covered: can a covered piece be swapped, fall, or be part of a match; and does an empty cell under a surviving overlay refill?
- Option A: A covered piece is locked: it can't be swapped and doesn't fall, but it can be part of a match; an emptied cell under a surviving overlay refills by normal falling.
- Option B: A covered cell is inert until its overlay is gone: its piece can't be swapped, matched or fall; an emptied cell under a surviving overlay stays empty and pieces slide past it like a blocker.
Blocks: IR-09 (overlay hp ≥ 2), IR-52 (covered pieces), IR-51 (gravity with overlays).
Decision:

### OQ-30 · Drop item swaps that make no match, or with a special — OPEN
GDD says: Rules clarifications › OQ-21 drop items can be swapped; OQ-03 "Snap-back applies only to two plain pieces"; "A Jade Orb swapped with a plain piece clears that piece's colour". Read literally, a drop item + plain piece swap with no match would not snap back and would cost a move. A drop item has no colour, so Orb + drop item is undefined, and Rocket/Firecracker/Crane + drop item isn't covered by "special swapped with a plain piece".
- Option A: A drop item swap with no match snaps back (like two plain pieces); a special swapped with a drop item fires as with a plain piece (IR-39); Orb + drop item acts as an Orb tap.
- Option B: Any accepted drop item swap uses a move (literal reading); swaps between a special and a drop item are refused.
Blocks: IR-52 (drop item swap tests), IR-01, IR-18.
Decision:

### OQ-31 · Healing dew: what does a hit or a match on dew do? — OPEN
GDD says: Obstacle set › OB04 "Matches made on dew spread it; cover the target cells"; Rules clarifications › OQ-09 "the underlay (goo or dew) takes the hit"; Interaction rules › Crane "Dew goal: an uncovered target cell". Where dew spreads to, and what "a hit" on dew means, aren't given.
- Option A: When a match or special clears a piece on a dew cell, every cell cleared by that same match or special gets dew; a Crane landing on an uncovered target cell gives it dew.
- Option B: When a dew cell takes a hit (match on top or special), dew spreads to its 4 orthogonal neighbours; a Crane landing on an uncovered target cell gives it dew.
Blocks: IR-09, IR-15, IR-48 (dew cases), and the OB04 obstacle module.
Decision:

### OQ-32 · What happens between the Firecracker's two blasts? — OPEN
GDD says: Rules clarifications › OQ-11 "Hits the same centre cell after pieces have fallen"; Combos › "Firecracker + Firecracker | 5×5 double blast". Not covered: do new pieces drop in from the top before the second blast, do matches formed by that fall resolve before the second blast, and does the 5×5 combo follow the same timing?
- Option A: Fall and refill, then the second blast; matches formed by the fall wait until after the second blast; Firecracker + Firecracker uses the same timing.
- Option B: Fall, refill and all cascades resolve fully, then the second blast; Firecracker + Firecracker uses the same timing.
Blocks: IR-17 (tests near the top rows or where a match forms between blasts), IR-24 (piece-count tests).
Decision:

### OQ-33 · Which pieces count as "of a colour" for the Jade Orb? — OPEN
GDD says: Special pieces › Orb "Clears every piece of the colour it's swapped with"; Interaction rules › "most common colour on the board"; Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces". Not covered: whether coloured specials (and pieces under an overlay) count toward the most common colour, and whether the Orb clears (and so sets off) coloured specials of that colour.
- Option A: Only plain pieces count and are cleared; coloured specials are left alone.
- Option B: Every piece with that colour counts and is cleared, including coloured specials, which then fire as a chain (IR-41); covered pieces count too.
Blocks: IR-18, IR-19, IR-25, IR-47 (boards that hold coloured specials or covered pieces).
Decision:

### OQ-34 · Paper Crane details — OPEN
GDD says: Rules clarifications › OQ-16 "It also clears its own starting cell when it takes off"; OQ-17 "the goal with the fewest hits left … Ties: closest to the Crane"; Interaction rules › "Dew goal: an uncovered target cell. Lantern shrine: counts as one piece of a colour it still needs"; "Crane swapped with another special … the other special fires first". Not covered: (a) how "closest" is measured; (b) how "hits left" is counted for dew, lantern-shrine and drop-item goals; (c) which colour a shrine landing counts as if the shrine still needs several; (d) whether take-off gives an underlay under the Crane a hit; (e) in Crane + Crane, which Crane is "the other special".
- Option A: (a) Steps along rows and columns (|dx| + |dy|); (b) dew = uncovered target cells left, shrine = pieces still needed, drop items = items still to collect; (c) the first needed colour in the order red, yellow, blue, green; (d) take-off clears the Crane only, no hit; (e) the Crane the player did not drag fires first.
- Option B: (a) Straight-line distance; (b) same as A; (c) the colour the shrine needs most of; (d) take-off counts as a special covering that cell (IR-09: underlay hit); (e) the dragged Crane fires first.
Blocks: IR-49 (distance, non-hit goals, shrine), IR-48 (take-off), IR-27 (Crane + Crane).
Decision:

### OQ-35 · Gravity details — OPEN
GDD says: Rules clarifications › OQ-19 "a piece may slide in diagonally. New pieces drop in at the top of each column, or at spawner cells where the level has them". Not covered: (a) which diagonal is tried first (from the upper-left or the upper-right) and whether slides happen only after all straight falls; (b) on a level with spawners, do columns without a spawner still refill from the top; (c) where new pieces enter a column whose top cell is not playable.
- Option A: (a) Straight falls first, then slides, upper-left before upper-right; (b) yes, every column refills at its top playable cell and spawners add extra entry points; (c) at the column's top playable cell.
- Option B: (a) Straight falls first, then slides, alternating left and right column by column; (b) no, on spawner levels only spawner cells create pieces; (c) a column whose top cell is not playable gets no new pieces except by sliding.
Blocks: IR-51 (slide direction, spawner and gap tests).
Decision:

### OQ-36 · Hoof Tap and other boosters on a cell with a piece and an obstacle layer — OPEN
Two parts of the GDD now read against each other:
- Meta & economy › Hoof Tap "Removes one single tile of the player's choice (a piece, or the top layer of one cell)"; Interaction rules › boosters "Like a special: one hit per cell, top layer only".
- Rules clarifications › OQ-09 "Pieces are not obstacle layers. A special clears the piece and gives one hit to the top obstacle layer in that cell".
For a piece on goo or under moss: does Hoof Tap (or Tail Slam / Bamboo Dash) clear only one thing, or the piece and one obstacle hit, as a special does?
- Option A: All boosters follow IR-09 exactly: clear the piece and give the top obstacle layer one hit.
- Option B: Tail Slam and Bamboo Dash follow IR-09; Hoof Tap removes only one thing: the top obstacle layer if there is one, otherwise the piece.
Blocks: IR-36 (cells holding both a piece and an obstacle layer).
Decision:

---

## New questions from the MatchResolver build (27 Nov 2026)

### OQ-37 · Jade Orb + Jade Orb on a cell with two obstacle layers — OPEN
Two parts of the GDD read against each other:
- Interaction rules › "Jade Orb + Jade Orb | Clears the whole board, collects every collectible goal item (fragments included) and hits every obstacle once". Read literally, goo (OB10) under moss (OB03) is a second obstacle in that cell and also takes a hit.
- Interaction rules › "What a special hits | Each cell it covers takes one hit, on the top layer only (overlay, then content, then underlay)" with Rules clarifications › OQ-12 "A combo counts as one special". Read this way, only the moss is hit and the goo is untouched.
- Option A: Every obstacle on the board takes one hit, on every layer (moss over goo: both lose 1). A multi-cell obstacle still takes one hit in total.
- Option B: Top layer only, as for any special (moss over goo: moss loses 1, goo untouched).
Blocks: IR-26 (stacked-layer cells only). godot-engineer currently uses Option A provisionally.
Decision:

### OQ-38 · Crane with no goal left: does healing dew count as a "remaining obstacle"? — OPEN
GDD says: Rules clarifications › OQ-17 "No goal left: the nearest remaining obstacle"; Obstacle set › OB04 "Healing dew … Matches made on dew spread it; cover the target cells" (listed as an obstacle, but it is something the player spreads, not removes); Interaction rules › "Dew goal: an uncovered target cell". Creep moss and creep goo clearly count (both are in the Obstacle set and are removed by hits); dew is not removed by hits, so "remaining" dew has no clear meaning, and what a hit on dew does is still OQ-31.
- Option A: Dew never counts as a remaining obstacle; a Crane with no goal left ignores dew cells (it may still land on one if another obstacle shares the cell).
- Option B: Uncovered dew target cells count as remaining obstacles; the Crane landing there gives the cell dew, as for a dew goal.
Blocks: IR-49 (no-goal case on boards with dew).
Decision:
