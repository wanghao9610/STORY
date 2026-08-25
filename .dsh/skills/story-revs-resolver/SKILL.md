---
name: story-revs-resolver
disable-model-invocation: true
description: Convert master's or doctoral thesis feedback from supervisors, committees, examiners, defenses, corrections, or deposits into an immutable-source point ledger, reasoned dispositions, and tracked promises; use after feedback arrives.
---

# Resolve thesis feedback

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. Then resolve the milestone; if its directory or `milestone.yml` does not exist yet, create it from author-confirmed facts per conventions §6 before anything else. This skill owns feedback ingestion: copy feedback the author supplies verbatim into `feedback/` — never retyped, trimmed, or summarized — then read every file there; do not edit them. Generated simulations under `simulations/` enter the ledger only when the author explicitly asks.

Create a point ledger under `milestones/<slug>/response/`. Each actionable point gets one stable ID, its exact source location, the affected chapters/claims/contributions, a disposition, a rationale, an owner skill, and completion evidence. Use only these dispositions: `accepted`, `completed`, `planned`, `disagreed`, and `needs-author`.

Mirror every promised manuscript or artifact change as a checkbox in `tasks/<slug>_promises.md`. Downgrade a conceded claim in `notes/claims.md` when the feedback changes its defensible scope. Ask the author before a substantive disagreement, contribution change, or committee-facing response.

This skill records and reasons about feedback; it does not rewrite chapters or alter received comments.
