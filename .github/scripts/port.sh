#!/usr/bin/env bash
# Materialize the six harness-owned skill trees from the neutral source under
# .agents/skills. Byte-identical files are relative symlinks back to .agents;
# SKILL.md/SKILL_zh.md frontmatter stays harness-owned wherever a tree needs the
# slash-only guard or the argument-hint only .claude and .qwen read.
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
# (writing workflow conventions §7). Uppercase placeholders are values the author
# supplies, lowercase words are literal modes, and only the free-text placeholder
# is translated — targets, modes, and tokens stay English everywhere.
argument_hint() { # $1 = skill, $2 = en|zh
    local description="DESCRIPTION"
    [[ "$2" == "zh" ]] && description="描述"
    case "$1" in
        story-chap-drafter)  printf 'CHAPTER [%s] [involve=low]' "${description}" ;;
        story-cite-auditor)  printf '[CHAPTER | full] [%s]' "${description}" ;;
        story-clms-auditor)  printf '[CHAPTER | CLAIM_ID | full] [%s]' "${description}" ;;
        story-copy-editor)   printf '[CHAPTER | full | style] [%s] [involve=low]' "${description}" ;;
        story-defn-builder)  printf '[MILESTONE] [%s] [involve=high]' "${description}" ;;
        story-depo-packer)   printf 'MILESTONE [%s] [involve=high]' "${description}" ;;
        story-evid-curator)  printf '[check | import source=PATH [slug=NAME] | register path=FILE] [%s] [involve=low]' "${description}" ;;
        story-exam-reviewer) printf '[MILESTONE] [%s]' "${description}" ;;
        story-figs-designer) printf '[FIGURE | new] [%s] [involve=low]' "${description}" ;;
        story-flow-status)   printf '[%s]' "${description}" ;;
        story-outl-planner)  printf '[%s] [involve=high]' "${description}" ;;
        story-proj-adopt)    printf 'SOURCE_PATH [%s] [involve=low]' "${description}" ;;
        story-refs-curator)  printf 'PAPER... [%s] [involve=low]' "${description}" ;;
        story-revs-resolver) printf '[MILESTONE] [%s] [involve=high]' "${description}" ;;
        story-syns-coach)    printf '[%s] [involve=high]' "${description}" ;;
        story-tabs-builder)  printf '[TABLE | new] [%s] [involve=low]' "${description}" ;;
        *) return 1 ;;
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

render_manifest() { # $1 = neutral manifest, $2 = destination, $3 = true|false guard, $4 = argument hint
    local source="$1"
    local destination="$2"
    local guard="$3"
    local hint="$4"
    local temporary wanted
    temporary="$(mktemp)"
    if ! awk -v guard="${guard}" -v hint="${hint}" '
        /^---[[:space:]]*$/ { boundary++ }
        { print }
        boundary == 1 && guard == "true" && !guarded && /^name:[[:space:]]*story-/ {
            print "disable-model-invocation: true"
            guarded = 1
        }
        boundary == 1 && hint != "" && !hinted && /^description:/ {
            printf "argument-hint: \"%s\"\n", hint
            hinted = 1
        }
        END {
            if (guard == "true" && !guarded) exit 3
            if (hint != "" && !hinted) exit 4
        }
    ' "${source}" > "${temporary}"; then
        rm -f "${temporary}"
        fail "${source} frontmatter has no anchor line for the ${destination} render"
        return 0
    fi

    wanted="the neutral manifest"
    [[ "${guard}" == "true" ]] && wanted="${wanted} plus the slash-only guard"
    [[ -n "${hint}" ]] && wanted="${wanted} plus its argument-hint"

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

render_pi_prompt() { # $1 = skill name, $2 = language (en|zh)
    local skill="$1"
    local language="$2"
    local destination counterpart description hint skill_file temporary
    if [[ "${language}" == "zh" ]]; then
        destination=".pi/prompts/${skill}.zh-CN.md"
        counterpart="${skill}.md"
        description="使用 STORY 工作流指令运行 ${skill}"
        skill_file="SKILL_zh.md"
    else
        destination=".pi/prompts/${skill}.md"
        counterpart="${skill}.zh-CN.md"
        description="Run ${skill} with its STORY workflow instructions"
        skill_file="SKILL.md"
    fi
    # argument-hint is a prompt-template field in Pi even though it is not a skill
    # one, so the per-skill hint belongs here rather than in .pi/skills.
    if ! hint="$(argument_hint "${skill}" "${language}")"; then
        fail "no argument-hint is defined for ${skill}"
        return 0
    fi
    temporary="$(mktemp)"
    {
        printf '%s\n' '---'
        printf 'description: %s\n' "${description}"
        printf 'argument-hint: "%s"\n' "${hint}"
        printf '%s\n' '---' ''
        if [[ "${language}" == "zh" ]]; then
            printf '**语言：** [English](%s) | 简体中文\n\n' "${counterpart}"
            printf '完整阅读 `.pi/skills/%s/%s`，并将其作为本次运行的指令执行。\n\n' "${skill}" "${skill_file}"
            printf '本次运行的参数位于方括号之间：[$@]\n\n'
            printf '空方括号表示未提供参数；使用该 skill 所规定的无参数行为。\n'
        else
            printf '**Language:** English | [简体中文](%s)\n\n' "${counterpart}"
            printf 'Read `.pi/skills/%s/%s` in full and follow it as this run\x27s instructions.\n\n' "${skill}" "${skill_file}"
            printf 'This run\x27s argument, between the brackets: [$@]\n\n'
            printf 'Empty brackets mean no argument was given; use the skill\x27s documented no-argument behavior.\n'
        fi
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
            case "${rel}" in
                SKILL.md) language=en ;;
                SKILL_zh.md) language=zh ;;
                *) install_link "${destination}" "${source}"; continue ;;
            esac
            hint=""
            if takes_argument_hint "${tree}" && ! hint="$(argument_hint "${skill}" "${language}")"; then
                fail "no argument-hint is defined for ${skill}"
                continue
            fi
            if [[ "${guard}" == "true" || -n "${hint}" ]]; then
                render_manifest "${source}" "${destination}" "${guard}" "${hint}"
            else
                install_link "${destination}" "${source}"
            fi
        done < <(find -L "${SOURCE_ROOT}/${skill}" -type f | sort)
    done
    render_pi_prompt "${skill}" en
    render_pi_prompt "${skill}" zh
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
