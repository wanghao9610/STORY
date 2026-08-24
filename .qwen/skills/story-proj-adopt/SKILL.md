---
name: story-proj-adopt
disable-model-invocation: true
description: Safely adopt an existing master's or doctoral thesis draft or Overleaf export into STORY by inventorying it, confirming a file map, preserving the source, recording unsourced claims, and verifying the resulting build.
argument-hint: "SOURCE_PATH [DESCRIPTION] [involve=low]"
---

# Adopt an existing thesis

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

Read `degree_level` from `degree/profile.tex`. If it is absent or invalid, inventory may continue, but ask the author to confirm `master` or `doctoral` before mapping level-specific front matter, milestones, or requirements. Never infer the level from the imported title page.

1. Inventory the draft read-only: entry points, chapter inputs, front/back matter, figures, tables, bibliography, styles, build commands, institutional-template signals, and candidate evidence.
2. Determine whether the source is inside this repository or external. Never modify an external source tree; copy from it.
3. Propose a complete mapping into `manus/fronts/`, `manus/chaps/`, `manus/backs/`, `manus/figs/`, `manus/tabs/`, `manus/bibs/`, and `manus/stys/`. Name every path and reference rewrite.
4. Get author confirmation before moving, overwriting, or changing the main entry point.
5. Apply only the confirmed map and create `notes/adopt.md` when recording the first approved adoption; on a rerun, update the existing record without replacing it with a scaffold.
6. Add the draft's quantitative or comparative statements to `notes/claims.md` as `unsourced` unless their evidence is already registered. If the ledger is absent, initialize it with `ID | Claim | Contribution | Stated in | Evidence | Status | Notes` immediately before adding the first row. Route candidate evidence to `story-evid-curator`.
7. Build with `bash execs/run.sh`; report unresolved mappings and compilation failures without guessing fixes.

Create the paired `notes/adopt.zh-CN.md` and, when the ledger is initialized here, `notes/claims.zh-CN.md` in the same change. Do not create any other `notes/*.md` artifact during adoption.

Do not redesign the chapter architecture during adoption. Route that work to `story-outl-planner` after the imported thesis builds.
