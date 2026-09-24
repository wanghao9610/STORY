#!/usr/bin/env bash
# STORY PreToolUse hook (Kimi Code) — decline the git commands that break the
# STORY git safety policy.
# It also prevents low-involvement runs from staging unrelated work.
# Blanket staging and history
# rewrites are what turn a cheap local commit into one that needs surgery to
# unpick.
#
# Declined: blanket or forced staging (add -A / . / ./ / * / :/ / -u / -f,
# commit -a), the history rewrites named below (commit --amend, rebase,
# reset --hard, filter-branch, filter-repo), the forced branch operations named
# below (branch -D / -f, switch -C / -f / --discard-changes, checkout -B / -f),
# blanket discards of uncommitted work (checkout or restore of `.` or `:/`,
# a forced clean, stash clear / drop), forced pushes (push -f / --force* /
# --mirror, or a +refspec — the remote's history is the user's too), remote
# deletions (push -d / --delete / --prune, or a :dst refspec), any deletion or
# move of a tag (tag -d / -f, or update-ref on refs/tags/ or with --stdin — a
# freeze tag is the immutable record of what was deposited, and exactly one
# skill creates one),
# and a commit whose staged files exceed 10 MB — a build PDF, a raw figure
# export, or an evidence blob in history is costly to remove, since clearing it
# back out needs exactly those rewrites. A plain `push` stays
# absent: no rule here makes a skill likelier to push, and a user who asks for
# one directly should get it.
#
# Registered with event PreToolUse and matcher Bash. Kimi loads no project-level
# config, so the entry lives in the global config and is written there by
# .kimi-code/hooks/install.sh; the relative command path resolves per project
# because Kimi runs hooks from the project root. Its documented block shape omits
# the hookEventName the other PreToolUse harnesses carry, so this copy omits it
# too rather than sending a field the parser was not shown.
#
# A floor, not a proof. It reads one shell line at a time and cannot resolve
# quoting, so a flag written after a commit message (`commit -m x --amend`) is
# past where it stops reading. Silence means "no decision", so that case, an
# unfamiliar spelling, and a payload no branch below can read all fall through
# to the normal permission flow. What it declines is the user's to run.
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
    else
        # No parser on PATH, so the field is read out of the raw JSON and its
        # escapes are decoded by hand: \n and \t, which is how a command typed
        # over several lines arrives and what the segment split below must see,
        # then \" and \\. An escaped backslash is parked first, so a `\\n` in
        # the JSON stays the backslash and n it spells. A \uXXXX escape stays as
        # written. Without this branch the guard reads an empty command and
        # declines nothing.
        local v park=$'\001' nl=$'\n' tab=$'\t'
        v="$(printf '%s' "${input}" \
            | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' \
            | head -1 | sed -E 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//')"
        v="${v//\\\\/${park}}"
        v="${v//\\n/${nl}}"
        v="${v//\\t/${tab}}"
        v="${v//\\\"/\"}"
        v="${v//${park}/\\}"
        printf '%s\n' "${v}"
    fi
}

cmd="$(command_text)"
case "${cmd}" in
    *git*) ;;
    *) exit 0 ;;
esac

# The reason reaches the agent as JSON, so it carries no quote and no backslash.
deny() { # $1 = one-line reason
    printf '{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"%s (declined by .kimi-code/hooks/story_commit_guard.sh — hand it to the user to run)"}}\n' "$1"
    exit 0
}

# 10 MB. No tex source, note, or bibliography comes near it; a build PDF or a
# raw figure export clears it easily.
# ==== STORY shared guard core. Everything from here to the end of the file is
# byte-identical across the seven harness copies, and
# .github/scripts/check_consistency.sh diffs it against the .claude copy — edit
# it once, then propagate. ====
size_limit=$((10 * 1024 * 1024))

