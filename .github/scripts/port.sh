#!/usr/bin/env bash
# Materialize the six harness-owned skill trees from the neutral source under
# .agents/skills. Byte-identical files are relative symlinks back to .agents;
# SKILL.md frontmatter stays harness-owned wherever a tree needs the slash-only
# guard, the argument-hint only .claude and .qwen read, or a Claude-only field.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cd "${ROOT_DIR}"

MODE="check"
case "${1:-}" in
    "") ;;
    --check) MODE="check" ;;
    --write) MODE="write" ;;
    -h|--help)
        sed -n '2,5p' "${BASH_SOURCE[0]}"
        exit 0
        ;;
    *)
        printf 'port.sh: unknown option: %s\n' "$1" >&2
        exit 2
        ;;
esac

SOURCE_ROOT=".agents/skills"
CODEX_ROOT=".codex/skills"
TREES=(.claude/skills .cursor/skills .dsh/skills .kimi-code/skills .pi/skills .qwen/skills)
FAILURES=0
WRITTEN=0

fail() {
    printf 'FAIL  %s\n' "$*"
    FAILURES=$((FAILURES + 1))
}

list_skills() {
    find "${SOURCE_ROOT}" -mindepth 1 -maxdepth 1 -type d -name 'story-*' -exec basename {} \; | sort
}

is_slash_only() {
    grep -Eq '^[[:space:]]*allow_implicit_invocation:[[:space:]]*false[[:space:]]*$' \
        "${CODEX_ROOT}/$1/agents/openai.yaml"
}

# Only Claude Code and Qwen Code read argument-hint from skill frontmatter. It is
# kept out of the neutral source because .agents is Codex's discovery root, whose
# manifest validator rejects the key outright, and because Cursor, Kimi, DSH, and
# Pi would carry an inert field nothing reports. See .github/CONTRIBUTING.md.
takes_argument_hint() { # $1 = tree
    case "$1" in
        .claude/skills|.qwen/skills) return 0 ;;
        *) return 1 ;;
    esac
}

# One shape for the whole roster: <skill> [TARGET] [DESCRIPTION] [involve=<level>]
# (writing workflow conventions §7), written as STAR and STAGE write theirs.
# Uppercase placeholders are positional values the author supplies, lowercase
# words are literal modes, and a <lowercase> placeholder is the value after a
# key= or a mode; [] marks what may be left out, ... a repeat. The manifest is
# English only, so the hint is too. The involve token names the level worth
# switching to for this skill (low to ask less, high to weigh each call), or
# <level> where no level is suggested; the default still comes from INVOLVE in
# .env. This table holds the target part and that level.
argument_hint() { # $1 = skill
    local target level
    case "$1" in
        story-chap-drafter)  target='CHAPTER | FRONT_OR_BACK_FILE | trace CHAPTER'; level='low' ;;
        story-cite-auditor)  target='[CHAPTER | full]'; level='<level>' ;;
        story-clms-auditor)  target='[CHAPTER | CLAIM_ID[,CLAIM_ID...] | full]'; level='<level>' ;;
        story-copy-editor)   target='[CHAPTER | FILE | full | style]'; level='low' ;;
        story-defn-builder)  target='[MILESTONE]'; level='high' ;;
        story-depo-packer)   target='MILESTONE'; level='high' ;;
        story-evid-curator)  target='[check | import source=<path> [slug=<name>] | register path=<file>...]'; level='low' ;;
        story-exam-reviewer) target='[MILESTONE]'; level='<level>' ;;
        story-figs-designer) target='[FIGURE | new]'; level='low' ;;
        story-flow-status)   target=''; level='<level>' ;;
        story-outl-planner)  target=''; level='high' ;;
        story-proj-adopt)    target='[SOURCE_PATH]'; level='low' ;;
        story-refs-curator)  target='[PAPER... | CHAPTER | reconcile]'; level='low' ;;
        story-revs-resolver) target='[MILESTONE]'; level='high' ;;
        story-syns-coach)    target=''; level='high' ;;
        story-tabs-builder)  target='[TABLE | new]'; level='low' ;;
        *) return 1 ;;
    esac
    printf '%s[DESCRIPTION] [involve=%s]' "${target:+${target} }" "${level}"
}

