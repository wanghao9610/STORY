#!/usr/bin/env bash
set -euo pipefail

# execs/update.sh — sync STORY-managed content from the upstream template (the
# shared skill source, the shared /story router and /story-auto procedure with
# their harness commands and prompts, six harness entry trees, the Codex $story
# and $story-auto plugin, the Kimi and DSH /story and /story-auto entries, all
# hook trees, docs/mds/story-workflow/, the shared agent instructions, and
# every script under execs/ — both entrypoints, this one included, and the three
# utilities in execs/scpts/), or install the STORY skeleton into an existing
# thesis repo with --adopt.

STORY_REF="main"
SKILL_NAME=""
REF_SET=false
ADOPT=false
DIFF=false
FORCE=false
HARNESSES_ARG=""

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

# The STORY-managed trees: overwritten on update, copy-if-absent on adopt.
# One neutral root plus six harness-owned entry trees. Upstream stores identical
# files once under .agents and links the entry trees to them; updates materialize
# those links so a downstream project remains self-contained.
SKILL_ROOTS=(
    ".agents/skills"
    ".claude/skills"
    ".cursor/skills"
    ".dsh/skills"
    ".kimi-code/skills"
    ".pi/skills"
    ".qwen/skills"
)
CODEX_MANIFEST_ROOT=".codex/skills"
# The shared command files and the harness wrappers that read them: the /story
# router and the /story-auto goal-run procedure under .agents/commands, the
# Claude, Cursor and Qwen commands wrapping both, and Pi's prompt templates (one
# per skill, plus /story and /story-auto). Each tree syncs whole, so a command
# added upstream ships without a change to this list.
HARNESS_ASSET_TREES=(
    ".agents/commands"
    ".claude/commands"
    ".cursor/commands"
    ".pi/prompts"
    ".qwen/commands"
)
DOCS_TREE="docs/mds/story-workflow"

# STORY-owned hook assets. Two inject at the start of a session: the script that
# puts the project-memory index (.story/memory/) in front of the agent, and the
# one that states the runtime's model id so an artifact records who wrote it
# (conventions §7). The rest decide instead: the commit guard that declines the
# git commands the STORY git safety policy forbids (its own header states the
# policy), in every tree; the involve gate that answers a file-edit permission
# prompt at INVOLVE=low (§7), in the three trees whose harness lets a hook decide
# one (Claude, Codex, Qwen Code); and, in Claude's tree alone, the bash gate that
# answers its shell prompt at low, with the level resolver both Claude gates
# source. One copy of each per harness, because every runtime spells the event
# and the output field differently. Overwritten on update like the skills — the
# memory store itself is the thesis's and is never synced.
HOOK_TREES=(
    ".claude/hooks"
    ".codex/hooks"
    ".cursor/hooks"
    ".dsh/hooks"
    ".kimi-code/hooks"
    ".pi/extensions/story-hooks"
    ".qwen/hooks"
)

# Single STORY-managed files an update overwrites alongside the trees above.
# Each is called by name and by flag from something the update also syncs:
# story-clms-auditor runs `import.sh --diff`, story-copy-editor and
# story-flow-status's scan.sh run `lint.sh --no-build` (scan.sh with `--main`),
# and lint.sh runs `run.sh --main` and `fmt.sh --check`. A thesis repo that
# syncs a caller while keeping a script that predates the flag it passes gets a
# run that fails at that step, and a caller reading an exit code means the one
# its own version documents. No script here carries project configuration:
# everything an instance sets lives in .env, which is git-ignored and never
# synced (AGENTS.md §6) — so all five are safe to replace wholesale.
#
# execs/update.sh syncs itself, so a repo never strands on an update mechanism
# too old to fetch its successor. A running shell script must not be rewritten
# in place — bash reads it incrementally by offset, so a truncating extract can
# resume parsing into different bytes — so this one file is kept out of the tar
# below and installed by rename instead (SELF_PATH, further down): the running
# process keeps the old inode to the end, the next invocation gets the new file.
SELF_PATH="execs/update.sh"
SYNC_FILES=(
    "execs/run.sh"
    "execs/scpts/import.sh"
    "execs/scpts/lint.sh"
    "execs/scpts/fmt.sh"
    # Kimi has no project-level hook config, so its registration snippet ships
    # as documentation beside the hook rather than as a config an update keeps.
    ".kimi-code/hooks.example.toml"
    ".dsh/cordis.patch.yml"
    ".pi/APPEND_SYSTEM.md"
    "${SELF_PATH}"
)

# Synced paths a ref is allowed not to have. Each arrived later than the tree it
# sits in, so pinning an older ref is a legitimate reason for it to be missing,
# and that is a skipped line rather than a stopped update: the session hooks,
# which arrived after the skills; fmt.sh, which arrived after the other two
# utilities; and the Kimi and DSH /story and /story-auto entries, which arrived
# after their harness entry trees. Anything else missing is a broken ref and still
# fatal.
is_optional_path() {
    case "$1" in
        .*/hooks*)            return 0 ;;
        "execs/scpts/fmt.sh") return 0 ;;
        ".dsh/commands")      return 0 ;;
        ".kimi-code/plugins") return 0 ;;
    esac
    return 1
}

# The shared agent instructions and the Cursor rule that copies their body:
# upstream-managed like the skills and overwritten by an update. A project's own
# conventions belong in a section the update does not own or in .env, not in an
# edited copy of these.
AGENT_DOCS=("AGENTS.md")
AGENT_RULES_TREE=".cursor/rules"

# Harness configuration a project may have edited: installed when it is missing
# — by --adopt and by an update alike — and never overwritten unless --force
# says so. A flat file list on purpose: an empty array expands to an unbound
# variable under `set -u` on bash 3.2, so a tree joins this only with the
# guarded expansion that needs.
#
# The last three register the hooks. They are kept rather than overwritten
# because a thesis repo may have added its own settings to them — so a repo
# adopted before a hook existed keeps a config that does not register it, which
# HOOK_CONFIGS below turns into a printed line instead of a hook that silently
# never fires.
HARNESS_FILES=(
    ".cursorignore"
    ".claude/settings.json"
    ".codex/hooks.json"
    ".cursor/hooks.json"
    ".dsh/hooks.json"
    ".pi/settings.json"
    ".qwen/settings.json"
)
HOOK_CONFIGS=(
    ".claude/settings.json"
    ".codex/hooks.json"
    ".cursor/hooks.json"
    ".dsh/hooks.json"
    ".qwen/settings.json"
)

# Harness trees named by --harnesses and STORY_HARNESSES. The neutral .agents
# root belongs to the shared skeleton, except for the one Codex marketplace
# discovery file, and is updated on every run.
ALL_HARNESSES=(claude codex cursor dsh kimi pi qwen)

log() {
    printf '[STORY update] %s\n' "$*"
}

