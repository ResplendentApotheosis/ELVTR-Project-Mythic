# Zodiac Forest: Interaction rules spec

Derived only from `docs/gdd/zodiac-forest-gdd-final.md` (the GDD wins over this file). Owner decisions OQ-01 to OQ-38 are in the GDD's "Rules clarifications" table and are cited as "Rules clarifications › OQ-xx". IDs are permanent: never renumber; a removed rule is marked `RETIRED` and kept. Gaps and conflicts live in `spec/open_questions.md` (OQ-xx), never here. New rules are numbered after IR-38 but filed in the section they belong to (see the index).

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
| C. Damage to layers and obstacles | IR-09 to IR-15, IR-44, IR-45, IR-53, IR-54 |
| D. Special effects | IR-16 to IR-21, IR-41, IR-47, IR-48, IR-49 |
| E. Combos | IR-22 to IR-27, IR-46 |
| F. Soul fragments and drop items | IR-28 to IR-31 |
| G. Gravity, refill, cascades, shuffle | IR-32, IR-33, IR-51 |
| H. Hero boosters | IR-34 to IR-36 |
| I. Level flow | IR-37, IR-38 |

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

### IR-02 · Tapping a special fires it and costs a move
Rule: Tapping a special fires it and uses one move; tapping anything else does nothing.
Applies to: Bamboo Rocket, Firecracker, Paper Crane, Jade Orb (Orb tap effect: IR-19).
Source: GDD › Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Interaction rules › "Tapping a Jade Orb … costs a move like any tap".
Test cases:
- Moves 10. Tap a Firecracker at (4,4) → it fires (IR-17); moves = 9.
- Moves 10. Tap a plain piece → nothing happens; moves = 10.

