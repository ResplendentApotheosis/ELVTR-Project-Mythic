# Zodiac Forest: Interaction rules spec

Derived only from `docs/gdd/zodiac-forest-gdd-final.md` (the GDD wins over this file). IDs are permanent: never renumber; a removed rule is marked `RETIRED` and kept. Gaps and conflicts live in `spec/open_questions.md` (OQ-xx), never here. New rules are numbered after IR-38 but filed in the section they belong to (see the index).

**Conventions used in test cases**
- Coordinates are `(x, y)`; `x` = column from the left, `y` = row from the top (row 0 is the top row), matching the level JSON schema.
- "Lowest" = largest `y`; "top-most" = smallest `y`; "left-most" = smallest `x`.
- Colours: R = red peach, Y = yellow bell, B = blue fan, G = green leaf. A bare letter is a plain piece.
- "Swap A→B" = the player drags the piece at A into B. B is the swap's **target cell** ("the cell the player moved into"); A is the **start cell**.
- "Adjacent" / "next to" always means directly above, below, left or right, never diagonal (GDD › Rules clarifications › OQ-08).
- "Hit" = one hit to the top **obstacle** layer of a cell (overlay, then content blocker or container, then underlay). Pieces are not obstacle layers (IR-09).
- Unless a test says otherwise, the board is 9×9, fully playable, and the rest of the board contains no match before or after the action.
- Where part of a rule depends on an open question, the rule lists it under "Blocked by" and only the unblocked test cases are written.

**Index**

| Section | Rules |
|---|---|
| A. Swaps, taps and moves | IR-01, IR-02, IR-39, IR-52 |
| B. Match detection and special creation | IR-03 to IR-08, IR-40, IR-42, IR-43, IR-50 |
| C. Damage to layers and obstacles | IR-09 to IR-15, IR-44, IR-45 |
| D. Special effects | IR-16 to IR-21, IR-41, IR-47, IR-48, IR-49 |
| E. Combos | IR-22 to IR-27, IR-46 |
| F. Soul fragments and drop items | IR-28 to IR-31 |
| G. Gravity, refill, cascades, shuffle | IR-32, IR-33, IR-51 |
| H. Hero boosters | IR-34 to IR-36 |
| I. Level flow | IR-37, IR-38 |

---

## A. Swaps, taps and moves

### IR-01 · A swap of two plain pieces that makes no match snaps back
Rule: Swapping two adjacent plain pieces uses one move if it makes a match; if it makes no match it snaps back and uses no move (snap-back applies only to two plain pieces).
Applies to: Swaps between two plain pieces. Special + plain piece: IR-39 (and IR-18 for the Orb). Special + special: IR-22 to IR-27. What can be swapped at all: IR-52.
Source: GDD › Core gameplay › Rules › "Swap two adjacent pieces; a swap that makes no match snaps back (no move used)."; Rules clarifications › OQ-03 "Snap-back applies only to two plain pieces".
Test cases:
- Moves 20. R at (2,4),(3,4), Y at (4,4), R at (4,5). Swap (4,5)→(4,4) → R at (2,4),(3,4),(4,4) clears; moves = 19.
- Moves 20. Swap two plain pieces that form no line of 3 and no 2×2 → board identical to before; moves = 20; an "invalid swap" event is returned.

### IR-02 · Tapping a special fires it and costs a move
Rule: Tapping a special fires it and uses one move; tapping anything else does nothing.
Applies to: Bamboo Rocket, Firecracker, Paper Crane, Jade Orb (Orb tap effect: IR-19).
Source: GDD › Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Interaction rules › "Tapping a Jade Orb … costs a move like any tap".
Test cases:
- Moves 10. Tap a Firecracker at (4,4) → it fires (IR-17); moves = 9.
- Moves 10. Tap a plain piece → nothing happens; moves = 10.

### IR-39 · A special swapped with a plain piece fires and uses a move (NEW)
Rule: Swapping a Bamboo Rocket, Firecracker or Paper Crane with an adjacent plain piece is never snapped back: the swap uses one move and the special fires, whether or not the swap also makes a match.
Applies to: Rocket, Firecracker or Crane + plain piece. Jade Orb + plain piece: IR-18. Special + drop item: OQ-30.
Source: GDD › Rules clarifications › OQ-03 "The special fires and the swap costs a move. Snap-back applies only to two plain pieces".
Blocked by: OQ-26 (which cell the special fires from after the swap, and the order when the swap also makes a match). Tests below avoid both.
Test cases:
- Moves 10. Firecracker at (4,4), Y at (5,4); swap (5,4)→(4,4) makes no match → swap accepted (no snap-back); moves = 9; exactly one Firecracker fire event (two blast events, IR-17).
- Moves 10. Paper Crane at (4,4), G at (4,3); swap (4,4)→(4,3) makes no match → moves = 9; the Crane fires (crane target event, IR-49).
- Moves 10. Same set-up with two plain pieces instead → snaps back; moves = 10 (IR-01).

