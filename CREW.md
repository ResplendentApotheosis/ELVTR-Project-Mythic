# Zodiac Forest: agent crew architecture

How the five Claude Code agents connect, and how data moves between them. The rules themselves are in `CLAUDE.md`; the agent prompts are in `.claude/agents/`.

## 1. Architecture and data flow

Solid arrows show data being read or written. Dashed arrows show hand-offs and reports. Agents never call each other: the producer (the main Claude session) runs each hand-off.

```mermaid
flowchart TB
    subgraph OWNER["Owner (you)"]
        O(["Owner"])
    end

    subgraph SOURCES["Sources of truth: owner-only, guarded by hook"]
        GDD[("docs/gdd/<br/>GDD final")]
        RES[("research/match-villains/<br/>level brief + 1–100 plan")]
    end

    P{{"Producer<br/>(main session)<br/>/build · /level-block"}}

    subgraph CODE["Build a module"]
        RK["rules-keeper"]
        TE["test-engineer"]
        GE["godot-engineer"]
    end

    subgraph LEVELS["Make a level block"]
        LD["level-designer"]
        BA["balance-analyst"]
    end

    subgraph REPO["Repo outputs"]
        SPEC[("spec/<br/>interaction_rules.md<br/>open_questions.md")]
        TESTS[("tests/<br/>GUT tests")]
        SRC[("src/<br/>game code")]
        TOOLS[("tools/<br/>validate_level · level_bot<br/>calibration.json")]
        LVL[("levels/<br/>level_NNN.json")]
        REP[("reports/balance/")]
    end

    O -- "commands" --> P
    P -. "report + 'Needs you'" .-> O
    O -- "edits" --> GDD
    O -- "edits" --> RES
    O -- "sets offsets after tester rounds" --> TOOLS

    P -. "1 · rules for module" .-> RK
    P -. "2 · write failing tests" .-> TE
    P -. "3 · implement" .-> GE
    P -. "a · design block" .-> LD
    P -. "b · validate + bot" .-> BA

    GDD --> RK
    RK --> SPEC
    SPEC -. "open questions" .-> O

    SPEC --> TE
    TE --> TESTS
    SPEC --> GE
    TESTS --> GE
    GDD --> GE
    GE --> SRC
    GE --> TOOLS

    RES --> LD
    GDD --> LD
    LD --> LVL

    LVL --> BA
    TOOLS --> BA
    SRC -. "real BoardModel + MatchResolver" .-> TOOLS
    BA -- "bounded tweaks only<br/>goals ±20% · moves ±2" --> LVL
    BA --> REP
    BA -. "send back: redesign" .-> LD
    REP -. "playtest list:<br/>intro · hard · finale" .-> O
```

## 2. `/build <module>`: test-first

```mermaid
sequenceDiagram
    actor O as Owner
    participant P as Producer
    participant RK as rules-keeper
    participant TE as test-engineer
    participant GE as godot-engineer

    O->>P: /build MatchResolver
    P->>RK: Which IR rules does this module need?
    RK->>RK: Read GDD, write spec/interaction_rules.md
    alt GDD doesn't answer something
        RK-->>P: spec/open_questions.md
        P-->>O: Stop: decision needed
    end
    RK-->>P: IR-xx list
    P->>TE: Write failing tests for IR-xx
    TE-->>P: tests/ written, failing for the right reason
    P->>GE: Implement until the tests pass (don't touch tests/)
    GE-->>P: src/ updated
    P->>TE: Run full suite + coverage
    alt Still failing
        P->>GE: One fix round only
        P->>TE: Re-run
    end
    TE-->>P: Pass/fail table per IR
    P-->>O: Report (Done · Files · Check · Rules · Needs you)
```

## 3. `/level-block <first>-<last>`: design, then check

```mermaid
sequenceDiagram
    actor O as Owner
    participant P as Producer
    participant LD as level-designer
    participant BA as balance-analyst

    O->>P: /level-block 26-30
    P->>LD: Design levels 26–30
    LD->>LD: Read brief §3–6, plan rows, GDD
    LD-->>P: levels/level_026–030.json (self-checked)
    P->>BA: Validate + bot 500× per level
    BA->>BA: Validator → bot → apply calibration offset → band check
    opt Missed band, within limits
        BA->>BA: Tweak goals ±20% / moves ±2, re-run (max 2 rounds)
    end
    alt Needs a redesign
        BA-->>P: Send back with reason
        P->>LD: Redesign those levels (one round)
        P->>BA: Re-check
    end
    BA-->>P: reports/balance/levels_026-030.md
    P-->>O: Balance table + levels to playtest
```

## 4. Who can write where

| Agent | Reads | Writes | Model | Bash |
|---|---|---|---|---|
| rules-keeper | GDD, brief | `spec/` | inherit | no |
| test-engineer | `spec/` | `tests/` | sonnet | yes (runs GUT) |
| godot-engineer | `spec/`, `tests/`, GDD | `src/`, `tools/`, `scenes/`, project files | inherit | yes |
| level-designer | brief §3–6, plan CSV, GDD, earlier levels | `levels/` | inherit | no |
| balance-analyst | `levels/`, `tools/`, GDD | `reports/balance/`, bounded fields in `levels/` | sonnet | yes (validator, bot) |
| Owner | everything | `docs/`, `research/`, `tools/level_bot/calibration.json` | — | — |

The hook in `.claude/hooks/protect-sources.js` blocks agent edits to `docs/`, `research/` and `addons/gut/`. Every other write limit is set by the agent prompts.
