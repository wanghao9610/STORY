# Maintaining STORY harnesses

`.agents/skills/` is the neutral authored source for all sixteen master's/doctoral thesis skills. The six private skill roots (`.claude`, `.cursor`, `.dsh`, `.kimi-code`, `.pi`, `.qwen`) are generated entry trees; do not edit a linked file there.

Codex metadata is the one exception to this storage direction: `.codex/skills/<name>/agents/openai.yaml` owns each manifest, and `.agents/skills/<name>/agents/openai.yaml` links to it because Codex discovers the neutral root. `allow_implicit_invocation: false` marks the six explicit-only skills, and their private `SKILL.md` files are generated with `disable-model-invocation: true`.

## `argument-hint` does not port

`argument-hint` is **not** in the neutral source. `port.sh` owns one hint per skill and injects it only where the harness reads it, so `.claude` and `.qwen` hold generated `SKILL.md` files rather than links.

| Tree | `argument-hint` | Why |
|---|---|---|
| `.claude` | generated into the manifest | Claude Code reads it and shows it in the `/` menu |
| `.qwen` | generated into the manifest | Qwen Code reads it; `allowedTools` stays out, because it grants rather than restricts |
| `.agents` | never | this is Codex's discovery root, and its marketplace validator rejects any key outside `name`, `description`, `license`, `allowed-tools`, and `metadata` |
| `.cursor` | never | Cursor's frontmatter table is closed without it |
| `.dsh`, `.kimi-code` | never | the key is kept and ignored — an inert field nothing reports |
| `.pi` | prompt templates only | not a skill field in Pi, so the hint rides in `.pi/prompts/<skill>.md` instead |

Every hint follows the shape in [conventions §7](../docs/mds/story-workflow/writing-workflow-conventions.md), `[TARGET] [DESCRIPTION] [involve=<level>]`, and every skill's hint ends with `[involve=LEVEL]`. Uppercase placeholders are author-supplied values and lowercase words are literal modes; targets, modes, and tokens stay English everywhere. A new skill needs its hint in `argument_hint()` in `port.sh`; the port fails loudly rather than shipping a skill without one. No tree carries `allowed-tools`: pre-approval outside Claude is a project- or user-level config change with a wider scope than the turn-scoped Claude equivalent.

A field only Claude Code reads stays out of the neutral source for the reason `argument-hint` does: `.agents` is Codex's discovery root, whose validator rejects unknown keys. `claude_frontmatter()` in `port.sh` owns one table per skill and renders its lines into `.claude/skills/<name>/SKILL.md` alone, right after the name: today it gives `story-flow-status` `effort: medium`, and no other skill carries one. `check_consistency.sh` reads that table from `port.sh` rather than keeping its own list, so a new row needs no second edit: it fails on `effort`, `model`, `context`, or any key the table renders when it appears in another tree or on a skill the table does not give it, fails when a Claude manifest lacks a line the table gives it, and fails if the table stops giving `story-flow-status` `effort: medium`. `port.sh --check` compares every rendered manifest byte for byte, so a field edited by hand in a generated manifest fails the check.

Each manifest opens with a **Shared conventions** paragraph whose source is conventions §7: load the conventions in full, read `.env` once for `STORY_LANG`, `INVOLVE`, and `STORY_MAIN`, resolve the reply language in one order, keep the manuscript language in `degree/profile.tex`, and let a clear instruction authorize routine work without replacing a confirmation point or an `AGENTS.md` §1 ask-first choice. `check_consistency.sh` validates that every manifest in all seven trees names `.env`, `STORY_LANG`, `INVOLVE`, and `STORY_MAIN`; it checks their presence, not the paragraph's wording.

After editing a neutral skill or a Codex policy, run:

```bash
bash .github/scripts/port.sh --write
bash .github/scripts/check_consistency.sh
```

`port.sh --check` verifies both content and storage shape. A byte-identical private file must be a relative link into `.agents`; a harness-only file must be a real file. Commands, prompts, hooks, and settings remain in their harness directories because their invocation syntax, events, payloads, or registration mechanisms differ.

The workflow conventions name a specific harness, hook event, or configuration path only in §11 (harness adapters): invocation spelling, explicit-only enforcement, hook registration, and per-harness model-id provenance live there, and §1–§10 hold the shared rules. Project memory is §10 and the writing rules are §5's human-writing contract; there are no separate spec files. Every skill loads the conventions in full, so per-harness mechanics a run never acts on (hook events, registration files, resolver internals, plugin reinstalls, which trees show `argument-hint`) go in `docs/mds/story-workflow/harness-reference.md`, which no skill loads; §11 keeps only what a run copies or obeys. `check_consistency.sh` rejects a harness name, a hook event or harness-private key that §11 uses, and a harness-only skill spelling before §11, pins the section headings that skills and hooks cite by number, and fails if a retired spec file or a path to one comes back. Renumbering a section means re-auditing every `§n` and `section n` citation of the conventions first.