### IR-52 · What can be swapped (NEW)
Rule: A swap is only accepted between two orthogonally adjacent cells that each hold a plain piece, a special or a drop item; swaps involving an obstacle, a cocooned fragment or an empty cell, and diagonal swaps, are refused and change nothing (no move used).
Applies to: Every swap attempt.
Source: GDD › Rules clarifications › OQ-21 "Any two orthogonally adjacent pieces, including specials and drop items. Not obstacles, cocooned fragments or empty cells".
Blocked by: OQ-29 (pieces under an overlay), OQ-30 (drop item swaps that make no match, or with a special).
Test cases:
- Moves 10. Withered bramble (OB02) at (4,4), R at (4,5). Swap (4,5)→(4,4) → refused; board unchanged; moves = 10.
- Moves 10. Swap (3,3)→(4,4) (diagonal) → refused; board unchanged; moves = 10.
- Moves 10. Cocoon with a fragment (OB07) at (2,2), Y at (3,2). Swap (3,2)→(2,2) → refused; moves = 10.
- Moves 10. Lost hatchling (OB11) at (4,4); R at (2,4),(3,4) and (4,5). Swap (4,5)→(4,4) → accepted; R at (2,4),(3,4),(4,4) clears; the hatchling is now at (4,5) (then falls, IR-51); moves = 9.

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
Applies to: Plain pieces (player or cascade matches). Rocket effect: IR-16. Rockets not made from a line (Orb + Rocket, finale): OQ-24.
Source: GDD › Core gameplay › Special pieces › "4 in a line | Bamboo Rocket"; Rules clarifications › OQ-01 "a horizontal 4 clears its row, a vertical 4 clears its column. Its icon shows the direction".
Test cases:
- R at (1,4),(2,4),(4,4), Y at (3,4), R at (3,5). Swap (3,5)→(3,4) → 4 pieces clear; one red **row** Rocket at (3,4).
- R at (5,1),(5,2),(5,4), Y at (5,3), R at (4,3). Swap (4,3)→(5,3) → 4 pieces clear; one red **column** Rocket at (5,3).

### IR-06 · An L or T of five makes a Firecracker
Rule: Five same-colour pieces in an L or T shape (a line of 3 and a line of 3 at right angles sharing one cell, which is the end of at least one of the lines) make a Firecracker.
Applies to: Plain pieces. Larger mixed shapes: IR-08. A "+" shape (shared cell in the middle of both lines): OQ-28. Placement: IR-40.
Source: GDD › Core gameplay › Special pieces › "L or T shape (5) | Firecracker"; Rules clarifications › OQ-06 "Mixed shapes follow the shape-priority rule".
Blocked by: OQ-28 ("+" shape only).
Test cases:
- L by swap: R at (2,2),(2,3),(3,4),(4,4), Y at (2,4), R at (1,4). Swap (1,4)→(2,4) → 5 pieces clear; one red Firecracker at (2,4).
- T by cascade: R lands at (2,2),(3,2),(4,2),(3,3),(3,4) → 5 pieces clear; one red Firecracker at (3,2) (IR-40 crossing cell).

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

### IR-40 · Where a new special appears (NEW)
Rule: A special made by the player's swap appears on the swap's target cell; a special made by a cascade appears on the lowest, then left-most, cell of the match, except an L or T, which puts it on the crossing cell (the cell shared by its two lines).
Applies to: IR-04 to IR-07 and IR-42.
Source: GDD › Rules clarifications › OQ-02 "On the cell the player moved into; in cascades, on the lowest then leftmost cell of the match (the crossing cell for an L or T)".
Blocked by: OQ-25 (a player-made match that does not include the target cell, e.g. the second match of IR-43).
Test cases:
- Swap (3,5)→(3,4) completes R at (1,4),(2,4),(3,4),(4,4) → Rocket at (3,4).
- R at (6,2),(6,3),(6,5), Y at (6,4), R at (5,4). Swap (5,4)→(6,4) → column Rocket at (6,4) (the target cell, not the lowest cell (6,5)).
- Cascade: R lands at (2,6),(3,6),(4,6),(5,6) → row Rocket at (2,6). Cascade: R lands at (7,1),(7,2),(7,3),(7,4) → column Rocket at (7,4).
- Cascade: Y 2×2 lands at (5,2),(6,2),(5,3),(6,3) → yellow Crane at (5,3).