fail() {
    printf '[STORY update] ERROR: %s\n' "$*" >&2
    exit 1
}

# Keep Codex's repo marketplace at the path its host discovers while leaving
# the canonical file and the plugin itself under .codex. Filesystems that
# cannot create symlinks get a real copy so the plugin remains usable.
link_codex_marketplace() {
    local dst="${ROOT_DIR}/.agents/plugins/marketplace.json"
    local src="${ROOT_DIR}/.codex/plugins/marketplace.json"

    [[ -f "${src}" ]] || fail "Missing Codex marketplace: .codex/plugins/marketplace.json."
    mkdir -p "$(dirname -- "${dst}")"
    if [[ -L "${dst}" ]] && [[ "$(readlink "${dst}")" == "../../.codex/plugins/marketplace.json" ]]; then
        return 0
    fi
    if [[ -e "${dst}" || -L "${dst}" ]]; then
        rm -f -- "${dst}"
    fi
    if ! ln -s "../../.codex/plugins/marketplace.json" "${dst}" 2>/dev/null; then
        cp -p "${src}" "${dst}"
        log "NOTE: symlinks are unavailable; installed .agents/plugins/marketplace.json as a real file."
    fi
}

# Which harness owns a path. Empty means shared and therefore always selected.
# Only the marketplace discovery file under .agents is Codex-owned; keeping
# that exception narrow avoids exposing future Codex-private plugins through a
# shared directory link.
path_harness() { # $1 = path relative to the project root
    case "$1" in
        .agents/plugins/marketplace.json|.codex/*) printf 'codex' ;;
        .agents/*)               printf '' ;;
        .claude/*)               printf 'claude' ;;
        .cursor/*|.cursorignore) printf 'cursor' ;;
        .dsh/*)                  printf 'dsh' ;;
        .kimi-code/*)            printf 'kimi' ;;
        .pi/*)                   printf 'pi' ;;
        .qwen/*)                 printf 'qwen' ;;
    esac
}

# Directories a selected harness needs in the sparse checkout. The shared
# .agents root is fetched separately because every run updates it.
harness_dirs() { # $1 = harness name
    case "$1" in
        claude) printf '.claude' ;;
        codex)  printf '.codex' ;;
        cursor) printf '.cursor' ;;
        dsh)    printf '.dsh' ;;
        kimi)   printf '.kimi-code' ;;
        pi)     printf '.pi' ;;
        qwen)   printf '.qwen' ;;
    esac
}

is_selected() { # $1 = harness name
    local name
    for name in ${SELECTED_HARNESSES[@]+"${SELECTED_HARNESSES[@]}"}; do
        [[ "${name}" == "$1" ]] && return 0
    done
    return 1
}

# True for a shared path or a path owned by a selected harness.
path_selected() { # $1 = path relative to the project root
    local harness
    harness="$(path_harness "$1")"
    [[ -n "${harness}" ]] || return 0
    is_selected "${harness}"
}

FILTERED=()
filter_paths() { # $@ = paths relative to the project root
    local path
    FILTERED=()
    for path in "$@"; do
        if path_selected "${path}"; then
            FILTERED+=("${path}")
        fi
    done
}

# Every harness-configuration file the fetched ref actually carries, one path
# per line. A path the ref does not have is skipped rather than fatal — harness
# configuration is optional to the update, unlike SYNC_PATHS.
harness_rels() {
    local rel
    for rel in "${HARNESS_FILES[@]}"; do
        if path_selected "${rel}" && [[ -f "${SOURCE_DIR}/${rel}" ]]; then
            printf '%s\n' "${rel}"
        fi
    done
}

# A kept registration config that does not name one of the hooks: the script is
# installed, nothing errors, and either no memory reaches a session, or every
# artifact it writes records "unrecorded", or a git command the STORY git safety
# policy forbids (see story_commit_guard.sh's header) meets no floor. Reported, not repaired — merging into a file the project may have
# extended is the user's.
report_unregistered_hooks() {
    local cfg missing hook label hooks
    for cfg in "${HOOK_CONFIGS[@]}"; do
        path_selected "${cfg}" || continue
        [[ -e "${ROOT_DIR}/${cfg}" ]] || continue
        missing=""
        # The commit guard declines a shell command before it runs, which every
        # harness can express — Claude and Codex on PreToolUse, Cursor on
        # beforeShellExecution — so every config carries it. The involve gate
        # answers a permission prompt, so it applies only where a hook can
        # decide one: Cursor has no event that gates a file edit. The bash gate
        # answers Claude's shell prompt at low, and only Claude's PreToolUse
        # allow is honored for it, so only Claude's config carries it.
        hooks=("story_memory.sh|project-memory" "story_model_id.sh|model-id provenance"
               "story_commit_guard.sh|commit guard")
        case "${cfg}" in
            .claude/settings.json|.codex/hooks.json|.qwen/settings.json)
                hooks+=("story_involve_gate.sh|involve gate") ;;
        esac
        if [[ "${cfg}" == ".claude/settings.json" ]]; then
            hooks+=("story_bash_gate.sh|bash gate")
        fi
        for hook in "${hooks[@]}"; do
            label="${hook#*|}"
            grep -q "${hook%%|*}" "${ROOT_DIR}/${cfg}" 2>/dev/null || missing+="${missing:+, }${label}"
        done
        if [[ -n "${missing}" ]]; then
            log "NOTE: ${cfg} was kept and registers no STORY hook for: ${missing}."
            log "      Merge the hook entries from upstream ${cfg} to enable them."
        fi
        # A kept Claude config can register every hook and still lack the allow
        # rule for the read-only command the provenance line hands a skill. The
        # main session then asks before each provenance read, and a delegate,
        # which cannot answer a prompt, is denied it and records "unrecorded". A
        # missing permission is not a missing hook, so it gets a note of its own.
        if [[ "${cfg}" == ".claude/settings.json" ]] && \
           ! grep -q 'story_model_id\.sh --resolve' "${ROOT_DIR}/${cfg}" 2>/dev/null; then
            log "NOTE: ${cfg} was kept and does not allow the read-only model-id resolver, so each provenance read asks first and a delegate's model_id reads unrecorded."
            log "      Copy \"Bash(bash .claude/hooks/story_model_id.sh --resolve:*)\" from upstream ${cfg} into its permissions.allow."
        fi
        if [[ -z "${missing}" && "${cfg}" == ".codex/hooks.json" ]]; then
            # Registering them is not enough on Codex: a project hook runs only
            # once the project is trusted and the hook itself approved, and a
            # changed hook needs approving again. Nothing reports the gap — the
            # hooks simply do not fire, no memory reaches the session, and every
            # artifact the session writes records "unrecorded".
            log "NOTE: ${cfg} is registered, but Codex runs a project hook only after you approve it."
            log "      Run /hooks in the Codex CLI and approve it — re-approve whenever it changes."
        fi
        # A grep cannot see which SessionStart group names the memory hook. A
        # kept config from before upstream gave it a group of its own still
        # loads memory only where that group's matcher fires (startup|resume),
        # so not after /clear. Read as JSON where python3 is at hand.
        if [[ "${cfg}" == ".codex/hooks.json" ]] && command -v python3 >/dev/null 2>&1 && \
           python3 -c 'import json, sys
groups = json.load(open(sys.argv[1])).get("hooks", {}).get("SessionStart", [])
sys.exit(0 if any(g.get("matcher") and any("story_memory.sh" in h.get("command", "") for h in g.get("hooks", [])) for g in groups) else 1)' \
               "${ROOT_DIR}/${cfg}" 2>/dev/null; then
            log "NOTE: ${cfg} was kept and loads project memory only on the SessionStart sources its matcher names."
            log "      Move the story_memory.sh entry into a SessionStart group of its own with no matcher, as upstream ${cfg} does."
        fi
    done
}

# What an earlier release left in the memory store that the hooks now read
# differently. The hand-written index files, one in the versioned store and one
# under local/, each with the Chinese twin the old pairing rule required: the
# hooks now build the index from each memory file's frontmatter and read none
# of them, so a line kept only there no longer reaches a session. And the
# <slug>.zh-CN.md twin that rule put beside every memory file: the hooks read it
# as a memory of its own, listed a second time beside its English file, and it
# keeps its own `verified` date when the English one is re-verified. Reported,
# not removed — the store is the thesis's.
report_legacy_memory_index() {
    local rel path found="" twins=""
    for rel in .story/memory/MEMORY.md .story/memory/MEMORY.zh-CN.md \
               .story/memory/local/MEMORY.md .story/memory/local/MEMORY.zh-CN.md; do
        [[ -f "${ROOT_DIR}/${rel}" ]] && found+="${found:+, }${rel}"
    done
    for path in "${ROOT_DIR}"/.story/memory/*.zh-CN.md "${ROOT_DIR}"/.story/memory/local/*.zh-CN.md; do
        [[ "${path##*/}" != MEMORY.zh-CN.md && -f "${path}" && -f "${path%.zh-CN.md}.md" ]] || continue
        twins+="${twins:+, }${path#"${ROOT_DIR}/"}"
    done
    if [[ -n "${found}" ]]; then
        log "NOTE: the session hooks no longer read ${found}; they build the memory index from each memory file's frontmatter."
        log "      Give every memory file a one-line \`summary:\` in its frontmatter (docs/mds/story-workflow/writing-workflow-conventions.md §10); a file without one is listed by its first body line, and one without frontmatter is not listed. Then delete the old index."
    fi
    if [[ -n "${twins}" ]]; then
        log "NOTE: the session hooks list a memory's Chinese twin as a second memory beside its English file: ${twins}."
        log "      Memory files take no Chinese twin any more: fold what a twin adds into its English file, then delete the twin."
    fi
}

