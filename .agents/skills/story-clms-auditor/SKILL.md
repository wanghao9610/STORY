---
name: story-clms-auditor
description: Audit dissertation numbers, comparisons, and contribution claims against source anchors, the claim ledger, and fingerprinted evidence; use before reviews, defense, deposit, or after evidence changes.
---

# Audit claims and numbers

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

This skill is read-only on `manus/` and `mates/`. Scan the requested chapter, claim, or full dissertation. For every quantitative or comparative statement, follow the nearby `% src:` anchor and claim-ledger link, verify the evidence fingerprint, re-read the value and context, and assign `matched`, `mismatched`, or `unsourced`.

Also check that each doctoral contribution is supported across its mapped chapters and does not overstate the candidate's individual role. Run `execs/scpts/import.sh --diff` for reachable imported sources.

Update only claim statuses and audit notes in `notes/claims.md`; write detailed regenerable findings under `wkdrs/reports/` and one durable task per failure under `tasks/`. Route fixes to the owner of the manuscript, table, figure, evidence, or contribution map.
