# Levels 1-10, bot re-run after GDD round 10 (28 Nov 2026)

Why: specials made by a swap now appear on a swapped cell (IR-40, all four kinds) and goals show as done at once (IR-56). Placement changes bot play a little, so levels 1-10 were re-run.
Bot: 500 runs per level, seed 1, `--levels 1-10 --jobs 5`, UNCALIBRATED (offset 0). Raw data: `reports/balance/round5/`. No level was changed for balance; level 2 got three pinned tiles for the Rocket tutorial (not a balance change).

| Level | Tier | Bot % | Avg moves left (win) | Earlier result | Band | Result |
|---|---|---|---|---|---|---|
| 001 | intro | 100 | 23.07 | 100 / 23.2 | 95 (cap 100) | PASS |
| 002 | easy | 100 | 13.08 | 99.8 / 13.06 | 85-90 (cap 95) | too easy for the bot (as before) |
| 003 | easy | 100 | 14.76 | 99.8 / 14.80 | 85-90 (cap 95) | too easy for the bot (as before) |
| 004 | intro | 100 | 24.77 | 100 / 24.65 | 95 (cap 100) | PASS |
| 005 | easy | 100 | 12.92 | 100 / 12.82 | 85-90 (cap 95) | too easy for the bot (as before) |
| 006 | easy | 100 | 18.11 | 100 / 18.16 | 85-90 (cap 95) | too easy for the bot (as before) |
| 007 | intro | 100 | 26.08 | 100 / 26.06 | 95 (cap 100) | PASS |
| 008 | easy | 91.8 | 9.43 | 90.6 / 9.43 | 85-90 (cap 95) | PASS |
| 009 | easy | 100 | 16.33 | 100 / 16.37 | 85-90 (cap 95) | too easy for the bot (as before) |
| 010 | intro | 100 | 28.52 | 100 / 28.51 | 95 (cap 100) | PASS |

Result: no level moved by more than about 1.2 points or 0.2 moves left; the new placement changed nothing that matters for balance. Owner playtests said levels 6-10 felt OK, and the bot is not a human proxy on tutorial/easy levels, so the "too easy for the bot" levels stay until the week-9 calibration.