Hooks are maintained by hand in each harness tree, so a change to one reaches every copy of it. `story_commit_guard.sh` ships in all seven trees (Pi's under `.pi/extensions/story-hooks/`), and everything below its `STORY shared guard core` marker is byte-identical: edit it once in `.claude/hooks/`, then copy it to the other six. `check_consistency.sh` diffs each copy against the `.claude` one. What the hooks decide is behavior, which a grep cannot pin, so `.github/scripts/test_hooks.sh` runs them against fixture payloads, and `check_consistency.sh` runs that script. The fixtures pin the gates' red lines: a write into `mates/` other than through `bash execs/scpts/import.sh`, into `degree/`, or into `milestones/*/feedback/` keeps its prompt at every level. They also pin the level resolver's rule that a Skill call may raise the typed level but never lower it, the model-id resolvers, and each guard's fallback when no JSON parser is on PATH. Add fixtures with every gate or resolver change, and confirm that a new fixture fails against the old hook before you rely on it.

Behavior also needs a task-level check. After a change to authorization or routing (an involve rule, a gate, the `/story` router, the `/story-auto` goal-run procedure, a manifest's shared conventions, or a skill's confirmation points), run independent representative scenarios in fresh sessions: a local edit, a read-only status request that must end with its report, work the author already authorized that must not be asked for again, an ask-first boundary from `AGENTS.md` §1 (a chapter-boundary or attribution change) that must still be asked at `INVOLVE=low`, a write into a protected record, and a `/story-auto` goal whose next step is a skill marked †, which must stop and print that skill's command instead of starting it. Fixtures and wording checks do not establish that a model makes the right decision.

`AGENTS.md` ships to every thesis and `.github/` does not, so maintainer-only policy, such as the en/zh pairing and landing-page rules below, belongs in this guide, which `AGENTS.md` names only through an upstream-only pointer. `AGENTS.md` points to the conventions instead of restating them, and they win over it on any conflict except its §1 ask-first choices and §8 memory-offer rule; change a shared rule in the conventions and leave `AGENTS.md` a pointer.

`.cursor/rules/agent-instructions.mdc` repeats the `AGENTS.md` body under four lines of rule frontmatter and a blank line, so Cursor applies it as an always-on rule. Change both in the same commit, most simply by rewriting the rule's body from `AGENTS.md`; `check_consistency.sh` fails on any drift between them. It compares from line 6 of the rule (`tail -n +6`), so a new frontmatter key there means updating that offset in `check_consistency.sh`.

To run the same consistency checks automatically before every push — the script `.github/workflows/consistency.yml` runs on GitHub — enable the tracked pre-push hook once per clone:

```bash
git config core.hooksPath .github/hooks
```

A failing check declines the push; `git push --no-verify` or `STORY_SKIP_CHECKS=1` skips it once.

`execs/update.sh` follows and materializes links when updating or adopting another thesis repository, so the upstream template stays deduplicated and no downstream installation depends on an unselected harness tree.

Instructions and the workflow conventions are English only: `SKILL.md` has no Chinese edition, and neither do `AGENTS.md`, the conventions, this guide, or the `/story-auto` procedure and its harness entry points. A run in Chinese follows the English instructions and replies in Chinese. Five Markdown files ship with a Simplified Chinese twin, because a person or a run reads it: `README.zh-CN.md`, `docs/mds/story-workflow/writing-workflow-skills.zh-CN.md`, `.agents/commands/story.zh-CN.md` (the Codex and Kimi `/story` routers read it for Chinese wording), and `degree/committee.zh-CN.md` and `degree/requirements.zh-CN.md`. Change both halves of a pair in the same commit, keeping paths, IDs, structural keys, commands, status values, code blocks, and runtime policy equivalent; the degree guides are reading aids, and degree facts are recorded only in the English files. `check_consistency.sh` requires both halves of each pair and rejects any other `*.zh-CN.md` or `*_zh.md` file; it also requires the same dated entries under the READMEs' `## Change log` and `## 更新日志`, so a release note lands in both. The Chinese landing page `docs/htmls/story_zh.html` (served as `docs/index_zh.html`) is kept in step with `docs/htmls/story.html` the same way, and `manus/main-zh.tex` with the Chinese front and back matter it inputs (`fronts/*-zh.tex`, `backs/*_zh.tex`) is the Chinese thesis starter, not a translation.

A file STORY stops shipping to theses goes on `RETIRED_FILES` in `execs/update.sh`, so an update deletes the downstream copy instead of leaving it behind; a `SKILL_zh.md` beside a shipped `SKILL.md` and a `.pi/prompts/<name>.zh-CN.md` beside a shipped prompt are retired by rule. `check_consistency.sh` fails if a retired file comes back, and runs the updater against a fixture thesis (`.github/scripts/test_update_retired.sh`) to confirm that an update still previews, deletes, and reports every retired file while keeping the thesis's own.

STORY is the template every thesis starts from, and a clone or the GitHub template copies `.story/memory/` as it stands, so a memory about developing STORY would arrive in every thesis as a fact about that thesis. Upstream's own memories therefore never enter the versioned store: record them under the git-ignored `.story/memory/local/`, whatever their scope. `check_consistency.sh` fails when anything beyond `.story/memory/.gitkeep` would ship there, and applies that check only in the upstream repository (`wanghao9610/STORY`), so a thesis that kept `.github/` can version its own memories. The same script runs all seven `story_memory.sh` copies with `--list` against a fixture store and requires the same index from each, so a change to one copy's parsing has to reach the other six.
