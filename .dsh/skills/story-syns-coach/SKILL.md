---
name: story-syns-coach
disable-model-invocation: true
description: Shape or revise the dissertation-level problem, central argument, research questions, research arc, synthesis, and doctoral contributions from the author's intent and registered evidence; use before outlining or when the thesis feels like disconnected papers.
---

# Shape the doctoral synthesis

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

Load `degree/profile.tex`, the relevant registered evidence, and `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, and `notes/claims.md` where present. Interview the author only for judgments the repository cannot supply: the intended thesis, contribution boundaries, attribution, exclusions, and how the research changed over time.

On first use, initialize any absent artifact immediately before writing it; never overwrite an existing file with a scaffold. Use these schemas:

- `notes/story.md`: frontmatter keys `status: discovery`, `active_milestone: ""`, and `updated: <system date>`; headings `One-sentence thesis`, `Doctoral problem`, `Central argument`, `Research questions`, `Research arc`, `Cross-chapter synthesis`, and `Scope and limitations`;
- `notes/contributions.md`: `ID | Contribution | Research question | Evidence | Publications | Chapters | Attribution | Status`;
- `notes/publications.md`: `ID | Citation / artifact | Authors | Candidate chapters | Reused material | Permission / policy | Author contribution | Status`;
- `notes/claims.md`: `ID | Claim | Contribution | Stated in | Evidence | Status | Notes`, with the statuses defined in conventions §3.

Create the paired `*.zh-CN.md` artifact in the same change, following conventions §1 and §7.

Produce:

1. a one-sentence thesis that is arguable and supportable;
2. the doctoral problem and research questions;
3. an ordered research arc explaining why each contribution follows from the previous one;
4. cross-chapter synthesis that is not present in any individual paper;
5. limitations and scope;
6. publication/reuse rows in `notes/publications.md` for each paper, preprint, or collaborative artifact in scope;
7. contribution rows in `notes/contributions.md`, linked to evidence, publications, chapters, and attribution;
8. proposed claim rows in `notes/claims.md`.

The author must confirm the central argument and contribution/attribution map before marking `notes/story.md` finalized. Do not choose institutional rules or chapter files in this skill.
