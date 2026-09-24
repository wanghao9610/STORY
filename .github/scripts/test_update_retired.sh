#!/usr/bin/env bash
# execs/update.sh deletes what upstream retired: each RETIRED_FILES entry, a
# SKILL_zh.md beside a SKILL.md upstream ships, and a .zh-CN.md Pi prompt beside
# a prompt upstream ships. A grep cannot tell whether that still happens, so
# this runs the updater: the working tree, as it stands, becomes a scratch
# upstream, and a fixture thesis holding one file of each kind, plus files of
# its own, is previewed, updated, and previewed again. The same update has to
# install what upstream ships: the /story and /story-auto entry points of every
# harness arrive byte for byte, and a changed Codex or Kimi Code plugin is
# reported with its reinstall, while an unchanged one is not.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT
UP="${WORK_DIR}/upstream"
DOWN="${WORK_DIR}/thesis"
mkdir -p "${UP}" "${DOWN}"

fail() {
    printf 'FAIL  update retirement: %s\n' "$*" >&2
    exit 1
}

git_quiet() {
    git -c user.name=STORY -c user.email=story@example.invalid \
        -c init.defaultBranch=main -c core.hooksPath=/dev/null "$@" >/dev/null
}

# The upstream is the working tree as it stands: every tracked or new file git
# would commit, less what is deleted but not yet staged. It is copied, links
# kept as links, so nothing is written to this repository's index, objects, or
# refs.
(cd "${ROOT_DIR}" && git ls-files -z --cached --others --exclude-standard) |
    while IFS= read -r -d '' rel; do
        if [[ -e "${ROOT_DIR}/${rel}" || -L "${ROOT_DIR}/${rel}" ]]; then
            printf '%s\0' "${rel}"
        fi
    done |
    (cd "${ROOT_DIR}" && tar -cf - --null -T -) | tar -C "${UP}" -xf -
git_quiet -C "${UP}" init
git_quiet -C "${UP}" symbolic-ref HEAD refs/heads/main
git_quiet -C "${UP}" add -A
git_quiet -C "${UP}" commit -m upstream

RETIRED_EXPECTED=()
while IFS= read -r rel; do
    [[ -n "${rel}" ]] && RETIRED_EXPECTED+=("${rel}")