# Frontmatter only Claude Code reads, one table per skill like argument_hint():
# `key: value` lines, rendered into .claude/skills alone, right after the name
# (and the guard, where there is one). The neutral source cannot carry them —
# .agents is Codex's discovery root, whose validator rejects unknown keys — and
# no other tree reads them. story-flow-status runs a read-only scan, so its
# Claude copy asks for medium reasoning effort (conventions §11).
claude_frontmatter() { # $1 = skill
    case "$1" in
        story-flow-status) printf 'effort: medium' ;;
        *) ;;
    esac
}

relative_link() { # $1 = destination path, $2 = source path from repository root
    local destination="$1"
    local source="$2"
    local directory="${destination%/*}"
    local up="../"
    local rest="${directory}"
    while [[ "${rest}" == */* ]]; do
        up="../${up}"
        rest="${rest#*/}"
    done
    printf '%s%s' "${up}" "${source}"
}

install_link() { # $1 = destination, $2 = source
    local destination="$1"
    local source="$2"
    local wanted
    wanted="$(relative_link "${destination}" "${source}")"
    if [[ -L "${destination}" && "$(readlink "${destination}")" == "${wanted}" ]]; then
        return 0
    fi
    if [[ "${MODE}" == "write" ]]; then
        mkdir -p "${destination%/*}"
        local temporary="${destination}.link.$$"
        ln -s "${wanted}" "${temporary}"
        mv -f "${temporary}" "${destination}"
        WRITTEN=$((WRITTEN + 1))
    else
        fail "${destination} must link to ${wanted}"
    fi
}

render_manifest() { # $1 = neutral manifest, $2 = destination, $3 = true|false guard, $4 = argument hint, $5 = Claude-only lines
    local source="$1"
    local destination="$2"
    local guard="$3"
    local hint="$4"
    local extra="${5:-}"
    local temporary wanted
    temporary="$(mktemp)"
    # The Claude-only lines travel through the environment, which keeps their
    # newlines and backslashes literal where awk -v would expand them.
    if ! PORT_EXTRA="${extra}" awk -v guard="${guard}" -v hint="${hint}" '
        BEGIN { extra = ENVIRON["PORT_EXTRA"] }
        /^---[[:space:]]*$/ { boundary++ }
        { print }
        boundary == 1 && guard == "true" && !guarded && /^name:[[:space:]]*story-/ {
            print "disable-model-invocation: true"
            guarded = 1
        }
        boundary == 1 && extra != "" && !extended && /^name:[[:space:]]*story-/ {
            print extra
            extended = 1
        }
        boundary == 1 && hint != "" && !hinted && /^description:/ {
            printf "argument-hint: \"%s\"\n", hint
            hinted = 1
        }
        END {
            if (guard == "true" && !guarded) exit 3
            if (hint != "" && !hinted) exit 4
            if (extra != "" && !extended) exit 5
        }
    ' "${source}" > "${temporary}"; then
        rm -f "${temporary}"
        fail "${source} frontmatter has no anchor line for the ${destination} render"
        return 0
    fi

    wanted="the neutral manifest"
    [[ "${guard}" == "true" ]] && wanted="${wanted} plus the slash-only guard"
    [[ -n "${hint}" ]] && wanted="${wanted} plus its argument-hint"
    [[ -n "${extra}" ]] && wanted="${wanted} plus its Claude-only frontmatter"

    if [[ -f "${destination}" && ! -L "${destination}" ]] && cmp -s "${temporary}" "${destination}"; then
        rm -f "${temporary}"
        return 0
    fi
    if [[ "${MODE}" == "write" ]]; then
        mkdir -p "${destination%/*}"
        chmod 0644 "${temporary}"
        mv -f "${temporary}" "${destination}"
        WRITTEN=$((WRITTEN + 1))
    else
        rm -f "${temporary}"
        fail "${destination} must be ${wanted}"
    fi
}

render_pi_prompt() { # $1 = skill name
    local skill="$1"
    local destination=".pi/prompts/${skill}.md"
    local description="Run ${skill} with its STORY workflow instructions"
    local hint temporary
    # argument-hint is a prompt-template field in Pi even though it is not a skill
    # one, so the per-skill hint belongs here rather than in .pi/skills.
    if ! hint="$(argument_hint "${skill}")"; then
        fail "no argument-hint is defined for ${skill}"
        return 0
    fi
    temporary="$(mktemp)"
    {
        printf '%s\n' '---'
        printf 'description: %s\n' "${description}"
        printf 'argument-hint: "%s"\n' "${hint}"
        printf '%s\n' '---' ''
        printf 'Read `.pi/skills/%s/SKILL.md` in full and follow it as this run\x27s instructions.\n\n' "${skill}"
        printf 'This run\x27s argument, between the brackets: [$@]\n\n'
        printf 'Empty brackets mean no argument was given; use the skill\x27s documented no-argument behavior.\n'
    } > "${temporary}"
    if [[ -f "${destination}" ]] && cmp -s "${temporary}" "${destination}"; then
        rm -f "${temporary}"
        return 0
    fi
    if [[ "${MODE}" == "write" ]]; then
        mkdir -p "${destination%/*}"
        chmod 0644 "${temporary}"
        mv -f "${temporary}" "${destination}"
        WRITTEN=$((WRITTEN + 1))
    else
        rm -f "${temporary}"
        fail "${destination} is not the generated Pi entry point for ${skill}"
    fi
}

skills="$(list_skills)"
if [[ -z "${skills}" ]]; then
    fail "${SOURCE_ROOT} contains no story-* skills"
fi

while IFS= read -r skill; do
    [[ -n "${skill}" ]] || continue

    # Codex metadata belongs to Codex. The neutral root links to it only because
    # Codex discovers project skills at .agents/skills.
    neutral_manifest="${SOURCE_ROOT}/${skill}/agents/openai.yaml"
    codex_manifest="${CODEX_ROOT}/${skill}/agents/openai.yaml"
    if [[ "${MODE}" == "write" && ! -e "${codex_manifest}" ]]; then
        if [[ -f "${neutral_manifest}" && ! -L "${neutral_manifest}" ]]; then
            mkdir -p "${codex_manifest%/*}"
            mv "${neutral_manifest}" "${codex_manifest}"
            WRITTEN=$((WRITTEN + 1))
        else
            fail "missing Codex manifest for ${skill}"
            continue
        fi
    fi
    if [[ ! -f "${codex_manifest}" ]]; then
        fail "missing ${codex_manifest}"
        continue
    fi
    install_link "${neutral_manifest}" "${codex_manifest}"

    guard=false
    if is_slash_only "${skill}"; then
        guard=true
    fi

    for tree in "${TREES[@]}"; do
        while IFS= read -r source; do
            rel="${source#${SOURCE_ROOT}/${skill}/}"
            [[ "${rel}" == agents/* ]] && continue
            destination="${tree}/${skill}/${rel}"
            if [[ "${rel}" != SKILL.md ]]; then
                install_link "${destination}" "${source}"
                continue
            fi
            hint=""
            if takes_argument_hint "${tree}" && ! hint="$(argument_hint "${skill}")"; then
                fail "no argument-hint is defined for ${skill}"
                continue
            fi
            extra=""
            [[ "${tree}" == .claude/skills ]] && extra="$(claude_frontmatter "${skill}")"
            if [[ "${guard}" == "true" || -n "${hint}" || -n "${extra}" ]]; then
                render_manifest "${source}" "${destination}" "${guard}" "${hint}" "${extra}"
            else
                install_link "${destination}" "${source}"
            fi
        done < <(find -L "${SOURCE_ROOT}/${skill}" -type f | sort)
    done
    render_pi_prompt "${skill}"
done <<< "${skills}"

if (( FAILURES > 0 )); then
    printf '%d harness-port failure(s).\n' "${FAILURES}" >&2
    exit 1
fi

if [[ "${MODE}" == "write" ]]; then
    printf 'Harness skill trees updated: %d path(s) moved, linked, or regenerated.\n' "${WRITTEN}"
else
    printf 'Harness skill trees match .agents/skills; shared files are linked once.\n'
fi
