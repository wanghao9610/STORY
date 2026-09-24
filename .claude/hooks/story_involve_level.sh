#!/usr/bin/env bash
# Resolve the involve level a gate hook should act on: the `involve=<level>`
# token of the session's most recent STORY command, or `.env`'s INVOLVE when that
# invocation carried none (writing workflow conventions §7).
#
# Sourced by story_involve_gate.sh and story_bash_gate.sh; it decides nothing
# itself. Prints one of low / medium / high, or nothing at all — and nothing
# means "no level set", which every caller reads as no decision.
#
# Why the transcript. The token rides in the invocation the user typed, which
# reaches the model and not the hook: a hook is a separate process, and its
# payload carries the tool call, never the words that started the run. What the
# payload does carry is `transcript_path`, and the transcript records a slash
# command as <command-name>/story-chap-drafter</command-name> beside a
# <command-args> block holding what was typed after it, and a skill dispatched
# through the Skill tool as a tool_use block carrying that skill's `args`. Those
# two blocks are the only places read here. Plain chat text is ignored on
# purpose: a message *about* the level — "set involve=low for the drafter" — is
# discussion, and a grep over loose text would take it for a setting.
#
# Scope. The most recent typed STORY command wins for as long as it is the most
# recent: answering a question mid-run leaves it in force, and the next typed
# STORY command replaces it — with .env when that one names no level. A run's
# level therefore outlives the run itself, until the next command; .env stays
# the standing level and the token is the temporary one.
#
# The two forms count differently, on purpose. A typed command is the user
# speaking, so it sets the level either way: `/story-chap-drafter 3 involve=low`
# lowers it, and a bare `/story-flow-status` falls back to .env — the user
# retracting the level by not repeating it. A Skill call is the agent speaking,
# so its token can only raise the level above the one the typed command or .env
# set, never lower it: the agent must not grant itself `low` by writing the
# token into a dispatch. Raising is kept because it only ever adds prompts — the
# /story router passing on the token the user typed, or a run choosing to be
# asked more. A Skill call with no token changes nothing, and neither does one
# older than the most recent typed command.
#
# A command that wraps a STORY one — `/goal /story-auto <goal> involve=low` —
# records <command-name>/goal and the STORY command as its <command-args>. The
# user typed it, so it counts as a typed STORY command when its arguments open
# with one.
#
# Sidechain turns are skipped: a delegated subagent's invocation, and whatever it
# dispatches, is not the user's. So is a meta entry: a skill body the Skill tool
# loads is recorded as a user entry carrying <command-name>, and reading it as a
# typed command would reset the level the user set.

# The level an invocation names: its last `involve=<level>` word, wherever it
# sits — the rule every skill strips the token by (conventions §7).
story__involve_token() { # $1 = the invocation's argument text
    local word token="" words
    read -ra words <<< "$1"
    for word in "${words[@]+"${words[@]}"}"; do
        case "${word}" in
            involve=low|involve=medium|involve=high) token="${word#involve=}" ;;
        esac
    done
    printf '%s' "${token}"
}

story__payload_field() { # $1 = payload JSON, $2 = top-level field name
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$1" | jq -r --arg k "$2" '.[$k] // empty' 2>/dev/null
    else
        printf '%s' "$1" \
            | grep -oE "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
            | head -1 | sed -E 's/.*"([^"]*)"$/\1/'
    fi
}

