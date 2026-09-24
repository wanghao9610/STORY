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

# Every manifest opens with a Shared conventions paragraph (conventions §7): it
# loads the conventions, reads .env once for the controls a run needs, and
# resolves the reply language in one order. Presence of the controls is checked,
# not the paragraph's wording. Claude-only frontmatter is pinned the way
# argument-hint is, against the one table that owns it: claude_frontmatter() is
# read from port.sh, so a row added there needs no second allowlist here. Only
# .claude/skills may carry a Claude-only field (effort, model, context, or any
# key the table renders), only the lines that table gives the skill, and every
# one of them. The table itself must keep story-flow-status's effort: medium.
CLAUDE_ONLY_KEYS=(effort model context)
section 'Skill frontmatter, conventions, and explicit-only policy'
policy_errors=0
eval "$(sed -n '/^claude_frontmatter() {/,/^}/p' .github/scripts/port.sh)"
if ! declare -F claude_frontmatter >/dev/null; then
    fail '.github/scripts/port.sh no longer defines claude_frontmatter(), the table of Claude-only frontmatter'
    policy_errors=1
    claude_frontmatter() { :; }
elif ! grep -qx 'effort: medium' <<< "$(claude_frontmatter story-flow-status)"; then
    fail 'port.sh claude_frontmatter no longer gives story-flow-status its Claude-only effort: medium'
    policy_errors=1
fi
# A key the table renders is Claude-only too, even when the list above lacks it.
while IFS= read -r skill; do
    [[ -n "${skill}" ]] || continue
    while IFS= read -r claude_line; do
        [[ "${claude_line}" == *:* ]] || continue
        case " ${CLAUDE_ONLY_KEYS[*]} " in
            *" ${claude_line%%:*} "*) ;;
            *) CLAUDE_ONLY_KEYS+=("${claude_line%%:*}") ;;
        esac
    done <<< "$(claude_frontmatter "${skill}")"
done <<< "${BASE}"
SLASH_ONLY=""
while IFS= read -r skill; do
    [[ -n "${skill}" ]] || continue
    for root in "${ROOTS[@]}"; do
        path="${root}/${skill}/SKILL.md"
        [[ -f "${path}" ]] || { fail "missing ${path}"; policy_errors=1; continue; }
        frontmatter_has_line "${path}" "name: ${skill}" || { fail "frontmatter name mismatch: ${path}"; policy_errors=1; }
        grep -q 'docs/mds/story-workflow/writing-workflow-conventions\.md' "${path}" || { fail "conventions not loaded: ${path}"; policy_errors=1; }
        for control in .env STORY_LANG INVOLVE STORY_MAIN; do
            grep -Fq -- "\`${control}\`" "${path}" || { fail "${path} does not name the shared control ${control}"; policy_errors=1; }
        done
        claude_lines=""
        [[ "${root}" == .claude/skills ]] && claude_lines="$(claude_frontmatter "${skill}")"
        for key in "${CLAUDE_ONLY_KEYS[@]}"; do
            frontmatter_has_key "${path}" "${key}" || continue
            if ! grep -q "^${key}:" <<< "${claude_lines}"; then
                fail "${path} carries the Claude-only field ${key}:, which port.sh claude_frontmatter does not give ${skill} in this tree"
                policy_errors=1
            fi
        done
        while IFS= read -r claude_line; do
            [[ -n "${claude_line}" ]] || continue
            if ! frontmatter_has_line "${path}" "${claude_line}"; then
                fail "${path} lacks '${claude_line}' from port.sh claude_frontmatter"
                policy_errors=1
            fi
        done <<< "${claude_lines}"
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
        guarded=false
        frontmatter_has_line "${root}/${skill}/SKILL.md" 'disable-model-invocation: true' && guarded=true
        if [[ "${policy}" == false && "${guarded}" != true ]]; then
            fail "${root}/${skill}/SKILL.md lacks its explicit-only guard"
            policy_errors=1
        elif [[ "${policy}" == true && "${guarded}" == true ]]; then
            fail "${root}/${skill}/SKILL.md is guarded but Codex allows implicit invocation"
            policy_errors=1
        fi
    done
done <<< "${BASE}"

roster_slash_only() {
    sed -nE 's/^\| `(story-[a-z-]+)` † \|.*/\1/p' "$1" | sort
}
roster_all() {
    sed -nE 's/^\| `(story-[a-z-]+)`( †)? \|.*/\1/p' "$1" | sort
}
CONVENTIONS="docs/mds/story-workflow/writing-workflow-conventions.md"
if [[ "$(roster_all "${CONVENTIONS}")" != "${BASE}" ]]; then
    fail "${CONVENTIONS}: skill roster differs from .agents/skills"
    policy_errors=1
fi
if [[ "$(roster_slash_only "${CONVENTIONS}")" != "$(printf '%s\n' "${SLASH_ONLY}" | sort)" ]]; then
    fail "${CONVENTIONS}: dagger set differs from the harness policy"
    policy_errors=1
fi
# The skills guide's table is the roster a reader meets first, and its goal-run
# paragraph says where a story-auto run stops by the † mark, so it carries the
# same skills and the same marks in English and in its kept Chinese edition.
for guide in docs/mds/story-workflow/writing-workflow-skills.md docs/mds/story-workflow/writing-workflow-skills.zh-CN.md; do
    if [[ "$(roster_all "${guide}")" != "${BASE}" ]]; then
        fail "${guide}: skill table differs from .agents/skills"
        policy_errors=1
    fi
    if [[ "$(roster_slash_only "${guide}")" != "$(printf '%s\n' "${SLASH_ONLY}" | sort)" ]]; then
        fail "${guide}: † marks differ from the harness policy"
        policy_errors=1
    fi
done

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
(( policy_errors == 0 )) && ok "conventions, skills guide (en/zh) and shared /story router (en/zh) list all $(printf '%s\n' "${BASE}" | wc -l | tr -d ' ') skills; $(printf '%s\n' "${SLASH_ONLY}" | wc -l | tr -d ' ') explicit-only skills are guarded in every harness; every manifest names .env, STORY_LANG, INVOLVE and STORY_MAIN; Claude-only frontmatter matches port.sh claude_frontmatter and sits in .claude/skills alone"