### IR-42 · Cascade matches make specials (NEW)
Rule: Matches made by falling pieces make specials by exactly the same shape, direction and priority rules as player matches.
Applies to: Every cascade match (IR-32). Placement: IR-40.
Source: GDD › Rules clarifications › OQ-05 "Make specials by the same rules as player matches".
Test cases:
- A fall lines up B at (0,8),(1,8),(2,8),(3,8) → those 4 clear and one blue row Rocket appears at (0,8), without a move being used.
- A fall lines up G at (4,2)…(4,6) (vertical 5) → one Jade Orb at (4,6).

### IR-43 · One swap making two matches: both resolve, each makes its own special (NEW)
Rule: When one swap makes two separate matches (one through each swapped piece), both matches clear and each makes its own special by IR-04 to IR-08.
Applies to: Player swaps that create a match at both the start and the target cell.
Source: GDD › Rules clarifications › OQ-07 "Both resolve, and each can make its own special".
Blocked by: OQ-25 (where the special from the start-cell match appears).
Test cases:
- R at (3,3); Y at (4,3); R at (4,1),(4,2),(4,4); Y at (3,4),(3,5). Swap (3,3)→(4,3) → R at (4,1),(4,2),(4,3),(4,4) (vertical 4) and Y at (3,3),(3,4),(3,5) (vertical 3) both clear; one red column Rocket at (4,3); no special from the Y match; moves −1.
- A swap whose start-cell match is a 4-line and whose target-cell match is a 4-line → 8 pieces clear and exactly 2 Rockets are made (position of the second: OQ-25).

### IR-50 · Rockets, Firecrackers and Cranes keep a colour; the Jade Orb has none (NEW)
Rule: A Bamboo Rocket, Firecracker or Paper Crane keeps the colour of the match that made it and matches like a plain piece of that colour (firing when matched, IR-21); a Jade Orb has no colour and is never part of a match.
Applies to: All specials.
Source: GDD › Rules clarifications › OQ-18 "Rockets, Firecrackers and Cranes keep the colour they were made from and match like normal pieces. The Jade Orb has no colour".
Blocked by: OQ-26 (order between the match clearing and the special firing).
Test cases:
- A red row Rocket at (3,4); R at (1,4),(2,4) after a swap → a 3-match forms, the 3 cells clear and the Rocket fires (row 4 cleared).
- Jade Orb at (3,4); R at (1,4),(2,4),(4,4),(5,4) → no match through (3,4); the Orb stays.
- A Crane made from a Y 2×2 reports colour Y.

---

## C. Damage to layers and obstacles

### IR-09 · A special clears the piece in each cell it covers and hits the top obstacle layer once (CHANGED)
Rule: For each cell a special covers, it clears the piece in that cell (if any) and gives one hit to the top obstacle layer there: the overlay if there is one, else the content blocker or container, else the underlay (goo or dew).
Applies to: Every special and combo effect. Fragments and drop items are never cleared (IR-28). Specials in covered cells fire (IR-41). A Jade Orb covers every cell whose piece it clears (IR-18). Boosters: IR-36.
Source: GDD › Interaction rules › "What a special hits | Each cell it covers takes one hit, on the top layer only (overlay, then content, then underlay)"; Rules clarifications › OQ-09 "Pieces are not obstacle layers. A special clears the piece and gives one hit to the top obstacle layer in that cell; with no overlay or blocker, the underlay (goo or dew) takes the hit".
Blocked by: OQ-29 (a covered piece whose overlay survives the hit), OQ-31 (what a hit does to healing dew).
Test cases:
- Row Rocket fires along row 3; (5,3) holds a withered bramble (OB02) with 2 layers → bramble has 1 layer.
- Row Rocket along row 3; (2,3) holds R on creep goo (OB10) hp 2 → R cleared; goo hp 1.
- Row Rocket along row 3; (6,3) holds Y under creep moss (OB03) hp 1 → Y cleared; moss removed.
- Row Rocket along row 3; (4,3) holds B under moss hp 1, on goo hp 1 → B cleared; moss removed; goo still hp 1.

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
Applies to: Every obstacle inside the Firecracker's 3×3 area, single- or multi-cell. Firecracker + Firecracker: IR-24 with IR-45.
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
Applies to: OB02 withered bramble, OB07 mummified creature / creep cocoon, OB03 creep moss, OB06 petrified pillar, OB12 frozen idol, and overlays (layer 3). Not underlays (IR-15). Pieces cleared by a special never count as a match (IR-44).
Source: GDD › Board layers & obstacles › Cell layer model › "3 · Overlay … Cleared by Adjacent matches", "2 · Content … Matching / adjacent matches / specials"; Obstacle set › OB02 "Match next to it", OB07 "Match next to it to unwrap", OB03 "Match next to it to clear", OB06 "Ground down by adjacent matches"; Rules clarifications › OQ-08 "One hit to that obstacle. Only up, down, left and right count as 'next to', never diagonals", OQ-10 "Only matches hit neighbours".
Test cases:
- Bramble (OB02) with 3 layers at (4,3). A 3-match at (3,4),(4,4),(5,4) → bramble has 2 layers.
- Bramble with 1 layer at (4,3). A 3-match at (5,4),(6,4),(7,4) (touches only diagonally at (5,4)) → bramble unchanged.
- Pillar (OB06) 1×4 at x=4, y=2–5, hp 3. A 3-match at (5,2),(5,3),(5,4) runs alongside 3 of its cells → pillar hp 2.
- Brambles with 2 layers at (3,3) and (5,3). A 3-match at (3,4),(4,4),(5,4) → both brambles have 1 layer.
- Mummified creature (OB07) hp 1 at (2,2). A 3-match at (3,1),(3,2),(3,3) → creature freed (goal +1).

