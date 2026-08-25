#!/usr/bin/env bash
# STORY upstream consistency checks for the shared skill source and all harnesses.
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cd "${ROOT_DIR}" || exit 1

ROOTS=(.agents/skills .claude/skills .cursor/skills .dsh/skills .kimi-code/skills .pi/skills .qwen/skills)
NAMED_ROOTS=(.claude/skills .cursor/skills .dsh/skills .kimi-code/skills .pi/skills .qwen/skills)
# Claude Code and Qwen Code are the only skill roots that read argument-hint.
# .agents is Codex's discovery root, whose validator rejects the key; the rest
# would carry an inert field. Pi reads it, but as a prompt-template field.
HINT_ROOTS=".claude/skills .qwen/skills"
FAILURES=0

fail() { printf 'FAIL  %s\n' "$*"; FAILURES=$((FAILURES + 1)); }
ok() { printf 'ok    %s\n' "$*"; }
section() { printf '\n== %s ==\n' "$*"; }

list_skills() {
    find "$1" -mindepth 1 -maxdepth 1 -type d -name 'story-*' -exec basename {} \; | sort
}

frontmatter_has_line() {
    awk -v want="$2" 'NR == 1 { next } /^---[[:space:]]*$/ { exit } $0 == want { found = 1; exit } END { exit !found }' "$1"
}

frontmatter_has_key() {
    awk -v key="$2:" 'NR == 1 { next } /^---[[:space:]]*$/ { exit } index($0, key) == 1 { found = 1; exit } END { exit !found }' "$1"
}

section 'Seven skill trees and shared storage'
BASE="$(list_skills "${ROOTS[0]}")"
[[ -n "${BASE}" ]] || fail '.agents/skills contains no story-* skills'
for root in "${ROOTS[@]:1}"; do
    if [[ "$(list_skills "${root}")" != "${BASE}" ]]; then
        fail "${root} skill set differs from .agents/skills"
    fi
done

parity_errors=0
while IFS= read -r skill; do
    [[ -n "${skill}" ]] || continue
    baseline="$(cd ".agents/skills/${skill}" && find -L . -type f ! -path './agents/*' | sort)"
    for root in "${NAMED_ROOTS[@]}"; do
        listing="$(cd "${root}/${skill}" && find -L . -type f | sort)"
        if [[ "${listing}" != "${baseline}" ]]; then
            fail "${root}/${skill} file inventory differs from .agents/skills/${skill}"
            parity_errors=1
        fi
    done
done <<< "${BASE}"
(( parity_errors == 0 )) && ok "$(printf '%s\n' "${BASE}" | wc -l | tr -d ' ') skills have identical inventories across seven roots"

if ! bash .github/scripts/port.sh --check; then
    fail 'harness trees do not match the .agents source or shared files stopped being links'
else
    ok 'all generated harness files and symlinks match .agents/skills'
fi

