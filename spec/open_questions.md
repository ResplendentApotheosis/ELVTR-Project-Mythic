# Zodiac Forest: open rules questions

Questions the GDD (`docs/gdd/zodiac-forest-gdd-final.md`) doesn't answer, or where two parts disagree. Each lists 2 options; **the owner decides**. When answered, the owner writes the answer under "Decision" (or updates the GDD), and the Rules Keeper turns it into an IR rule.

Status: `OPEN` / `ANSWERED`. "Blocks" names the rules whose tests can't be written until it is answered.

**Summary (27 Nov 2026):** OQ-01 to OQ-22 ANSWERED in GDD › Rules clarifications. OQ-23 to OQ-38 ANSWERED by the owner in chat on 27 Nov 2026 (not yet in the GDD; see "GDD text to update" at the end). OPEN: OQ-39 to OQ-46 (parts those answers didn't settle) and OQ-47 to OQ-50 (choices godot-engineer had to make provisionally).

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
Decision: Owner decision, chat 27 Nov 2026: "Continue offer, given regardless of situation at least twice after failure." Neither option: the offer is never hidden (whether or not the goals can still be reached), and it is offered at least twice per attempt. This replaces the GDD's "not shown when…" line and "no second pop-up". Now in IR-37. (Unsettled parts: OQ-39.)

GDD says: Interaction rules › "Continue offer: Not shown when the remaining goals can no longer be reached". Meta › "+5 moves for 300 coins".
- Option A: Hidden only when a goal is impossible at any number of moves (e.g. not enough goal items left on the board or still to spawn).
- Option B: Hidden when the remaining goals clearly can't be done in 5 more moves (e.g. remaining hits needed > a set number per move, tuned with the bot).
Blocks: IR-37 hidden-offer test (GoalTracker, not MatchResolver).

---

## New questions found while applying OQ-01 to OQ-22 (27 Nov 2026)

### OQ-24 · Direction of Rockets that aren't made from a line — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: Rockets made by Jade Orb + Rocket copy the direction of the Rocket that was swapped with the Orb. Now in IR-16, IR-25, IR-05. The option left the win-finale Rockets' direction for the owner to pick: still open as OQ-40.

GDD says: Rules clarifications › OQ-01 "Fires along the line it was made from: a horizontal 4 clears its row, a vertical 4 clears its column". Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires". Core gameplay › "Leftover moves become Bamboo Rockets". Rockets made by Jade Orb + Rocket, or in the win finale, are not made from a line.
- Option A: They copy the direction of the Rocket that was swapped with the Orb (finale Rockets: the owner picks one fixed direction).
- Option B: Each one's direction is picked by the level's seeded random number generator (row or column, 50/50), so bot runs stay repeatable.
Blocks: IR-16, IR-25 (which cells the converted Rockets clear).

### OQ-25 · Where does a special appear if the player's match doesn't include the target cell? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option B: that special uses the cascade placement: the lowest, then left-most cell of its match (the crossing cell for an L, T or "+"). Now in IR-40, IR-43.

GDD says: Rules clarifications › OQ-02 "On the cell the player moved into"; OQ-07 "Both resolve, and each can make its own special". In a two-match swap (IR-43) the second match runs through the swap's start cell, not the cell the player moved into.
- Option A: On the swap's start cell (the other swapped cell, which that match always contains).
- Option B: Use the cascade placement: the lowest, then left-most cell of that match (crossing cell for an L or T).
Blocks: IR-40, IR-43 (position of the second special only).

### OQ-26 · Swapped specials that don't combo: firing cell and order with matches — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: the swap completes and each special fires from the cell it sits in after the swap; any match the swap makes resolves first (clears, neighbour hits, new specials), then the special fires, and it may set off a special that match has just made. Now in IR-39, IR-21, IR-27, IR-50. (Whether pieces fall between the match and the special firing: OQ-44.)

GDD says: Rules clarifications › OQ-03 "The special fires and the swap costs a move"; OQ-13 gives a centre only for combos ("The cell the player moved the special into"); OQ-18 specials "match like normal pieces". Not covered: (a) after a special + plain swap (or Crane + special swap), does the special fire from the cell it now sits in, or from the swap's target cell? It matters for which row/column a Rocket clears and where a Firecracker blasts. (b) When a swap fires a special and also makes a match, or a match includes a coloured special, which happens first, and can the special hit a special that same match has just created?
- Option A: The swap completes and each special fires from the cell it sits in after the swap; matches made by the swap resolve first (clears, neighbour hits, new specials), then the special fires, and it may set off (IR-41) a special just made.
- Option B: The special fires from the swap's target cell (as for combos); it fires first, then matches resolve, and a special made by that match is placed afterwards and is never hit by it.
Blocks: IR-39, IR-27 (firing cell), IR-21, IR-50 (order).

### OQ-27 · Chain details — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option B: (a) set-off specials fire lowest first, then left-most; (b) a set-off special is lifted off the board when hit and fires from that cell after the fall; (c) a set-off Jade Orb is removed without doing anything; (d) Jade Orb + Jade Orb clears other specials without firing them. Now in IR-41, IR-25 (firing order of converted specials), IR-26, IR-19, IR-21. (Whether cascades resolve before set-off specials fire: OQ-44.)

GDD says: Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes"; OQ-11 the Firecracker's second blast comes "after pieces have fallen"; Interaction rules › Jade Orb + Jade Orb "Clears the whole board … and hits every obstacle once". Not covered: (a) the order when one special sets off several; (b) a special hit by a Firecracker's first blast waits until after the second blast; is it removed and refilled over, or does it stay put through the fall, and which cell does it fire from; (c) what a set-off Jade Orb clears; (d) whether specials cleared by Jade Orb + Jade Orb fire (which would add hits beyond "hits every obstacle once").
- Option A: Set-off specials fire in the order they were hit (same moment: top-most, then left-most); a set-off special stays in its cell and doesn't fall until it fires; a set-off Orb acts as if tapped (IR-19); specials cleared by Orb + Orb fire too.
- Option B: Set-off specials fire lowest, then left-most first; a set-off special is lifted off the board when hit and fires from that cell after the fall; a set-off Orb is removed without effect; Orb + Orb clears other specials without firing them.
Blocks: IR-41 (multi-chain and Firecracker-chain tests), IR-25 (firing order), IR-26 (specials on the board).

### OQ-28 · The "+" shape — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: a "+" counts as an L/T and makes a Firecracker (on the crossing cell in cascades). Now in IR-06, IR-40.

GDD says: Special pieces › "L or T shape (5) | Firecracker"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule". A "+" (a line of 3 and a line of 3 crossing in the middle of both) is neither an L nor a T and contains no 4-line or 2×2.
- Option A: A "+" counts as an L/T and makes a Firecracker (crossing cell in cascades).
- Option B: A "+" makes no special; its 5 pieces just clear.
Blocks: IR-06 ("+" test only).

### OQ-29 · Pieces under an overlay (creep moss, shutters) — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: a covered piece is locked: it can't be swapped and doesn't fall, but it can be part of a match; a cell emptied under a surviving overlay refills by normal falling. Now in IR-54 (new), IR-52, IR-51, IR-09. (Not settled by the option: what a match through a covered piece does to the piece and layers, the shuffle, and filling the cell below a locked piece: OQ-41.)

GDD says: Rules clarifications › OQ-09 "A special clears the piece and gives one hit to the top obstacle layer in that cell"; OQ-21 lists what can be swapped but not covered pieces; Cell layer model › "3 · Overlay … Cleared by Adjacent matches". Read literally, a special clears a piece under moss hp 2 and leaves the moss (hp 1) over an empty cell. Not covered: can a covered piece be swapped, fall, or be part of a match; and does an empty cell under a surviving overlay refill?
- Option A: A covered piece is locked: it can't be swapped and doesn't fall, but it can be part of a match; an emptied cell under a surviving overlay refills by normal falling.
- Option B: A covered cell is inert until its overlay is gone: its piece can't be swapped, matched or fall; an emptied cell under a surviving overlay stays empty and pieces slide past it like a blocker.
Blocks: IR-09 (overlay hp ≥ 2), IR-52 (covered pieces), IR-51 (gravity with overlays).

### OQ-30 · Drop item swaps that make no match, or with a special — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: a drop item swap that makes no match snaps back (no move used), like two plain pieces; a Rocket, Firecracker or Crane swapped with a drop item fires as with a plain piece; a Jade Orb swapped with a drop item acts as an Orb tap. Now in IR-01, IR-39, IR-18, IR-52.

GDD says: Rules clarifications › OQ-21 drop items can be swapped; OQ-03 "Snap-back applies only to two plain pieces"; "A Jade Orb swapped with a plain piece clears that piece's colour". Read literally, a drop item + plain piece swap with no match would not snap back and would cost a move. A drop item has no colour, so Orb + drop item is undefined, and Rocket/Firecracker/Crane + drop item isn't covered by "special swapped with a plain piece".
- Option A: A drop item swap with no match snaps back (like two plain pieces); a special swapped with a drop item fires as with a plain piece (IR-39); Orb + drop item acts as an Orb tap.
- Option B: Any accepted drop item swap uses a move (literal reading); swaps between a special and a drop item are refused.
Blocks: IR-52 (drop item swap tests), IR-01, IR-18.

### OQ-31 · Healing dew: what does a hit or a match on dew do? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: when a match or special clears a piece on a dew cell, every cell cleared by that same match or special gets dew; a Crane landing on an uncovered target cell gives it dew. Now in IR-53 (new), IR-15, IR-48. (Cells in a special's area that held no piece: OQ-46.)

GDD says: Obstacle set › OB04 "Matches made on dew spread it; cover the target cells"; Rules clarifications › OQ-09 "the underlay (goo or dew) takes the hit"; Interaction rules › Crane "Dew goal: an uncovered target cell". Where dew spreads to, and what "a hit" on dew means, aren't given.
- Option A: When a match or special clears a piece on a dew cell, every cell cleared by that same match or special gets dew; a Crane landing on an uncovered target cell gives it dew.
- Option B: When a dew cell takes a hit (match on top or special), dew spreads to its 4 orthogonal neighbours; a Crane landing on an uncovered target cell gives it dew.
Blocks: IR-09, IR-15, IR-48 (dew cases), and the OB04 obstacle module.

### OQ-32 · What happens between the Firecracker's two blasts? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option B: after the first blast, pieces fall, new pieces refill and all cascade matches resolve fully; then the second blast; Firecracker + Firecracker uses the same timing. Now in IR-17, IR-24.

GDD says: Rules clarifications › OQ-11 "Hits the same centre cell after pieces have fallen"; Combos › "Firecracker + Firecracker | 5×5 double blast". Not covered: do new pieces drop in from the top before the second blast, do matches formed by that fall resolve before the second blast, and does the 5×5 combo follow the same timing?
- Option A: Fall and refill, then the second blast; matches formed by the fall wait until after the second blast; Firecracker + Firecracker uses the same timing.
- Option B: Fall, refill and all cascades resolve fully, then the second blast; Firecracker + Firecracker uses the same timing.
Blocks: IR-17 (tests near the top rows or where a match forms between blasts), IR-24 (piece-count tests).

### OQ-33 · Which pieces count as "of a colour" for the Jade Orb? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: only plain pieces count toward "most common colour" and only plain pieces are cleared; coloured specials (Rockets, Firecrackers, Cranes) are left alone. Now in IR-18, IR-19, IR-25, IR-47. (Option A doesn't say whether plain pieces under an overlay count: OQ-42.)

GDD says: Special pieces › Orb "Clears every piece of the colour it's swapped with"; Interaction rules › "most common colour on the board"; Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces". Not covered: whether coloured specials (and pieces under an overlay) count toward the most common colour, and whether the Orb clears (and so sets off) coloured specials of that colour.
- Option A: Only plain pieces count and are cleared; coloured specials are left alone.
- Option B: Every piece with that colour counts and is cleared, including coloured specials, which then fire as a chain (IR-41); covered pieces count too.
Blocks: IR-18, IR-19, IR-25, IR-47 (boards that hold coloured specials or covered pieces).

### OQ-34 · Paper Crane details — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option B: (a) "closest" = straight-line distance; (b) hits left: dew = uncovered target cells left, lantern shrine = pieces still needed, drop items = items still to collect; (c) a shrine landing counts as the colour the shrine needs most of; (d) take-off counts as a special covering the Crane's own cell (the top obstacle layer there, e.g. goo underneath, takes one hit); (e) in Crane + Crane, the Crane the player dragged flies first. Now in IR-49, IR-48, IR-27. (A shrine needing two colours equally: OQ-43.)

GDD says: Rules clarifications › OQ-16 "It also clears its own starting cell when it takes off"; OQ-17 "the goal with the fewest hits left … Ties: closest to the Crane"; Interaction rules › "Dew goal: an uncovered target cell. Lantern shrine: counts as one piece of a colour it still needs"; "Crane swapped with another special … the other special fires first". Not covered: (a) how "closest" is measured; (b) how "hits left" is counted for dew, lantern-shrine and drop-item goals; (c) which colour a shrine landing counts as if the shrine still needs several; (d) whether take-off gives an underlay under the Crane a hit; (e) in Crane + Crane, which Crane is "the other special".
- Option A: (a) Steps along rows and columns (|dx| + |dy|); (b) dew = uncovered target cells left, shrine = pieces still needed, drop items = items still to collect; (c) the first needed colour in the order red, yellow, blue, green; (d) take-off clears the Crane only, no hit; (e) the Crane the player did not drag fires first.
- Option B: (a) Straight-line distance; (b) same as A; (c) the colour the shrine needs most of; (d) take-off counts as a special covering that cell (IR-09: underlay hit); (e) the dragged Crane fires first.
Blocks: IR-49 (distance, non-hit goals, shrine), IR-48 (take-off), IR-27 (Crane + Crane).

### OQ-35 · Gravity details — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: (a) straight falls first, then diagonal slides, trying the upper-left before the upper-right; (b) every column refills at its top playable cell, and spawners add extra entry points; (c) a column whose top cell is not playable gets new pieces at its top playable cell. Now in IR-51. (Columns with a non-playable cell in the middle: OQ-45.)

GDD says: Rules clarifications › OQ-19 "a piece may slide in diagonally. New pieces drop in at the top of each column, or at spawner cells where the level has them". Not covered: (a) which diagonal is tried first (from the upper-left or the upper-right) and whether slides happen only after all straight falls; (b) on a level with spawners, do columns without a spawner still refill from the top; (c) where new pieces enter a column whose top cell is not playable.
- Option A: (a) Straight falls first, then slides, upper-left before upper-right; (b) yes, every column refills at its top playable cell and spawners add extra entry points; (c) at the column's top playable cell.
- Option B: (a) Straight falls first, then slides, alternating left and right column by column; (b) no, on spawner levels only spawner cells create pieces; (c) a column whose top cell is not playable gets no new pieces except by sliding.
Blocks: IR-51 (slide direction, spawner and gap tests).

### OQ-36 · Hoof Tap and other boosters on a cell with a piece and an obstacle layer — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option A: every booster (Hoof Tap included) follows IR-09 exactly: it clears the piece and gives the top obstacle layer one hit. Now in IR-36, IR-09. This differs from the GDD's Hoof Tap text "a piece, or the top layer of one cell".

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
Decision: Owner decision, chat 27 Nov 2026 › Option B: top layer only, as for any special: moss over goo → the moss loses 1 and the goo is untouched. Now in IR-26. (The provisional code used Option A and must change.)

Two parts of the GDD read against each other:
- Interaction rules › "Jade Orb + Jade Orb | Clears the whole board, collects every collectible goal item (fragments included) and hits every obstacle once". Read literally, goo (OB10) under moss (OB03) is a second obstacle in that cell and also takes a hit.
- Interaction rules › "What a special hits | Each cell it covers takes one hit, on the top layer only (overlay, then content, then underlay)" with Rules clarifications › OQ-12 "A combo counts as one special". Read this way, only the moss is hit and the goo is untouched.
- Option A: Every obstacle on the board takes one hit, on every layer (moss over goo: both lose 1). A multi-cell obstacle still takes one hit in total.
- Option B: Top layer only, as for any special (moss over goo: moss loses 1, goo untouched).
Blocks: IR-26 (stacked-layer cells only). godot-engineer currently uses Option A provisionally.

### OQ-38 · Crane with no goal left: does healing dew count as a "remaining obstacle"? — ANSWERED
Decision: Owner decision, chat 27 Nov 2026 › Option B: uncovered dew target cells count as remaining obstacles for a Crane with no goal left; the Crane landing there gives the cell dew. Now in IR-49, IR-53.

GDD says: Rules clarifications › OQ-17 "No goal left: the nearest remaining obstacle"; Obstacle set › OB04 "Healing dew … Matches made on dew spread it; cover the target cells" (listed as an obstacle, but it is something the player spreads, not removes); Interaction rules › "Dew goal: an uncovered target cell". Creep moss and creep goo clearly count (both are in the Obstacle set and are removed by hits); dew is not removed by hits, so "remaining" dew has no clear meaning, and what a hit on dew does is still OQ-31.
- Option A: Dew never counts as a remaining obstacle; a Crane with no goal left ignores dew cells (it may still land on one if another obstacle shares the cell).
- Option B: Uncovered dew target cells count as remaining obstacles; the Crane landing there gives the cell dew, as for a dew goal.
Blocks: IR-49 (no-goal case on boards with dew).

---

## New questions from applying the owner's answers to OQ-23 to OQ-38 (27 Nov 2026)

### OQ-39 · Continue offer: how many, what price, and what if declined? — OPEN
Owner decision (chat 27 Nov 2026 › OQ-23): "Continue offer, given regardless of situation at least twice after failure." GDD › Meta & economy › Continue: "+5 moves" for 300 coins. IR-37 now uses the literal reading: offered every time moves run out, at least the first and second time in an attempt, each "+5 moves for 300 coins". Not settled:
- (a) Is there a maximum? "At least twice" sets a minimum only.
- (b) Does the second offer cost 300 coins like the first?
- (c) If the player declines an offer, does the attempt end (GDD › Fail flow "then the retry screen"), or is the offer shown a second time for the same fail ("twice after failure")?
- (d) Is the offer shown to a player with fewer than 300 coins ("regardless of situation")?
- Option A: (a) exactly two offers per attempt; (b) 300 coins each; (c) declining goes straight to the retry screen; (d) shown, but it can't be accepted without 300 coins.
- Option B: (a) no limit: an offer every time moves run out; (b) 300 coins each; (c) a declined offer is shown once more before the retry screen; (d) not shown; straight to the retry screen.
Blocks: IR-37 (third-fail, decline and low-coin tests).
Decision:

### OQ-40 · Direction of the win-finale Rockets — OPEN
GDD says: Core gameplay › "Leftover moves become Bamboo Rockets that fire for bonus coins"; Audio › "Leftover moves fire as rockets 0.15 s apart". OQ-24's chosen Option A said "finale Rockets: the owner picks one fixed direction", but no direction was picked.
- Option A: All finale Rockets are row Rockets.
- Option B: All finale Rockets are column Rockets.
Blocks: IR-16 (finale Rockets only), the win-finale code.
Decision:

### OQ-41 · Locked covered pieces: matches, shuffle and the cell below — OPEN
Owner decision (chat 27 Nov 2026 › OQ-29, Option A): a covered piece "can't be swapped and doesn't fall, but it can be part of a match". Not settled:
- (a) When a covered piece is part of a match, is the piece cleared, does the overlay take a hit, and does an underlay beneath it (e.g. goo) take the "match on top" hit (IR-15)?
- (b) Does the free shuffle (IR-33) move covered pieces? (OQ-22 says the shuffle moves "plain pieces and specials".)
- (c) A cell below a locked piece is emptied: the locked piece blocks the straight fall from above. Is that cell filled by a diagonal slide as if the locked piece were a blocker (IR-51), or does it stay empty?
- Option A: (a) the piece is cleared and the overlay takes one hit; the underlay below is not hit while the overlay was there; (b) the shuffle leaves covered pieces where they are; (c) the locked piece counts as a blocker, so the cell below fills by a diagonal slide.
- Option B: (a) the piece is cleared, the overlay takes one hit and the underlay below also takes one hit; (b) the shuffle may move covered pieces (the overlay stays in its cell); (c) the cell below stays empty until the overlay is gone.
Blocks: IR-54, IR-14 (matches through covered pieces), IR-33, IR-51.
Decision:

### OQ-42 · Jade Orb and plain pieces under an overlay — OPEN
Owner decision (chat 27 Nov 2026 › OQ-33, Option A): "Only plain pieces count and are cleared". The question also asked about pieces under an overlay, which Option A doesn't mention (Option B said "covered pieces count too"). Rules clarifications › OQ-09: "A Jade Orb covers every cell whose piece it clears".
- Option A: Covered plain pieces count toward "most common colour" and are cleared; the Orb then covers that cell, so the overlay takes one hit (IR-09).
- Option B: Covered plain pieces neither count nor are cleared; their cells are untouched.
Blocks: IR-18, IR-19, IR-25, IR-47 (boards with covered pieces).
Decision:

### OQ-43 · Crane landing on a shrine that needs two colours equally — OPEN
Owner decision (chat 27 Nov 2026 › OQ-34, Option B (c)): a shrine landing counts as "the colour the shrine needs most of". Not settled: a shrine that still needs, say, 2 R and 2 B.
- Option A: Ties broken in the fixed order red, yellow, blue, green (as for the Jade Orb, IR-47).
- Option B: Ties broken by the level's seeded random number generator.
Blocks: IR-49 (shrine tie test only).
Decision:

### OQ-44 · Do pieces fall, and cascades resolve, before a waiting special fires? — OPEN
Owner decisions (chat 27 Nov 2026): OQ-26 Option A "matches made by the swap resolve first (clears, neighbour hits, new specials), then the special fires"; OQ-27 Option B "a set-off special … fires from that cell after the fall"; OQ-32 Option B (for the Firecracker) "Fall, refill and all cascades resolve fully, then the second blast". Not settled: (a) after a swap's match clears, do pieces fall before the swapped special fires; (b) after the first special in a chain, do cascade matches resolve before the set-off specials fire, or only the fall and refill?
- Option A: Only the fall and refill happen before a waiting special fires; cascade matches resolve after it has fired (swap: match clears, fall, refill, special fires, then cascades; chain: first special, fall, refill, set-off specials fire, then cascades).
- Option B: Fall, refill and all cascades resolve fully before a waiting special fires, as between the Firecracker's blasts.
Blocks: IR-39, IR-41, IR-21 (tests where a piece below the special is cleared, or where a match forms before a set-off special fires).
Decision:

### OQ-45 · Columns with a non-playable cell in the middle — OPEN
GDD says: Rules clarifications › OQ-19 "Pieces fall straight down; where a cell can't be filled from above because of a blocker, a piece may slide in diagonally". Owner decision (chat 27 Nov 2026 › OQ-35, Option A) covers a column whose **top** cell isn't playable, not a gap lower down (e.g. (3,4) not playable, (3,5) emptied).
- Option A: Pieces pass straight through non-playable cells to the playable cells below them.
- Option B: A non-playable cell stops straight falls like a blocker; the cells below it fill by diagonal slides.
Blocks: IR-51 (gap tests). Note: godot-engineer's provisional code lets pieces fall through holes (Option A).
Decision:

### OQ-46 · Dew spreading onto cells that held no piece — OPEN
Owner decision (chat 27 Nov 2026 › OQ-31, Option A): "every cell cleared by that same match or special gets dew". A special's area can include cells with no piece (a bramble, a pillar, a cocoon, an empty cell), where the special only hits an obstacle.
- Option A: Only cells whose piece was cleared get dew.
- Option B: Every playable cell the special covers gets dew, including cells where it only hit an obstacle.
Blocks: IR-53 (specials whose area includes obstacle cells).
Decision:

---

## New questions from godot-engineer's provisional choices (27 Nov 2026)

The code already does one option of each question below (marked "provisional"). Tests for the blocked part aren't written until the owner picks; if the owner picks another option, the code changes.

### OQ-47 · A chain inside a chain: which waiting special fires next? — OPEN
GDD says: Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes". Owner decision (chat 27 Nov 2026 › OQ-27, Option B): "Set-off specials fire lowest, then left-most first". Not settled: when a set-off special, while firing, sets off a further special, does that new one wait its turn with the specials already waiting, or does it fire before them?
Example: tap a row Rocket at (0,4); it sets off column Rocket A at (2,4) and column Rocket C at (6,4). A fires first (same row, left-most) and its column sets off row Rocket B at (2,1). Who fires next, C or B?
- Option A (provisional, what the code does now): one shared waiting list; the lowest, then left-most waiting special always fires next. In the example C (row 4) fires before B (row 1).
- Option B: each set-off special finishes its own chain first (the specials it set off fire, lowest then left-most, before any special that was already waiting). In the example B fires before C.
Blocks: IR-41 (chains of 3 or more specials), IR-21.
Decision:

### OQ-48 · Jade Orb + Rocket/Firecracker: where are the converted specials while they wait? — OPEN
GDD says: Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires". Owner decisions (chat 27 Nov 2026): OQ-27 Option B "lowest, then left-most first"; OQ-32 Option B (pieces fall, refill and cascades resolve between a Firecracker's two blasts). So pieces can fall while converted specials are still waiting their turn. Not settled: can a waiting converted special be moved by those falls?
- Option A (provisional, what the code does now): every converted piece leaves the board at once (like a lifted set-off special, IR-41) and its cell refills by normal falling; each then fires from the cell it was converted in, lowest then left-most, each finishing (falls included) before the next.
- Option B: converted specials stay on the board as specials and fall like other pieces; each fires from the cell it is in when its turn comes (turn order fixed at conversion: lowest, then left-most); a blast that covers a waiting converted special doesn't set it off (it is already part of the combo).
Note: whether cascade matches resolve between converted specials follows the answer to OQ-44.
Blocks: IR-25 (any test where pieces below a converted special are cleared before it fires), IR-45 with IR-25.
Decision:

### OQ-49 · Crane landing on an uncovered dew target: is the piece there cleared? — OPEN
GDD says: Rules clarifications › OQ-16 "Gives one hit to its target cell, or collects the fragment or drop item there"; OQ-09 "A special clears the piece and gives one hit to the top obstacle layer". Owner decision (chat 27 Nov 2026 › OQ-31, Option A): "a Crane landing on an uncovered target cell gives it dew". Not settled: is the dew given instead of the normal hit (the piece there stays), or as well as it (the piece is cleared, as a special covering the cell would do)?
- Option A (provisional, what the code does now, and how IR-48's "or otherwise" currently reads): the landing gives the cell dew only; the piece there stays.
- Option B: the landing counts as a special covering the cell (the piece there is cleared, IR-09) and the cell gets dew.
Blocks: IR-48, IR-53, IR-49 (the piece in the landing cell on dew-goal and no-goal dew landings).
Decision:

### OQ-50 · Lantern shrine (OB05): what do specials and matches do to it? — OPEN
GDD says: Obstacle set › OB05 "Lantern shrine … Collect the colours it shows to light it"; Interaction rules › Crane "Lantern shrine: counts as one piece of a colour it still needs"; "What a special hits | Each cell it covers takes one hit"; "Which obstacles are multi-cell | … any obstacle drawn across 2 or more cells". The brief gives shrines an `hp` field. Nothing says (a) what a special's hit does to a shrine, or (b) how pieces are "collected" into it. OB05 debuts at level 10, so this blocks levels 10–12, 16, 20, 24, 25 and later.
- Option A (provisional, what the code does now for (a)): (a) a special's hit lowers the shrine's `hp` by 1 (one hit per special, IR-10) but doesn't change the colours it still needs; (b) not decided (the code doesn't fill shrines from matches yet).
- Option B: (a) a special's hit counts as one piece of the colour the shrine needs most, as for a Crane landing (IR-49); (b) each piece of a needed colour in a match next to the shrine fills it by one.
- Option C: (a) specials don't affect a shrine at all (only collected colours and the Crane landing light it); (b) every matched piece of a needed colour anywhere on the board fills it by one.
(For (b) the owner may also mix: e.g. Option A's (a) with Option B's (b).)
Blocks: the OB05 obstacle module; no IR for OB05 exists yet beyond IR-11 (multi-cell) and IR-49 (Crane landing).
Decision:

---

## GDD text to update (owner only)

The owner's answers above now differ from or add to these GDD lines. The spec follows the owner's answers.

Contradictions (the GDD text now says something different):
1. Interaction rules › "Continue offer | Not shown when the remaining goals can no longer be reached" (OQ-23: shown regardless).
2. Meta & economy › Continue › "One optional '+5 moves' for 300 coins per attempt; no second pop-up" (OQ-23: at least twice).
3. Core gameplay › Fail flow › "one optional '+5 moves' for coins, then the retry screen" (OQ-23: at least twice).
4. Competitor table (line ~57) › "One optional continue" (OQ-23).
5. Rules clarifications intro › "OQ-23 belongs to GoalTracker and stays open" (now answered).
6. Rules clarifications › OQ-04 "It fires too (a chain)" (OQ-27: a set-off Jade Orb does nothing, and Orb + Orb clears other specials without firing them).
7. Meta & economy › Hoof Tap › "Removes one single tile … (a piece, or the top layer of one cell)" (OQ-36: clears the piece and hits the top layer).
8. Interaction rules › "Jade Orb + Jade Orb | … hits every obstacle once" (OQ-37: only the top layer of each cell, so goo under moss is not hit).
9. Rules clarifications › OQ-21 "Any two orthogonally adjacent pieces" (OQ-29: covered pieces can't be swapped).
10. Rules clarifications › OQ-19 "Pieces fall straight down" (OQ-29: covered pieces don't fall).
11. Rules clarifications › OQ-03 "Snap-back applies only to two plain pieces" (OQ-30: drop item swaps with no match snap back too).
12. Special pieces › Jade Orb "Clears every piece of the colour it's swapped with", with OQ-18 "match like normal pieces" (OQ-33: only plain pieces are counted and cleared).

Additions (new detail the GDD doesn't have yet): OQ-24 (converted Rocket direction), OQ-25 (second special placement), OQ-26 (firing cell and order), OQ-27 (chain order, lifted specials), OQ-28 ("+" shape), OQ-31 (dew spreading), OQ-32 (between blasts), OQ-34 (Crane distance, goal counts, shrine colour, take-off hit, Crane + Crane), OQ-35 (gravity), OQ-38 (dew as a no-goal target).