### IR-39 · A special swapped with a plain piece or drop item fires from its new cell, after the swap's matches (CHANGED)
Rule: Swapping a Bamboo Rocket, Firecracker or Paper Crane with an adjacent plain piece or drop item is never snapped back: the swap completes and uses one move, any match the swap makes resolves first (clears, neighbour hits, new specials), and then the special fires from the cell it sits in after the swap, possibly setting off (IR-41) a special that match has just made.
Applies to: Rocket, Firecracker or Crane + plain piece or drop item. Jade Orb + plain piece or drop item: IR-18. Crane + special: IR-27.
Source: GDD › Rules clarifications › OQ-03 "The special fires and the swap costs a move. Snap-back applies to two plain pieces, and to a drop item swapped with a plain piece", OQ-26 "The swap completes; any match it makes resolves first, then each special fires from the cell it sits in", OQ-30 "A Rocket, Firecracker or Crane swapped with a drop item fires as with a plain piece"; setting off a just-made special follows OQ-04.
Blocked by: OQ-44 (whether pieces fall, and cascades resolve, between the swap's match and the special firing). Tests below keep everything below the special uncleared, so it can't fall.
Test cases:
- Moves 10. Row Rocket at (4,4), Y at (4,5); swap (4,5)→(4,4) makes no match → accepted; moves = 9; the Rocket (now at (4,5)) clears all 9 cells of row 5; no cell of row 4 is cleared by it.
- Moves 10. R at (2,4),(3,4); yellow Firecracker at (4,4); R at (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clear (clear event first); then the Firecracker, now at (4,5), fires with both blasts centred on (4,5) (area x 3–5, y 4–6); moves = 9.
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
Applies to: Plain pieces. Placement: IR-40. Colour: IR-50. Crane effect: IR-20, IR-48, IR-49.
Source: GDD › Core gameplay › Special pieces › "2×2 square | Paper Crane".
Test cases:
- R at (2,2),(3,2),(3,3), Y at (2,3), R at (1,3). Swap (1,3)→(2,3) → the 4 R pieces clear; one red Paper Crane is created at (2,3).

### IR-05 · Four in a line makes a Bamboo Rocket that fires along that line
Rule: Four same-colour pieces in a row or column make a Bamboo Rocket that fires along the line it was made from: a horizontal 4 makes a row Rocket, a vertical 4 makes a column Rocket (its icon shows the direction).
Applies to: Plain pieces (player or cascade matches). Rockets made by Jade Orb + Rocket: IR-16, IR-25. Win-finale Rockets: OQ-40.
Source: GDD › Core gameplay › Special pieces › "4 in a line | Bamboo Rocket"; Rules clarifications › OQ-01 "a horizontal 4 clears its row, a vertical 4 clears its column. Its icon shows the direction".
Test cases:
- R at (1,4),(2,4),(4,4), Y at (3,4), R at (3,5). Swap (3,5)→(3,4) → 4 pieces clear; one red **row** Rocket at (3,4).
- R at (5,1),(5,2),(5,4), Y at (5,3), R at (4,3). Swap (4,3)→(5,3) → 4 pieces clear; one red **column** Rocket at (5,3).

### IR-06 · An L, T or "+" of five makes a Firecracker (CHANGED)
Rule: Five same-colour pieces in an L, T or "+" shape (a line of 3 and a line of 3 at right angles sharing one cell) make a Firecracker.
Applies to: Plain pieces. Larger mixed shapes: IR-08. Placement: IR-40 (crossing cell in cascades). A "+" can only form in a cascade: every neighbour of its centre is part of the shape, so no single swap can complete it without a match already existing.
Source: GDD › Core gameplay › Special pieces › "L or T shape (5) | Firecracker"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule", OQ-28 "Counts as an L/T and makes a Firecracker", OQ-25 "(the crossing cell for an L, T or '+')".
Test cases:
- L by swap: R at (2,2),(2,3),(3,4),(4,4), Y at (2,4), R at (1,4). Swap (1,4)→(2,4) → 5 pieces clear; one red Firecracker at (2,4).
- T by cascade: R lands at (2,2),(3,2),(4,2),(3,3),(3,4) → 5 pieces clear; one red Firecracker at (3,2) (IR-40 crossing cell).
- "+" by cascade: R lands at (3,1),(2,2),(3,2),(4,2),(3,3) → 5 pieces clear; exactly one red Firecracker at (3,2) (the crossing cell); no other special.

### IR-07 · Five or more in a line makes a Jade Orb
Rule: Five or more same-colour pieces in a single row or column make one Jade Orb.
Applies to: Plain pieces. Orb effects: IR-18, IR-19, IR-25, IR-26. Placement: IR-40.
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

### IR-40 · Where a new special appears (CHANGED)
Rule: A special made by a player match that contains the swap's target cell appears on the target cell; any other special (cascade matches, and a player match that doesn't contain the target cell, such as the start-cell match of IR-43) appears on the lowest, then left-most, cell of its match, except an L, T or "+", which puts it on the crossing cell (the cell shared by its two lines).
Applies to: IR-04 to IR-07, IR-42, IR-43.
Source: GDD › Rules clarifications › OQ-02 "On the cell the player moved into; in cascades, on the lowest then leftmost cell of the match (the crossing cell for an L or T)", OQ-25 "A special whose match doesn't include the player's cell | Uses the cascade placement: lowest, then left-most cell (the crossing cell for an L, T or '+')", OQ-28.
Test cases:
- Swap (3,5)→(3,4) completes R at (1,4),(2,4),(3,4),(4,4) → Rocket at (3,4).
- R at (6,2),(6,3),(6,5), Y at (6,4), R at (5,4). Swap (5,4)→(6,4) → column Rocket at (6,4) (the target cell, not the lowest cell (6,5)).
- Cascade: R lands at (2,6),(3,6),(4,6),(5,6) → row Rocket at (2,6). Cascade: R lands at (7,1),(7,2),(7,3),(7,4) → column Rocket at (7,4).
- Cascade: Y 2×2 lands at (5,2),(6,2),(5,3),(6,3) → yellow Crane at (5,3).
- Start-cell match, vertical: R at (4,1),(4,2),(4,4); Y at (3,1),(3,2),(3,4); R at (3,3), Y at (4,3). Swap (3,3)→(4,3) → red column Rocket at (4,3) (target cell); yellow column Rocket at (3,4) (lowest cell of the Y match (3,1)–(3,4)).
- Start-cell match, horizontal: R at (2,3),(3,3),(5,3); Y at (2,4),(3,4),(5,4); Y at (4,3), R at (4,4). Swap (4,4)→(4,3) → red row Rocket at (4,3) (target cell); yellow row Rocket at (2,4) (left-most cell of the Y match (2,4)–(5,4)).

### IR-42 · Cascade matches make specials (NEW)
Rule: Matches made by falling pieces make specials by exactly the same shape, direction and priority rules as player matches.
Applies to: Every cascade match (IR-32). Placement: IR-40.
Source: GDD › Rules clarifications › OQ-05 "Make specials by the same rules as player matches".
Test cases:
- A fall lines up B at (0,8),(1,8),(2,8),(3,8) → those 4 clear and one blue row Rocket appears at (0,8), without a move being used.
- A fall lines up G at (4,2)…(4,6) (vertical 5) → one Jade Orb at (4,6).

### IR-43 · One swap making two matches: both resolve, each makes its own special (CHANGED)
Rule: When one swap makes two separate matches (one through each swapped piece), both matches clear and each makes its own special by IR-04 to IR-08, the start-cell match's special being placed by the cascade placement (IR-40).
Applies to: Player swaps that create a match at both the start and the target cell.
Source: GDD › Rules clarifications › OQ-07 "Both resolve, and each can make its own special", OQ-25.
Test cases:
- R at (3,3); Y at (4,3); R at (4,1),(4,2),(4,4); Y at (3,4),(3,5). Swap (3,3)→(4,3) → R at (4,1),(4,2),(4,3),(4,4) (vertical 4) and Y at (3,3),(3,4),(3,5) (vertical 3) both clear; one red column Rocket at (4,3); no special from the Y match; moves −1.
- R at (4,1),(4,2),(4,4); Y at (3,1),(3,2),(3,4); R at (3,3), Y at (4,3). Swap (3,3)→(4,3) → 8 pieces clear; exactly 2 specials: red column Rocket at (4,3) and yellow column Rocket at (3,4); moves −1.

### IR-50 · Rockets, Firecrackers and Cranes keep a colour; the Jade Orb has none (CHANGED)
Rule: A Bamboo Rocket, Firecracker or Paper Crane keeps the colour of the match that made it and matches like a plain piece of that colour; when such a match forms, the match resolves first (clears, neighbour hits, new specials) and then the special fires from its cell (IR-21); a Jade Orb has no colour and is never part of a match.
Applies to: All specials.
Source: GDD › Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces. The Jade Orb has no colour", OQ-26 "any match it makes resolves first, then each special fires from the cell it sits in".
Test cases:
- R at (1,4); Y at (2,4); red row Rocket at (3,4); R at (2,5). Swap (2,5)→(2,4) → R 3-match (1,4),(2,4),(3,4) clear event first, then the Rocket fires from (3,4) (all of row 4 cleared).
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
Applies to: OB02 withered bramble, OB07 mummified creature / creep cocoon, OB03 creep moss, OB06 petrified pillar, OB12 frozen idol, and overlays (layer 3). Not underlays (IR-15). Pieces cleared by a special never count as a match (IR-44). A match that includes a covered piece: OQ-41.
Source: GDD › Board layers & obstacles › Cell layer model › "3 · Overlay … Cleared by Adjacent matches", "2 · Content … Matching / adjacent matches / specials"; Obstacle set › OB02 "Match next to it", OB07 "Match next to it to unwrap", OB03 "Match next to it to clear", OB06 "Ground down by adjacent matches"; Rules clarifications › OQ-08 "One hit to that obstacle. Only up, down, left and right count as 'next to', never diagonals", OQ-10 "Only matches hit neighbours".
Test cases:
- Bramble (OB02) with 3 layers at (4,3). A 3-match at (3,4),(4,4),(5,4) → bramble has 2 layers.
- Bramble with 1 layer at (4,3). A 3-match at (5,4),(6,4),(7,4) (touches only diagonally at (5,4)) → bramble unchanged.
- Pillar (OB06) 1×4 at x=4, y=2–5, hp 3. A 3-match at (5,2),(5,3),(5,4) runs alongside 3 of its cells → pillar hp 2.
- Brambles with 2 layers at (3,3) and (5,3). A 3-match at (3,4),(4,4),(5,4) → both brambles have 1 layer.
- Mummified creature (OB07) hp 1 at (2,2). A 3-match at (3,1),(3,2),(3,3) → creature freed (goal +1).

### IR-15 · An underlay is hit by a match on top of it, or by a special with nothing above it (CHANGED)
Rule: An underlay takes one hit when a match is made on top of it, or when a special covers its cell and there is no overlay or blocker above it (IR-09).
Applies to: OB10 creep goo (hp 1–3 per the brief's `underlay` field). OB04 healing dew: a match or special that clears a piece on dew spreads it instead (IR-53).
Source: GDD › Board layers & obstacles › Cell layer model › "1 · Underlay … Cleared by Matching on top of it"; Obstacle set › OB10 "Make a match on top to clear it"; Rules clarifications › OQ-09 "with no overlay or blocker, the underlay (goo or dew) takes the hit", OQ-31.
Test cases:
- Goo hp 1 under (3,5). A 3-match at (2,5),(3,5),(4,5) → goo at (3,5) cleared.
- Goo hp 2 under (3,5). Same match → goo hp 1.
- Goo hp 1 under (3,5), plain piece on it. A column Rocket clears column 3 → piece cleared; goo cleared.

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

### IR-53 · Healing dew spreads to every cell cleared with it (NEW)
Rule: When a match or a special clears a piece on a healing-dew cell, every cell cleared by that same match or special gets dew; a Paper Crane landing on an uncovered dew target cell gives that cell dew.
Applies to: OB04 healing dew (underlay). Matches next to dew (not on it) don't spread it. Crane landing: IR-48.
Source: GDD › Board layers & obstacles › Obstacle set › OB04 "Matches made on dew spread it; cover the target cells"; Interaction rules › "Where the Paper Crane flies … Dew goal: an uncovered target cell"; Rules clarifications › OQ-31 "When a match or special clears a piece on a dew cell, every cell cleared by that match or special gets dew. A Crane landing on an uncovered target cell gives it dew".
Blocked by: OQ-46 (whether cells in a special's area that held no piece, e.g. a bramble cell, also get dew). Tests below use areas where every cell holds a piece. OQ-49 (whether the Crane landing on a dew target also clears the piece there); the Crane test checks dew only.
Test cases:
- Dew under (3,5) only. A 3-match at (2,5),(3,5),(4,5) → (2,5),(3,5),(4,5) all have dew; no other cell has dew.
- Dew under (5,2) only; row 2 holds 9 plain pieces and no obstacles. A row Rocket fires along row 2 → all 9 cells of row 2 have dew.
- Dew under (3,6) only. A 3-match at (2,5),(3,5),(4,5) (dew is next to the match, not under it) → no new dew.
- Dew goal; only uncovered target cell left is (6,2); no other goal. A Crane fires → it lands on (6,2); (6,2) has dew; dew goal complete.

### IR-54 · Pieces under an overlay are locked (NEW)
Rule: A piece in a cell with an overlay (creep moss, shutters) is locked: it can't be swapped and doesn't fall, but it can be part of a match; when the piece in such a cell is cleared and the overlay survives, the cell refills by normal falling and the piece that falls in is then covered too.
Applies to: Every cell with an overlay (layer 3). Swaps: IR-52. Gravity: IR-51. Specials over covered cells: IR-09.
Source: GDD › Board layers & obstacles › Cell layer model › "3 · Overlay"; Rules clarifications › OQ-29 "Pieces under an overlay (moss, shutter) | Locked: can't be swapped and don't fall, but can be part of a match. A cell emptied under a surviving overlay refills by normal falling", OQ-19 "Pieces locked under an overlay (moss, shutter) don't fall", OQ-21.
Blocked by: OQ-41 (what a match through a covered piece does to the piece and the layers; whether the shuffle moves covered pieces; how a cell below a locked piece is filled). Tests below avoid these.
Test cases:
- Moves 10. Moss hp 1 over R at (4,4), Y at (4,5) → swaps (4,5)→(4,4) and (4,4)→(4,5) are both refused; moves = 10 (IR-52).
- Moss hp 2 over Y at (6,3). A row Rocket fires along row 3 → Y cleared; moss hp 1; after the board settles (6,3) holds the piece that was at (6,2), under moss hp 1, and that piece can't be swapped.
- Moss hp 2 over G at (4,3); cells (4,6),(4,7),(4,8) emptied directly; the board settles → G is still at (4,3) under moss hp 2 (it did not fall). (How (4,4)–(4,6) are then filled: OQ-41.)

---

## D. Special effects

### IR-16 · A Bamboo Rocket clears its full row or its full column (CHANGED)
Rule: A row Rocket hits every cell of its row and a column Rocket hits every cell of its column, as set when it was made (IR-05); Rockets made by Jade Orb + Rocket copy the direction of the Rocket that was swapped with the Orb.
Applies to: Bamboo Rocket. Hits follow IR-09/IR-10. Win-finale Rockets (leftover moves): direction not decided, see OQ-40.
Source: GDD › Core gameplay › Special pieces › "Bamboo Rocket | Clears its full row or column"; Rules clarifications › OQ-01, OQ-24 "Rockets made by Jade Orb + Rocket | Copy the direction of the Rocket swapped with the Orb".
Blocked by: OQ-40 (finale Rockets only).
Test cases:
- Tap a row Rocket at (4,4) on a plain 9×9 board → all 9 cells of row 4 cleared, nothing else.
- Tap a column Rocket at (4,4) on a plain 9×9 board → all 9 cells of column 4 cleared, nothing else.
- Jade Orb at (4,4), column Rocket at (4,5); R is the most common plain colour. Swap (4,5)→(4,4) → every converted Rocket is a column Rocket (every converted fire event reports "column"). With a row Rocket instead → every converted Rocket is a row Rocket.

### IR-17 · A Firecracker blasts the same 3×3 twice, with the board settling in between (CHANGED)
Rule: A Firecracker blasts the 3×3 area centred on its cell, then pieces fall, new pieces refill and all cascade matches resolve, then it blasts the same 3×3 (same centre cell) a second time; obstacle hits follow IR-12.
Applies to: Firecracker. Cells of the 3×3 that are off the board or not playable are skipped. Firecracker + Firecracker uses the same timing (IR-24).
Source: GDD › Core gameplay › Special pieces › "Firecracker | 3×3 blast, twice"; Rules clarifications › OQ-11 "Hits the same centre cell after pieces have fallen", OQ-32 "Pieces fall, refill and all cascades resolve, then the second blast. Firecracker + Firecracker uses the same timing".
Test cases:
- Tap a Firecracker at (4,4) on a plain 9×9 board with no matches forming → blast 1 clears (3–5, 3–5); pieces from (3–5, 0–2) fall into (3–5, 3–5); 9 new pieces enter at (3–5, 0–2); blast 2 clears (3–5, 3–5) again → 18 pieces cleared in total; events in order: blast 1, fall, refill, blast 2.
- Firecracker at (0,0) → each blast covers only (0–1, 0–1).
- R at (1,5),(2,5); Y at (3,5); R at (3,2). Tap a Firecracker at (4,4) → blast 1 clears (3–5, 3–5); R from (3,2) falls to (3,5); the cascade match R (1,5),(2,5),(3,5) clears **before** blast 2; events in order: blast 1, fall, refill, match clear (1,5)–(3,5), fall, refill, blast 2.

### IR-18 · Jade Orb swapped with a plain piece clears that colour (CHANGED)
Rule: A Jade Orb swapped with a plain piece uses one move and clears every plain piece of that piece's colour (coloured specials of that colour are left alone), covering every cell whose piece it clears (IR-09); a Jade Orb swapped with a drop item acts as an Orb tap (IR-19).
Applies to: Jade Orb + plain piece, Jade Orb + drop item. Orb + Rocket/Firecracker: IR-25. Orb + Orb: IR-26. Orb + Crane: IR-27.
Source: GDD › Core gameplay › Special pieces › "Jade Orb | Clears every plain piece of the colour it's swapped with; specials are left alone"; Rules clarifications › OQ-03 "A Jade Orb swapped with a plain piece clears that piece's colour", OQ-09 "A Jade Orb covers every cell whose piece it clears", OQ-33 "only plain pieces are cleared", OQ-30 "a Jade Orb swapped with one acts as an Orb tap".
Blocked by: OQ-42 (plain pieces under an overlay).
Test cases:
- Moves 15. Plain board, no obstacles, no specials. Orb at (4,4) swapped with B at (5,4) → every B cleared; the Orb is used up; moves = 14.
- Same, with a B on goo hp 1 at (1,1) → that B cleared and the goo cleared.
- Same, with bramble (OB02) at (2,2) next to a cleared B → bramble unchanged (IR-44).
- Same, with a blue row Rocket at (6,6) → every plain B cleared; the blue Rocket is not cleared and does not fire (no Rocket fire event).
- Moves 15. Plain pieces 20 R, 18 Y, 17 B, 16 G; Orb at (4,4), hatchling (OB11) at (4,5). Swap (4,5)→(4,4) → all 20 R cleared; the hatchling is not destroyed; moves = 14.

### IR-19 · Tapping a Jade Orb clears the most common colour (CHANGED)
Rule: A tapped Jade Orb uses one move and clears every plain piece of the most common colour among plain pieces on the board (coloured specials are neither counted nor cleared), ties broken by IR-47.
Applies to: Jade Orb tap; also Orb + drop item (IR-18) and the Orb's effect in Orb + Crane (IR-27). A set-off Orb does nothing (IR-41).
Source: GDD › Interaction rules › "Tapping a Jade Orb | Clears every piece of the most common colour on the board; costs a move like any tap"; Rules clarifications › OQ-14, OQ-33 "Only plain pieces count towards the most common colour, and only plain pieces are cleared".
Blocked by: OQ-42 (plain pieces under an overlay).
Test cases:
- Moves 10. Plain pieces only: 20 R, 18 Y, 17 B, 16 G. Tap Orb → all 20 R cleared; moves = 9.
- Plain pieces only: 18 R, 18 B, 17 Y, 17 G → R cleared (tie, IR-47).
- Plain pieces: 17 R, 18 Y, 16 B, 16 G, plus 2 red Firecrackers → Y cleared (the Firecrackers don't count); both Firecrackers stay and don't fire.

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
Source: GDD › Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Rules clarifications › OQ-03, OQ-04, OQ-18, OQ-26.
Test cases:
- A red Firecracker in an R 3-match → the Firecracker fires (two blast events), after the match's clear event.
- R at (1,4),(2,4); Y at (3,4); red Firecracker at (4,4); R at (3,5). Swap (3,5)→(3,4) → the 4-match (1,4)–(4,4) clears and makes a red row Rocket at (3,4); then the Firecracker fires centred on (4,4); its blast covers (3,4), so the new Rocket is set off and fires along row 4 after the Firecracker's second blast. Event order: match clear, Rocket created, blast 1, blast 2, Rocket fire.
- Tap → see IR-02. Swap → see IR-39. Chain → see IR-41.

### IR-41 · A special hit by another special fires too (chain) (CHANGED)
Rule: When a special's effect covers a cell holding another special, that special is lifted off the board (it no longer falls or takes hits); after the first special has completely finished and pieces have fallen, the set-off specials fire one at a time from the cells where they were hit, lowest first then left-most; a set-off Jade Orb is removed without effect; each set-off special is a separate special for the one-hit rules.
Applies to: All specials and combos as the first special. Jade Orb + Jade Orb clears other specials without firing them (IR-26).
Source: GDD › Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes. Set-off specials are lifted off the board and fire from their cell after pieces fall, lowest first, then left-most. A set-off Jade Orb is removed without effect", OQ-27 "A set-off Jade Orb does nothing; Orb + Orb clears other specials without firing them".
Blocked by: OQ-44 (whether cascade matches resolve before or after the set-off specials fire). OQ-47 (when a set-off special sets off another, whether the new one joins the same waiting list or fires before the other waiting specials). Tests below check order between specials set off by the same special only.
Test cases:
- Tap a row Rocket at (1,4); a column Rocket at (6,4) → row 4 cleared (the column Rocket is lifted, not destroyed); pieces fall; then the column Rocket fires from (6,4) and column 6 is cleared; every event of the first Rocket comes before any event of the second.
- Same, with bramble (OB02) 2 layers at (6,7) → bramble has 1 layer (hit by the set-off Rocket).
- Tap a column Rocket at (4,0); Firecrackers at (4,2) and (4,6) → after column 4 is cleared and pieces fall, the Firecracker hit at (4,6) fires (both blasts centred on (4,6)) before the one hit at (4,2) (both blasts centred on (4,2)).
- Tap a row Rocket at (0,4); column Rockets at (6,4) and (2,4) → the one hit at (2,4) fires before the one hit at (6,4) (same row: left-most first).
- Tap a row Rocket at (0,4); a Jade Orb at (5,4) → the Orb is removed; no colour-clear event; only row 4 was cleared by the Rocket.
- Tap a Firecracker at (4,4); a row Rocket at (5,5) → the Rocket is lifted at blast 1, is not hit again by blast 2, and fires exactly once, along row 5, after blast 2.
- Tap a column Rocket at (4,0); a Crane at (4,6) → after column 4 is cleared, the Crane fires (crane take-off event at (4,6)).

### IR-47 · Colour ties are broken red, yellow, blue, green (CHANGED)
Rule: When two or more colours tie for "most common colour" (counting plain pieces only), the first in the order red, yellow, blue, green is chosen.
Applies to: Jade Orb tap (IR-19), Orb + drop item (IR-18), Jade Orb + special (IR-25), Jade Orb + Crane (IR-27).
Source: GDD › Rules clarifications › OQ-14 "Broken in a fixed order: red, yellow, blue, green", OQ-33.
Blocked by: OQ-42 (plain pieces under an overlay).
Test cases:
- Plain pieces only: 18 R, 18 Y, 17 B, 16 G → R.
- Plain pieces only: 10 R, 19 Y, 19 B, 10 G → Y.
- Plain pieces only: 12 R, 12 Y, 20 B, 20 G → B.
- Plain pieces: 18 R, 18 Y, 17 B, 16 G, plus one yellow Rocket → R (the Rocket isn't counted).

### IR-48 · Paper Crane take-off and landing (CHANGED)
Rule: When a Crane flies, its take-off counts as a special covering its starting cell (for a set-off Crane, the cell where it was hit, IR-41): the Crane is cleared, whatever is in that cell at take-off is treated exactly as IR-09 says (a piece that fell in after the Crane was lifted is cleared, a special there is set off by IR-41, a fragment or drop item stays, IR-28) and the top obstacle layer there takes one hit; at its target cell it then collects the fragment or drop item there, gives an uncovered dew target cell dew (IR-53), or otherwise gives that cell one hit as a special does (IR-09).
Applies to: Every Crane flight (tap, match, swap, chain, IR-27). A set-off Crane's take-off is a separate special from the one that set it off (IR-41).
Source: GDD › Rules clarifications › OQ-16 "Gives one hit to its target cell, or collects the fragment or drop item there. It also clears its own starting cell when it takes off", OQ-09 "A special clears the piece and gives one hit to the top obstacle layer in that cell"; Interaction rules › "a drop item still has to reach the bottom row unless a Crane or Orb + Orb collects it"; Rules clarifications › OQ-34 "Take-off counts as a special on its own cell", OQ-04 "Set-off specials are lifted off the board and fire from their cell after pieces fall", OQ-31 "A Crane landing on an uncovered target cell gives it dew".
Blocked by: OQ-49 (whether a Crane landing on an uncovered dew target also clears the piece there). The dew test below checks dew only.
Test cases:
- Tap a column Rocket at (4,0); Crane at (4,6) on goo hp 2; nothing else special on the board → column 4 cleared (goo hp 1, the Crane lifted); pieces fall, so a plain piece P is now in (4,6); the Crane takes off from (4,6) → P is cleared and the goo is hp 0 (removed); then the Crane lands on its target.
- Crane at (1,7); only goal: bramble (OB02) hp 2 at (6,2) → bramble hp 1; (1,7) is emptied (then refilled, IR-51).
- Only goal: lost hatchling (OB11) at (5,3) → hatchling collected; goal +1; it is not destroyed.
- Only goal: fragment in a cocoon hp 1 at (4,1) → cocoon freed and fragment collected (IR-29).
- Crane at (1,7) on goo hp 1; only goal: bramble hp 2 at (6,2) → take-off clears the Crane and the goo at (1,7); bramble hp 1.
- Crane at (1,7) on goo hp 2 → after take-off, goo at (1,7) hp 1.
- Dew goal; only uncovered target cell (6,2) → the Crane lands there; (6,2) has dew (IR-53).

### IR-49 · Paper Crane targeting order and tie-breaks (CHANGED)
Rule: The Crane aims at one cell of an unfinished goal: an unfreed fragment first, otherwise the goal with the fewest hits left (dew: uncovered target cells left; lantern shrine: pieces still needed; drop items: items still to collect); any tie (between goals or between cells) goes to the cell with the shortest straight-line distance to the Crane, then the top-most, then the left-most; with no goal left it aims at the nearest cell holding any remaining obstacle on any layer or an uncovered dew target cell (same tie-breaks), and with no obstacle left at a piece picked by the level's seeded random number generator; a landing on a lantern shrine counts as one piece of the colour the shrine needs most of.
Applies to: Every Crane flight. "Obstacle" means anything in the GDD's Obstacle set, so creep moss (OB03, overlay) and creep goo (OB10, underlay) both count for the no-goal case; the landing then hits that cell's top layer (IR-48 → IR-09). Uncovered dew target cells also count, and the landing gives the cell dew.
Source: GDD › Interaction rules › "Where the Paper Crane flies"; Rules clarifications › OQ-17 "Aims at one obstacle cell of the goal with the fewest hits left (an unfreed fragment always first). Ties: closest to the Crane, then top-most, then left-most. No goal left: the nearest remaining obstacle; if none, a seeded random piece"; Board layers & obstacles › Obstacle set and Cell layer model; Rules clarifications › OQ-34 "Distance is straight-line. Hits left: dew = uncovered target cells, shrine = pieces still needed, drop items = items still to collect. A shrine landing counts as the colour it needs most", OQ-38 "Uncovered dew target cells count as remaining obstacles; landing there gives the cell dew".
Blocked by: OQ-43 (a shrine that needs two colours equally; tie case only).
Test cases:
- Crane at (4,4). Goals: brambles (two at hp 3 → 6 hits left) and mummified creatures (one at hp 1 → 1 hit left) → targets the creature's cell.
- Crane at (4,4). Only goal: 2 creatures hp 1 at (2,4) and (6,4) (equal distance, same row) → targets (2,4) (left-most).
- Crane at (4,4). Only goal: 2 creatures hp 1 at (4,1) and (4,7) → targets (4,1) (top-most).
- Crane at (4,4). Only goal: creatures hp 1 at (5,4) and (1,4) → targets (5,4) (closest). All goals already complete, one bramble left at (4,2) → targets (4,2). No obstacle left → the same level seed gives the same target piece on every run.
- Crane at (4,4). Only goal: creatures hp 1 at (6,6) (distance 2.83) and (4,1) (distance 3) → targets (6,6). (Counting steps along rows and columns would have picked (4,1).)
- Crane at (4,4). Goals: dew with 2 uncovered target cells left, at (1,1) and (7,7); bramble goal with 3 hits left → targets (1,1) (2 < 3; equal distance; top-most); (1,1) gets dew.
- Crane at (4,4). Goals: hatchlings with 1 still to collect, at (2,2); bramble hp 2 at (6,6) → targets (2,2); hatchling collected.
- Crane at (4,4). Goals: lantern shrine (OB05) still needing 3 R and 1 B (4 left); brambles with 5 hits left → targets a shrine cell; afterwards the shrine needs 2 R and 1 B.
- Crane at (4,4). All goals complete; only obstacles left: creep goo (OB10) hp 1 under a piece at (4,5) and a bramble at (4,1) → targets (4,5) (goo counts; closest); piece cleared and goo removed.
- Crane at (4,4). All goals complete; only obstacle left: creep moss (OB03) hp 1 at (1,1) → targets (1,1); moss removed.
- Crane at (4,4). All goals complete; only things left: an uncovered dew target cell at (4,6) (distance 2) and a bramble at (4,1) (distance 3) → targets (4,6); (4,6) gets dew.

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
Rule: Swapping a Jade Orb with a Rocket or Firecracker turns every plain piece of the most common plain colour (ties: IR-47) into that special (converted Rockets copy the swapped Rocket's direction) and fires them one after another, lowest first then left-most; the whole combo counts as one special (IR-45).
Applies to: Jade Orb + Bamboo Rocket, Jade Orb + Firecracker (on the cut list, step 5). Not Orb + Crane (IR-27) or Orb + Orb (IR-26).
Source: GDD › Core gameplay › Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires"; Rules clarifications › OQ-12, OQ-14, OQ-24, OQ-27 "Set-off specials fire lowest first, then left-most", OQ-33.
Blocked by: OQ-42 (plain pieces under an overlay). OQ-48 (whether converted specials leave the board at once and fire from their own cells, or stay on the board and can fall before their turn). Tests below keep everything below the converted pieces from being cleared, or check order only.
Test cases:
- Plain pieces only besides the two specials: 20 R (most common). Orb swapped with a Firecracker → the 20 R become Firecrackers and each fires; the Orb and the swapped Firecracker are used up.
- Same, with a 2×2 pillar hp 3 inside the areas of several converted Firecrackers → pillar hp 2.
- Orb at (4,4), column Rocket at (4,5) → every converted Rocket is a column Rocket (IR-16).
- R only at (2,1),(6,1),(2,7); Y, B, G two pieces each; Orb at (4,4), Firecracker at (4,5); every other cell holds a withered bramble (OB02). Swap (4,5)→(4,4) → converted Firecrackers fire in the order (2,7), (2,1), (6,1).
- Plain 18 R, 19 Y, 17 B, 16 G, plus 3 red Rockets on the board → Y is converted (the red Rockets don't count and aren't converted).

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

### IR-31 · A fragment always takes one of the level's goal slots
Rule: On a fragment level the soul fragment is always one of the goals and uses one of the tier's goal slots, never an extra one.
Applies to: Fragment levels 26, 30, 33, 35, 38, 40, 45, 50. (GoalTracker / LevelLoader / validator, not MatchResolver.)
Source: GDD › Core gameplay › "On a fragment level the soul fragment is always one of the goals and uses one of the tier's slots, never an extra one, so a level cannot be won without it"; Technical design › Level format.
Test cases:
- Level 35 (hard, 3–4 goals) lists 4 goals, one of them the fragment → valid. Lists 4 goals plus the fragment as a 5th → validator rejects.
- All non-fragment goals done, fragment not collected → level is not won.

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
Rule: When a stable board has no possible move (no swap that would be accepted and no special to tap), plain pieces and specials are shuffled for free, never moving obstacles, fragments or drop items, so that the result has at least one possible move and no ready-made match.
Applies to: Any stable board. Independent of Feather Fan (IR-35).
Source: GDD › Core gameplay › Rules › "No possible move: free shuffle with a short animation"; Meta & economy › Feather Fan "the free auto-shuffle still happens when no move exists"; Rules clarifications › OQ-22 "Moves only plain pieces and specials, never obstacles, fragments or drop items; must leave at least one valid move and no ready-made matches".
Blocked by: OQ-41 (whether pieces under an overlay are shuffled).
Test cases:
- Moves 8. Stable board of plain pieces with no valid swap → a shuffle event; moves = 8; the shuffled board has at least one valid swap and no match.
- Same, with a bramble at (2,2), a cocoon at (5,5) and a hatchling at (7,1) → all three in the same cells after the shuffle.
- A board where a plain-piece swap and a tappable special both exist → no shuffle.

### IR-51 · Gravity and refill (CHANGED)
Rule: Pieces, specials and drop items first fall straight down into empty cells; then a cell that can't be filled from straight above because a blocker is in the way is filled by a piece sliding in diagonally, from the upper-left first, then the upper-right; new pieces enter at the top playable cell of every column, and spawner cells add extra entry points on levels that have them.
Applies to: Every fall step (IR-17, IR-32). Obstacles don't fall; locked covered pieces don't fall (IR-54).
Source: GDD › Rules clarifications › OQ-19 "Pieces fall straight down; where a cell can't be filled from above because of a blocker, a piece may slide in diagonally. New pieces drop in at the top of each column, or at spawner cells where the level has them" (the row now opens "Pieces locked under an overlay (moss, shutter) don't fall. Other pieces fall straight down"), OQ-35 "Straight falls first, then diagonal slides (upper-left before upper-right). Every column refills at its top playable cell; spawners add extra entry points".
Blocked by: OQ-41 (filling the cell below a locked covered piece), OQ-45 (columns with a non-playable cell in the middle).
Test cases:
- Plain column 4: clear (4,6),(4,7),(4,8) → see IR-32 test 1.
- Bramble (OB02) with 2 layers at (3,2); cells (3,3),(3,4),(3,5) are emptied directly (no match, no special) and the board settles → after the fall no playable cell is empty; the bramble is still at (3,2) (obstacles don't fall) with 2 layers. (Layer hits from a match are IR-14, not this rule.)
- Bramble at (4,3); (4,4) emptied directly → (4,4) is filled by the piece from (3,3) (upper-left), not from (5,3); the piece at (5,3) has not moved; column 3 then falls by one and a new piece enters at (3,0).
- Level with a spawner at (2,0) only; (6,8) emptied directly → pieces at (6,0)–(6,7) move to (6,1)–(6,8); a new piece enters at (6,0).
- (5,0) and (5,1) not playable; (5,8) emptied directly → pieces at (5,2)–(5,7) move to (5,3)–(5,8); a new piece enters at (5,2).

---

## H. Hero boosters (BoosterService, not MatchResolver; listed because they share the hit rules)

### IR-34 · Boosters collect fragments and drop items, never delete them
Rule: Hoof Tap, Tail Slam and Bamboo Dash collect any fragment or drop item they hit and never delete it.
Applies to: Hoof Tap (11), Tail Slam (23), Bamboo Dash (29).
Source: GDD › Interaction rules › "Hero boosters on fragments and drop items | Never deleted. Hoof Tap, Tail Slam and Bamboo Dash collect a fragment or drop item they hit".
Test cases:
- Hoof Tap on a hatchling (OB11) at (4,2) → collected; goal +1.
- Bamboo Dash along row 3 passes a fragment drop item at (6,3) → fragment collected.

### IR-35 · Feather Fan moves pieces only
Rule: Feather Fan reshuffles pieces only and never moves fragments or drop items.
Applies to: Feather Fan (36).
Source: GDD › Interaction rules › "Feather Fan moves pieces only, never fragments or drop items"; Meta & economy › "Reshuffles the board".
Test cases:
- Fragment drop item at (2,3), hatchling at (6,1). Use Feather Fan → both still at (2,3) and (6,1); plain pieces have moved.

### IR-36 · Boosters hit like a special (CHANGED)
Rule: On everything other than fragments and drop items, every booster acts like a special on each cell it covers (IR-09): it clears the piece there and gives one hit to the top obstacle layer, and a multi-cell obstacle takes at most one hit per use (Bamboo Dash's diagonal included).
Applies to: Hoof Tap (one cell of the player's choice), Tail Slam (3×3, one hit to every cell), Bamboo Dash (one full row, column or diagonal).
Source: GDD › Interaction rules › "Hero boosters on everything else | Like a special: one hit per cell, top layer only; a multi-cell obstacle takes at most one hit per use. Bamboo Dash's diagonal follows the same rule"; Meta & economy › Booster unlocks › Hoof Tap "Clears the piece in one cell of the player's choice and gives that cell's top obstacle layer one hit", Tail Slam "one hit to every cell in it"; Rules clarifications › OQ-36 "Every booster clears the piece and gives the top obstacle layer one hit".
Test cases:
- Tail Slam centred on (4,4); 2×2 pillar (OB06) hp 3 covers (4,4),(5,4),(4,5),(5,5) → pillar hp 2.
- Bamboo Dash on the diagonal (0,0)…(8,8) crossing a 1×4 pillar at x=4, y=2–5 → pillar loses 1 layer.
- Hoof Tap on a plain piece with no obstacle layer at (3,3) → piece removed.
- Hoof Tap on R on goo hp 2 at (3,3) → R cleared and goo hp 1 (both in one use).
- Hoof Tap on Y under moss hp 1, on goo hp 1, at (3,3) → Y cleared; moss removed; goo still hp 1.
- Hoof Tap on a bramble (OB02) with 2 layers → bramble 1 layer.
- Tail Slam centred on (4,4); B on goo hp 1 at (5,5) → B cleared and goo cleared.

---

## I. Level flow (GoalTracker / UI, not MatchResolver)

### IR-37 · Continue offer: always shown, at least twice per attempt (CHANGED)
Rule: When moves run out, the "+5 moves for 300 coins" continue is offered whatever the state of the goals (even if they can no longer be reached), and it is offered at least on the first and the second time moves run out in the same attempt.
Applies to: Every level fail by running out of moves.
Source: GDD › Interaction rules › "Continue offer | Always shown after a fail, whether or not the goals can still be reached, and offered at least twice per attempt"; Rules clarifications › OQ-23; Core gameplay › Rules › Fail flow "an optional '+5 moves' for coins, offered at least twice per attempt whatever the board state, then the retry screen"; Meta & economy › Continue "Optional '+5 moves' for 300 coins, offered at least twice per attempt".
Blocked by: OQ-39 (maximum number of offers per attempt; price of later offers; what declining does; a player with fewer than 300 coins). OQ-51 (whether quitting mid-level, which "counts as a fail", also triggers the offer).
Test cases:
- Moves hit 0; the only goal is "collect 5 hatchlings": 1 collected, 1 left on the board, none still to spawn (the goal can't be reached); 500 coins → the continue offer is shown.
- Moves hit 0, goals reachable, 700 coins → offer 1; accept → coins 400, moves 5. Moves hit 0 again → offer 2 is shown; accept → coins 100, moves 5.

### IR-38 · Quitting mid-level counts as a fail
Rule: Quitting mid-level counts as a fail: it costs a life (except on chapter finales) and counts as that level's first try.
Applies to: Every level 1–50.
Source: GDD › Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try"; Meta & economy › Lives.
Blocked by: OQ-51 (whether the continue offer, "always shown after a fail", is shown after a quit). Tests below check lives and the attempt log only.
Test cases:
- Level 12, 5 lives, first attempt. Quit after 3 moves → lives 4; attempt logged as a fail and as the first try.
- Level 25 (finale), 3 lives. Quit → lives 3; attempt logged as a fail.
