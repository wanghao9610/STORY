# STORY project memory

**Language:** English | [简体中文](memory_spec.zh-CN.md)

Project memory stores durable facts learned during a session only when no other repository file owns them. It is a navigation aid, never evidence.

## What belongs here

| Type | Purpose | Example |
| --- | --- | --- |
| `env` | Machine or TeX-toolchain fact | a package is unavailable on one machine |
| `pref` | Durable author workflow preference | review one chapter at a time |
| `insight` | Reusable project insight | an upstream table ID is a more stable anchor than its row number |
| `deadend` | A tried and rejected approach | a framing that failed a mock examination |

Do not store facts already owned elsewhere: evidence belongs to `mates/`, claims to `notes/claims.md`, institutional requirements to `degree/`, publication reuse to `notes/publications.md`, feedback to `milestones/`, and promises to `tasks/`.

## Layout

```text
.story/memory/
├── MEMORY.md
├── <slug>.md
└── local/               # machine-specific and gitignored
    ├── MEMORY.md
    └── <slug>.md
```

One fact lives in one file:

```markdown
---
type: env
scope: machine:mbp-a
language: en
verified: 2026-08-23
model_id: runtime-reported-id
source: wkdrs/builds/main.log
---

The confirmed fact, followed by why it matters and how to apply it.
```

Valid scopes are `global`, `machine:<name>`, `milestone:<slug>`, and `manus:<path>`. Use the actual system date and runtime-reported model ID; never guess either.

## Index format

`MEMORY.md` lists the newest entry first:

```text
- <type> · <scope> · <verified> · [<slug>](<slug>.md) — <one-line fact>
```

Session hooks parse the separators exactly. Only lines beginning with `- ` are injected. Open the linked file before relying on an index line. An `env` memory older than 180 days is marked stale by the hooks.

Re-verify a still-true memory by updating its date and model ID. Replace a changed memory and remove the old entry; delete a memory that was wrong. Git preserves history.
