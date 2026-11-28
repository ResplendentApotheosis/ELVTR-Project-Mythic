# Zodiac Forest: Interaction rules spec

Derived only from `docs/gdd/zodiac-forest-gdd-final.md` (the GDD wins over this file). Owner decisions OQ-01 to OQ-38 are in the GDD's "Rules clarifications" table and are cited as "Rules clarifications › OQ-xx". Owner decisions OQ-39 to OQ-61, given in chat on 27 Nov 2026 and not yet in the GDD, are cited as "Owner decision, chat 27 Nov 2026 › OQ-xx"; OQ-62 to OQ-97 (OQ-64 changed by the owner later the same day), given in chat on 28 Nov 2026, are cited as "Owner decision, chat 28 Nov 2026 › OQ-xx". IDs are permanent: never renumber; a removed rule is marked `RETIRED` and kept. Gaps and conflicts live in `spec/open_questions.md` (OQ-xx), never here. New rules are numbered after IR-38 but filed in the section they belong to (see the index).

**Conventions used in test cases**
- Coordinates are `(x, y)`; `x` = column from the left, `y` = row from the top (row 0 is the top row), matching the level JSON schema.
- "Lowest" = largest `y`; "top-most" = smallest `y`; "left-most" = smallest `x`.
- Colours: R = red peach, Y = yellow bell, B = blue fan, G = green leaf. A bare letter is a plain piece.
- "Swap A→B" = the player drags the piece at A into B. B is the swap's **target cell** ("the cell the player moved into"); A is the **start cell**. After the swap, the dragged piece sits in B and the other piece sits in A.
- "Adjacent" / "next to" always means directly above, below, left or right, never diagonal (GDD › Rules clarifications › OQ-08).
- "Hit" = one hit to the top **obstacle** layer of a cell (overlay, then content blocker or container, then underlay). Pieces are not obstacle layers (IR-09).
- "Distance" between cells = straight-line distance, √(dx² + dy²) (IR-49).
- "Emptied directly" = the test harness removes the piece (no match, no special), then the board settles.
- Unless a test says otherwise, the board is 9×9, fully playable, and the rest of the board contains no match before or after the action (refills in tests use a seed or a fixed sequence that makes no match).
- Where part of a rule depends on an open question, the rule lists it under "Blocked by" and only the unblocked test cases are written.

**Index**

| Section | Rules |
|---|---|
| A. Swaps, taps and moves | IR-01, IR-02, IR-39, IR-52 |
| B. Match detection and special creation | IR-03 to IR-08, IR-40, IR-42, IR-43, IR-50 |
| C. Damage to layers and obstacles | IR-09 to IR-15, IR-44, IR-45, IR-53, IR-54, IR-55, IR-74 |
| D. Special effects | IR-16 to IR-21, IR-41, IR-47, IR-48, IR-49 |
| E. Combos | IR-22 to IR-27, IR-46 |
| F. Soul fragments and drop items | IR-28 to IR-31 |
| G. Gravity, refill, cascades, shuffle | IR-32, IR-33, IR-51 |
| H. Hero boosters | IR-34 to IR-36, IR-62 |
| I. Level flow | IR-37, IR-38, IR-56 to IR-61, IR-90 |
| J. Level files (LevelLoader and validator) | IR-63 to IR-73, IR-75 to IR-77, IR-89 |
| K. Save, progress and meta (SaveService) | IR-78 to IR-88 |

---

## A. Swaps, taps and moves

