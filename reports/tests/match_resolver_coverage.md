# MatchResolver step 4: IR coverage (round 2)

Run: `--headless --import`, then full GUT suite. Exit code 0.
Totals: 7 scripts, 203 tests, 182 passing, 1 failing, 20 pending, 0 script errors.
("Tests" counts pending placeholders too; Pass = Tests - Pending - Fail.)

| IR | Tests | Pass | Fail | Pending | Status |
|---|---|---|---|---|---|
| IR-01 | 5 | 5 | 0 | 0 | pass |
| IR-02 | 2 | 2 | 0 | 0 | pass |
| IR-03 | 3 | 3 | 0 | 0 | pass |
| IR-04 | 1 | 1 | 0 | 0 | pass |
| IR-05 | 2 | 2 | 0 | 0 | pass |
| IR-06 | 3 | 3 | 0 | 0 | pass |
| IR-07 | 3 | 3 | 0 | 0 | pass |
| IR-08 | 3 | 3 | 0 | 0 | pass |
| IR-09 | 5 | 5 | 0 | 0 | pass |
| IR-10 | 4 | 4 | 0 | 0 | pass |
| IR-11 | 2 | 2 | 0 | 0 | pass |
| IR-12 | 4 | 4 | 0 | 0 | pass |
| IR-13 | 4 | 4 | 0 | 0 | pass |
| IR-14 | 6 | 5 | 0 | 1 | pending: OQ-41 |
| IR-15 | 4 | 4 | 0 | 0 | pass |
| IR-16 | 5 | 4 | 0 | 1 | pending: OQ-40 |
| IR-17 | 3 | 3 | 0 | 0 | pass |
| IR-18 | 6 | 5 | 0 | 1 | pending: OQ-42 |
| IR-19 | 4 | 3 | 0 | 1 | pending: OQ-42 |
| IR-20 | 2 | 2 | 0 | 0 | pass |
| IR-21 | 2 | 2 | 0 | 0 | pass |
| IR-22 | 2 | 2 | 0 | 0 | pass |
| IR-23 | 2 | 2 | 0 | 0 | pass |
| IR-24 | 4 | 4 | 0 | 0 | pass |
| IR-25 | 5 | 2 | 0 | 3 | pending: OQ-42, OQ-48 |
| IR-26 | 6 | 6 | 0 | 0 | pass |
| IR-27 | 5 | 5 | 0 | 0 | pass |
| IR-28 | 2 | 2 | 0 | 0 | pass |
| IR-29 | 2 | 2 | 0 | 0 | pass |
| IR-30 | 5 | 5 | 0 | 0 | pass |
| IR-31 | 0 | 0 | 0 | 0 | other module |
| IR-32 | 2 | 2 | 0 | 0 | pass |
| IR-33 | 5 | 4 | 0 | 1 | pending: OQ-41 |
| IR-34 | 0 | 0 | 0 | 0 | other module |
| IR-35 | 0 | 0 | 0 | 0 | other module |
| IR-36 | 0 | 0 | 0 | 0 | other module |
| IR-37 | 0 | 0 | 0 | 0 | other module |
| IR-38 | 0 | 0 | 0 | 0 | other module |
| IR-39 | 7 | 6 | 0 | 1 | pending: OQ-44 |
| IR-40 | 8 | 7 | 0 | 1 | pending: OQ-40 |
| IR-41 | 9 | 7 | 0 | 2 | pending: OQ-44, OQ-47 |
| IR-42 | 2 | 2 | 0 | 0 | pass |
| IR-43 | 2 | 2 | 0 | 0 | pass |
| IR-44 | 3 | 3 | 0 | 0 | pass |
| IR-45 | 3 | 3 | 0 | 0 | pass |
| IR-46 | 3 | 3 | 0 | 0 | pass |
| IR-47 | 5 | 4 | 0 | 1 | pending: OQ-42 |
| IR-48 | 8 | 6 | 1 | 1 | FAIL: set-off Crane take-off does not clear the piece that fell in; pending: OQ-49 |
| IR-49 | 14 | 13 | 0 | 1 | pending: OQ-43 |
| IR-50 | 3 | 3 | 0 | 0 | pass |
| IR-51 | 6 | 4 | 0 | 2 | pending: OQ-41, OQ-45 |
| IR-52 | 7 | 7 | 0 | 0 | pass |
| IR-53 | 6 | 4 | 0 | 2 | pending: OQ-46, OQ-49 |
| IR-54 | 4 | 3 | 0 | 1 | pending: OQ-41 |

Round 2 fix: `test_ir19_coloured_specials_are_not_counted_and_not_cleared` now pins its layout (Firecrackers in the bottom corners, all neighbours reserved unique fillers) so no cascade can match them. Cause confirmed: with the old layout, column 0 fell after the yellows cleared and the Firecracker at (0,0) landed next to two Rs, a legitimate cascade match (IR-32/IR-50). Code was right.

Round 3 (IR-48 tightened; OQ-47..OQ-50 blocks):
- New test `test_ir48_set_off_crane_takeoff_clears_the_piece_that_fell_into_its_cell` (tests/match_resolver/test_special_effects.gd). FAILS for the right reason: goo hp and take-off event are correct, but no `clear` event lists (4,6) after `crane_takeoff`, so the piece that fell into the Crane's start cell is not cleared (src/match/special_firing.gd `fire_crane` only clears `take_off_board` cells).
- New pending placeholders: IR-41 (OQ-47), IR-48 (OQ-49), IR-53 (OQ-49), IR-25 (OQ-48).
- Converted to pending (bodies kept as unused `_blocked_oq48_*` functions in test_combos.gd, because they pin OQ-48 Option A, "fire from the converted cell"): `test_ir25_orb_plus_firecracker_turns_every_common_piece_into_a_firecracker`, `test_ir25_red_rockets_are_neither_counted_nor_converted`.
- OQ-50 (lantern shrine): no IR-numbered rule lists it as a block; no passing test pins shrine hit behaviour except IR-49 Crane landing tests, left as is. No tests pin OQ-47 or OQ-49 behaviour (the Crane dew tests check dew only).
