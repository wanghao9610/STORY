#!/usr/bin/env bash
# Print the project-owned memory index as plain text for Pi's TypeScript hook.
set -uo pipefail

root="$(cd -- "$(dirname -- "$0")/../../.." 2>/dev/null && pwd -P)" || exit 0
cutoff="$(date -v-180d +%Y-%m-%d 2>/dev/null || date -d '180 days ago' +%Y-%m-%d 2>/dev/null || true)"

entries() {
    [[ -r "$1" ]] || return 0
    awk -v cutoff="${cutoff}" '
        # Entry lines live outside the fenced block that documents their format.
        /^```/ { infence = !infence; next }
        !infence && /^- / {
            if (split($0, f, " · ") >= 4 && cutoff != "" &&
                substr(f[1], 3) == "env" && f[3] < cutoff)
                print $0 "  [stale: verify before relying on it]"
            else
                print
        }
    ' "$1"
}

shared="$(entries "${root}/.story/memory/MEMORY.md")"
machine="$(entries "${root}/.story/memory/local/MEMORY.md")"
[[ -n "${shared}${machine}" ]] || exit 0

printf '%s\n' "STORY project memory — each line below is a pointer, not evidence. Open its file before acting on it; repository files win over memory, and numbers, institutional rules, and literature assertions must trace to mates/, degree/, milestones/, and notes/refs/."
[[ -n "${shared}" ]] && printf 'Shared (.story/memory/):\n%s\n' "${shared}"
[[ -n "${machine}" ]] && printf 'Machine-local (.story/memory/local/):\n%s\n' "${machine}"
