---
name: story-clms-auditor
description: Use before reviews, defense, or deposit, or after evidence changes, to audit a thesis's numbers, comparisons, and degree-contribution claims against source anchors, the claim ledger, and fingerprinted evidence. Read-only on the manuscript and evidence. For citation keys and literature assertions, use story-cite-auditor.
argument-hint: "[CHAPTER | CLAIM_ID[,CLAIM_ID...] | full] [DESCRIPTION] [involve=<level>]"
---

# Audit claims and numbers

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, read from the author's latest own prose and never from a bare command or the English this run loads, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Read-only on `manus/` and `mates/`. Audit the named chapter, one claim ID or a comma-separated list (`C003,C007`), or the whole thesis (`full` or no target).

1. Follow each quantitative or comparative statement's source anchor and claim-ledger row (conventions §2), confirm the cited file is registered evidence, and re-read the value and its context in this run.
2. For each imported slug the audited claims cite, run `bash execs/scpts/import.sh --diff --source <dir> --slug <slug>` and read its per-file lines as conventions §3 does; `<dir>` is the entry's `- source:` minus the file's path under `mates/<slug>/` (`## proj/results/a.csv` with `- source: /work/proj/results/a.csv` gives `/work/proj`). Route a `stale`, `tampered`, or `missing` file to `story-evid-curator`.
3. Set claim status by verdict (conventions §3, Who sets each status): `matched` → `verified`, with the §3 `Notes` stamp; `mismatched` with an author-confirmed narrower scope → `weakened`, noting the narrowing and the audit date, and still a failure line in `## Claims` until a rerun finds the narrowed wording `matched`; `unsourced`, or any other `mismatched` → `unsourced` until the wording or evidence is corrected. At `low`, an unconfirmed narrower scope stays `unsourced`, with the proposed wording in the report.
4. Check that each degree contribution is supported across its mapped chapters, does not overstate the candidate's individual role, and uses claim strength fit for the confirmed degree level (conventions §1, Degree-level contract). Move its `Status` between `confirmed` and `evidenced` as §3 directs, promoting only in a thesis-wide run.

In the ledgers, change only the `Status` and `Notes` cells of `notes/claims.md` and a contribution's `Status`, routing every other fix to its owner (conventions §7, Ownership). Put detailed findings under `wkdrs/reports/`, and one checkbox per failure, keyed by claim ID or location, in `## Claims` of `tasks/audits.md`, created on first use and reconciled for the keys this run audited (conventions §6, Feedback and promises); only a thesis-wide run sets its `Last full run:` to the system date.