# Skills and hooks cite the conventions by section number (every provenance hook
# cites "section 7", every memory hook "section 10"), so the numbered headings
# are pinned: renumbering one means re-auditing each §n and "section n" citation
# first. §11 (harness adapters) is the only section allowed to name a harness, a
# hook event, or a harness-private key, and it opens by saying so; everything
# before it is the shared contract each harness implements. HARNESS_WORDS bans,
# before §11, the harness names, every hook event §11 names, the skill-policy
# keys (`allow_implicit_invocation`, `disable-model-invocation`, `openai.yaml`),
# the `hooks.json` and `settings.json` registration files, and the harness-only
# skill spellings `$story-<name>` and `/skill:story-<name>`; other harness-private
# paths and config keys are caught only through the harness name beside them.
# It deliberately leaves out `argument-hint`: §7 names that field as the skill's
# shared usage hint, not as one harness's key. The prose skills cite §5's
# human-writing contract, which absorbed the retired writing guide.
section 'Workflow conventions: sections, adapter boundary, human-writing contract'
conv_errors=0
CONV_HEADINGS=(
    '1. Sources of truth'
    '2. Evidence contract'
    '3. Structured record IDs and states'
    '4. Publication reuse and attribution'
    '5. Chapter contract'
    '6. Milestone contract'
    '7. Interaction, language, and provenance'
    '8. Verification'
    '9. Skill roster'
    '10. Project memory'
    '11. Harness adapters'
)
actual_headings="$(sed -nE 's/^## (.+)$/\1/p' "${CONVENTIONS}")"
if [[ "${actual_headings}" != "$(printf '%s\n' "${CONV_HEADINGS[@]}")" ]]; then
    fail "${CONVENTIONS} headings changed; skills and hooks cite them as §n and 'section n'. Re-audit those citations, then update CONV_HEADINGS:"
    diff <(printf '%s\n' "${CONV_HEADINGS[@]}") <(printf '%s\n' "${actual_headings}") | sed 's/^/      /'
    conv_errors=1
fi
for pinned in '5|Human-writing contract' '8|Completion handoff' '8|Goal runs' '11|Invocation and tags' '11|Hooks and model provenance'; do
    if ! awk -v want="${pinned}" '
        /^## [0-9]+\. / { n = $2; sub(/\.$/, "", n) }
        /^### / { h = substr($0, 5); if (n "|" h == want) found = 1 }
        END { exit !found }' "${CONVENTIONS}"; then
        fail "${CONVENTIONS}: '### ${pinned#*|}' is no longer under §${pinned%%|*}"
        conv_errors=1
    fi
done
for rule in 'Preserve the record.' 'Match the writer.' 'Review pattern clusters, not words.' 'Rewrite and verify.'; do
    grep -qF "**${rule}**" "${CONVENTIONS}" || { fail "${CONVENTIONS}: the human-writing contract (§5) lost its '${rule}' rule"; conv_errors=1; }
done
HARNESS_WORDS='claude|codex|cursor|kimi|qwen|(^|[^[:alnum:]_])(pi|dsh)([^[:alnum:]_]|$)|spawn_agent|reasoning_effort|AgentSwarm|SessionStart|SubagentStart|default_effort|UserPromptSubmit|PreToolUse|PermissionRequest|beforeShellExecution|before_agent_start|model_select|tool_call|openai\.yaml|allow_implicit_invocation|disable-model-invocation|hooks\.json|settings\.json|\$story-|/skill:'
harness_hits="$(awk '/^## 11\. /{exit} {print}' "${CONVENTIONS}" | grep -niE "${HARNESS_WORDS}" || true)"
if [[ -n "${harness_hits}" ]]; then
    fail "${CONVENTIONS}: harness-specific wording before §11 (harness adapters), the one section allowed to carry it:"
    printf '%s\n' "${harness_hits}" | sed 's/^/      /'
    conv_errors=1
fi
if ! awk '/^## 11\. /{f=1;next} f&&NF{print;exit}' "${CONVENTIONS}" | grep -Fq 'This is the one section of this file that names a harness'; then
    fail "${CONVENTIONS}: §11 (harness adapters) no longer opens by claiming the harness names"
    conv_errors=1
fi
HUMAN_WRITING_SKILLS=(story-chap-drafter story-copy-editor story-exam-reviewer)
for root in "${ROOTS[@]}"; do
    for skill in "${HUMAN_WRITING_SKILLS[@]}"; do
        grep -qi 'human-writing contract' "${root}/${skill}/SKILL.md" 2>/dev/null || {
            fail "${root}/${skill}/SKILL.md does not cite the human-writing contract (conventions §5)"
            conv_errors=1
        }
    done
done
(( conv_errors == 0 )) && ok "conventions keep their ${#CONV_HEADINGS[@]} numbered sections; only §11 names a harness; ${#HUMAN_WRITING_SKILLS[@]} prose skills cite the §5 human-writing contract in every tree"

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
    README.zh-CN.md \
    docs/mds/story-workflow/writing-workflow-skills.zh-CN.md; do
    if ! grep -qF '`下一步：`' "${path}"; then
        fail "Chinese completion handoff is missing from ${path}"
        handoff_errors=1
    fi
done
if ! grep -qF 'recommendation, not authorization' docs/mds/story-workflow/writing-workflow-conventions.md || \
   ! grep -qF 'This recommendation does not authorize another skill to run.' docs/mds/story-workflow/writing-workflow-skills.md || \
   ! grep -qF '这项建议不构成运行另一个 skill 的授权。' docs/mds/story-workflow/writing-workflow-skills.zh-CN.md; then
    fail 'completion handoff does not preserve the authorization boundary in the conventions and both skills guides'
    handoff_errors=1
fi
(( handoff_errors == 0 )) && ok 'every workflow step reports one localized next action without expanding authorization'

