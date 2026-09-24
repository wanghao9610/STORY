#!/usr/bin/env bash
# Skip Claude's permission prompt for file edits while the project runs at
# INVOLVE=low (.env, writing workflow conventions §7). Confirmation points
# (conventions §7) are untouched: they are questions a skill asks, not
# permission prompts a hook can answer.
#
# The level comes from story_involve_level.sh: the `involve=` token of the
# session's most recent STORY command, or `.env`'s INVOLVE when it carried none.
# Silence means "no decision", so every other level, every path this declines,
# and a project that sets none fall through to the normal permission flow. The
# level is resolved on each call, so a new invocation — or an edit to .env —
# takes effect without a restart.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-${PWD}}"

# The payload is read before the level is tested: it carries the transcript path
# the level is resolved from, and a hook that exits without reading stdin leaves
# the runtime's write to fail.
input=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/story_involve_level.sh"
involve="$(story_involve_level "${input}" "${root}")"
[[ "${involve}" == "low" ]] || exit 0

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
#
# So do the thesis's protected records, at every level: the evidence store
# mates/ (AGENTS.md §1 — written only through execs/scpts/import.sh and
# story-evid-curator, whose edits you approve here), the confirmed institutional
# facts in degree/, and received committee feedback in miles/*/feedback/.
case "${path#"${root}"/}" in
    .*|*/..|*/../*) exit 0 ;;
    mates|mates/*|degree|degree/*|miles/*/feedback|miles/*/feedback/*) exit 0 ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"involve=low"}}\n'
