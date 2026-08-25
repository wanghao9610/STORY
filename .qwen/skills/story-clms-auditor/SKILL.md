---
name: story-clms-auditor
description: Audit master's or doctoral thesis numbers, comparisons, and degree-contribution claims against source anchors, the claim ledger, and fingerprinted evidence; use before reviews, defense, deposit, or after evidence changes.
argument-hint: "[CHAPTER | CLAIM_ID | full] [DESCRIPTION]"
---

# Audit claims and numbers

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

This skill is read-only on `manus/` and `mates/`. Scan the requested chapter, claim, or full thesis. For every quantitative or comparative statement, follow the nearby `% src:` anchor and claim-ledger link. Verify the evidence fingerprint, re-read the value and context, and assign a run verdict of `matched`, `mismatched`, or `unsourced` in the report. Verdicts are report vocabulary, not ledger statuses: in `notes/claims.md` write only the canonical statuses from conventions §3 — `matched` becomes `verified`; `unsourced` becomes `unsourced`; `mismatched` becomes `weakened` when the author confirms a narrower defensible scope, otherwise `unsourced` until the wording or evidence is corrected.

Check that each degree contribution is supported across its mapped chapters, does not overstate the candidate's individual role, and uses claim strength appropriate to the confirmed degree level. Do not audit a master's contribution against a generic doctoral originality threshold. Run `execs/scpts/import.sh --diff` for reachable imported sources.

Update only claim statuses and audit notes in `notes/claims.md`; write detailed regenerable findings under `wkdrs/reports/` and one checkbox per failure in `tasks/audits.md`, creating the file on first use. Route fixes to the owner of the manuscript, table, figure, evidence, or contribution map.
