# Pursue a thesis goal

The author has typed `story-auto`, and this file is what that invocation runs. Typing it is the goal-run grant of the workflow conventions §8 (Goal runs): the one request that already authorizes a multi-step workflow. While this run pursues its goal, it may start, without asking again, each unmarked skill that a `Next action:` line names toward that goal, and, where a named action does not advance the goal, the unmarked skill that owns the goal's own next step (The loop, step 1). A started run behaves exactly as if the author had typed its name: the same scope, the same confirmation points, the same artifact ownership. The grant covers nothing else. It never starts a skill marked † in the roster (conventions §9), never answers an ask-first choice of `AGENTS.md` §1 on the author's behalf, and never widens what a started run may write.

Invocation shape: `story-auto <GOAL> [involve=<level>]`.

## Parse the invocation

- Strip `involve=<level>` first, wherever it sits (conventions §7). This run's level is that token; with no token, it is `INVOLVE` in `.env`, and `medium` when that is absent, unset, or invalid. A plain-language instruction during the run changes it as §7 says. A goal run has no default of its own: it resolves the level exactly as every skill does.
- What remains is the goal, in the author's own words: `story-auto chapter 3 drafted and audited`, `story-auto a mock examination of the current draft for the pre-defense milestone`. With no goal, ask for one. Never infer a goal from the repository.
- One goal per invocation. The next goal is the next invocation.

## Before the loop

Read `STORY_LANG`, `INVOLVE` and `STORY_MAIN` from `.env` once (conventions §7), and reply in the language §7 resolves. Then turn the goal into a check this run can verify on disk, such as:

- a row status in `notes/outline.md`: a chapter, figure, or table reaching `in-progress` or `ready`;
- claim statuses in `notes/claims.md`: the chapter's claim IDs audited during this invocation, none left `drafted`;
- a file this invocation writes, such as `miles/<slug>/simulations/SIM_EXAM_<date>.md`, `wkdrs/reports/SIM_EXAM_<date>.md` when no milestone applies, or an audit report under `wkdrs/reports/`, each created or rewritten during this invocation; a file left by an earlier session, even one dated today, proves nothing;
- `bash execs/run.sh` building the manuscript.

A status check trusts only the setters conventions §3 (Who sets each status) names: a row is `ready` because its writing skill set it, and a claim leaves `drafted` only through the runs that section lists.

Green lint is never the check, even when the goal mentions lint. A visible `\todo` keeps lint red by design (conventions §8), so a run waiting for green lint would never end: the lint verdict is reported, not pursued. A goal that names lint is turned into the concrete findings it points at, such as a chapter's unresolved citation keys, or it is asked about.

A goal that cannot be turned into such a check is asked about, not pursued. A goal that only an action outside the grant could meet (What a goal run never does, below), such as confirming the thesis argument, importing evidence, or a deposit being ready, is not pursued either: name the command or author action that owns it as the `Next action:`, and stop.

Open with one line stating the check and the resolved level, and repeat it as the first line of the final reply, since text written between tool calls may never reach the author.

## The loop

1. Run `story-flow-status` through the harness's native skill mechanism and take its one `Next action:`. Every next action, from status or from a run, passes the goal filter first. An action that does not advance the goal's check is not taken: say so in one line, list it in the final reply, and take the goal's own next step instead. That step is the skill that owns the goal's target, provided the prerequisites that target needs exist. Every target needs a valid `degree_level` in `degree/profile.tex`. A chapter, table, or figure also needs a `finalized` `notes/story.md`, or a provisional outline the author chose (recorded at the top of `notes/outline.md`, conventions §3); a chapter then needs its brief in `notes/outline.md`, and a table or figure needs `notes/outline.md` and `notes/notation.md`, a `new` one adding its own `planned` row. An appendix needs the brief of the chapter that references it. Any other target, such as the abstract or other front matter, a milestone simulation, an audit, or a reference, needs only the inputs its owning skill names. If one is missing, the step is the owner of the first missing prerequisite in the gate order of conventions §8 (Completion handoff).
2. Take what the action names:
   - **An unmarked skill.** Announce one line (what matched, which target), then start it through the harness's native skill mechanism with this run's resolved level appended as an `involve=<level>` token, or with the level the handoff line spelled out when that one asks more. One unit of work per start: one chapter or front/back-matter file per `story-chap-drafter` run, one table, one figure. `story-evid-curator` starts only in its read-only `check` mode.
   - **A skill marked †.** The run never starts one, and dispatches nothing else to run it. Stop, and print its exact `/story-<name> <argument>` command as this run's `Next action:`, with `involve=<level>` spelled out when the level differs from the one `.env` resolves to (conventions §8).
   - **An author action**, such as confirming `degree_level` in `degree/profile.tex` or recording an institutional requirement: stop, and name that action, with the file or fact to confirm, as the `Next action:`.
   - **An action outside the grant** (below): stop, and name it as the `Next action:`, the command the author would type or the author action, without taking it.
