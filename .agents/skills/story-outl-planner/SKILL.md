---
name: story-outl-planner
description: Use once the thesis story is finalized or the author chooses a provisional outline, and whenever chapter boundaries change. Turns the story and contribution map into chapter architecture, briefs, figure and table plans, and chapter scaffolds wired into the active entry point, mapping existing drafts instead of replacing them. For the thesis argument itself, use story-syns-coach.
---

# Plan the thesis outline

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, read from the author's latest own prose and never from a bare command or the English this run loads, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

**Inputs.** Resolve `% degree_level` from `degree/profile.tex`, stopping to ask if it is unknown (conventions §1). If `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, or `notes/claims.md` is absent, stop and route to `story-syns-coach`. If `notes/story.md` is not `status: finalized`, report and route it there too, continuing only if the author chooses a provisional outline (an `AGENTS.md` §1 choice), recorded with its date at the top of `notes/outline.md` and stated in the handoff. When `% thesis_type` in `degree/profile.tex` is empty, ask the author for it (monograph, publication-based, hybrid, or the official term) and record the stated value on that line (conventions §1, Degree-level contract). Before proposing anything, read the published-work row of `degree/requirements.md`, `notes/adopt.md` when present, the active entry point, and every file under `manus/chaps/`, deriving each existing chapter's current purpose from its text.

**Plan.** Propose each chapter's full brief (conventions §5) and test the plan for:

- a visible thesis-level argument: with reused publications, an architecture rather than a paper bundle, and `as-published` chapters only where conventions §5 allows them;
- foundations introduced before use;
- limited repetition of methods and related work;
- explicit transitions between multiple research chapters;
- degree-appropriate synthesis, with a separate synthesis chapter only when the confirmed rules or research arc require one;
- accurate attribution and publication reuse.

In master mode, infer no minimum chapter, study, contribution, or publication count. The architecture, and every later rename, renumber, split, merge, or removal, is an `AGENTS.md` §1 chapter-boundary choice: write nothing until the author confirms it. Then:

1. Create `notes/outline.md`, or reconcile an existing one, keeping its rows, `F`/`T` IDs, and statuses and keying chapter rows by `File`. Spell its headings and column headers exactly as here (conventions §1):
   - `## Chapters`: `Chapter | File | Purpose | Contributions | Claims | Status`;
   - `## Figures` and `## Tables`: `ID | File | Purpose | Claims | Evidence | Chapter | Status`, with IDs and `Chapter` cells as conventions §3 defines;
   - `## Chapter briefs`: one `### <n>_<slug>` block per chapter with the fields `Research questions`, `Required evidence`, `Figures/tables`, `Dependencies`, `Exit condition`, and `Inclusion` (`adapt` | `as-published`).

   Set row statuses only as conventions §3 (Who sets each status) assigns them to this skill.
2. Scaffold `manus/chaps/<n>_<slug>.tex` only for a chapter with no file, never over an existing one. Carry out a confirmed rename or renumber with `git mv`, content unchanged.
3. For a confirmed split or merge of drafted chapters, record the migration map (source section → target chapter) under `## Migration map` in `notes/outline.md`, move the text verbatim in this run, update the `Stated in` cell of every moved claim in `notes/claims.md` in the same change, and mark an emptied chapter `retired` rather than deleting it. Route rewording to `story-chap-drafter`. For a confirmed removal, mark the chapter's row `retired` and keep its file, drop its path from each claim's `Stated in`, and retire each claim left with no path in a file the entry point builds, asking first when it maps to a confirmed contribution and ticking any `## Claims` line of `tasks/audits.md` keyed by it (conventions §3, Who sets each status).
4. Keep `Chapters` in `notes/contributions.md` and `Candidate chapters` in `notes/publications.md` in step with the outline, dropping a removed chapter's path, and after a rename, renumber, split, or merge rewrite every cell naming an old chapter path (conventions §7, Ownership); list every rewritten file, and name `story-refs-curator` when `notes/refs/refs_index.md` still cites one.
5. Keep one chapter `\input` line per non-retired chapter in the active entry point, in outline order, and none for a retired one.
6. Create or seed `notes/notation.md` with `Symbol or term | Meaning | First use | Scope`: the first two cells free text, `First use` a repository-relative manuscript path or empty, and `Scope` `thesis-wide | <chapter path>`.
7. Build, then lint (conventions §8); lint must report no chapter file the entry point omits unless its outline row is `retired`.

Never replace an existing note with a scaffold.