# fmt.sh is synced but .latexindent.yaml is the thesis's: a kept config without
# the rules that hold a closing brace or bracket on its sentence's line makes
# fmt.sh refuse every file in which a sentence ends a group. Reported, not
# merged — the config may carry the author's own rules.
report_latexindent_closers() {
    local cfg="${ROOT_DIR}/.latexindent.yaml"
    [[ -f "${cfg}" ]] || return 0
    grep -q 'RCuBStartsOnOwnLine:[[:space:]]*-1' "${SOURCE_DIR}/.latexindent.yaml" 2>/dev/null || return 0
    if grep -q 'RCuBStartsOnOwnLine:[[:space:]]*-1' "${cfg}" && \
       grep -q 'RSqBStartsOnOwnLine:[[:space:]]*-1' "${cfg}"; then
        return 0
    fi
    log "NOTE: your .latexindent.yaml was kept and does not keep a closing } or ] on its sentence's line, so fmt.sh refuses every file in which a sentence ends a group."
    log "      Copy the mandatoryArguments and optionalArguments rules under modifyLineBreaks from ${STORY_REPOSITORY} .latexindent.yaml."
}

usage() {
    cat <<'EOF'
Usage: bash execs/update.sh [ref] [--harnesses LIST] [--skill NAME] [--force]
       bash execs/update.sh --diff [ref] [--harnesses LIST] [--skill NAME] [--force]
       bash execs/update.sh [ref] [--harnesses LIST] --adopt

Overwrite the STORY-managed content — the shared agent instructions (AGENTS.md
and the Cursor rule that copies its body), the neutral skill source plus six
harness entry trees (.agents, .claude, .cursor, .dsh, .kimi-code, .pi, .qwen),
Codex's per-skill manifests and $story / $story-auto plugin, Kimi Code's /story
and /story-auto plugin, DSH's /story and /story-auto command bundle, the shared
/story router and /story-auto procedure (.agents/commands) with the harness
commands and prompts that read them,
the hooks (the session hooks that inject project memory and model provenance,
the commit guard, and the gates that answer permission prompts at INVOLVE=low),
docs/mds/story-workflow/, and every script under execs/ — the two entrypoints,
run.sh and this one, and the three utilities in execs/scpts/: import.sh,
lint.sh, fmt.sh — with files from upstream. An update deletes nothing: every
local-only file, the project's own included, is kept.
The default ref is main; a branch or tag may be supplied instead. Local edits to
those paths are replaced, AGENTS.md included; the manuscript, evidence, notes,
and the memory store under .story/memory/ are never touched. Use --skill to
update only the named skill across the neutral source, six entry trees, Codex
manifest, and Pi prompt (it leaves everything else, entrypoints and docs
included, alone).

--harnesses limits the run to comma-separated harness trees: claude, codex,
cursor, dsh, kimi, pi, or qwen — or all, the default, or none for shared paths
only. Without the flag, STORY_HARNESSES is resolved from the environment, then
.env, then defaults to all. A tree left out is neither installed nor updated.
Shared paths such as .agents/skills, docs/mds/story-workflow, execs/, and
AGENTS.md remain in scope for every selection.
The generic router packages live under .codex/plugins, .dsh/commands and
.kimi-code/plugins; each is updated only when its harness is selected. Codex's
one discovery link under .agents/plugins follows the same selection.

No script under execs/ holds project configuration — everything an instance sets
lives in .env, which is git-ignored and never synced — so all five are safe to
replace. They are synced because they are called by name and by flag:
import.sh --diff from story-clms-auditor, lint.sh --no-build from
story-copy-editor and story-flow-status's scan.sh, and run.sh --main and
fmt.sh --check from lint.sh. A repo that syncs a caller while keeping a script
that predates the flag it passes gets a run that fails at that step.
execs/update.sh syncs itself, so no repo strands on an update mechanism too old
to fetch its successor: it is installed by rename, which leaves this running
process on the old file and gives the next invocation the new one.

Harness configuration an instance may have edited — .cursorignore plus hook
registrations and harness settings under .claude, .codex, .cursor, .dsh, .pi,
and .qwen — is installed when it is absent and otherwise kept, however far it has drifted
from upstream; only --force overwrites it. A kept registration that does not name
a hook is reported, since a hook nobody registers never fires, and so are a kept
.claude/settings.json without the model-id resolver's allow rule and a kept
.codex/hooks.json whose memory hook sits behind a SessionStart matcher.
After a full update, leftovers of the old memory index in the thesis's own
.story/memory/ (a MEMORY.md or MEMORY.zh-CN.md index there or under local/,
and a memory's Chinese twin) are reported, never removed.

--diff previews an update without changing anything: it lists upstream files
that are new or differ from the local copies, harness configuration that
differs but would be kept, and project-local files an update would keep. It
exits 0 when everything already matches, 2 when an update would change files,
and 1 on error — so a script can tell "an update is available" from "the check
itself failed".

--force updates the same paths with both refusals lifted: uncommitted changes
under them are overwritten instead of stopping the command, and the harness
configuration above is overwritten instead of kept. It widens nothing — the
path list is unchanged, and a local file upstream does not have is still kept.
Combined with --diff it previews that scope without changing anything.

--adopt installs the STORY skeleton into an already-started thesis repo instead
of updating this one. It runs against the current working directory, which
must be a git repository root, and never overwrites a file that is already
there: every existing path is kept and reported. Run `story-proj-adopt` in
your agent afterwards to wire the thesis up.

The upstream repository is STORY_REPOSITORY (environment first, then .env);
default https://github.com/wanghao9610/STORY.git.

Examples:
  bash execs/update.sh
  bash execs/update.sh TAG_OR_BRANCH
  bash execs/update.sh --diff
  bash execs/update.sh --force
  bash execs/update.sh --skill story-chap-drafter
  bash execs/update.sh TAG_OR_BRANCH --skill story-chap-drafter
  bash execs/update.sh --harnesses claude
  bash execs/update.sh --harnesses claude,pi --diff

  cd /path/to/my-thesis
  curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o /tmp/story-update.sh
  bash /tmp/story-update.sh --adopt
EOF
}

while (( $# > 0 )); do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --skill)
            shift
            (( $# > 0 )) || fail "--skill requires a skill name."
            [[ -z "${SKILL_NAME}" ]] || fail "--skill may only be specified once."
            SKILL_NAME="$1"
            ;;
        --skill=*)
            [[ -z "${SKILL_NAME}" ]] || fail "--skill may only be specified once."
            SKILL_NAME="${1#*=}"
            [[ -n "${SKILL_NAME}" ]] || fail "--skill requires a skill name."
            ;;
        --harnesses)
            shift
            (( $# > 0 )) || fail "--harnesses requires a list of harnesses."
            [[ -z "${HARNESSES_ARG}" ]] || fail "--harnesses may only be specified once."
            HARNESSES_ARG="$1"
            ;;
        --harnesses=*)
            [[ -z "${HARNESSES_ARG}" ]] || fail "--harnesses may only be specified once."
            HARNESSES_ARG="${1#*=}"
            [[ -n "${HARNESSES_ARG}" ]] || fail "--harnesses requires a list of harnesses."
            ;;
        --adopt)
            ADOPT=true
            ;;
        --diff)
            DIFF=true
            ;;
        --force)
            FORCE=true
            ;;
        -*)
            fail "Unknown option: $1"
            ;;
        *)
            [[ "${REF_SET}" == false ]] || fail "Only one ref may be supplied."
            STORY_REF="$1"
            REF_SET=true
            ;;
    esac
    shift
