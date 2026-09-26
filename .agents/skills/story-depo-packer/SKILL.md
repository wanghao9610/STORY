---
name: story-depo-packer
description: Use only for a named deposit milestone of a finished thesis. Preflights every deposit gate against confirmed institutional requirements, packages the final PDF with a checksummed inventory, and writes the freeze record; never uploads, submits, pushes, commits, or changes the manuscript. For a read-only progress report, use story-flow-status.
---

# Package the thesis deposit

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, read from the author's latest own prose and never from a bare command or the English this run loads, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Resolve the degree level and the named, institutionally applicable `deposit` milestone; create a missing `milestone.yml` or change its status only per conventions §6 (Milestone lifecycle).

Preflight every gate of conventions §6 (Deposit gates), reporting each as pass or fail with its evidence: the command and its `Result:` line, the file and row, or the path read. Check gate 8 first, recording `git rev-parse HEAD` as the source commit, then run `bash execs/scpts/lint.sh`, which builds first. Beyond the list:

- gate 1: whenever lint did not print a numeric `Page limit: <n>/<limit> (miles/<slug>/milestone.yml)` line for this milestone, compare its `max_pages` with the PDF's page count yourself as the evidence, and never change a milestone's status during preflight; match each unwired-chapter warning against that chapter's `notes/outline.md` row;
- gate 2: read every checked row too, since lint and the status scan count only unchecked boxes, for its applicability and source, including a page limit's recorded counting rule, and check the format against any `official_template` in `degree/profile.tex`;
- gate 5: compare each `Last full run:` date in `tasks/audits.md` with `git log -1 --format=%cs -- manus mates`; on the same date, ask whether the audit followed that change, and at `low` count the gate as failing;
- gate 7: no script checks it, so read `degree/profile.tex`, the entry point, and every front- and back-matter file it inputs.

This skill fixes nothing: after reporting every gate, route the earliest failure to its owner or name the author action (conventions §7, Ownership; §8, Completion handoff), and do not freeze. A failed preflight is reported and routed, never recorded as `blocked`.

When every gate passes, ask the author to confirm the freeze and whether to tag it; both are confirmation points at every level (conventions §7). Then:

1. copy the final PDF and required sources into `wkdrs/builds/deposit/<slug>/`;
2. create a confirmed tag with `git tag -a <name> <source commit>`, never on an implicit `HEAD`;
3. write `miles/<slug>/RECORD_<date>.md` as conventions §6 (Deposit gates) lists, and set `status: completed` in `milestone.yml` in the same change.

Institution-facing text, such as a cover note, follows conventions §7 (Language and profile). Never commit: ask the author to commit the RECORD and `milestone.yml` and to archive the deposited files outside the repository. Never upload, submit, publish, or push anything, or edit the thesis (conventions §7, Git and outward transfer).
