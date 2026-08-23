---
name: story-proj-adopt
disable-model-invocation: true
description: Safely adopt an existing dissertation, thesis draft, or Overleaf export into STORY by inventorying it, confirming a file map, preserving the source, recording unsourced claims, and verifying the resulting build.
---

# Adopt an existing dissertation

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

1. Inventory the draft read-only: entry points, chapter inputs, front/back matter, figures, tables, bibliography, styles, build commands, institutional-template signals, and candidate evidence.
2. Determine whether the source is inside this repository or external. Never modify an external source tree; copy from it.
3. Propose a complete mapping into `manus/fronts/`, `manus/chaps/`, `manus/backs/`, `manus/figs/`, `manus/tabs/`, `manus/bibs/`, and `manus/stys/`. Name every path and reference rewrite.
4. Get author confirmation before moving, overwriting, or changing the main entry point.
5. Apply only the confirmed map and record it in `notes/adopt.md`.
6. Add existing quantitative or comparative statements to `notes/claims.md` as `unsourced` unless their evidence is already registered. Route candidate evidence to `story-evid-curator`.
7. Build with `bash execs/run.sh`; report unresolved mappings and compilation failures without guessing fixes.

Do not redesign the chapter architecture during adoption. Route that work to `story-outl-planner` after the imported draft builds.