# Staged paths over the limit, as a printable list. Empty when none are.
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
                    -A|--all|-u|--update|--no-ignore-removal|.|./|:/|:/*|'*')
                        deny "STORY git safety: a blanket add stages work this run did not do, and it sweeps in build litter, half-registered evidence, and the user's own uncommitted edits. Stage the paths this run wrote, by name." ;;
                    -f|--force)
                        deny "STORY git safety: a force-add puts a git-ignored path — .env, a build under wkdrs/ — into history. Stage paths the ignore rules allow; evidence under mates/ that an ignore rule catches needs '!/mates/**' after the build-file rules in .gitignore, not a force-add." ;;
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
        update-ref)
            # The plumbing spelling of `tag -f` and `tag -d`. A freeze tag is
            # created with `git tag -a`, so no skill needs this on a tag, and
            # none needs --stdin, whose refs arrive where this cannot read them.
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    --stdin)
                        deny "STORY git safety: update-ref --stdin can move or delete a tag the guard cannot see, and a freeze tag is the immutable record of what was deposited. Leave the tag where it is." ;;
                    refs/tags/*)
                        deny "STORY git safety: update-ref on a tag moves or deletes it outside git tag, and a freeze tag is the immutable record of what was deposited. Leave the tag where it is." ;;
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
                    -B)
                        deny "STORY git safety: checkout -B resets an existing branch to another commit — a history rewrite in effect. Pick a fresh branch name." ;;
                    -f|--force)
                        deny "STORY git safety: a forced checkout discards uncommitted work, including anything the user had in the tree." ;;
                    # A blanket pathspec — bare or after `--` — discards every
                    # uncommitted change under it, the user's own edits included.
                    .|./|:/|:/*)
                        deny "STORY git safety: checking out a blanket pathspec discards every uncommitted change under it, including the user's own edits. Restore a named file instead." ;;
                esac
            done
            ;;
        restore)
            # restore --staged only unstages — content survives, so it passes.
            # Anything that touches the worktree with a blanket pathspec is the
            # same discard `checkout -- .` is.
            worktree=true
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                case "${tok[j]}" in
                    -S|--staged) worktree=false ;;
                    -W*|--worktree|-[!-]*W*) worktree=true ;;
                esac
            done
            if [[ "${worktree}" == true ]]; then
                for ((j = i + 1; j < ${#tok[@]}; j++)); do
                    arg="${tok[j]}"
                    case "${arg}" in
                        \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                    esac
                    case "${arg}" in
                        .|./|:/|:/*|'*')
                            deny "STORY git safety: restoring a blanket pathspec discards every uncommitted change under it, including the user's own edits. Restore a named file instead." ;;
                    esac
                done
            fi
            ;;
        clean)
            # git honors -n over -f: a dry run stays a dry run, so it passes.
            dry=false
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                case "${tok[j]}" in
                    -n*|--dry-run|-[!-]*n*) dry=true ;;
                esac
            done
            if [[ "${dry}" == false ]]; then
                for ((j = i + 1; j < ${#tok[@]}; j++)); do
                    arg="${tok[j]}"
                    case "${arg}" in
                        \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                    esac
                    case "${arg}" in
                        -f|--force|-d|-x|-X)
                            deny "STORY git safety: git clean deletes untracked files — unsaved drafts, unregistered evidence, the user's own scratch work — with no way back. Delete a named file instead." ;;
                        --*) ;;
                        -*[fdxX]*)
                            deny "STORY git safety: this flag cluster forces a clean, deleting untracked files with no way back. Delete a named file instead." ;;
                    esac
                done
            fi
            ;;
        stash)
            # The subcommand is always the first argument; a later `clear` or
            # `drop` is message text.
            if (( i + 1 < ${#tok[@]} )); then
                arg="${tok[i + 1]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    clear)
                        deny "STORY git safety: stash clear deletes every stash, and each one is uncommitted work the user set aside. Leave the stash list to the user." ;;
                    drop)
                        deny "STORY git safety: stash drop deletes a stash — uncommitted work the user set aside. Leave the stash list to the user." ;;
                esac
            fi
            ;;
        push)
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in
                    \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;;
                esac
                case "${arg}" in
                    -f|--force|--force-with-lease|--force-with-lease=*|--force-if-includes|--mirror)
                        deny "STORY git safety: a forced push rewrites the remote, and the remote's history is the user's too — a freeze tag must keep pointing at what was deposited. Leave the push to the user." ;;
                    -d|--delete|--prune)
                        deny "STORY git safety: this push deletes a branch or a tag on the remote, and the remote is the user's — a freeze tag must keep pointing at what was deposited. Leave remote refs to the user." ;;
                    --*) ;;
                    -*[fd]*)
                        deny "STORY git safety: this flag cluster carries a forced push or a remote delete, which rewrites the remote the user owns. Leave the push to the user." ;;
                    # A refspec is src:dst. A leading + forces that one update, and
                    # an empty src deletes dst; a bare : is the matching push and
                    # passes.
                    +*)
                        deny "STORY git safety: a +refspec forces that update, which rewrites the remote the user owns. Leave the push to the user." ;;
                    :?*)
                        deny "STORY git safety: a refspec with an empty source deletes that branch or tag on the remote, and the remote is the user's. Leave remote refs to the user." ;;
                esac
            done
            ;;
    esac
done < <(printf '%s\n' "${cmd}" | tr ';&|()' '\n\n\n\n\n')

exit 0
