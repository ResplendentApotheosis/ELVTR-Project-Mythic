# MatchResolver step 4: IR coverage (round 4 final)

Run: `--headless --import`, then full GUT suite. Exit code 0.
Totals: 8 scripts, 251 tests, 245 passing, 0 failing, 6 pending, 0 script errors.
(Tests counts pending placeholders too; Pass = Tests - Pending - Fail.)

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
| IR-14 | 6 | 6 | 0 | 0 | pass |
| IR-15 | 5 | 5 | 0 | 0 | pass |
| IR-16 | 19 | 17 | 0 | 2 | pending: OQ-60 |
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
| IR-49 | 16 | 16 | 0 | 0 | pass |
| IR-50 | 4 | 4 | 0 | 0 | pass |
| IR-51 | 6 | 6 | 0 | 0 | pass |
| IR-52 | 7 | 7 | 0 | 0 | pass |
| IR-53 | 11 | 11 | 0 | 0 | pass |
| IR-54 | 8 | 8 | 0 | 0 | pass |
| IR-55 | 14 | 10 | 0 | 4 | pending: OQ-59 (3), OQ-61 (1) |

Round 4 changes:
- IR-50 settled by rules-keeper: a lifted special is not a cleared piece of the match and is not in the match's `clear` event (count 11 = 2 + 9). Three tests asserted the old reading; all three were test bugs, now fixed: IR-50 `coloured_rocket_in_a_match_clears_and_fires` (clear event is (1,4),(2,4) only, Rocket cell (3,4) absent), IR-54 covered-Rocket-matched-by-colour (clear event excludes the lifted Rocket), IR-39 match-then-Firecracker (lifted Firecracker at (4,5) absent from the clear event). The `match` detection event is not pinned either way.
- OQ-61 (does a lifted coloured special next to a shrine fill it?): pending placeholder added in test_damage_and_obstacles.gd (IR-55); no passing test pins either answer.
- Not covered here: IR-31 (GoalTracker), IR-34..IR-38 (other modules).

Pending (6): OQ-59 x3 (IR-55), OQ-61 (IR-55), OQ-60 x2 (IR-16).
