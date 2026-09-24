#!/usr/bin/env bash
# Skip Qwen Code's permission prompt for file edits while the project runs at
# INVOLVE=low (.env, writing workflow conventions §7). Confirmation points
# (conventions §7) are untouched: they are questions a skill asks, not
# permission prompts a hook can answer.
#
# Silence means "no decision", so every other level, every path this declines,
# and a project with no .env fall through to the normal permission flow. INVOLVE
# is read on each call, so editing .env takes effect without a restart.
set -uo pipefail

root="${QWEN_PROJECT_DIR:-${PWD}}"

# The payload is read before the level is tested: the runtime writes it to this
# hook's stdin, and a hook that exits without reading leaves that write to fail.
input=$(cat)

line="$(grep -sE '^INVOLVE=' "${root}/.env" | tail -1)"
value="${line#INVOLVE=}"
value="${value%%#*}"
involve="$(printf '%s' "${value}" | tr -cd '[:alpha:]')"
[[ "${involve}" == "low" ]] || exit 0

# The edited path, from edit/write_file (file_path) or notebook_edit
# (notebook_path).
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

# Dot-directories at the project root — .git, .qwen, .story, the other tool
# trees — keep their prompt, the way auto-edit mode keeps one for protected
# paths. Their contents are project machinery, not the manuscript, the notes, or
# the milestone files a run is writing. A `..` component keeps its prompt too:
# the root-prefix match above is textual, so without this a path spelled
# `<root>/manus/../..` would read as inside the project while pointing out of it.
#
# So do the thesis's protected records, at every level: the evidence store
# mates/ (AGENTS.md §1 — written only through execs/scpts/import.sh and
# story-evid-curator, whose edits you approve here), the confirmed institutional
# facts in degree/, and received committee feedback in miles/*/feedback/.
case "${path#"${root}"/}" in
    .*|*/..|*/../*) exit 0 ;;
    mates|mates/*|degree|degree/*|miles/*/feedback|miles/*/feedback/*) exit 0 ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"INVOLVE=low"}}\n'
