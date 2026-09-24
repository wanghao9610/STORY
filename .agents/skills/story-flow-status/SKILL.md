---
name: story-flow-status
description: Use when the thesis state is unclear or the author asks for status or the next step. Reads the whole STORY repository and reports degree-level validity, evidence health, chapter/claim/contribution coverage, applicable milestone gates, build and lint state, and exactly one recommended next action. Strictly read-only; writes no files.
---

# Report thesis workflow status

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Strictly read-only. From the repository root, run `scripts/scan.sh` in this skill's own directory, then summarize from these scan lines:

- from `Degree`: degree level, thesis type, and dissertation language (an empty value is unconfirmed and an off-list one invalid, never a fact), and `unresolved requirement rows:`, which counts unchecked boxes only;
- the thesis story status and contribution-map readiness under the confirmed level, flagging a `discovery` story beside an existing outline (conventions §3, Who sets each status);
- from `Status counts`: outline, claim, contribution, publication (open means `candidate` or `in-scope`), and reference statuses;
- `integrity:` (`ok`, `tampered`, `missing`, `unregistered`; conventions §3); the scan does not check upstream `stale`, so route it to `story-evid-curator check`;
- `bibliography entries:` against index rows (an entry without a row is `unverified`) and reading-note coverage;
- each milestone's kind and status and the `active milestone:` line, reporting a `supervision` record only through its open promises;
- only the milestone gates the confirmed degree applies, with the state of each deposit gate the scan can see (conventions §6, Deposit gates), never declaring readiness, which only `story-depo-packer` does;
- `Open tasks` by file (`tasks/prose.md` is advisory), and each `Last full run:` date, read from `tasks/audits.md`, which the scan does not print;
- the entry point, page count, `build: current|stale`, `todo markers:`, and `lint:` (the `Result:` of `lint.sh --no-build` when the build is current, otherwise `not run`);
- any `Legacy translated twins`, author-owned files no skill maintains (conventions §1).

Distinguish absent, unknown, invalid, stale, blocked, and complete states. Give exactly one next action as conventions §8 (Completion handoff) directs, an absent `notes/*.md` artifact being an uninitialized stage its first creator owns (conventions §1). An absent or invalid degree level comes first for any level-specific workflow: no skill owns institutional facts, so the one recommendation is the author action of confirming `degree/profile.tex`, never an assumed mode. The report ends the run and never starts the skill it recommends.