# /story-auto is the one standing authorization for a multi-step run, and STORY
# bounds it more tightly than STAR's /star-auto does: it starts only unmarked
# skills, so the six † skills keep their author-typed-only rule; it never
# writes evidence, degree facts, or received feedback, never declares a deposit
# ready, never commits, and never waits on green lint. The procedure has to say
# so, name every † skill the roster marks, and stay free of the STAR grant
# machinery (a subagent that runs a † skill, stop= lines, the unattended Git
# flow, launch markers, model tiers), so a later STAR sync cannot bring it back
# unnoticed. The conventions, AGENTS.md and both router halves carry the grant.
section 'Goal run grant (/story-auto)'
auto_errors=0
AUTO_PROCEDURE=".agents/commands/story-auto.md"
AUTO_ENTRIES=(
    "${AUTO_PROCEDURE}"
    .claude/commands/story-auto.md
    .cursor/commands/story-auto.md
    .qwen/commands/story-auto.md
    .pi/prompts/story-auto.md
    .codex/plugins/story/skills/story-auto/SKILL.md
    .kimi-code/plugins/story/skills/story-auto/SKILL.md
    .dsh/commands/story/lib/index.js
)
if [[ ! -f "${AUTO_PROCEDURE}" ]]; then
    fail "missing the shared goal-run procedure ${AUTO_PROCEDURE}"
    auto_errors=1
else
    for phrase in \
        'It never starts a skill marked †' \
        'Green lint is never the check' \
        'nothing in a goal run writes `mates/`' \
        'write anything under `degree/`' \
        'write or edit received feedback under `milestones/*/feedback/`' \
        'declare a deposit ready' \
        'commit, push, or tag' \
        'are asked and waited on at every involve level' \
        'a full pass made no progress' \
        'It ends with exactly one `Next action:` line'; do
        if ! grep -qF -- "${phrase}" "${AUTO_PROCEDURE}"; then
            fail "${AUTO_PROCEDURE} lost a goal-run limit: ${phrase}"
            auto_errors=1
        fi
    done
    # The never-list names the † skills on one line; it must name exactly the
    # roster's explicit-only set, so a skill that gains or loses its † changes
    # what a goal run may start only through a visible edit here.
    never_line="$(grep -m1 '^- start a skill marked †:' "${AUTO_PROCEDURE}")"
    never_named="$(grep -oE '`story-[a-z-]+`' <<< "${never_line}" | tr -d '`' | sort)"
    if [[ "${never_named}" != "$(printf '%s\n' "${SLASH_ONLY}" | sort)" ]]; then
        fail "${AUTO_PROCEDURE}: the '- start a skill marked †:' line must name exactly the roster's explicit-only skills:"
        diff <(printf '%s\n' "${SLASH_ONLY}" | sort) <(printf '%s\n' "${never_named}") | sed 's/^/      /'
        auto_errors=1
    fi
fi
for path in "${AUTO_ENTRIES[@]}"; do
    [[ -f "${path}" ]] || continue
    # The words are matched in any case; the model-tier keys only exactly, so
    # STORY's own story_model_id provenance hook is never read as a tier key.
    leaks="$( { grep -niE 'subagent|stop=|auto=unattended|\.await|squash|worktree|tier=' "${path}"; \
                grep -nE '(STAR|STORY)_[A-Z]+_MODEL' "${path}"; } | sort -t: -k1,1n -u)"
    if [[ -n "${leaks}" ]]; then
        fail "${path} carries STAR goal-run machinery STORY does not grant:"
        printf '%s\n' "${leaks}" | sed 's/^/      /'
        auto_errors=1
    fi
done
if ! awk '/^### Goal runs/{f=1;next} /^#/{f=0} f' "${CONVENTIONS}" | grep -qF 'It never starts a skill marked †'; then
    fail "${CONVENTIONS}: §8 Goal runs no longer says a goal run never starts a skill marked †"
    auto_errors=1
fi
if ! grep -qF '(../../../.agents/commands/story-auto.md)' "${CONVENTIONS}"; then
    fail "${CONVENTIONS}: §8 Goal runs does not link the procedure"
    auto_errors=1
fi
# AGENTS.md is read by every harness, so it names the goal run without any
# one harness's spelling (`/story-auto` as a slash command, `$story-auto` in Codex); the shared
# router is a front door whose wrappers respell its slash form.
if ! grep -qF '`story-auto <goal>`' AGENTS.md || grep -qF '/story-auto' AGENTS.md; then
    fail 'AGENTS.md must name `story-auto <goal>`, harness-neutrally, as the one standing authorization'
    auto_errors=1
fi
grep -qF '`/story-auto <goal>`' .agents/commands/story.md || { fail '.agents/commands/story.md does not name /story-auto as the one standing authorization'; auto_errors=1; }
grep -qF '`/story-auto <目标>`' .agents/commands/story.zh-CN.md || { fail '.agents/commands/story.zh-CN.md does not hand goal pursuit to /story-auto'; auto_errors=1; }
(( auto_errors == 0 )) && ok "/story-auto is bounded: it never starts the $(printf '%s\n' "${SLASH_ONLY}" | wc -l | tr -d ' ') explicit-only skills, keeps evidence, degree facts, feedback, deposit and git out of reach, and carries no STAR grant machinery"

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
for skill_file in "${PLUGIN_ROOT}/skills/story/SKILL.md"; do
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
# $story-auto rides the same plugin: an explicit-only skill wrapping the shared
# .agents/commands/story-auto.md procedure. It is English only, so unlike the
# router it reads no Chinese twin.
AUTO_SKILL="${PLUGIN_ROOT}/skills/story-auto/SKILL.md"
if [[ ! -f "${AUTO_SKILL}" ]] || \
   ! frontmatter_has_line "${AUTO_SKILL}" 'name: story-auto' || \
   ! grep -qF 'Read `.agents/commands/story-auto.md`' "${AUTO_SKILL}" || \
   ! grep -qF 'is never started' "${AUTO_SKILL}" || \
   ! grep -qF 'allow_implicit_invocation: false' "${PLUGIN_ROOT}/skills/story-auto/agents/openai.yaml"; then
    fail "${PLUGIN_ROOT}/skills/story-auto is not the explicit-only wrapper around the shared goal-run procedure"
    plugin_errors=1
