---
name: story-revs-resolver
disable-model-invocation: true
description: Use after thesis feedback or an official outcome arrives from supervisors, coauthors, committees, examiners, defenses, corrections, or deposits. Converts it into an immutable-source point ledger, reasoned dispositions, tracked promises, and outcome records, without rewriting chapters. For a simulated review, use story-exam-reviewer.
---

# Resolve thesis feedback

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Resolve the milestone: the one the invocation names, else the active one, else ask; informal supervisor or coauthor feedback tied to no institutional event goes to `milestones/supervision/` (conventions §6, Milestone lifecycle). When it is unclear which applies, ask at every level: copied feedback is never moved. Create a missing `milestone.yml`, change a milestone's status, or record an official outcome the author supplies only as that section says.

Copy what the author supplies into `feedback/` unchanged — never retyped, trimmed, or summarized — then read every file without editing it (conventions §6, Feedback and promises). A generated review enters the ledger only when the author explicitly asks, and a kept `wkdrs/reports/SIM_EXAM_<date>.md` is first copied unchanged into `simulations/`.

In the point ledger under `milestones/<slug>/response/`, give each actionable point a stable ID, its exact source location, the affected chapters, claims, and contributions, one disposition, a rationale, an owner skill, and completion evidence; open and tick promise boxes in `tasks/<slug>_promises.md`, keyed by point ID, as conventions §6 says. On a rerun, copy a ticked box's evidence into the point that becomes `completed`; record the disposition the author settles for a `needs-author` point, and tick its box unless the point became `planned`. Handle a conceded claim as conventions §3 (Who sets each status) assigns this skill.

Ask before recording a `disagreed` point, conceding a claim mapped to a confirmed contribution, or finalizing committee-facing text (conventions §7); at `low`, record such a point as `needs-author`, leave such a claim unchanged, keep such text as a draft, and say so.

Never rewrite chapters or alter received comments.
