---
name: story-clms-auditor
description: Audit master's or doctoral thesis numbers, comparisons, and degree-contribution claims against source anchors, the claim ledger, and fingerprinted evidence; use before reviews, defense, deposit, or after evidence changes.
argument-hint: "[CHAPTER | CLAIM_ID | full] [DESCRIPTION]"
---

# Audit claims and numbers

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

This skill is read-only on `manus/` and `mates/`. Scan the requested chapter, claim, or full thesis. For every quantitative or comparative statement, follow the nearby `% src:` anchor and claim-ledger link. Verify the evidence fingerprint, re-read the value and context, and assign `matched`, `mismatched`, or `unsourced`.

Check that each degree contribution is supported across its mapped chapters, does not overstate the candidate's individual role, and uses claim strength appropriate to the confirmed degree level. Do not audit a master's contribution against a generic doctoral originality threshold. Run `execs/scpts/import.sh --diff` for reachable imported sources.

Update only claim statuses and audit notes in `notes/claims.md`; write detailed regenerable findings under `wkdrs/reports/` and one durable task per failure under `tasks/`. Route fixes to the owner of the manuscript, table, figure, evidence, or contribution map.
