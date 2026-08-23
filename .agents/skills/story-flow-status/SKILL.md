---
name: story-flow-status
description: Read the complete STORY repository state and report dissertation progress, evidence health, chapter/claim/contribution coverage, milestone gates, build status, and exactly one recommended next action without writing files.
---

# Report dissertation workflow status

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. This skill is strictly read-only.

Run the bundled `scripts/scan.sh` from the repository root, then summarize:

- degree profile and unchecked institutional requirements;
- dissertation story and contribution-map readiness;
- chapter, figure, and table states from the outline;
- claim counts by status and evidence-manifest integrity signals;
- publication reuse or attribution rows still open;
- bibliography and reading-note coverage;
- active milestone, feedback promises, defense/deposit gates;
- latest build, page count, and lint signal.

Distinguish absent, unknown, stale, blocked, and complete states. Treat an absent `notes/*.md` artifact in a fresh or partially initialized repository as an uninitialized workflow stage, not as corruption, and recommend its first creator from conventions §1 when it is the earliest gate. Recommend exactly one next action with the owning `story-*` skill and a concrete target. Do not turn the status run into the recommended action.
