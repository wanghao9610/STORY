---
name: story-syns-coach
disable-model-invocation: true
description: Use before outlining, when the thesis lacks a coherent argument, or to record an author-supplied publication reuse or permission fact. Shapes the thesis problem, central argument, research questions, arc, synthesis, and degree contributions from the author's intent and registered evidence, with the contribution, publication, and claim maps. For chapter architecture, use story-outl-planner.
argument-hint: "[DESCRIPTION] [involve=LEVEL]"
---

# Shape the degree-level synthesis

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

**Inputs.** Resolve `% degree_level` from `degree/profile.tex` before framing the problem or contributions; if it is unknown, stop and ask (conventions §1), never inferring it from the work's apparent ambition or publications. Apply the §1 level contract and any confirmed rubric in `degree/requirements.md` or a milestone's `requirements_source`. Load the relevant registered evidence and, where present, the four records below. When `notes/adopt.md` exists or `manus/chaps/` holds drafted chapters, first read `notes/adopt.md` and the draft's abstract, introduction, and conclusion as the author's stated intent, not evidence, and propose the problem, research questions, and contributions they state for the author only to confirm or correct. Interview the author only for what the repository cannot supply: the intended thesis, contribution boundaries, attribution, exclusions, how the research changed over time, and each in-scope publication's permission or program-policy status with its source.

**Record-only path.** A request that only records an author-supplied publication reuse or permission fact, with its source, updates only that row's cells as conventions §3 (Who sets each status) allows, then stops: no synthesis rerun and no `notes/story.md` status change.

**Records.** Never overwrite an existing file with a scaffold (conventions §1). Spell keys, headings, and column headers exactly as here, with the IDs and field formats of conventions §3:

- `notes/story.md`: frontmatter `status: discovery` and `updated: <system date>`; headings `One-sentence thesis`, `Research problem`, `Central argument`, `Research questions` (one list item per question, IDs `RQ1`, `RQ2`, …), `Research arc`, `Thesis-level synthesis`, and `Scope and limitations`. Accept the legacy `Doctoral problem` and `Cross-chapter synthesis` headings in an existing file, renaming them only with author confirmation;
- `notes/contributions.md`: `ID | Contribution | Research question | Evidence | Publications | Chapters | Attribution | Status`;
- `notes/publications.md`: `ID | Citation / artifact | Authors | Candidate chapters | Reused material | Permission / policy | Author contribution | Status`;
- `notes/claims.md`: the claims columns of conventions §3.

Set statuses only as conventions §3 (Who sets each status) assigns them to this skill. Match an existing claim row, adopted rows included, before adding one; once contribution IDs are author-confirmed, fill the `Contribution` cell of existing claim rows. Once `notes/outline.md` exists, leave `Chapters` and `Candidate chapters` to `story-outl-planner` (conventions §7, Ownership).

Produce:

1. an arguable, supportable one-sentence thesis;
2. the degree-appropriate research problem and research questions;
3. an ordered research arc explaining how the contributions relate, or the bounded path through a single-study master's thesis;
4. synthesis proportionate to the confirmed degree (conventions §1, Degree-level contract), in master mode integrating the bounded evidence;
5. limitations and scope;
6. `notes/publications.md` once the author confirms the reuse map: a row for each paper, preprint, or collaborative artifact actually in scope, never assuming a master's thesis has publications; with none in scope, the dated confirmed-absence line (conventions §1) and `none` in each contribution's `Publications` cell;
7. contribution and claim rows.

In master mode, never inflate a bounded contribution into a doctoral originality claim; in doctoral mode, never waive confirmed originality or synthesis requirements. Choose no institutional rules or chapter files here.