3. Questions. An unsettled target names its candidates and waits. A confirmation point (conventions §7) and an `AGENTS.md` §1 ask-first choice are asked and waited on at every involve level, whichever run raises them. The loop never answers one itself. Where nobody can answer, as in a headless run, it stops there and reports. A judgment call a started run hands back is answered at `low` with its recommended safe option and listed in the final reply; at `medium` and `high` it goes to the author. Once a question is answered, start the same skill again on the same target, with the question and its answer passed along; a skill that resumes from disk picks up where it stopped.
4. After each run ends, take the next action its `Next action:` line names, through the goal filter and step 2. Where it names none, or names `none`, run `story-flow-status` again.
5. An action that failed is not retried on the same target. The fix a failure routes to, such as a missing reading note to `story-refs-curator` or a failed build to the chapter whose source broke, is itself a next action, taken once through step 2. When that fails too, stop.

## What a goal run never does

These stay outside the grant whatever the goal says and whatever level resolves. The run stops at the first one it would need and names it as its `Next action:` instead of taking it:

- start a skill marked †: `story-proj-adopt`, `story-syns-coach`, `story-outl-planner`, `story-revs-resolver`, `story-defn-builder`, or `story-depo-packer`;
- import, register, or refresh evidence: nothing in a goal run writes `mates/` (`AGENTS.md` §1);
- write anything under `degree/`, whose facts only the author confirms;
- write or edit received feedback under `miles/*/feedback/`;
- declare a deposit ready, or report any check as deposit readiness: only the author's own `story-depo-packer` run freezes a deposit;
- answer a confirmation point or an `AGENTS.md` §1 ask-first choice on the author's behalf;
- commit, push, or tag: the author reviews the runs' changes and commits them;
- launch long-running work in the background or wait on it;
- write a note, prose, or report of its own: every file it leaves behind was written by a run it started.

## Where it ends

Report and stop at the first of:

- the goal's check passes;
- the next action that bears on the goal is a skill marked †, an author action, or an action outside the grant;
- a mandatory question has nobody to answer it;
- a full pass made no progress. A pass is one `story-flow-status` run and every action it led to, a restart after an answered question included. It made no progress when it wrote no durable file under `manus/`, `notes/`, `tasks/`, or `miles/*/simulations/` and moved no status field (conventions §3) or `tasks/` checkbox. A build, or a report regenerated under `wkdrs/`, is not progress;
- step 5 runs out of moves.

The final reply lists:

- first, the goal's check and the resolved level;
- the runs, and the files each one wrote;
- the build path and page count, and the lint verdict, from the last run that built; red lint is a remaining gate, not a failure (conventions §8);
- the ledger rows that changed;
- the goal check's result;
- the actions skipped as not advancing the goal, and the judgment calls taken at `low`;
- why the run stopped: the check passing, the † command, author action, or action outside the grant it reached, the pending question verbatim, that a full pass made no progress, or the failed action and its error.

It ends with exactly one `Next action:` line (conventions §8): the † command, author action, or action outside the grant where the run stopped; for a mandatory question nobody could answer, the author action of answering it and typing the same `story-auto` invocation again; after a pass with no progress or a failed fix, the concrete action most likely to clear the block; the earliest remaining gate when the check passed and work remains; or `Next action: none — the requested workflow is complete.` Nothing carries between invocations. Typing the command again resumes from the repository as the runs left it.
