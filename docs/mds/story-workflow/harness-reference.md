# STORY harness reference

Maintainer reference for how each harness runs STORY's hooks and entry points. No skill loads this file: the rules a run follows are in [`writing-workflow-conventions.md`](writing-workflow-conventions.md), whose §11 (harness adapters) gives each harness's invocation spelling, explicit-only enforcement, the resolver commands a run copies, and the fallback reads. This file records the mechanics behind them, and where the two disagree the conventions win.

## Entry points

Codex and Kimi Code copy a plugin when it is installed, so an installed copy gains a new entry, such as `story-auto`, only after the plugin is installed again. Only Claude Code and Qwen Code show a skill's `argument-hint`; Pi reads the hint from the skill's prompt template under `.pi/prompts/`. Only Claude Code reads a skill's `effort:` field, and only its copy of `story-flow-status` sets one (`effort: medium`); no other tree carries an equivalent.

## Hooks and events

Each tree's `hooks/` directory (Pi: `.pi/extensions/story-hooks/`) holds `story_model_id.sh`, `story_memory.sh`, and `story_commit_guard.sh`. The commit guard runs before a shell command: on `PreToolUse` in Claude Code, Codex, DSH, Kimi Code, and Qwen Code, on `beforeShellExecution` in Cursor, and on `tool_call` in Pi. Claude Code, Codex, and Qwen Code add `story_involve_gate.sh`, which answers the edit permission prompt at `INVOLVE=low`; Claude Code alone adds `story_bash_gate.sh` for its shell prompt and `story_involve_level.sh`, which reads the `involve=` token of the session's latest typed STORY command for both gates. The memory hook fires on the provenance hook's event, except in Codex, where it takes every `SessionStart` source, including after `/clear`, while the provenance hook matches `startup` and `resume` only.

## Registration and model provenance

| Harness | Registered in | Provenance line: event → what it injects → when the value is read |
| --- | --- | --- |
| Claude Code | `.claude/settings.json`, loaded automatically | `SessionStart` → a `--resolve` command over the session transcript; the id itself when no transcript was named → as you write |
| Codex | `.codex/hooks.json`, active once approved with `/hooks` | `SessionStart` (`startup`, `resume`) → the exact `session_model_id`, a `--resolve` command over the rollout, and the `--check` command → as you write, then after |
| Cursor | `.cursor/hooks.json`, loaded automatically | `sessionStart` → the id → at session start |
| DSH | `.dsh/hooks.json`, enabled by `bash .dsh/hooks/install.sh` and the per-profile hooks bridge | `SessionStart` via the bridge → a `--resolve` command over the session log, which needs `zstd` on PATH when the log is compressed → as you write |
| Kimi Code | no project config: `bash .kimi-code/hooks/install.sh` writes the entries `.kimi-code/hooks.example.toml` shows into the global `config.toml`, once per machine | `UserPromptSubmit` → `default_model` from `~/.kimi-code/config.toml` → from config, never the session |
| Pi | `.pi/extensions/story-hooks/index.ts`, loaded once the project is trusted | `before_agent_start`, again after `model_select` changes the model → the live provider/model id → at the prompt that uses it |
| Qwen Code | `.qwen/settings.json`, loaded automatically | `SessionStart` → a `--resolve` command over the transcript; the id itself when no transcript was named → as you write |

`execs/update.sh` keeps a thesis's own registration files and names any STORY hook they do not register, to be added by hand. A value read as you write cannot be stale; Cursor's and Kimi's can, because a mid-session model switch changes nothing they read, while Pi's latest injected line names the writing model.

## Resolvers

`.claude/settings.json` ships the allow rule the Claude Code resolver command needs. The Claude Code and Codex resolvers read the runtime's per-turn record and prefer the session-start id only when it names the same model, keeping a suffix the record drops (`claude-opus-5[1m]` over `claude-opus-5`); Qwen Code's prints the transcript's id whenever it has one; DSH's falls back to `DSH_SESSION_JSONL` when no path is given and takes no session model. STORY registers no `SubagentStart` hook, because no STORY skill dispatches a delegate that records `model_id`. The Codex `--check` compares an artifact's `model_id` with the resolver's output, else the exact session-start id, else `unrecorded`.