done

# --adopt targets the current repository; every other mode targets the project
# containing this script. Read that project's .env for persistent selection.
ENV_DIR="${ROOT_DIR}"
[[ "${ADOPT}" == false ]] || ENV_DIR="$(pwd -P)"

env_value() { # $1 = key; print its last assignment in the target .env
    # Same tolerance as run.sh, lint.sh, and import.sh: leading whitespace and
    # one layer of quotes come off, so a quoted .env value reads the same here.
    local val
    [[ -f "${ENV_DIR}/.env" ]] || return 0
    val="$(sed -n "s/^[[:space:]]*$1=//p" "${ENV_DIR}/.env" | tail -1)"
    val="${val%$'\r'}"; val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
    printf '%s' "${val}"
}

HARNESSES_SPEC="${HARNESSES_ARG}"
HARNESSES_SOURCE="--harnesses"
if [[ -z "${HARNESSES_SPEC}" ]]; then
    HARNESSES_SPEC="${STORY_HARNESSES:-}"
    HARNESSES_SOURCE="the STORY_HARNESSES environment variable"
fi
if [[ -z "${HARNESSES_SPEC}" ]]; then
    HARNESSES_SPEC="$(env_value STORY_HARNESSES)"
    HARNESSES_SOURCE="STORY_HARNESSES in .env"
fi
if [[ -z "${HARNESSES_SPEC}" ]]; then
    HARNESSES_SPEC="all"
    HARNESSES_SOURCE="the default"
fi

SELECTED_HARNESSES=()
if [[ "${HARNESSES_SPEC}" == all ]]; then
    SELECTED_HARNESSES=("${ALL_HARNESSES[@]}")
