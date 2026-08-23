---
name: story-revs-resolver
disable-model-invocation: true
description: Convert supervisor, committee, examiner, defense, correction, or deposit feedback into an immutable-source point ledger, reasoned dispositions, and tracked promises; use after feedback arrives.
---

# Resolve dissertation feedback

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. Resolve the milestone and read every file in its `feedback/` directory without editing those files.

Create a point ledger under `milestones/<slug>/response/` with one stable ID per actionable point, the exact source location, affected chapters/claims/contributions, disposition, rationale, owner skill, and completion evidence. Use only these dispositions: `accepted`, `completed`, `planned`, `disagreed`, and `needs-author`.

Mirror every promised manuscript or artifact change as a checkbox in `tasks/<slug>_promises.md`. Downgrade a conceded claim in `notes/claims.md` when the feedback changes its defensible scope. Ask the author before a substantive disagreement, contribution change, or committee-facing response.

This skill records and reasons about feedback; it does not rewrite chapters or alter received comments.
