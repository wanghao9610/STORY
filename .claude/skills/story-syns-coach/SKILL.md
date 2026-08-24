---
name: story-syns-coach
disable-model-invocation: true
description: Shape or revise a master's or doctoral thesis-level problem, central argument, research questions, research arc, synthesis, and degree contributions from the author's intent and registered evidence; use before outlining or when the thesis lacks a coherent argument.
argument-hint: "[DESCRIPTION] [involve=high]"
---

# Shape the degree-level synthesis

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

Resolve `% degree_level: master|doctoral` from `degree/profile.tex` before framing the problem or contributions. If it is missing or invalid, stop and ask the author to confirm and record it; never infer it from the work's apparent ambition or publication history. Apply the level-specific contract in conventions §1 and any confirmed institutional rubric.

Load `degree/profile.tex`, the relevant registered evidence, and `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, and `notes/claims.md` where present. Interview the author only for judgments the repository cannot supply: the intended thesis, contribution boundaries, attribution, exclusions, and how the research changed over time.

On first use, initialize any absent artifact immediately before writing it; never overwrite an existing file with a scaffold. Use the IDs, field formats, and statuses defined in conventions §3 with these schemas:

- `notes/story.md`: frontmatter keys `status: discovery`, `active_milestone: ""`, and `updated: <system date>`; headings `One-sentence thesis`, `Research problem`, `Central argument`, `Research questions`, `Research arc`, `Cross-chapter synthesis`, and `Scope and limitations`; accept the legacy `Doctoral problem` heading in an existing file, but do not rename it without author confirmation;
- `notes/contributions.md`: `ID | Contribution | Research question | Evidence | Publications | Chapters | Attribution | Status`;
- `notes/publications.md`: `ID | Citation / artifact | Authors | Candidate chapters | Reused material | Permission / policy | Author contribution | Status`;
- `notes/claims.md`: `ID | Claim | Contribution | Stated in | Evidence | Status | Notes`.

Initialize the story as `discovery`, new contributions as `proposed`, new publication/reuse rows as `candidate` until the author confirms them in scope, and new claims as `proposed`. Promote only when the corresponding definition in conventions §3 is satisfied.

Create the paired `*.zh-CN.md` artifact in the same change, following conventions §1 and §7.

Produce:

1. a one-sentence thesis that is arguable and supportable;
2. the degree-appropriate research problem and research questions;
3. an ordered research arc explaining the relationship among contributions, or the bounded path through a single-study master's thesis;
4. thesis-level synthesis proportionate to the confirmed degree: original cross-study synthesis in doctoral mode where the arc requires it, and integration of the bounded evidence in master mode without inventing a multi-paper requirement;
5. limitations and scope;
6. publication/reuse rows in `notes/publications.md` for each paper, preprint, or collaborative artifact actually in scope, without assuming a master's thesis has publications;
7. contribution rows in `notes/contributions.md`, linked to evidence, publications, chapters, and attribution;
8. proposed claim rows in `notes/claims.md`.

The author must confirm the central argument and contribution/attribution map before marking `notes/story.md` finalized. In master mode, do not inflate a bounded contribution into a doctoral originality claim; in doctoral mode, do not waive confirmed originality or synthesis requirements. Do not choose institutional rules or chapter files in this skill.
