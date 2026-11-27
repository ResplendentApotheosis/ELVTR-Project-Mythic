# MatchResolver step 4: IR coverage (round 5 final)

Run: `--headless --import`, then full GUT suite. Exit code 0.
Totals: 8 scripts, 257 tests, 257 passing, 0 failing, 0 pending, 0 script errors, 1589 asserts.

| IR | Tests | Pass | Fail | Pending | Status |
|---|---|---|---|---|---|
| IR-01 | 5 | 5 | 0 | 0 | pass |
| IR-02 | 3 | 3 | 0 | 0 | pass |
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
| IR-14 | 7 | 7 | 0 | 0 | pass |
| IR-15 | 5 | 5 | 0 | 0 | pass |
| IR-16 | 23 | 23 | 0 | 0 | pass |
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
| IR-33 | 6 | 6 | 0 | 0 | pass |
| IR-34 | 0 | 0 | 0 | 0 | other module |
| IR-35 | 0 | 0 | 0 | 0 | other module |
| IR-36 | 0 | 0 | 0 | 0 | other module |
| IR-37 | 0 | 0 | 0 | 0 | other module |
| IR-38 | 0 | 0 | 0 | 0 | other module |
| IR-39 | 9 | 9 | 0 | 0 | pass |
| IR-40 | 8 | 8 | 0 | 0 | pass |
| IR-41 | 9 | 9 | 0 | 0 | pass |
| IR-42 | 2 | 2 | 0 | 0 | pass |
| IR-43 | 2 | 2 | 0 | 0 | pass |
| IR-44 | 3 | 3 | 0 | 0 | pass |
| IR-45 | 3 | 3 | 0 | 0 | pass |
| IR-46 | 3 | 3 | 0 | 0 | pass |
| IR-47 | 5 | 5 | 0 | 0 | pass |
| IR-48 | 9 | 9 | 0 | 0 | pass |
| IR-49 | 17 | 17 | 0 | 0 | pass |
| IR-50 | 4 | 4 | 0 | 0 | pass |
| IR-51 | 6 | 6 | 0 | 0 | pass |
| IR-52 | 7 | 7 | 0 | 0 | pass |
| IR-53 | 11 | 11 | 0 | 0 | pass |
| IR-54 | 8 | 8 | 0 | 0 | pass |
| IR-55 | 14 | 14 | 0 | 0 | pass |

Round 5: the OQ-59, OQ-60 and OQ-61 placeholders are now real passing tests. Two test mistakes fixed: IR-55 shrine needs asserted after the shrine was removed, and the IR-16 fallback-rocket set-up (plain piece added at (1,0)). Not covered here: IR-31 (GoalTracker), IR-34..IR-38 (other modules).
