#!/usr/bin/env bash
# STORY PreToolUse hook (DeepSeek Harness) — decline the git commands that break the
# STORY git safety policy.
# It also prevents low-involvement runs from staging unrelated work.
# Blanket staging and history
# rewrites are what turn a cheap local commit into one that needs surgery to
# unpick.
#
# Declined: blanket or forced staging (add -A / . / * / :/ / -u / -f, commit -a),
# the history rewrites named below (commit --amend, rebase, reset --hard,
# filter-branch, filter-repo), the forced branch operations named below
# (branch -D / -f, switch -C / -f / --discard-changes, checkout -B / -f), any
# deletion or move of a tag (a freeze tag is the immutable record of what
# was deposited, and exactly one skill creates one), and a commit whose staged
# files exceed 10 MB — a build PDF, a raw figure export, or an evidence blob in
# history is costly to remove, since clearing it back out
# needs exactly those rewrites. `push` is deliberately absent: no rule here makes
# a skill likelier to push, and a user who asks for one directly should get it.
#
# Registered under PreToolUse matching DSH's lowercase `bash` tool in
# .dsh/hooks.json. The Claude Code hook bridge decodes the decision JSON.
#
# A floor, not a proof. It reads one shell line at a time and cannot resolve
# quoting, so a flag written after a commit message (`commit -m x --amend`) is
# past where it stops reading. Silence means "no decision", so that case, an
# unfamiliar spelling, and a machine with no JSON parser all fall through to the
# normal permission flow. What it declines is the user's to run.
set -uo pipefail

# Every harness registers this script by its own path inside the project, so the
# project root is two levels up from the script itself — no environment variable
# and no payload field, which differ per harness.
root="$(cd -- "$(dirname -- "$0")/../.." 2>/dev/null && pwd -P)" || exit 0

input=$(cat)

# The shell command, from Bash's tool_input.
command_text() {
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "${input}" | jq -r '.tool_input.command // empty' 2>/dev/null
    elif command -v python3 >/dev/null 2>&1; then
        printf '%s' "${input}" | python3 -c 'import sys, json
try:
    print((json.load(sys.stdin).get("tool_input") or {}).get("command") or "")
except Exception:
    print("")' 2>/dev/null
    fi
}

cmd="$(command_text)"
case "${cmd}" in
    *git*) ;;
    *) exit 0 ;;
esac

# The reason reaches the agent as JSON, so it carries no quote and no backslash.
deny() { # $1 = one-line reason
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s (declined by .dsh/hooks/story_commit_guard.sh — hand it to the user to run)"}}\n' "$1"
    exit 0
}

# 10 MB. No tex source, note, or bibliography comes near it; a build PDF or a
# raw figure export clears it easily.
size_limit=$((10 * 1024 * 1024))

# Storyd paths over the limit, as a printable list. Empty when none are.
staged_oversize() {
    local f size out=""
    while IFS= read -r -d '' f; do
        [[ -f "${root}/${f}" ]] || continue
        size="$(wc -c < "${root}/${f}" 2>/dev/null)" || continue
        size="${size//[[:space:]]/}"
        case "${size}" in ''|*[!0-9]*) continue ;; esac
        (( size > size_limit )) && out="${out:+${out}, }${f} ($((size / 1024 / 1024)) MB)"
    done < <(git -C "${root}" diff --cached --name-only -z 2>/dev/null)
    printf '%s' "${out}"
}