section 'Skill frontmatter, conventions, and explicit-only policy'
policy_errors=0
SLASH_ONLY=""
while IFS= read -r skill; do
    [[ -n "${skill}" ]] || continue
    for root in "${ROOTS[@]}"; do
        for file in SKILL.md SKILL_zh.md; do
            path="${root}/${skill}/${file}"
            [[ -f "${path}" ]] || { fail "missing ${path}"; policy_errors=1; continue; }
            frontmatter_has_line "${path}" "name: ${skill}" || { fail "frontmatter name mismatch: ${path}"; policy_errors=1; }
            grep -q 'docs/mds/story-workflow/writing-workflow-conventions\.md' "${path}" || { fail "conventions not loaded: ${path}"; policy_errors=1; }
            case " ${HINT_ROOTS} " in
                *" ${root} "*)
                    frontmatter_has_key "${path}" 'argument-hint' \
                        || { fail "missing argument-hint: ${path}"; policy_errors=1; }
                    ;;
                *)
                    if frontmatter_has_key "${path}" 'argument-hint'; then
                        fail "${path} carries an argument-hint this harness does not read"
                        policy_errors=1
                    fi
                    ;;
            esac
        done
    done

    codex_manifest=".codex/skills/${skill}/agents/openai.yaml"
    neutral_manifest=".agents/skills/${skill}/agents/openai.yaml"
    [[ -f "${codex_manifest}" ]] || { fail "missing ${codex_manifest}"; policy_errors=1; continue; }
    [[ -L "${neutral_manifest}" ]] || { fail "${neutral_manifest} must link to the Codex-owned manifest"; policy_errors=1; }
    cmp -s "${codex_manifest}" "${neutral_manifest}" || { fail "Codex manifest link is broken: ${neutral_manifest}"; policy_errors=1; }
    grep -Fq '$'"${skill}" "${codex_manifest}" || { fail "default_prompt does not name \$${skill}: ${codex_manifest}"; policy_errors=1; }
    policy="$(sed -nE 's/^[[:space:]]*allow_implicit_invocation:[[:space:]]*(true|false)[[:space:]]*$/\1/p' "${codex_manifest}")"
    case "${policy}" in
        false) SLASH_ONLY="${SLASH_ONLY}${SLASH_ONLY:+$'\n'}${skill}" ;;
        true) ;;
        *) fail "invalid invocation policy: ${codex_manifest}"; policy_errors=1; continue ;;
    esac

    for root in "${NAMED_ROOTS[@]}"; do
        for file in SKILL.md SKILL_zh.md; do
            guarded=false
            frontmatter_has_line "${root}/${skill}/${file}" 'disable-model-invocation: true' && guarded=true
            if [[ "${policy}" == false && "${guarded}" != true ]]; then
                fail "${root}/${skill}/${file} lacks its explicit-only guard"
                policy_errors=1
            elif [[ "${policy}" == true && "${guarded}" == true ]]; then
                fail "${root}/${skill}/${file} is guarded but Codex allows implicit invocation"
                policy_errors=1
            fi
        done
    done
done <<< "${BASE}"

roster_slash_only() {
    sed -nE 's/^\| `(story-[a-z-]+)` † \|.*/\1/p' "$1" | sort
}
roster_all() {
    sed -nE 's/^\| `(story-[a-z-]+)`( †)? \|.*/\1/p' "$1" | sort
}
for conventions in \
    docs/mds/story-workflow/writing-workflow-conventions.md \
    docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md; do
    if [[ "$(roster_all "${conventions}")" != "${BASE}" ]]; then
        fail "${conventions}: skill roster differs from .agents/skills"
        policy_errors=1
    fi
done
if [[ "$(roster_slash_only docs/mds/story-workflow/writing-workflow-conventions.md)" != "$(printf '%s\n' "${SLASH_ONLY}" | sort)" ]]; then
    fail 'English conventions dagger set differs from the harness policy'
    policy_errors=1
fi
if [[ "$(roster_slash_only docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md)" != "$(printf '%s\n' "${SLASH_ONLY}" | sort)" ]]; then
    fail 'Chinese conventions dagger set differs from the harness policy'
    policy_errors=1
fi

ROUTER=".agents/commands/story.md"
ROUTER_ZH=".agents/commands/story.zh-CN.md"
ROUTER_DAGGER='s/^\| `(story-[a-z-]+)` \| † \|.*/\1/p'
ROUTER_ANY='s/^\| `(story-[a-z-]+)` \|.*$/\1/p'
router_rows() {
    sed -nE "$2" "$1" | sort
}
for router in "${ROUTER}" "${ROUTER_ZH}"; do
    if [[ ! -f "${router}" ]]; then
        fail "${router} is missing"
        policy_errors=1
        continue
    fi
    if [[ "$(router_rows "${router}" "${ROUTER_ANY}")" != "${BASE}" ]]; then
        fail "${router}: shared /story router differs from .agents/skills"
        policy_errors=1
    fi
    if [[ "$(router_rows "${router}" "${ROUTER_DAGGER}")" != "$(printf '%s\n' "${SLASH_ONLY}" | sort)" ]]; then
        fail "${router}: shared /story router dagger set differs from the harness policy"
        policy_errors=1
    fi
done
(( policy_errors == 0 )) && ok "conventions and shared /story router list all $(printf '%s\n' "${BASE}" | wc -l | tr -d ' ') skills en/zh; $(printf '%s\n' "${SLASH_ONLY}" | wc -l | tr -d ' ') explicit-only skills are guarded in every harness"