elif [[ "${HARNESSES_SPEC}" != none ]]; then
    while IFS= read -r name; do
        name="${name//[[:space:]]/}"
        [[ -n "${name}" ]] || continue
        known=false
        for harness in "${ALL_HARNESSES[@]}"; do
            [[ "${name}" == "${harness}" ]] && known=true
        done
        [[ "${known}" == true ]] || \
            fail "Unknown harness '${name}' in ${HARNESSES_SOURCE}. Valid: ${ALL_HARNESSES[*]}, all, none."
        is_selected "${name}" || SELECTED_HARNESSES+=("${name}")
    done < <(tr ',' '\n' <<<"${HARNESSES_SPEC}")
    (( ${#SELECTED_HARNESSES[@]} > 0 )) || \
        fail "${HARNESSES_SOURCE} names no harness. Use 'none' to update shared paths only."
fi

if (( ${#SELECTED_HARNESSES[@]} < ${#ALL_HARNESSES[@]} )); then
    untouched=()
    for harness in "${ALL_HARNESSES[@]}"; do
        is_selected "${harness}" || untouched+=("${harness}")
    done
    selected_label="none"
    (( ${#SELECTED_HARNESSES[@]} == 0 )) || selected_label="${SELECTED_HARNESSES[*]}"
    log "Harnesses (${HARNESSES_SOURCE}): ${selected_label}."
    log "Left alone, neither written nor deleted: ${untouched[*]}."
fi

if [[ "${ADOPT}" == true ]]; then
    [[ -z "${SKILL_NAME}" ]] || fail "--adopt cannot be combined with --skill."
    [[ "${DIFF}" == false ]] || fail "--adopt cannot be combined with --diff."
    # Adopt's whole contract is that it never touches an existing file, which is
    # the opposite of what --force asks for.
    [[ "${FORCE}" == false ]] || fail "--adopt cannot be combined with --force."

    ROOT_DIR="$(pwd -P)"
    git -C "${ROOT_DIR}" rev-parse --git-dir >/dev/null 2>&1 || \
        fail "--adopt must run inside a git repository. Run 'git init' first."
    [[ -e "${ROOT_DIR}/.git" ]] || \
        fail "--adopt must run at the repository root, not in a subdirectory."

    # Directories merged file by file, and single files, all copy-if-absent.
    ADOPT_TREES=(
        "${SKILL_ROOTS[@]}"
        "${CODEX_MANIFEST_ROOT}"
        # Codex owns the repo-local $story / $story-auto plugin. Its .agents
        # discovery entry is installed separately as one narrow file link.
        ".codex/plugins"
        # Kimi Code owns the repo-local /story and /story-auto plugin.
        ".kimi-code/plugins"
        # DSH owns the profile bundle that registers its /story and /story-auto
        # commands.
        ".dsh/commands"
        "${HARNESS_ASSET_TREES[@]}"
        "${HOOK_TREES[@]}"
        "${AGENT_RULES_TREE}"
        "${DOCS_TREE}"
        "degree"
        "notes"
        "manus/fronts"
        "manus/chaps"
        "manus/backs"
        "milestones"
    )
    ADOPT_FILES=(
        "${AGENT_DOCS[@]}"
        ".agents/plugins/marketplace.json"
        "${HARNESS_FILES[@]}"
        ".kimi-code/hooks.example.toml"
        ".dsh/cordis.patch.yml"
        ".pi/APPEND_SYSTEM.md"
        # The memory store ships empty: .gitkeep is the only file the template
        # tracks there, and the session hooks build the index from each
        # memory's frontmatter. The store is the thesis's own from here on.
        ".story/memory/.gitkeep"
        ".env.example"
        ".gitignore"
        # The line-break rule fmt.sh applies and .vscode/settings.json points
        # at, plus the editor-side half of the same convention; a thesis that
        # already has either keeps its own, like every file here.
        ".latexindent.yaml"
        ".editorconfig"
        "execs/run.sh"
        "execs/update.sh"
        "execs/scpts/import.sh"
        "execs/scpts/lint.sh"
        "execs/scpts/fmt.sh"
        # Both entry points: main-zh.tex is the one .env.example and AGENTS.md
        # name for a Chinese thesis, and the only one that inputs the -zh front
        # and back matter the trees above install.
        "manus/main.tex"
        "manus/main-zh.tex"
        # The three template-layer files both entry points load by path or by
        # name: the generic thesis class, the authoring package, and the
        # bibliography style their \bibliographystyle line names. A thesis that
        # already has any of them keeps its own, like every file here.
        "manus/stys/story.cls"
        "manus/stys/story.sty"
        "manus/stys/story.bst"
        "mates/MANIFEST.md"
    )
    # Layout directories the writing workflow expects to exist.
    ADOPT_DIRS=(
        "manus/fronts"
        "manus/chaps"
        "manus/backs"
        "manus/figs/srcs"
        "manus/tabs"
        "manus/bibs"
        "manus/stys"
        "mates/manual"
        "notes/refs"
        "degree"
        "milestones"
        "tasks"
        "wkdrs"
        "execs/scpts"
    )
    # Layout directories are shared and always created. Harness-owned trees and
    # files are installed only when their harness is selected.
    filter_paths "${ADOPT_TREES[@]}"
    ADOPT_TREES=("${FILTERED[@]}")
    filter_paths "${ADOPT_FILES[@]}"
    ADOPT_FILES=("${FILTERED[@]}")
elif [[ -n "${SKILL_NAME}" ]]; then
    [[ "${SKILL_NAME}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || \
        fail "Invalid skill name '${SKILL_NAME}'."

    SYNC_PATHS=()
    for root in "${SKILL_ROOTS[@]}"; do
        SYNC_PATHS+=("${root}/${SKILL_NAME}")
    done
    SYNC_PATHS+=("${CODEX_MANIFEST_ROOT}/${SKILL_NAME}" ".pi/prompts/${SKILL_NAME}.md")
    filter_paths "${SYNC_PATHS[@]}"
    SYNC_PATHS=("${FILTERED[@]}")

    # The neutral skill and Codex manifest are always fetched because upstream
    # harness trees link into them, even when only another harness is written.
    SPARSE_PATHS=()
    for path in "${SYNC_PATHS[@]}"; do
        case "${path}" in
            .pi/prompts/*.md) SPARSE_PATHS+=("$(dirname -- "${path}")") ;;
            *)                SPARSE_PATHS+=("${path}") ;;
        esac
    done
    SPARSE_PATHS+=(".agents/skills/${SKILL_NAME}" "${CODEX_MANIFEST_ROOT}/${SKILL_NAME}")

    if [[ "${DIFF}" == true ]]; then
        log "Diffing skill: ${SKILL_NAME}"
    else
        log "Updating skill: ${SKILL_NAME}"
    fi
else
    # SYNC_PATHS is what gets diffed, dirty-checked, archived, and extracted —
    # directories and single files alike. SPARSE_PATHS is what the sparse
    # checkout creates files, and it holds directories only: the checkout runs
    # in cone mode (forced below), where every argument is read as a directory,
    # so naming a file there would match nothing. A file's parent directory goes
    # in instead; fetching a few siblings we do not copy is cheaper than getting
    # this subtly wrong.
    SYNC_PATHS=(
        "${AGENT_DOCS[@]}"
        "${AGENT_RULES_TREE}"
        "${SKILL_ROOTS[@]}"
        "${CODEX_MANIFEST_ROOT}"
        ".codex/plugins"
        ".dsh/commands"
        ".kimi-code/plugins"
        ".agents/plugins/marketplace.json"
        "${HARNESS_ASSET_TREES[@]}"
        "${HOOK_TREES[@]}"
        "${DOCS_TREE}"
        "${SYNC_FILES[@]}"
    )
    filter_paths "${SYNC_PATHS[@]}"
    SYNC_PATHS=("${FILTERED[@]}")

    # Fetch shared paths plus only the selected harness directories. Codex's
    # manifest source is fetched unconditionally so links from .agents resolve;
    # its plugin tree is fetched through .codex when codex is selected.
    SPARSE_PATHS=("${DOCS_TREE}" execs .agents "${CODEX_MANIFEST_ROOT}")
    for harness in ${SELECTED_HARNESSES[@]+"${SELECTED_HARNESSES[@]}"}; do
        read -ra harness_roots <<<"$(harness_dirs "${harness}")"
        SPARSE_PATHS+=("${harness_roots[@]}")
    done
fi

# Without --adopt this script rewrites the project it lives in, derived from
# its own location. A copy run from somewhere else would target that other
# tree.
if [[ "${ADOPT}" == false ]]; then
    [[ -f "${ROOT_DIR}/execs/run.sh" ]] || \
        fail "${ROOT_DIR} is not a STORY project (no execs/run.sh). This script updates the project it lives in: copy it to <thesis>/execs/update.sh and run it there, or pass --adopt to install STORY into the current directory."
fi

# Upstream resolution: environment wins, then .env, then the public default.
if [[ -z "${STORY_REPOSITORY:-}" ]]; then
    STORY_REPOSITORY="$(env_value STORY_REPOSITORY)"
fi
STORY_REPOSITORY="${STORY_REPOSITORY:-https://github.com/wanghao9610/STORY.git}"

command -v git >/dev/null 2>&1 || fail "git is required."
command -v tar >/dev/null 2>&1 || fail "tar is required."

TEMP_DIR="$(mktemp -d)"
# SELF_TMP holds the incoming copy of this script between `cp` and the `mv`
# that puts it in place; a run that dies in that window leaves no debris.
SELF_TMP=""
cleanup() {
    rm -rf -- "${TEMP_DIR}"
    [[ -z "${SELF_TMP}" ]] || rm -f -- "${SELF_TMP}"
}
trap cleanup EXIT

SOURCE_DIR="${TEMP_DIR}/repository"
ARCHIVE_FILE="${TEMP_DIR}/story-content.tar"

log "Fetching ${STORY_REF} from ${STORY_REPOSITORY}"

# Force real symlinks in the temporary checkout. The upstream harness trees use
# links into .agents/skills; a checkout that turns them into path-text files
# would otherwise install those path strings as skill content.
CLONE_ARGS=(-c core.symlinks=true --quiet --depth 1 --branch "${STORY_REF}" --single-branch)
if [[ "${ADOPT}" == false ]]; then
    CLONE_ARGS+=(--filter=blob:none --sparse)
fi

git clone \
    "${CLONE_ARGS[@]}" \
    "${STORY_REPOSITORY}" \
    "${SOURCE_DIR}" || fail "Unable to fetch ref '${STORY_REF}' from ${STORY_REPOSITORY}. Check the ref exists (a branch or tag, not a commit SHA), that the network is reachable, and that git is 2.25 or newer — currently $(git --version 2>/dev/null || echo 'unknown')."

if [[ "${ADOPT}" == false ]]; then
    # SPARSE_PATHS is directories only (see above); the existence check below
    # then runs over SYNC_PATHS, which is the exact list the tar copies — so a
    # file that the sparse checkout failed to create stops the run here
    # instead of being silently skipped. Cone mode is set explicitly: before
    # git 2.37, `clone --sparse` starts in non-cone mode, where these names are
    # literal patterns and root files such as AGENTS.md are never checked out.
    # `init --cone` exists from 2.25; `set --cone` would need 2.35.
    git -C "${SOURCE_DIR}" sparse-checkout init --cone
    git -C "${SOURCE_DIR}" sparse-checkout set "${SPARSE_PATHS[@]}"

    # SYNCED is SYNC_PATHS minus what the fetched ref does not carry, and it is
    # what everything below diffs, dirty-checks, and extracts. What may be
    # absent is is_optional_path()'s list and nothing else; anything else
    # missing is a broken ref and still fatal.
    SYNCED=()
    for path in "${SYNC_PATHS[@]}"; do
        if [[ -e "${SOURCE_DIR}/${path}" ]]; then
            SYNCED+=("${path}")
        elif is_optional_path "${path}"; then
            log "Skipping ${path}: not present in ref '${STORY_REF}'."
        else
            fail "Upstream ref is missing ${path}."
        fi
    done

    if [[ "${DIFF}" == true ]]; then
        changed=0
        added=0
        kept=0

        # Upstream files that an update would overwrite or add.
        while IFS= read -r rel; do
            if [[ ! -e "${ROOT_DIR}/${rel}" && ! -L "${ROOT_DIR}/${rel}" ]]; then
                printf '  new      %s\n' "${rel}"
                added=$(( added + 1 ))
            elif ! cmp -s "${SOURCE_DIR}/${rel}" "${ROOT_DIR}/${rel}"; then
                printf '  differs  %s\n' "${rel}"
                changed=$(( changed + 1 ))
            fi
        done < <(cd "${SOURCE_DIR}" && find -L "${SYNCED[@]}" -type f | sort)

        # Project-local files under the same paths; an update keeps them.
        while IFS= read -r rel; do
            if [[ ! -e "${SOURCE_DIR}/${rel}" ]]; then
                printf '  extra    %s (not in upstream ref; update keeps it)\n' "${rel}"
                kept=$(( kept + 1 ))
            fi
        done < <(cd "${ROOT_DIR}" && find -L "${SYNCED[@]}" -type f 2>/dev/null | sort)

        # Harness configuration: installed when missing, kept when it differs —
        # unless --force, which puts it back in the overwrite set. A skill-only
        # update never reaches it at all.
        if [[ -z "${SKILL_NAME}" ]]; then
            while IFS= read -r rel; do
                if [[ ! -e "${ROOT_DIR}/${rel}" && ! -L "${ROOT_DIR}/${rel}" ]]; then
                    printf '  new      %s (harness config)\n' "${rel}"
                    added=$(( added + 1 ))
                elif ! cmp -s "${SOURCE_DIR}/${rel}" "${ROOT_DIR}/${rel}"; then
                    if [[ "${FORCE}" == true ]]; then
                        printf '  differs  %s (harness config; --force overwrites it)\n' "${rel}"
                        changed=$(( changed + 1 ))
                    else
                        printf '  config   %s (differs from upstream; update never overwrites it)\n' "${rel}"
                    fi
                fi
            done < <(harness_rels)
        fi

        if (( changed + added > 0 )); then
            hint="bash execs/update.sh"
            [[ "${REF_SET}" == false ]] || hint="${hint} ${STORY_REF}"
            [[ -z "${SKILL_NAME}" ]] || hint="${hint} --skill ${SKILL_NAME}"
            [[ -z "${HARNESSES_ARG}" ]] || hint="${hint} --harnesses ${HARNESSES_ARG}"
            [[ "${FORCE}" == false ]] || hint="${hint} --force"
            log "${changed} differ, ${added} new upstream, ${kept} extra local."
            log "'differs' is direction-blind: it includes files you edited yourself."
            log "Run '${hint}' to apply the upstream versions."
            # 2, not 1: fail() uses 1 for every hard error, so a caller could not
            # distinguish "an update is available" from "the check itself broke".
            exit 2
        fi
        log "Everything STORY manages matches upstream ref '${STORY_REF}'. Nothing to update."
        exit 0
    fi

    # The extract below overwrites in place and cannot be rolled back. Git is
    # the only safety net, so refuse to run when it would not hold:
    # uncommitted edits under a synced path would be destroyed with no copy
    # anywhere.
    if git -C "${ROOT_DIR}" rev-parse --git-dir >/dev/null 2>&1; then
        # --force also overwrites the harness configuration, so it belongs in
        # what gets reported as about to be lost.
        DIRTY_PATHS=("${SYNCED[@]}")
        if [[ "${FORCE}" == true && -z "${SKILL_NAME}" ]]; then
            filter_paths "${HARNESS_FILES[@]}"
            # FILTERED is empty under --harnesses none, and bash 3.2 treats an
            # empty-array expansion as unbound under set -u.
            DIRTY_PATHS+=(${FILTERED[@]+"${FILTERED[@]}"})
        fi
        DIRTY="$(git -C "${ROOT_DIR}" status --porcelain -- "${DIRTY_PATHS[@]}" 2>/dev/null || true)"
        if [[ -n "${DIRTY}" ]]; then
            printf '%s\n' "${DIRTY}" | sed 's/^/      /' >&2
            if [[ "${FORCE}" == true ]]; then
                log "--force: the uncommitted changes above are being overwritten with no way back."
            else
                fail "The paths above have uncommitted changes and would be overwritten with no way back. Commit or stash them first, or preview with 'bash execs/update.sh --diff'."
            fi
        fi
    else
        log "NOTE: not a git repository, so an update cannot be undone. Back up the STORY-managed trees first if you have local edits."
    fi

    # Everything but this script goes through the tar, which extracts in place.
    # This script is the one file that must not be written in place while it is
    # running, so it is filtered out here and renamed into position below.
    TAR_PATHS=()
    for path in "${SYNCED[@]}"; do
        case "${path}" in
            "${SELF_PATH}") ;;
            ".agents/plugins/marketplace.json")
                # tar -h intentionally dereferences shared skill links, but
                # this discovery entry must remain one narrow symlink.
                ;;
            *) TAR_PATHS+=("${path}") ;;
        esac
    done

    # Materialize upstream symlinks. Downstream projects may update only one
    # harness, so installing links into an unselected tree would be fragile.
    TAR_CREATE_ARGS=(-ch)
    # Captured, not piped: grep -q closing the pipe early can hand tar a
    # SIGPIPE, and under pipefail a real match then reads as a miss.
    TAR_HELP="$(tar --help 2>/dev/null || true)"
    case "${TAR_HELP}" in
        *--hard-dereference*) TAR_CREATE_ARGS+=(--hard-dereference) ;;
    esac
    # Codex and Kimi Code copy their plugin when it is installed, so a changed
    # plugin tree reaches neither harness until the author installs it again.
    # Compared before the extract, which makes each file upstream ships match.
    # Only those files count: the extract never touches a file only the thesis
    # has, such as a SKILL_zh.md an earlier release shipped, so counting one
    # would ask for a reinstall on every update that none could clear.
    PLUGIN_REINSTALL=()
    if [[ -z "${SKILL_NAME}" ]]; then
        for plugin_harness in codex kimi; do
            is_selected "${plugin_harness}" || continue
            case "${plugin_harness}" in
                codex) plugin_tree=".codex/plugins/story" ;;
                kimi)  plugin_tree=".kimi-code/plugins/story" ;;
            esac
            [[ -d "${SOURCE_DIR}/${plugin_tree}" ]] || continue
            if [[ ! -d "${ROOT_DIR}/${plugin_tree}" ]]; then
                PLUGIN_REINSTALL+=("${plugin_harness}-new")
                continue
            fi
            while IFS= read -r rel; do
                if ! cmp -s "${SOURCE_DIR}/${rel}" "${ROOT_DIR}/${rel}"; then
                    PLUGIN_REINSTALL+=("${plugin_harness}")
                    break
                fi
            done < <(cd "${SOURCE_DIR}" && find -L "${plugin_tree}" -type f | sort)
        done
    fi

    tar -C "${SOURCE_DIR}" "${TAR_CREATE_ARGS[@]}" -f "${ARCHIVE_FILE}" "${TAR_PATHS[@]}"
    tar -C "${ROOT_DIR}" -xf "${ARCHIVE_FILE}"

    if [[ -z "${SKILL_NAME}" ]] && is_selected codex; then
        link_codex_marketplace
    fi

    # Self-update by rename. `mv` within the same directory is rename(2): the
    # directory entry swings to the new file while the running bash keeps the
    # old inode open and reads it to the end. `cp` over the target would
    # truncate and rewrite the bytes this process is still parsing.
    if [[ -z "${SKILL_NAME}" ]] && [[ -f "${SOURCE_DIR}/${SELF_PATH}" ]] && \
       ! cmp -s "${SOURCE_DIR}/${SELF_PATH}" "${ROOT_DIR}/${SELF_PATH}"; then
        SELF_TMP="${ROOT_DIR}/${SELF_PATH}.incoming.$$"
        cp -p "${SOURCE_DIR}/${SELF_PATH}" "${SELF_TMP}"
        mv -f "${SELF_TMP}" "${ROOT_DIR}/${SELF_PATH}"
        SELF_TMP=""
        log "Replaced ${SELF_PATH} with upstream's copy."
        log "      This run finishes on the old code; the next invocation uses the new one."
    fi

    if [[ -z "${SKILL_NAME}" ]]; then
        harness_kept=0
        while IFS= read -r rel; do
            if [[ ! -e "${ROOT_DIR}/${rel}" && ! -L "${ROOT_DIR}/${rel}" ]]; then
                mkdir -p "$(dirname -- "${ROOT_DIR}/${rel}")"
                cp -p "${SOURCE_DIR}/${rel}" "${ROOT_DIR}/${rel}"
                log "Installed ${rel} (harness config, was missing)"
            elif cmp -s "${SOURCE_DIR}/${rel}" "${ROOT_DIR}/${rel}"; then
                continue
            elif [[ "${FORCE}" == true ]]; then
                cp -p "${SOURCE_DIR}/${rel}" "${ROOT_DIR}/${rel}"
                log "Overwrote ${rel} (harness config; --force), including any edits you made to it."
            else
                harness_kept=$(( harness_kept + 1 ))
            fi
        done < <(harness_rels)

        if (( harness_kept > 0 )); then
            log "NOTE: ${harness_kept} harness config file(s) differ from upstream and were kept."
            log "      See which with 'bash execs/update.sh --diff'; take upstream's with --force."
        fi
        report_unregistered_hooks
        report_legacy_memory_index
        report_latexindent_closers
    fi

    log "Updated: ${SYNCED[*]}"
    for plugin_harness in ${PLUGIN_REINSTALL[@]+"${PLUGIN_REINSTALL[@]}"}; do
        case "${plugin_harness}" in
            codex) log "NOTE: .codex/plugins/story changed. Codex runs the copy made at install: run 'codex plugin remove story@story' then 'codex plugin add story@story', and start a new session." ;;
            kimi)  log "NOTE: .kimi-code/plugins/story changed. Kimi Code runs the copy made at install: run '/plugins install ./.kimi-code/plugins/story' in its prompt again, then '/reload'." ;;
            codex-new) log "NOTE: .codex/plugins/story arrived. Codex only: run 'codex plugin marketplace add .' then 'codex plugin add story@story', and start a new session." ;;
            kimi-new)  log "NOTE: .kimi-code/plugins/story arrived. Kimi Code only: run '/plugins install ./.kimi-code/plugins/story' in its prompt, then '/reload'." ;;
        esac
    done
    log "Review the changes with git status and git diff before committing them."
    exit 0
fi

# --adopt: install into an existing thesis repo, never overwriting anything.
installed=0
skipped=0

install_file() {
    local rel="$1"
    local src="${SOURCE_DIR}/${rel}"
    local dst="${ROOT_DIR}/${rel}"

    [[ -e "${src}" ]] || return 0
    if [[ -e "${dst}" || -L "${dst}" ]]; then
        printf '  kept    %s (already present)\n' "${rel}"
        skipped=$(( skipped + 1 ))
        return 0
    fi
    if [[ "${rel}" == ".agents/plugins/marketplace.json" ]]; then
        link_codex_marketplace
        printf '  added   %s -> %s\n' "${rel}" "../../.codex/plugins/marketplace.json"
        installed=$(( installed + 1 ))
        return 0
    fi
    mkdir -p "$(dirname -- "${dst}")"
    cp -p "${src}" "${dst}"
    printf '  added   %s\n' "${rel}"
    installed=$(( installed + 1 ))
}

for tree in "${ADOPT_TREES[@]}"; do
    if [[ ! -d "${SOURCE_DIR}/${tree}" ]]; then
        if is_optional_path "${tree}"; then
            log "Skipping ${tree}: not present in ref '${STORY_REF}'."
            continue
        fi
        fail "Upstream ref is missing ${tree}."
    fi
    while IFS= read -r rel; do
        install_file "${rel}"
    done < <(cd "${SOURCE_DIR}" && find -L "${tree}" -type f | sort)
done

for file in "${ADOPT_FILES[@]}"; do
    install_file "${file}"
done

for dir in "${ADOPT_DIRS[@]}"; do
    if [[ -e "${ROOT_DIR}/${dir}" || -L "${ROOT_DIR}/${dir}" ]]; then
        printf '  kept    %s/ (already present)\n' "${dir}"
        skipped=$(( skipped + 1 ))
    else
        mkdir -p "${ROOT_DIR}/${dir}"
        printf '  added   %s/\n' "${dir}"
        installed=$(( installed + 1 ))
    fi
done

if [[ -e "${ROOT_DIR}/CLAUDE.md" || -L "${ROOT_DIR}/CLAUDE.md" ]]; then
    printf '  kept    CLAUDE.md (already present)\n'
    skipped=$(( skipped + 1 ))
elif [[ -e "${ROOT_DIR}/AGENTS.md" ]]; then
    ln -s AGENTS.md "${ROOT_DIR}/CLAUDE.md"
    printf '  added   CLAUDE.md -> AGENTS.md\n'
    installed=$(( installed + 1 ))
fi

log "Adopted into ${ROOT_DIR}: ${installed} added, ${skipped} left alone."
if (( skipped > 0 )); then
    log "Nothing that was already there was modified. Review the kept lines above."
fi

# Two kept files have consequences worth naming instead of leaving to
# discovery.
if [[ -e "${ROOT_DIR}/AGENTS.md" ]] && \
   ! cmp -s "${SOURCE_DIR}/AGENTS.md" "${ROOT_DIR}/AGENTS.md"; then
    log "NOTE: your AGENTS.md was kept, so STORY's writing conventions are not in it."
    log "      Compare against ${STORY_REPOSITORY} AGENTS.md and merge what you want."
    log "      Adopt keeps it, but a later 'bash execs/update.sh' overwrites it."
fi
if [[ -e "${ROOT_DIR}/.gitignore" ]] && \
   ! cmp -s "${SOURCE_DIR}/.gitignore" "${ROOT_DIR}/.gitignore"; then
    # Git's own verdict, asked per path with a probe name that need not exist,
    # so every rule form counts (.env*, /wkdrs/, .story/memory/local/**) and a
    # directory-only rule such as .env/ does not pass for the .env file. Only the
    # repository's .gitignore files are read: an empty git directory stands in
    # for .git, so this clone's .git/info/exclude is left out, and this machine's
    # global excludes file is masked. No other clone shares either.
    git init -q --bare --template= "${TEMP_DIR}/ignore-probe.git"
    kept_rules_ignore() {
        GIT_DIR="${TEMP_DIR}/ignore-probe.git" GIT_WORK_TREE="${ROOT_DIR}" \
            git -C "${ROOT_DIR}" -c core.excludesFile=/dev/null check-ignore -q --no-index -- "$1"
    }
    unignored=()
    for probe in ".env" "wkdrs/probe" ".story/memory/local/probe"; do
        kept_rules_ignore "${probe}" || unignored+=("${probe%probe}")
    done
    if (( ${#unignored[@]} > 0 )); then
        log "NOTE: your .gitignore was kept and does not ignore ${unignored[*]}."
        log "      Add them before committing, or machine-local config, builds, reports, or one machine's own notes enter history."
    fi
    # The reverse mistake, judged by the same rules: an unanchored LaTeX-junk
    # glob such as *.log or *.out also matches evidence, which git then leaves
    # untracked while MANIFEST.md fingerprints it. import.sh names a file that
    # any rule on this machine leaves untracked.
    if kept_rules_ignore "mates/manual/probe.log"; then
        log "NOTE: your .gitignore was kept and ignores evidence under mates/ (mates/manual/probe.log matches)."
        log "      Add '!/mates/**' after its LaTeX build-file rules and before any .DS_Store rule, with a .env line right after it, or a registered log or output file never enters history."
    fi
fi
report_unregistered_hooks
report_latexindent_closers

log "Next: confirm degree_level in degree/profile.tex, copy .env.example to .env, then run story-proj-adopt in your agent to wire the thesis up."
if is_selected codex; then
    log "      Codex only: run 'codex plugin marketplace add .' then 'codex plugin add story@story', and start a new session."
fi
if is_selected dsh; then
    log "      DSH only: 'bash .dsh/hooks/install.sh' registers the DSH hook bridge once per machine."
fi
if is_selected kimi; then
    log "      Kimi Code only: 'bash .kimi-code/hooks/install.sh' registers all three Kimi hooks once per machine."
fi