### IR-01 · A plain or drop-item swap that makes no match snaps back (CHANGED)
Rule: A swap between two plain pieces, or between a drop item and a plain piece or another drop item, uses one move if it makes a match; if it makes no match it snaps back and uses no move.
Applies to: Plain + plain, drop item + plain, drop item + drop item. Special + plain piece or drop item: IR-39 (and IR-18 for the Orb). Special + special: IR-22 to IR-27. What can be swapped at all: IR-52.
Source: GDD › Core gameplay › Rules › "Swap two adjacent pieces; a swap that makes no match snaps back (no move used)."; Rules clarifications › OQ-03 "Snap-back applies to two plain pieces, and to a drop item swapped with a plain piece (no move used)", OQ-30 "Drop item swaps | No match: snaps back with no move used".
Test cases:
- Moves 20. R at (2,4),(3,4), Y at (4,4), R at (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clears; moves = 19.
- Moves 20. Swap two plain pieces that form no line of 3 and no 2×2 → board identical to before; moves = 20; an "invalid swap" event is returned.
- Moves 20. Lost hatchling (OB11) at (4,4), Y at (4,5); swap (4,5)→(4,4) makes no match → snaps back: hatchling still at (4,4), Y at (4,5); moves = 20; "invalid swap" event.
- Moves 20. Hatchling at (4,4); R at (2,4),(3,4) and (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clears; moves = 19 (see IR-52).

### IR-02 · Tapping a special fires it and costs a move (CHANGED)
Rule: Tapping an uncovered special fires it and uses one move; tapping anything else, including a special locked under an overlay (IR-54), does nothing and uses no move.
Applies to: Bamboo Rocket, Firecracker, Paper Crane, Jade Orb (Orb tap effect: IR-19). Covered specials: IR-54. A covered special can't be tapped by the player, but a Hoof Tap on it: IR-36 (OQ-108).
Source: GDD › Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Interaction rules › "Tapping a Jade Orb … costs a move like any tap"; Owner decision, chat 27 Nov 2026 › OQ-57 (Option A: "locked like any covered piece: it can't be swapped, doesn't fall and can't be tapped").
Test cases:
- Moves 10. Tap a Firecracker at (4,4) → it fires (IR-17); moves = 9.
- Moves 10. Tap a plain piece → nothing happens; moves = 10.
- Moves 10. Row Rocket at (2,6) under creep moss (OB03) hp 1. Tap (2,6) → no fire event; board unchanged; moves = 10.

### IR-39 · A special swapped with a plain piece or drop item fires from its new cell, after the swap's matches (CHANGED)
Rule: Swapping a Bamboo Rocket, Firecracker or Paper Crane with an adjacent plain piece or drop item is never snapped back: the swap completes and uses one move; any match the swap makes resolves first (clears, neighbour hits, new specials) and, if the swap made a match, the swapped special is lifted off the board at that moment (like a set-off special, IR-41: it no longer falls or takes hits, and its cell refills in the fall); pieces fall and refill (cascade matches don't resolve yet), and then the special fires from the cell it sat in right after the swap, possibly setting off (IR-41) a special that match has just made; cascade matches resolve only after it (and any specials it set off) has finished.
Applies to: Rocket, Firecracker or Crane + plain piece or drop item. Jade Orb + plain piece or drop item: IR-18. Crane + special: IR-27. A Firecracker's own two blasts still have cascades in between (IR-17). A lifted Crane's take-off: IR-48.
Source: GDD › Rules clarifications › OQ-03 "The special fires and the swap costs a move. Snap-back applies to two plain pieces, and to a drop item swapped with a plain piece", OQ-26 "The swap completes; any match it makes resolves first, then each special fires from the cell it sits in", OQ-30 "A Rocket, Firecracker or Crane swapped with a drop item fires as with a plain piece"; setting off a just-made special follows OQ-04; Owner decision, chat 27 Nov 2026 › OQ-44 (Option A: "Only the fall and refill happen before a waiting special fires; cascade matches resolve after it has fired (swap: match clears, fall, refill, special fires, then cascades)"), OQ-54 (Option A: "Both are lifted off the board as the match resolves, like a set-off special (IR-41): their cells refill in the fall, and each fires from the cell it was in right after the swap").
Test cases:
- Moves 10. Row Rocket at (4,4), Y at (4,5); swap (4,5)→(4,4) makes no match → accepted; moves = 9; the Rocket (now at (4,5)) clears all 9 cells of row 5; no cell of row 4 is cleared by it.
- Moves 10. R at (2,4),(3,4); yellow Firecracker at (4,4); R at (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clear and the Firecracker (now at (4,5)) is lifted; fall: columns 2 and 3 drop by one (pieces from (2,3),(3,3) into (2,4),(3,4)); in column 4 both (4,4) and (4,5) are empty, so pieces from (4,0)–(4,3) move to (4,2)–(4,5); refill: new pieces at (2,0),(3,0),(4,0),(4,1); then the Firecracker fires with both blasts centred on (4,5) (area x 3–5, y 4–6), so blast 1 clears the pieces that fell into (3,4), (4,4) and (4,5); events in order: match clear, fall, refill, blast 1; moves = 9.
- Moves 10. R at (5,6),(6,6); column Rocket (colour B) at (7,6); R at (7,7); G at (4,6),(5,5),(6,5); Y at (4,5),(7,5); B at (5,4); R at (6,4). Swap (7,7)→(7,6) → R at (5,6),(6,6),(7,6) clear and the Rocket (now at (7,7)) is lifted; pieces fall (columns 5 and 6 by one, so G now sits at (4,6),(5,6),(6,6); column 7 by two: pieces from (7,0)–(7,5) move to (7,2)–(7,7)); refill; the Rocket fires along column 7 from (7,7); fall, refill; only then do G at (4,6),(5,6),(6,6) clear as a cascade match. Events in order: match clear, fall, refill, Rocket fire (column 7), fall, refill, match clear (4,6)–(6,6).
- Moves 10. Row Rocket (colour B) at (4,5); R at (4,4); R at (2,5),(3,5). Swap (4,5)→(4,4) → the Rocket moves to (4,4) and R to (4,5); R at (2,5),(3,5),(4,5) clear and the Rocket is lifted from (4,4); fall: columns 2 and 3 drop by one; in column 4 pieces from (4,0)–(4,3) move to (4,2)–(4,5); refill; then the Rocket fires along **row 4** (the row of (4,4), its cell right after the swap), not row 5: all 9 cells of row 4 are cleared, including the piece that fell from (4,2) into (4,4); no cell of row 5 is cleared by it. Events in order: match clear, fall, refill, Rocket fire (row 4); moves = 9.
- Moves 10. Paper Crane at (4,4), G at (4,3); swap (4,4)→(4,3) makes no match → moves = 9; the Crane fires from (4,3) (crane take-off event at (4,3), IR-48).
- Moves 10. Firecracker at (4,4), hatchling (OB11) at (4,5); swap (4,5)→(4,4) → accepted; moves = 9; the Firecracker fires centred on (4,5); the hatchling (now at (4,4), inside the blast) is not destroyed and not collected (IR-28, IR-30).
- Moves 10. Same set-ups with two plain pieces instead and no match → snaps back; moves = 10 (IR-01).

### IR-52 · What can be swapped (CHANGED)
Rule: A swap is only accepted between two orthogonally adjacent cells that each hold an uncovered plain piece, special or drop item; swaps involving an obstacle, a cocooned fragment, an empty cell or a piece under an overlay (IR-54), and diagonal swaps, are refused and change nothing (no move used).
Applies to: Every swap attempt. Accepted swaps that make no match: IR-01 (snap-back) or IR-39 (special fires).
Source: GDD › Rules clarifications › OQ-21 "Any two orthogonally adjacent pieces, including specials and drop items. Not obstacles, cocooned fragments, empty cells, or pieces locked under an overlay (moss, shutter)", OQ-29 "Locked: can't be swapped", OQ-30.
Test cases:
- Moves 10. Withered bramble (OB02) at (4,4), R at (4,5). Swap (4,5)→(4,4) → refused; board unchanged; moves = 10.
- Moves 10. Swap (3,3)→(4,4) (diagonal) → refused; board unchanged; moves = 10.
- Moves 10. Cocoon with a fragment (OB07) at (2,2), Y at (3,2). Swap (3,2)→(2,2) → refused; moves = 10.
- Moves 10. Lost hatchling (OB11) at (4,4); R at (2,4),(3,4) and (4,5). Swap (4,5)→(4,4) → accepted; R at (2,4),(3,4),(4,4) clears; the hatchling is now at (4,5) (then falls, IR-51); moves = 9.
- Moves 10. Creep moss (OB03) hp 1 over R at (4,4); Y at (4,5). Swap (4,5)→(4,4) → refused; swap (4,4)→(4,5) → refused; board unchanged; moves = 10.

---

## B. Match detection and special creation

### IR-03 · Three or more in a line clears
Rule: Three or more same-colour pieces in a row or column are a match and clear.
Applies to: All plain pieces, and coloured specials (IR-50), on every level.
Source: GDD › Core gameplay › Rules › "3+ in a row or column clears."
Test cases:
- R at (1,2),(2,2),(3,2) after a swap → those 3 cells are cleared.
- R at (5,1),(5,2),(5,3) after a swap → those 3 cells are cleared.
- R at (1,2),(2,2) and R at (3,3) (not in line) → no match; swap snaps back (IR-01).

### IR-04 · A 2×2 square makes a Paper Crane
Rule: Four same-colour pieces forming a 2×2 square are a match and make a Paper Crane.
Applies to: Plain pieces. Placement: IR-40 (a swap's Crane appears on the swapped cell in its match, the target cell first; GDD Rules clarifications rows 02, 25, 100). Colour: IR-50. Crane effect: IR-20, IR-48, IR-49.
Source: GDD › Core gameplay › Special pieces › "2×2 square | Paper Crane".
Test cases:
- R at (2,2),(3,2),(3,3), Y at (2,3), R at (1,3). Swap (1,3)→(2,3) → the 4 R pieces clear; one red Paper Crane is created at (2,3).

### IR-05 · Four in a line makes a Bamboo Rocket that fires along that line
Rule: Four same-colour pieces in a row or column make a Bamboo Rocket that fires along the line it was made from: a horizontal 4 makes a row Rocket, a vertical 4 makes a column Rocket (its icon shows the direction).
Applies to: Plain pieces (player or cascade matches). Placement: IR-40 (a swap's Rocket appears on the swapped cell in its match, the target cell first; GDD Rules clarifications rows 02, 25, 100). Rockets made by Jade Orb + Rocket: IR-16, IR-25. Win-finale Rockets: IR-16 (random direction; replace a random uncovered plain piece).
Source: GDD › Core gameplay › Special pieces › "4 in a line | Bamboo Rocket"; Rules clarifications › OQ-01 "a horizontal 4 clears its row, a vertical 4 clears its column. Its icon shows the direction".
Test cases:
- R at (1,4),(2,4),(4,4), Y at (3,4), R at (3,5). Swap (3,5)→(3,4) → 4 pieces clear; one red **row** Rocket at (3,4).
- R at (5,1),(5,2),(5,4), Y at (5,3), R at (4,3). Swap (4,3)→(5,3) → 4 pieces clear; one red **column** Rocket at (5,3).

### IR-06 · An L, T or "+" of five makes a Firecracker (CHANGED)
Rule: Five same-colour pieces in an L, T or "+" shape (a line of 3 and a line of 3 at right angles sharing one cell) make a Firecracker.
Applies to: Plain pieces. Larger mixed shapes: IR-08. Placement: IR-40 (a swap's Firecracker appears on the swapped cell in its match, the target cell first, even when that is not the crossing cell; in cascades the crossing cell; GDD Rules clarifications rows 02, 25, 100). A "+" can only form in a cascade: every neighbour of its centre is part of the shape, so no single swap can complete it without a match already existing.
Source: GDD › Core gameplay › Special pieces › "L or T shape (5) | Firecracker"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule", OQ-28 "Counts as an L/T and makes a Firecracker", OQ-25 "(the crossing cell for an L, T or '+')".
Test cases:
- L by swap: R at (2,2),(2,3),(3,4),(4,4), Y at (2,4), R at (1,4). Swap (1,4)→(2,4) → 5 pieces clear; one red Firecracker at (2,4).
- T by cascade: R lands at (2,2),(3,2),(4,2),(3,3),(3,4) → 5 pieces clear; one red Firecracker at (3,2) (IR-40 crossing cell).
- "+" by cascade: R lands at (3,1),(2,2),(3,2),(4,2),(3,3) → 5 pieces clear; exactly one red Firecracker at (3,2) (the crossing cell); no other special.

### IR-07 · Five or more in a line makes a Jade Orb
Rule: Five or more same-colour pieces in a single row or column make one Jade Orb.
Applies to: Plain pieces. Orb effects: IR-18, IR-19, IR-25, IR-26. Placement: IR-40 (a swap's Orb appears on the swapped cell in its match, the target cell first; GDD Rules clarifications rows 02, 25, 100; cascade Orbs: left-most cell).
Source: GDD › Core gameplay › Special pieces › "5 in a line | Jade Orb"; Rules clarifications › OQ-06 "6 or more in a line | Makes a Jade Orb".
Test cases:
- R at (0,6),(1,6),(3,6),(4,6), Y at (2,6), R at (2,7). Swap (2,7)→(2,6) → 5 pieces clear; one Jade Orb at (2,6).
- A fall lines up R at (0,6)…(5,6) (6 in a row) → 6 pieces clear; exactly one Jade Orb at (0,6) (IR-40) and no other special.
- A fall lines up R at (0,6)…(6,6) (7 in a row) → 7 pieces clear; exactly one Jade Orb.
(A single swap can't make a 6+ line without a match already existing, so 6+ lines are tested through cascades.)

### IR-08 · Shape priority: only the strongest special is made
Rule: When one match fits the shapes of two or more specials, only the strongest is made, in the order Jade Orb > Firecracker > Bamboo Rocket > Paper Crane.
Applies to: Every match that fits more than one special shape, including longer or mixed shapes.
Source: GDD › Interaction rules › "One match fits two specials | Make only the strongest: Jade Orb (5 in a line) > Firecracker (L or T) > Bamboo Rocket (4 in a line) > Paper Crane (2×2)"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule".
Test cases:
- R at (2,4),(3,4),(4,4),(5,4),(6,4) plus R at (4,3),(4,2) (5-line that also forms a T) → exactly one Jade Orb, no Firecracker.
- R at (2,4),(3,4),(4,4),(5,4) plus R at (2,3),(2,2) (4-line that also forms an L) → exactly one Firecracker, no Rocket.
- R at (2,4),(3,4),(4,4),(5,4) plus R at (2,3),(3,3) (4-line that also contains a 2×2) → exactly one Bamboo Rocket, no Crane.

### IR-40 · Where a new special appears (CHANGED 28 Nov: all four specials, now in the GDD)
Rule: A Bamboo Rocket, Firecracker, Paper Crane or Jade Orb made by a player swap appears on a swapped cell that is in its match: the cell the player moved into (the target cell) if the match contains it, otherwise the other swapped cell (the start cell); if the match contains both, the target cell. Every special made by a cascade match uses the cascade placement: the lowest, then left-most, cell of its match, except an L, T or "+", which puts it on the crossing cell (the cell shared by its two lines).
Applies to: IR-04 to IR-07, IR-42, IR-43. The target cell is the cell the player dragged onto; the start cell is the cell the dragged piece left (the piece that was on the target cell moves into it). For a swap-made L or T the crossing cell is NOT used: the special goes on the swapped cell, even when that cell is the end of an arm. The placement cell may be a covered cell whose overlay survived the match: the special appears there, locked (IR-54).
Source: GDD › Rules clarifications › row 02 "Where a new special appears" (all four specials; target cell if in the match, otherwise the start cell; cascades: lowest then leftmost, crossing cell for an L or T), row 25 "A special whose match doesn't include the player's cell" (start cell; if both swapped cells are in the match, the cell the player moved into; cascade placement only for cascades), row 100 "Which specials move to the swapped cell" (all four); Owner decision, chat 28 Nov 2026 (now in the GDD); GDD › Rules clarifications › OQ-28; Owner decision, chat 27 Nov 2026 › OQ-57 (Option A: "The special appears there, under the overlay, locked like any covered piece").
Test cases:
- Swap (3,5)→(3,4) completes R at (1,4),(2,4),(3,4),(4,4) → Rocket at (3,4).
- R at (6,2),(6,3),(6,5), Y at (6,4), R at (5,4). Swap (5,4)→(6,4) → column Rocket at (6,4) (the target cell, not the lowest cell (6,5)).
- Cascade: R lands at (2,6),(3,6),(4,6),(5,6) → row Rocket at (2,6). Cascade: R lands at (7,1),(7,2),(7,3),(7,4) → column Rocket at (7,4).
- Cascade: Y 2×2 lands at (5,2),(6,2),(5,3),(6,3) → yellow Crane at (5,3).
- Start-cell match, vertical: R at (4,1),(4,2),(4,4); Y at (3,1),(3,2),(3,4); R at (3,3), Y at (4,3). Swap (3,3)→(4,3) (start (3,3), target (4,3)) → red column Rocket at (4,3) (target cell, in the R match); yellow column Rocket at (3,3) (the start cell, in the Y match (3,1)–(3,4); not the lowest cell (3,4)).
- Start-cell match, horizontal: R at (2,3),(3,3),(5,3); Y at (2,4),(3,4),(5,4); Y at (4,3), R at (4,4). Swap (4,4)→(4,3) (start (4,4), target (4,3)) → red row Rocket at (4,3) (target cell); yellow row Rocket at (4,4) (the start cell, in the Y match (2,4)–(5,4); not the left-most cell (2,4)).
- Orb at the start cell: Y at (0,5),(1,5),(3,5),(4,5); R at (2,5); Y at (2,6) (no other match forms). Swap (2,5)→(2,6) (start (2,5), target (2,6)) → Y at (0,5)–(4,5) clear; one Jade Orb at (2,5) (the start cell, the only swapped cell in the match).
- Single match containing only the start cell, vertical Rocket: Y at (6,1),(6,2),(6,4); R at (6,3); Y at (7,3) (no other match forms). Swap (6,3)→(7,3) (start (6,3), target (7,3)) → Y at (6,1)–(6,4) clear; column Rocket at (6,3) (the start cell, not the lowest cell (6,4)).
- Target cell still wins when in the match (unchanged): the second test above (Swap (5,4)→(6,4), Rocket at (6,4)).
- Cascade Rocket and Orb unchanged: R lands at (2,6),(3,6),(4,6),(5,6) → row Rocket at (2,6) (left-most); a fall lines up R at (0,6)…(4,6) → Jade Orb at (0,6) (left-most); the cascade tests above.
- Firecracker, L with the target cell in the match, not the crossing cell: R at (2,5),(3,5),(3,6),(3,7); Y at (1,5); R at (1,4) (no other match forms). Swap (1,4)→(1,5) (start (1,4), target (1,5)) → L (1,5),(2,5),(3,5) + (3,5),(3,6),(3,7) clears; one red Firecracker at (1,5) (the target cell, an arm end), NOT at (3,5) (the crossing cell).
- Firecracker, T made by a swap with only the start cell in the match: R at (2,3),(3,3),(4,3),(3,4); Y at (3,5); R at (4,5) (no other match forms; (4,5) after the swap holds Y and matches nothing). Swap (3,5)→(4,5) (start (3,5), target (4,5)) → R at (3,5) completes the T (2,3),(3,3),(4,3) + (3,3),(3,4),(3,5); 5 pieces clear; one red Firecracker at (3,5) (the start cell), NOT at (3,3) (the crossing cell) and not at (4,5) (the target cell, not in the match); moves −1.
- Paper Crane, only the start cell in the match: Y at (1,2),(2,2),(1,3); R at (2,3); Y at (2,4) (no other match forms; (2,4) after the swap holds R and matches nothing). Swap (2,3)→(2,4) (start (2,3), target (2,4)) → the 2×2 (1,2),(2,2),(1,3),(2,3) clears; one yellow Crane at (2,3) (the start cell), NOT at (1,3) (lowest, then left-most) and not at (2,4).
- Paper Crane, target cell in the match: the IR-04 test (Swap (1,3)→(2,3) → Crane at (2,3), the target cell).
- A swap-made Firecracker or Crane never uses the cascade placement: the same T or 2×2 formed by a fall (cascade) → Firecracker on the crossing cell (3,3); Crane on its lowest, then left-most cell (IR-42).
- Cascade onto a covered cell: creep moss (OB03) hp 2 over R at (2,6); a fall lands R at (3,6),(4,6),(5,6) → R at (2,6)–(5,6) clear; moss at (2,6) hp 1; one red row Rocket appears at (2,6) (lowest, then left-most), under moss hp 1 (locked, IR-54).

### IR-42 · Cascade matches make specials (NEW)
Rule: Matches made by falling pieces make specials by exactly the same shape, direction and priority rules as player matches.
Applies to: Every cascade match (IR-32). Placement: IR-40 (cascade placement: lowest then left-most, the crossing cell for an L or T; GDD Rules clarifications row 02; a special placed in a covered cell is locked, IR-54).
Source: GDD › Rules clarifications › OQ-05 "Make specials by the same rules as player matches".
Test cases:
- A fall lines up B at (0,8),(1,8),(2,8),(3,8) → those 4 clear and one blue row Rocket appears at (0,8), without a move being used.
- A fall lines up G at (4,2)…(4,6) (vertical 5) → one Jade Orb at (4,6).

### IR-43 · One swap making two matches: both resolve, each makes its own special (CHANGED 28 Nov: placement)
Rule: When one swap makes two separate matches (one through each swapped piece), both matches clear and each makes its own special by IR-04 to IR-08; the special of each match (Rocket, Firecracker, Crane or Orb) appears on the swapped cell in its own match (the target cell for the target-cell match, the start cell for the start-cell match, IR-40).
Applies to: Player swaps that create a match at both the start and the target cell. A special placed in a covered cell is locked (IR-54).
Source: GDD › Rules clarifications › row 07 "One swap making two matches | Both resolve, and each can make its own special; each appears on the swapped cell in its own match", rows 02, 25, 100 (see IR-40).
Test cases:
- R at (3,3); Y at (4,3); R at (4,1),(4,2),(4,4); Y at (3,4),(3,5). Swap (3,3)→(4,3) → R at (4,1),(4,2),(4,3),(4,4) (vertical 4) and Y at (3,3),(3,4),(3,5) (vertical 3) both clear; one red column Rocket at (4,3); no special from the Y match; moves −1.
- R at (4,1),(4,2),(4,4); Y at (3,1),(3,2),(3,4); R at (3,3), Y at (4,3). Swap (3,3)→(4,3) → 8 pieces clear; exactly 2 specials: red column Rocket at (4,3) (target cell) and yellow column Rocket at (3,3) (start cell, IR-40; not (3,4)); moves −1.

### IR-50 · Rockets, Firecrackers and Cranes keep a colour; the Jade Orb has none (CHANGED)
Rule: A Bamboo Rocket, Firecracker or Paper Crane keeps the colour of the match that made it and matches like a plain piece of that colour; when such a match forms, the match resolves first (clears, neighbour hits, new specials) and the matched special is lifted off the board (like a set-off special, IR-41; its cell refills in the fall; a lifted special is not a cleared piece: it leaves the board via the lift, not as one of the match's cleared pieces), pieces fall and refill, and then the special fires from the cell where it was matched (IR-21); cascade matches wait until it has finished (IR-41); a Jade Orb has no colour and is never part of a match.
Applies to: All specials. A special locked under an overlay can still be matched by colour (IR-54).
Source: GDD › Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces. The Jade Orb has no colour", OQ-26 "any match it makes resolves first, then each special fires from the cell it sits in"; Owner decision, chat 27 Nov 2026 › OQ-44 (Option A: only the fall and refill happen before a waiting special fires), OQ-54 (Option A: "Both are lifted off the board as the match resolves, like a set-off special (IR-41): their cells refill in the fall"), OQ-57 (Option A: a covered special "can still be … matched by colour (IR-50)"), OQ-61 (Option A: "The lifted special counts: every piece of a needed colour in the match, specials included, fills the shrine by one").
Test cases:
- R at (1,4); Y at (2,4); red row Rocket at (3,4); R at (2,5). Swap (2,5)→(2,4) → events in order: R 3-match (1,4),(2,4),(3,4) clear, fall, refill, then the Rocket fires along row 4 (all 9 cells of row 4 cleared).
- Same set-up, counting pieces: the match clears 2 pieces, the R at (1,4) and (2,4), and lifts the Rocket from (3,4) (lifted, not cleared: the match's cleared pieces are (1,4),(2,4) only); fall: columns 1, 2 and 3 each drop by one (the piece from (3,3) falls into (3,4)); new pieces enter at (1,0),(2,0),(3,0); the Rocket fires along row 4 from (3,4) and clears 9 pieces, including the one now at (3,4) → 11 pieces cleared in total (2 + 9; the Rocket itself is not counted).
- Lantern shrine: a lifted coloured special still counts as a piece of its colour for a shrine next to the match (Owner decision, chat 27 Nov 2026 › OQ-61 Option A); see IR-55's Rocket-in-match tests (shrine fills by 3, not 2). The piece count above stays 11.
- Jade Orb at (3,4); R at (1,4),(2,4),(4,4),(5,4) → no match through (3,4); the Orb stays.
- A Crane made from a Y 2×2 reports colour Y.

---

## C. Damage to layers and obstacles

### IR-09 · A special clears the piece in each cell it covers and hits the top obstacle layer once (CHANGED)
Rule: For each cell a special covers, it clears the piece in that cell (if any) and gives one hit to the top obstacle layer there: the overlay if there is one, else the content blocker or container, else the underlay (goo or dew).
Applies to: Every special and combo effect, and every booster (IR-36). Fragments and drop items are never cleared (IR-28). Specials in covered cells are set off (IR-41). A Jade Orb covers every cell whose piece it clears (IR-18). A cell whose overlay survives refills (IR-54). Dew spreading: IR-53.
Source: GDD › Interaction rules › "What a special hits | Each cell it covers takes one hit, on the top layer only (overlay, then content, then underlay)"; Rules clarifications › OQ-09 "Pieces are not obstacle layers. A special clears the piece and gives one hit to the top obstacle layer in that cell; with no overlay or blocker, the underlay (goo or dew) takes the hit", OQ-29 "A cell emptied under a surviving overlay refills by normal falling".
Test cases:
- Row Rocket fires along row 3; (5,3) holds a withered bramble (OB02) with 2 layers → bramble has 1 layer.
- Row Rocket along row 3; (2,3) holds R on creep goo (OB10) hp 2 → R cleared; goo hp 1.
- Row Rocket along row 3; (6,3) holds Y under creep moss (OB03) hp 1 → Y cleared; moss removed.
- Row Rocket along row 3; (4,3) holds B under moss hp 1, on goo hp 1 → B cleared; moss removed; goo still hp 1.
- Row Rocket along row 3; (6,3) holds Y under moss hp 2 → Y cleared; moss hp 1; after the board settles (6,3) holds the piece that was at (6,2), still under moss hp 1 (IR-54).

### IR-10 · Multi-cell obstacles take at most one hit per special (CHANGED)
Rule: An obstacle covering 2 or more cells takes at most one hit from a single special, however many of its cells the special covers; a whole combo counts as one special (IR-45).
Applies to: Every multi-cell obstacle (IR-11). Not OB03 (one obstacle per cell).
Source: GDD › Interaction rules › "Obstacles bigger than one cell | Take at most one hit per special, however many of their cells it covers"; Rules clarifications › OQ-12 "A combo counts as one special".
Test cases:
- Petrified pillar (OB06) at x=4, y=0–3 (w 1, h 4), hp 3. A column Rocket clears column 4 → pillar hp 2.
- Pillar (OB06) 2×2 at (3,3)–(4,4), hp 3. Firecracker at (4,5) fires (its 3×3 covers (3,4) and (4,4)) → pillar hp 2 (with IR-12).
- Pillar (OB06) 2×2 at (3,3)–(4,4), hp 3. A row Rocket clears row 3 (covers (3,3) and (4,3)) → pillar hp 2.
- Pillar 2×2 at (3,3)–(4,4), hp 3. Rocket + Firecracker centred on (5,5): rows 4–6 cover (3,4),(4,4) and columns 4–6 cover (4,3),(4,4) → pillar hp 2 (one hit for the whole combo).

### IR-11 · Which obstacles are multi-cell
Rule: The petrified pillar (OB06) and any obstacle drawn across 2 or more cells are multi-cell; creep moss (OB03) is always one obstacle per cell.
Applies to: OB06; any object in the level JSON with `w`×`h` ≥ 2 cells (e.g. OB05, OB16 per the brief's schema); OB03 is never multi-cell.
Source: GDD › Interaction rules › "Which obstacles are multi-cell | Petrified pillar (OB06) and any obstacle drawn across 2 or more cells. Creep moss (OB03) is one obstacle per cell"; level_agent_brief.md §5 "Multi-cell objects (OB05, OB06, OB16) use w/h".
Test cases:
- Creep moss (OB03) hp 1 on (2,2),(3,2),(4,2),(5,2). A row Rocket clears row 2 → all 4 moss cells take one hit each (all 4 removed).
- Lantern shrine (OB05) with w 2, h 2 → treated as multi-cell for IR-10.

### IR-12 · The Firecracker's double blast counts as one hit (CHANGED)
Rule: The Firecracker's two blasts together give at most one hit to any single obstacle: an obstacle hit by the first blast takes no hit from the second, while pieces in the area are cleared by both blasts.
Applies to: Every obstacle inside the Firecracker's 3×3 area, single- or multi-cell. Timing between blasts: IR-17. Firecracker + Firecracker: IR-24 with IR-45.
Source: GDD › Interaction rules › "Firecracker's double blast | The two blasts together count as one hit on any single obstacle"; Rules clarifications › OQ-11 "An obstacle hit by the first blast takes no hit from the second".
Test cases:
- Firecracker at (4,4) fires; withered bramble (OB02) with 2 layers at (5,4) → bramble has 1 layer.
- Firecracker at (4,4) fires; frozen idol (OB12) with 2 hits left at (3,3) → idol has 1 hit left.
- Firecracker at (4,4) fires; R on goo hp 2 at (4,5) → blast 1 clears R and goo becomes hp 1; a piece falls into (4,5); blast 2 clears that piece and goo stays hp 1.
- Firecracker at (4,4) fires; Y under moss hp 1 at (3,3), on goo hp 1 → blast 1 clears Y and removes the moss (the goo is not hit); a piece falls into (3,3); blast 2 clears it and hits the goo (not hit before) → goo cleared.

### IR-13 · Frozen idol: each adjacent match or each special is one hit (CHANGED)
Rule: A frozen idol (OB12) needs 2 hits; each adjacent match gives it one hit (however many of the match's pieces touch it), and each special gives it one hit.
Applies to: OB12 frozen idol (debut 41).
Source: GDD › Interaction rules › "Two-hit obstacles (Frozen idol) | Each adjacent match or each special counts as one hit"; Obstacle set › "OB12 … Needs 2 adjacent matches"; Rules clarifications › OQ-08.
Test cases:
- Idol at (4,4), 2 hits left. A 3-match at (3,5),(4,5),(5,5) (touching it from below) → idol 1 hit left. Another such match → idol cleared.
- Idol at (4,4), 2 hits left. A row Rocket clears row 4 → idol 1 hit left.
- Idol at (4,4), 2 hits left. An L match R at (3,3),(3,4),(3,5),(4,5),(5,5) touches the idol from the left and from below → idol 1 hit left.

### IR-14 · A match next to an obstacle gives it one hit (CHANGED)
Rule: A match gives one hit to each adjacent-match obstacle or overlay that is orthogonally next to any of its pieces, at most one hit per obstacle per match, however many of its pieces (or of the obstacle's cells) touch it; diagonal contact never counts.
Applies to: OB02 withered bramble, OB07 mummified creature / creep cocoon, OB03 creep moss, OB06 petrified pillar, OB12 frozen idol, OB08 paper-screen lantern while its screen is on (IR-74), and overlays (layer 3). Not underlays (IR-15). Pieces cleared by a special never count as a match (IR-44). A match that includes a covered piece also gives that cell's overlay one hit, still at most one hit per overlay per match (IR-54). Not OB05 lantern shrine: a match next to it fills the colours it needs and never lowers its `hp` (IR-55; Owner decision, chat 27 Nov 2026 › OQ-59 Option A (b)).
Source: GDD › Board layers & obstacles › Cell layer model › "3 · Overlay … Cleared by Adjacent matches", "2 · Content … Matching / adjacent matches / specials"; Obstacle set › OB02 "Match next to it", OB07 "Match next to it to unwrap", OB03 "Match next to it to clear", OB06 "Ground down by adjacent matches"; Rules clarifications › OQ-08 "One hit to that obstacle. Only up, down, left and right count as 'next to', never diagonals", OQ-10 "Only matches hit neighbours"; Owner decision, chat 27 Nov 2026 › OQ-59 (Option A (b): "no, matches only fill colours; `hp` falls only from specials").
Test cases:
- Bramble (OB02) with 3 layers at (4,3). A 3-match at (3,4),(4,4),(5,4) → bramble has 2 layers.
- Bramble with 1 layer at (4,3). A 3-match at (5,4),(6,4),(7,4) (touches only diagonally at (5,4)) → bramble unchanged.
- Pillar (OB06) 1×4 at x=4, y=2–5, hp 3. A 3-match at (5,2),(5,3),(5,4) runs alongside 3 of its cells → pillar hp 2.
- Brambles with 2 layers at (3,3) and (5,3). A 3-match at (3,4),(4,4),(5,4) → both brambles have 1 layer.
- Mummified creature (OB07) hp 1 at (2,2). A 3-match at (3,1),(3,2),(3,3) → creature freed (goal +1).
- Lantern shrine (OB05) 3×1 at (3,3)–(5,3), hp 1, still needs 1 B. G 3-match at (3,4),(4,4),(5,4) → shrine hp still 1; still needs 1 B; not lit (IR-55).

### IR-15 · An underlay is hit by a match on top of it, or by a special with nothing above it (CHANGED)
Rule: An underlay takes one hit when a match is made on top of it while the cell has no overlay, or when a special covers its cell and there is no overlay or blocker above it (IR-09).
Applies to: OB10 creep goo (hp 1–3 per the brief's `underlay` field). OB04 healing dew: a match or special that clears a piece on dew spreads it instead (IR-53). A match through a covered piece hits the overlay, not the underlay (IR-54). Dew spreading onto a goo cell: the goo takes its hit first and blocks the dew if it survives (IR-53).
Source: GDD › Board layers & obstacles › Cell layer model › "1 · Underlay … Cleared by Matching on top of it"; Obstacle set › OB10 "Make a match on top to clear it"; Rules clarifications › OQ-09 "with no overlay or blocker, the underlay (goo or dew) takes the hit", OQ-31; Owner decision, chat 27 Nov 2026 › OQ-41 (Option A (a): "the underlay below is not hit while the overlay was there").
Test cases:
- Goo hp 1 under (3,5). A 3-match at (2,5),(3,5),(4,5) → goo at (3,5) cleared.
- Goo hp 2 under (3,5). Same match → goo hp 1.
- Goo hp 1 under (3,5), plain piece on it. A column Rocket clears column 3 → piece cleared; goo cleared.
- Moss hp 1 over R at (3,4), goo hp 1 under (3,4); R at (2,4); Y at (4,4); R at (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clear; moss at (3,4) removed; goo at (3,4) still hp 1.

### IR-44 · Pieces cleared by a special don't hit neighbouring obstacles (NEW)
Rule: Only matches hit obstacles next to them; a special (or combo) hits only the cells it covers, and the pieces it clears give no hit to neighbouring cells.
Applies to: All specials and combos; every adjacent-match obstacle and overlay (IR-14).
Source: GDD › Rules clarifications › OQ-10 "Don't hit neighbouring obstacles. Only matches hit neighbours; specials hit only the cells they cover".
Test cases:
- Bramble (OB02) with 2 layers at (4,3). A row Rocket clears row 4 → bramble still 2 layers.
- Mummified creature hp 1 at (2,2). Firecracker at (4,2) fires (area x 3–5, y 1–3) → creature still hp 1.
- Moss hp 1 over a piece at (4,5). A row Rocket clears row 4 → moss unchanged.

### IR-45 · A combo counts as one special for the one-hit rules (NEW)
Rule: A whole combo (both swapped specials, and any specials it creates such as Jade Orb + special's converted pieces) counts as one special: each cell it covers takes at most one hit and each obstacle takes at most one hit from it, even where its areas overlap or it blasts twice.
Applies to: IR-22 to IR-26. Specials set off by a combo (IR-41) are separate specials.
Source: GDD › Rules clarifications › OQ-12 "A combo counts as one special"; Interaction rules › "Obstacles bigger than one cell | Take at most one hit per special".
Test cases:
- Rocket + Rocket centred on (4,4); goo hp 2 under (4,4) (covered by both row and column) → goo hp 1.
- Firecracker + Firecracker centred on (4,4); bramble with 3 layers at (3,3) (inside both blasts) → bramble has 2 layers.
- Rocket + Firecracker centred on (5,5); 2×2 pillar hp 3 at (3,3)–(4,4) → pillar hp 2.

### IR-53 · Healing dew spreads to every cell covered with it (CHANGED)
Rule: When a match or a special clears a piece on a healing-dew cell, every playable cell that same match or special covers gets dew, including cells where the special only hit an obstacle or held a fragment or drop item, except a cell with creep goo: the goo takes its hit from that match or special first, and the cell gets dew only if that hit removed the goo (if the goo survives, the cell gets no dew this time); a Paper Crane landing on an uncovered dew target cell clears the piece there (as a special covering the cell, IR-09) and gives that cell dew.
Applies to: OB04 healing dew (underlay); OB10 creep goo cells reached by spreading dew. Matches next to dew (not on it) don't spread it. Dew goal: every playable cell is a target and progress = playable cells that have dew, seed cells (`s` in `underlay`) counted from the start (OQ-66, trial), stopping at the count (OQ-73); the count must be more than the seed cells (OQ-74); units and validator: IR-61. A Jade Orb covers only the cells whose piece it clears (IR-18). Crane landing: IR-48.
Source: GDD › Board layers & obstacles › Obstacle set › OB04 "Matches made on dew spread it; cover the target cells"; Cell layer model › "1 · Underlay | Creep goo, healing dew"; Interaction rules › "Where the Paper Crane flies … Dew goal: an uncovered target cell"; Rules clarifications › OQ-31 "When a match or special clears a piece on a dew cell, every cell cleared by that match or special gets dew. A Crane landing on an uncovered target cell gives it dew"; Owner decision, chat 27 Nov 2026 › OQ-46 (Option B: "Every playable cell the special covers gets dew, including cells where it only hit an obstacle"), OQ-49 (Option B: "the landing counts as a special covering the cell (the piece there is cleared, IR-09) and the cell gets dew"), OQ-56 (Option A: "Goo blocks dew. The goo takes its hit first; if the goo survives, the cell gets no dew this time; if that hit cleared it, the cell gets dew"); Owner decision, chat 28 Nov 2026 › OQ-66 (Option A, trial, "let's try A for now": "Every playable cell is a target; progress = playable cells that have dew, seed cells included from the start"); `level_agent_brief.md` §5 "`s` = OB04 already covering that cell (a seed)".
Test cases:
- Dew under (3,5) only. A 3-match at (2,5),(3,5),(4,5) → (2,5),(3,5),(4,5) all have dew; no other cell has dew.
- Dew under (5,2) only; row 2 holds 9 plain pieces and no obstacles. A row Rocket fires along row 2 → all 9 cells of row 2 have dew.
- Dew under (3,6) only. A 3-match at (2,5),(3,5),(4,5) (dew is next to the match, not under it) → no new dew.
- Dew under (5,2) only; withered bramble (OB02) with 2 layers at (7,2); the other 8 cells of row 2 hold plain pieces. A row Rocket fires along row 2 → all 9 cells of row 2 have dew, (7,2) included; the bramble has 1 layer.
- 9×9 board, all 81 cells playable; no obstacles other than dew. Only goal: OB04 count 72. 71 cells have dew (goal 71/72); the 10 cells without dew are (6,2), holding Y, and the 9 cells of column 0, (0,0) to (0,8). Crane at (6,5), on a dew cell. Tap the Crane → take-off clears (6,5) (already dew, no change); it targets (6,2) (distance 3; the nearest cell of column 0, (0,5), is at distance 6); Y is cleared (then (6,2) refills, IR-51); (6,2) has dew; dew goal 72/72 (done); the level is won once the board settles (IR-56).
- Level with seeds (`s`) under (1,1), (2,1) and (3,1); goal OB04 count 10 → at the start the goal is 3/10 (seed cells count, OQ-66). A 3-match at (3,1),(4,1),(5,1) (on the seed at (3,1)) → (4,1),(5,1) get dew; goal 5/10 ((3,1) already had dew and isn't counted twice).
- Same level. A 3-match at (5,4),(6,4),(7,4), none on dew → no new dew; goal still 3/10.
- Dew under (3,5); creep goo (OB10) hp 2 under (4,5). A 3-match at (2,5),(3,5),(4,5) → (2,5) and (3,5) have dew; (4,5) has goo hp 1 and no dew.
- Dew under (3,5); goo hp 1 under (4,5). The same 3-match → the goo at (4,5) is removed and (4,5) has dew.
- Dew under (5,2); goo hp 1 under a piece at (1,2); goo hp 2 under a piece at (7,2); creep moss (OB03) hp 1 over a piece at (6,2), on goo hp 1; the other cells of row 2 hold plain pieces. A row Rocket fires along row 2 → (1,2): goo removed, dew; (7,2): goo hp 1, no dew; (6,2): moss removed, goo untouched (still hp 1, IR-09), no dew; the other 6 cells of row 2 have dew.

### IR-54 · Pieces under an overlay are locked (CHANGED)
Rule: A piece in a cell with an overlay (creep moss; the paper-screen lantern OB08 is a content obstacle, not an overlay, IR-74) is locked: it can't be swapped, doesn't fall, isn't moved by the free shuffle and counts as a blocker for the pieces above it, but it can be part of a match, which clears it and gives the overlay one hit (the underlay below is not hit by that match); when the piece in such a cell is cleared and the overlay survives, the cell refills by normal falling and the piece that falls in is then covered too; a special made in such a cell (IR-40) appears there under the overlay and is locked the same way, and also can't be tapped, but it can still be set off by another special (IR-41) or, if coloured, matched by colour (IR-50).
Applies to: Every cell with an overlay (layer 3). Swaps: IR-52. Taps: IR-02. Gravity: IR-51. Shuffle: IR-33. Specials over covered cells: IR-09. Jade Orb colour effects ignore covered pieces (IR-18, IR-19, IR-25).
Source: GDD › Board layers & obstacles › Cell layer model › "3 · Overlay"; Rules clarifications › OQ-29 "Pieces under an overlay (moss, shutter) | Locked: can't be swapped and don't fall, but can be part of a match. A cell emptied under a surviving overlay refills by normal falling", OQ-19 "Pieces locked under an overlay (moss, shutter) don't fall", OQ-21; Owner decision, chat 27 Nov 2026 › OQ-41 (Option A: "(a) the piece is cleared and the overlay takes one hit; the underlay below is not hit while the overlay was there; (b) the shuffle leaves covered pieces where they are; (c) the locked piece counts as a blocker, so the cell below fills by a diagonal slide"), OQ-57 (Option A: "The special appears there, under the overlay, locked like any covered piece: it can't be swapped, doesn't fall and can't be tapped; it can still be set off by another special (IR-41) or matched by colour (IR-50)").
Test cases:
- Moves 10. Moss hp 1 over R at (4,4), Y at (4,5) → swaps (4,5)→(4,4) and (4,4)→(4,5) are both refused; moves = 10 (IR-52).
- Moss hp 2 over Y at (6,3). A row Rocket fires along row 3 → Y cleared; moss hp 1; after the board settles (6,3) holds the piece that was at (6,2), under moss hp 1, and that piece can't be swapped.
- Moss hp 2 over R at (3,4); R at (2,4); Y at (4,4); R at (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clear; moss at (3,4) hp 1 (one hit, even though (2,4) and (4,4) also touch it, IR-14); after the board settles (3,4) holds the piece that was at (3,3), under moss hp 1.
- Moss hp 2 over G at (4,3); (4,4) emptied directly; the board settles → G is still at (4,3) under moss hp 2; (4,4) is filled by the piece from (3,3) (diagonal slide from the upper-left, IR-51); no playable cell is empty.
- Moves 10. Red row Rocket under moss hp 1 at (2,6) (as made in IR-40's covered-cell test); Y at (3,6). Swap (3,6)→(2,6) → refused; tap (2,6) → nothing; moves = 10. Then (2,7) is emptied directly and the board settles → the Rocket is still at (2,6).
- Red row Rocket under moss hp 1 at (2,6). A column Rocket is tapped at (2,0) → column 2 cleared; the moss at (2,6) is removed; the red Rocket is set off and fires along row 6 after the fall (IR-41).
- Red row Rocket under moss hp 2 at (2,6); R at (3,6); Y at (4,6); R at (4,7). Swap (4,7)→(4,6) → R 3-match (2,6),(3,6),(4,6): the covered Rocket is part of it and is lifted; moss at (2,6) hp 1; fall and refill ((2,6) refills and the new piece there is covered); the Rocket fires along row 6 from (2,6), which clears that piece and removes the moss. Events in order: match clear, fall, refill, Rocket fire (row 6).

### IR-55 · Lantern shrine: matches next to it fill its colours, specials lower its hp; lit by either (CHANGED)
Rule: When at least one piece of a match is next to a lantern shrine (OB05) (up, down, left or right), every piece of that match of a colour the shrine still needs, coloured specials in the match included (IR-50), fills it by one (a colour it no longer needs fills nothing), and the match never lowers the shrine's `hp`; a special covering the shrine lowers its `hp` by 1, at most once per special (IR-10, IR-12, IR-45), and doesn't change the colours it needs; a Paper Crane landing on it counts as one piece of a colour it needs (IR-49) and doesn't lower its `hp`; the shrine is lit when it needs no more colours or its `hp` reaches 0, whichever comes first, and a lit shrine is removed from the board: its cells become open cells that fill by normal falling.
Applies to: OB05 lantern shrine (debut level 10); every match next to it, every special, combo and booster (IR-36), and Crane landings (IR-48, IR-49). A Jade Orb is never part of a match (IR-50), so it fills nothing. The colours (and how many of each) a shrine needs at the start come from its `needs` field in the level file (IR-73). A removed shrine is no longer an obstacle, so the Crane never aims at its old cells for it (IR-49). Matches never hit the shrine (IR-14).
Source: GDD › Board layers & obstacles › Obstacle set › OB05 "Lantern shrine … Collect the colours it shows to light it"; Interaction rules › "What a special hits | Each cell it covers takes one hit"; "Obstacles bigger than one cell | Take at most one hit per special"; "Where the Paper Crane flies … Lantern shrine: counts as one piece of a colour it still needs"; Rules clarifications › OQ-08 (only up, down, left, right count as "next to"); Owner decision, chat 27 Nov 2026 › OQ-50 (Option A (a): "a special's hit lowers the shrine's `hp` by 1 (one hit per special, IR-10) but doesn't change the colours it still needs"), OQ-55 (Option A: "(a) each piece of a needed colour in a match next to the shrine fills it by one; (b) the shrine is lit when every colour is collected or its `hp` reaches 0, whichever comes first; (c) the landing counts as one piece only, no `hp` loss"); Owner decision, chat 27 Nov 2026 › OQ-59 (Option A: "(a) every piece of a needed colour in the match counts, as long as at least one piece of the match touches the shrine; (b) no, matches only fill colours; `hp` falls only from specials; (c) the shrine is removed and its cells become open cells that fill by normal falling"), OQ-61 (Option A: "The lifted special counts: every piece of a needed colour in the match, specials included, fills the shrine by one").
Test cases:
- Shrine 2×2 at (3,3)–(4,4), hp 3, still needs 2 R and 1 B. A row Rocket fires along row 3 (covers (3,3) and (4,3)) → shrine hp 2; still needs 2 R and 1 B.
- Same shrine. A Firecracker at (5,4) fires (both blasts cover (4,3) and (4,4)) → shrine hp 2 (one hit for the double blast); needs unchanged.
- Same shrine. Rocket + Rocket centred on (4,5) (column 4 covers (4,3),(4,4)) → shrine hp 2.
- Shrine 3×1 (w 3, h 1) at (3,3)–(5,3), hp 3, still needs 2 R and 1 B. R 3-match at (3,4),(4,4),(5,4) (every piece touches the shrine from below) → it needs 1 B only (two R fill it; the third R fills nothing); hp still 3 (a match never lowers `hp`); not lit.
- Same shrine, still needs 3 R only. The same R 3-match → it needs nothing; a shrine-lit event; the shrine is removed; after the board settles (3,3),(4,3),(5,3) each hold a plain piece that can be swapped like any other, and no shrine is on the board.
- Same shrine, still needs 1 Y. G 3-match at (3,4),(4,4),(5,4) → still needs 1 Y.
- Shrine 3×1 at (3,3)–(5,3), still needs 2 R. R 3-match at (6,4),(7,4),(8,4) (touches only diagonally at (6,4)) → still needs 2 R.
- Shrine 2×2 at (3,3)–(4,4), hp 1, still needs 2 R and 1 B. A row Rocket fires along row 3 → hp 0; a shrine-lit event, although colours were still needed; the shrine is removed; after the board settles (3,3),(4,3),(3,4),(4,4) each hold a plain piece.
- Shrine 2×2, hp 2, still needs 3 R; it is the only goal. A Crane fires → it lands on a shrine cell; the shrine needs 2 R; hp 2.
- Shrine 2×2, hp 3, still needs 1 B; it is the only goal. A Crane fires → it lands on a shrine cell; the shrine needs nothing; a shrine-lit event; hp 3; the shrine is removed and its 4 cells fill by falling.
- Shrine 2×2 at (3,3)–(4,4), hp 3, still needs 3 R. R 3-match at (2,5),(3,5),(4,5) ((3,5) and (4,5) touch the shrine from below; (2,5) touches nothing) → all 3 R count: it needs nothing; a shrine-lit event.
- Same shrine, hp 3, still needs 3 R and 1 B. R 3-match at (5,4),(6,4),(7,4) (only (5,4) touches the shrine, from the right) → all 3 R count: it needs 1 B; hp still 3; not lit.
- Shrine 3×1 at (2,4)–(4,4), hp 3, still needs 3 R. R at (2,5); red row Rocket at (3,5); Y at (4,5); R at (5,5). Swap (5,5)→(4,5) → match R (2,5), Rocket (3,5), R (4,5): the lifted Rocket counts, so the shrine fills by 3, needs nothing, a shrine-lit event, hp 3; events in order: match clear (Rocket lifted), shrine lit, fall, refill, Rocket fires along row 5.
- Shrine 2×2 at (3,3)–(4,4), hp 3, still needs 3 R. Red row Rocket at (5,4); R at (6,4); Y at (7,4); R at (7,5). Swap (7,5)→(7,4) → match Rocket (5,4), R (6,4), R (7,4); only the Rocket touches the shrine, and that is enough: all 3 count; a shrine-lit event; the shrine is removed; fall and refill fill (3,3)–(4,4); then the Rocket fires along row 4 and clears 9 pieces, including the ones now at (3,4) and (4,4); no shrine hit event.

### IR-74 · Paper-screen lantern: matches and specials open the screen, then a match of its colour, a special or a Crane lights it (CHANGED)
Rule: A paper-screen lantern (OB08) is a one-cell content obstacle (its cell holds no piece) with a colour and a screen of `hp` hits; while the screen has hits left, each match with at least one piece next to it (up, down, left or right) gives the screen one hit whatever the match's colour (at most one hit per match, IR-14), and if that match takes the screen's last hit and is of the lantern's colour it also lights the lantern in the same match; each special covering a closed lantern gives the screen one hit (at most one per special, IR-09, IR-12, IR-45) and never lights it in the same special; once the screen is at 0 the lantern is open, and it is lit by a match of its colour with at least one piece next to it, or by any special, combo, Orb + Orb or booster hit covering its cell; a Paper Crane landing gives a closed lantern one screen hit and lights an open one (as a match of its colour); a match of another colour next to an open lantern does nothing to it; a lit lantern is one unit of an OB08 goal (IR-61) and is removed from the board, its cell becoming an open cell that fills by normal falling.
Applies to: OB08 paper-screen lantern (debut 22). **Trial decision (OQ-78): revisit after playtest.** Written in the level file as `{"type": "OB08", "x": …, "y": …, "hp": …, "color": "…"}` with `hp` 1–3 and `"color"` one of the level's colours (IR-66, IR-68). Not an overlay, so nothing is locked under it (IR-54); as a content obstacle it is a blocker for falling (IR-51) until it is lit and removed. One cell only: the brief's multi-cell objects are OB05, OB06 and OB16 (IR-11). "Open" means the screen was already at 0 before that match, special or landing; the Firecracker's two blasts and a combo are one special (IR-12, IR-45), so they open a closed lantern with screen hp 1 but don't also light it. Boosters hit like a special (IR-36); the Feather Fan never hits, so it neither opens nor lights a lantern (IR-35). How the Crane picks an OB08 goal: IR-49. A removed lantern is no longer an obstacle (not hit, not a Crane target).
Source: GDD › Board layers & obstacles › Obstacle set › "22 | OB08 · shutter + colour | Paper-screen lantern | Fire | Open the screen, then match its colour to light it"; OB05 "a lit shrine is removed and its cells fill by normal falling" (the model for (a)); Interaction rules › "What a special hits | Each cell it covers takes one hit", "Firecracker's double blast | The two blasts together count as one hit on any single obstacle", "Where the Paper Crane flies"; Rules clarifications › OQ-08 (only up, down, left, right count as "next to"), OQ-12 (a combo counts as one special); `level_agent_brief.md` §5 › "Multi-cell objects (OB05, OB06, OB16) use `w`/`h`"; Owner decision, chat 28 Nov 2026 › OQ-78 (Option B, trial, "for now": "The lantern is a content obstacle (no piece in its cell) with `"color"` and `hp`: adjacent matches or specials take the screen off (its `hp`), then an adjacent match of its colour lights it (goal +1)"), OQ-84 ((a) A: "It is removed and its cell fills by normal falling (like a lit shrine)"; (b) B: "It opens the screen and lights the lantern in the same match"; (c) B: a special (or combo, booster, Orb + Orb) covering an open lantern "lights the lantern"; (d) B: "Like a shrine landing: on a closed lantern it is one screen hit; on an open lantern it counts as a match of its colour and lights it"; (e) A: "`hp` 1–3; `"color"` one of the level's colours").
Test cases:
- Red lantern, screen hp 2, at (4,3); only goal OB08 count 1. G 3-match at (3,4),(4,4),(5,4) → screen hp 1; not lit; goal 0/1. Then a B 3-match at (3,4),(4,4),(5,4) → screen hp 0 (open); goal still 0/1 (a closed lantern takes a hit, whatever the match's colour; an R match here would also light it, test 5).
- Red lantern, screen hp 2, at (4,4). A Firecracker at (4,5) fires (both blasts cover (4,4)) → screen hp 1. Red lantern, screen hp 1, at (4,3): a row Rocket fires along row 3 → screen hp 0 (open); not lit; (4,3) still holds the lantern and no piece.
- Red lantern, screen open, at (4,3); only goal OB08 count 1. B 3-match at (3,4),(4,4),(5,4) → not lit; goal 0/1. Then an R 3-match at (3,4),(4,4),(5,4) → a lantern-lit event; goal 1/1.
- Red lantern, screen open, at (4,3). R 3-match at (5,4),(6,4),(7,4) (touches only diagonally at (5,4)) → not lit.
- Red lantern, screen hp 1, at (4,3); only goal OB08 count 1. R 3-match at (3,4),(4,4),(5,4) → screen hp 0 and a lantern-lit event in the same match; goal 1/1. Same lantern, screen hp 1: a B 3-match at (3,4),(4,4),(5,4) → screen hp 0 (open); not lit; goal 0/1.
- Red lantern, screen open, at (4,3). A row Rocket fires along row 3 → a lantern-lit event; goal +1 (compare test 2: on screen hp 1 the same Rocket only opens it).
- Red lantern, screen hp 1, at (4,4). A Firecracker at (4,5) fires (both blasts cover (4,4)) → screen hp 0 (open) after the first blast; still open and not lit after the second (one special, IR-12).
- Red lantern, screen open, at (4,3); R 3-match at (3,4),(4,4),(5,4) → a lantern-lit event; the lantern is removed; after the board settles (4,3) holds a plain piece that can be swapped like any other, and no lantern is on the board.
- Red lantern, screen open, at (6,6); Jade Orb + Jade Orb fires → a lantern-lit event. Hoof Tap on (6,6) → a lantern-lit event (IR-36). Feather Fan used → the lantern is unchanged (IR-35).
- Only goal: OB08 count 1; red lantern, screen hp 2, at (6,2). A Crane lands on it → screen hp 1; not lit. Another Crane lands on it → screen hp 0 (open); not lit. A third Crane lands on it → a lantern-lit event; goal 1/1.

---

## D. Special effects

### IR-16 · A Bamboo Rocket clears its full row or its full column (CHANGED)
Rule: A row Rocket hits every cell of its row and a column Rocket hits every cell of its column, as set when it was made (IR-05); Rockets made by Jade Orb + Rocket copy the direction of the Rocket that was swapped with the Orb; each win-finale Rocket (one per leftover move) gets its own direction, row or column, 50/50, picked independently by the level's seeded random number generator (all-row or all-column finales can happen), and then replaces an uncovered plain piece picked by a second draw from the same generator; if no uncovered plain piece is left, it still counts for coins and appears on a random playable cell (seeded) without replacing anything: it fires from that cell, and whatever is there is treated as IR-09 says; finale Rockets go one at a time: each is drawn, placed and fired, and the board settles fully (fall, refill, cascades, set-off specials) before the next Rocket's draws; the first finale Rocket is drawn on the board as it is once the winning move has fully settled (IR-56: the rest of that move, falls, refills, waiting specials, second blasts, cascades and any free shuffle, all happen first), and a level won on its last move has no finale Rockets.
Applies to: Bamboo Rocket. Hits follow IR-09/IR-10. Win-finale Rockets: Core gameplay › "Leftover moves become Bamboo Rockets"; Meta › Coins "Win = 20 + 5 per finale rocket". When the win happens: IR-56 (only after the winning move has fully settled). Fallback cell contents: a piece there is cleared, a special is set off (IR-41), a fragment or drop item stays (IR-28), and the top obstacle layer takes one hit (IR-09).
Source: GDD › Core gameplay › Special pieces › "Bamboo Rocket | Clears its full row or column"; Core gameplay › Rules › "Leftover moves become Bamboo Rockets that fire for bonus coins"; Meta & economy › Coins "Win = 20 + 5 per finale rocket"; Rules clarifications › OQ-01, OQ-24 "Rockets made by Jade Orb + Rocket | Copy the direction of the Rocket swapped with the Orb"; Owner decision, chat 27 Nov 2026 › OQ-40 ("random rockets: some row, some column", confirmed), OQ-53 (Option A: "Each finale Rocket independently: row or column, 50/50, from the level's seeded random number generator; all-row or all-column finales can happen"), OQ-58 (Option A: "Each Rocket replaces a random uncovered plain piece, picked by the level's seeded random number generator (a second draw after the direction). If no uncovered plain piece is left, the Rocket still counts for coins but appears on any random playable cell"), OQ-60 (Option A: "(a) the Rocket doesn't replace anything: it fires from that cell, and whatever is there is treated as IR-09 says (piece cleared, special set off, fragment or drop item stays, top layer hit); (b) one at a time: each Rocket is drawn, placed and fired, and the board settles fully, before the next Rocket's draws"); Owner decision, chat 28 Nov 2026 › OQ-63 (Option A: "finishing the goals on the last move is a win with 0 finale Rockets (win coins 20)"), OQ-64 (changed by the owner, 28 Nov 2026, replacing the earlier trial Option B; with OQ-72: "I would like the whole match to apply and the rest continued because that is the satisfaction level": the winning move's resolve plays out in full and the win, then the finale, comes once the move has fully settled).
Test cases:
- Tap a row Rocket at (4,4) on a plain 9×9 board → all 9 cells of row 4 cleared, nothing else.
- Tap a column Rocket at (4,4) on a plain 9×9 board → all 9 cells of column 4 cleared, nothing else.
- Jade Orb at (4,4), column Rocket at (4,5); R is the most common plain colour. Swap (4,5)→(4,4) → every converted Rocket is a column Rocket (every converted fire event reports "column"). With a row Rocket instead → every converted Rocket is a row Rocket.
- Level won with 4 moves left → 4 finale Rocket fire events, each reporting "row" or "column". Replaying the same win with the same level seed gives the same 4 directions in the same order.
- Level won with 3 moves left; the direction pick is stubbed to return row, column, column → the finale Rockets fire as row, column, column, in that order.
- Level won with 3 moves left; the direction pick is stubbed to return row, row, row → 3 row Rockets; none is flipped to column.
- Level seeds 1–1000, each won with 10 moves left (10,000 finale Rockets) → between 48% and 52% of them are row Rockets.
- Level won with 1 move left; every playable cell holds a special, a covered piece (creep moss hp 2), a lost hatchling (OB11) or an obstacle, except (6,2), which holds the only uncovered plain piece (Y) → the finale Rocket appears at (6,2) (the Y is replaced); with the direction stubbed to column it clears column 6. For that Rocket the direction draw comes before the cell draw.
- Level won with 1 move left on a board with plain pieces, a Firecracker at (1,1), a lost hatchling (OB11) at (2,2) and moss hp 1 over a piece at (3,3); level seeds 1–100 → the finale Rocket never appears at (1,1), (2,2) or (3,3).
- Level won with 2 moves left and no uncovered plain piece on the board → 2 finale Rocket fire events; win coins = 20 + 5 × 2 = 30.
- Level won with 1 move left; no uncovered plain piece on the board; the fallback cell draw is stubbed to (1,1), which holds a Firecracker; direction stubbed to row → the finale Rocket fires along row 1 from (1,1); the Firecracker is set off (not replaced) and blasts (1,1)'s 3×3 twice after the fall (IR-41, IR-17); win coins = 25.
- Same, but (1,1) holds a fragment riding a drop item → the Rocket fires along row 1; the fragment is still on the board afterwards (IR-28), not collected by the Rocket.
- Same, but (1,1) holds a piece under creep moss (OB03) hp 2 → the piece is cleared; moss hp 1 (one hit, IR-09); after the board settles (1,1) holds the piece that fell in, still covered.
- Same, but (1,1) holds a withered bramble (OB02) with 2 layers → the bramble has 1 layer; the rest of row 1 is cleared as usual.
- Level won with 2 moves left; directions stubbed to row, row; cell draws stubbed to (4,4) then (4,6); a Firecracker sits at (7,4) → events in order: Rocket 1 placed at (4,4), fires along row 4 (sets off the Firecracker), fall, refill, Firecracker blast 1, fall, refill, blast 2, fall, refill (and any cascades), then Rocket 2 placed at (4,6), fires along row 6, fall, refill. No Rocket 2 event comes before the last settling event of Rocket 1.
- Level won with 2 moves left; the board after Rocket 1 has settled has no empty playable cell when Rocket 2's direction and cell are drawn, and Rocket 2's cell holds an uncovered plain piece of that settled board (not of the board before Rocket 1).
- Level won on its last move (moves left 0) → no finale Rocket events; win coins 20.
- Moves 3. Only goal: OB07 count 1; mummified creature hp 1 at (2,3). R at (2,4),(3,4); Y at (4,4); R at (4,5). Swap (4,5)→(4,4) → R 3-match frees the creature; no further match forms (refill fixed by the test); events in order: match clear, fall, refill, win, then finale Rocket 1's direction, cell and fire events; moves 2; Rocket 1's cell draw picks among the uncovered plain pieces of the settled board (after the fall and refill); an empty cell is never picked.

### IR-17 · A Firecracker blasts the same 3×3 twice, with the board settling in between (CHANGED)
Rule: A Firecracker blasts the 3×3 area centred on its cell, then pieces fall, new pieces refill and all cascade matches resolve, then it blasts the same 3×3 (same centre cell) a second time; obstacle hits follow IR-12.
Applies to: Firecracker. Cells of the 3×3 that are off the board or not playable are skipped. Firecracker + Firecracker uses the same timing (IR-24).
Source: GDD › Core gameplay › Special pieces › "Firecracker | 3×3 blast, twice"; Rules clarifications › OQ-11 "Hits the same centre cell after pieces have fallen", OQ-32 "Pieces fall, refill and all cascades resolve, then the second blast. Firecracker + Firecracker uses the same timing".
Test cases:
- Tap a Firecracker at (4,4) on a plain 9×9 board with no matches forming → blast 1 clears (3–5, 3–5); pieces from (3–5, 0–2) fall into (3–5, 3–5); 9 new pieces enter at (3–5, 0–2); blast 2 clears (3–5, 3–5) again → 18 pieces cleared in total; events in order: blast 1, fall, refill, blast 2.
- Firecracker at (0,0) → each blast covers only (0–1, 0–1).
- R at (1,5),(2,5); Y at (3,5); R at (3,2). Tap a Firecracker at (4,4) → blast 1 clears (3–5, 3–5); R from (3,2) falls to (3,5); the cascade match R (1,5),(2,5),(3,5) clears **before** blast 2; events in order: blast 1, fall, refill, match clear (1,5)–(3,5), fall, refill, blast 2.

### IR-18 · Jade Orb swapped with a plain piece clears that colour (CHANGED)
Rule: A Jade Orb swapped with a plain piece uses one move and clears every uncovered plain piece of that piece's colour (coloured specials of that colour, and plain pieces under an overlay, are left alone and their cells untouched), covering every cell whose piece it clears (IR-09); a Jade Orb swapped with a drop item acts as an Orb tap (IR-19).
Applies to: Jade Orb + plain piece, Jade Orb + drop item. Orb + Rocket/Firecracker: IR-25. Orb + Orb: IR-26 (clears covered pieces too). Orb + Crane: IR-27.
Source: GDD › Core gameplay › Special pieces › "Jade Orb | Clears every plain piece of the colour it's swapped with; specials are left alone"; Rules clarifications › OQ-03 "A Jade Orb swapped with a plain piece clears that piece's colour", OQ-09 "A Jade Orb covers every cell whose piece it clears", OQ-33 "only plain pieces are cleared", OQ-30 "a Jade Orb swapped with one acts as an Orb tap"; Owner decision, chat 27 Nov 2026 › OQ-42 (Option B: "Covered plain pieces neither count nor are cleared; their cells are untouched").
Test cases:
- Moves 15. Plain board, no obstacles, no specials. Orb at (4,4) swapped with B at (5,4) → every B cleared; the Orb is used up; moves = 14.
- Same, with a B on goo hp 1 at (1,1) → that B cleared and the goo cleared.
- Same, with bramble (OB02) at (2,2) next to a cleared B → bramble unchanged (IR-44).
- Same, with a blue row Rocket at (6,6) → every plain B cleared; the blue Rocket is not cleared and does not fire (no Rocket fire event).
- Moves 15. Plain pieces 20 R, 18 Y, 17 B, 16 G; Orb at (4,4), hatchling (OB11) at (4,5). Swap (4,5)→(4,4) → all 20 R cleared; the hatchling is not destroyed; moves = 14.
- Orb at (4,4) swapped with B at (5,4); creep moss (OB03) hp 1 over a B at (1,1) → every uncovered B cleared; the B at (1,1) is still there, moss still hp 1.

### IR-19 · Tapping a Jade Orb clears the most common colour (CHANGED)
Rule: A tapped Jade Orb uses one move and clears every uncovered plain piece of the most common colour among uncovered plain pieces on the board (coloured specials and plain pieces under an overlay are neither counted nor cleared), ties broken by IR-47.
Applies to: Jade Orb tap; also Orb + drop item (IR-18) and the Orb's effect in Orb + Crane (IR-27). A set-off Orb does nothing (IR-41).
Source: GDD › Interaction rules › "Tapping a Jade Orb | Clears every piece of the most common colour on the board; costs a move like any tap"; Rules clarifications › OQ-14, OQ-33 "Only plain pieces count towards the most common colour, and only plain pieces are cleared"; Owner decision, chat 27 Nov 2026 › OQ-42 (Option B: "Covered plain pieces neither count nor are cleared; their cells are untouched").
Test cases:
- Moves 10. Plain pieces only: 20 R, 18 Y, 17 B, 16 G. Tap Orb → all 20 R cleared; moves = 9.
- Plain pieces only: 18 R, 18 B, 17 Y, 17 G → R cleared (tie, IR-47).
- Plain pieces: 17 R, 18 Y, 16 B, 16 G, plus 2 red Firecrackers → Y cleared (the Firecrackers don't count); both Firecrackers stay and don't fire.
- Uncovered plain pieces: 17 R, 18 Y, 16 B, 16 G; plus 3 more R, each under creep moss hp 1 → Y cleared (only 17 R count); the 3 covered R stay and their moss is still hp 1.

### IR-20 · The Paper Crane telegraphs its target, fragment first (CHANGED)
Rule: When a Paper Crane fires, it chooses its target by IR-49 (an unfreed soul fragment always first) and shows it with a dotted path before it flies; it then takes off and lands by IR-48.
Applies to: Paper Crane (IR-04).
Source: GDD › Interaction rules › "Where the Paper Crane flies | To the remaining goal with the fewest hits left; an unfreed soul fragment always comes first. Dew goal: an uncovered target cell. Lantern shrine: counts as one piece of a colour it still needs"; Special pieces › "its target is shown with a dotted path before it flies".
Test cases:
- Goals: bramble (OB02) hp 1 and fragment in a cocoon hp 3. Crane fires → target is the cocoon, even though the bramble has fewer hits left.
- Every Crane event list contains, in order: crane target (target cell), crane take-off (start cell), crane landing (target cell).

### IR-21 · When a special fires (CHANGED)
Rule: A special fires when it is part of a match (after the match resolves, IR-50), when it is swapped (IR-18, IR-22 to IR-27, IR-39), when it is tapped (IR-02), or when another special covers its cell (IR-41).
Applies to: All four specials (the Jade Orb is never matched; a set-off Orb does nothing, IR-41).
Source: GDD › Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Rules clarifications › OQ-03, OQ-04, OQ-18, OQ-26; Owner decision, chat 27 Nov 2026 › OQ-44 (Option A: fall and refill before a waiting special fires; cascades after).
Test cases:
- A red Firecracker in an R 3-match → the Firecracker fires (two blast events), after the match's clear event.
- R at (1,4),(2,4); Y at (3,4); red Firecracker at (4,4); R at (3,5). Swap (3,5)→(3,4) → the 4-match (1,4)–(4,4) clears and makes a red row Rocket at (3,4); then the Firecracker fires centred on (4,4); its blast covers (3,4), so the new Rocket is set off and fires along row 4 after the Firecracker's second blast. Event order: match clear, Rocket created, fall, refill, blast 1, fall, refill, blast 2, fall, refill, Rocket fire (IR-39, IR-41).
- Tap → see IR-02. Swap → see IR-39. Chain → see IR-41.

### IR-41 · A special hit by another special fires too (chain) (CHANGED)
Rule: When a special's effect covers a cell holding another special, that special is lifted off the board (it no longer falls or takes hits) and joins one shared waiting list; after the first special has completely finished, and again after each waiting special finishes, pieces fall and refill (cascade matches don't resolve yet), and then the waiting special that is lowest, then left-most, among all specials waiting (including ones set off by other set-off specials) fires from the cell where it was hit; cascade matches resolve only once the waiting list is empty; a set-off Jade Orb is removed without effect; each set-off special is a separate special for the one-hit rules.
Applies to: All specials and combos as the first special; also a special cleared by a Hoof Tap (IR-36), which is set off the same way. Jade Orb + Jade Orb clears other specials without firing them (IR-26). A Firecracker's own two blasts still have cascades in between (IR-17).
Source: GDD › Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes. Set-off specials are lifted off the board and fire from their cell after pieces fall, lowest first, then left-most. A set-off Jade Orb is removed without effect", OQ-27 "A set-off Jade Orb does nothing; Orb + Orb clears other specials without firing them"; Owner decision, chat 27 Nov 2026 › OQ-44 (Option A: "Only the fall and refill happen before a waiting special fires; cascade matches resolve after it has fired (… chain: first special, fall, refill, set-off specials fire, then cascades)"), OQ-47 (Option A: "one shared waiting list; the lowest, then left-most waiting special always fires next").
Test cases:
- Tap a row Rocket at (1,4); a column Rocket at (6,4) → row 4 cleared (the column Rocket is lifted, not destroyed); pieces fall; then the column Rocket fires from (6,4) and column 6 is cleared; every event of the first Rocket comes before any event of the second.
- Same, with bramble (OB02) 2 layers at (6,7) → bramble has 1 layer (hit by the set-off Rocket).
- Tap a column Rocket at (4,0); Firecrackers at (4,2) and (4,6) → after column 4 is cleared and pieces fall, the Firecracker hit at (4,6) fires (both blasts centred on (4,6)) before the one hit at (4,2) (both blasts centred on (4,2)).
- Tap a row Rocket at (0,4); column Rockets at (6,4) and (2,4) → the one hit at (2,4) fires before the one hit at (6,4) (same row: left-most first).
- Tap a row Rocket at (0,4); a Jade Orb at (5,4) → the Orb is removed; no colour-clear event; only row 4 was cleared by the Rocket.
- Tap a Firecracker at (4,4); a row Rocket at (5,5) → the Rocket is lifted at blast 1, is not hit again by blast 2, and fires exactly once, along row 5, after blast 2.
- Tap a column Rocket at (4,0); a Crane at (4,6) → after column 4 is cleared, the Crane fires (crane take-off event at (4,6)).
- Tap a row Rocket at (0,4); column Rocket A at (2,4); column Rocket C at (6,4); row Rocket B at (2,1). Row 4 cleared (A and C lifted); fall (B moves from (2,1) to (2,2)); refill; A fires along column 2, setting off B at (2,2); fall, refill; C fires along column 6 (row 4 is lower than row 2, so C goes before B although B was set off later); fall, refill; B fires along row 2. Fire events in order: row 4, column 2, column 6, row 2.
- G at (1,3),(1,5),(1,6); nothing else lines up. Tap a row Rocket at (0,4); a column Rocket at (6,4) → events in order: Rocket fire (row 4), fall (G from (1,3) now at (1,4)), refill, Rocket fire (column 6), fall, refill, match clear (1,4),(1,5),(1,6). The G match does not clear before the column Rocket fires.

### IR-47 · Colour ties are broken red, yellow, blue, green (CHANGED)
Rule: When two or more colours tie for the Jade Orb's "most common colour" (counting uncovered plain pieces only), the first in the order red, yellow, blue, green is chosen.
Applies to: Jade Orb tap (IR-19), Orb + drop item (IR-18), Jade Orb + special (IR-25), Jade Orb + Crane (IR-27). Not the Crane's shrine colour tie (IR-49: seeded random).
Source: GDD › Rules clarifications › OQ-14 "Broken in a fixed order: red, yellow, blue, green", OQ-33; Owner decision, chat 27 Nov 2026 › OQ-42 (Option B: covered plain pieces don't count).
Test cases:
- Plain pieces only: 18 R, 18 Y, 17 B, 16 G → R.
- Plain pieces only: 10 R, 19 Y, 19 B, 10 G → Y.
- Plain pieces only: 12 R, 12 Y, 20 B, 20 G → B.
- Plain pieces: 18 R, 18 Y, 17 B, 16 G, plus one yellow Rocket → R (the Rocket isn't counted).
- Uncovered plain pieces: 18 R, 18 Y, 17 B, 16 G; plus 2 Y under creep moss → R (the covered Y aren't counted).

### IR-48 · Paper Crane take-off and landing (CHANGED)
Rule: When a Crane flies, its take-off counts as a special covering its starting cell (for a lifted Crane, the cell it was lifted from: where it was hit, IR-41; its cell right after a swap that made a match, IR-39; where it was matched, IR-50): the Crane is cleared, whatever is in that cell at take-off is treated exactly as IR-09 says (a piece that fell in after the Crane was lifted is cleared, a special there is set off by IR-41, a fragment or drop item stays, IR-28) and the top obstacle layer there takes one hit; at its target cell it then collects the fragment or drop item there, or, on a lantern shrine, counts as one piece of a colour the shrine needs without lowering its `hp` (IR-49, IR-55), or otherwise acts as a special covering that cell (IR-09: the piece there is cleared and the top obstacle layer takes one hit), and on an uncovered dew target cell it also gives that cell dew (IR-53).
Applies to: Every Crane flight (tap, match, swap, chain, IR-27). A set-off Crane's take-off is a separate special from the one that set it off (IR-41).
Source: GDD › Rules clarifications › OQ-16 "Gives one hit to its target cell, or collects the fragment or drop item there. It also clears its own starting cell when it takes off", OQ-09 "A special clears the piece and gives one hit to the top obstacle layer in that cell"; Interaction rules › "a drop item still has to reach the bottom row unless a Crane or Orb + Orb collects it"; Rules clarifications › OQ-34 "Take-off counts as a special on its own cell", OQ-04 "Set-off specials are lifted off the board and fire from their cell after pieces fall", OQ-31 "A Crane landing on an uncovered target cell gives it dew"; Owner decision, chat 27 Nov 2026 › OQ-49 (Option B: "the landing counts as a special covering the cell (the piece there is cleared, IR-09) and the cell gets dew"), OQ-54 (Option A: swapped and matched specials "are lifted off the board as the match resolves, like a set-off special (IR-41)"), OQ-55 (Option A (c): "the landing counts as one piece only, no `hp` loss").
Test cases:
- Tap a column Rocket at (4,0); Crane at (4,6) on goo hp 2; nothing else special on the board → column 4 cleared (goo hp 1, the Crane lifted); pieces fall, so a plain piece P is now in (4,6); the Crane takes off from (4,6) → P is cleared and the goo is hp 0 (removed); then the Crane lands on its target.
- Crane at (1,7); only goal: bramble (OB02) hp 2 at (6,2) → bramble hp 1; (1,7) is emptied (then refilled, IR-51).
- Only goal: lost hatchling (OB11) at (5,3) → hatchling collected; goal +1; it is not destroyed.
- Only goal: fragment in a cocoon hp 1 at (4,1) → cocoon freed and fragment collected (IR-29).
- Crane at (1,7) on goo hp 1; only goal: bramble hp 2 at (6,2) → take-off clears the Crane and the goo at (1,7); bramble hp 1.
- Crane at (1,7) on goo hp 2 → after take-off, goo at (1,7) hp 1.
- Dew level; (6,2), holding B, is the only playable cell without dew; no other obstacle → the Crane lands there; B is cleared; (6,2) has dew (IR-53); after the board settles (6,2) holds the piece that was at (6,1).
- G at (2,4); Y at (3,4); green Crane at (4,4); G at (3,5). Swap (3,5)→(3,4) → G 3-match (2,4),(3,4),(4,4): G at (2,4),(3,4) clear and the Crane is lifted from (4,4); fall: the piece P from (4,3) falls into (4,4); refill; the Crane takes off from (4,4) (take-off event at (4,4)) and P is cleared.
- Only goal: lantern shrine 2×2, hp 2, still needing 3 R → the Crane lands on a shrine cell; the shrine needs 2 R; hp still 2 (IR-55).

### IR-49 · Paper Crane targeting order and tie-breaks (CHANGED)
Rule: The Crane aims at one cell of an unfinished goal: an unfreed fragment first, otherwise the goal with the fewest hits left (dew: uncovered target cells left; lantern shrine: pieces still needed; paper-screen lantern: remaining screen `hp` plus 1 for each unlit lantern; drop items: items still to collect); any tie (between goals or between cells) goes to the cell with the shortest straight-line distance to the Crane, then the top-most, then the left-most; with no goal left it aims at the nearest cell holding any remaining obstacle on any layer or an uncovered dew target cell (same tie-breaks), and with no obstacle left at a piece picked by the level's seeded random number generator; a landing on a lantern shrine counts as one piece of the colour the shrine needs most of (and doesn't lower its `hp`, IR-55), a tie between colours being broken by the level's seeded random number generator.
Applies to: Every Crane flight. "Obstacle" means anything in the GDD's Obstacle set, so creep moss (OB03, overlay) and creep goo (OB10, underlay) both count for the no-goal case; the landing then hits that cell's top layer (IR-48 → IR-09). Uncovered dew target cells also count, and the landing gives the cell dew. A lit lantern shrine has been removed (IR-55), so it is neither a goal cell nor a remaining obstacle; its old cells are ordinary cells. Paper-screen lanterns (OB08, IR-74): a landing is like a shrine landing: on a closed lantern it is one screen hit, on an open one it lights it (OQ-84 (d) B); so a lantern needs one landing per screen hit left plus one to light it, which is what "hits left" counts. A lit lantern is removed (IR-74), so it is neither a goal cell nor a remaining obstacle. "Hits left" for an obstacle goal is still counted in hits (the remaining `hp` or layers of its obstacles not yet gone, a multi-cell obstacle counted once), not in goal units: a goal's units are whole obstacles (IR-61), but the Crane compares hits. On a level with a dew (OB04) goal every playable cell is a dew target (OQ-66, trial), so "uncovered target cells left" means the playable cells without dew, whatever the goal's count: a dew goal at 70/72 on a board with 11 cells without dew has 11 hits left, not 2. "No goal left" also covers a Crane that flies later in the same move that finished the last goal: the rest of that move still plays out before the win (IR-56), so such a Crane still flies and aims by the no-goal case.
Source: GDD › Interaction rules › "Where the Paper Crane flies"; Owner decision, chat 28 Nov 2026 › OQ-62 (Option A, trial: "One unit = one obstacle fully gone"), OQ-64 / OQ-72 (changed 28 Nov 2026: "I would like the whole match to apply and the rest continued"; the win comes after the move has fully settled), OQ-66 (Option A, trial: "Every playable cell is a target; progress = playable cells that have dew, seed cells included from the start"); Owner decision, chat 27 Nov 2026 › OQ-59 (Option A (c): "the shrine is removed and its cells become open cells"); Rules clarifications › OQ-17 "Aims at one obstacle cell of the goal with the fewest hits left (an unfreed fragment always first). Ties: closest to the Crane, then top-most, then left-most. No goal left: the nearest remaining obstacle; if none, a seeded random piece"; Board layers & obstacles › Obstacle set and Cell layer model; Rules clarifications › OQ-34 "Distance is straight-line. Hits left: dew = uncovered target cells, shrine = pieces still needed, drop items = items still to collect. A shrine landing counts as the colour it needs most", OQ-38 "Uncovered dew target cells count as remaining obstacles; landing there gives the cell dew"; Owner decision, chat 27 Nov 2026 › OQ-43 (Option B: "Ties broken by the level's seeded random number generator"), OQ-55 (Option A (c): the shrine landing "counts as one piece only, no `hp` loss"); Owner decision, chat 28 Nov 2026 › OQ-84 ((d) B: "Like a shrine landing: on a closed lantern it is one screen hit; on an open lantern it counts as a match of its colour and lights it"; (a) A: a lit lantern "is removed").
Test cases:
- Crane at (4,4). Goals: brambles (two at hp 3 → 6 hits left) and mummified creatures (one at hp 1 → 1 hit left) → targets the creature's cell.
- Crane at (4,4). Only goal: 2 creatures hp 1 at (2,4) and (6,4) (equal distance, same row) → targets (2,4) (left-most).
- Crane at (4,4). Only goal: 2 creatures hp 1 at (4,1) and (4,7) → targets (4,1) (top-most).
- Crane at (4,4). Only goal: creatures hp 1 at (5,4) and (1,4) → targets (5,4) (closest). All goals already complete, one bramble left at (4,2) → targets (4,2). No obstacle left → the same level seed gives the same target piece on every run.
- Crane at (4,4). Only goal: creatures hp 1 at (6,6) (distance 2.83) and (4,1) (distance 3) → targets (6,6). (Counting steps along rows and columns would have picked (4,1).)
- Crane at (4,4). 9×9 board, all 81 cells playable. Goals: dew OB04 count 72, with 70 cells already having dew (goal 70/72) and the 11 cells without dew at (1,1), (7,7) and 9 cells further than 4.25 from (4,4); bramble goal with 12 hits left → targets (1,1) (dew hits left = 11 cells without dew, not 72 − 70 = 2; 11 < 12; (1,1) and (7,7) equally close; top-most); (1,1) gets dew; dew goal 71/72.
- Same board, but the bramble goal has 10 hits left → targets a bramble cell (10 < 11), even though the dew goal needs only 2 more cells.
- Crane at (4,4). Goals: hatchlings with 1 still to collect, at (2,2); bramble hp 2 at (6,6) → targets (2,2); hatchling collected.
- Crane at (4,4). Goals: lantern shrine (OB05) hp 3 still needing 3 R and 1 B (4 left); brambles with 5 hits left → targets a shrine cell; afterwards the shrine needs 2 R and 1 B, still hp 3 (IR-55).
- Crane at (4,4). All goals complete; only obstacles left: creep goo (OB10) hp 1 under a piece at (4,5) and a bramble at (4,1) → targets (4,5) (goo counts; closest); piece cleared and goo removed.
- Crane at (4,4). All goals complete; only obstacle left: creep moss (OB03) hp 1 at (1,1) → targets (1,1); moss removed.
- Crane at (4,4). Dew level, all goals complete; only things left: an uncovered dew target cell at (4,6) (distance 2; every other playable cell already has dew), holding a plain piece, and a bramble at (4,1) (distance 3) → targets (4,6); the piece there is cleared and (4,6) gets dew (IR-48).
- Crane at (4,4). Only goal: a lantern shrine still needing 2 R and 2 B (and no Y or G) → after the landing it needs either 1 R and 2 B or 2 R and 1 B. Running it again with the same level seed gives the same result. With the colour pick stubbed to return B → it needs 2 R and 1 B.
- Crane at (4,4). The level's lantern shrine 2×2 at (3,2)–(4,3) was lit earlier (removed) and its goal is complete; all other goals complete; only obstacle left: a bramble at (4,8) (distance 4) → targets (4,8), never a cell of (3,2)–(4,3).
- Crane at (4,4). Goals: OB06 count 1, one 2×2 pillar hp 3 at (0,0)–(1,1) (1 unit left, 3 hits left); OB02 count 2, brambles with 1 layer at (8,7) and (8,8) (2 units left, 2 hits left) → targets (8,7) (2 hits < 3 hits; of the two brambles, (8,7) is closer); bramble removed; OB02 goal 1/2.
- Moves 5. Only goal: OB07 count 1; creature hp 1 at (2,2). Crane at (6,2); bramble (OB02, not a goal) with 2 layers at (6,6); no other obstacle. Tap a row Rocket at (0,2) → row 2 frees the creature (goal 1/1) and sets off the Crane; fall, refill; the Crane takes off from (6,2) and, with no goal left, targets (6,6) → bramble 1 layer; the win event comes after the Crane's landing and the board settling (IR-56); moves 4.
- Crane at (4,4). Goals: OB08 count 2, red lanterns at (4,1) with screen hp 2 and at (8,8) with the screen open (2 + 1 + 0 + 1 = 4 hits left); brambles with 5 hits left → targets a lantern; (4,1) is closer (distance 3 vs 5.66) → its screen hp 1; not lit.
- Crane at (4,4). Goals: OB08 count 1, red lantern with screen hp 2 at (2,2) (3 hits left); brambles with 2 hits left → targets a bramble cell.
- Crane at (4,4). The level's red lantern at (4,5) was lit earlier (removed) and its goal is complete; all other goals complete; only obstacle left: a bramble at (4,8) → targets (4,8), never (4,5).

---

## E. Combos (swap two specials)

### IR-22 · Rocket + Rocket: row and column cross (CHANGED)
Rule: Swapping two Bamboo Rockets fires the full row and the full column through the swap's target cell (IR-46), as one special (IR-45).
Applies to: Bamboo Rocket + Bamboo Rocket (taught at level 8), whatever their own directions.
Source: GDD › Core gameplay › Combos › "Rocket + Rocket | Row and column cross"; Rules clarifications › OQ-12, OQ-13.
Test cases:
- Rocket at (4,4), Rocket at (4,5). Swap (4,5)→(4,4) on a plain 9×9 board → row 4 and column 4 cleared (17 cells), nothing else; moves −1.
- Same, with goo hp 2 under (4,4) → goo hp 1 (crossing cell hit once).

### IR-23 · Rocket + Firecracker: 3-wide row and 3-wide column (CHANGED)
Rule: Swapping a Bamboo Rocket with a Firecracker hits rows y−1 to y+1 and columns x−1 to x+1 in full, where (x, y) is the swap's target cell, as one special.
Applies to: Bamboo Rocket + Firecracker (taught at level 12).
Source: GDD › Core gameplay › Combos › "Rocket + Firecracker | 3-wide row and 3-wide column"; Rules clarifications › OQ-12, OQ-13.
Test cases:
- Firecracker at (3,4), Rocket at (4,4). Swap (3,4)→(4,4) on a plain 9×9 board → rows 3–5 and columns 3–5 cleared (45 cells).
- Same, with bramble (OB02) 2 layers at (3,3) (inside both bands) → bramble 1 layer.

### IR-24 · Firecracker + Firecracker: 5×5 double blast (CHANGED)
Rule: Swapping two Firecrackers blasts the 5×5 area centred on the swap's target cell, then pieces fall, refill and all cascades resolve, then it blasts the same 5×5 again; the whole combo gives any single obstacle at most one hit.
Applies to: Firecracker + Firecracker (on the cut list, step 5).
Source: GDD › Core gameplay › Combos › "Firecracker + Firecracker | 5×5 double blast"; Rules clarifications › OQ-12, OQ-13, OQ-32 "Firecracker + Firecracker uses the same timing".
Test cases:
- Firecrackers at (4,4) and (4,5). Swap (4,5)→(4,4) → first blast covers (2–6, 2–6); two blast events.
- Same, with frozen idol (OB12) 2 hits left at (2,2) → idol 1 hit left.
- Same swap on a plain 9×9 board with no matches forming → blast 1 clears 25 cells (2–6, 2–6); pieces from (2–6, 0–1) fall to (2–6, 5–6); 25 new pieces enter at (2–6, 0–4); blast 2 clears (2–6, 2–6) again → 50 pieces cleared in total; events in order: blast 1, fall, refill, blast 2.

### IR-25 · Jade Orb + special: the most common colour becomes that special (CHANGED)
Rule: Swapping a Jade Orb with a Rocket or Firecracker turns every uncovered plain piece of the most common uncovered plain colour (ties: IR-47; pieces under an overlay are neither counted nor converted) into that special (converted Rockets copy the swapped Rocket's direction); every converted piece leaves the board at once and its cell refills by normal falling; then they fire one at a time, each from the cell it was converted in, lowest first then left-most, each finishing (fall and refill included) before the next; cascade matches resolve only after the last one; the whole combo counts as one special (IR-45).
Applies to: Jade Orb + Bamboo Rocket, Jade Orb + Firecracker (on the cut list, step 5). Not Orb + Crane (IR-27) or Orb + Orb (IR-26). A converted Firecracker still has cascades between its own two blasts (IR-17).
Source: GDD › Core gameplay › Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires"; Rules clarifications › OQ-12, OQ-14, OQ-24, OQ-27 "Set-off specials fire lowest first, then left-most", OQ-33; Owner decision, chat 27 Nov 2026 › OQ-42 (Option B: covered plain pieces neither count nor are cleared), OQ-44 (Option A: only fall and refill before a waiting special fires; cascades after), OQ-48 (Option A: "every converted piece leaves the board at once … and its cell refills by normal falling; each then fires from the cell it was converted in, lowest then left-most, each finishing (falls included) before the next").
Test cases:
- Plain pieces only besides the two specials: 20 R (most common). Orb swapped with a Firecracker → the 20 R become Firecrackers and each fires; the Orb and the swapped Firecracker are used up.
- Same, with a 2×2 pillar hp 3 inside the areas of several converted Firecrackers → pillar hp 2.
- Orb at (4,4), column Rocket at (4,5) → every converted Rocket is a column Rocket (IR-16).
- R only at (2,1),(6,1),(2,7); Y, B, G two pieces each; Orb at (4,4), Firecracker at (4,5); every other cell holds a withered bramble (OB02). Swap (4,5)→(4,4) → converted Firecrackers fire in the order (2,7), (2,1), (6,1).
- Plain 18 R, 19 Y, 17 B, 16 G, plus 3 red Rockets on the board → Y is converted (the red Rockets don't count and aren't converted).
- Same set-up as the (2,7),(2,1),(6,1) test, plus creep moss hp 1 over an R at (6,7) → (6,7) is not converted; the fire order is still (2,7), (2,1), (6,1); the R at (6,7) is still there under moss hp 1.
- Plain board; R is the most common colour; the only R in rows 7–8 are at (2,8) and (2,7). Orb at (4,4) swapped with a row Rocket at (4,5) → the first two converted Rocket fire events are row 8 (from (2,8)) and then row 7 (from (2,7)), with a fall and refill between them; the Rocket converted at (2,7) fires along row 7, not row 8, although pieces fell in column 2 before its turn.

### IR-26 · Jade Orb + Jade Orb clears the whole board (CHANGED)
Rule: Swapping two Jade Orbs clears every piece on the board (other specials are cleared without firing), collects every collectible goal item (fragments included) and gives the top obstacle layer of every cell one hit.
Applies to: Jade Orb + Jade Orb. A multi-cell obstacle takes one hit in total (IR-10, a combo is one special). In a cell with moss over goo, only the moss is hit.
Source: GDD › Core gameplay › Combos › "Jade Orb + Jade Orb | Clears the whole board and hits the top layer of every cell once"; Interaction rules › "Jade Orb + Jade Orb | Clears the whole board, collects every collectible goal item (fragments included) and hits the top obstacle layer of every cell once (goo under moss is not hit). Other specials are cleared without firing"; "Obstacles bigger than one cell | Take at most one hit per special"; Rules clarifications › OQ-12 "A combo counts as one special", OQ-27, OQ-37 "Top layer only: moss over goo loses one moss layer; the goo is untouched".
Test cases:
- Board with a lost hatchling (OB11) at (3,2) and a fragment drop item at (6,1) → both collected (goal counters +1 each), neither is "destroyed".
- Bramble (OB02) with 3 layers at (1,1); 2×2 pillar (OB06) hp 3 → bramble has 2 layers, pillar hp 2.
- Every plain piece on the board is cleared.
- Creep moss (OB03) hp 2 alone at (2,5); creep goo (OB10) hp 2 under a plain piece at (7,5) → moss hp 1; goo hp 1.
- Moss hp 1 over a piece, on goo hp 1, at (4,4) → piece cleared; moss removed; goo still hp 1.
- Row Rocket at (2,2) and Firecracker at (6,6) on the board; bramble 3 layers at (7,2) → both specials cleared with no fire events; bramble has 2 layers.

### IR-27 · Crane swapped with a special: no combo, the other special first, then the Crane (CHANGED)
Rule: A Paper Crane swapped with any other special is never refused, uses one move and makes no combo: the other special fires first from the cell it sits in after the swap (a Jade Orb clears the most common colour, as for a tap), then the Crane flies once to whatever goal is left; in Crane + Crane, the Crane the player dragged flies first, then the other.
Applies to: Crane + Rocket, Crane + Firecracker, Crane + Jade Orb, Crane + Crane. (The Crane + special combo is out of scope for the MVP; this rule is what happens instead.)
Source: GDD › Interaction rules › "Crane swapped with another special (Jade Orb included) | No combo in the MVP and never refused: the other special fires first, then the Crane flies to whatever goal is left"; Rules clarifications › OQ-15 "The Orb clears the most common colour (as for a tap), then the Crane flies", OQ-26 "each special fires from the cell it sits in", OQ-34 "In Crane + Crane, the dragged Crane flies first".
Test cases:
- Moves 12. Crane at (4,4), Firecracker at (4,5); swap (4,5)→(4,4) → accepted; moves = 11; the Firecracker (now at (4,4)) blasts centred on (4,4); every Firecracker event comes before any Crane event; no combo event; the Crane (now at (4,5)) flies exactly once.
- Crane at (4,4), row Rocket at (4,5); swap (4,5)→(4,4) → the Rocket fires from (4,4): row 4 cleared, row 5 not; then the Crane (at (4,5)) flies.
- Goals: bramble hp 1 at (5,4) and a mummified creature hp 1 at (0,0). Swap as in test 1 → the Firecracker clears the bramble, then the Crane targets (0,0).
- Plain pieces: 20 R, 18 Y, 17 B, 16 G. Orb swapped with a Crane → all R cleared, then the Crane flies.
- Cranes at (4,4) and (4,5); only goal: creatures hp 1 at (4,0) and (4,8). Swap (4,5)→(4,4) → the dragged Crane (now at (4,4)) flies first: take-off (4,4), lands on (4,0) (equal distance 4; top-most); then the other Crane takes off from (4,5) and lands on (4,8); moves −1.

### IR-46 · A combo is centred on the swap's target cell (NEW)
Rule: A combo's area is centred on the cell the player moved the special into (the swap's target cell).
Applies to: IR-22, IR-23, IR-24 (Orb combos have no centre).
Source: GDD › Rules clarifications › OQ-13 "The cell the player moved the special into".
Test cases:
- Rockets at (4,4) and (4,5). Swap (4,5)→(4,4) → row 4 + column 4. Swap (4,4)→(4,5) instead → row 5 + column 4.
- Firecracker at (2,3), Rocket at (3,3). Swap (2,3)→(3,3) → rows 2–4 and columns 2–4.

---

## F. Soul fragments and drop items

### IR-28 · Fragments and drop items are never destroyed
Rule: No special, combo or board clear ever destroys a soul fragment or a drop item.
Applies to: Soul fragments (in a cocoon or riding a drop item), OB11 lost hatchlings. All specials and combos.
Source: GDD › Interaction rules › "Soul fragments and drop items | Never destroyed by any special, combo or board clear"; Soul fragments › Rules › "no special can destroy it".
Test cases:
- Fragment drop item at (4,4). A row Rocket clears row 4 → the fragment is still on the board (at (4,4) or lower after falling); not collected; goal unchanged.
- Hatchling (OB11) at (4,4). A Firecracker at (4,5) fires → hatchling still on the board.
- Jade Orb + Jade Orb with a fragment on board → fragment is collected, not destroyed (IR-26).

### IR-29 · A freed cocoon collects its fragment at once
Rule: When a creep cocoon holding a fragment is freed, the fragment is collected immediately.
Applies to: Fragments sealed in a cocoon (OB07 behaviour), levels 26–33 and later.
Source: GDD › Interaction rules › "A freed cocoon collects its fragment at once"; Soul fragments › Rules › "sealed in a creep cocoon (OB07 behaviour) and freed by adjacent matches".
Test cases:
- Cocoon hp 1 with a fragment at (4,4). A 3-match at (3,5),(4,5),(5,5) → cocoon freed; fragment goal +1 in the same resolve; no fragment piece remains on the board.
- Cocoon hp 1 at (4,4). A row Rocket clears row 4 → cocoon freed and fragment collected (the hit is on the cocoon, not the fragment).

### IR-30 · Where and how a drop item is collected (CHANGED)
Rule: A drop item is collected when it reaches the bottom playable cell of its column (only in the level's `exit_columns` if it lists them), or when a Paper Crane lands on it or Jade Orb + Jade Orb fires; other specials leave it in place.
Applies to: OB11 lost hatchlings (from 34) and fragments riding drop items (from 38). Boosters: IR-34.
Source: GDD › Interaction rules › "a drop item still has to reach the bottom row unless a Crane or Orb + Orb collects it"; Obstacle set › OB11 "Bring it to the bottom row to collect it"; Rules clarifications › OQ-20 "On reaching the bottom playable cell of their column. If a level lists `exit_columns`, only those columns collect".
Test cases:
- No `exit_columns`. Hatchling falls to (4,8) → collected; goal +1.
- No `exit_columns`; (3,8) is not playable. Hatchling falls to (3,7) → collected.
- `exit_columns` [2,6]. Hatchling falls to (4,8) → not collected; stays at (4,8). Another falls to (2,8) → collected.
- Hatchling at (4,2). A Firecracker covers it → not collected; still on board. A Crane targets it → collected (IR-48).

### IR-31 · A fragment always takes one of the level's goal slots (CHANGED)
Rule: On a fragment level the soul fragment is always one of the goals, written as an obstacle goal with the fragment flag (`{"obstacle": "OB07", "count": 1, "fragment": true}` for a fragment in a cocoon; OB11 for one riding a drop item), and uses one of the tier's goal slots, never an extra one; freeing the fragment's cocoon (or collecting its drop item) completes that goal and also counts one toward a plain OB07 (or OB11) goal on the same level; the level file marks the object itself: the fragment's cocoon is the OB07 entry in `objects` with `"fragment": true`, and a fragment drop item is set by `"fragment_item": n` in `spawn.drop_items` (the n-th item spawned carries it, counting in the spawn order of IR-75).
Applies to: Fragment levels 26, 30, 33, 35, 38, 40, 45, 50. (GoalTracker / LevelLoader / validator, not MatchResolver.) Goal units and counts: IR-61 (the fragment goal's count 1 = one marked cocoon or one `fragment_item`; a plain OB07 / OB11 goal's count includes the fragment's cocoon or item). The schema lines are in the owner-only brief (round 6 update list in open_questions.md).
Source: GDD › Core gameplay › "On a fragment level the soul fragment is always one of the goals and uses one of the tier's slots, never an extra one, so a level cannot be won without it"; Technical design › Level format "A fragment level also lists the fragment in goals, inside the tier's goal count"; Soul fragments › "sealed in a creep cocoon (OB07 behaviour) … it can also be an OB11 drop item"; Owner decision, chat 28 Nov 2026 › OQ-65 (Option B: "(a) an obstacle entry with a flag, e.g. `{"obstacle": "OB07", "count": 1, "fragment": true}`; (b) yes: it also counts toward a plain OB07 or OB11 goal on the same level"; owner's words: "Basically fragment is part of the goal and must be completed to pass"), OQ-71 (Option A: "Mark the object itself: the fragment's cocoon is one of the OB07 entries in `objects`, with `"fragment": true`; for a fragment drop item, `spawn.drop_items` gets e.g. `"fragment_item": n` (the n-th item spawned carries it)").
Test cases:
- Level 35 (hard, 3–4 goals) lists 4 goals, one of them `{"obstacle": "OB07", "count": 1, "fragment": true}` → valid. Lists 4 other goals plus the fragment entry as a 5th → validator rejects.
- A fragment level whose goals contain no entry with `"fragment": true` → validator rejects.
- All non-fragment goals done, fragment not collected → level is not won.
- Goals: fragment `{"obstacle": "OB07", "count": 1, "fragment": true}` and plain `{"obstacle": "OB07", "count": 3}`; 3 cocoons hp 1 on the board, the one at (4,4) holding the fragment. A match frees (4,4) → fragment goal 1/1 (done) and plain OB07 goal 1/3. A match then frees another cocoon → fragment goal still 1/1; plain OB07 goal 2/3.
- Goals: fragment `{"obstacle": "OB11", "count": 1, "fragment": true}` and plain `{"obstacle": "OB11", "count": 2}`. The fragment's drop item reaches its exit (IR-30) → fragment goal 1/1; plain OB11 goal 1/2. A plain hatchling is collected → plain OB11 goal 2/2; fragment goal unchanged.
- Level 26 (fragment level) with goals: fragment OB07 and plain OB07 count 3 (3 cocoons, one holding the fragment). Two plain cocoons are freed → plain OB07 goal 2/3; fragment goal 0/1; not won.
- LevelLoader: `objects` has OB07 entries at (2,2), (4,4) and (6,6), and only (4,4)'s has `"fragment": true` → after loading, the fragment is in the cocoon at (4,4); the cocoons at (2,2) and (6,6) hold none.
- LevelLoader: `spawn.drop_items` = `{"type":"OB11","total":3,"max_on_board":1,"fragment_item":2}` → the 1st and 3rd items spawned are plain hatchlings; the 2nd carries the fragment.
- Same `spawn.drop_items`. At the start one plain hatchling is in row 0 (IR-75). It reaches its exit and is collected → at the next refill the 2nd item, carrying the fragment, enters at the top of a seeded random column; once that one is collected, the 3rd (plain) enters at the next refill; no 4th ever enters.
- Validator: fragment goal OB07 count 1 and plain OB07 count 3; `objects` has 3 OB07 entries, one with `"fragment": true` → valid. Plain OB07 count 2 (leaving out the fragment's cocoon) → rejected.
- Validator: fragment goal OB07 count 1 and no OB07 entry with `"fragment": true` → rejected; two OB07 entries with `"fragment": true` → rejected.
- Validator: fragment goal OB11 count 1 and plain OB11 count 3; `spawn.drop_items` total 3 with `"fragment_item": 2` → valid. Plain OB11 count 2 → rejected. No `fragment_item` → rejected. `"fragment_item": 4` (more than total 3, so it never spawns) → rejected.

---

## G. Gravity, refill, cascades and shuffle

### IR-32 · Pieces fall, refill, and cascades chain until stable (CHANGED)
Rule: After clears, pieces fall and refill (IR-51), and any new matches resolve automatically (making specials by IR-42) until no match remains, without using a move.
Applies to: Every resolve after a swap, tap, combo or booster. Between a Firecracker's two blasts: IR-17.
Source: GDD › Core gameplay › Rules › "Pieces fall, new ones drop from the top, cascades chain automatically."; Rules clarifications › OQ-05, OQ-19.
Test cases:
- Plain column 4: clear (4,6),(4,7),(4,8) → pieces formerly at (4,0)–(4,5) now at (4,3)–(4,8); 3 new pieces at (4,0)–(4,2); no empty cells.
- A fall creates a new R line of 3 → it clears in the same resolve without another swap and without using a move; the board ends with no matches.

### IR-33 · No possible move: free shuffle (CHANGED)
Rule: When a stable board has no possible move (no swap that would be accepted and no uncovered special to tap), uncovered plain pieces and specials are shuffled for free, never moving obstacles, fragments, drop items or pieces and specials under an overlay, so that the result has at least one possible move and no ready-made match.
Applies to: Any stable board. Independent of Feather Fan (IR-35). A special under an overlay can't be tapped (IR-02, IR-54), so it doesn't count as a possible move.
Source: GDD › Core gameplay › Rules › "No possible move: free shuffle with a short animation"; Meta & economy › Feather Fan "the free auto-shuffle still happens when no move exists"; Rules clarifications › OQ-22 "Moves only plain pieces and specials, never obstacles, fragments or drop items; must leave at least one valid move and no ready-made matches"; Owner decision, chat 27 Nov 2026 › OQ-41 (Option A (b): "the shuffle leaves covered pieces where they are"), OQ-57 (Option A: a covered special "can't be swapped, doesn't fall and can't be tapped").
Test cases:
- Moves 8. Stable board of plain pieces with no valid swap → a shuffle event; moves = 8; the shuffled board has at least one valid swap and no match.
- Same, with a bramble at (2,2), a cocoon at (5,5) and a hatchling at (7,1) → all three in the same cells after the shuffle.
- Same, with creep moss hp 1 over a G at (3,6) → after the shuffle (3,6) still holds that G under moss hp 1.
- A board where a plain-piece swap and a tappable special both exist → no shuffle.
- Moves 8. Stable board with no valid swap; the only special is a row Rocket under creep moss hp 1 at (2,6) → a shuffle event; moves = 8; the Rocket is still at (2,6) under moss hp 1.

### IR-51 · Gravity and refill (CHANGED)
Rule: Pieces, specials and drop items first fall straight down into empty cells, passing straight through non-playable cells to the playable cells below them; then a cell that can't be filled from straight above because a blocker (an obstacle or a locked covered piece) is in the way is filled by a piece sliding in diagonally, from the upper-left first, then the upper-right; new pieces enter at the top playable cell of every column, and spawner cells add extra entry points on levels that have them.
Applies to: Every fall step (IR-17, IR-32). Obstacles don't fall; locked covered pieces don't fall and count as blockers (IR-54).
Source: GDD › Rules clarifications › OQ-19 "Pieces fall straight down; where a cell can't be filled from above because of a blocker, a piece may slide in diagonally. New pieces drop in at the top of each column, or at spawner cells where the level has them" (the row now opens "Pieces locked under an overlay (moss, shutter) don't fall. Other pieces fall straight down"), OQ-35 "Straight falls first, then diagonal slides (upper-left before upper-right). Every column refills at its top playable cell; spawners add extra entry points"; Owner decision, chat 27 Nov 2026 › OQ-41 (Option A (c): "the locked piece counts as a blocker, so the cell below fills by a diagonal slide"), OQ-45 (Option A: "Pieces pass straight through non-playable cells to the playable cells below them").
Test cases:
- Plain column 4: clear (4,6),(4,7),(4,8) → see IR-32 test 1.
- Bramble (OB02) with 2 layers at (3,2); cells (3,3),(3,4),(3,5) are emptied directly (no match, no special) and the board settles → after the fall no playable cell is empty; the bramble is still at (3,2) (obstacles don't fall) with 2 layers. (Layer hits from a match are IR-14, not this rule.)
- Bramble at (4,3); (4,4) emptied directly → (4,4) is filled by the piece from (3,3) (upper-left), not from (5,3); the piece at (5,3) has not moved; column 3 then falls by one and a new piece enters at (3,0).
- Level with a spawner at (2,0) only; (6,8) emptied directly → pieces at (6,0)–(6,7) move to (6,1)–(6,8); a new piece enters at (6,0).
- (5,0) and (5,1) not playable; (5,8) emptied directly → pieces at (5,2)–(5,7) move to (5,3)–(5,8); a new piece enters at (5,2).
- (3,4) not playable; (3,5) emptied directly → the piece from (3,3) falls straight through (3,4) to (3,5); pieces at (3,0)–(3,2) move to (3,1)–(3,3); a new piece enters at (3,0); (3,4) stays empty (not playable); no diagonal slide happens.
- Moss hp 2 over G at (4,3); (4,4) emptied directly → see IR-54 test 4: (4,4) filled from (3,3) by a diagonal slide; G stays at (4,3).

---

## H. Hero boosters (BoosterService, not MatchResolver; listed because they share the hit rules)

### IR-34 · Boosters collect fragments and drop items, never delete them (CHANGED)
Rule: Hoof Tap, Tail Slam and Bamboo Dash collect any fragment or drop item they hit and never delete it.
Applies to: Hoof Tap (11), Tail Slam (23), Bamboo Dash (29). A booster uses no move (IR-62). A collected fragment drop item also counts toward a plain OB11 goal (IR-31).
Source: GDD › Interaction rules › "Hero boosters on fragments and drop items | Never deleted. Hoof Tap, Tail Slam and Bamboo Dash collect a fragment or drop item they hit"; Owner decision, chat 28 Nov 2026 › OQ-67 (Option A: "Using Hoof Tap, Tail Slam, Bamboo Dash or Feather Fan uses no move").
Test cases:
- Hoof Tap on a hatchling (OB11) at (4,2) → collected; goal +1.
- Bamboo Dash along row 3 passes a fragment drop item at (6,3) → fragment collected.
- Moves 6. Hoof Tap on a hatchling at (4,2) → collected; moves = 6.

### IR-35 · Feather Fan moves pieces only (CHANGED)
Rule: Feather Fan reshuffles pieces only and never moves fragments or drop items.
Applies to: Feather Fan (36). It uses no move (IR-62).
Source: GDD › Interaction rules › "Feather Fan moves pieces only, never fragments or drop items"; Meta & economy › "Reshuffles the board"; Owner decision, chat 28 Nov 2026 › OQ-67 (Option A).
Test cases:
- Fragment drop item at (2,3), hatchling at (6,1). Use Feather Fan → both still at (2,3) and (6,1); plain pieces have moved.
- Moves 4. Use Feather Fan → moves = 4.

### IR-36 · Boosters hit like a special (CHANGED 28 Nov: a booster sets off a special it hits, OQ-106 B)
Rule: On everything other than fragments and drop items, every booster acts like a special on each cell it covers (IR-09): it clears the piece there and gives one hit to the top obstacle layer, and a multi-cell obstacle takes at most one hit per use (Bamboo Dash's diagonal included); if the piece cleared is a special, that special is set off as in IR-41 (lifted off the board, fall and refill, then it fires from its cell; a Jade Orb is removed without effect) and the booster's own hit on the cell's top layer still happens as above, while the special's blast gives its own hits as a separate special (IR-41).
Applies to: Hoof Tap (one cell of the player's choice), Tail Slam (3×3, one hit to every cell), Bamboo Dash (one full row, column or diagonal). A booster uses no move (IR-62), and neither does the special it sets off. A booster has no second special, so it never makes a combo (IR-22 to IR-26 need two specials swapped); a set-off special fires alone. Details the GDD does not settle: Orb tapped by Hoof Tap (OQ-107), special under moss (OQ-108), the tapped cell hit by both the booster and the special (OQ-109), Tail Slam and Bamboo Dash on specials (OQ-110).
Source: GDD › Interaction rules › "Hero boosters on everything else | Like a special: one hit per cell, top layer only; a multi-cell obstacle takes at most one hit per use. Bamboo Dash's diagonal follows the same rule"; Meta & economy › Booster unlocks › Hoof Tap "Clears the piece in one cell of the player's choice and gives that cell's top obstacle layer one hit", Tail Slam "one hit to every cell in it"; Rules clarifications › OQ-36 "Every booster clears the piece and gives the top obstacle layer one hit", row 04 "Special hit by another special | It fires too (a chain) … A set-off Jade Orb is removed without effect"; Owner decision, chat 28 Nov 2026 › OQ-106 (Option B: "a Hoof Tap on a cell holding a special fires that special as in Rules clarifications row 04").
Test cases:
- Moves 10. Hoof Tap on a red row Rocket at (4,4) (no obstacle) → the Rocket is cleared and lifted; fall, refill; it fires along row 4 from (4,4); moves = 10 (IR-62). Events in order: booster clear (4,4), fall, refill, Rocket fire (row 4), fall, refill.
- Hoof Tap on a Firecracker at (4,4) → cleared and lifted; fall, refill; blast 1 on the 3×3 around (4,4), fall, refill and cascades, blast 2 (IR-17); moves unchanged. Bramble (OB02) 2 layers at (5,4) → 1 layer (the two blasts are one hit, IR-12).
- Hoof Tap on a Rocket at (4,4); a column Rocket at (6,4) → the tapped Rocket fires along row 4 and sets off the column Rocket (IR-41), which fires after the fall; every event of the first before any of the second.
- Hoof Tap on a Paper Crane at (4,4); goal OB02 bramble hp 1 at (7,7), the only remaining obstacle → crane target (7,7), take-off (4,4), landing (7,7) (IR-48, IR-49); bramble removed; moves unchanged. With a fragment cocoon hp 3 also present, the target is the cocoon (IR-49).
- Hoof Tap on a Jade Orb at (4,4) with 20 R, 18 Y, 17 B, 16 G plain pieces → the Orb is removed without effect: no colour-clear event; all 71 other pieces stay; moves unchanged (row 04; OQ-107).
- Hoof Tap on a row Rocket at (2,6) under moss hp 1 → (OQ-108 A) the Rocket is cleared and the moss removed (the booster's hit), the Rocket fires along row 6 after the fall; moves unchanged. The same under moss hp 2 → moss hp 1 after the booster's hit, then the Rocket's own hit on its cell makes it hp 0 (OQ-109 A).
- Moves 10; only goal OB02 count 1; one bramble hp 1 at (7,4); Hoof Tap on a row Rocket at (4,4) → the Rocket fires along row 4, the bramble is removed → goal done, then win after the board settles (IR-56); moves = 10.
- Hoof Tap on a Jade Orb that is the only piece on goo hp 2 at (3,3) → Orb removed without effect; goo hp 1 (the booster's hit on the cell still happens).
- Tail Slam centred on (4,4); 2×2 pillar (OB06) hp 3 covers (4,4),(5,4),(4,5),(5,5) → pillar hp 2.
- Bamboo Dash on the diagonal (0,0)…(8,8) crossing a 1×4 pillar at x=4, y=2–5 → pillar loses 1 layer.
- Hoof Tap on a plain piece with no obstacle layer at (3,3) → piece removed.
- Hoof Tap on R on goo hp 2 at (3,3) → R cleared and goo hp 1 (both in one use).
- Hoof Tap on Y under moss hp 1, on goo hp 1, at (3,3) → Y cleared; moss removed; goo still hp 1.
- Hoof Tap on a bramble (OB02) with 2 layers → bramble 1 layer.
- Tail Slam centred on (4,4); B on goo hp 1 at (5,5) → B cleared and goo cleared.
- Moves 9. Bamboo Dash along row 4 → row 4 hit; moves = 9 (IR-62).

### IR-62 · Using a hero booster uses no move (NEW)
Rule: Using Hoof Tap, Tail Slam, Bamboo Dash or Feather Fan uses no move, so a booster can finish goals (and win, IR-56) but can never cause a fail (IR-57).
Applies to: All four hero boosters (BoosterService, GoalTracker). The board settles after a booster as after any action (IR-32), still without using a move. Booster prices and unlock levels: GDD › Meta & economy › Booster unlocks.
Source: GDD › Meta & economy › Booster unlocks (effect and price, nothing about moves); Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Owner decision, chat 28 Nov 2026 › OQ-67 (Option A: "Using Hoof Tap, Tail Slam, Bamboo Dash or Feather Fan uses no move").
Test cases:
- Moves 5. Hoof Tap on a plain piece at (3,3) → piece cleared; moves = 5.
- Moves 1; only goal OB02 count 3, no bramble cleared yet. Tail Slam that clears no bramble → moves = 1; no fail event; no continue offer.
- Moves 10. Only goal: OB07 count 1; mummified creature hp 1 at (4,4). Hoof Tap on (4,4) → creature freed; a win event; moves = 10; 10 finale Rockets (IR-16); win coins 20 + 5 × 10 = 70.

---

## I. Level flow (GoalTracker / UI, not MatchResolver)

### IR-37 · Continue offer: always shown, up to 5 times per attempt (CHANGED)
Rule: Each time moves run out, up to 5 times in one attempt, a "+5 moves" continue is offered whatever the state of the goals (even if they can no longer be reached): the 1st offer costs 300 coins and the 2nd to 5th cost 500 coins each; declining ends the attempt and goes to the retry screen; a player who has fewer coins than that offer's price still sees the offer, with the message "you have less than N coins" (N = that offer's price, 300 or 500), can't accept it and can only decline (→ retry screen); when moves run out a 6th time there is no offer and the attempt goes straight to the retry screen; quitting mid-level never shows the offer (IR-38).
Applies to: Every level fail by running out of moves. Not quitting (IR-38).
Source: GDD › Interaction rules › "Continue offer | Always shown after a fail, whether or not the goals can still be reached, and offered at least twice per attempt"; Rules clarifications › OQ-23; Core gameplay › Rules › Fail flow "an optional '+5 moves' for coins, offered at least twice per attempt whatever the board state, then the retry screen"; Meta & economy › Continue "Optional '+5 moves' for 300 coins, offered at least twice per attempt"; Owner decision, chat 27 Nov 2026 › OQ-39 ("39a: max 5, 39: 2nd-55h 500coins, 39c: attempt ends, goes back to retry screen, 39d: yes, shown but pop up says 'you have less than 300 coins' and hence cannot be accepted, eventually have decline and go back to retry screen"; the owner confirmed "2nd-55h" means 2nd–5th: "Q39 and Q40 is correct"), OQ-51 (Option A: "The offer appears only when moves run out; quitting goes straight to the fail result (life lost, first try used), with no offer"), OQ-52 (Option A: "The offer is shown; the message names that offer's price ('you have less than 500 coins'); only Decline works → retry screen").
Test cases:
- Moves hit 0; the only goal is "collect 5 hatchlings": 1 collected, 1 left on the board, none still to spawn (the goal can't be reached); 500 coins → the continue offer is shown, price 300.
- 3000 coins, goals never completed. Moves hit 0 five times and the player accepts each offer → prices 300, 500, 500, 500, 500; coins after each accept 2700, 2200, 1700, 1200, 700; moves = 5 after each. Moves hit 0 a sixth time → no offer; retry screen; coins 700.
- 1000 coins. Moves hit 0 → offer 1 (300); the player declines → the attempt ends; retry screen; coins 1000; moves are not added; no second offer for this fail.
- 250 coins. Moves hit 0 → the offer is shown with the message "you have less than 300 coins"; accepting is not possible (coins stay 250, moves stay 0); the only action is decline → retry screen. With exactly 300 coins → the offer can be accepted; coins 0; moves 5.
- 700 coins. Moves hit 0 → offer 1 (300) accepted; coins 400; moves 5. Moves hit 0 again → offer 2 is shown, price 500, with the message "you have less than 500 coins"; accepting is not possible (coins stay 400, moves stay 0); decline → retry screen; coins 400.
- 500 coins. Offer 1 accepted (coins 200). Moves hit 0 again → offer 2 shown with "you have less than 500 coins"; only decline works → retry screen; coins 200.
- 800 coins. Offer 1 accepted (coins 500). Moves hit 0 again → offer 2 can be accepted; coins 0; moves 5.
- 1000 coins, 7 moves left. The player quits → no continue offer; the fail result is shown at once (IR-38); coins 1000.

### IR-38 · Quitting mid-level counts as a fail (CHANGED)
Rule: Quitting mid-level counts as a fail: it goes straight to the fail result with no continue offer, costs a life (except on chapter finales and while unlimited lives run, IR-60), resets the win streak (IR-84) and counts as that level's first try; the app being closed or killed (crash, or the phone stopping it) mid-level counts as a quit, and on the next launch the player is on the map, with the level not resumed.
Applies to: Every level 1–50. The continue offer is only for running out of moves (IR-37). The attempt log and "first try": IR-86. Coins spent on continues and boosters in a killed attempt stay spent. How SaveService notices a killed attempt (e.g. an "attempt open" mark written at the start) is an implementation choice. Not yet specified: an attempt killed while unlimited lives were running whose next launch comes after they ran out. A board that fails to build after the attempt has started is not a quit: IR-88.
Source: GDD › Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try"; Meta & economy › Lives; Owner decision, chat 27 Nov 2026 › OQ-51 (Option A: "The offer appears only when moves run out; quitting goes straight to the fail result (life lost, first try used), with no offer"); Owner decision, chat 28 Nov 2026 › OQ-92 (Option A: "It counts as a quit (IR-38): a fail, a life lost (not on finales), the streak back to 0, the first try used and logged; on the next launch the player is on the map (the level is not resumed)").
Test cases:
- Level 12, 5 lives, first attempt. Quit after 3 moves → lives 4; attempt logged as a fail and as the first try.
- Level 25 (finale), 3 lives. Quit → lives 3; attempt logged as a fail.
- Level 12, 5 lives, 1000 coins, 7 moves left. Quit → no continue offer event; fail result shown; lives 4; coins 1000.
- Level 12, first attempt, lives 5, streak 3, coins 1000. Offer 1 accepted (coins 700), then the app is killed. Next launch → the map is shown (level 12 not resumed); lives 4; streak 0; coins 700; next level 12; one attempt logged: level 12, fail, quit, first try.
- Level 25, lives 2. The app is killed mid-level → next launch: lives 2; the attempt is logged as a fail and a quit.

### IR-56 · A level is won once all its goals are done and the move has fully settled; each goal is announced the moment it is done (CHANGED 28 Nov: goal done event)
Rule: A level is won when every one of its goals is done, counting everything a move does (its matches, cascades and specials), so goals finished by the last move win too; while any goal (the fragment goal included, IR-31) is not done the level is not won; when the last goal is done, the rest of that move still happens in full (the rest of the match or special that finished it, falls, refills, waiting specials, second blasts, cascades and any free shuffle), the win is declared only once the move has fully settled, and then the moves left (0 if the level was won on its last move) become finale Rockets that start on that settled board (IR-16). Goal done event (added 28 Nov 2026): the moment a goal's count is reached inside a move, the game emits one "goal done" event for that goal, at that point in the move's event sequence and before the events of everything that happens after it (the rest of the match or special, falls, refills, waiting specials, cascades), so the UI can mark the objective achieved at once; the win event still comes only after the move has settled.
Applies to: Every level 1–50 (GoalTracker). Goal done events: one per goal per attempt, never repeated and never withdrawn (goals never become undone); a goal finished by the last move's cascade, or by a booster (IR-62), fires too; the goal done event comes right after the clear or hit event that reached the count and before the next event of the move (the fall, a blast, a cascade); a goal done event is not a win: the win event follows once every goal is done and the move has settled (an all-goals-done move still emits its goal done events first). Two or more goals reached by one and the same hit: their goal done events come in goal-bar order, the order the goals are listed in the level file, all before the next event of the move; each event carries the goal's index in that list and its obstacle ID (GDD Rules clarifications row 101). Fragment goal: IR-31; dew: IR-61. What uses a move: IR-01, IR-02, IR-18, IR-22 to IR-27, IR-39 (one each); IR-52 refused swaps, IR-01 snap-backs, IR-32 cascades, IR-33 shuffles and hero boosters (IR-62) use none. What adds to a goal, and what one unit is: IR-61 (IR-14 creature freed, IR-29 fragment, IR-30, IR-48, IR-26, IR-34 drop items and fragments collected, IR-53 dew, IR-55 shrine lit). Win coins: IR-16; coins come only from the win (20 + 5 per finale Rocket), so extra clears after the goals are done pay nothing. A waiting Crane that flies after the goals are done aims by IR-49's no-goal case. Nothing in levels 1–50 undoes goal progress, so a goal done part-way through a move is still done when the move settles. Goal progress never goes past the count (dew included: extra dew is not counted, IR-61, OQ-73), and a dew goal is never done at the start (the validator rejects a dew count not above the seed cells, IR-61, OQ-74).
Source: GDD › Core gameplay › Rules › "Win: all goals done before moves run out. Leftover moves become Bamboo Rockets that fire for bonus coins"; Core gameplay › Goals per level › "a level cannot be won without it"; Technical design › "`GoalTracker` | Goals and moves; win or fail"; Meta & economy › Coins "Win = 20 + 5 per finale rocket"; Owner decision, chat 28 Nov 2026 › OQ-62 (Option A, trial: "One unit = one obstacle fully gone"), OQ-63 (Option A: "everything a move does (its matches, cascades and specials) counts for that move; finishing the goals on the last move is a win with 0 finale Rockets (win coins 20)"), OQ-64 (changed by the owner, 28 Nov 2026, replacing the earlier trial Option B "win at once, rest dropped"), OQ-72 (owner's words: "I would like the whole match to apply and the rest continued because that is the satisfaction level"), OQ-67 (Option A: boosters use no move); goal done event: GDD › Core gameplay › Rules › Win ("The moment a goal's count is reached, the game shows it as done (a "goal done" event) while the rest of the move still plays; if one hit finishes two goals, they show in goal-bar order"), GDD › Rules clarifications › row 101 "Goal done: two goals finished by one hit" ("They show as done in goal-bar order (the order listed in the level file); the event carries the goal's index and obstacle ID"); Owner decision, chat 28 Nov 2026 (after playtesting levels 6–10): "Objective should be marked as achieved once it has been cleared, and then let the cascades happen: it feels more intuitive to have the objective marked as achieved first while the rest of the cascades and animations happen." OQ-64 and OQ-72 stay in force for everything else: the rest of the move still happens in full and the win is declared after the settle.
Test cases:
- Goal done event, order (added 28 Nov 2026). Moves 10. Only goal: OB07 count 1; creature hp 1 at (2,2). A swap makes a 3-match at (3,1),(3,2),(3,3) → events in order: swap, match clear / creature freed, goal done (OB07), fall, refill, win, then the finale Rocket events; exactly one goal done event; it comes before the first fall event and before the win event.
- Two goals finished by one hit, goal-bar order (row 101). Moves 10. Goals listed in this order: index 0 = OB02 count 1 (bramble 1 layer at (6,6)); index 1 = OB07 count 1 (creature hp 1 at (6,7)). A column Rocket tapped at (6,0) hits column 6 once → bramble gone and creature freed in the same hit → events in order: rocket hit, goal done {index 0, OB02}, goal done {index 1, OB07}, fall, refill, win; both goal done events before the first fall event. Swap the two goals' order in the level file (OB07 first) with the same board → goal done {index 0, OB07} then {index 1, OB02}: the order follows the file, not the board position or the obstacle ID.
- Two goals, same move, different steps. Moves 10. Goals: OB07 count 1 (creature hp 1 at (2,2)) and OB02 count 1 (bramble 1 layer at (6,6)). The swap's 3-match frees the creature; the fall forms a cascade 3-match that removes the bramble (refill fixed by the test) → events in order: clear / freed, goal done (OB07), fall, refill, cascade clear / bramble gone, goal done (OB02), fall, refill, win. Two goal done events, one win event, the win last.
- Goal finishing on a cascade. Moves 5. Only goal: OB07 count 1; creature hp 1 at (6,6); the swap's 3-match touches nothing; the fall forms a cascade 3-match next to it (refill fixed by the test) → events: swap clear, fall, refill, cascade clear / creature freed, goal done, fall, refill, win. No goal done event before the cascade.
- Goal finishing on the last move's cascade. Moves 1. Same board as the previous test → goal done event, then the rest of the cascade events, then win; no fail event; 0 finale Rockets.
- Dew goal reaching its count mid-move. 9×9 board, only goal: OB04 count 72; 70 cells have dew. A row Rocket fires along row 4 and 4 of its cells get dew → one goal done event the moment the count 72 is reached (the 72nd cell; progress shows 72/72, IR-61); the rest of that special applies (75 cells have dew); a cascade then gives 2 more (77 cells); no second goal done event; one win event after the settle.
- Fragment goal. Level 26. Goals: the fragment goal (count 1 = the one marked cocoon, IR-31, IR-61) and one other goal already done. A match frees the fragment's cocoon (hp 1) → the fragment is collected (IR-29); one goal done event for the fragment goal right after that clear, before the fall; the fragment is never destroyed by the move's later steps; the win event comes after the settle. If the other goal is not done, there is no win event.
- Last goal done: goals never become undone. Two goals; goal A done by the first match of a move, goal B not done; later steps of the same move clear more of A's obstacle type or add new ones → no second goal done event for A, A stays done, and no win event while B is not done.
- Goal done by a booster. Hoof Tap finishes the only goal → goal done event, then the rest of the booster's events, then win; moves unchanged (IR-62).
- Moves 10. Only goal: OB07 count 1; one mummified creature hp 1 at (2,2). A swap makes a 3-match at (3,1),(3,2),(3,3) → creature freed; goal done; moves 9; a win event; 9 finale Rockets (IR-16); win coins 20 + 5 × 9 = 65.
- Moves 10. Goals: OB07 count 1 (one creature hp 1 at (2,2)) and OB11 count 1 (one hatchling at (6,1), not collected). The same swap frees the creature → OB07 goal done; OB11 goal not done; no win event; moves 9.
- Fragment level. Every non-fragment goal done, the fragment not yet collected, moves 4 → no win event (IR-31).
- Moves 10. Only goal: OB02 count 1; one withered bramble with 2 layers at (4,3). A 3-match at (3,4),(4,4),(5,4) → bramble 1 layer; goal 0/1; no win event; moves 9. A second match next to it → bramble gone; goal 1/1; a win event; moves 8.
- Moves 1. Only goal: OB07 count 1; creature hp 1 at (2,2). A swap makes a 3-match at (3,1),(3,2),(3,3) → moves 0; creature freed; a win event; no fail event; no continue offer; 0 finale Rockets; win coins 20.
- Moves 1. Only goal: OB07 count 1; creature hp 1 at (6,6). The swap's 3-match touches nothing; the fall forms a cascade 3-match next to (6,6) (refill fixed by the test) → creature freed; a win event; no fail event; no continue offer; 0 finale Rockets; win coins 20.
- Moves 3. Only goal: OB07 count 1; creature hp 1 at (5,5). Tap a Firecracker at (4,4); no match forms (refills fixed by the test) → blast 1 frees the creature; events in order: blast 1, fall, refill, blast 2, fall, refill, win; then the finale; moves 2; 2 finale Rockets; win coins 30.
- Moves 5. Only goal: OB07 count 1; creature hp 1 at (2,3). R at (2,4),(3,4); yellow Firecracker at (4,4); R at (4,5); no other match forms (refills fixed by the test). Swap (4,5)→(4,4) → R 3-match (2,4),(3,4),(4,4) frees the creature; events in order: match clear (Firecracker lifted, IR-39), fall, refill, Firecracker blast 1 centred on (4,5), fall, refill, blast 2, fall, refill, win, then the first finale Rocket event; moves 4; 4 finale Rockets; win coins 40.
- Moves 3. Only goal: OB07 count 1; creature hp 1 at (2,4). Bramble (OB02, not a goal) with 2 layers at (6,4). Tap a row Rocket at (0,4) → all 9 cells of row 4 are hit: creature freed and the bramble has 1 layer (the whole special applies, not only up to the creature's cell); the win event comes after the fall and refill; moves 2.
- Moves 2. Only goal: OB07 count 1; creature hp 1 at (2,2). The swap's 3-match frees it; the fall then forms a 4-match cascade elsewhere (refill fixed by the test) → the cascade clears and makes a Rocket (IR-42), which stays on the board unfired; the win event comes after that cascade's fall and refill; moves 1; then 1 finale Rocket.
- Moves 4. Only goal: OB07 count 1. The move that frees the last creature settles on a board with no possible move (refill fixed by the test) → events in order: …, shuffle (IR-33), win; moves 3; the finale's first cell draw uses the shuffled board.
- Moves 5. Only goal: OB07 count 1; the Crane case of IR-49's last test (the Crane flies after the goal is done and hits a non-goal bramble) → the bramble loses 1 layer; one win event; win coins 20 + 5 × 4 = 40 (the extra clears add no coins).

### IR-57 · Running out of moves with a goal not done is a fail (CHANGED)
Rule: When the moves left are 0 and, once the last move's resolve has fully settled, at least one goal is still not done, the level is failed and the continue offer follows (IR-37); if the last move finished every goal it is a win (IR-56), not a fail; an action that uses no move (snap-back, refused swap, tapping a non-special, a hero booster) can never cause a fail.
Applies to: Every level 1–50 (GoalTracker). Continue offers, prices and the retry screen: IR-37. Quitting: IR-38. Lives: IR-60. Boosters: IR-62. The win is also only checked once the move has fully settled (IR-56), so win and fail are decided at the same point.
Source: GDD › Core gameplay › Rules › "Win: all goals done before moves run out", "Fail flow: an optional '+5 moves' for coins, offered at least twice per attempt whatever the board state, then the retry screen"; Interaction rules › "Continue offer | Always shown after a fail"; Owner decision, chat 28 Nov 2026 › OQ-63 (Option A: "finishing the goals on the last move is a win with 0 finale Rockets"), OQ-64 (the fail "is checked once the resolve has fully settled"; unchanged when the owner changed the win timing on 28 Nov 2026), OQ-67 (Option A: "Using Hoof Tap, Tail Slam, Bamboo Dash or Feather Fan uses no move").
Test cases:
- Moves 1. Only goal: OB02 count 5; no bramble has been cleared. A swap makes a 3-match touching no bramble → moves 0; a fail event; continue offer 1 shown, price 300 (IR-37).
- Moves 1, a goal not done. A swap of two plain pieces that makes no match → snaps back; moves 1; no fail event.
- Moves 1, a goal not done. A refused swap (bramble with a plain piece, IR-52) → moves 1; no fail event.
- Moves 3, a goal not done; three accepted moves that don't finish it → a fail event only after the 3rd; none after the 1st or 2nd.
- Moves 1, a goal not done. Tap a Firecracker whose resolve has blast 1, fall, refill, a cascade, blast 2, fall and refill, none finishing the goal → moves 0; exactly one fail event, and it comes after the last fall/refill event of that move.
- Moves 1. Only goal: OB07 count 1, creature hp 1. The last move's own match doesn't touch it, a cascade in the same resolve frees it → a win event; no fail event (see IR-56).
- Moves 1, a goal not done. Use Hoof Tap (not finishing the goal) → moves 1; no fail event (IR-62).

### IR-58 · A failed fragment level keeps its fragment for the retry (NEW)
Rule: A soul fragment is added to its guardian only when its level is won; when the level is failed or quit (IR-38), no fragment is gained, even if it was freed or collected during that attempt, and the retry has the fragment back on the board with its goal not done.
Applies to: Fragment levels 26, 30, 33, 35, 38, 40, 45, 50 (GoalTracker, SaveService). The Rat's restoration at 8 fragments: IR-85.
Source: GDD › Soul fragments › Rules › "Fail the level and the fragment stays for the retry. The fragment is one of the level's goals, so winning always collects it"; Interaction rules › "Quitting mid-level | Counts as a fail".
Test cases:
- Level 26, save `fragments.rat` = 0. The fragment's cocoon is freed (fragment goal done), but moves run out with another goal not done; the player declines the continue → retry screen; `fragments.rat` = 0. Retry → the fragment is back in the cocoon at the cell whose `objects` entry has `"fragment": true` (IR-31); the fragment goal is not done.
- Level 38, fragment on drop item 2 (`"fragment_item": 2`), `fragments.rat` = 3. The 2nd item spawned (the fragment) is collected, then the attempt fails → `fragments.rat` = 3. Retry → the item spawn count starts again from 1, so the 2nd item spawned carries the fragment again; the fragment goal is not done.
- Level 26, `fragments.rat` = 0. Every goal done → win; `fragments.rat` = 1.
- Level 30, `fragments.rat` = 1. The fragment is collected, then the player quits → `fragments.rat` = 1.

### IR-59 · How many goals each tier has (CHANGED)
Rule: An intro level has exactly 1 goal (its new obstacle), an easy level 1 or 2, a medium level 2 or 3, a hard level 3 or 4, and a finale exactly 4; a fragment goal counts inside these numbers (IR-31).
Applies to: LevelLoader and the level validator (GoalTracker can assume a valid level). The owner chose the tier table over Core gameplay's looser "1–3 on regular levels" (OQ-69).
Source: GDD › Level progression › Level tiers (Intro "1 (the new obstacle)", Easy "1–2", Medium "2–3", Hard "3–4", Finale "4"); Core gameplay › "Goals per level: 1 on intro levels, 1–3 on regular levels, 3–4 on hard levels, 4 on finales"; Board layers & obstacles › Rules from the research brief › "Intro level: the new obstacle is the only goal"; Owner decision, chat 28 Nov 2026 › OQ-69 (Option A: "Use the tier table: easy 1–2, medium 2–3").
Test cases:
- Intro level with 1 goal → valid; with 2 goals → rejected.
- Hard level with 2 goals → rejected; 3 → valid; 4 → valid; 5 → rejected.
- Finale with 3 goals → rejected; 4 → valid.
- Easy level with 1 goal → valid; 2 → valid; 3 → rejected.
- Medium level with 1 goal → rejected; 2 → valid; 3 → valid; 4 → rejected.
- Level 35 (hard) with 3 goals, one of them the fragment entry (IR-31) → valid; with 2 goals plus the fragment entry → valid (3 in total); with only 1 goal plus the fragment entry → rejected.

### IR-60 · A fail costs a life, except on chapter finales (CHANGED)
Rule: A life is lost only when an attempt ends in a fail (a declined continue offer, moves running out a 6th time, or a quit), at most one life per attempt, none on a chapter finale (levels 25 and 50 in the MVP), and none while the 10 minutes of unlimited lives after winning a finale are running (IR-81); running out of moves and accepting a continue costs no life by itself, and an attempt won after continues costs no life.
Applies to: Fails by running out of moves (IR-57, after the continue offers, IR-37) and quits (IR-38, the app closed or killed included). SaveService. Lives limit, refills, starting at 0 lives and unlimited lives: IR-81.
Source: GDD › Meta & economy › Lives "5 max; lose one on fail, except on chapter finales, where a fail costs no life"; Level progression › "finales at 25, 50, 75 and 100"; Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales)"; Owner decision, chat 28 Nov 2026 › OQ-70 (Option A: "Only when the attempt ends in a fail (declined offer, moves out a 6th time, or a quit): at most one life per attempt; an attempt won after continues costs no life"); Meta & economy › Lives "10 min of unlimited lives after each chapter finale" and Owner decision, chat 28 Nov 2026 › OQ-91 (Option A: only winning the finale gives them).
Test cases:
- Level 12, lives 5, 1000 coins. Moves run out; the player declines offer 1 → retry screen; lives 4.
- Level 25, lives 3. Moves run out; the player declines → retry screen; lives 3.
- Level 50, lives 2. The player quits → lives 2 (IR-38).
- Level 12, lives 5, 1000 coins. Moves run out; offer 1 accepted (lives still 5); the level is then won → lives 5.
- Level 12, lives 5, 1000 coins. Offer 1 accepted (lives 5); moves run out again; offer 2 declined → retry screen; lives 4 (one life, not two).
- Level 12, lives 5, 3000 coins. Offers 1 to 5 all accepted (lives 5 after each); moves run out a 6th time → retry screen; lives 4.
- Level 12, lives 5, 1000 coins. Offer 1 accepted; the player then quits → lives 4.
- Level 25, lives 3, 1000 coins. Offer 1 accepted; offer 2 declined → lives 3.

### IR-61 · Goals are obstacle goals; one unit is one obstacle fully gone; the count equals the number placed (NEW)
Rule: Every goal in levels 1–50 is an obstacle goal (`{"obstacle": "OBxx", "count": n}`, one of which may carry the fragment flag, IR-31), never a colour goal; one unit of its count is one obstacle fully gone (a bramble with no layers left, a moss cell removed, a goo cell cleared, a pillar ground down completely, a creature freed, an idol cleared, a shrine lit, a paper-screen lantern lit (IR-74), a drop item collected, a playable cell with dew), never one hit; the count must equal the number of those obstacles placed on the board (or that generators can produce), except a dew (OB04) goal, where every playable cell is a target, progress is the number of playable cells that have dew (seed cells counted from the start) but stops at the count (extra dew is not counted), and the count must be more than the number of seed cells and at most 90% of the playable cells.
Applies to: GoalTracker, LevelLoader and the level validator; every obstacle type in levels 1–50. Trial decisions (OQ-62, OQ-66): revisit after playtest. Fragment marking in the level file: IR-31. The Crane still compares goals by hits left, not units (IR-49). What finishes each obstacle: IR-14, IR-15, IR-29, IR-30, IR-48, IR-53, IR-55.
Source: GDD › Core gameplay › Goals per level › "Goals are always obstacles to clear, free or collect (see the obstacle table); 'collect N red' style goals are only used in tutorials"; `level_agent_brief.md` §4 Goals › "Goal count must equal what is placed on the board (or what generators can produce)"; Owner decision, chat 28 Nov 2026 › OQ-62 (Option A, trial: "One unit = one obstacle fully gone … The count must equal the number placed"), OQ-68 (Option A: "No colour goals in levels 1–50; GoalTracker supports obstacle goals (and the fragment goal) only"), OQ-66 (Option A, trial, "let's try A for now": "Every playable cell is a target; progress = playable cells that have dew, seed cells included from the start"), OQ-71 (Option A: fragment marked on its `objects` entry or by `"fragment_item": n`), OQ-73 (Option A: "Progress stops at the count: GoalTracker reports 72/72 and the counter shows the goal as done; extra dew is not counted"), OQ-74 (Option A: "Validator rejects a dew goal whose count is not more than the number of seed cells (the count must need at least one new dew cell)"); `level_agent_brief.md` §4 "OB04 spread goals must not exceed 90% of playable cells", §5 "`s` = OB04 already covering that cell (a seed)".
Test cases:
- Only goal: OB02 count 1; withered bramble with 3 layers at (4,3). Two matches next to it → 1 layer left; goal 0/1. A third → bramble gone; goal 1/1.
- Only goal: OB06 count 1; 2×2 pillar hp 3. A row Rocket covers it → hp 2; goal 0/1. Two more specials cover it → hp 0, pillar gone; goal 1/1.
- Goal: OB03 count 2; creep moss hp 2 at (1,1) and moss hp 1 at (6,6). One special hits each once → (1,1) hp 1, (6,6) removed; goal 1/2.
- Goal: OB10 count 1; creep goo hp 2 under (3,5). A match on top → hp 1; goal 0/1. A second match on top → goo cleared; goal 1/1.
- Goal: OB12 count 1; frozen idol with 2 hits left. One special covers it → 1 hit left; goal 0/1.
- Goal: OB05 count 1; lantern shrine hp 3 needing 2 R. An R match next to it fills both → lit; goal 1/1 (IR-55).
- Goal: OB08 count 1; red paper-screen lantern, screen hp 1. A special covers it → screen open; goal 0/1. A later R match next to it → lit; goal 1/1 (IR-74).
- Validator: two OB06 pillars, `"hp": 3` each; goal `{"obstacle": "OB06", "count": 2}` → valid; `"count": 6` (their hp added up) → rejected; `"count": 1` → rejected.
- Validator: 17 OB02 brambles placed (any layers); goal OB02 count 17 → valid; 16 → rejected; 18 → rejected.
- Validator: a goal `{"color": "red", "count": 20}` on any level 1–50 → rejected.
- Goal: OB04 count 10; seeds (`s`) under (1,1), (2,1), (3,1) → at the start, goal 3/10. Seven more playable cells get dew → 10/10 (done).
- Goal: OB04 count 10; 9 cells have dew (goal 9/10). A 3-match on dew gives dew to 3 cells, one of which already had it → 11 cells have dew; GoalTracker reports 10/10, not 11/10; the goal is done and the counter shows it as done (OQ-73).
- 9×9 board, all 81 cells playable. Only goal: OB04 count 72; 70 cells have dew (goal 70/72); row 4 has 4 cells with dew and 5 without. A row Rocket fires along row 4 → 75 cells have dew; GoalTracker reports 72/72 (done). A cascade in the same move gives 2 more cells dew → 77 cells have dew; still 72/72; one win event once the move settles (IR-56).
- Validator: 9×9 board, all 81 cells playable, no seeds; goal OB04 count 72 → valid (72 ≤ 72.9); count 73 → rejected.
- Validator: board with 70 playable cells, no seeds; goal OB04 count 63 → valid (63 = 90% of 70); count 64 → rejected.
- Validator: 9×9 board, all 81 cells playable, 5 seed cells (`s`); goal OB04 count 4 → rejected; count 5 → rejected (count not more than the seeds, OQ-74); count 6 → valid; count 72 → valid; count 73 → rejected.
- Validator: board with no seed cells; goal OB04 count 1 → valid; count 0 → rejected.
- Validator: fragment level, fragment goal OB07 count 1 + plain OB07 count 3, 3 OB07 entries in `objects` with one marked `"fragment": true` → valid; plain count 2 → rejected (IR-31).
- Validator: fragment level, fragment goal OB11 count 1 + plain OB11 count 2, `spawn.drop_items` total 2 with `"fragment_item": 1` → valid; plain count 1 → rejected (IR-31).
- Validator: level 5 (easy), goals OB04 count 70 and OB02 count 4, 4 OB02 brambles in `objects` (any layers), enough playable cells and seeds under the dew limits → valid (2 goals, IR-59); OB02 count 3 or 5 → rejected.

### IR-90 · Using Hoof Tap in a level: the button, arming, payment at the moment of use, and when it can be used (NEW; CHANGED 28 Nov: owner answers OQ-102 to OQ-106)
Rule: The Hoof Tap button shows locked until Hoof Tap is unlocked (when level 11 is first started, IR-82), then shows its free uses left, and once none are left its price, 100 coins; while a level is being played the player arms it with the button and then taps a playable cell, and that tap is the use: it takes a free use if any are left, otherwise 100 coins, with fewer coins it is refused and changes nothing (board, moves and coins untouched), and a use clears the cell as IR-36 and IR-34 say (a special on the cell is set off and fires, IR-36), uses no move (IR-62), can finish the goals and win the level (IR-56), and the new coin balance and free uses are shown at once; tapping the button again, or any area that is not a cell, cancels it with nothing spent, a tap on a cell that is not playable is not a use and spends nothing, and it can be used only while the player can make a move: not on the win, fail or retry screen, not while a move or an earlier booster is still resolving, and not during the continue offer.
Applies to: Hoof Tap only (Tail Slam, Bamboo Dash and Feather Fan: the same flow is NOT yet specified, left to when they are built); LevelSession / UI, BoosterService, SaveService, GoalTracker. Unlock, free uses (3, given once and kept between levels and retries, so a use on level 12 leaves 2 for level 13) and price (100): IR-82. Coins: IR-80; "paid at the moment of use", so arming is free and nothing is charged until the cell is tapped. What a use does to the cell: IR-34 (a fragment or drop item is collected and it counts as a use), IR-36 (piece cleared, top layer one hit); after it the board settles as IR-32. A cancelled attempt locks Hoof Tap again if that start unlocked it (IR-88). The tracker's coins and SaveService's coins are the same number: `use_hero_booster` takes `tracker.coins` first and sets it back to the new balance (API_CONTRACT 12.2, 12.6). The button, arming and cancelling are a grey-box UI flow decided by the owner (OQ-102 A, chat 28 Nov 2026; the GDD only says "one cell of the player's choice"). A refused use (not enough coins) leaves the button armed (OQ-103 A). A tap on a hole of the board shape counts as a non-cell area: it cancels (OQ-104 A). The button can't be armed and a use is refused while a move or booster resolves, in the finale, on the result screens and during the continue offer (OQ-105 A). A Hoof Tap on a special sets it off (OQ-106 B); the special it fires uses no move and can win, with goal done events as usual (IR-62, IR-56). Open details of that: OQ-107 to OQ-110.
Source: GDD › Meta & economy › Booster unlocks › "11 | Kancil's Hoof Tap | In-level | Clears the piece in one cell of the player's choice and gives that cell's top obstacle layer one hit | 3 free, then 100 coins each"; "A booster unlocks when its level is first started, so it can be used on that level. With no free uses left, each use costs its price at the moment of use; uses are never bought ahead"; "Using a booster uses no move"; Coins "No purchase (continue, life refill, booster) can be made with fewer coins than its price; coins never go below 0"; Interaction rules › "Hero boosters on fragments and drop items", "Hero boosters on everything else"; Rules clarifications › rows 36, 67, 93; Core gameplay › Rules › Win; Level progression › "Won levels cannot be replayed"; CLAUDE.md › Owner decisions (Hoof Tap level 11; coins pay for hero boosters, 100–200); Owner request, chat 28 Nov 2026 (a booster button, arm then tap a cell, tap the button again or a non-cell area to cancel, locked/free uses/price display; Owner decisions, chat 28 Nov 2026 › OQ-102 Option A (arm-then-tap), OQ-103 Option A (stays armed after a refusal), OQ-104 Option A (a hole cancels), OQ-105 Option A (not usable while a move or booster resolves, in the finale, on result screens, during the continue offer), OQ-106 Option B (Hoof Tap fires a special on the cell, as row 04).
Test cases:
- (a) Level 10 won, level 11 not yet started → the button shows locked; tapping it arms nothing; free uses 0 (locked). Level 11's first attempt starts → the button is unlocked and shows "3" free uses. Level 11's attempt is cancelled because its board fails to build (IR-88) → the button shows locked again, 3 free uses not given.
- (a) Hoof Tap unlocked, free uses 0, coins 500 → the button shows the price 100. Free uses 2, coins 500 → it shows 2 free (not the price). Free uses 0, coins 90 → it still shows the price 100; arming works, the cell tap is refused (see (c)).
- (b) Level 11 in play, free uses 3, button tapped (armed), cell (3,3) holding a plain piece tapped → piece at (3,3) cleared; free uses 2; no longer armed (one tap, one use); a second cell tap does nothing until the button is tapped again.
- (b) Button tapped (armed), button tapped again → not armed; free uses 3; coins unchanged; board and moves unchanged. Button tapped (armed), a tap on the area outside the board (or on a non-cell area of the screen) → not armed; nothing spent. Armed, nothing tapped yet → free uses 3 and coins unchanged (arming is free).
- (c) Free uses 3, coins 500, armed, cell tapped → free uses 2, coins 500. Free uses 0, coins 500 → coins 400, free uses 0. Free uses 0, coins 100 → coins 0. Never a free use and coins spent for the same use.
- (c) Free uses 0, coins 90, armed, cell (3,3) tapped → refused: coins 90; the piece at (3,3) and every other cell unchanged; moves unchanged; no events from the board; the player sees it was refused.
- (c) Hoof Tap locked (level 11 not yet started), coins 500; BoosterService is asked to use it on cell (3,3) → refused; coins 500; board unchanged; moves unchanged.
- (d) Armed; tap on a playable cell with a plain piece → a use. A playable cell with R on goo hp 2 → a use (IR-36). A playable cell with only an obstacle layer and its piece locked under moss → a use. A hatchling or fragment drop item (IR-34) → collected, and a use that spends a free use or 100 coins.
- (d) 7×7 shape in a 9×9 grid; armed; tap on a non-playable cell (a hole of the board shape, IR-64) → not a use and the button is disarmed (OQ-104 A): free uses and coins unchanged; board and moves unchanged; a following tap on a playable cell does nothing until the button is armed again.
- (d) Armed, free uses 0, coins 90, a playable cell tapped → refused; the button is still armed (OQ-103 A); tapping the button again then disarms it with nothing spent.
- (d) Armed; tap on a playable cell holding a Rocket → a use that spends a free use or 100 coins; the Rocket fires (IR-36); no move used. Armed; tap on a playable cell holding a special under moss → a use (OQ-108 A, IR-36).
- (e) The attempt has been won (win finale or the result screen shown) → button tapped: nothing is armed; free uses and coins unchanged. Same on the fail result screen and the retry screen.
- (e) A swap's matches and cascades are still resolving (events not finished playing) → a button tap or cell tap is ignored; nothing spent. After the move settles the button works again.
- (e) Moves 0, goals not done, the continue offer is shown → the button can't be armed; nothing spent (the player accepts or declines the offer; OQ-105 A). Armed, then a move starts resolving → the button is disarmed and further taps are ignored until the board settles.
- (f) Moves 10; only goal OB07 count 1; mummified creature hp 1 at (4,4); free uses 1, coins 500. Armed, tap (4,4) → creature freed; goal done event, then a win event once the board settles (IR-56); moves 10 (IR-62); 10 finale Rockets; coins 500 + 20 + 5 × 10 = 570; the one free use is spent, so free uses 0 and the coin balance shown right after the tap is 500, before the win coins.
- (f) Moves 1, free uses 0, coins 400. Armed, tap a plain piece at (3,3) → coins 300 shown at once; moves 1; no fail event and no continue offer; the player can still make their last move.
- (g) Level 11 started with 500 coins; the tracker's coins = 500. A continue accepted earlier in the attempt took the tracker to 200 (attempt coins not yet synced); Hoof Tap with no free uses: the price is taken from the tracker's 200 → 100 and SaveService's coins become 100 (12.2: `use_hero_booster` takes `tracker.coins` first), tracker coins 100. Not 400 (500 − 100).
- (g) Free uses 0, coins 100 → use → tracker coins 0 and the save's coins 0; the button shows the price 100 and a further use is refused.

---

## J. Level files (LevelLoader and validator, not MatchResolver)

How each field of `res://levels/level_NNN.json` becomes the starting board and attempt. The schema is `level_agent_brief.md` §5 (GDD › Technical design › Level format: "exactly the schema in `level_agent_brief.md` section 5"). Goals in the file: IR-31, IR-59, IR-61. Drop item exits (`exit_columns`): IR-30. "Validator:" tests are for `tools/validate_level/`; "LevelLoader:" tests for `src/game/level_loader.gd`.

### IR-63 · Level identity: id, chapter, tier and story beat (NEW)
Rule: A level file's `id` equals the NNN in its file name; `chapter` is 1 for levels 1–25 and 2 for 26–50; `tier` is one of intro, easy, medium, hard or finale, with levels 25 and 50 `finale` and levels 15, 20, 30, 35, 40 and 45 `hard`; `story_beat` is `"intro"` on level 1 (the opening comic, which plays once before the board), `"mini"` on hard levels and on level 17 (the first freed creature), `"chapter"` on finales and `null` on every other level; `"intro"` on any level but 1 is rejected, `"mini"` on any level but the hard levels and 17 is rejected, and level 1 or level 17 with `null` is rejected.
Applies to: Every level 1–50. The tier sets the goal count (IR-59); a finale fail costs no life (IR-60). Each beat plays once: IR-87. Level 17 is not a hard level but has a beat in IR-87's list, so it is the one non-hard level that takes `"mini"` (OQ-99 A). CHANGED 28 Nov 2026: `"intro"` added; level 17 `"mini"` added.
Source: `level_agent_brief.md` §5 › loading line `"res://levels/level_%03d.json" % id`, "`story_beat`: `null`, `"mini"` (on hard levels) or `"chapter"` (on finales)" (the brief gets `"intro"` by `spec/brief_additions.md`); Owner decision, chat 28 Nov 2026 › story_beat "intro" ("level 1 only, the opening comic, plays once before the board"); GDD › Story › Story beats (level 1 "Intro comic"); §4 Rhythm › "Every 5th level from 15 is `hard`; 25/50/75/100 are `finale`"; GDD › Level progression › "finales at 25, 50, 75 and 100, a hard level every 5th level from 15"; Chapters › "1 (1–25) … 2 (26–50)"; "each hard level carries a mini story beat"; "Each finale ends with a chapter story card".
Test cases:
- Validator: `level_026.json` with `"id": 26` → valid; with `"id": 27` → rejected.
- Validator: level 26 with `"chapter": 1` → rejected; `"chapter": 2` → valid.
- Validator: level 25 with `"tier": "hard"` → rejected; `"finale"` → valid. Level 30 with `"tier": "medium"` → rejected; `"hard"` → valid.
- Validator: level 30 (hard) with `"story_beat": null` → rejected; `"mini"` → valid. Level 50 (finale) with `"story_beat": "chapter"` → valid.
- Validator: level 1 with `"story_beat": "intro"` → valid; with `null` → rejected; with `"mini"` or `"chapter"` → rejected.
- Validator: level 2 with `"story_beat": "intro"` → rejected; `null` → valid. Level 30 (hard) with `"intro"` → rejected. Level 25 (finale) with `"intro"` → rejected.
- Validator: level 12 (no beat) with `"story_beat": "mini"` → rejected; `null` → valid.
- Validator: level 17 with `"story_beat": "mini"` → valid; with `null` → rejected; with `"intro"` or `"chapter"` → rejected. Level 16 and level 18 with `"mini"` → rejected.
- Validator: all hard levels (15, 20, 30, 35, 40, 45) with `"mini"` → valid; each with `null` → rejected.

### IR-64 · The `cells` grid sets the board shape (NEW)
Rule: The board is `width` × `height` cells, at most 9 × 9; `cells` has `height` rows of `width` characters each, row 0 is the top row and character x of row y is cell (x, y); `#` is a playable cell and `.` is no cell; levels 1–50 have no spawner cells, so the file has no spawner field or character and new pieces enter only at the top playable cell of each column (IR-51).
Applies to: Every level. Pieces fall straight through `.` cells (IR-51). IR-51's spawner case stays in MatchResolver for later levels but is never loaded from a level 1–50 file.
Source: GDD › Core gameplay › "a board up to 9×9"; `level_agent_brief.md` §5 › "`cells`: `#` = playable cell, `.` = no cell. Row 0 is the top row"; §6 › "Every row in `cells` and `underlay` has length `width`, and there are `height` rows"; Owner decision, chat 28 Nov 2026 › OQ-81 (Option A (c): "no spawners in levels 1–50, so no field is needed yet").
Test cases:
- LevelLoader: width 9, height 9, row 0 = `"..#######"`, every other row `"#########"` → (0,0) and (1,0) are not playable; (2,0) and all 79 other cells are playable.
- LevelLoader: width 7, height 8, every row `"#######"` → a 7 × 8 board; (6,7) is playable; (7,0) and (0,8) are off the board.
- Validator: width 9 with one `cells` row of 8 characters → rejected; 8 rows when `height` is 9 → rejected.
- Validator: width 10 → rejected (more than 9). A `cells` row containing `"S"` → rejected (only `#` and `.`).
- LevelLoader: any level 1–50, (6,8) emptied directly → the only new piece enters at (6,0) (no other entry point).

### IR-65 · The `underlay` grid places creep goo and dew seeds (NEW)
Rule: `underlay` has the same size as `cells`; `.` is no underlay, `1`, `2` or `3` is creep goo (OB10) with that many hp, and `s` is healing dew (OB04) already on that cell (a seed); no other character is allowed; an underlay (`1`–`3` or `s`) is only allowed on a playable (`#`) cell; a cell with an underlay still holds a piece (or a content obstacle) above it.
Applies to: OB10 creep goo and OB04 healing dew. Dew goal progress counts seeds from the start (IR-61). Hits on underlays: IR-15, IR-53.
Source: `level_agent_brief.md` §5 › "`underlay`: `.` = none; `1`–`3` = OB10 with that many hp; `s` = OB04 already covering that cell (a seed)"; §6 (row lengths); GDD › Board layers & obstacles › Cell layer model › "1 · Underlay | Creep goo, healing dew", "2 · Content | A piece, a blocker, a container or a drop item"; Owner decision, chat 28 Nov 2026 › OQ-81 (Option A (b): underlay on a `.` cell: "no, rejected").
Test cases:
- LevelLoader: `underlay` row 4 = `"..2..s..."` → goo hp 2 under (2,4); dew under (5,4); no underlay in the other 7 cells of row 4; (2,4) and (5,4) each hold a plain piece.
- LevelLoader: underlay `"1"` at (3,4) and an OB03 entry at (3,4) with `"hp": 1` → (3,4) has moss hp 1 over a plain piece on goo hp 1 (the stack used in IR-09 test 4).
- Validator: an `underlay` row containing `"4"` → rejected; one containing `"x"` → rejected.
- Validator: an `underlay` row of 8 characters on a width-9 board → rejected.
- Validator: `cells` row 0 = `"..#######"`; `underlay` row 0 = `"s........"` (dew on the `.` cell (0,0)) → rejected; `"1........"` → rejected; `"..s......"` → valid.

### IR-66 · `objects`: one entry per obstacle, placed in its layer (NEW)
Rule: Each `objects` entry is one obstacle of its `type`, at cell (`x`, `y`); OB05, OB06 and OB16 entries cover the `w` × `h` cells whose top-left cell is (`x`, `y`) and are one obstacle; `hp` sets its layers or hits (OB02 1–3 layers; OB03, OB05, OB07 and OB08 1–3; OB06 1–4; OB12 always 2 hits); no two objects share a cell, no object is on a `.` cell and every object lies inside the board; OB03 creep moss is an overlay, so its cell also holds a piece under it; OB02, OB05, OB06, OB07, OB08 and OB12 fill the cell's content layer, so their cells hold no piece; an OB05 entry also has `needs` (IR-73) and an OB08 entry also has `"color"`, one of the level's colours (IR-68, IR-74).
Applies to: Every object type in levels 1–50 except OB11 (comes from `spawn.drop_items`, IR-75). Multi-cell hits: IR-10, IR-11. Covered pieces: IR-54. Fragment cocoon flag: IR-31.
Source: `level_agent_brief.md` §5 › "`objects`: one entry per blocker. Multi-cell objects (OB05, OB06, OB16) use `w`/`h`, with `x`/`y` as the top-left cell", example `{"type": "OB06", "x": 1, "y": 0, "w": 1, "h": 4, "hp": 4}`; §6 › "No object overlaps another object or a `.` cell, and multi-cell objects fit inside the board"; GDD › Board layers & obstacles › Cell layer model (overlay = "Cover clusters, shutters"; content = "A piece, a blocker, a container or a drop item", lantern shrine named in the content row; underlay = "Creep goo, healing dew"; so every obstacle that is not a cover cluster, shutter, goo or dew is content), Obstacle set › OB02 "up to 3 layers", OB03 "cover cluster", OB07 "container release", OB12 "Needs 2 adjacent matches"; Interaction rules › "Two-hit obstacles (Frozen idol)"; Rules clarifications › OQ-29 (pieces under an overlay); Owner decision, chat 28 Nov 2026 › OQ-81 (Option A (d): "1–3 for all four"), OQ-87 (Option B: "OB06 allows 1–4 (OB03, OB05, OB07 stay 1–3); the example stands"), OQ-84 ((e) A: OB08 "`hp` 1–3; `"color"` one of the level's colours").
Test cases:
- LevelLoader: `{"type": "OB06", "x": 1, "y": 0, "w": 1, "h": 4, "hp": 4}` → one pillar covering (1,0), (1,1), (1,2), (1,3) with hp 4; none of those 4 cells holds a piece; it counts as 1 toward an OB06 goal (IR-61).
- LevelLoader: `{"type": "OB03", "x": 3, "y": 4, "hp": 1}` → creep moss hp 1 at (3,4) over a plain piece, which is locked (IR-54).
- LevelLoader: `{"type": "OB02", "x": 0, "y": 6, "hp": 2}` → withered bramble with 2 layers at (0,6); (0,6) holds no piece. `{"type": "OB07", "x": 4, "y": 4, "hp": 1}` → mummified creature hp 1 at (4,4); no piece there. `{"type": "OB12", "x": 5, "y": 5, "hp": 2}` → frozen idol with 2 hits left at (5,5); no piece there.
- Validator: two entries on (3,4) → rejected; an OB06 with `"y": 6, "h": 4` on a 9-high board → rejected (off the board); an object on a `.` cell → rejected; OB02 `"hp": 4` → rejected; OB12 `"hp": 3` → rejected.
- Validator: OB03 `"hp": 3` → valid; OB03 `"hp": 4` → rejected; OB07 `"hp": 0` → rejected; OB05 `"hp": 4` → rejected; OB06 `"hp": 3` → valid; OB06 `"hp": 4` → valid; OB06 `"hp": 5` → rejected; OB06 `"hp": 0` → rejected.
- LevelLoader: `{"type": "OB08", "x": 4, "y": 3, "hp": 2, "color": "red"}` → a red paper-screen lantern at (4,3) with screen hp 2, not lit; (4,3) holds no piece.
- Validator: OB08 `"hp": 1` and `"hp": 3` → valid; `"hp": 0` or `"hp": 4` → rejected; no `"color"` → rejected; `"color": "purple"` → rejected; `"color": "green"` on a 3-colour level with `"color_set": ["red", "yellow", "blue"]` → rejected; `"color": "yellow"` there → valid.

### IR-67 · Only obstacles that have debuted by this level (NEW)
Rule: A level uses only obstacles (in `objects`, `underlay`, `spawn` and `goals`) whose debut level is at or before its own id: OB02 at 1, OB04 at 4, OB03 at 7, OB05 at 10, OB06 at 13, OB07 at 17, OB08 at 22, OB10 at 28, OB11 at 34, OB12 at 41; no other obstacle (OB09, OB13 to OB17) is used in levels 1–50.
Applies to: The validator; levels 1–50. OB03 at 7 and OB07 at 17 follow the plan CSV by owner decision (OQ-75 B); the GDD's Debut column still says OB07 at 7 and OB03 at 17 until the owner edits it to match (round-8 list in open_questions.md). The "First freed creature tells of a dark beast" story beat moves from level 10 to level 17, the creature intro (Owner decision, chat 28 Nov 2026 › OQ-83 Option A; owner-only GDD edit, round-8 list); no rule here depends on it.
Source: GDD › Board layers & obstacles › Obstacle set (Debut column, for every obstacle except OB03 and OB07) and "10 debut in the MVP (levels 1–50) … following `levels_1_100_plan.csv`"; `levels_1_100_plan.csv` rows 7 ("OB03 x36, new obstacle OB03") and 17 ("OB07 x24, new obstacle OB07"); Owner decision, chat 28 Nov 2026 › OQ-75 (Option B: "The plan stands (moss at 7, creature at 17); the owner changes the GDD's Debut column for OB07 and OB03"); Interaction rules › "Hazards | None in the MVP. Nian's Eye moves to level 61 and Nian's Jar stays at 86"; `level_agent_brief.md` intro › "Their Zodiac Forest names, looks and debut levels are in the GDD's obstacle table, which wins over this file and the plan"; §3 › "Use only IDs that have already been introduced"; §4 › "OB09 (Nian's Eye) is not used in levels 1–50"; §6 › "Only introduced obstacle IDs are used".
Test cases:
- Validator: level 27 with a `"1"` (goo) in `underlay` → rejected; level 28 → valid.
- Validator: level 33 with `spawn.drop_items` of type OB11 → rejected; level 34 → valid.
- Validator: level 40 with an OB12 object → rejected; level 41 → valid.
- Validator: level 46 with an OB09 object or goal → rejected; level 3 with an `s` (dew) in `underlay` → rejected (dew debuts at 4).
- Validator: level 6 with an OB03 (moss) object → rejected; level 7 → valid. Level 16 with an OB07 object or goal → rejected; level 17 → valid.

### IR-68 · Moves and colours (NEW)
Rule: An attempt starts with the file's `moves` moves, which must be at least 16 and within 2 of the plan's moves for that level; `colors` is 4, or 3 only on an intro level; a 4-colour level uses red, yellow, blue and green; a 3-colour level names its 3 colours in `"color_set"` (3 different names from red, yellow, blue, green), and a 4-colour level has no `color_set`; every starting piece and every refill is one of the level's colours.
Applies to: LevelLoader, GoalTracker (starting moves), MatchResolver refills, the validator. Continues add moves during an attempt (IR-37). The level's colours also limit shrine `needs` (IR-73) and fixed tiles (IR-76).
Source: GDD › Core gameplay › "a move limit that never drops below 16", "**4 colours** on every level (3 only on a very cramped intro level)"; Level progression › Fair difficulty › "never by starving moves below 16"; `level_agent_brief.md` §4 › "Never starve moves below 16", "Use 4 tile colours by default. Only use 3 on an intro level, if the board is very cramped"; §6 › "Moves are within ±2 of the plan"; Owner decision, chat 28 Nov 2026 › OQ-81 (Option A (a): "the level file says which, e.g. `"color_set": ["red", "yellow", "blue"]`"), OQ-88 (Option A (a): a `color_set` on a 4-colour level is "rejected").
Test cases:
- LevelLoader: `"moves": 26` → the attempt starts with 26 moves.
- Validator: `"moves": 15` → rejected; 16 → valid (if within 2 of the plan). Level 26 (plan 24 moves) with `"moves": 26` → valid; 27 → rejected; 21 → rejected.
- Validator: an easy level with `"colors": 3` → rejected; an intro level with `"colors": 3` → valid; `"colors": 5` or `2` → rejected on any level.
- LevelLoader: `"colors": 4` → every starting plain piece is R, Y, B or G; after 50 refills (seeded) still only R, Y, B or G.
- LevelLoader: intro level, `"colors": 3`, `"color_set": ["red", "blue", "green"]` → every starting plain piece is R, B or G (no Y); after 50 refills (seeded) still no Y.
- Validator: intro level, `"colors": 3` with no `color_set` → rejected; `"color_set": ["red", "red", "blue"]` → rejected; `["red", "yellow"]` → rejected; `["red", "yellow", "purple"]` → rejected; `["red", "yellow", "blue"]` → valid.
- Validator: `"colors": 4` with `"color_set": ["red", "yellow", "blue", "green"]` → rejected; `"colors": 4` with no `color_set` → valid.

### IR-69 · The starting board: every free cell gets a piece, no match, at least 3 matching swaps (NEW)
Rule: When an attempt starts, every playable cell whose content layer has no obstacle gets a piece (cells under creep moss and cells on an underlay included): a `fixed_tiles` entry's tile in its cell (IR-76), otherwise a random plain piece of the level's colours drawn from the attempt's seed (IR-72); the finished starting board, as the player first sees it (with its starting drop items, IR-75), has no match anywhere and at least 3 different swaps that would make a match.
Applies to: LevelLoader (first load and every retry, IR-71); the validator checks that `fixed_tiles` don't form a match themselves. Pre-level booster and streak-chest specials replace pieces of this finished board without making a match (IR-77). Each attempt's random pieces are new (IR-72). "One area where a special is easy to make" is a design check for level-designer and balance-analyst, not a LevelLoader rule.
Source: GDD › Core gameplay › Rules › "Every level starts with at least 3 valid moves, no pre-made matches, and one area where a special is easy to make"; `level_agent_brief.md` §4 Openings › "Leave at least 3 valid matches available at the start, and no pre-made matches"; §5 › "`fixed_tiles`: optional pre-placed colours or power-ups, e.g. `{"x":4,"y":8,"tile":"line_h"}`"; GDD › Cell layer model (content layer holds "a piece, a blocker, a container or a drop item"); Rules clarifications › OQ-29 (pieces under an overlay).
Test cases:
- LevelLoader: 9×9 all playable; bramble at (0,6); pillar 1×4 at (1,0)–(1,3); moss hp 1 at (3,4); goo hp 1 under (6,6); dew seed under (7,7); no `fixed_tiles` → (0,6) and (1,0)–(1,3) hold no piece; (3,4) holds a plain piece under the moss; (6,6) and (7,7) each hold a plain piece; the other 73 cells each hold a plain piece; no 3 same-coloured pieces in a row or column; at least 3 swaps make a match.
- LevelLoader: the same level loaded with 200 different seeds → every starting board has no match and at least 3 swaps that make a match.
- LevelLoader: `"fixed_tiles": [{"x": 4, "y": 8, "tile": "line_h"}]` → (4,8) holds a row Rocket (IR-05) of one of the level's colours (IR-76); the rest of the board follows this rule.
- LevelLoader: a drop-item level (`max_on_board` 2) loaded with 200 different seeds → every starting board, with its 2 hatchlings in top playable cells (row 0 on a fully playable board, IR-75), has no match and at least 3 swaps that make a match.
- Validator: `fixed_tiles` that place three same-coloured plain pieces in a line → rejected (pre-made match).

### IR-70 · Fragment levels: the `fragment` field and where the fragment sits (NEW)
Rule: Levels 26, 30, 33, 35, 38, 40, 45 and 50, and no others in 1–50, carry `"fragment": {"guardian": "rat", "scripted": true}` and a fragment goal (IR-31); on levels 26–35 the fragment is in a cocoon (the OB07 entry with `"fragment": true`), and from level 38 it is in a cocoon or rides a drop item (`"fragment_item": n`).
Applies to: LevelLoader, the validator. Goal flag and marking: IR-31. Intro levels never carry one. SaveService counts a won fragment by the level number, not by reading `fragment.guardian` (IR-85, owner, 28 Nov 2026); the result is the same while the Rat is the only guardian with fragments.
Source: GDD › Technical design › Level format › "plus one Mythic field: `"fragment": {"guardian": "rat", "scripted": true}` on fragment levels"; Soul fragments › Schedule › "26–50 | 26, 30, 33, 35, 38, 40, 45, 50 (scripted) | Rat 8/8"; Soul fragments › Rules › "Levels 26–33: the fragment is sealed in a creep cocoon (OB07 behaviour) … From level 38 it can also be an OB11 drop item", "Intro levels never do … the validation checklist rejects a fragment placed on one"; CLAUDE.md › Owner decisions › "Drop items debut at 34; fragments ride drop items only from 38".
Test cases:
- LevelLoader: level 26 with `"fragment": {"guardian": "rat", "scripted": true}` → loaded as a Rat fragment level; winning it adds 1 to `fragments.rat` (IR-58).
- Validator: level 27 with a `fragment` field → rejected; level 30 without one → rejected; level 26 with the field but no goal with `"fragment": true` → rejected; level 26 with a fragment goal but no field → rejected.
- Validator: level 35 with the fragment on a drop item (`"fragment_item": 1`) → rejected; level 38 with `"fragment_item": 2` → valid; level 38 with an OB07 entry marked `"fragment": true` → valid.

### IR-71 · A retry builds a new attempt from the level file (NEW)
Rule: A retry starts a new attempt built again from the level file: the file's moves, every goal back to its starting progress (0, or the seed cells for a dew goal), every obstacle back as placed with its file `hp`, the fragment back where the file puts it, the drop-item spawn count back to 1, and the next continue offer is again the 1st (300 coins).
Applies to: LevelLoader, GoalTracker. Lives: IR-60. Lives and coins are the player's, not the attempt's: a retry starts with the values the save holds after the last attempt (IR-78), never resets them. Won levels can't be replayed (IR-79), so no retry follows a win. The retry gets a new seed, so its random starting pieces, refills and other seeded draws differ from the last attempt's (IR-72); everything the file fixes (obstacles, `hp`, fixed tiles' cells and names, fragment) comes back the same; a fixed special with no `"color"` may get a different colour (IR-76).
Source: GDD › Core gameplay › Rules › Fail flow "… declining goes to the retry screen"; Interaction rules › "Continue offer | … Up to 5 offers per attempt"; Soul fragments › Rules › "Fail the level and the fragment stays for the retry", "Won levels cannot be replayed in the MVP"; Owner decision, chat 28 Nov 2026 › OQ-66 (seed cells count from the start), OQ-71 (fragment marking).
Test cases:
- Level with `"moves": 26` and one goal OB02 count 17 (17 brambles in the file). The attempt fails at 9/17, moves 0; the player declines → retry → moves 26; goal 0/17; all 17 brambles back in their file cells with their file layers.
- Dew level with 3 seed cells and goal OB04 count 58; the attempt fails at 40/58 → retry → goal 3/58; only the 3 seed cells have dew.
- 3000 coins. Attempt 1: offers 1 and 2 accepted, offer 3 declined → retry; moves run out in the new attempt → the offer is the 1st, price 300.
- Level 26: see IR-58 test 1 (fragment back in the marked cocoon). Level 38: see IR-58 test 2 (the 2nd item spawned carries it again).
- Attempt 1 fails; retry with no seed passed in → attempt 2's seed is not attempt 1's seed; obstacles with their `hp`, and any fixed tiles (by name), are in the same cells as in attempt 1 (IR-72).

### IR-72 · Each attempt gets a new seed (NEW)
Rule: Every attempt (the first play of a level and each retry) gets a new random seed, and every seeded draw in that attempt (starting pieces, refills, drop-item columns, colours of fixed specials without `"color"`, pre-level and streak-chest specials, finale Rockets, colour and Crane ties) comes from it; "the level's seeded random number generator" in other rules means the current attempt's generator; tests and the level bot can pass a seed in, and the same level with the same seed and the same moves repeats the run exactly.
Applies to: LevelLoader, MatchResolver (refills), the level bot, every rule that uses a seeded draw (IR-16, IR-47, IR-49, IR-69, IR-75, IR-76, IR-77). Retry: IR-71.
Source: GDD › Core gameplay › Rules › "Every level starts with at least 3 valid moves, no pre-made matches"; Rules clarifications › OQ-17 ("a seeded random piece"), OQ-40, OQ-53, OQ-58 (seeded finale Rockets); Owner decision, chat 28 Nov 2026 › OQ-76 (Option A: "Each attempt gets a new seed: a retry shows a new random starting board (and new refills). Tests and the bot pass a seed in to repeat a run exactly").
Test cases:
- LevelLoader: level 12 loaded twice with seed 1234 → the two starting boards are the same cell for cell; the same 5 swaps played on both → after each swap the two boards are the same (same refills).
- Level won with 3 moves left, played twice with seed 1234 and the same swaps → the same 3 finale Rocket directions and cells both times (IR-16).
- Attempt 1 with no seed passed in fails; retry → attempt 2 has a different seed from attempt 1 (see IR-71's last test).

### IR-73 · How a lantern shrine's needed colours are written (NEW)
Rule: An OB05 entry lists the colours its lantern shrine needs as a count per colour, e.g. `"needs": {"red": 2, "blue": 1}`; `needs` must be present and name at least one colour, every count must be at least 1, and every colour named must be one of the level's colours (IR-68); the shrine starts the attempt needing exactly those counts.
Applies to: LevelLoader, the validator; OB05 (levels 10, 11, 12, 16, 20, 24, 25, 27, 32, 33, 35, 38, 49). How the needs are filled and when the shrine is lit: IR-55.
Source: GDD › Board layers & obstacles › Obstacle set › OB05 "Collect the colours it shows to light it"; `level_agent_brief.md` §5 (OB05 entry fields); Owner decision, chat 28 Nov 2026 › OQ-77 (Option A: "A count per colour on the object, e.g. `{"type": "OB05", "x": 3, "y": 3, "w": 2, "h": 2, "hp": 3, "needs": {"red": 2, "blue": 1}}`"; "the colours must be among the level's `colors`"), OQ-88 (Option A (c): an OB05 entry with no `needs`, an empty `needs` or a colour with count 0 is "rejected (every shrine needs at least 1 piece of each colour it names)").
Test cases:
- LevelLoader: `{"type": "OB05", "x": 3, "y": 3, "w": 2, "h": 2, "hp": 3, "needs": {"red": 2, "blue": 1}}` → one shrine covering (3,3)–(4,4), hp 3, needing 2 R and 1 B and nothing else; none of its 4 cells holds a piece.
- Validator: that entry on a 4-colour level → valid; `"needs": {"purple": 1}` → rejected.
- Validator: intro level with `"colors": 3`, `"color_set": ["red", "yellow", "blue"]` and an OB05 with `"needs": {"green": 1}` → rejected; `"needs": {"yellow": 2}` → valid.
- Validator: an OB05 entry with no `needs` → rejected; `"needs": {}` → rejected; `"needs": {"red": 2, "blue": 0}` → rejected; `"needs": {"red": 2, "blue": 1}` → valid.

### IR-75 · When and where drop items appear (NEW)
Rule: At the start of an attempt the first `max_on_board` drop items (never more than `total`) are placed each in the top playable cell of a different column picked by the attempt's seed, only among columns whose top playable cell holds an uncovered plain piece (no obstacle, no moss, no fixed tile), in place of that piece, and they are numbered left to right; after that, every item collected in a move is replaced in the next refill, each at the top of a different column picked by the seed among the columns that get a new piece in that refill, in place of that new piece, until `total` items have appeared in that attempt; no item ever enters otherwise; items after the starting ones are numbered in the order they enter (for `fragment_item`, IR-31); the validator rejects a level in which fewer columns can take a starting item (top playable cell holds an uncovered plain piece with no fixed tile) than `max_on_board`.
Applies to: LevelLoader, MatchResolver refills and the validator; OB11 lost hatchlings (levels 34–36, 38, 39, 45, 48, 50) and fragment drop items (from 38). **Trial decision (OQ-79): revisit after playtest** ("if it is too easy during test, we move to A"). Collection: IR-30. The starting board with its items must still pass IR-69. Too few eligible starting columns is a validator rejection (owner, 28 Nov 2026); LevelLoader may assume a valid level and does not run this check itself (the spec sets no loader behaviour for such a level). Not yet specified: a refill in which more items must enter than columns get a new piece, and the numbering order of two items entering in the same refill; level-designer should avoid these cases (none blocks LevelLoader on a level that avoids them).
Source: GDD › Board layers & obstacles › Obstacle set › OB11 "Bring it to the bottom row to collect it"; `level_agent_brief.md` §5 › "`spawn.drop_items`: e.g. `{"type":"OB11","total":3,"max_on_board":1,"exit_columns":[2,6]}`"; GDD › Rules clarifications › OQ-35 "Every column refills at its top playable cell"; Owner decision, chat 28 Nov 2026 › OQ-79 (Option B, trial: "The first `max_on_board` items are placed in the top row at the start (seeded columns); after that, each collected item is replaced at the next refill at the top of a random column (seeded), until `total` have appeared"), OQ-85 ((a) A: "In each column's top playable cell; only columns whose top playable cell holds an uncovered plain piece (no obstacle, no moss, no fixed tile) can be picked"; (b) A: "Picked (seeded) among the columns that get a new piece in that refill, so it always enters in that refill"; (c) A: "All are replaced in the same refill, each in a different column"; (d) A: starting items numbered "Left to right"); Owner decision, chat 28 Nov 2026 (validator rejects a level with fewer eligible starting columns than `max_on_board`; replaces godot-engineer's provisional "place as many as fit").
Test cases (9×9, all cells playable, nothing but plain pieces in row 0, unless a test says otherwise):
- LevelLoader: `{"type":"OB11","total":3,"max_on_board":1}` → at the start exactly 1 hatchling on the board, in row 0; loaded again with the same seed → the same column.
- LevelLoader: `{"type":"OB11","total":3,"max_on_board":2}` → at the start 2 hatchlings, both in row 0, in two different columns. `{"type":"OB11","total":1,"max_on_board":2}` → 1 hatchling at the start.
- `total` 3, `max_on_board` 1; only goal OB11 count 3. Many moves are played with item 1 not yet collected → no other item appears. Item 1 is collected → the refill that follows brings in item 2 at the top of a column; item 2 collected → item 3 enters; item 3 collected → goal 3/3 and no further item ever enters.
- LevelLoader: `cells` row 0 = `"..#######"` (rows 1–8 all `#`); a bramble at (2,0); moss at (3,0); `fixed_tiles` `{"x": 4, "y": 0, "tile": "red"}`; `{"type":"OB11","total":2,"max_on_board":2}`; loaded with 200 different seeds → the 2 hatchlings are always in two different columns; a hatchling in column 0 or 1 is at (0,1) or (1,1) (their top playable cells); none is ever in column 2, 3 or 4 (top playable cell holds an obstacle, moss or a fixed tile).
- LevelLoader: `{"type":"OB11","total":3,"max_on_board":2,"fragment_item":2}`; with the seed stubbed so the starting columns are drawn as 6 then 1 → hatchlings at (1,0) and (6,0); the one at (6,0) carries the fragment (left to right: (1,0) is item 1, (6,0) is item 2).
- `total` 3, `max_on_board` 1; a move clears pieces in columns 4 and 5 only, item 1 falls to (4,8) and is collected, and the refill brings new pieces into columns 4 and 5 only → in that refill item 2 enters at (4,0) or (5,0), never in another column.
- `total` 4, `max_on_board` 2; in one move both items fall to (2,8) and (6,8) and are collected, and the refill brings new pieces into columns 2, 3 and 6 → in that same refill 2 new items enter, in two different columns among 2, 3 and 6; 4 items have now appeared, so no further item ever enters.
- Validator: `{"type":"OB11","total":3,"max_on_board":2}`; row 0 has a bramble or moss on every cell except (4,0), which holds a plain piece → only column 4 is eligible → rejected.
- Validator: same level, but (6,0) also holds a plain piece (no obstacle, no moss, no fixed tile) → 2 eligible columns → valid.
- Validator: `{"type":"OB11","total":3,"max_on_board":2}`; row 0 has a bramble on every cell except (4,0) and (6,0); `fixed_tiles` `{"x": 6, "y": 0, "tile": "red"}` → only column 4 is eligible → rejected.

### IR-76 · `fixed_tiles`: tile names and colours (NEW)
Rule: A `fixed_tiles` entry's `tile` is one of `red`, `yellow`, `blue`, `green` (a plain piece of that colour), `line_h` (row Rocket), `line_v` (column Rocket), `firecracker`, `crane` or `orb` (Jade Orb, no colour, IR-50, so an `orb` entry may not have a `"color"`); a Rocket, Firecracker or Crane takes the colour in its optional `"color"` field or, without one, a colour drawn from the attempt's seed; every colour is one of the level's colours (IR-68); a fixed tile may only be on a playable cell that would hold a piece (no content obstacle there), and under creep moss is allowed, where it is locked (IR-54).
Applies to: LevelLoader, the validator. **Trial decision (OQ-80): revisit after playtest** ("move to B during test if too easy"). The plan lists no fixed tiles in levels 1–50. A column whose top playable cell holds a fixed tile never gets a starting drop item (IR-75).
Source: `level_agent_brief.md` §5 › "`fixed_tiles`: optional pre-placed colours or power-ups, e.g. `{"x":4,"y":8,"tile":"line_h"}`"; GDD › Rules clarifications › OQ-18 ("Rockets, Firecrackers and Cranes keep the colour they were made from"), OQ-29 (pieces under an overlay); Owner decision, chat 28 Nov 2026 › OQ-80 (Option A, trial: "Names `red`, `yellow`, `blue`, `green`, `line_h`, `line_v`, `firecracker`, `crane`, `orb`; a coloured special takes an extra `"color"` field, and gets a random colour (seeded) if it has none; only on cells that would hold a piece (under moss allowed)"), OQ-88 (Option A (b): a `"color"` on an `orb` tile is "rejected").
Test cases:
- LevelLoader: `{"x": 4, "y": 8, "tile": "line_v", "color": "blue"}` → a blue column Rocket at (4,8). `{"x": 2, "y": 2, "tile": "orb"}` → a Jade Orb at (2,2). `{"x": 0, "y": 0, "tile": "yellow"}` → a plain Y at (0,0).
- LevelLoader: `{"x": 4, "y": 8, "tile": "crane"}` on a 4-colour level, loaded twice with seed 1234 → a Crane at (4,8) with the same colour both times, one of R, Y, B, G.
- LevelLoader: `{"x": 3, "y": 4, "tile": "firecracker", "color": "red"}` and an OB03 moss hp 1 at (3,4) → a red Firecracker under the moss; swapping it is refused and tapping it does nothing (IR-54).
- Validator: tile `"rocket"` → rejected; a fixed tile on an OB02 bramble's cell → rejected; on a `.` cell → rejected; `"tile": "line_h", "color": "purple"` → rejected; `"tile": "green"` on a 3-colour level with `"color_set": ["red", "yellow", "blue"]` → rejected.
- Validator: `{"x": 2, "y": 2, "tile": "orb", "color": "red"}` → rejected; `{"x": 2, "y": 2, "tile": "orb"}` → valid.

### IR-77 · Pre-level booster and streak-chest specials on the starting board (NEW)
Rule: Each special from a pre-level booster or the win-streak chest replaces a plain piece of the finished starting board picked by the attempt's seed, never one under creep moss, and takes that piece's colour, so the board still has no match; a Rocket placed this way is a row Rocket if its row holds more targets than its column, a column Rocket if its column holds more, and a 50/50 pick by the attempt's seed on a tie (0 and 0 included); a line's targets are the obstacles of the level's goals with at least one cell in that line, each counted once however many of its cells are in the line, plus, for a dew goal, the playable cells in the line without dew, plus 1 for each drop item in the line; loading with an unknown pre-special name fails with an error naming it (never silently ignored).
Applies to: Pre-level boosters (from level 16: "a Rocket + Crane, or a Firecracker") and the win-streak chest (a Rocket and a Crane). When both are on one board, the booster's specials are placed first, then the chest's (IR-83). Both are on CLAUDE.md's cut list if a milestone slips; the level bot uses neither. Obstacles that are not part of any goal never count. The fragment's cocoon is an OB07 goal obstacle (IR-31), so it counts. `pre_specials` is a load option passed in by the meta layer, not a level-file field, so the validator never sees it. How the error is surfaced in code is an API choice for test-engineer.
Source: GDD › Meta & economy › Booster unlocks › "16 | Pre-level boosters | Pre-level | Start with a Rocket + Crane, or a Firecracker"; Currencies › "Win streak | 6 wins in a row: a chest drops a free Rocket and Crane onto the next board"; Owner decision, chat 28 Nov 2026 › OQ-82 (Option A, changed by the owner: "Each replaces a random plain piece of the finished starting board (seeded), not under moss, taking that piece's colour; … the board still has no match"; "Rocket's direction would be towards direction with highest number of targets"), OQ-86 ((a) A: "Seeded 50/50" on a tie, now an owner decision; (b) A: "Each goal obstacle with at least one cell in the line counts once (a 2×2 pillar crossing the row = 1); dew goal: playable cells in the line without dew; drop items on the board: 1 each"); Owner decision, chat 28 Nov 2026 (an unknown `pre_specials` name is an error, not silently ignored; replaces godot-engineer's provisional "ignore").
Test cases:
- LevelLoader: load a valid level with `pre_specials` holding a known special plus the name `"banana"` → loading fails with an error that names `"banana"`; no board is returned as if `"banana"` were absent.
- Pre-level Rocket + Crane; level loaded twice with seed 1234 → both specials in the same cells, with the same colours, both times; each is in a cell that held a plain piece not under moss and has that piece's colour; the board has no match.
- Pre-level Firecracker on a level with moss on 20 cells, loaded with 200 different seeds → the Firecracker is never under moss and never replaces a fixed tile, drop item or obstacle; the board never has a match.
- Only goal: OB02 count 4, brambles at (0,5), (1,5), (8,5) and (2,0). The Rocket replaces the piece at (2,5) → row 5 holds 3 goal brambles, column 2 holds 1 → a row Rocket.
- Same level. The Rocket replaces the piece at (8,2) → row 2 holds 0 goal brambles, column 8 holds 1 ((8,5)) → a column Rocket.
- Only goal: OB02 count 2, brambles at (0,5) and (2,0). The Rocket replaces the piece at (2,5) → row 5 holds 1, column 2 holds 1 (a tie) → loaded twice with seed 1234, the same direction both times; with the 50/50 draw stubbed to "column" → a column Rocket, stubbed to "row" → a row Rocket. Same level, Rocket at (6,7) → 0 and 0 (a tie) → decided by the same seeded draw.
- Goals: OB06 count 1, a 2×2 pillar at (4,4)–(5,5); OB02 count 2, brambles at (0,1) and (0,7). The Rocket replaces the piece at (0,4) → row 4 holds 1 (the pillar, counted once though 2 of its cells are in row 4), column 0 holds 2 → a column Rocket.
- Only goal: OB02 count 1, a bramble at (8,5); moss (no moss goal) at (2,1), (2,2) and (2,3). The Rocket replaces the piece at (2,5) → row 5 holds 1, column 2 holds 0 (moss is not a goal) → a row Rocket.
- Only goal: OB04 dew; (6,3) has dew; row 3 has 4 playable cells without dew, column 6 has 2 → the Rocket at (6,3) is a row Rocket.
- Only goal: OB11 count 3, `max_on_board` 2, starting hatchlings at (1,0) and (7,0). The Rocket replaces the piece at (5,0) → row 0 holds 2, column 5 holds 0 → a row Rocket.

### IR-89 · `tutorial`: the swap hint on a tutorial level (NEW)
Rule: A level file may carry an optional `tutorial` field, `null` or absent meaning no hint, otherwise `{"teach": "<name>", "hint_cells": [[x,y],[x,y]]}` where `teach` is one of `"rocket"` (4 in a row), `"firecracker"` (L or T match), `"crane"` (2×2 match) or `"orb"` (5 in a row), and `hint_cells` is exactly two different, orthogonally adjacent playable cells inside the board, each holding a piece at the start (not a content obstacle); the loader carries the field to the attempt unchanged, the UI uses it to point at the two cells (the swap the player is shown), and the hint changes no game rule (no extra move, no booster, no change to the board).
Applies to: LevelLoader, the validator and the UI hint. Added to levels 2, 3, 5 and 6 and any later tutorial level, placed by the level designer; no rule limits which levels may have it. The special each name teaches follows the shape rules (IR-04 Crane, IR-05 Rocket, IR-06 Firecracker, IR-07 Orb). The validator does not check that swapping the two cells really makes the taught special; the level designer pins the tiles with `fixed_tiles` so it does, and a wrong hint is found by a playtest (owner decision, chat 28 Nov 2026 › OQ-98 Option A). A retry (IR-71) carries the same field again. Whether the hint is shown again on a retry is not decided here.
Source: Owner decision, chat 28 Nov 2026 › OQ-98 (Option A: no swap check in the validator); Owner decision, chat 28 Nov 2026 › `tutorial` field ("`{"teach": "rocket", "hint_cells": [[3,4],[4,4]]}` … `teach` is one of rocket (4 in a row), firecracker (L/T match), crane (2x2 match), orb (5 in a row); two different, orthogonally adjacent playable cells, each holding a piece at the start; no extra move, no booster"); GDD › Core gameplay › "four special pieces (taught on levels 2, 3, 5 and 6)"; Interaction rules › "Adjacent / next to … never diagonal" (Rules clarifications › OQ-08); IR-66 (which cells hold no piece).
Test cases:
- Validator: level 2 with `"tutorial": {"teach": "rocket", "hint_cells": [[3,4],[4,4]]}`, both cells playable, plain pieces, inside the board → valid. `"tutorial": null`, and the field absent → valid.
- LevelLoader: the same level → the attempt's `tutorial` equals `{"teach": "rocket", "hint_cells": [[3,4],[4,4]]}` exactly; the starting board, moves and goals are the same as without the field.
- Validator: `"teach": "banana"`, `"teach": "Rocket"` or a missing `teach` → rejected. `"teach": "firecracker"`, `"crane"` and `"orb"` → valid.
- Validator: `hint_cells` with 1 cell, 3 cells, 0 cells or a missing `hint_cells` → rejected. Two entries that are the same cell, `[[3,4],[3,4]]` → rejected.
- Validator: `[[3,4],[5,4]]` (two apart) or `[[3,4],[4,5]]` (diagonal) → rejected; `[[3,4],[3,5]]` (vertical neighbours) → valid.
- Validator: a hint cell on a `.` cell → rejected; on a cell with a content obstacle (an OB02 bramble, an OB06 pillar cell, an OB12 idol) → rejected; on a cell with a plain piece at the start → valid.
- Validator: a hint cell `[9,4]` or `[-1,4]` or `[4,9]` on a 9×9 board → rejected.
- Validator: `"tutorial": "rocket"`, `"tutorial": []`, `"tutorial": 3`, `"hint_cells": "3,4"`, `"hint_cells": [3,4]` (not a list of pairs) or a cell given as `[3]` or `["a","b"]` → rejected.
- Validator: a valid-shape `tutorial` (`teach` "rocket") whose two hint cells, when swapped, make no 4-in-a-row → still valid (the validator does not check the swap).
- Level 2, 28 moves, with a valid `tutorial` field. The attempt starts → moves 28, no booster in the bag, the board identical to the same file without the field (the hint adds and takes no move). The player makes a different legal swap → resolved by the normal rules (moves 27), the hint changes nothing.

---

## K. Save, progress and meta (SaveService, not MatchResolver)

What the player keeps between attempts and sessions. Field names, the `schema_version` number, the file format and the migration hook are implementation choices for godot-engineer and test-engineer (the GDD gives an example, quoted in IR-78). Out of scope (CLAUDE.md): shared cross-game profiles, monetisation (no coin purchases), Soul Dust, levels 51+, Monkey's Staff, Rat's Nibble, random fragments, the pity rule. Prices are the GDD's starting values ("tune in playtests"), so tests should read them from one place. Owner decisions OQ-89 to OQ-96 (chat 28 Nov 2026) are applied below; the few edge cases they leave are marked "Not yet specified" in their rule, and tests avoid them. Time in this section is real (wall-clock) time on the device, whether the game is open or closed.

### IR-78 · The save keeps the player's progress between sessions and attempts (NEW)
Rule: The save holds the player's level progress (IR-79), coins (IR-80), lives with the life refill clock and the end time of any unlimited lives (IR-81), which boosters are unlocked and their free uses left (IR-82, IR-83), the win streak and whether a streak chest is waiting for the next board (IR-84), soul fragments and restored guardians (IR-85), which story beats have been seen (IR-87), and whether an attempt is in progress (IR-38), with a schema version; every value is the same after the game is closed and opened again, and lives and coins belong to the player, not the attempt: a continue or a retry never resets them, and every change is written back to the save; a save that can't be read, with no temporary copy of it, starts the player as a new player.
Applies to: SaveService; GoalTracker and LevelLoader read lives and coins from it for each attempt (IR-37, IR-60, IR-71). A new player: next level 1 (IR-79), 500 coins (IR-80), 5 lives (IR-81), nothing else saved yet. The temporary copy is the file written while saving (an interrupted write can leave only it); when and how it is used if the main save can't be read is an implementation choice. The GDD example has `"ox": 0`; Ox fragments are post-MVP and never change in levels 1–50. Upgrade milestones at levels 20 and 50: nothing is saved for them yet; winning 20 or 50 changes the save only as any other win does (plus IR-85 at 50); the owner adds rewards when the upgrade flow is designed (OQ-95). Field names for the new values are an API choice.
Source: GDD › Technical design › "`SaveService` | A local save with a schema version and a migration hook. Sharing one profile across Zodiac games is post-MVP and needs an account server"; Save file (local, versioned) › `{"schema_version": 1, "level": 28, "coins": 840, "lives": 5, "fragments": {"rat": 1, "ox": 0}, "restored": [], "boosters": {"hoof_tap": 3, "tail_slam": 2, "bamboo_dash": 0, "feather_fan": 0}}`; Meta & economy › "the save data already tracks levels, fragments and restored guardians"; Level progression › "Your 20/50-level upgrade milestones can sit on top of this"; Owner decision, chat 28 Nov 2026 › OQ-89 (Option A), OQ-91 (Option A), OQ-92 (Option A), OQ-93 (Option A), OQ-94 (Option A), OQ-95 (Option A: "Not built in the MVP code yet: winning 20 and 50 shows the milestone (story card / badge) and gives nothing saved; the owner adds rewards when the upgrade flow is designed"), OQ-96 (Option A: "the save remembers which were seen"); Owner decision, chat 28 Nov 2026 ("Agree": an unreadable save with no temporary copy starts the player as a new player).
Test cases:
- Save holding next level 28, coins 840, lives 5, `fragments.rat` 1, restored none, Hoof Tap 3, Tail Slam 2, Bamboo Dash 0, Feather Fan 0 → written, then loaded by a new SaveService → every value the same, and the file carries a `schema_version`.
- Level 12, lives 4, coins 700. Attempt 1: offer 1 accepted (coins 400), offer 2 declined → retry; attempt 2 starts with coins 400 and lives 3 (IR-37, IR-60), not 700 and 4.
- Level 26 won with 2 finale Rockets, coins 500, `fragments.rat` 0 → after a close and reopen: coins 530, `fragments.rat` 1, next level 27.
- Streak 5; level 21 won (chest waiting, streak 0, IR-84); story beats for levels 1, 15, 17 and 20 seen; the game is closed before level 22 starts → reopened: the chest is still waiting, streak 0, the same 4 beats marked seen.
- Coins 500, streak 2; level 20 won with 0 finale Rockets → coins 520, streak 3, next level 21; no milestone reward is saved (no extra coins, no booster uses, no new field; OQ-95).
- Save file holding next level 28, coins 840 is overwritten with text that is not valid JSON; no temporary copy exists → a new SaveService loads a new player: next level 1, coins 500, lives 5, `fragments.rat` 0, restored none, streak 0.

### IR-79 · Levels are played in order, and a won level can't be played again (NEW)
Rule: Levels 1 to 50 are played in order with no skipping: the only level that can be started is the lowest level not yet won; winning level N makes N + 1 the next level; a fail or a quit leaves the next level unchanged; a won level can never be started again; once level 50 is won no level can be started (the end of the MVP).
Applies to: SaveService, the map. Whether the player has the lives to start or retry the next level: IR-81 (0 lives). Which number the save's `level` field stores (the next level, or the last one won) is an API choice; the GDD example's `"level": 28` fits either. The furthest level for the attempt log (IR-86) comes from this.
Source: GDD › Soul fragments › Rules › "Won levels cannot be replayed in the MVP"; Soul fragments › "The Rat's 8 fragments are scripted so it is restored at exactly level 50"; Overview › "Levels 1–50 are the whole MVP scope, ending on the Rat's restoration"; Story beats › 50 "End of the MVP"; Technical design › Save file (a single `"level"` number); Retention test › "50 levels with no replay"; CLAUDE.md › Owner decisions › "Won levels can't be replayed"; Owner decision, chat 28 Nov 2026 (the rules-keeper's reading "levels are played in order, no skipping" confirmed by the owner).
Test cases:
- New save → the next level is 1; levels 2–50 can't be started.
- Next level 12; level 12 won → next level 13; starting level 12 is refused; starting level 14 is refused.
- Next level 12; level 12 failed (offer declined) → next level 12. Quit instead → next level 12.
- Next level 50; level 50 won → no level can be started; starting level 50 or 51 is refused.

### IR-80 · Coins: start at 500, earned only by winning, spent only on continues, life refills and boosters (NEW)
Rule: A new save starts with 500 coins; a win adds 20 + 5 per finale Rocket (IR-16) and nothing else adds coins; coins are spent only on continues (300, then 500, IR-37), buying all 5 lives back (150, IR-81) and boosters once their free uses are gone, paid at the moment of use (IR-82, IR-83); no purchase of any kind is made with fewer coins than its price (it is refused and coins are unchanged), so coins never go below 0; buying all 5 lives at 5 lives is refused too, with no coins charged (IR-81).
Applies to: SaveService, GoalTracker (continues), BoosterService. There is no way to buy coins (monetisation is out of scope). Coins from a win are added once, after the finale (IR-56: extra clears pay nothing).
Source: GDD › Meta & economy › Currencies › Coins "Start 500. Win = 20 + 5 per finale rocket (about 40 a win). Spent on the continue, life refills and hero boosters"; Lives "buy all 5 back for 150 coins"; Continue; Booster unlocks (prices); Overview › "Monetization | None in MVP"; Owner decision, chat 27 Nov 2026 › OQ-39, OQ-52 (an offer can't be accepted with fewer coins than its price, IR-37); CLAUDE.md › Owner decisions › "Coins pay for the continue (300), life refills (150) and hero boosters (100–200)"; Owner decision, chat 28 Nov 2026 (the rules-keeper's reading "no purchase of any kind (continue, life refill, boosters) without enough coins; coins never go below 0" confirmed by the owner), OQ-93 (Option A (b): "Paid at the moment of use"); Owner decision, chat 28 Nov 2026 ("Refuse it, show error message: you already have 5 lives").
Test cases:
- New save → coins 500.
- Coins 500, lives 5. Buy all 5 lives → refused; coins 500; lives 5.
- Coins 500; a level won with 4 finale Rockets → coins 540. Won on its last move → coins 520.
- Coins 500; an attempt fails (offer 1 declined, no continue bought) → coins 500.
- Coins 120, lives 0. Buy all 5 lives → refused; coins 120; lives 0. With coins 150 → coins 0; lives 5.
- Coins 90; Hoof Tap unlocked with no free uses left → a paid Hoof Tap is refused; coins 90.
- Coins 140; level 18 started; pre-level boosters have no free uses left → choosing a Firecracker is refused; coins 140; the attempt can still start without it.

### IR-81 · Lives: at most 5, one lost per failed attempt, refilled by time or for 150 coins (NEW)
Rule: A new player starts with 5 lives and lives are never more than 5; an attempt that ends in a fail lowers lives by 1 as IR-60 says; the refill countdown starts when lives drop below 5, each full 20 minutes of real time (game open or closed) gives 1 life back and starts the next 20 minutes, losing another life doesn't restart it, and it stops at 5 lives or when all 5 are bought; the countdown does not run while unlimited lives are running: a countdown running when they begin is dropped (not resumed), and when they end, if lives are below 5, a fresh 20-minute countdown starts at that moment (game open or closed); if the device clock reads earlier than the saved countdown time, no life comes back until the clock passes that time again and no life is ever taken away, and if the clock is moved forward lives come back as the clock says; buying all 5 back costs 150 coins (IR-80) and sets lives to 5, and at 5 lives it is refused, no coins are charged and the player sees the message "You already have 5 lives"; no level can be started or retried at 0 lives unless unlimited lives are running, except the chapter finales 25 and 50, which can be started and retried at 0 lives, and at 0 lives the retry screen offers only waiting or buying all 5; only winning a chapter finale gives 10 minutes of unlimited lives, counted in real time from the win, during which a fail costs no life and any level can be started at 0 lives.
Applies to: SaveService, the map and the retry screen. Fails and quits: IR-38, IR-57, IR-60. Any reward such as the unlimited-lives grant shows as a badge on the map (GDD › Fairness rules), not as a pop-up. In the MVP only winning level 25 gives unlimited lives (no level follows 50, IR-79); a failed finale gives none. Tests should pass the current time in (a fake clock) rather than wait. How SaveService returns the refusal at 5 lives, and how the UI gets the message text, is an API choice. Settled (owner, 28 Nov 2026): the countdown during unlimited lives; buying all 5 at 5 lives. Not yet specified: an attempt started during unlimited lives that ends in a fail after they have run out.
Source: GDD › Meta & economy › Lives "5 max; lose one when an attempt ends in a fail (a declined offer, moves out a 6th time, or a quit), at most one per attempt; an attempt won after continues costs no life; chapter finales cost no life on a fail; refill 1 per 20 min, or buy all 5 back for 150 coins; 10 min of unlimited lives after each chapter finale"; CLAUDE.md › Owner decisions › "Lives: 5 max, 1 back every 20 min, or all 5 for 150 coins. A failed chapter finale costs no life. Quitting mid-level counts as a fail"; Owner decision, chat 28 Nov 2026 › OQ-89 (Option A: "(a) Yes, by real time: on opening, every full 20 minutes since the saved time gives a life (up to 5). (b) It starts when lives first drop below 5; each life that comes back starts the next 20 minutes; losing another life doesn't restart it; it stops at 5 lives (and when all 5 are bought). (c) Clock moved back: no lives come back until the clock passes the saved time again, and no life is ever taken away; clock moved forward: lives come back as the clock says. (d) 5"), OQ-90 (Option B: "As A [no level can be started (or retried) with 0 lives unless unlimited lives are running; at 0 lives the retry screen offers only waiting or buying all 5 for 150 coins], except the chapter finales (25 and 50) can be started and retried with 0 lives, since a fail there costs no life"), OQ-91 (Option A: "(a) Only winning the finale (once, since it can't be replayed). (b) Yes, real time from the win"); Owner decision, chat 28 Nov 2026 ("Life refill countdown starts after unlimited lives end"; "Refuse it, show error message: you already have 5 lives").
Test cases:
- New save → lives 5.
- Lives 5; level 12 failed → lives 4. Lives 5; level 12 won after one accepted continue → lives 5 (IR-60).
- Lives 5; level 12 failed at time T (lives 4); the game stays open and nothing else happens → at T + 19 min lives 4; at T + 20 min lives 5; at T + 3 h lives 5 (never above 5).
- Lives 5; level 12 failed at T (lives 4); failed again at T + 10 min (lives 3); the game is closed at T + 11 min and opened at T + 50 min → lives 5 (lives back at T + 20 and T + 40; the second fail did not restart the countdown).
- Lives 5; fails at T, T + 1 min and T + 2 min (lives 2); the game is closed and opened at T + 50 min → lives 4 (back at T + 20 and T + 40); at T + 60 min → lives 5.
- Lives 4, countdown started at T. The device clock is set back so it reads T − 60 min → lives 4; at a clock reading of T + 19 min → lives 4; at T + 20 min → lives 5. With lives 3 and the clock set back, lives never drop below 3.
- Lives 4, countdown started at T. The device clock is moved forward to read T + 45 min → lives 5.
- Lives 2, coins 300. Buy all 5 back at T → lives 5; coins 150. Level 12 failed at T + 30 min (lives 4) → lives 5 at T + 50 min, not earlier (the countdown starts again from the new loss).
- Lives 0, next level 14, no unlimited lives → starting level 14 is refused; the retry screen offers only waiting and buying all 5. Lives 0, next level 25 → level 25 can be started; failed → lives 0; retry allowed.
- Lives 1, its refill countdown last restarted at T − 5 min (next life at T + 15 min). Level 25 won at time T (game open). Level 26 failed at T + 5 min → lives 1. Failed again at T + 8 min → lives 1. Failed at T + 11 min → lives 0. Retry at T + 12 min → refused (0 lives, unlimited lives over, level 26 is not a finale). At T + 15 min → lives 0, retry still refused (the countdown that was running at T was dropped; a fresh one started at T + 10 min, and the loss at T + 11 min did not restart it). At T + 30 min → lives 1; retry allowed.
- Lives 0, refill countdown last restarted at T − 1 min (next life at T + 19 min). Level 25 won at T; the game is closed at T + 1 min and opened at T + 6 min → level 26 can be started (unlimited lives until T + 10 min). Opened at T + 12 min instead → starting level 26 is refused; lives 0 until T + 30 min, then 1.
- Lives 3, countdown last restarted at T − 1 min. Level 25 failed at T → unlimited lives are not running (none saved, no map badge); lives 3. Level 25 then won at T + 5 min (the running countdown is dropped); level 26 failed at T + 14 min → lives 3; at T + 15 min unlimited lives end and a fresh countdown starts; failed again at T + 16 min → lives 2; at T + 35 min → lives 3.
- Lives 3, countdown 5 min in (started at T − 5 min). Level 25 won at T (game open) → unlimited lives until T + 10 min; at T + 10 min lives 3 and a fresh countdown starts; at T + 15 min lives 3 (no life from the dropped countdown); at T + 30 min lives 4; at T + 50 min lives 5.
- Same start (lives 3, countdown started at T − 5 min). Level 25 won at T; the game is closed at T + 1 min and opened at T + 45 min → lives 4 (counted as if the countdown began at T + 10 min, when unlimited lives ended: a life at T + 30 min, the next due at T + 50 min); at T + 50 min → lives 5.
- Lives 5. Level 25 won at T → unlimited lives until T + 10 min; at T + 10 min lives 5 and no countdown starts; at T + 30 min lives 5.
- Lives 5, coins 500. Buy all 5 lives → refused; lives 5; coins 500; the player sees "You already have 5 lives". Lives 4, coins 500 → bought; lives 5; coins 350.

### IR-82 · Hero boosters unlock at 11, 23, 29 and 36 with free uses, then cost coins (NEW)
Rule: Kancil's Hoof Tap unlocks at level 11 with 3 free uses, then costs 100 coins a use; Binturong's Tail Slam at 23 with 2 free, then 200; Red Panda's Bamboo Dash at 29 with 2 free, then 150; Peafowl's Feather Fan at 36 with 2 free, then 100; a booster unlocks when its level N is first started, so it can be used from that first attempt of level N on, and never before; its free uses are given once, when it unlocks (not again on each level); each use spends a free use while any are left, otherwise its price in coins is paid at the moment of use (IR-80; refused with fewer coins); paid uses are never bought ahead, so the save's count per booster is its free uses left; no other booster or free per-level power exists in the MVP.
Applies to: SaveService (free uses left, and which boosters are unlocked), BoosterService. Effects: IR-34 to IR-36; a booster uses no move (IR-62). Win targets and the level bot assume no boosters. Monkey's Staff and Rat's Nibble are cut (CLAUDE.md). The GDD save example's `"bamboo_dash": 0` can mean "not unlocked" or "unlocked, no free uses left", so the save must also know which are unlocked (or derive it from the levels started); an API choice.
Source: GDD › Meta & economy › Booster unlocks › "11 | Kancil's Hoof Tap | … | 3 free, then 100 coins each", "23 | Binturong's Tail Slam | … | 2 free, then 200 coins each", "29 | Red Panda's Bamboo Dash | … | 2 free, then 150 coins each", "36 | Peafowl's Feather Fan | … | 2 free, then 100 coins each", "30 | Monkey's Staff | … | Cut from the MVP", "50 | Rat's Nibble | … | Post-MVP"; Save file › `"boosters": {"hoof_tap": 3, "tail_slam": 2, "bamboo_dash": 0, "feather_fan": 0}`; CLAUDE.md › Owner decisions › "Hero boosters: Hoof Tap (level 11), Tail Slam (23), Bamboo Dash (29), Feather Fan (36). Cut: Monkey's Staff, Rat's Nibble, and any free per-level powers"; Research basis › "Boosters unlock one at a time with free uses"; Owner decision, chat 28 Nov 2026 › OQ-93 (Option A: "(a) When level N is first started, so it can be used (and taught) on level N. (b) Paid at the moment of use: with no free uses left, using it costs its price then; the save's count is the free uses left").
Test cases:
- Next level 10 → no hero booster can be used. Next level 35 (started) → Feather Fan can't be used; Hoof Tap, Tail Slam and Bamboo Dash can.
- Level 10 won; next level 11, not yet started → Hoof Tap not unlocked. Level 11's first attempt starts → Hoof Tap unlocked with 3 free uses and usable in that attempt. Level 36's first attempt starts → Feather Fan unlocked with 2 free uses.
- Level 11's first attempt: 1 Hoof Tap used, then the attempt fails → free uses 2. Retry → still 2 (not given again).
- Hoof Tap unlocked with 3 free uses, coins 500. Three Hoof Taps → free uses 0; coins 500. A 4th Hoof Tap → coins 400.
- Hoof Tap free uses 2 after level 14; level 15 started → still 2 (no free uses per level).
- Tail Slam unlocked, no free uses, coins 150 → a Tail Slam is refused; coins 150. Coins 200 → one Tail Slam; coins 0.

### IR-83 · Pre-level boosters unlock at 16: 1 free of each, then 150 coins (NEW)
Rule: Pre-level boosters unlock when level 16 is first started, so from that first attempt on the player can start an attempt with a Rocket + Crane, or with a Firecracker, placed on the starting board as IR-77 says; at most one of the two per attempt; each is spent per attempt (each attempt started with one spends one, a retry included); each of the two has 1 free use, then costs 150 coins, paid when the attempt starts with it (IR-80; refused with fewer coins); neither is available before level 16 is first started; a pre-level booster may be chosen for the attempt that also gets the win-streak chest (IR-84), and then the chest's Rocket and Crane are placed after the booster's specials.
Applies to: SaveService (free uses left, unlocked), the level-start screen, LevelLoader (`pre_specials`, IR-77). On CLAUDE.md's cut list (item 2) if a milestone slips. Win targets and the level bot use none. Spent per attempt: a pre-level booster in an attempt that fails, is quit or is killed (IR-38) stays spent. Settled (owner, 28 Nov 2026): a pre-level booster on the streak-chest board. The chest is not a pre-level booster, so "one of the two per attempt" still holds with it; the order of the chest's own Rocket and Crane is not set by this rule.
Source: GDD › Meta & economy › Booster unlocks › "16 | Pre-level boosters | Pre-level | Start with a Rocket + Crane, or a Firecracker. … | 1 each free, then 150 coins each"; MVP milestones › Cut list › "2. Pre-level boosters (level 16)"; Owner decision, chat 28 Nov 2026 › OQ-93 (Option A: "(a) When level N is first started … (b) Paid at the moment of use … (c) One of the two per attempt. (d) Per attempt: each attempt started with one spends one (a retry needs another, free or 150 coins)"); Owner decision, chat 28 Nov 2026 ("Yes": a pre-level booster and the streak chest on the same board, the chest's specials placed after the booster's).
Test cases:
- Next level 15 → no pre-level booster can be chosen. Level 16's first attempt → both can be chosen (one of them).
- First Rocket + Crane chosen, coins 500 → free; coins 500. A later attempt started with Rocket + Crane → coins 350.
- Rocket + Crane already used once; the first Firecracker → free; coins unchanged.
- Level 18, both free uses left, coins 500. Choosing Rocket + Crane and a Firecracker for the same attempt → refused; only one can be chosen.
- Level 18: attempt 1 started with the free Firecracker (coins 500), then fails. Retry started with a Firecracker → coins 350. Retry started with nothing → coins unchanged; no Firecracker on the board.
- Streak chest waiting; level 22 started with a pre-level Firecracker → allowed; the starting board has 3 specials: the Firecracker, placed first (IR-77), then the chest's Rocket and Crane in other cells; the board has no match.
- Streak chest waiting; level 22 started with a pre-level Rocket + Crane, loaded with seed 1234 → 4 specials, all in different cells: the booster's Rocket and Crane are placed first, then the chest's Rocket and Crane; loaded again with seed 1234 → the same 4 cells and colours.

### IR-84 · Win streak: 6 wins in a row drop a free Rocket and Crane onto the next board (NEW)
Rule: The win streak counts levels won in a row; an attempt that ends in a fail (a declined offer, moves out a 6th time, or a quit, on finales too) sets it to 0; a win after accepted continues counts as a win; when the streak reaches 6 a chest drops and the streak goes back to 0 (the next chest needs 6 more wins); the chest puts a free Rocket and Crane, placed as IR-77 says, on the next attempt's starting board, costing no coins and no booster uses; that attempt uses the chest up whatever its result, so a retry after it starts without it; a 6th win on level 50 gives no chest (there is no next board).
Applies to: SaveService (streak count, chest waiting), LevelLoader (`pre_specials`, IR-77). On CLAUDE.md's cut list (item 1) if a milestone slips. Accepting a continue doesn't end the attempt, so it doesn't touch the streak. An app closed or killed mid-level is a quit (IR-38): streak 0, and a chest on that board is used up. Settled (owner, 28 Nov 2026): a pre-level booster may be used on the chest board; the chest's Rocket and Crane are placed after the booster's specials (IR-83).
Source: GDD › Meta & economy › Currencies › "Win streak | 6 wins in a row: a chest drops a free Rocket and Crane onto the next board, placed as for pre-level boosters"; Lives (what ends an attempt in a fail); Interaction rules › "Quitting mid-level | Counts as a fail"; Owner decision, chat 28 Nov 2026 › OQ-70 ("an attempt won after continues costs no life": a win), OQ-92 (Option A: the streak back to 0), OQ-94 (Option A: "(a) The streak goes back to 0; the next chest needs 6 more wins (12 in a row in total). (b) The chest is used up by that attempt; the retry starts without it (and the fail sets the streak to 0). (c) No chest").
Test cases:
- Streak 5; level 21 won → a chest; streak 0; level 22's first attempt starts with a Rocket and a Crane (IR-77); coins and pre-level booster uses unchanged.
- Streak 5; level 21 won (chest, streak 0); level 22 won with the chest → streak 1; level 23's board has no chest Rocket or Crane. Levels 22 to 27 all won → the next chest drops after level 27 (streak 6 → 0); level 28 starts with it.
- Streak 5; level 21 won (chest); level 22's first attempt, with the chest, fails → streak 0; the retry starts with no chest Rocket or Crane.
- Streak 4; the player quits level 14 → streak 0.
- Streak 4; level 14: offer 1 accepted, then won → streak 5.
- Streak 3; level 25 failed (no life lost, IR-60) → streak 0.
- Streak 5; level 50 won → no chest (no level can be started, IR-79).
- Streak 5; level 21 won (chest); pre-level Firecracker free uses 0, coins 500; level 22 started with a Firecracker → coins 350; the board has the Firecracker and the chest's Rocket and Crane (IR-83); the chest is used up.

### IR-85 · The Rat is restored when its 8th fragment is won (NEW)
Rule: Each fragment level won adds 1 to its guardian's fragments (IR-58, `fragments.rat`), and when the Rat has 8 it is added to the restored guardians, which with the scripted fragment levels happens when level 50 is won; fragments are never spent, lost or given by any other level; SaveService knows a fragment level by its level number (26, 30, 33, 35, 38, 40, 45 or 50, IR-70).
Applies to: SaveService. Fragment levels and their `fragment` field: IR-70. Counting by level number gives the same result as the level file's `fragment.guardian` while the Rat is the only guardian with fragments (all of levels 1–50); it must be revisited when another guardian gets fragments (post-MVP). Kept for the retry on a fail: IR-58. Random drops, the pity rule, other guardians' fragments and Soul Dust are out of scope.
Source: GDD › Soul fragments › "The Rat's 8 fragments are scripted so it is restored at exactly level 50", Rules › "The Rat needs 8 fragments"; Schedule › "26–50 | 26, 30, 33, 35, 38, 40, 45, 50 (scripted) | Rat 8/8 | Rat restored at 50"; Currencies › "Soul fragments | Not spendable; restore guardians"; Save file › `"restored": []`; Story beats › 50 "Rat guardian restored"; CLAUDE.md › Owner decisions › "Rat fragments are scripted at levels 26, 30, 33, 35, 38, 40, 45 and 50"; Owner decision, chat 28 Nov 2026 ("Agree": SaveService counts fragments by the level number).
Test cases:
- SaveService told only "level 26 won" (no level file passed) → `fragments.rat` +1. Told "level 27 won" → `fragments.rat` unchanged.
- `fragments.rat` 7, restored none; level 50 won → `fragments.rat` 8; restored = Rat.
- `fragments.rat` 6; level 45 won → `fragments.rat` 7; restored none.
- Levels 1–50 won in order → `fragments.rat` becomes 1 at 26, 2 at 30, 3 at 33, 4 at 35, 5 at 38, 6 at 40, 7 at 45, 8 at 50; no other win changes it.
- `fragments.rat` 3; a fail, a continue bought and a booster bought → `fragments.rat` 3.

### IR-86 · Every attempt is logged, quits and first tries included (NEW)
Rule: When an attempt ends it is logged with its level, whether it was won or failed, whether it ended by a quit, and whether it was that level's first try (the first attempt of that level, whatever its result, a quit included); an attempt ended by the app being closed or killed is logged as a fail and a quit, at the latest on the next launch (IR-38); buying lives back and lives running out (reaching 0) are logged too; the furthest level is the progress of IR-79.
Applies to: SaveService (or whatever stores the log; where the log is kept or sent is an implementation choice, and the MVP has no account server). Used to measure first-try win rates against the tier bands. A continue doesn't end an attempt, so it adds no attempt entry.
Source: GDD › MVP milestones › Retention test › "Log per player: furthest level, every attempt and win, lives run out, life refills bought and mid-level quits"; Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try"; Level progression › Level tiers › "First-try win target"; Fairness rules › "every level's human first-try win rate"; Owner decision, chat 28 Nov 2026 › OQ-92 (Option A: "the first try used and logged").
Test cases:
- Level 12 never played. The player quits after 3 moves → one entry: level 12, fail, quit, first try. Retry and win → a second entry: level 12, win, not a quit, not a first try.
- Level 25, first attempt: moves run out, offer 1 declined → one entry: level 25, fail, not a quit, first try.
- Level 30, first attempt: offer 1 accepted, then won → one entry: level 30, win, first try.
- Lives 1; level 14 failed → lives 0; a "lives ran out" entry. Coins 150; all 5 lives bought → a "lives bought" entry.
- Level 17 never played. The app is killed mid-level; next launch → one entry: level 17, fail, quit, first try. Retry and win → a second entry: level 17, win, not a first try.

### IR-87 · Each story beat plays once (NEW)
Rule: Each story beat of levels 1–50 plays only the first time its level is reached; retries of that level skip it, also after the game is closed and opened again, because the save remembers which beats have been seen.
Applies to: StoryPlayer and SaveService (one saved list of seen beats, IR-78). The beats in levels 1–50: 1 (intro comic), 15, 17, 20, 25, 30, 35, 40, 45 and 50 (the creature beat is at 17 by OQ-83). A beat skipped by the player has still been played (it is skippable) and is not shown again. The level 1 beat is the `"intro"` value (IR-63) and plays before the board (Owner decision, chat 28 Nov 2026 › story_beat "intro"). Not yet specified for the other beats: whether each plays before or after its level (the GDD gives only the level and how it is delivered). Level 17's beat is the `"mini"` value (IR-63, Owner decision, chat 28 Nov 2026 › OQ-99 Option A).
Source: GDD › Story › Story beats, levels 1–50 (table: levels 1, 15, 17, 20, 25, 30, 35, 40, 45, 50; "Intro comic (4 panels, skippable…)"); Level progression › "each hard level carries a mini story beat"; Fairness rules › "At most one pop-up between the lobby and Play"; Owner decision, chat 28 Nov 2026 › OQ-96 (Option A: "Each beat plays once, the first time it is reached; retries skip it (the save remembers which were seen)").
Test cases:
- Level 15 never reached. First attempt → the level 15 story card plays; the attempt fails; retry → no story card.
- Level 15's beat seen; the game is closed and opened; level 15 retried → no story card.
- Level 15's beat skipped by the player on the first attempt → marked seen; the retry shows no story card.
- Level 16 (no beat) started → no beat plays and the seen list is unchanged.
- Level 1, never played. First attempt → the intro comic plays before the board is shown; the attempt fails; retry → no comic.

### IR-88 · A board that fails to build cancels the attempt and puts the save back as it was (CHANGED)
Rule: If the attempt has been started in the save but its board then fails to build, the attempt is cancelled, not counted as a quit or a fail, and the save goes back to exactly how it was before the attempt started: no life is lost, the level is not marked as tried (so the next attempt that builds is its first try), the win streak is unchanged, no attempt-log entry is written (no fail, no quit, no first try, no "lives ran out"), the open-attempt mark is cleared (so the next launch does not treat it as a killed attempt, IR-38), a pre-level booster chosen for it comes back (its free use, or the 150 coins paid, IR-83), a streak chest it used is waiting again (IR-84), a hero booster unlocked by this start is locked again (it unlocks, with its free uses, when the level is next started, IR-82); no fail result, continue offer or retry screen is shown for it, and the player goes back to the screen the attempt was started from, with the message "This level couldn't be loaded".
Applies to: LevelSession and SaveService: any failure to build the board after the attempt was started (e.g. LevelLoader returns no board for an invalid level or an unknown `pre_specials` name, IR-77). Not a player quit or a killed app (IR-38), and not running out of moves (IR-37, IR-57). Lives: IR-60, IR-81. Streak and chest: IR-84. Pre-level boosters: IR-83. Hero booster unlocks: IR-82. Attempt log and first try: IR-86. A cancelled attempt is none of fail, quit or kill, so IR-83's "spent per attempt" and IR-84's "used up by that attempt whatever its result" don't apply to it. Any other save field changed by the start (e.g. a story beat marked seen at that start, IR-87) is put back too, by the owner's "exactly how it was". How SaveService undoes the start (e.g. a snapshot restored, a cancel call, or starting the attempt only after the board is built) is an implementation choice; only the end state is the rule. "No attempt-log entry" and "open-attempt mark cleared" are the rules-keeper's reading of "cancel the attempt … instead of counting it as a quit" with "no first try used"; OQ-97 A ("exactly how it was before the attempt started") confirms them. The screen the attempt was started from is e.g. the map or the level-start screen. The message text is exact, as given in the decision (capital T, straight apostrophe, no full stop).
Source: Owner decision, chat 28 Nov 2026 › board build failure ("If a board fails to build after an attempt has started, cancel the attempt with no penalty (no life lost, no first try used, streak kept) instead of counting it as a quit"); Owner decision, chat 28 Nov 2026 › OQ-97 (Option A: "A cancelled attempt (IR-88, board failed to build) restores the save to exactly how it was before the attempt started: the pre-level booster use or its coins come back, a used streak chest is waiting again, a hero booster unlocked by that start is locked again, and the player goes back to the screen they started from with a short message \"This level couldn't be loaded\""); GDD › Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try" (the rule this case does not follow); MVP milestones › Retention test › "Log per player: … every attempt and win, lives run out, … mid-level quits".
Test cases:
- Level 12 never played; lives 5, streak 3, coins 1000, no pre-level booster, no chest waiting. The attempt is started from the map, then the board fails to build → lives 5; streak 3; coins 1000; level 12 not tried; attempt log unchanged (no entry); no open attempt; no fail result, continue offer or retry screen; the map is shown with the message "This level couldn't be loaded"; next level 12. The next attempt builds and is won → one log entry: level 12, win, not a quit, first try; streak 4.
- Level 18; Firecracker free uses 1, coins 500. The attempt is started from the level-start screen with the free Firecracker; the board fails to build → Firecracker free uses 1; coins 500; the level-start screen is shown with the message "This level couldn't be loaded".
- Level 18; Rocket + Crane free uses 0, coins 500. The attempt is started with Rocket + Crane (coins 350 at the start); the board fails to build → coins 500; Rocket + Crane free uses 0. The next attempt started with Rocket + Crane builds → coins 350.
- Level 21 won with streak 5 (chest waiting, streak 0). Level 22's first attempt is started; the board fails to build → chest still waiting; streak 0. The next attempt of level 22 builds → its starting board has the chest's Rocket and Crane (IR-77); the chest is then used up.
- Level 10 won; Hoof Tap not unlocked. Level 11's first attempt is started (Hoof Tap unlocks with 3 free uses); the board fails to build → Hoof Tap not unlocked; no free uses given. The next attempt of level 11 builds → Hoof Tap unlocked with 3 free uses, usable in that attempt.
- Level 14 tried once before (one log entry: fail); lives 1, streak 0. An attempt is started and its board fails to build → lives 1 (not 0); no "lives ran out" entry; the log still has exactly one entry; level 14 can still be started (IR-81).
- Level 25 never played; lives 2, streak 5. The attempt is started, the board fails to build, then the app is closed. Next launch → lives 2; streak 5; no quit or fail logged; level 25 not tried.
