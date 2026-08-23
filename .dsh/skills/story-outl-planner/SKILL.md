---
name: story-outl-planner
disable-model-invocation: true
description: Turn a confirmed dissertation story and contribution map into a coherent chapter architecture, chapter briefs, figure/table plans, and compilable chapter scaffolds; use for monograph or publication-based thesis structures.
---

# Plan the dissertation outline

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

Use `degree/profile.tex`, `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, and `notes/claims.md`. Identify whether the confirmed thesis type is monograph, publication-based, or another institution-approved form.

For each proposed chapter, state its purpose, research questions, contribution and claim IDs, evidence, planned figures/tables, dependencies, and exit condition. Test the plan for:

- a visible thesis-level argument rather than a paper bundle;
- foundations introduced before use;
- limited repetition of methods and related work;
- explicit transitions between research chapters;
- a synthesis chapter that produces cross-study insight;
- accurate attribution and publication reuse.

After author confirmation, update `notes/outline.md`, create or rename `manus/chaps/<n>_<slug>.tex` scaffolds, update the `\input` order in `manus/main.tex`, seed `notes/notation.md`, and build. Never delete an existing chapter without explicit approval.