# One shell line can carry several commands, so each is read on its own: `cd x &&
# git add -A` is the add it looks like.
while IFS= read -r segment; do
    read -ra tok <<< "${segment}"
    [[ ${#tok[@]} -gt 0 ]] || continue
    case "${tok[0]}" in
        git|*/git) ;;
        *) continue ;;
    esac

    # Walk past git's own options — `git -C dir add` names its subcommand third.
    i=1
    while [[ ${i} -lt ${#tok[@]} ]]; do
        case "${tok[i]}" in
            -C|-c|--git-dir|--work-tree|--namespace|--exec-path) i=$((i + 2)) ;;
            -*) i=$((i + 1)) ;;
            *) break ;;
        esac
    done
    [[ ${i} -lt ${#tok[@]} ]] || continue

    case "${tok[i]}" in
        add)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                # `git add "."` is the instruction `git add .` is; word splitting
                # keeps the quotes, so one pair comes off before matching.
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    -A|--all|-u|--update|--no-ignore-removal|.|:/|:/*|'*')
                        deny "STORY git safety: a blanket add stages work this run did not do, and it sweeps in build litter, half-registered evidence, and the user's own uncommitted edits. Stage the paths this run wrote, by name." ;;
                    -f|--force)
                        deny "STORY git safety: a force-add puts a git-ignored path — .env, a build under wkdrs/ — into history. Stage a tracked path instead." ;;
                    --*) ;;
                    -*[Auf]*)
                        deny "STORY git safety: this flag cluster carries a blanket or forced add. Stage the paths this run wrote, by name." ;;
                esac
            done
            ;;
        commit)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    -m|--message|-F|--file|-t|--template|--fixup|--squash|-C|--reuse-message|--reedit-message|-m*|--message=*|--file=*)
                        break ;;
                    --amend)
                        deny "STORY git safety: no history rewrites — the user owns the branch and the remote, and a freeze tag points at a commit that must not move. Make a new commit instead." ;;
                    --all)
                        deny "STORY git safety: commit --all stages every tracked modification, including work this run did not do. Stage the paths this run wrote, by name, then commit without it." ;;
                    --*) ;;
                    -*a*)
                        deny "STORY git safety: commit -a stages every tracked modification, including work this run did not do. Stage the paths this run wrote, by name, then commit without -a." ;;
                esac
            done
            big="$(staged_oversize)"
            [[ -n "${big}" ]] && \
                deny "STORY git safety: staged over 10 MB — ${big}. Builds and large assets belong in wkdrs/ or in mates/ by import, and clearing one back out of history needs a history rewrite, so unstage it first."
            ;;
        rebase)
            deny "STORY git safety: no history rewrites — the user owns the branch and the remote." ;;
        filter-branch|filter-repo)
            deny "STORY git safety: no history rewrites — the user owns the branch and the remote." ;;
        reset)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                [[ "${tok[j]}" == --hard ]] && \
                    deny "STORY git safety: reset --hard discards uncommitted work, including anything the user had in the tree."
            done
            ;;
        tag)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    -d|--delete)
                        deny "STORY git safety: a freeze tag is the immutable record of what was deposited — no skill deletes one." ;;
                    -f|--force)
                        deny "STORY git safety: moving a tag rewrites what a deposit record points at. Leave the freeze tag where it is." ;;
                    --*) ;;
                    -*[df]*)
                        deny "STORY git safety: this flag cluster deletes or moves a tag, and a freeze tag is the immutable record of what was deposited." ;;
                esac
            done
            ;;
        branch)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    -D|--delete-force)
                        deny "STORY git safety: a force-deleted branch takes its unmerged commits with it, and the branch is the user's. A merged branch deletes with -d." ;;
                    -f|--force)
                        deny "STORY git safety: forcing a branch onto another commit rewrites where its history points. Create a new branch instead." ;;
                    --*) ;;
                    -*[Df]*)
                        deny "STORY git safety: this flag cluster carries a forced branch delete or move. The user owns the branch." ;;
                esac
            done
            ;;
        switch)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    -C|--force-create)
                        deny "STORY git safety: switch -C resets an existing branch to another commit — a history rewrite in effect. Pick a fresh branch name." ;;
                    -f|--force|--discard-changes)
                        deny "STORY git safety: a forced switch discards uncommitted work, including anything the user had in the tree." ;;
                esac
            done
            ;;
        checkout)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    --) break ;;
                    -B)
                        deny "STORY git safety: checkout -B resets an existing branch to another commit — a history rewrite in effect. Pick a fresh branch name." ;;
                    -f|--force)
                        deny "STORY git safety: a forced checkout discards uncommitted work, including anything the user had in the tree." ;;
                esac
            done
            ;;
    esac
done < <(printf '%s\n' "${cmd}" | tr ';&|()' '\n\n\n\n\n')

exit 0