### IR-15 · An underlay is hit by a match on top of it, or by a special with nothing above it (CHANGED)
Rule: An underlay takes one hit when a match is made on top of it, or when a special covers its cell and there is no overlay or blocker above it (IR-09).
Applies to: OB10 creep goo (hp 1–3 per the brief's `underlay` field). OB04 healing dew: what a hit does to dew is OQ-31.
Source: GDD › Board layers & obstacles › Cell layer model › "1 · Underlay … Cleared by Matching on top of it"; Obstacle set › OB10 "Make a match on top to clear it"; Rules clarifications › OQ-09 "with no overlay or blocker, the underlay (goo or dew) takes the hit".
Blocked by: OQ-31 (dew cases only).
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

---

## D. Special effects

### IR-16 · A Bamboo Rocket clears its full row or its full column (CHANGED)
Rule: A row Rocket hits every cell of its row and a column Rocket hits every cell of its column, as set when it was made (IR-05).
Applies to: Bamboo Rocket. Hits follow IR-09/IR-10. Rockets made by Jade Orb + Rocket: OQ-24.
Source: GDD › Core gameplay › Special pieces › "Bamboo Rocket | Clears its full row or column"; Rules clarifications › OQ-01.
Blocked by: OQ-24 (converted Rockets only).
Test cases:
- Tap a row Rocket at (4,4) on a plain 9×9 board → all 9 cells of row 4 cleared, nothing else.
- Tap a column Rocket at (4,4) on a plain 9×9 board → all 9 cells of column 4 cleared, nothing else.

### IR-17 · A Firecracker blasts the same 3×3 twice, with a fall in between (CHANGED)
Rule: A Firecracker blasts the 3×3 area centred on its cell, then pieces fall, then it blasts the same 3×3 (same centre cell) a second time; obstacle hits follow IR-12.
Applies to: Firecracker. Cells of the 3×3 that are off the board or not playable are skipped.
Source: GDD › Core gameplay › Special pieces › "Firecracker | 3×3 blast, twice"; Rules clarifications › OQ-11 "Hits the same centre cell after pieces have fallen".
Blocked by: OQ-32 (whether refill and cascade matches happen between the blasts). Tests below avoid both.
Test cases:
- Tap a Firecracker at (4,4) on a plain 9×9 board with no matches forming → blast 1 clears (3–5, 3–5); pieces from (3–5, 0–2) fall into (3–5, 3–5); blast 2 clears those 9 → 18 pieces cleared in total; events in order: blast 1, fall, blast 2.
- Firecracker at (0,0) → each blast covers only (0–1, 0–1).

### IR-18 · Jade Orb swapped with a plain piece clears that colour (CHANGED)
Rule: A Jade Orb swapped with a plain piece uses one move and clears every piece of that piece's colour, covering every cell whose piece it clears (IR-09).
Applies to: Jade Orb + plain piece. Orb + Rocket/Firecracker: IR-25. Orb + Orb: IR-26. Orb + Crane: IR-27. Orb + drop item: OQ-30.
Source: GDD › Core gameplay › Special pieces › "Jade Orb | Clears every piece of the colour it's swapped with"; Rules clarifications › OQ-03 "A Jade Orb swapped with a plain piece clears that piece's colour", OQ-09 "A Jade Orb covers every cell whose piece it clears".
Blocked by: OQ-33 (whether coloured specials and covered pieces count as "pieces of that colour").
Test cases:
- Moves 15. Plain board, no obstacles, no specials. Orb at (4,4) swapped with B at (5,4) → every B cleared; the Orb is used up; moves = 14.
- Same, with a B on goo hp 1 at (1,1) → that B cleared and the goo cleared.
- Same, with bramble (OB02) at (2,2) next to a cleared B → bramble unchanged (IR-44).

### IR-19 · Tapping a Jade Orb clears the most common colour (CHANGED)
Rule: A tapped Jade Orb uses one move and clears every piece of the most common colour on the board, ties broken by IR-47.
Applies to: Jade Orb tap; also the Orb's effect in Orb + Crane (IR-27).
Source: GDD › Interaction rules › "Tapping a Jade Orb | Clears every piece of the most common colour on the board; costs a move like any tap"; Rules clarifications › OQ-14.
Blocked by: OQ-33 (what counts toward "most common").
Test cases:
- Moves 10. Plain pieces only: 20 R, 18 Y, 17 B, 16 G. Tap Orb → all 20 R cleared; moves = 9.
- Plain pieces only: 18 R, 18 B, 17 Y, 17 G → R cleared (tie, IR-47).

### IR-20 · The Paper Crane telegraphs its target, fragment first (CHANGED)
Rule: When a Paper Crane fires, it chooses its target by IR-49 (an unfreed soul fragment always first) and shows it with a dotted path before it flies; it then takes off and lands by IR-48.
Applies to: Paper Crane (IR-04).
Source: GDD › Interaction rules › "Where the Paper Crane flies | To the remaining goal with the fewest hits left; an unfreed soul fragment always comes first. Dew goal: an uncovered target cell. Lantern shrine: counts as one piece of a colour it still needs"; Special pieces › "its target is shown with a dotted path before it flies".
Test cases:
- Goals: bramble (OB02) hp 1 and fragment in a cocoon hp 3. Crane fires → target is the cocoon, even though the bramble has fewer hits left.
- Every Crane event list contains, in order: crane target (target cell), crane take-off (start cell), crane landing (target cell).

### IR-21 · When a special fires (CHANGED)
Rule: A special fires when it is part of a match (IR-50), when it is swapped (IR-18, IR-22 to IR-27, IR-39), when it is tapped (IR-02), or when another special covers its cell (IR-41).
Applies to: All four specials (the Jade Orb is never matched).
Source: GDD › Core gameplay › Rules › "Specials fire when matched, swapped or tapped (tap costs a move)"; Rules clarifications › OQ-03, OQ-04, OQ-18.
Blocked by: OQ-26 (order between a match and the special it sets off).
Test cases:
- A red Firecracker in an R 3-match → the Firecracker fires (two blast events).
- Tap → see IR-02. Swap → see IR-39. Chain → see IR-41.

### IR-41 · A special hit by another special fires too (chain) (NEW)
Rule: When a special's effect covers a cell holding another special, that special also fires, after the first special has completely finished; each set-off special is a separate special for the one-hit rules.
Applies to: All specials and combos as the first special; Rocket, Firecracker and Crane as the set-off special. A set-off Jade Orb, the order of several set-off specials, and Orb + Orb: OQ-27.
Source: GDD › Rules clarifications › OQ-04 "It fires too (a chain), after the first special finishes".
Blocked by: OQ-27 (cell a set-off special fires from after pieces have fallen; order of several; set-off Orb; Orb + Orb).
Test cases:
- Tap a row Rocket at (1,4); a column Rocket at (6,4) → row 4 cleared, then column 6 cleared; every event of the first Rocket comes before any event of the second.
- Same, with bramble (OB02) 2 layers at (6,7) → bramble has 1 layer (hit by the set-off Rocket).
- Tap a column Rocket at (4,0); a Crane at (4,6) → after column 4 is cleared, the Crane fires (crane target event).

### IR-47 · Colour ties are broken red, yellow, blue, green (NEW)
Rule: When two or more colours tie for "most common colour", the first in the order red, yellow, blue, green is chosen.
Applies to: Jade Orb tap (IR-19), Jade Orb + special (IR-25), Jade Orb + Crane (IR-27).
Source: GDD › Rules clarifications › OQ-14 "Broken in a fixed order: red, yellow, blue, green".
Blocked by: OQ-33 (which pieces are counted).
Test cases:
- Plain pieces only: 18 R, 18 Y, 17 B, 16 G → R.
- Plain pieces only: 10 R, 19 Y, 19 B, 10 G → Y.
- Plain pieces only: 12 R, 12 Y, 20 B, 20 G → B.

### IR-48 · Paper Crane take-off and landing (NEW)
Rule: When a Crane flies, it clears its own starting cell as it takes off, then at its target cell either collects the fragment or drop item there, or gives that cell one hit as a special does (IR-09).
Applies to: Every Crane flight (tap, match, swap, chain, IR-27).
Source: GDD › Rules clarifications › OQ-16 "Gives one hit to its target cell, or collects the fragment or drop item there. It also clears its own starting cell when it takes off"; Interaction rules › "a drop item still has to reach the bottom row unless a Crane or Orb + Orb collects it".
Blocked by: OQ-34 (whether take-off also hits an underlay under the Crane), OQ-31 (landing on a dew target).
Test cases:
- Crane at (1,7); only goal: bramble (OB02) hp 2 at (6,2) → bramble hp 1; (1,7) is emptied (then refilled, IR-51).
- Only goal: lost hatchling (OB11) at (5,3) → hatchling collected; goal +1; it is not destroyed.
- Only goal: fragment in a cocoon hp 1 at (4,1) → cocoon freed and fragment collected (IR-29).

### IR-49 · Paper Crane targeting order and tie-breaks (CHANGED)
Rule: The Crane aims at one cell of an unfinished goal: an unfreed fragment first, otherwise the goal with the fewest hits left; any tie (between goals or between cells) goes to the cell closest to the Crane, then the top-most, then the left-most; with no goal left it aims at the nearest cell holding any remaining obstacle on any layer (overlay, content or underlay; same tie-breaks), and with no obstacle left at a piece picked by the level's seeded random number generator.
Applies to: Every Crane flight. Dew goals aim at an uncovered target cell; lantern shrines count the landing as one piece of a colour still needed. "Obstacle" means anything in the GDD's Obstacle set, so creep moss (OB03, overlay) and creep goo (OB10, underlay) both count for the no-goal case; the landing then hits that cell's top layer (IR-48 → IR-09). Healing dew (OB04) as a no-goal target: not decided, see OQ-38.
Source: GDD › Interaction rules › "Where the Paper Crane flies"; Rules clarifications › OQ-17 "Aims at one obstacle cell of the goal with the fewest hits left (an unfreed fragment always first). Ties: closest to the Crane, then top-most, then left-most. No goal left: the nearest remaining obstacle; if none, a seeded random piece"; Board layers & obstacles › Obstacle set (lists OB03 Creep moss and OB10 Creep goo as obstacles) and Cell layer model (overlay, content, underlay).
Blocked by: OQ-34 (distance measure; "hits left" for dew, shrine and drop-item goals; which colour a shrine landing counts as), OQ-38 (dew in the no-goal case). Tests below use distances that are equal or unequal under any measure.
Test cases:
- Crane at (4,4). Goals: brambles (two at hp 3 → 6 hits left) and mummified creatures (one at hp 1 → 1 hit left) → targets the creature's cell.
- Crane at (4,4). Only goal: 2 creatures hp 1 at (2,4) and (6,4) (equal distance, same row) → targets (2,4) (left-most).
- Crane at (4,4). Only goal: 2 creatures hp 1 at (4,1) and (4,7) → targets (4,1) (top-most).
- Crane at (4,4). Only goal: creatures hp 1 at (5,4) and (1,4) → targets (5,4) (closest). All goals already complete, one bramble left at (4,2) → targets (4,2). No obstacle left → the same level seed gives the same target piece on every run.
- Crane at (4,4). All goals complete; only obstacles left: creep goo (OB10) hp 1 under a piece at (4,5) and a bramble at (4,1) → targets (4,5) (goo counts; closest); piece cleared and goo removed.
- Crane at (4,4). All goals complete; only obstacle left: creep moss (OB03) hp 1 at (1,1) → targets (1,1); moss removed.

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
Rule: Swapping two Firecrackers blasts the 5×5 area centred on the swap's target cell twice, and the whole combo gives any single obstacle at most one hit.
Applies to: Firecracker + Firecracker (on the cut list, step 5).
Source: GDD › Core gameplay › Combos › "Firecracker + Firecracker | 5×5 double blast"; Rules clarifications › OQ-12, OQ-13.
Blocked by: OQ-32 (timing of the second 5×5 blast and what happens between blasts; piece-count tests only).
Test cases:
- Firecrackers at (4,4) and (4,5). Swap (4,5)→(4,4) → first blast covers (2–6, 2–6); two blast events.
- Same, with frozen idol (OB12) 2 hits left at (2,2) → idol 1 hit left.

### IR-25 · Jade Orb + special: the most common colour becomes that special (CHANGED)
Rule: Swapping a Jade Orb with a Rocket or Firecracker turns every piece of the most common colour (ties: IR-47) into that special and fires them all, and the whole combo counts as one special (IR-45).
Applies to: Jade Orb + Bamboo Rocket, Jade Orb + Firecracker (on the cut list, step 5). Not Orb + Crane (IR-27) or Orb + Orb (IR-26).
Source: GDD › Core gameplay › Combos › "Jade Orb + special | Every piece of the most common colour becomes that special and fires"; Rules clarifications › OQ-12, OQ-14.
Blocked by: OQ-24 (direction of the converted Rockets), OQ-27 (firing order), OQ-33 (what counts toward "most common").
Test cases:
- Plain pieces only besides the two specials: 20 R (most common). Orb swapped with a Firecracker → the 20 R become Firecrackers and each fires; the Orb and the swapped Firecracker are used up.
- Same, with a 2×2 pillar hp 3 inside the areas of several converted Firecrackers → pillar hp 2.

### IR-26 · Jade Orb + Jade Orb clears the whole board (CHANGED)
Rule: Swapping two Jade Orbs clears every piece on the board, collects every collectible goal item (fragments included) and hits every obstacle once.
Applies to: Jade Orb + Jade Orb. A multi-cell obstacle takes one hit in total (IR-10, a combo is one special). Cells holding two obstacle layers (an overlay over an underlay, e.g. moss over goo): not decided, see OQ-37; do not test or rely on either reading until the owner answers.
Source: GDD › Core gameplay › Combos › "Jade Orb + Jade Orb | Clears the whole board"; Interaction rules › "Jade Orb + Jade Orb | Clears the whole board, collects every collectible goal item (fragments included) and hits every obstacle once"; "Obstacles bigger than one cell | Take at most one hit per special"; Rules clarifications › OQ-12 "A combo counts as one special".
Blocked by: OQ-27 (whether other specials on the board fire when cleared), OQ-37 (stacked layers in one cell).
Test cases:
- Board with a lost hatchling (OB11) at (3,2) and a fragment drop item at (6,1) → both collected (goal counters +1 each), neither is "destroyed".
- Bramble (OB02) with 3 layers at (1,1); 2×2 pillar (OB06) hp 3 → bramble has 2 layers, pillar hp 2.
- Every plain piece on the board is cleared.
- Creep moss (OB03) hp 2 alone at (2,5); creep goo (OB10) hp 2 under a plain piece at (7,5) → moss hp 1; goo hp 1. (Single-layer cells only; stacked cells wait for OQ-37.)

### IR-27 · Crane swapped with a special: no combo, the other special first, then the Crane (CHANGED)
Rule: A Paper Crane swapped with any other special is never refused, uses one move and makes no combo: the other special fires first (a Jade Orb clears the most common colour, as for a tap), then the Crane flies once to whatever goal is left.
Applies to: Crane + Rocket, Crane + Firecracker, Crane + Jade Orb, Crane + Crane. (The Crane + special combo is out of scope for the MVP; this rule is what happens instead.)
Source: GDD › Interaction rules › "Crane swapped with another special (Jade Orb included) | No combo in the MVP and never refused: the other special fires first, then the Crane flies to whatever goal is left"; Rules clarifications › OQ-15 "The Orb clears the most common colour (as for a tap), then the Crane flies".
Blocked by: OQ-26 (which cell the other special fires from), OQ-34 (which Crane goes first in Crane + Crane).
Test cases:
- Moves 12. Crane at (4,4), Firecracker at (4,5); swap (4,5)→(4,4) → accepted; moves = 11; every Firecracker event comes before any Crane event; no combo event; the Crane flies exactly once.
- Goals: bramble hp 1 at (5,4) (inside the Firecracker's area whichever of the two cells it fires from) and a mummified creature hp 1 at (0,0). Same swap → the Firecracker clears the bramble, then the Crane targets (0,0).
- Plain pieces: 20 R, 18 Y, 17 B, 16 G. Orb swapped with a Crane → all R cleared, then the Crane flies.

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
Applies to: Every resolve after a swap, tap, combo or booster.
Source: GDD › Core gameplay › Rules › "Pieces fall, new ones drop from the top, cascades chain automatically."; Rules clarifications › OQ-05, OQ-19.
Test cases:
- Plain column 4: clear (4,6),(4,7),(4,8) → pieces formerly at (4,0)–(4,5) now at (4,3)–(4,8); 3 new pieces at (4,0)–(4,2); no empty cells.
- A fall creates a new R line of 3 → it clears in the same resolve without another swap and without using a move; the board ends with no matches.

### IR-33 · No possible move: free shuffle (CHANGED)
Rule: When a stable board has no possible move (no swap that would be accepted and no special to tap), plain pieces and specials are shuffled for free, never moving obstacles, fragments or drop items, so that the result has at least one possible move and no ready-made match.
Applies to: Any stable board. Independent of Feather Fan (IR-35).
Source: GDD › Core gameplay › Rules › "No possible move: free shuffle with a short animation"; Meta & economy › Feather Fan "the free auto-shuffle still happens when no move exists"; Rules clarifications › OQ-22 "Moves only plain pieces and specials, never obstacles, fragments or drop items; must leave at least one valid move and no ready-made matches".
Test cases:
- Moves 8. Stable board of plain pieces with no valid swap → a shuffle event; moves = 8; the shuffled board has at least one valid swap and no match.
- Same, with a bramble at (2,2), a cocoon at (5,5) and a hatchling at (7,1) → all three in the same cells after the shuffle.
- A board where a plain-piece swap and a tappable special both exist → no shuffle.

### IR-51 · Gravity and refill (NEW)
Rule: Pieces, specials and drop items fall straight down into empty cells; a cell that can't be filled from straight above because a blocker is in the way may be filled by a piece sliding in diagonally; new pieces enter at the top of each column, or at spawner cells on levels that have them.
Applies to: Every fall step (IR-17, IR-32). Obstacles don't fall.
Source: GDD › Rules clarifications › OQ-19 "Pieces fall straight down; where a cell can't be filled from above because of a blocker, a piece may slide in diagonally. New pieces drop in at the top of each column, or at spawner cells where the level has them".
Blocked by: OQ-35 (which diagonal is tried first and when slides happen; which columns refill on spawner levels; entry point of a column whose top cell is not playable).
Test cases:
- Plain column 4: clear (4,6),(4,7),(4,8) → see IR-32 test 1.
- Bramble (OB02) with 2 layers at (3,2); cells (3,3),(3,4),(3,5) are emptied directly (no match, no special) and the board settles → after the fall no playable cell is empty; the bramble is still at (3,2) (obstacles don't fall) with 2 layers. (Layer hits from a match are IR-14, not this rule.)

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

### IR-36 · Boosters hit like a special
Rule: On everything other than fragments and drop items, a booster hits like a special: one hit per cell, top layer only, and a multi-cell obstacle takes at most one hit per use (Bamboo Dash's diagonal included).
Applies to: Hoof Tap (one tile: a piece, or the top layer of one cell), Tail Slam (3×3, one hit to every cell), Bamboo Dash (one full row, column or diagonal).
Source: GDD › Interaction rules › "Hero boosters on everything else | Like a special: one hit per cell, top layer only; a multi-cell obstacle takes at most one hit per use. Bamboo Dash's diagonal follows the same rule"; Meta & economy › Booster unlocks.
Blocked by: OQ-36 (a cell holding both a piece and an obstacle layer: does a booster clear the piece and hit the layer, as a special now does under IR-09?).
Test cases:
- Tail Slam centred on (4,4); 2×2 pillar (OB06) hp 3 covers (4,4),(5,4),(4,5),(5,5) → pillar hp 2.
- Bamboo Dash on the diagonal (0,0)…(8,8) crossing a 1×4 pillar at x=4, y=2–5 → pillar loses 1 layer.
- Hoof Tap on a plain piece with no obstacle layer at (3,3) → piece removed.

---

## I. Level flow (GoalTracker / UI, not MatchResolver)

### IR-37 · Continue offer: one per attempt, hidden when goals can't be reached
Rule: After moves run out, one optional "+5 moves" continue is offered for 300 coins per attempt, and it is not shown when the remaining goals can no longer be reached.
Applies to: Every level fail by moves.
Source: GDD › Interaction rules › "Continue offer | Not shown when the remaining goals can no longer be reached"; Core gameplay › Fail flow; Meta & economy › "Continue | One optional "+5 moves" for 300 coins per attempt; no second pop-up".
Blocked by: OQ-23 (what "can no longer be reached" means).
Test cases:
- Moves hit 0, goals reachable, 500 coins → one continue offer; accept → coins 200, moves 5. Moves hit 0 again → retry screen, no second offer.

### IR-38 · Quitting mid-level counts as a fail
Rule: Quitting mid-level counts as a fail: it costs a life (except on chapter finales) and counts as that level's first try.
Applies to: Every level 1–50.
Source: GDD › Interaction rules › "Quitting mid-level | Counts as a fail: costs a life (except on finales) and counts as that level's first try"; Meta & economy › Lives.
Test cases:
- Level 12, 5 lives, first attempt. Quit after 3 moves → lives 4; attempt logged as a fail and as the first try.
- Level 25 (finale), 3 lives. Quit → lives 3; attempt logged as a fail.
