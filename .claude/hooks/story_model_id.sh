#!/usr/bin/env bash
# STORY SessionStart hook — inject the runtime-reported model id into session
# context so skills record a real model_id instead of "unrecorded".
#
# Claude Code puts a `model` field on the SessionStart payload, and nowhere else:
# no other hook event carries it, and there is no $CLAUDE_MODEL env var. It is
# absent whenever the session did not start fresh — after /clear, resume,
# compact, or fork — which in practice is most sessions. And when it is present
# it is a snapshot of one moment: /model switches the model without any hook
# firing, so a session that starts on one model and writes with another would
# record the one it started on.
#
# Both holes have the same floor. Claude Code stamps `message.model` on every
# assistant turn it appends to the session transcript, and the payload always
# carries `transcript_path`. That transcript is empty at SessionStart, so the
# read cannot happen here; instead the injected line hands the skill the command
# to run at the moment it needs the value, which is also the moment the answer is
# true. The SessionStart field is passed along to that command, because it is the
# more precise of the two when they agree: it may carry a context-window suffix
# the transcript drops (claude-opus-5[1m] -> claude-opus-5).
#
# Registered under hooks.SessionStart in .claude/settings.json. Prints one JSON
# object whose additionalContext is added to context before the first prompt.
#
# SessionStart does not fire for a sub-agent, and STORY registers no
# SubagentStart mount: its skills dispatch no delegate that records a model id.
# A delegate started some other way — a workflow script, the Agent tool — sees
# the session's line, and resolving the session's transcript from inside it
# answers with the model that dispatched it. What it needs is its own
# transcript, which --resolve below reads when it is handed one.

