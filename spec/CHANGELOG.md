# spec/ changelog

- 2026-11-27 · IR-01 to IR-38 added · First spec from the GDD's Core gameplay, Interaction rules, Board layers, Soul fragments and Meta sections, for the MatchResolver build (plus the booster and level-flow rows of the Interaction rules table).
- 2026-11-27 · OQ-01 to OQ-23 opened · Gaps and conflicts found while writing the MatchResolver rules; owner to decide.
- 2026-11-27 · OQ-01 to OQ-22 marked ANSWERED · Owner answers added to GDD › Rules clarifications; OQ-23 stays open.
- 2026-11-27 · IR-01, IR-05, IR-06, IR-07, IR-09, IR-10, IR-12 to IR-27, IR-30, IR-32, IR-33 changed · Applied GDD › Rules clarifications OQ-01 to OQ-22 (direction, 6+ lines, pieces vs obstacle layers, one hit per match, second blast timing, combo centre and one-hit rule, Orb + Crane, drop-item exits, shuffle); removed resolved "Blocked by" lines; tests made exact.
- 2026-11-27 · IR-39 to IR-52 added · New rules for clarifications OQ-02 to OQ-05, OQ-07, OQ-10, OQ-12 to OQ-14, OQ-16 to OQ-19, OQ-21 (special + plain swap, placement, chains, cascade specials, two-match swaps, no neighbour hits from specials, combo = one special, combo centre, colour ties, Crane landing and targeting, special colours, gravity, what can be swapped).
- 2026-11-27 · IR-36 now blocked by OQ-36 · OQ-09's answer (specials clear the piece and hit the layer) reads against Hoof Tap's "a piece, or the top layer".
- 2026-11-27 · IR-51 test case 2 reworded · It used a match next to the bramble yet expected no layer loss, contradicting IR-14; now the three cells are emptied directly and the board settles (gravity only), matching test-engineer's test. Rule text unchanged.
- 2026-11-27 · OQ-24 to OQ-36 opened · New gaps found while applying the answers; owner to decide.
- 2026-11-27 · IR-26 changed; OQ-37 opened · godot-engineer asked whether Orb + Orb hits every layer in a cell; GDD's "hits every obstacle once" reads against "top layer only" + "a combo counts as one special". Rule text unchanged; stacked-layer cells marked blocked; single-layer moss/goo test added.
- 2026-11-27 · IR-49 changed; OQ-38 opened · Clarified from GDD Obstacle set + Cell layer model that "nearest remaining obstacle" includes overlays (moss) and underlays (goo); added two tests. Healing dew in the no-goal case left open.