fi
if ! grep -qF '$story-auto' "${PLUGIN_ROOT}/.codex-plugin/plugin.json"; then
    fail "${PLUGIN_ROOT}/.codex-plugin/plugin.json does not describe \$story-auto"
    plugin_errors=1
fi
(( plugin_errors == 0 )) && ok 'Codex owns one branded story plugin, with $story and the explicit-only $story-auto; .agents exposes only its marketplace file'

section 'Kimi and DSH STORY router layouts'
router_entry_errors=0
KIMI_MARKETPLACE=".kimi-code/plugins/marketplace.json"
KIMI_PLUGIN_ROOT=".kimi-code/plugins/story"
if ! python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); p=json.load(open(sys.argv[2])); e=m["plugins"]; assert m["version"] == "2" and len(e) == 1 and e[0] == {"id": "story", "displayName": "STORY", "source": "./.kimi-code/plugins/story"}; assert p["name"] == "story" and p["skills"] == "./skills/" and p["interface"]["displayName"] == "STORY"' "${KIMI_MARKETPLACE}" "${KIMI_PLUGIN_ROOT}/.kimi-plugin/plugin.json"; then
    fail 'Kimi STORY plugin or marketplace metadata is invalid'
    router_entry_errors=1
fi
for skill_file in "${KIMI_PLUGIN_ROOT}/skills/story/SKILL.md"; do
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
KIMI_AUTO_SKILL="${KIMI_PLUGIN_ROOT}/skills/story-auto/SKILL.md"
if [[ ! -f "${KIMI_AUTO_SKILL}" ]] || \
   ! frontmatter_has_line "${KIMI_AUTO_SKILL}" 'name: story-auto' || \
   ! frontmatter_has_line "${KIMI_AUTO_SKILL}" 'disableModelInvocation: true' || \
   ! grep -qF 'Read `.agents/commands/story-auto.md`' "${KIMI_AUTO_SKILL}" || \
   ! grep -qF 'is never started' "${KIMI_AUTO_SKILL}"; then
    fail "${KIMI_PLUGIN_ROOT}/skills/story-auto is not the explicit-only wrapper around the shared goal-run procedure"
    router_entry_errors=1
fi
if ! grep -qF '/story-auto' "${KIMI_PLUGIN_ROOT}/.kimi-plugin/plugin.json"; then
    fail "${KIMI_PLUGIN_ROOT}/.kimi-plugin/plugin.json does not describe /story-auto"
    router_entry_errors=1
fi
if ! grep -qF 'name: "story-auto",' "${DSH_COMMAND_ROOT}/lib/index.js" || \
   ! grep -qF 'Read \`.agents/commands/story-auto.md\`' "${DSH_COMMAND_ROOT}/lib/index.js" || \
   ! grep -qF '/story-auto' "${DSH_COMMAND_ROOT}/cordis.patch.yml"; then
    fail "${DSH_COMMAND_ROOT} does not also register /story-auto forwarding to the shared goal-run procedure"
    router_entry_errors=1
fi
# The shared files print `/story-<name>`, which is no DSH command: every DSH
# follow-up respells it as `/skill:story-<name>`, as the Kimi and Codex wrappers do,
# except `/story-auto`, which this package registers as a command and no DSH skill
# backs, so respelling it would print a command DSH does not have.
if [[ "$(grep -cF '${spelling}' "${DSH_COMMAND_ROOT}/lib/index.js")" != 4 ]] || \
   ! grep -qF "a skill's command is \`/skill:story-<name> <argument>\` wherever the shared file writes \`/story-<name> <argument>\`, except \`/story-auto <goal>\`, which DSH registers as a command" "${DSH_COMMAND_ROOT}/lib/index.js"; then
    fail "${DSH_COMMAND_ROOT}/lib/index.js: each of its four follow-ups must respell /story-<name> as /skill:story-<name>, leaving the registered /story-auto command as written"
    router_entry_errors=1
fi
(( router_entry_errors == 0 )) && ok 'Kimi and DSH expose explicit /story and /story-auto front doors backed by the shared router and goal-run procedure'

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
        '/story-auto' \
        'STORY_LANG' \
        'STORY_HARNESSES' \
        'INVOLVE=low' \
        '.story/memory/' \
        'bash execs/update.sh --diff' \
        'bash execs/update.sh TAG_OR_BRANCH' \
        'bash execs/update.sh --harnesses claude' \
        'bash execs/update.sh --skill story-flow-status' \
        '--adopt' \
        '--force' \
        'effort: medium' \
        'RETIRED_FILES'; do
        if ! grep -qF -- "${shared_topic}" "${readme}"; then
            fail "${readme} omits shared setup or update topic: ${shared_topic}"
            deployment_errors=1
        fi
    done
done
# The change log ships in both READMEs, entry for entry: a dated entry in one
# and not the other is a pair that drifted.
changelog_dates() { # $1 = README, $2 = its change-log heading
    # Bytewise: macOS awk compares strings by locale collation, under which
    # every CJK heading can compare equal to '## 更新日志'.
    LC_ALL=C awk -v heading="$2" '
        $0 == heading { inside = 1; next }
        inside && /^## / { exit }
        inside && /^- \*\*/ && match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) { print substr($0, RSTART, RLENGTH) }
    ' "$1"
}
changelog_en="$(changelog_dates README.md '## Change log')"
changelog_zh="$(changelog_dates README.zh-CN.md '## 更新日志')"
if [[ -z "${changelog_en}" || "${changelog_en}" != "${changelog_zh}" ]]; then
    fail "README.md and README.zh-CN.md do not carry the same dated change-log entries: en [${changelog_en//$'\n'/ }], zh [${changelog_zh//$'\n'/ }]"
    deployment_errors=1
fi
(( deployment_errors == 0 )) && ok 'all router packages update by harness, tolerate older refs, and share one setup template; both READMEs carry the same change log'