section 'Completion handoff contract'
handoff_errors=0
for path in \
    AGENTS.md \
    .cursor/rules/agent-instructions.mdc \
    README.md \
    docs/mds/story-workflow/writing-workflow-conventions.md \
    docs/mds/story-workflow/writing-workflow-skills.md; do
    if ! grep -qF '`Next action:`' "${path}"; then
        fail "English completion handoff is missing from ${path}"
        handoff_errors=1
    fi
done
for path in \
    AGENTS.zh-CN.md \
    README.zh-CN.md \
    docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md \
    docs/mds/story-workflow/writing-workflow-skills.zh-CN.md; do
    if ! grep -qF '`下一步：`' "${path}"; then
        fail "Chinese completion handoff is missing from ${path}"
        handoff_errors=1
    fi
done
if ! grep -qF 'recommendation, not authorization' docs/mds/story-workflow/writing-workflow-conventions.md || \
   ! grep -qF '只是建议，并不构成' docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md; then
    fail 'completion handoff does not preserve the authorization boundary in both languages'
    handoff_errors=1
fi
(( handoff_errors == 0 )) && ok 'every workflow step reports one localized next action without expanding authorization'

# Codex gets the generic router through one plugin owned entirely by .codex.
# .agents exposes only the marketplace file the host discovers; linking the
# directory would leak every Codex-private plugin into a shared namespace.
section 'Codex STORY plugin layout'
plugin_errors=0
MARKETPLACE=".codex/plugins/marketplace.json"
PLUGIN_ROOT=".codex/plugins/story"
DISCOVERY=".agents/plugins/marketplace.json"
if [[ ! -L "${DISCOVERY}" ]]; then
    fail "${DISCOVERY} is not a file symlink"
    plugin_errors=1
elif [[ "$(readlink "${DISCOVERY}")" != "../../.codex/plugins/marketplace.json" ]]; then
    fail "${DISCOVERY} does not point to ../../.codex/plugins/marketplace.json"
    plugin_errors=1
elif ! cmp -s "${DISCOVERY}" "${MARKETPLACE}"; then
    fail "${DISCOVERY} does not resolve to ${MARKETPLACE}"
    plugin_errors=1
fi
if ! python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); p=json.load(open(sys.argv[2])); e=m["plugins"]; assert m["name"] == "story" and m["interface"]["displayName"] == "STORY" and len(e) == 1 and e[0]["name"] == "story" and e[0]["source"] == {"source": "local", "path": "./.codex/plugins/story"}; assert e[0]["policy"] == {"installation": "AVAILABLE", "authentication": "ON_INSTALL"} and e[0]["category"] == "Productivity"; assert p["name"] == "story" and p["skills"] == "./skills/" and p["interface"]["composerIcon"] == "./assets/icon.png" and p["interface"]["logo"] == "./assets/icon.png"' "${MARKETPLACE}" "${PLUGIN_ROOT}/.codex-plugin/plugin.json"; then
    fail "Codex STORY plugin or marketplace metadata is invalid"
    plugin_errors=1
fi
for skill_file in "${PLUGIN_ROOT}/skills/story/SKILL.md" "${PLUGIN_ROOT}/skills/story/SKILL_zh.md"; do
    if [[ ! -f "${skill_file}" ]] || \
       ! frontmatter_has_line "${skill_file}" "name: story" || \
       ! grep -qF '.agents/commands/story.md' "${skill_file}"; then
        fail "${skill_file} is not a wrapper around the shared router"
        plugin_errors=1
    fi
    if ! grep -qF 'STORY_LANG=zh' "${skill_file}" || \
       ! grep -qF '.agents/commands/story.zh-CN.md' "${skill_file}"; then
        fail "${skill_file} does not apply STORY's Chinese router wording"
        plugin_errors=1
    fi
done
if [[ ! -s "${PLUGIN_ROOT}/assets/icon.png" ]] || \
   ! grep -qF 'allow_implicit_invocation: false' "${PLUGIN_ROOT}/skills/story/agents/openai.yaml"; then
    fail "${PLUGIN_ROOT} lacks its icon or explicit-only invocation policy"
    plugin_errors=1
fi
(( plugin_errors == 0 )) && ok 'Codex owns one branded story plugin; .agents exposes only its marketplace file'

