---
description: Build one game module test-first, e.g. /build MatchResolver
argument-hint: <module>  (e.g. MatchResolver, OB07, GoalTracker, level_bot)
---

Build **$ARGUMENTS** using the "Build a module" workflow in CLAUDE.md.

1. Use the **rules-keeper** agent to list the IR rules this module needs, adding any that are missing from the GDD. If it raises open questions, stop and show them to me before going on.
2. Use the **test-engineer** agent to write failing tests for those IR IDs and run them, to confirm they fail for the right reason.
3. Use the **godot-engineer** agent to implement until those tests pass without breaking others.
4. Use the **test-engineer** agent to run the full suite and produce the IR coverage table.
5. If tests still fail after one fix round by godot-engineer, stop and report. Don't loop.
6. Give me one combined report in the CLAUDE.md format.
