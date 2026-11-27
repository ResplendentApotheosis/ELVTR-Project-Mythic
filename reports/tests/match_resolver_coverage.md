# MatchResolver step 4: IR coverage (round 3 final)

Run: `--headless --import`, then full GUT suite. Exit code 0.
Totals: 8 scripts, 223 tests, 218 passing, 0 failing, 5 pending, 0 script errors.
(Tests counts pending placeholders too; Pass = Tests - Pending - Fail.)

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
| IR-14 | 6 | 6 | 0 | 0 | pass |
| IR-15 | 5 | 5 | 0 | 0 | pass |
| IR-16 | 11 | 10 | 0 | 1 | pending: OQ-53 |
| IR-17 | 3 | 3 | 0 | 0 | pass |
| IR-18 | 6 | 6 | 0 | 0 | pass |
| IR-19 | 4 | 4 | 0 | 0 | pass |
| IR-20 | 2 | 2 | 0 | 0 | pass |
| IR-21 | 2 | 2 | 0 | 0 | pass |
| IR-22 | 2 | 2 | 0 | 0 | pass |
| IR-23 | 2 | 2 | 0 | 0 | pass |
| IR-24 | 4 | 4 | 0 | 0 | pass |
| IR-25 | 7 | 7 | 0 | 0 | pass |
| IR-26 | 6 | 6 | 0 | 0 | pass |
| IR-27 | 5 | 5 | 0 | 0 | pass |
| IR-28 | 2 | 2 | 0 | 0 | pass |
| IR-29 | 2 | 2 | 0 | 0 | pass |
| IR-30 | 5 | 5 | 0 | 0 | pass |
| IR-31 | 0 | 0 | 0 | 0 | other module |
| IR-32 | 2 | 2 | 0 | 0 | pass |
| IR-33 | 5 | 5 | 0 | 0 | pass |
| IR-34 | 0 | 0 | 0 | 0 | other module |
| IR-35 | 0 | 0 | 0 | 0 | other module |
| IR-36 | 0 | 0 | 0 | 0 | other module |
| IR-37 | 0 | 0 | 0 | 0 | other module |
| IR-38 | 0 | 0 | 0 | 0 | other module |
| IR-39 | 9 | 8 | 0 | 1 | pending: OQ-54a |
| IR-40 | 7 | 7 | 0 | 0 | pass |
| IR-41 | 9 | 9 | 0 | 0 | pass |
| IR-42 | 2 | 2 | 0 | 0 | pass |
| IR-43 | 2 | 2 | 0 | 0 | pass |
| IR-44 | 3 | 3 | 0 | 0 | pass |
| IR-45 | 3 | 3 | 0 | 0 | pass |
| IR-46 | 3 | 3 | 0 | 0 | pass |
| IR-47 | 5 | 5 | 0 | 0 | pass |
| IR-48 | 8 | 7 | 0 | 1 | pending: OQ-55c |
| IR-49 | 16 | 16 | 0 | 0 | pass |
| IR-50 | 4 | 3 | 0 | 1 | pending: OQ-54b |
| IR-51 | 6 | 6 | 0 | 0 | pass |
| IR-52 | 7 | 7 | 0 | 0 | pass |
| IR-53 | 8 | 8 | 0 | 0 | pass |
| IR-54 | 5 | 5 | 0 | 0 | pass |
| IR-55 | 4 | 3 | 0 | 1 | pending: OQ-55 |

Round 3 final fixes (all five failures were test bugs):
- IR-21 `..._rocket_that_the_firecracker_then_sets_off`: expected list now ends `rocket_fire, fall, refill` (row 4 is cleared, pieces above fall in).
- IR-41 `..._cascades_only_after_the_last` and IR-39 `..._waits_until_the_swapped_rocket_has_fired`: a column Rocket empties its whole column, so nothing can fall; only `refill` follows it. Tests no longer require an empty `fall`. API_CONTRACT unchanged (`fall` = pieces fell).
- IR-25 pillar test, IR-25 covered-pieces test, IR-25 lower-Rocket test: pinned with `BB.spread_palette()` (12 refill colours that are not R/Y/B/G) so refills do not line up into cascades. Helper added to tests/helpers/board_builder.gd.
Pending (5): OQ-53 (IR-16), OQ-54 a (IR-39), OQ-54 b (IR-50), OQ-55 (IR-55), OQ-55 c (IR-48).
