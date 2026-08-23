---
name: story-flow-status
description: Read the complete STORY repository state and report master's or doctoral thesis progress, degree-level validity, evidence health, chapter/claim/contribution coverage, applicable milestone gates, build status, and exactly one recommended next action without writing files.
---

# Report thesis workflow status

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. This skill is strictly read-only.

Run the bundled `scripts/scan.sh` from the repository root, then summarize:

- degree level, profile consistency, and unchecked institutional requirements;
- thesis story and contribution-map readiness under the confirmed level;
- chapter, figure, and table states from the outline;
- claim counts by status and evidence-manifest integrity signals;
- publication reuse or attribution rows still open;
- bibliography and reading-note coverage;
- active milestone, feedback promises, and only the defense/deposit gates applicable to the confirmed degree;
- latest build, page count, and lint signal.

Distinguish absent, unknown, invalid, stale, blocked, and complete states. An absent or invalid degree level is the earliest gate for any level-specific workflow; recommend exactly one author action—confirm `degree/profile.tex`—rather than assuming a mode, because no skill owns institutional facts. Otherwise, treat an absent `notes/*.md` artifact in a fresh or partially initialized repository as an uninitialized workflow stage, not as corruption, and recommend its first creator from conventions §1 when it is the earliest remaining gate. Recommend exactly one next action with the owning `story-*` skill and a concrete target. Do not turn the status run into the recommended action.
