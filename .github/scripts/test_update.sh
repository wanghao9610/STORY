#!/usr/bin/env bash
# execs/update.sh installs what upstream ships and keeps what the thesis owns.
# A grep cannot tell whether that still happens, so this runs the updater: the
# working tree, as it stands, becomes a scratch upstream, and a fixture thesis
# holding files of its own is previewed, updated, and previewed again. The
# update has to keep the thesis's own files and report what an earlier release
# left in the memory store; the /story and /story-auto entry points of every
# harness arrive byte for byte, and a changed Codex or Kimi Code plugin is
# reported with its reinstall, while an unchanged one is not, even when it
# holds a file only the thesis has.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT
UP="${WORK_DIR}/upstream"
DOWN="${WORK_DIR}/thesis"
mkdir -p "${UP}" "${DOWN}"

fail() {
    printf 'FAIL  update: %s\n' "$*" >&2
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
for rel in "${KEPT_EXPECTED[@]}"; do
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

run_update "${WORK_DIR}/update.log" || { sed 's/^/      /' "${WORK_DIR}/update.log" >&2; fail 'the update failed'; }
for rel in "${KEPT_EXPECTED[@]}"; do
    [[ -f "${DOWN}/${rel}" ]] || fail "the update deleted the thesis's ${rel}"
done
# The command trees and router packages sync whole, so a command added upstream
# reaches a thesis with no list change in the updater; these prove it for the
# shared procedures and each harness's /story and /story-auto entry points.
ARRIVED_EXPECTED=(
    ".agents/commands/story.md"
    ".agents/commands/story-auto.md"
    ".claude/commands/story.md"
    ".claude/commands/story-auto.md"
    ".cursor/commands/story.md"
    ".cursor/commands/story-auto.md"
    ".qwen/commands/story.md"
    ".qwen/commands/story-auto.md"
    ".pi/prompts/story.md"
    ".pi/prompts/story-auto.md"
    ".codex/plugins/story/skills/story/SKILL.md"
    ".codex/plugins/story/skills/story-auto/SKILL.md"
    ".codex/plugins/story/skills/story-auto/agents/openai.yaml"
    ".kimi-code/plugins/story/skills/story/SKILL.md"
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

# An update deletes nothing, so a thesis updated from an earlier release keeps
# the Chinese twin that release shipped beside each plugin's story skill. The
# extract never touches a file only the thesis has, so such a file is no change
# to the plugin: counting it would ask for a reinstall on every update, and no
# reinstall could clear it.
LEFTOVER_EXPECTED=(
    ".codex/plugins/story/skills/story/SKILL_zh.md"
    ".kimi-code/plugins/story/skills/story/SKILL_zh.md"
)
for rel in "${LEFTOVER_EXPECTED[@]}"; do
    [[ ! -e "${UP}/${rel}" ]] || fail "fixture path ${rel} is shipped upstream"
    printf 'fixture: %s\n' "${rel}" > "${DOWN}/${rel}"
done
printf 'thesis edit\n' >> "${DOWN}/.codex/plugins/story/skills/story-auto/SKILL.md"
git_quiet -C "${DOWN}" add -A
git_quiet -C "${DOWN}" commit -m 'story update'
run_update "${WORK_DIR}/again.log" || { sed 's/^/      /' "${WORK_DIR}/again.log" >&2; fail 'the second update failed'; }
grep -qF '[STORY update] NOTE: .codex/plugins/story changed.' "${WORK_DIR}/again.log" || \
    fail 'an update that changed the installed Codex plugin does not ask for its reinstall'
! grep -qF '.kimi-code/plugins/story changed.' "${WORK_DIR}/again.log" && \
    ! grep -qF 'plugins/story arrived.' "${WORK_DIR}/again.log" || \
    fail 'an update that left a plugin tree alone still asks for its install'

git_quiet -C "${DOWN}" add -A
git_quiet -C "${DOWN}" commit --allow-empty -m 'story update again'
run_update "${WORK_DIR}/third.log" || { sed 's/^/      /' "${WORK_DIR}/third.log" >&2; fail 'the third update failed'; }
! grep -qF 'plugins/story changed.' "${WORK_DIR}/third.log" && \
    ! grep -qF 'plugins/story arrived.' "${WORK_DIR}/third.log" || \
    fail 'an update asks for a plugin reinstall over a file only the thesis has'
for rel in "${LEFTOVER_EXPECTED[@]}"; do
    [[ -f "${DOWN}/${rel}" ]] || fail "the update deleted the thesis's ${rel}"
done
status=0
run_update "${WORK_DIR}/final.log" --diff || status=$?
[[ "${status}" -eq 0 ]] || { sed 's/^/      /' "${WORK_DIR}/final.log" >&2; fail "--diff over the thesis's own plugin files exited ${status}, expected 0"; }

printf 'ok    execs/update.sh keeps the thesis'"'"'s own files, installs %s /story and /story-auto entry points, and asks for a Codex or Kimi Code plugin install only when a plugin tree arrived or a file it ships changed\n' "${#ARRIVED_EXPECTED[@]}"