# --resolve <transcript_path> [session_model]: print the model id of the last
# assistant turn in a transcript, or nothing at all. Run on demand by skills,
# per the line injected below. Prints nothing rather than failing, so
# "unrecorded" stays the fallback.
#
# Which turns count depends on which transcript this is. In a session
# transcript, sidechain turns are skipped: a delegated sub-agent may run a
# different model, and the question this answers is which model is writing the
# artifact. A delegate's own transcript — .../subagents/agent-<id>.jsonl, or
# .../subagents/workflows/wf_<id>/agent-<id>.jsonl for a delegate a workflow
# script dispatched; a separate file as of Claude Code 2.1.260, with the session
# transcript carrying none of those turns any more — holds nothing but that
# delegate's turns and marks every one of them as sidechain, so the same filter
# there would drop every turn and leave nothing to record. The path, not the
# flag, is what tells a delegate's file apart. A flat delegate path that cannot
# be read here is looked up by its file name under the subagents/ directory it
# names, which finds the workflow layout too.
#
# session_model is what SessionStart reported, and settles the two ways the
# transcript alone is not enough. It stands in when the transcript names nothing
# yet, and it is preferred over an identical id to keep a context-window suffix
# the transcript drops. It never wins over a different id — that difference is a
# mid-session switch, and the transcript is the one that saw it. A delegate
# passes none, because the session's model is not the delegate's.
if [ "${1:-}" = "--resolve" ]; then
    transcript="${2:-}"
    session_model="${3:-}"
    resolved=""
    if [ -n "${transcript}" ] && [ ! -r "${transcript}" ]; then
        case "${transcript}" in
            */subagents/agent-*.jsonl)
                found=$(find "$(dirname "${transcript}")" -type f \
                    -name "$(basename "${transcript}")" 2>/dev/null | head -1)
                [ -n "${found}" ] && transcript="${found}" ;;
        esac
    fi
    case "${transcript}" in
        */subagents/*agent-*.jsonl) delegate=true ;;
        *) delegate=false ;;
    esac
    if [ -n "${transcript}" ] && [ -r "${transcript}" ]; then
        if command -v jq >/dev/null 2>&1; then
            if [ "${delegate}" = true ]; then
                filter='select(.type == "assistant") | .message.model // empty'
            else
                filter='select(.type == "assistant" and (.isSidechain | not)) | .message.model // empty'
            fi
            # Lines are read raw and a malformed one is skipped, as the python3
            # reader skips it: jq would otherwise stop at it and lose every turn
            # after it.
            resolved=$(jq -rR "fromjson? | ${filter}" \
                "${transcript}" 2>/dev/null | grep -vx '<synthetic>' | tail -1)
        elif command -v python3 >/dev/null 2>&1; then
            resolved=$(python3 - "${transcript}" "${delegate}" <<'PY' 2>/dev/null
import json, sys

path, delegate = sys.argv[1], sys.argv[2] == "true"
last = ""
with open(path, errors="replace") as fh:
    for line in fh:
        try:
            entry = json.loads(line)
        except Exception:
            continue
        if entry.get("type") != "assistant":
            continue
        if not delegate and entry.get("isSidechain"):
            continue
        model = (entry.get("message") or {}).get("model")
        if model and model != "<synthetic>":
            last = model
print(last)
PY
            )
        fi
    fi

    if [ -z "${resolved}" ]; then
        [ -n "${session_model}" ] && printf '%s\n' "${session_model}"
        exit 0
    fi
    # Same model, richer string: claude-opus-5[1m] over claude-opus-5.
    case "${session_model}" in
        "${resolved}"|"${resolved}["*) printf '%s\n' "${session_model}" ;;
        *) printf '%s\n' "${resolved}" ;;
    esac
    exit 0
fi

input=$(cat)

# Read one top-level string field from the payload.
payload_field() {
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "${input}" | jq -r --arg k "$1" '.[$k] // empty' 2>/dev/null
    elif command -v python3 >/dev/null 2>&1; then
        printf '%s' "${input}" | python3 -c 'import sys, json
try:
    print(json.load(sys.stdin).get(sys.argv[1]) or "")
except Exception:
    print("")' "$1" 2>/dev/null
    else
        printf '%s' "${input}" \
            | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
            | head -1 | sed -E 's/.*"([^"]*)"$/\1/'
    fi
}

# ctx embeds a filesystem path and the backslashes that quote a command's
# arguments for the shell, so encode it as JSON rather than assuming it is
# quote-free. The last branch, having no encoder to hand, escapes the two
# characters a one-line JSON string cannot hold bare; stripping them instead
# would undo the quoting the injected command relies on.
emit_context() { # $1 = the context text
    if command -v jq >/dev/null 2>&1; then
        jq -cn --arg c "$1" \
            '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import sys, json
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": sys.argv[1]}}))' "$1"
    else
        printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
            "$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
    fi
}

model=$(payload_field model)
transcript=$(payload_field transcript_path)
# The path the injected command carries is relative to the project root, not
# absolute: `permissions.allow` in .claude/settings.json matches a command by
# its literal prefix, and an absolute path is machine-specific, so no committed
# allow entry could ever match one — and a delegate cannot answer the prompt an
# unmatched command raises, so it is simply denied. Every STORY skill runs its
# commands from the project root (`bash execs/...`), which is what makes the
# relative form resolve.
self=".claude/hooks/story_model_id.sh"
# The arguments go through the shell the agent runs the command in, which is
# often zsh: a bare `claude-opus-5[1m]` is a glob there, and an unmatched glob
# fails the whole command before the resolver runs, leaving nothing printed, so
# the writer falls back to an id its context states, which /model may have
# staled, or to "unrecorded". So each is quoted for the shell; the allow rule matches
# the command's prefix, which the quoting leaves alone.
printf -v transcript_arg '%q' "${transcript:-}"
printf -v model_arg '%q' "${model:-}"

if [ -n "${transcript:-}" ]; then
    ctx="STORY provenance: read this session's model id when you record it, not from memory — the runtime states it at session start only, and /model changes it afterwards without saying so. Before you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), run: bash ${self} --resolve ${transcript_arg}${model:+ ${model_arg}} — then copy what it prints verbatim. If it prints nothing, copy the model id this session's own context states outright (Claude Code's system prompt names one); write 'unrecorded' only when none is stated, and do not guess."
elif [ -n "${model:-}" ]; then
    ctx="STORY provenance: this session's runtime-reported model id is ${model}, and the runtime named no transcript to check it against later. When you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), copy this exact string verbatim; do not write 'unrecorded'. If you switch models mid-session, this string is the one you started with, not the one writing."
else
    ctx="STORY provenance: the SessionStart payload carried no model id for this session and named no transcript to recover it from. When you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), copy the model id this session's own context states outright (Claude Code's system prompt names one); write 'unrecorded' only when none is stated, and do not guess."
fi

emit_context "${ctx}"