# Every STORY invocation in the transcript, oldest first, one per line:
# `T<tab><args>` for a command the user typed (its <command-args>, empty for a
# bare command) and `S<tab><args>` for a Skill call dispatching a story skill
# whose args carry a token. Newlines inside the args become spaces. The grep in
# front keeps a long session cheap: this runs on every edit and shell call.
story__invocations() { # $1 = transcript path
    local transcript="$1"
    [ -n "${transcript}" ] && [ -r "${transcript}" ] || return 0
    if command -v jq >/dev/null 2>&1; then
        # The args capture takes jq's "p" flag, not "s": in jq, "s" only pins
        # ^ and $ to the whole string, and "p" is the one that also lets `.`
        # cross a newline, so args typed over several lines are read whole —
        # as the python3 reader's re.S reads them — instead of not at all. Lines
        # are read raw and one that does not parse is skipped, as the python3
        # reader skips it: jq would otherwise stop at it and drop every later
        # invocation, a later bare command resetting the level among them.
        grep -E '<command-(name|message)>|"name":[[:space:]]*"Skill"' "${transcript}" 2>/dev/null \
            | jq -rR 'fromjson? | select(.isSidechain | not)
                | if .type == "user" then
                    select(.isMeta | not)
                    | ((.message.content) as $c
                       | if ($c | type) == "string" then $c
                         else ([$c[]? | select(.type? == "text") | .text] | join(" ")) end)
                    | select(test("^[[:space:]]*<command-(name|message)>"))
                    | ((capture("<command-name>(?<n>[^<]*)</command-name>") | .n) // "") as $n
                    | ((capture("<command-args>(?<a>.*?)</command-args>"; "p") | .a) // "") as $a
                    | select(($n | test("^/story(-[a-z0-9-]+)?$"))
                             or ($a | test("^[[:space:]]*/story(-[a-z0-9-]+)?([[:space:]]|$)")))
                    | "T\t" + ($a | gsub("[[:space:]]+"; " "))
                  elif .type == "assistant" then
                    (.message.content[]?
                     | select(.type? == "tool_use" and .name? == "Skill")
                     | select((.input.skill // "" | tostring) | test("^story(-|$)"))
                     | (.input.args // "" | tostring)
                     | select(test("involve=(low|medium|high)"))
                     | "S\t" + gsub("[[:space:]]+"; " "))
                  else empty end' 2>/dev/null
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "${transcript}" <<'PY' 2>/dev/null
import json, re, sys

opening = re.compile(r"\s*<command-(name|message)>")
name_re = re.compile(r"<command-name>([^<]*)</command-name>")
args_re = re.compile(r"<command-args>(.*?)</command-args>", re.S)
story_name = re.compile(r"/story(-[a-z0-9-]+)?$")
story_wrapped = re.compile(r"\s*/story(-[a-z0-9-]+)?(\s|$)")
token = re.compile(r"involve=(low|medium|high)")
flat = lambda s: re.sub(r"\s+", " ", s)
with open(sys.argv[1], errors="replace") as fh:
    for line in fh:
        if "<command-" not in line and '"Skill"' not in line:
            continue
        try:
            entry = json.loads(line)
        except Exception:
            continue
        if entry.get("isSidechain"):
            continue
        content = (entry.get("message") or {}).get("content")
        if entry.get("type") == "user":
            if entry.get("isMeta"):
                continue
            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                text = " ".join(b.get("text", "") for b in content
                                if isinstance(b, dict) and b.get("type") == "text")
            else:
                continue
            if not opening.match(text):
                continue
            found = name_re.search(text)
            name = found.group(1) if found else ""
            found = args_re.search(text)
            args = found.group(1) if found else ""
            if story_name.match(name) or story_wrapped.match(args):
                print("T\t" + flat(args))
        elif entry.get("type") == "assistant" and isinstance(content, list):
            for block in content:
                if not (isinstance(block, dict)
                        and block.get("type") == "tool_use"
                        and block.get("name") == "Skill"):
                    continue
                params = block.get("input") or {}
                args = str(params.get("args") or "")
                if (re.match(r"story(-|$)", str(params.get("skill") or ""))
                        and token.search(args)):
                    print("S\t" + flat(args))
PY
    fi
}

story__env_involve() { # $1 = project root
    local line value
    line="$(grep -sE '^INVOLVE=' "$1/.env" | tail -1)"
    value="${line#INVOLVE=}"
    value="${value%%#*}"
    printf '%s' "${value}" | tr -cd '[:alpha:]'
}

# low < medium < high. No level at all ranks as medium, the level a skill
# assumes when .env sets none (conventions §7), so a Skill call's `medium` does
# not count as raising it and its `high` does.
story__involve_rank() { # $1 = level
    case "$1" in
        low) printf 1 ;;
        high) printf 3 ;;
        *) printf 2 ;;
    esac
}

story_involve_level() { # $1 = hook payload, $2 = project root
    local record typed="" typed_seen=false skill="" base
    while IFS= read -r record; do
        case "${record}" in
            T$'\t'*) typed="${record#T$'\t'}"; typed_seen=true; skill="" ;;
            S$'\t'*) skill="$(story__involve_token "${record#S$'\t'}")" ;;
        esac
    done < <(story__invocations "$(story__payload_field "$1" transcript_path)")

    base=""
    [ "${typed_seen}" = true ] && base="$(story__involve_token "${typed}")"
    [ -n "${base}" ] || base="$(story__env_involve "$2")"
    case "${base}" in
        low|medium|high) ;;
        *) base="" ;;
    esac

    if [ -n "${skill}" ] && (( $(story__involve_rank "${skill}") > $(story__involve_rank "${base}") )); then
        printf '%s' "${skill}"
    else
        printf '%s' "${base}"
    fi
}
