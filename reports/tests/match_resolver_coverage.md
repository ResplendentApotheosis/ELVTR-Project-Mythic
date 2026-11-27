# MatchResolver step 4: IR coverage

Run: `--headless --import`, then full GUT suite. Exit code 0.
Totals: 6 scripts, 154 tests, 131 passing, 0 failing, 23 pending, 0 script errors.
("Tests" below counts pending placeholders too; Passing = Tests - Pending.)

| IR | Tests | Pass | Fail | Pending | Status |
|---|---|---|---|---|---|
| IR-01 | 2 | 2 | 0 | 0 | pass |
| IR-02 | 2 | 2 | 0 | 0 | pass |
| IR-03 | 3 | 3 | 0 | 0 | pass |
| IR-04 | 1 | 1 | 0 | 0 | pass |
| IR-05 | 2 | 2 | 0 | 0 | pass |
| IR-06 | 3 | 2 | 0 | 1 | OQ-28 |
| IR-07 | 3 | 3 | 0 | 0 | pass |
| IR-08 | 3 | 3 | 0 | 0 | pass |
| IR-09 | 5 | 4 | 0 | 1 | OQ-29, OQ-31 |
| IR-10 | 4 | 4 | 0 | 0 | pass |
| IR-11 | 2 | 2 | 0 | 0 | pass |
| IR-12 | 4 | 4 | 0 | 0 | pass |
| IR-13 | 4 | 4 | 0 | 0 | pass |
| IR-14 | 5 | 5 | 0 | 0 | pass |
| IR-15 | 4 | 3 | 0 | 1 | OQ-31 |
| IR-16 | 3 | 2 | 0 | 1 | OQ-24 |
| IR-17 | 3 | 2 | 0 | 1 | OQ-32 |
| IR-18 | 4 | 3 | 0 | 1 | OQ-33 |
| IR-19 | 3 | 2 | 0 | 1 | OQ-33 |
| IR-20 | 2 | 2 | 0 | 0 | pass |
| IR-21 | 2 | 1 | 0 | 1 | OQ-26 |
| IR-22 | 2 | 2 | 0 | 0 | pass |
| IR-23 | 2 | 2 | 0 | 0 | pass |
| IR-24 | 3 | 2 | 0 | 1 | OQ-32 |
| IR-25 | 1 | 0 | 0 | 1 | OQ-24, OQ-27, OQ-33, OQ-32 (pending only) |
| IR-26 | 6 | 4 | 0 | 2 | OQ-27, OQ-37 |
| IR-27 | 4 | 3 | 0 | 1 | OQ-26, OQ-34 |
| IR-28 | 2 | 2 | 0 | 0 | pass |
| IR-29 | 2 | 2 | 0 | 0 | pass |
| IR-30 | 5 | 5 | 0 | 0 | pass |
| IR-31 | 0 | - | - | - | other module (fragments / GoalTracker) |
| IR-32 | 2 | 2 | 0 | 0 | pass |
| IR-33 | 4 | 4 | 0 | 0 | pass |
| IR-34..IR-38 | 0 | - | - | - | other module (boosters, continue, quit) |
| IR-39 | 4 | 3 | 0 | 1 | OQ-26 |
| IR-40 | 6 | 5 | 0 | 1 | OQ-25 |
| IR-41 | 4 | 3 | 0 | 1 | OQ-27 |
| IR-42 | 2 | 2 | 0 | 0 | pass |
| IR-43 | 3 | 2 | 0 | 1 | OQ-25 |
| IR-44 | 3 | 3 | 0 | 0 | pass |
| IR-45 | 3 | 3 | 0 | 0 | pass |
| IR-46 | 3 | 3 | 0 | 0 | pass |
| IR-47 | 3 | 3 | 0 | 0 | pass |
| IR-48 | 4 | 3 | 0 | 1 | OQ-34, OQ-31 |
| IR-49 | 10 | 8 | 0 | 2 | OQ-34, OQ-38 |
| IR-50 | 4 | 3 | 0 | 1 | OQ-26 |
| IR-51 | 2 | 1 | 0 | 1 | OQ-35 |
| IR-52 | 6 | 5 | 0 | 1 | OQ-29, OQ-30 |

Note: IR numbers mapped by the test_irNN_ name prefix. OQ labels are taken from each pending test message.
Failing tests: none.
