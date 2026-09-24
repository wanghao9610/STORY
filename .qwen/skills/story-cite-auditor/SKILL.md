---
name: story-cite-auditor
description: Use to audit what a thesis already cites: citation keys, bibliography hygiene, literature assertions, missing citations, and cross-chapter consistency, checked against verified records and reading notes. Reports failures and never silently repairs prose. For adding or verifying a source record, use story-refs-curator.
argument-hint: "[CHAPTER | full] [DESCRIPTION] [involve=LEVEL]"
---

# Audit citations and literature assertions

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Read-only on `manus/`, the bibliography, and reading notes. Audit the named chapter, or the whole thesis (`full` or no target).

1. Check that every citation key resolves, every cited-work assertion has the support conventions §2 requires, and claim-bearing background statements carry appropriate citations. A claim-bearing assertion fails when its key is `stale` in `notes/refs/refs_index.md`, or has neither a `content-verified` row nor an imported source checked in this run.
2. Detect duplicate records, incomplete identity fields, inconsistent citekeys, and secondary-source substitution. Never judge a work from its title or abstract alone when the manuscript makes a detailed claim.
3. Only in a thesis-wide run, check citation drift between chapters, never-cited bibliography entries, and `Used in chapters` cells that differ from the `\cite` keys in `manus/`.

Put a regenerable report under `wkdrs/reports/`, and one checkbox per failure, keyed by citekey and location, in `## Citations` of `tasks/audits.md`, created on first use and reconciled for the keys this run audited (conventions §6, Feedback and promises); only a thesis-wide run sets its `Last full run:` to the system date. Route record, index, and reading-note failures to `story-refs-curator`, and prose or `\cite` placement to `story-chap-drafter`. Do not add citations merely to increase the count.
