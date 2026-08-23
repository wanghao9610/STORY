# STORY Agent Instructions

This repository uses STORY — **Systematic Toolchain for Organizing Research over Years** — to turn a body of doctoral research into a coherent, defensible, and deposit-ready dissertation.

## 1. Scope and authority

- One repository represents one doctoral dissertation.
- `degree/` contains user-confirmed institutional facts. Never invent a deadline, formatting rule, committee decision, authorship statement, or deposit requirement.
- `mates/` is the evidence store. It is read-only except through `execs/scpts/import.sh` and `$story-evid-curator`.
- `manus/` is the dissertation source. Write manuscript prose in the dissertation language recorded in `degree/profile.tex`; structural keys, IDs, paths, and statuses remain English.
- Ask before a choice that changes the thesis-wide argument, chapter boundaries, attribution, publication reuse, or a degree requirement. Make safe local choices without interrupting the user.

## 2. Evidence before prose

- Every quantitative or comparative claim in `manus/` must trace to a fingerprinted `mates/` file through a nearby `% src:` comment or a claim-ledger entry.
- Missing evidence is written visibly as `\todo{...}`. A plausible invented value is never acceptable.
- Assertions about cited work must be checkable against `notes/refs/` or imported reference material.
- Fix incorrect evidence at its source and re-import it. Never silently edit a snapshot under `mates/`.
- A published paper is evidence, not automatically the dissertation's final wording. Reconcile terminology, scope, attribution, and overlap before reuse.

## 3. Dissertation-level coherence

- `notes/story.md` owns the thesis-level problem, central argument, research arc, and synthesis.
- `notes/contributions.md` maps doctoral contributions to evidence, publications, chapters, and candidate examination claims.
- `notes/publications.md` records authorship, chapter reuse, permissions, and overlap. Do not imply sole authorship when work was collaborative.
- `notes/outline.md` owns chapter order and chapter briefs. A chapter draft must serve the thesis-wide argument, not merely reproduce a paper.
- `notes/claims.md` is the claim ledger. Update it in the same change that introduces, moves, weakens, or verifies a claim.

## 4. Degree milestones

- Each proposal, annual review, pre-defense, defense, correction round, or deposit attempt lives under `milestones/<slug>/`.
- `milestone.yml` contains user-confirmed facts; `feedback/` preserves received comments; `response/` records dispositions; `RECORD_<date>.md` freezes an outcome.
- Committee feedback is never edited in place. Responses distinguish completed changes, planned changes, reasoned disagreements, and questions requiring the author.
- A deposit package cannot be declared ready while required checks in `degree/requirements.md` or open promises in `tasks/` remain unresolved.

## 5. File ownership

- `manus/fronts/`: abstract, acknowledgements, declarations, and other front matter.
- `manus/chaps/`: numbered chapters `<n>_<slug>.tex`.
- `manus/backs/`: appendices and other back matter.
- `manus/figs/`, `manus/tabs/`, `manus/bibs/`, `manus/stys/`: figures, tables, bibliography, and template layers.
- `degree/`: profile, committee record, and institutional checklist.
- `notes/`: narrative, outline, claims, contribution/publication maps, notation, style, adoption record, and reading notes.
- `wkdrs/`: builds and regenerable reports; never treat it as durable project state.
- `tasks/`: durable unresolved work and feedback promises.

## 6. Runtime

- Build only with `bash execs/run.sh`; output belongs under `wkdrs/builds/`.
- Run deterministic checks with `bash execs/scpts/lint.sh`.
- Use `bash execs/scpts/fmt.sh` to preserve one sentence per line without changing typeset text.
- Runtime configuration comes from `.env`, copied from `.env.example`; do not hardcode machine paths.
- Use the actual system date whenever a dated artifact is created.

## 7. Workflow

- When the repository state is unclear, run `$story-flow-status` first.
- Every workflow skill loads `docs/mds/story-workflow/writing-workflow-conventions.md` before acting.
- Prefer the smallest applicable skill. Do not let a drafting request mutate evidence, degree requirements, or received feedback.
- Build after changing `manus/`; run lint when references, claims, metadata, or finalization state may have changed.
- Report what was verified: build path and page count, lint result, changed ledger rows, and any remaining gate.

## 8. Language and project memory

- `.env` `STORY_LANG=en|zh` controls replies and newly written Markdown; unset follows the conversation. It does not silently translate existing files.
- `degree/profile.tex` controls the manuscript language.
- Store session knowledge in `.story/memory/` only when no repository file already owns it. Machine-local facts go under `.story/memory/local/`.
- Memory is never evidence and cannot override `degree/`, `mates/`, `notes/`, or `milestones/`.