section 'Harness entry points, hooks, and configuration'
harness_errors=0
for path in \
    .agents/commands/story.md \
    .agents/commands/story.zh-CN.md \
    .agents/commands/story-auto.md \
    .claude/commands/story.md \
    .cursor/commands/story.md \
    .qwen/commands/story.md \
    .pi/prompts/story.md \
    .claude/commands/story-auto.md \
    .cursor/commands/story-auto.md \
    .qwen/commands/story-auto.md \
    .pi/prompts/story-auto.md \
    .codex/plugins/story/skills/story-auto/SKILL.md \
    .kimi-code/plugins/story/skills/story/SKILL.md \
    .kimi-code/plugins/story/skills/story-auto/SKILL.md \
    .dsh/commands/story/lib/index.js \
    .pi/APPEND_SYSTEM.md; do
    [[ -f "${path}" ]] || { fail "missing harness entry point: ${path}"; harness_errors=1; }
done
for wrapper in \
    .claude/commands/story.md \
    .cursor/commands/story.md \
    .qwen/commands/story.md \
    .pi/prompts/story.md; do
    if [[ -f "${wrapper}" ]] && ! grep -qF '.agents/commands/story.md' "${wrapper}"; then
        fail "${wrapper} does not delegate to the shared .agents/commands/story.md router"
        harness_errors=1
    fi
done
# /story-auto ships the same way: four wrappers over the shared goal-run
# procedure, each repeating that a † skill is never started. The Claude one is
# user-only, so the model cannot grant itself a multi-step run by invoking it.
for wrapper in \
    .claude/commands/story-auto.md \
    .cursor/commands/story-auto.md \
    .qwen/commands/story-auto.md \
    .pi/prompts/story-auto.md; do
    [[ -f "${wrapper}" ]] || continue
    if ! grep -qF '.agents/commands/story-auto.md' "${wrapper}" || \
       ! grep -qF 'is never started' "${wrapper}"; then
        fail "${wrapper} does not delegate to the shared .agents/commands/story-auto.md procedure, or drops its † rule"
        harness_errors=1
    fi
done
if [[ -f .claude/commands/story-auto.md ]] && \
   ! frontmatter_has_line .claude/commands/story-auto.md 'disable-model-invocation: true'; then
    fail '.claude/commands/story-auto.md must stay user-only (disable-model-invocation: true)'
    harness_errors=1
fi
while IFS= read -r skill; do
    prompt=".pi/prompts/${skill}.md"
    if [[ ! -f "${prompt}" ]]; then
        fail "missing Pi prompt: ${prompt}"
        harness_errors=1
    elif ! frontmatter_has_key "${prompt}" 'argument-hint'; then
        fail "${prompt} lacks the per-skill argument-hint Pi reads from a prompt template"
        harness_errors=1
    fi
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
for hook in story_commit_guard.sh story_memory.sh story_model_id.sh; do
    [[ -x ".pi/extensions/story-hooks/${hook}" ]] || { fail "missing or non-executable .pi/extensions/story-hooks/${hook}"; harness_errors=1; }
done
[[ -f .pi/extensions/story-hooks/index.ts ]] || { fail 'missing Pi session-context extension'; harness_errors=1; }
# Pi has no registration file: its extension is the registration, and it must
# hand the bash tool's command to the guard, or the guard never runs there.
if ! grep -qF '"tool_call"' .pi/extensions/story-hooks/index.ts || \
   ! grep -qF 'story_commit_guard.sh' .pi/extensions/story-hooks/index.ts; then
    fail 'the Pi extension does not wire story_commit_guard.sh to its tool_call event'
    harness_errors=1
fi
[[ -x .dsh/hooks/install.sh && -x .kimi-code/hooks/install.sh ]] || { fail 'DSH or Kimi global hook installer is not executable'; harness_errors=1; }
[[ -f .dsh/cordis.patch.yml ]] || { fail 'missing DSH composition patch'; harness_errors=1; }

# The commit guard's rule core is hand-synced across the seven harness copies;
# existence checks alone let a rule added to one tree drift out of the others,
# so the marker-delimited core must stay byte-identical to the .claude copy.
GUARD_MARKER='^# ==== STORY shared guard core'
GUARD_REF="$(awk "/${GUARD_MARKER}/{p=1} p" .claude/hooks/story_commit_guard.sh)"
if [[ -z "${GUARD_REF}" ]]; then
    fail '.claude/hooks/story_commit_guard.sh lacks the shared-guard-core marker'
    harness_errors=1
else
    for root in .codex/hooks .cursor/hooks .dsh/hooks .kimi-code/hooks .pi/extensions/story-hooks .qwen/hooks; do
        if [[ "$(awk "/${GUARD_MARKER}/{p=1} p" "${root}/story_commit_guard.sh" 2>/dev/null)" != "${GUARD_REF}" ]]; then
            fail "${root}/story_commit_guard.sh shared guard core differs from the .claude copy"
            harness_errors=1
        fi
    done
fi

# Every involve gate must refuse to auto-allow a path with a `..` component:
# the root-prefix containment check is textual, and this hardening once lived
# only in the Codex port.
for gate in .claude/hooks/story_involve_gate.sh .codex/hooks/story_involve_gate.sh .qwen/hooks/story_involve_gate.sh; do
    if ! grep -Eq 'path_ok|\*/\.\.' "${gate}"; then
        fail "${gate} lacks the dot-dot traversal rejection"
        harness_errors=1
    fi
done

# Claude alone answers its shell prompt at low (story_bash_gate.sh), and its two
# gates take the level from the shared resolver, which reads the involve= token
# of the session's latest STORY command. The settings ship allow rules for the
# read-only model-id resolver the provenance line hands a skill — its injected
# path is relative so a committed rule can match it — and for story-flow-status's
# read-only collector.
for hook in story_bash_gate.sh story_involve_level.sh; do
    [[ -x ".claude/hooks/${hook}" ]] || { fail "missing or non-executable .claude/hooks/${hook}"; harness_errors=1; }
done
grep -qF '.claude/hooks/story_bash_gate.sh' .claude/settings.json || \
    { fail '.claude/settings.json does not register story_bash_gate.sh'; harness_errors=1; }
for gate in .claude/hooks/story_bash_gate.sh .claude/hooks/story_involve_gate.sh; do
    grep -qF 'story_involve_level.sh' "${gate}" || { fail "${gate} does not take its level from story_involve_level.sh"; harness_errors=1; }
