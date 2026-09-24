#!/usr/bin/env bash
# Skip Claude's permission prompt for shell commands while the project runs at
# INVOLVE=low (.env, writing workflow conventions §7) — the shell counterpart of
# story_involve_gate.sh, so a low-involvement run is not parked at a prompt for
# every ls, grep, latexmk, or bash execs/run.sh call. The red lines stay prompts
# at every level: deletion, sudo, disk and device writes, system and TeX package
# installs, process kills, service control, git push and every other outward
# transfer (gh, scp, sftp, ftp, rclone, rsync to a host, curl or wget uploads),
# the git commands that delete files or discard uncommitted work (clean, stash
# drop / clear, a restore or checkout of the whole tree), forced mv/cp, and any
# command that may write into the thesis's protected records — the evidence
# store mates/ (except through its sanctioned writer, bash
# execs/scpts/import.sh), the confirmed institutional facts in degree/, and
# received committee feedback in milestones/*/feedback/. This gate stays silent
# on those, and the normal permission flow takes over. Confirmation points
# (conventions §7) are untouched: they are questions a skill asks in a model
# turn, not permission prompts a hook can answer.
# story_commit_guard.sh runs beside this gate on the same matcher and its deny
# outranks this allow, so a blanket add is still declined, not allowed.
#
# A floor, not a proof. It reads one shell line at a time, cannot resolve
# quoting, and matches only the paths a command names — a script that opens a
# protected file itself, or a heredoc body, is not seen. A `> file` redirect
# passes, since skills write regenerable reports under wkdrs/ through them, unless
# its target is one of the protected records. Silence means "no decision", so
# every red line, every other level, a payload it cannot read, and a project that
# sets no level all fall through to the normal permission flow. The level comes
# from story_involve_level.sh — the `involve=` token of the session's most recent
# STORY command, or `.env`'s INVOLVE when it carried none — and is resolved on
# each call, so a new invocation, or an edit to .env, takes effect without a
# restart.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-${PWD}}"

# The payload is read before the level is tested: it carries the transcript path
# the level is resolved from, and a hook that exits without reading stdin leaves
# the runtime's write to fail.
input=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/story_involve_level.sh"
involve="$(story_involve_level "${input}" "${root}")"
[[ "${involve}" == "low" ]] || exit 0

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
        # No parser on PATH: an allow read out of a misparsed payload could
        # cover a red line, so an unreadable command keeps its prompt.
        printf ''
    fi
}

cmd="$(command_text)"
[[ -n "${cmd}" ]] || exit 0

# A heredoc body is data, not commands — a commit-message line reading "rm old
# draft" is not the rm it spells. Drop each body through its delimiter before
# the segments are read. Only a bare-word delimiter (EOF-shaped) opens one, and
# a here-string's <<< is erased first, so an arithmetic x<<2 cannot swallow the
# lines after it and hide a real command; anything malformed falls back to
# reading every line, which errs toward the prompt, never past it.
strip_heredocs() {
    local line probe rest delim="" body=0 out=""
    while IFS= read -r line; do
        if (( body )); then
            [[ "${line}" == "${delim}" || "${line//$'\t'/}" == "${delim}" ]] && body=0
            continue
        fi
        out="${out}${line}"$'\n'
        probe="${line//<<</ }"
        [[ "${probe}" == *'<<'* ]] || continue
        rest="${probe##*<<}"
        rest="${rest#-}"
        read -r delim rest <<< "${rest}" || delim=""
        delim="${delim#\'}"; delim="${delim%\'}"; delim="${delim#\"}"; delim="${delim%\"}"
        case "${delim}" in
            [A-Za-z_]*[!A-Za-z0-9_]*) ;;
            [A-Za-z_]*) body=1 ;;
        esac
    done <<< "${cmd}"
    printf '%s' "${out}"
}
cmd="$(strip_heredocs)"
[[ -n "${cmd}" ]] || exit 0

