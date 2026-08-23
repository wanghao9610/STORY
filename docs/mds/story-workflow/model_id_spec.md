# Model-id Fallbacks

**Language:** English | [简体中文](model_id_spec.zh-CN.md)

The per-runtime detail behind the `model_id` rule in [`writing-workflow-conventions.md`](writing-workflow-conventions.md) §8. Read it when the provenance line a hook injects is missing, or carries a recovery command in place of an id. The rule itself — record what the runtime reports for the writing session, verbatim, and never guess — stays in §8 and is not repeated here.

## How each runtime reports it

| Runtime | Hook | Event | What it injects | When the value is read |
|---|---|---|---|---|
| Claude Code | `.claude/hooks/story_model_id.sh` | `SessionStart` | a command reading the session transcript; the id itself when none was named | as you write it |
| Codex | `.codex/hooks/story_model_id.sh` | `SessionStart` | a command reading the session rollout; the id itself when none was named | as you write it |
| Cursor | `.cursor/hooks/story_model_id.sh` | `SessionStart` | the id | at session start |
| DeepSeek Harness | `.dsh/hooks/story_model_id.sh` | `SessionStart` | a command reading DSH's session log | as you write it |
| Kimi | `.kimi-code/hooks/story_model_id.sh` | `UserPromptSubmit` | `default_model` from `~/.kimi-code/config.toml` | from config, never the session |
| Pi | `.pi/extensions/story-hooks/story_model_id.sh` | `before_agent_start` and `model_select` | the live provider/model id | immediately before the writing run |
| Qwen Code | `.qwen/hooks/story_model_id.sh` | `SessionStart` | a command reading the Qwen transcript; the id itself when none was named | as you write it |

The last column is the difference that matters. A value read as the artifact is written cannot be stale; Cursor and Kimi can be, because a mid-session model switch changes nothing they read. A hook that exists is not necessarily active: DSH and Kimi need their one-time installers, Codex hooks require approval, Pi extensions require project trust, while Claude, Cursor, and Qwen load project registration files automatically.

## Claude Code and Codex, why the id is read at the moment it is written

The `model` field rides on `SessionStart` alone: it is omitted after `/clear`, resume, compact, or fork, and where it is present it describes the moment the session opened — `/model` changes the model afterwards with no hook firing, so a session that starts on one model and writes with another would record the one it started on. Both runtimes keep a per-turn record of what actually ran, so whenever the payload names one the injected line carries a command instead of an id. Run it as you record the value:

```bash
bash "$CLAUDE_PROJECT_DIR"/.claude/hooks/story_model_id.sh --resolve <transcript_path> [session_model]
bash .codex/hooks/story_model_id.sh --resolve <transcript_path> [session_model]
```

with the arguments that line already fills in, and record what it prints verbatim. Claude Code's reader takes `message.model` off this session's own main-loop assistant turns, skipping a delegated subagent's — the question is which model is writing the artifact. Codex's takes `payload.model` off the rollout's `turn_context` records and skips nothing, because a Codex subagent is given a rollout of its own. Either way it is the runtime's record rather than a guess. `session_model` is what `SessionStart` reported: it stands in when the record names nothing yet, and it wins over an identical id to keep a suffix the record drops (`claude-opus-5[1m]` over `claude-opus-5`), but never over a different one — that difference is a mid-session switch, and the per-turn record is the one that saw it.

## DeepSeek Harness and Qwen Code

DSH records provider/model routes in its session log; Qwen records the model on assistant transcript rows. Their injected provenance lines already contain the exact command and path to run. The fallback forms are:

```bash
bash .dsh/hooks/story_model_id.sh --resolve [transcript_path]
bash .qwen/hooks/story_model_id.sh --resolve <transcript_path> [session_model]
```

Pi needs no recovery command: its extension receives the live model object immediately before the agent run and reinjects provenance after `model_select`.

## Kimi, when no line was injected at all

Kimi's `SessionStart` cannot inject context and exposes no model id, so its hook runs on `UserPromptSubmit` and injects the configured `default_model` — which is stale if the model was overridden mid-session. Slash-command skill activation does not pass through that event, so a skill opened before any plain user message has seen nothing. Run one read yourself before writing `unrecorded`:

```bash
grep -E '^[[:space:]]*default_model[[:space:]]*=' "${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
```

and record the value verbatim — still self-reported, still possibly stale.

## When `unrecorded` is the right answer

Only when the session names no model anywhere: a runtime that states none, and every read above also empty. Never infer the id from behavior, never reason about which model this is "probably", and never copy one artifact's value into another.
