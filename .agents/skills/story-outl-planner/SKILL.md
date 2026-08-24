---
name: story-outl-planner
description: Turn a confirmed master's or doctoral thesis story and contribution map into a coherent chapter architecture, chapter briefs, figure/table plans, and compilable chapter scaffolds; use for monograph or publication-based structures.
---

# Plan the thesis outline

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

Use `degree/profile.tex`, `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, and `notes/claims.md`. Resolve a valid degree level before planning; if it is unknown, stop and ask the author to confirm it. If any required `notes/` artifact is absent, stop and route to `story-syns-coach`; the absence means the synthesis stage has not been initialized. Identify whether the confirmed thesis type is monograph, publication-based, or another institution-approved form.

For each proposed chapter, state its purpose, research questions, contribution and claim IDs, evidence, planned figures/tables, dependencies, and exit condition. Test the plan for:

- a visible thesis-level argument, and—when publications are reused—an architecture rather than a paper bundle;
- foundations introduced before use;
- limited repetition of methods and related work;
- explicit transitions between research chapters where more than one exists;
- degree-appropriate synthesis, with a separate synthesis chapter only when the confirmed rules or research arc require one;
- accurate attribution and publication reuse.

In master mode, do not infer a minimum chapter, study, contribution, or publication count. After author confirmation, create `notes/outline.md` if it is absent or reconcile it if present. Give it a chapter table with columns `Chapter | File | Purpose | Contributions | Claims | Status`, a Figures table (`ID | File | Purpose | Evidence | Chapter | Status`), and a Tables table with the same columns. Use the field formats and shared outline statuses in conventions §3, initializing each new row as `planned`. Create or rename `manus/chaps/<n>_<slug>.tex` scaffolds, update the `\input` order in `manus/main.tex`, and create or seed `notes/notation.md` with the columns `Symbol or term | Meaning | First use | Scope`; notation cells are free text, `First use` is either a repository-relative manuscript path or empty, and `Scope` is `thesis-wide | <chapter path>`. Create the paired `*.zh-CN.md` artifacts in the same change, then build. Never replace an existing note with a scaffold or delete an existing chapter without explicit approval.