done < <(sed -n '/^RETIRED_FILES=(/,/^)/p' "${UP}/execs/update.sh" | sed -nE 's/^[[:space:]]*"([^"]+)".*/\1/p')
(( ${#RETIRED_EXPECTED[@]} > 0 )) || fail 'execs/update.sh has no readable RETIRED_FILES list'
SKILL="$(cd "${UP}/.agents/skills" && find . -mindepth 2 -maxdepth 2 -name SKILL.md | sed -n 's|^\./\([^/]*\)/SKILL\.md$|\1|p' | sort | head -n 1)"
[[ -n "${SKILL}" ]] || fail 'upstream ships no skill under .agents/skills'
PROMPT="$(cd "${UP}/.pi/prompts" && find . -maxdepth 1 -name '*.md' ! -name '*.zh-CN.md' | sed 's|^\./||' | sort | head -n 1)"
[[ -n "${PROMPT}" ]] || fail 'upstream ships no Pi prompt'

# Every RETIRED_FILES entry, and one of each kind retired by rule.
RETIRED_EXPECTED+=(
    ".agents/skills/${SKILL}/SKILL_zh.md"
    ".pi/prompts/${PROMPT%.md}.zh-CN.md"
)
# The thesis's own files, which an update keeps: one it wrote under a synced
# path, a Chinese note, and, in the memory store the update never touches, what
# an earlier release left there: the hand-written indexes, versioned and under
# local/, and a memory with the Chinese twin the old pairing rule required.
KEPT_EXPECTED=(
    "docs/mds/story-workflow/thesis-local.md"
    "notes/story.zh-CN.md"
    ".story/memory/MEMORY.md"
    ".story/memory/MEMORY.zh-CN.md"
    ".story/memory/local/MEMORY.md"
    ".story/memory/local/MEMORY.zh-CN.md"
    ".story/memory/biber.md"
    ".story/memory/biber.zh-CN.md"
)

# A thesis on an older release: the two entrypoints the updater looks for, and
# no other STORY file, so every upstream file arrives as new.
mkdir -p "${DOWN}/execs"
cp "${UP}/execs/run.sh" "${UP}/execs/update.sh" "${DOWN}/execs/"
for rel in "${RETIRED_EXPECTED[@]}" "${KEPT_EXPECTED[@]}"; do
    [[ ! -e "${UP}/${rel}" ]] || fail "fixture path ${rel} is shipped upstream"
    mkdir -p "$(dirname -- "${DOWN}/${rel}")"
    printf 'fixture: %s\n' "${rel}" > "${DOWN}/${rel}"
done
git_quiet -C "${DOWN}" init
git_quiet -C "${DOWN}" add -A
git_quiet -C "${DOWN}" commit -m thesis

run_update() {
    local log="$1"
    shift
    (cd "${DOWN}" && env -u STORY_HARNESSES STORY_REPOSITORY="file://${UP}" \
        bash execs/update.sh "$@") > "${log}" 2>&1
}

status=0
run_update "${WORK_DIR}/preview.log" --diff || status=$?
[[ "${status}" -eq 2 ]] || { sed 's/^/      /' "${WORK_DIR}/preview.log" >&2; fail "--diff exited ${status}, expected 2"; }
for rel in "${RETIRED_EXPECTED[@]}"; do
    grep -qxF "  removes  ${rel} (no longer shipped upstream)" "${WORK_DIR}/preview.log" || \
        fail "--diff does not list ${rel} as removes"
done
for rel in "${KEPT_EXPECTED[@]}"; do
    ! grep -qF "removes  ${rel}" "${WORK_DIR}/preview.log" || fail "--diff would remove the thesis's ${rel}"
done

run_update "${WORK_DIR}/update.log" || { sed 's/^/      /' "${WORK_DIR}/update.log" >&2; fail 'the update failed'; }
for rel in "${RETIRED_EXPECTED[@]}"; do
    [[ ! -e "${DOWN}/${rel}" && ! -L "${DOWN}/${rel}" ]] || fail "the update left the retired ${rel} in place"
    grep -qxF "[STORY update] Removed ${rel}: upstream no longer ships it." "${WORK_DIR}/update.log" || \
        fail "the update did not report removing ${rel}"
done
for rel in "${KEPT_EXPECTED[@]}"; do
    [[ -f "${DOWN}/${rel}" ]] || fail "the update deleted the thesis's ${rel}"
done
# The command trees and router packages sync whole, so a command added upstream
# reaches a thesis with no list change in the updater; these prove it for the
# shared procedures and each harness's /story-auto entry point.
ARRIVED_EXPECTED=(
    ".agents/commands/story.md"
    ".agents/commands/story-auto.md"
    ".claude/commands/story-auto.md"
    ".cursor/commands/story-auto.md"
    ".qwen/commands/story-auto.md"
    ".pi/prompts/story-auto.md"
    ".codex/plugins/story/skills/story-auto/SKILL.md"
    ".codex/plugins/story/skills/story-auto/agents/openai.yaml"
    ".kimi-code/plugins/story/skills/story-auto/SKILL.md"
    ".dsh/commands/story/lib/index.js"
)
for rel in "${ARRIVED_EXPECTED[@]}"; do
    [[ -f "${UP}/${rel}" ]] || fail "upstream does not ship ${rel}"
    cmp -s "${UP}/${rel}" "${DOWN}/${rel}" || fail "the update did not install ${rel} as upstream ships it"
done
# The hooks no longer read the kept indexes, and list the kept twin as a second
# memory; the update says both.
grep -qF '[STORY update] NOTE: the session hooks no longer read .story/memory/MEMORY.md, .story/memory/MEMORY.zh-CN.md, .story/memory/local/MEMORY.md, .story/memory/local/MEMORY.zh-CN.md;' "${WORK_DIR}/update.log" || \
    fail 'the update does not report the memory indexes the hooks no longer read'
grep -qF "[STORY update] NOTE: the session hooks list a memory's Chinese twin as a second memory beside its English file: .story/memory/biber.zh-CN.md." "${WORK_DIR}/update.log" || \
    fail "the update does not report the memory's leftover Chinese twin"

# Codex and Kimi Code run the plugin copy made at install, so an update that
# brings a plugin tree names the install, one that changes it names the
# reinstall, and one that leaves it alone names neither. This thesis had no
# plugin tree, so both arrive; a second pass over one of them, edited, differs.
for tree in .codex/plugins/story .kimi-code/plugins/story; do
    grep -qF "[STORY update] NOTE: ${tree} arrived." "${WORK_DIR}/update.log" || \
        fail "the update installed ${tree} without saying the harness must install it"
done

status=0
run_update "${WORK_DIR}/after.log" --diff || status=$?
[[ "${status}" -eq 0 ]] || { sed 's/^/      /' "${WORK_DIR}/after.log" >&2; fail "--diff after the update exited ${status}, expected 0"; }

printf 'thesis edit\n' >> "${DOWN}/.codex/plugins/story/skills/story-auto/SKILL.md"
git_quiet -C "${DOWN}" add -A
git_quiet -C "${DOWN}" commit -m 'story update'
run_update "${WORK_DIR}/again.log" || { sed 's/^/      /' "${WORK_DIR}/again.log" >&2; fail 'the second update failed'; }
grep -qF '[STORY update] NOTE: .codex/plugins/story changed.' "${WORK_DIR}/again.log" || \
    fail 'an update that changed the installed Codex plugin does not ask for its reinstall'
! grep -qF '.kimi-code/plugins/story changed.' "${WORK_DIR}/again.log" && \
    ! grep -qF 'plugins/story arrived.' "${WORK_DIR}/again.log" || \
    fail 'an update that left a plugin tree alone still asks for its install'

printf 'ok    execs/update.sh previews, deletes, and reports %s retired files, keeps the thesis'"'"'s own, installs %s /story and /story-auto entry points, and asks for a Codex or Kimi Code plugin install only when a plugin tree arrived or changed\n' "${#RETIRED_EXPECTED[@]}" "${#ARRIVED_EXPECTED[@]}"