section 'Kimi and DSH STORY router layouts'
router_entry_errors=0
KIMI_MARKETPLACE=".kimi-code/plugins/marketplace.json"
KIMI_PLUGIN_ROOT=".kimi-code/plugins/story"
if ! python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); p=json.load(open(sys.argv[2])); e=m["plugins"]; assert m["version"] == "2" and len(e) == 1 and e[0] == {"id": "story", "displayName": "STORY", "source": "./.kimi-code/plugins/story"}; assert p["name"] == "story" and p["skills"] == "./skills/" and p["interface"]["displayName"] == "STORY"' "${KIMI_MARKETPLACE}" "${KIMI_PLUGIN_ROOT}/.kimi-plugin/plugin.json"; then
    fail 'Kimi STORY plugin or marketplace metadata is invalid'
    router_entry_errors=1
fi
for skill_file in "${KIMI_PLUGIN_ROOT}/skills/story/SKILL.md" "${KIMI_PLUGIN_ROOT}/skills/story/SKILL_zh.md"; do
    if [[ ! -f "${skill_file}" ]] || \
       ! frontmatter_has_line "${skill_file}" 'name: story' || \
       ! frontmatter_has_line "${skill_file}" 'disableModelInvocation: true' || \
       ! grep -qF '.agents/commands/story.md' "${skill_file}"; then
        fail "${skill_file} is not an explicit-only wrapper around the shared router"
        router_entry_errors=1
    fi
    if ! grep -qF 'STORY_LANG=zh' "${skill_file}" || \
       ! grep -qF '.agents/commands/story.zh-CN.md' "${skill_file}"; then
        fail "${skill_file} does not apply STORY's Chinese router wording"
        router_entry_errors=1
    fi
done

DSH_COMMAND_ROOT=".dsh/commands/story"
if ! python3 -c 'import json,sys; p=json.load(open(sys.argv[1])); assert p["name"] == "story" and p["private"] is True and p["type"] == "module" and p["main"] == "lib/index.js" and p["dsh"]["bundle"]["patch"] == "./cordis.patch.yml"' "${DSH_COMMAND_ROOT}/package.json"; then
    fail 'DSH STORY command package metadata is invalid'
    router_entry_errors=1
fi
if [[ ! -f "${DSH_COMMAND_ROOT}/lib/index.js" ]] || \
   ! grep -qF 'ctx.commands.register' "${DSH_COMMAND_ROOT}/lib/index.js" || \
   ! grep -qF '.agents/commands/story.md' "${DSH_COMMAND_ROOT}/lib/index.js" || \
   ! grep -qF 'story-flow-status' "${DSH_COMMAND_ROOT}/lib/index.js"; then
    fail 'DSH /story command does not delegate to the shared router'
    router_entry_errors=1
fi
if [[ ! -f "${DSH_COMMAND_ROOT}/cordis.patch.yml" ]] || \
   ! grep -qE '^[[:space:]]*- id: story[[:space:]]*$' "${DSH_COMMAND_ROOT}/cordis.patch.yml" || \
   ! grep -qE "^[[:space:]]*name: ['\"]?story['\"]?[[:space:]]*$" "${DSH_COMMAND_ROOT}/cordis.patch.yml"; then
    fail 'DSH /story bundle patch does not register the story plugin'
    router_entry_errors=1
fi
(( router_entry_errors == 0 )) && ok 'Kimi and DSH expose explicit /story front doors backed by the shared router'

