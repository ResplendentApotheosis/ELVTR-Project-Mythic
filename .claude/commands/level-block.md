---
description: Design and balance one 5-level block, e.g. /level-block 26-30
argument-hint: <first>-<last>  (e.g. 26-30)
---

Make and balance level block **$ARGUMENTS** using the "Make a level block" workflow in CLAUDE.md.

1. Check the block is 5 levels inside 1–50 and starts on 1, 6, 11, 16… (i.e. first ≡ 1 mod 5). If not, stop and ask.
2. Check that `research/match-villains/level_agent_brief.md` and `levels_1_100_plan.csv` exist. If not, stop and tell me to commit the research pack.
3. Use the **level-designer** agent to write the block.
4. Use the **balance-analyst** agent to validate it, bot it and apply bounded tweaks.
5. If balance-analyst sends levels back, run level-designer once more on just those levels, then balance-analyst again. After that second round, stop and report. Don't loop.
6. Give me one combined report in the CLAUDE.md format, with the balance table and the list of levels I need to playtest.
