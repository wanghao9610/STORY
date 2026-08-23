#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cd "${ROOT_DIR}" || exit 1

ROOTS=(.agents/skills .claude/skills .cursor/skills .kimi-code/skills)
FAILURES=0
fail() { printf 'FAIL  %s\n' "$*"; FAILURES=$((FAILURES + 1)); }
ok() { printf 'ok    %s\n' "$*"; }
section() { printf '\n== %s ==\n' "$*"; }

list_skills() { find "$1" -mindepth 1 -maxdepth 1 -type d -name 'story-*' -exec basename {} \; | sort; }
frontmatter_name() { sed -nE '1,/^---$/ s/^name:[[:space:]]*//p' "$1" | head -1; }

section 'Skill sets and mirrors'
BASE="$(list_skills "${ROOTS[0]}")"
[[ -n "${BASE}" ]] || fail '.agents/skills contains no story-* skills.'
for root in "${ROOTS[@]:1}"; do
    [[ "$(list_skills "${root}")" == "${BASE}" ]] || fail "${root} skill set differs from .agents/skills."
done

while IFS= read -r skill; do
    [[ -n "${skill}" ]] || continue
    for root in "${ROOTS[@]}"; do
        for file in SKILL.md SKILL_zh.md; do
            path="${root}/${skill}/${file}"
            [[ -f "${path}" ]] || { fail "missing ${path}"; continue; }
            [[ "$(frontmatter_name "${path}")" == "${skill}" ]] || fail "frontmatter name mismatch: ${path}"
            grep -q 'docs/mds/story-workflow/writing-workflow-conventions\.md' "${path}" || fail "conventions not loaded: ${path}"
        done
        if [[ "${root}" != .agents/skills ]]; then
            cmp -s ".agents/skills/${skill}/SKILL.md" "${root}/${skill}/SKILL.md" || fail "English mirror drift: ${root}/${skill}"
            cmp -s ".agents/skills/${skill}/SKILL_zh.md" "${root}/${skill}/SKILL_zh.md" || fail "Chinese mirror drift: ${root}/${skill}"
        fi
    done
    yaml=".agents/skills/${skill}/agents/openai.yaml"
    [[ -f "${yaml}" ]] || { fail "missing ${yaml}"; continue; }
    grep -Fq '$'"${skill}" "${yaml}" || fail "default_prompt does not name \$${skill}: ${yaml}"
    grep -Eq 'allow_implicit_invocation:[[:space:]]*(true|false)$' "${yaml}" || fail "invalid invocation policy: ${yaml}"
done <<< "${BASE}"
(( FAILURES == 0 )) && ok "$(printf '%s\n' "${BASE}" | wc -l | tr -d ' ') skills mirrored across four runtimes."

section 'Scripts and configuration'
while IFS= read -r script; do
    bash -n "${script}" || fail "bash syntax: ${script}"
done < <(find execs .agents/skills .claude/hooks .codex/hooks .cursor/hooks .kimi-code/hooks -type f -name '*.sh' | sort)
for cfg in .claude/settings.json .codex/hooks.json .cursor/hooks.json; do
    python3 -m json.tool "${cfg}" >/dev/null 2>&1 || fail "invalid JSON: ${cfg}"
done
for root in .claude/hooks .codex/hooks .cursor/hooks .kimi-code/hooks; do
    for hook in story_commit_guard.sh story_memory.sh story_model_id.sh; do
        [[ -x "${root}/${hook}" ]] || fail "missing or non-executable ${root}/${hook}"
    done
done
[[ -x execs/run.sh && -x execs/update.sh && -x execs/scpts/import.sh && -x execs/scpts/lint.sh && -x execs/scpts/fmt.sh ]] || fail 'one or more execs scripts are not executable.'
(( FAILURES == 0 )) && ok 'shell scripts parse, JSON loads, and entrypoints are executable.'

section 'Repository identity and layout'
grep -q 'Systematic Toolchain for Organizing Research over Years' README.md || fail 'README.md lacks the official expansion.'
grep -q 'A STAR takes the STAGE to tell a STORY' README.md || fail 'README.md lacks the official tagline.'
for path in degree/profile.tex degree/requirements.md notes/story.md notes/contributions.md notes/publications.md notes/outline.md notes/claims.md mates/MANIFEST.md manus/main.tex manus/stys/story.cls manus/stys/story.sty milestones/README.md; do
    [[ -f "${path}" ]] || fail "missing core path: ${path}"
done
[[ "$(readlink CLAUDE.md 2>/dev/null)" == AGENTS.md ]] || fail 'CLAUDE.md must link to AGENTS.md.'
[[ "$(readlink docs/index.html 2>/dev/null)" == htmls/story.html ]] || fail 'docs/index.html link is wrong.'
[[ "$(readlink docs/index_zh.html 2>/dev/null)" == htmls/story_zh.html ]] || fail 'docs/index_zh.html link is wrong.'

stale_paths="$(find . -path './.git' -prune -o \( -iname 'stage-*' -o -iname 'stage_*' -o -iname '.stage' \) -print)"
[[ -z "${stale_paths}" ]] || fail "stale STAGE-owned paths remain: ${stale_paths}"
bad_words="$(grep -RInE --exclude-dir=.git --exclude='*.bst' --exclude='check_consistency.sh' '\bstoryd\b|\bstorys\b' . 2>/dev/null || true)"
[[ -z "${bad_words}" ]] || fail 'mechanical rename artifacts storyd/storys remain.'
(( FAILURES == 0 )) && ok 'identity, symlinks, and dissertation layout are coherent.'

if (( FAILURES > 0 )); then
    printf '\n%d consistency failure(s).\n' "${FAILURES}"
    exit 1
fi
printf '\nAll STORY consistency checks passed.\n'
