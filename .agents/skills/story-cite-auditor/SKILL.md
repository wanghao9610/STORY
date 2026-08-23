---
name: story-cite-auditor
description: Audit thesis citation keys, bibliography hygiene, literature assertions, missing citations, and cross-chapter citation consistency against verified records and reading notes; use for master's or doctoral work and never silently repair prose.
---

# Audit citations and literature assertions

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

This skill is read-only on `manus/`, the bibliography, and reading notes. Check that every citation key resolves, every cited-work assertion is supported by a reading note or imported source checked in this run, and claim-bearing background statements have appropriate citations.

Detect duplicate records, incomplete identity fields, inconsistent citekeys, secondary-source substitution, citation drift between chapters, and bibliography entries never cited. Do not judge a work from its title or abstract alone when the manuscript makes a detailed claim.

Write a regenerable report under `wkdrs/reports/` and durable tasks for failures. Route metadata work to `story-refs-curator` and prose changes to `story-chap-drafter`. Do not add citations merely to increase count.