done
for rule in \
    'Bash(bash .claude/hooks/story_model_id.sh --resolve:*)' \
    'Bash(bash .claude/skills/story-flow-status/scripts/scan.sh)' \
    'Bash(bash .claude/skills/story-flow-status/scripts/scan.sh:*)'; do
    python3 -c 'import json, sys; sys.exit(sys.argv[2] not in json.load(open(sys.argv[1])).get("permissions", {}).get("allow", []))' \
        .claude/settings.json "${rule}" || { fail ".claude/settings.json does not allow ${rule}"; harness_errors=1; }
done
grep -qF 'self=".claude/hooks/story_model_id.sh"' .claude/hooks/story_model_id.sh || \
    { fail '.claude/hooks/story_model_id.sh injects a path its allow rule cannot match'; harness_errors=1; }
# Who is asked, and which model is recorded, are behavior a grep cannot pin, so
# the gates and resolvers run against fixtures.
if ! bash .github/scripts/test_hooks.sh; then
    fail 'a gate or provenance hook no longer behaves as its fixtures require'
    harness_errors=1
fi
(( harness_errors == 0 )) && ok 'all seven harnesses have valid entry points, registrations, and runtime hooks; every harness exposes the shared /story router and /story-auto goal run'

# The seven memory hooks are hand-synced copies, one per runtime, and each builds
# the index from the memory files' frontmatter itself. The literals they share
# with conventions §10 are grepped: the field separator (space, middle dot, space) and
# the aging rule (both date spellings of the 180-day cutoff, gated on the type
# `env`). What the awk does is shown, not read: every copy runs at its own depth
# against one fixture store (an aged `env`, an `insight` of the same date, a
# newer `deadend` that has to lead the shared block, a git-ignored legacy file
# with no `summary:`, and a hand-kept MEMORY.md from an earlier release, which no
# hook reads) and has to print the same index as the .claude copy, four lines
# with one stale mark, newest first. Each copy then runs as its runtime calls it,
# against the versioned store alone, and has to exit 0 with the index in the
# shape its runtime reads: hookSpecificOutput.additionalContext for Claude Code,
# Codex, DSH and Qwen Code, additional_context for Cursor, and plain text for
# Kimi Code and Pi, whose extension also discards the output of a non-zero exit.
section 'Project memory hooks'
memory_errors=0
MEMORY_HOOKS=(
    .claude/hooks/story_memory.sh
    .codex/hooks/story_memory.sh
    .cursor/hooks/story_memory.sh
    .dsh/hooks/story_memory.sh
    .kimi-code/hooks/story_memory.sh
    .pi/extensions/story-hooks/story_memory.sh
    .qwen/hooks/story_memory.sh
)
for f in "${MEMORY_HOOKS[@]}" "${CONVENTIONS}"; do
    grep -qF ' · ' "${f}" 2>/dev/null || \
        { fail "${f} no longer carries the memory index separator ' · '"; memory_errors=1; }
done
for f in "${MEMORY_HOOKS[@]}"; do
    { grep -qF -- '-v-180d' "${f}" && grep -qF '180 days ago' "${f}"; } || \
        { fail "${f} lost a spelling of the 180-day cutoff (-v-180d / '180 days ago')"; memory_errors=1; }
    grep -qF 'f["type"] == "env"' "${f}" || \
        { fail "${f} no longer gates the stale mark on the literal type env"; memory_errors=1; }
done
grep -qF '180 days' "${CONVENTIONS}" || \
    { fail 'conventions §10 no longer states the 180-day aging window'; memory_errors=1; }
memory_fixture="$(mktemp -d)"
mkdir -p "${memory_fixture}/.story/memory/local"
printf -- '---\ntype: env\nscope: machine:box\nsummary: biber is missing here\nverified: 2025-01-01\n---\nbody\n' > "${memory_fixture}/.story/memory/old-biber.md"
printf -- '---\ntype: insight\nscope: milestone:proposal\nsummary: table IDs outlast row numbers\nverified: 2025-01-01\n---\nbody\n' > "${memory_fixture}/.story/memory/table-ids.md"
printf -- '---\ntype: deadend\nscope: global\nsummary: a per-paper chapter order failed the mock examination\nverified: 2026-03-01\n---\nbody\n' > "${memory_fixture}/.story/memory/paper-order.md"
printf -- '---\ntype: pref\nscope: global\nverified: 2026-09-01\n---\n\nThe first body line stands in.\n' > "${memory_fixture}/.story/memory/local/legacy.md"
printf -- '# Project Memory — index\n\n- env · global · 2020-01-01 · [gone](gone.md) — a hand-kept line\n' > "${memory_fixture}/.story/memory/MEMORY.md"
memory_reference=""
for f in "${MEMORY_HOOKS[@]}"; do
    mkdir -p "${memory_fixture}/$(dirname "${f}")"
    cp "${f}" "${memory_fixture}/${f}"
    listed="$(bash "${memory_fixture}/${f}" --list </dev/null 2>/dev/null)"
    newest="$(sed -n '/^Shared (\.story\/memory\/):$/{n;p;q;}' <<< "${listed}")"
    if [[ "$(grep -c '^- ' <<< "${listed}")" != 4 || "$(grep -c '\[stale:' <<< "${listed}")" != 1 || \
          "${newest}" != *"[paper-order](paper-order.md)"* || \
          "${listed}" != *"— The first body line stands in."* || "${listed}" == *"a hand-kept line"* ]]; then
        fail "${f} --list does not index the fixture store (4 lines, 1 stale mark, newest shared first, legacy summary from the body, no MEMORY.md line):"
        printf '%s\n' "${listed:-<nothing>}" | sed 's/^/      /'
        memory_errors=1
    elif [[ -z "${memory_reference}" ]]; then
        memory_reference="${listed}"
    elif [[ "${listed}" != "${memory_reference}" ]]; then
        fail "${f} --list prints a different index from ${MEMORY_HOOKS[0]}:"
        diff <(printf '%s\n' "${memory_reference}") <(printf '%s\n' "${listed}") | sed 's/^/      /'
        memory_errors=1
    fi
