#!/usr/bin/env bash
# Materialize the six harness-owned skill trees from the neutral source under
# .agents/skills. Byte-identical files are relative symlinks back to .agents;
# only slash-only SKILL.md/SKILL_zh.md frontmatter remains harness-owned.
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

render_guarded() { # $1 = neutral SKILL.md, $2 = destination
    local source="$1"
    local destination="$2"
    local temporary
    temporary="$(mktemp)"
    awk '
        { print }
        NR == 2 && /^name:[[:space:]]*story-/ { print "disable-model-invocation: true" }
    ' "${source}" > "${temporary}"

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
        fail "${destination} must be the neutral manifest plus the slash-only guard"
    fi
}

render_pi_prompt() { # $1 = skill name, $2 = language (en|zh)
    local skill="$1"
    local language="$2"
    local destination counterpart description argument_hint skill_file temporary
    if [[ "${language}" == "zh" ]]; then
        destination=".pi/prompts/${skill}.zh-CN.md"
        counterpart="${skill}.md"
        description="使用 STORY 工作流指令运行 ${skill}"
        argument_hint="[目标]"
        skill_file="SKILL_zh.md"
    else
        destination=".pi/prompts/${skill}.md"
        counterpart="${skill}.zh-CN.md"
        description="Run ${skill} with its STORY workflow instructions"
        argument_hint="[TARGET]"
        skill_file="SKILL.md"
    fi
    temporary="$(mktemp)"
    {
        printf '%s\n' '---'
        printf 'description: %s\n' "${description}"
        printf 'argument-hint: "%s"\n' "${argument_hint}"
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

    for tree in "${TREES[@]}"; do
        while IFS= read -r source; do
            rel="${source#${SOURCE_ROOT}/${skill}/}"
            [[ "${rel}" == agents/* ]] && continue
            destination="${tree}/${skill}/${rel}"
            if [[ "${rel}" == "SKILL.md" || "${rel}" == "SKILL_zh.md" ]] && is_slash_only "${skill}"; then
                render_guarded "${source}" "${destination}"
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
