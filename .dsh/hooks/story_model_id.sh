#!/usr/bin/env bash
# STORY SessionStart hook (DeepSeek Harness) — inject the runtime-reported model
# id into session context so skills record a real model_id instead of "unrecorded".
#
# DSH has no hook table of its own; it runs STORY's hooks through its Claude Code
# bridge, and that bridge's SessionStart payload carries session_id, cwd and
# transcript_path but no `model` — DSH's own bridge README lists `model` among
# the fields it omits. Nor is there one in the environment: the managed DSH_*
# variables reach the model's own shell calls, not a hook process. So nothing at
# session start can state the model, and the value has to be read where DSH
# writes it.
#
# DSH does write it. Every session log carries a `request/context` record with
# the resolved provider and model, appended whenever the route changes, so the
# last one is the model in force; `request/header` carries the same pair inside
# its call config, as a second place to look. The payload's transcript_path
# names that log. It is empty at SessionStart, so the read cannot happen here;
# instead the injected line hands the skill the command to run at the moment it
# needs the value, which is also the moment the answer is true. That is the same
# shape the Claude Code copy uses, for the same reason, over a different log.
#
# Registered under hooks.SessionStart in .dsh/hooks.json. Prints one JSON object
# whose additionalContext is added to context before the first prompt — the
# bridge consumes that field and ignores plain stdout, so prose would run,
# succeed, and inject nothing.

# --resolve [transcript_path]: print `provider/model` for the last route the
# session log records, or nothing at all. Run on demand by skills, per the line
# injected below. With no argument it falls back to $DSH_SESSION_JSONL, which
# DSH puts in the environment of every model shell call — that is what answers
# after a compaction has taken the injected line away. Prints nothing rather
# than failing, so "unrecorded" stays the fallback.
if [ "${1:-}" = "--resolve" ]; then
    transcript="${2:-${DSH_SESSION_JSONL:-}}"
    [ -n "${transcript}" ] && [ -r "${transcript}" ] || exit 0

    # DSH stores the log as concatenated Zstandard frames by default, and as
    # plain lines only when a deployment sets compression: 'none'. The frames
    # need the zstd command: Node decodes just the first one, which holds the
    # session header and no route at all, so a decoder that stops there would
    # confidently report nothing while looking like it worked. Without the
    # command this exits silently — one hook is not worth a dependency.
    case "${transcript}" in
        *.zst|*.zstd)
            command -v zstd >/dev/null 2>&1 || exit 0
            decode() { zstd -dcq -- "${transcript}" 2>/dev/null; } ;;
        *)
            decode() { cat -- "${transcript}" 2>/dev/null; } ;;
    esac

    # Both record shapes, newest wins. A line that is not JSON — a packed chunk
    # row, a partial tail — is skipped rather than ending the scan.
    if command -v jq >/dev/null 2>&1; then
        resolved=$(decode | jq -rR 'fromjson?
            | if .type == "request/context" then .data
              elif .type == "request/header" then .data.header.config
              else empty end
            | select(.model != null)
            | if .provider == null or .provider == "" then .model else "\(.provider)/\(.model)" end' \
            2>/dev/null | tail -1)
    elif command -v python3 >/dev/null 2>&1; then
        resolved=$(decode | python3 -c 'import json, sys

last = ""
for line in sys.stdin:
    try:
        entry = json.loads(line)
    except Exception:
        continue
    if entry.get("type") == "request/context":
        route = entry.get("data") or {}
    elif entry.get("type") == "request/header":
        route = ((entry.get("data") or {}).get("header") or {}).get("config") or {}
    else:
        continue
    model = route.get("model")
    if not model:
        continue
    provider = route.get("provider")
    last = f"{provider}/{model}" if provider else model
print(last)' 2>/dev/null)
    else
        resolved=""
    fi

    [ -n "${resolved}" ] && printf '%s\n' "${resolved}"
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

transcript=$(payload_field transcript_path)
# The path the injected command carries is relative to the project root, not
# the bridge's CLAUDE_PROJECT_DIR: dsh takes the invoking directory as the
# workspace, every STORY skill runs its commands from that root (`bash
# execs/...`), and a project directory with a space in it would split an
# absolute path into two words. The transcript path goes through the shell the
# agent runs the command in, often zsh, where a space would split it the same
# way and leave the resolver reading a file that does not exist; so it is
# quoted for the shell.
self=".dsh/hooks/story_model_id.sh"
printf -v transcript_arg '%q' "${transcript:-}"

if [ -n "${transcript:-}" ]; then
    ctx="STORY provenance: read this session's model id when you record it, not from memory — DSH states no model at session start, and the route can change afterwards without saying so. Before you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), run: bash ${self} --resolve ${transcript_arg} — then copy what it prints verbatim. If it prints nothing, copy the model id this session's own context states outright; write 'unrecorded' only when none is stated, and do not guess."
else
    ctx="STORY provenance: DSH named no session log for this session, so the model id cannot be recovered from it. Before you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), try: bash ${self} --resolve — with no argument it reads DSH_SESSION_JSONL from the shell environment. If it prints nothing, copy the model id this session's own context states outright; write 'unrecorded' only when none is stated, and do not guess."
fi

# ctx embeds a filesystem path and the backslashes that quote a command's
# arguments for the shell, so encode it as JSON rather than assuming it is
# quote-free. The last branch, having no encoder to hand, escapes the two
# characters a one-line JSON string cannot hold bare; stripping them instead
# would undo the quoting the injected command relies on.
if command -v jq >/dev/null 2>&1; then
    jq -cn --arg c "${ctx}" \
        '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import sys, json
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": sys.argv[1]}}))' "${ctx}"
else
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
        "$(printf '%s' "${ctx}" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
fi