done
rm -rf "${memory_fixture}/.story/memory/local"
for f in "${MEMORY_HOOKS[@]}"; do
    status=0
    out="$(bash "${memory_fixture}/${f}" <<< '{}' 2>/dev/null)" || status=$?
    case "${f}" in
        .cursor/*) shape='additional_context' ;;
        .kimi-code/*|.pi/*) shape='text' ;;
        *) shape='hookSpecificOutput.additionalContext' ;;
    esac
    if (( status != 0 )); then
        fail "${f} exits ${status} when local/ is absent"
        memory_errors=1
    elif [[ "${shape}" == text ]]; then
        [[ "${out}" == "STORY project memory"* && "${out}" == *"table IDs outlast row numbers"* ]] || \
            { fail "${f} does not print the index as plain text starting 'STORY project memory'"; memory_errors=1; }
    elif ! python3 -c 'import json, sys
value = json.loads(sys.stdin.read())
for key in sys.argv[1].split("."):
    value = value[key]
sys.exit(0 if "table IDs outlast row numbers" in value else 1)' "${shape}" <<< "${out}" 2>/dev/null; then
        fail "${f} does not print JSON carrying the index in ${shape}"
        memory_errors=1
    fi
done
rm -rf "${memory_fixture}"
(( memory_errors == 0 )) && ok "all ${#MEMORY_HOOKS[@]} memory hooks build the same index from the files' frontmatter, newest first, mark an aged env stale, and exit 0 with it in the shape their runtime reads"

# STORY is the template every thesis starts from: a clone or the GitHub template
# copies .story/memory/ as it stands, so a memory about developing STORY would
# arrive in every thesis as a fact about that thesis. Upstream's own memories
# live under the git-ignored .story/memory/local/ whatever their scope
# (CONTRIBUTING), and this holds what would ship there to the .gitkeep the
# template tracks: tracked or new files, less what is deleted or ignored, as the
# update fixture computes its upstream. A thesis that kept .github/ versions its
# own memories, so the check runs only where the repository is upstream: the
# GitHub Actions repository (a pull request from a fork runs as its base), else
# the origin remote.
section 'Upstream memory store ships as its template'
upstream_id="${GITHUB_REPOSITORY:-$(git config --get remote.origin.url 2>/dev/null || true)}"
if [[ "${upstream_id}" =~ (^|[/:])wanghao9610/STORY(\.git)?/?$ ]]; then
    # NUL-delimited, as the update fixture reads it: without -z, git quotes a
    # name outside printable ASCII (a Chinese slug, say), the existence test
    # then misses the quoted string, and the file slips past the check.
    shipped_memory="$(git ls-files -z --cached --others --exclude-standard -- .story/memory | while IFS= read -r -d '' rel; do
        [[ -e "${rel}" || -L "${rel}" ]] && printf '%s\n' "${rel}"
    done)"
    if [[ "${shipped_memory}" == '.story/memory/.gitkeep' ]]; then
        ok '.story/memory/ ships only the .gitkeep the template tracks'
    else
        fail ".story/memory/ would ship more than .gitkeep; STORY's own memories belong under the git-ignored .story/memory/local/:"
        diff <(printf '%s\n' '.story/memory/.gitkeep') <(printf '%s\n' "${shipped_memory}") | sed 's/^/      /'
    fi
else
    ok "skipped outside the upstream repository (${upstream_id:-no origin remote}): a thesis versions its own memories"
fi

# Cursor reads AGENTS.md only through its rule file, which repeats the AGENTS.md
# body under four lines of rule frontmatter and a blank line; any other
# difference is drift. A new frontmatter key there moves the tail -n +6 offset.
section 'Cursor rule mirrors AGENTS.md'
CURSOR_RULE=".cursor/rules/agent-instructions.mdc"
if diff AGENTS.md <(tail -n +6 "${CURSOR_RULE}") >/dev/null; then
    ok "${CURSOR_RULE} matches the AGENTS.md body"
else
    fail "${CURSOR_RULE} has drifted from AGENTS.md:"
    diff AGENTS.md <(tail -n +6 "${CURSOR_RULE}") | sed 's/^/      /'
fi

# Instructions and the workflow conventions are English only: a run in Chinese follows
# them and replies in Chinese. A Chinese edition ships only where a person or a
# run reads it, and each one is listed here with its English original. Anything
# else in Chinese is a twin STORY retired, and it must not come back. The walk
# prunes what a thesis owns rather than STORY (notes, milestones, tasks, the
# evidence store, and the memory store, versioned and machine-local alike),
# where a thesis may keep twins of its own from an earlier release. Upstream's
# own store is held to its .gitkeep above.
section 'Chinese editions and retired files'
markdown_errors=0
ZH_PAIRS=(
    "README.md|README.zh-CN.md"
    "docs/mds/story-workflow/writing-workflow-skills.md|docs/mds/story-workflow/writing-workflow-skills.zh-CN.md"
    ".agents/commands/story.md|.agents/commands/story.zh-CN.md"
    "degree/committee.md|degree/committee.zh-CN.md"
    "degree/requirements.md|degree/requirements.zh-CN.md"
)
ZH_ALLOWED=""
for pair in "${ZH_PAIRS[@]}"; do
    for half in "${pair%%|*}" "${pair#*|}"; do
        [[ -f "${half}" ]] || { fail "${half} is missing; ${pair%%|*} ships as an en/zh pair"; markdown_errors=1; }
    done
    ZH_ALLOWED="${ZH_ALLOWED}./${pair#*|}"$'\n'
done
while IFS= read -r path; do
    if ! grep -qxF -- "${path}" <<<"${ZH_ALLOWED}"; then
        fail "${path}: STORY ships no Chinese edition of this file; the English one is the only copy"
        markdown_errors=1
    fi
done < <(find . \( -path './.git' -o -path './wkdrs' -o -path './notes' -o -path './milestones' -o -path './tasks' -o -path './mates' -o -path './.story/memory' \) -prune \
    -o \( -type f -o -type l \) \( -name '*.zh-CN.md' -o -name '*_zh.md' \) -print | sort)
# By name and with no -type test, so a dangling link left by a hand-deleted
# target is caught too: SKILL.md is the only manifest in every tree and plugin.
while IFS= read -r path; do
    fail "${path}: SKILL.md has no Chinese edition; a Chinese run reads SKILL.md and replies in Chinese"
    markdown_errors=1
done < <(find "${ROOTS[@]}" .codex/skills .codex/plugins .kimi-code/plugins -name SKILL_zh.md | sort)
# Every file execs/update.sh retires downstream stays gone here, so an update
# never deletes what upstream has quietly started shipping again.
RETIRED_LIST="$(sed -n '/^RETIRED_FILES=(/,/^)/p' execs/update.sh | sed -nE 's/^[[:space:]]*"([^"]+)".*/\1/p')"
if [[ -z "${RETIRED_LIST}" ]]; then
    fail 'execs/update.sh has no readable RETIRED_FILES list'
    markdown_errors=1