# Whether a word names a path under one of the thesis's protected records:
# mates/ (AGENTS.md §1: written only through import.sh and story-evid-curator),
# degree/ (user-confirmed institutional facts), and milestones/*/feedback/
# (received comments, never edited in place). The word is read the way the shell
# would hand it over: backslashes (so an escaped quote inside `python3 -c "..."`
# is the quote it escapes), quotes, a redirect written onto its target (`>f`,
# `2>>f`), a `--flag=` or `NAME=` prefix, the project root, and leading `./` all
# come off first.
protected_path() { # $1 = one word of the command
    local p="$1"
    p="${p//\\/}"
    p="${p#\'}"; p="${p#\"}"; p="${p%\'}"; p="${p%\"}"
    p="${p##*>}"
    p="${p#<}"
    case "${p}" in *=*) p="${p#*=}" ;; esac
    p="${p#\'}"; p="${p#\"}"
    p="${p#"${root}"/}"
    while [[ "${p}" == ./* ]]; do p="${p#./}"; done
    case "${p}" in
        mates|mates/*|degree|degree/*|milestones/*/feedback|milestones/*/feedback/*) return 0 ;;
        */mates|*/mates/*|*/degree|*/degree/*|*/milestones/*/feedback|*/milestones/*/feedback/*) return 0 ;;
    esac
    return 1
}

# Commands that only read what they are given, so naming a protected path is a
# read. Anything else that names one keeps its prompt — a list of writers would
# miss `python3 -c`, `ln`, or `install`, and this list cannot. sed and awk read
# unless an in-place flag says otherwise, find unless it writes a file list; git
# only for the subcommands that leave the working tree alone, and then only
# without an --output file. tree and less are left off: `tree -o` and `less -o`
# each write the file they name.
reads_only() { # $1 = index of the command word in tok
    local j arg sub
    case "${name}" in
        cat|head|tail|more|wc|ls|file|stat|du|readlink|realpath|basename|dirname|\
        grep|egrep|fgrep|rg|diff|cmp|comm|cut|nl|od|strings|column|jq|echo|printf|test|'['|\
        shasum|sha1sum|sha256sum|sha512sum|md5|md5sum|cksum|b2sum|pdfinfo|pdffonts)
            return 0 ;;
        sed|awk|gawk)
            for ((j = $1 + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"; arg="${arg#\'}"; arg="${arg#\"}"
                case "${arg}" in
                    --in-place*|-i*|-I*) return 1 ;;
                    --*) ;;
                    -[!-]*[iI]*) return 1 ;;
                esac
            done
            return 0 ;;
        find)
            for ((j = $1 + 1; j < ${#tok[@]}; j++)); do
                case "${tok[j]}" in -fprint*|-fls) return 1 ;; esac
            done
            return 0 ;;
        git)
            j=$(($1 + 1))
            while [[ ${j} -lt ${#tok[@]} ]]; do
                case "${tok[j]}" in
                    -C|-c|--git-dir|--work-tree|--namespace|--exec-path) j=$((j + 2)) ;;
                    -*) j=$((j + 1)) ;;
                    *) break ;;
                esac
            done
            sub="${tok[j]:-}"; sub="${sub#\'}"; sub="${sub#\"}"; sub="${sub%\'}"; sub="${sub%\"}"
            case "${sub}" in
                status|diff|log|show|blame|ls-files|ls-tree|grep|add|commit|rev-parse|cat-file|shortlog|describe|check-ignore)
                    # diff, log and show write the file an --output names.
                    for ((j = j + 1; j < ${#tok[@]}; j++)); do
                        arg="${tok[j]}"; arg="${arg#\'}"; arg="${arg#\"}"
                        case "${arg}" in --output|--output=*) return 1 ;; esac
                    done
                    return 0 ;;
            esac
            return 1 ;;
    esac
    return 1
}

# One shell line can carry several commands, so each is read on its own:
# `cd x && sudo make install` is the sudo it looks like.
while IFS= read -r segment; do
    read -ra tok <<< "${segment}"
    [[ ${#tok[@]} -gt 0 ]] || continue

    # A redirect into a protected record keeps its prompt whatever command
    # writes it; any other word naming one is weighed against the command below.
    names_protected=false
    for ((k = 0; k < ${#tok[@]}; k++)); do
        word="${tok[k]}"
        if [[ "${word}" == *'>'* ]]; then
            target="${word##*>}"
            [[ -n "${target}" ]] || target="${tok[k + 1]:-}"
            protected_path "${target}" && exit 0
        fi
        protected_path "${word}" && names_protected=true
    done

    # Walk past wrappers, assignments, flags, and a timeout's duration to the
    # command itself, so `env rm`, `timeout 30 rm`, and `xargs rm` are the rm
    # they carry.
    i=0
    while [[ ${i} -lt ${#tok[@]} ]]; do
        t="${tok[i]}"
        # A quote pair can span tokens (`bash -c "rm x"` splits as `"rm x"`),
        # so each side strips on its own, not only as a pair.
        t="${t#\'}"; t="${t#\"}"; t="${t%\'}"; t="${t%\"}"
        case "${t##*/}" in
            env|command|exec|nohup|time|nice|caffeinate|stdbuf|timeout|xargs|sh|bash|zsh)
                i=$((i + 1)) ;;
            *=*|-*|[0-9]*)
                i=$((i + 1)) ;;
            *)
                break ;;
        esac
    done
    if [[ ${i} -ge ${#tok[@]} ]]; then
        # Nothing but wrappers and flags, yet a protected path was named.
        [[ "${names_protected}" == true ]] && exit 0
        continue
    fi
    # The walk left this token's quote-stripped form in t.
    name="${t##*/}"

    # The evidence store's one sanctioned writer, in command position: it copies
    # and fingerprints a snapshot, which is exactly the write the rule allows.
    if [[ "${names_protected}" == true ]]; then
        case "${t}" in
            execs/scpts/import.sh|./execs/scpts/import.sh|"${root}"/execs/scpts/import.sh) ;;
            *) reads_only "${i}" || exit 0 ;;
        esac
    fi

    case "${name}" in
        rm|rmdir|unlink|shred|srm|trash)
            exit 0 ;;
        sudo|su|doas)
            exit 0 ;;
        dd|mkfs*|fdisk|parted|diskutil|truncate)
            exit 0 ;;
        shutdown|reboot|halt|poweroff|launchctl|systemctl|service)
            exit 0 ;;
        kill|pkill|killall)
            exit 0 ;;
        modprobe|insmod|kextload|kextunload)
            exit 0 ;;
        apt|apt-get|aptitude|yum|dnf|pacman|zypper|brew|port|softwareupdate|installer|tlmgr|mpm)
            exit 0 ;;
        crontab)
            exit 0 ;;
        find)
            # A find that deletes or executes is whatever it carries.
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                case "${tok[j]}" in
                    -delete|-exec|-execdir|-ok|-okdir) exit 0 ;;
                esac
            done
            ;;
        git)
            # Walk past git's own options — `git -C dir push` names its
            # subcommand third. Push goes outward and is hard to retract.
            j=$((i + 1))
            while [[ ${j} -lt ${#tok[@]} ]]; do
                case "${tok[j]}" in
                    -C|-c|--git-dir|--work-tree|--namespace|--exec-path) j=$((j + 2)) ;;
                    -*) j=$((j + 1)) ;;
                    *) break ;;
                esac
            done
            [[ ${j} -lt ${#tok[@]} ]] || continue
            # Quotes cling to the words they open and close (`bash -c "git
            # stash clear"`), so each word read below sheds them first.
            sub="${tok[j]}"; sub="${sub#\'}"; sub="${sub#\"}"; sub="${sub%\'}"; sub="${sub%\"}"
            case "${sub}" in
                push)
                    exit 0 ;;
                clean)
                    # Removes untracked and, with -x, git-ignored files:
                    # wkdrs/ builds, .env, unregistered evidence drafts.
                    exit 0 ;;
                stash)
                    # drop and clear throw stashed work away for good.
                    nxt="${tok[j + 1]:-}"; nxt="${nxt#\'}"; nxt="${nxt#\"}"; nxt="${nxt%\'}"; nxt="${nxt%\"}"
                    case "${nxt}" in drop|clear) exit 0 ;; esac
                    ;;
                restore|checkout)
                    # Only a pathspec covering the whole tree discards every
                    # uncommitted change; restoring named paths is how a failed
                    # group of edits is rolled back, and prompting it would
                    # re-block a designed restore.
                    for ((k = j + 1; k < ${#tok[@]}; k++)); do
                        arg="${tok[k]}"
                        arg="${arg#\'}"; arg="${arg#\"}"; arg="${arg%\'}"; arg="${arg%\"}"
                        case "${arg}" in
                            .|./|:/|:/.|'*'|':/*') exit 0 ;;
                        esac
                    done
                    ;;
            esac
            ;;
        gh|scp|sftp|ftp|rclone)
            # Outward transfer is an author action (conventions §7, Git and
            # outward transfer), and each of these can reach another host.
            exit 0 ;;
        rsync)
            # A local copy passes; a host: or rsync:// operand sends files away.
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"; arg="${arg#\'}"; arg="${arg#\"}"; arg="${arg%\'}"; arg="${arg%\"}"
                case "${arg}" in
                    -*) ;;
                    *:*) exit 0 ;;
                esac
            done
            ;;
        curl|wget)
            # A plain GET, such as a DOI or arXiv record fetch, passes; a flag
            # that sends a local file or a form keeps the prompt. The short
            # flags are curl's alone (wget's -T is a timeout, -d is debug), read
            # letter by letter until one takes a value, so -XGET stays a GET.
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"; arg="${arg#\'}"; arg="${arg#\"}"; arg="${arg%\'}"; arg="${arg%\"}"
                nxt="${tok[j + 1]:-}"; nxt="${nxt#\'}"; nxt="${nxt#\"}"
                case "${arg}" in
                    --upload-file*|--form*|--post-file*|--body-file*)
                        exit 0 ;;
                    --data|--data-ascii|--data-binary|--data-urlencode|--json)
                        [[ "${nxt}" == @* ]] && exit 0 ;;
                    --*) ;;
                    -*)
                        [[ "${name}" == curl ]] || continue
                        flags="${arg#-}"
                        while [[ -n "${flags}" ]]; do
                            c="${flags:0:1}"; flags="${flags:1}"
                            case "${c}" in
                                T|F) exit 0 ;;
                                d) [[ "${flags:-${nxt}}" == @* ]] && exit 0; break ;;
                                [AbcCDeEHKmoPQrtuUwxXyYz]) break ;;
                            esac
                        done
                        ;;
                esac
            done
            ;;
        mv|cp)
            # Only the forced form; a plain mv is how a chapter, figure or table
            # file is renamed, and prompting it would re-block a designed move.
            for ((j = i + 1; j < ${#tok[@]}; j++)); do
                arg="${tok[j]}"
                case "${arg}" in \'*\'|\"*\") arg="${arg#?}"; arg="${arg%?}" ;; esac
                case "${arg}" in
                    --) break ;;
                    -f|--force|-*f*) exit 0 ;;
                esac
            done
            ;;
    esac
done < <(printf '%s\n' "${cmd}" | tr ';&|()' '\n\n\n\n\n')

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"involve=low (story_bash_gate.sh); red-line commands keep their prompt"}}\n'