section 'Router deployment and documentation'
deployment_errors=0
for router_tree in ".codex/plugins" ".dsh/commands" ".kimi-code/plugins"; do
    if [[ "$(grep -Fxc "        \"${router_tree}\"" execs/update.sh)" -ne 2 ]]; then
        fail "execs/update.sh must carry ${router_tree} in both adopt and full-update paths"
        deployment_errors=1
    fi
done
for optional_tree in ".dsh/commands" ".kimi-code/plugins"; do
    if ! grep -qF "\"${optional_tree}\")" execs/update.sh; then
        fail "execs/update.sh does not allow an older ref to omit ${optional_tree}"
        deployment_errors=1
    fi
done
if ! grep -qF 'if is_optional_path "${tree}"; then' execs/update.sh; then
    fail "execs/update.sh --adopt does not skip router packages absent from an older ref"
    deployment_errors=1
fi
for readme in README.md README.zh-CN.md; do
    for command in \
        'codex plugin marketplace add .' \
        'codex plugin add story@story' \
        '/plugins install ./.kimi-code/plugins/story' \
        '/reload' \
        'dsh plugin --profile YOUR_PROFILE add ./.dsh/commands/story' \
        'dsh --profile YOUR_PROFILE --dump-config'; do
        if ! grep -qF "${command}" "${readme}"; then
            fail "${readme} omits router setup step: ${command}"
            deployment_errors=1
        fi
    done
    for shared_topic in \
        'STORY_LANG' \
        'STORY_HARNESSES' \
        'INVOLVE=low' \
        '.story/memory/MEMORY.md' \
        'bash execs/update.sh --diff' \
        'bash execs/update.sh TAG_OR_BRANCH' \
        'bash execs/update.sh --harnesses claude' \
        'bash execs/update.sh --skill story-flow-status' \
        '--adopt' \
        '--force'; do
        if ! grep -qF -- "${shared_topic}" "${readme}"; then
            fail "${readme} omits shared setup or update topic: ${shared_topic}"
            deployment_errors=1
        fi
    done
done
(( deployment_errors == 0 )) && ok 'all router packages update by harness, tolerate older refs, and share one setup template'

section 'Harness entry points, hooks, and configuration'
harness_errors=0
for path in \
    .agents/commands/story.md \
    .agents/commands/story.zh-CN.md \
    .claude/commands/story.md \
    .claude/commands/story.zh-CN.md \
    .cursor/commands/story.md \
    .cursor/commands/story.zh-CN.md \
    .qwen/commands/story.md \
    .qwen/commands/story.zh-CN.md \
    .pi/prompts/story.md \
    .pi/prompts/story.zh-CN.md \
    .kimi-code/plugins/story/skills/story/SKILL.md \
    .kimi-code/plugins/story/skills/story/SKILL_zh.md \
    .dsh/commands/story/lib/index.js \
    .pi/APPEND_SYSTEM.md \
    .pi/APPEND_SYSTEM.zh-CN.md; do
    [[ -f "${path}" ]] || { fail "missing harness entry point: ${path}"; harness_errors=1; }
done
for wrapper in \
    .claude/commands/story.md \
    .claude/commands/story.zh-CN.md \
    .cursor/commands/story.md \
    .cursor/commands/story.zh-CN.md \
    .qwen/commands/story.md \
    .qwen/commands/story.zh-CN.md \
    .pi/prompts/story.md \
    .pi/prompts/story.zh-CN.md; do
    if [[ -f "${wrapper}" ]] && ! grep -qF '.agents/commands/story.md' "${wrapper}"; then
        fail "${wrapper} does not delegate to the shared .agents/commands/story.md router"
        harness_errors=1
    fi
done
while IFS= read -r skill; do
    for prompt in ".pi/prompts/${skill}.md" ".pi/prompts/${skill}.zh-CN.md"; do
        if [[ ! -f "${prompt}" ]]; then
            fail "missing Pi prompt: ${prompt}"
            harness_errors=1
        elif ! frontmatter_has_key "${prompt}" 'argument-hint'; then
            fail "${prompt} lacks the per-skill argument-hint Pi reads from a prompt template"
            harness_errors=1
        fi
    done
done <<< "${BASE}"

for cfg in .claude/settings.json .codex/hooks.json .cursor/hooks.json .dsh/hooks.json .pi/settings.json .qwen/settings.json; do
    python3 -m json.tool "${cfg}" >/dev/null 2>&1 || { fail "invalid JSON: ${cfg}"; harness_errors=1; }
done

for root in .claude/hooks .codex/hooks .qwen/hooks; do
    for hook in story_commit_guard.sh story_involve_gate.sh story_memory.sh story_model_id.sh; do
        [[ -x "${root}/${hook}" ]] || { fail "missing or non-executable ${root}/${hook}"; harness_errors=1; }
    done
done
for root in .cursor/hooks .dsh/hooks .kimi-code/hooks; do
    for hook in story_commit_guard.sh story_memory.sh story_model_id.sh; do
        [[ -x "${root}/${hook}" ]] || { fail "missing or non-executable ${root}/${hook}"; harness_errors=1; }
    done
done
for hook in .pi/extensions/story-hooks/story_memory.sh .pi/extensions/story-hooks/story_model_id.sh; do
    [[ -x "${hook}" ]] || { fail "missing or non-executable ${hook}"; harness_errors=1; }
done
[[ -f .pi/extensions/story-hooks/index.ts ]] || { fail 'missing Pi session-context extension'; harness_errors=1; }
[[ -x .dsh/hooks/install.sh && -x .kimi-code/hooks/install.sh ]] || { fail 'DSH or Kimi global hook installer is not executable'; harness_errors=1; }
[[ -f .dsh/cordis.patch.yml ]] || { fail 'missing DSH composition patch'; harness_errors=1; }
(( harness_errors == 0 )) && ok 'all seven harnesses have valid entry points, registrations, and runtime hooks; every harness exposes the shared /story router'

section 'English and Simplified Chinese Markdown pairs'
markdown_errors=0
while IFS= read -r path; do
    case "${path}" in
        *.zh-CN.md|*_zh.md) continue ;;
        ./mates/MANIFEST.md) counterpart="./docs/mds/story-workflow/mates-MANIFEST.zh-CN.md" ;;
        */SKILL.md) counterpart="${path%SKILL.md}SKILL_zh.md" ;;
        *) counterpart="${path%.md}.zh-CN.md" ;;
    esac
    if [[ ! -f "${counterpart}" ]]; then
        fail "missing Chinese Markdown counterpart: ${path} -> ${counterpart}"
        markdown_errors=1
    fi
