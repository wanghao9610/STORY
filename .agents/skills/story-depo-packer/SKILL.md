---
name: story-depo-packer
description: Preflight, package, and freeze a final master's or doctoral thesis deposit from confirmed institutional requirements; use only for a named deposit milestone, never to upload, submit, push, or silently change the manuscript.
---

# Package the thesis deposit

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. Resolve the degree level and a named, institutionally applicable `deposit` milestone; require author confirmation before freezing anything.

Preflight all hard gates:

1. `bash execs/run.sh` and `bash execs/scpts/lint.sh` pass;
2. every required box in `degree/requirements.md` is checked with a source;
3. every approval required for this degree level and the milestone facts are recorded;
4. no open promise remains under `tasks/`;
5. claim and citation audits have no unresolved hard failures;
6. publication reuse, attribution, and permissions are resolved;
7. the official format, naming, accessibility, file-size, embargo, and license rules are confirmed.

Copy the final PDF and required sources into `wkdrs/builds/deposit/<slug>/`, create checksums and a file inventory, then write `milestones/<slug>/RECORD_<date>.md`. Create a freeze tag only after explicit confirmation. Never upload to a portal, push a tag, or edit the thesis in this skill.