fi
while IFS= read -r path; do
    [[ -n "${path}" ]] || continue
    if [[ -e "${path}" || -L "${path}" ]]; then
        fail "${path} is back, but execs/update.sh retires it downstream (RETIRED_FILES)"
        markdown_errors=1
    fi
done <<<"${RETIRED_LIST}"
(( markdown_errors == 0 )) && ok "${#ZH_PAIRS[@]} en/zh pairs ship; no other Chinese edition, SKILL_zh.md, or retired file is present"
# The three specs folded into the conventions (§5, §7 with §11, §10) stay
# folded: beyond RETIRED_FILES keeping the files gone, no shipped file may point
# at one by path again. execs/update.sh names them to retire them, and this
# script to reject them; a thesis's own records are skipped.
spec_links="$(grep -RInE --exclude-dir=.git --exclude-dir=wkdrs --exclude-dir=notes --exclude-dir=milestones \
    --exclude-dir=tasks --exclude-dir=mates --exclude-dir=manus --exclude-dir=.story \
    '(human-writing-guide|memory_spec|model_id_spec)(\.zh-CN)?\.md' . 2>/dev/null |
    grep -vE '^\./(execs/update\.sh|\.github/scripts/check_consistency\.sh):' || true)"
if [[ -n "${spec_links}" ]]; then
    fail 'a file still points at a retired workflow spec; cite the conventions section that absorbed it:'
    printf '%s\n' "${spec_links}" | sed 's/^/      /'
else
    ok 'no file points at the retired human-writing guide, memory spec, or model-id spec'
fi
# Whether an update still deletes them is behavior, not text a grep can pin, so
# the updater is run against a fixture thesis.
if ! bash .github/scripts/test_update_retired.sh; then
    fail 'execs/update.sh no longer retires what upstream dropped'
fi

section 'Scripts and repository layout'
script_errors=0
while IFS= read -r script; do
    bash -n "${script}" || { fail "bash syntax: ${script}"; script_errors=1; }
done < <(find -L execs .agents/skills .claude/hooks .codex/hooks .cursor/hooks .dsh/hooks .kimi-code/hooks .pi/extensions/story-hooks .qwen/hooks .github/scripts -type f -name '*.sh' | sort)
for script in execs/run.sh execs/update.sh execs/scpts/import.sh execs/scpts/lint.sh execs/scpts/fmt.sh .github/scripts/port.sh .github/hooks/pre-push; do
    [[ -x "${script}" ]] || { fail "non-executable entrypoint: ${script}"; script_errors=1; }
done
(( script_errors == 0 )) && ok 'shell scripts parse and managed entrypoints are executable'

if ! bash .github/scripts/test_degree_levels.sh; then
    fail 'degree-level lint cases failed'
fi

grep -q 'Systematic Toolchain for Organizing Research over Years' README.md || fail 'README.md lacks the official expansion'
grep -q 'A STAR takes the STAGE to tell a STORY' README.md || fail 'README.md lacks the official tagline'
for path in degree/profile.tex degree/requirements.md notes/.gitkeep notes/refs/.gitkeep mates/MANIFEST.md manus/main.tex manus/stys/story.cls manus/stys/story.sty milestones/.gitkeep tasks/.gitkeep .story/memory/.gitkeep; do
    [[ -f "${path}" ]] || fail "missing core path: ${path}"
done
for path in notes notes/refs; do
    [[ -d "${path}" ]] || fail "missing core directory: ${path}"
done
[[ "$(readlink CLAUDE.md 2>/dev/null)" == AGENTS.md ]] || fail 'CLAUDE.md must link to AGENTS.md'
[[ "$(readlink docs/index.html 2>/dev/null)" == htmls/story.html ]] || fail 'docs/index.html link is wrong'
[[ "$(readlink docs/index_zh.html 2>/dev/null)" == htmls/story_zh.html ]] || fail 'docs/index_zh.html link is wrong'

# Both walks below skip wkdrs/, as the Chinese-edition walk does: builds and
# scratch copies there are regenerable, and an old copy is not what ships. They
# skip the memory store too, whose files are the thesis's (or, upstream, a
# maintainer's git-ignored local/), not STORY's.
stale_paths="$(find . \( -path './.git' -o -path './wkdrs' -o -path './.story/memory' \) -prune -o \( -iname 'stage-*' -o -iname 'stage_*' -o -iname '.stage' \) -print)"
[[ -z "${stale_paths}" ]] || fail "stale STAGE-owned paths remain: ${stale_paths}"
# A blanket star->story or stage->story rename corrupts the words that contain
# it (started, restart, startswith, before_agent_start, staged), in any case.
bad_words="$(grep -RIniE --exclude-dir=.git --exclude-dir=wkdrs --exclude='*.bst' --exclude='check_consistency.sh' '\bstoryd\b|\bstorys\b|\bstoryt(ed|s|up|swith)?\b|[a-z_]storyt' . 2>/dev/null | grep -v '^\./\.story/memory/' || true)"
[[ -z "${bad_words}" ]] || { fail 'mechanical rename artifacts remain:'; printf '%s\n' "${bad_words}" | sed 's/^/      /'; }

if (( FAILURES > 0 )); then
    printf '\n%d consistency failure(s).\n' "${FAILURES}"
    exit 1
fi
printf '\nAll STORY consistency checks passed.\n'
