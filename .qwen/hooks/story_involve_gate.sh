#!/usr/bin/env bash
# Skip Claude's permission prompt for file edits while the project runs at
# INVOLVE=low (.env, writing workflow conventions §7). Confirmation points are
# untouched: the STOP line, deletions and overwrites, and every institutional-requirement value
# entering as confirmed are questions a skill asks, not permission prompts a hook
# can answer.
#
# Silence means "no decision", so every other level, every path this declines,
# and a project with no .env fall through to the normal permission flow. INVOLVE
# is read on each call, so editing .env takes effect without a restart.
set -uo pipefail

root="${QWEN_PROJECT_DIR:-${PWD}}"

line="$(grep -sE '^INVOLVE=' "${root}/.env" | tail -1)"
value="${line#INVOLVE=}"
value="${value%%#*}"
involve="$(printf '%s' "${value}" | tr -cd '[:alpha:]')"
[[ "${involve}" == "low" ]] || exit 0

input=$(cat)

# The edited path, from Edit/Write (file_path) or NotebookEdit (notebook_path).
edited_path() {
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "${input}" \
            | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null
    else
        printf '%s' "${input}" \
            | grep -oE '"(file_path|notebook_path)"[[:space:]]*:[[:space:]]*"[^"]*"' \
            | head -1 | sed -E 's/.*"([^"]*)"$/\1/'
    fi
}

path="$(edited_path)"
case "${path}" in
    "${root}"/*) ;;
    *) exit 0 ;;
esac

# Dot-directories at the project root — .git, .claude, .story, the other tool
# trees — keep their prompt, the way acceptEdits mode keeps one for protected
# paths. Their contents are project machinery, not the manuscript, the notes, or
# the milestone files a run is writing. A `..` component keeps its prompt too:
# the root-prefix match above is textual, so without this a path spelled
# `<root>/manus/../..` would read as inside the project while pointing out of it.
case "${path#"${root}"/}" in
    .*|*/..|*/../*) exit 0 ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"INVOLVE=low"}}\n'