done < <(find . -path './.git' -prune -o -path './wkdrs' -prune -o \( -type f -o -type l \) -name '*.md' -print | sort)
(( markdown_errors == 0 )) && ok 'every English Markdown file has a Simplified Chinese counterpart'

section 'Scripts and repository layout'
script_errors=0
while IFS= read -r script; do
    bash -n "${script}" || { fail "bash syntax: ${script}"; script_errors=1; }
done < <(find -L execs .agents/skills .claude/hooks .codex/hooks .cursor/hooks .dsh/hooks .kimi-code/hooks .pi/extensions/story-hooks .qwen/hooks -type f -name '*.sh' | sort)
for script in execs/run.sh execs/update.sh execs/scpts/import.sh execs/scpts/lint.sh execs/scpts/fmt.sh .github/scripts/port.sh; do
    [[ -x "${script}" ]] || { fail "non-executable entrypoint: ${script}"; script_errors=1; }
done
(( script_errors == 0 )) && ok 'shell scripts parse and managed entrypoints are executable'

if ! bash .github/scripts/test_degree_levels.sh; then
    fail 'degree-level lint cases failed'
fi

grep -q 'Systematic Toolchain for Organizing Research over Years' README.md || fail 'README.md lacks the official expansion'
grep -q 'A STAR takes the STAGE to tell a STORY' README.md || fail 'README.md lacks the official tagline'
for path in degree/profile.tex degree/requirements.md notes/.gitkeep notes/refs/.gitkeep mates/MANIFEST.md manus/main.tex manus/stys/story.cls manus/stys/story.sty milestones/.gitkeep tasks/.gitkeep; do
    [[ -f "${path}" ]] || fail "missing core path: ${path}"
done
for path in notes notes/refs; do
    [[ -d "${path}" ]] || fail "missing core directory: ${path}"
done
[[ "$(readlink CLAUDE.md 2>/dev/null)" == AGENTS.md ]] || fail 'CLAUDE.md must link to AGENTS.md'
[[ "$(readlink docs/index.html 2>/dev/null)" == htmls/story.html ]] || fail 'docs/index.html link is wrong'
[[ "$(readlink docs/index_zh.html 2>/dev/null)" == htmls/story_zh.html ]] || fail 'docs/index_zh.html link is wrong'

stale_paths="$(find . -path './.git' -prune -o \( -iname 'stage-*' -o -iname 'stage_*' -o -iname '.stage' \) -print)"
[[ -z "${stale_paths}" ]] || fail "stale STAGE-owned paths remain: ${stale_paths}"
bad_words="$(grep -RInE --exclude-dir=.git --exclude='*.bst' --exclude='check_consistency.sh' '\bstoryd\b|\bstorys\b|SessionStoryt' . 2>/dev/null || true)"
[[ -z "${bad_words}" ]] || fail 'mechanical rename artifacts remain'

if (( FAILURES > 0 )); then
    printf '\n%d consistency failure(s).\n' "${FAILURES}"
    exit 1
fi
printf '\nAll STORY consistency checks passed.\n'
