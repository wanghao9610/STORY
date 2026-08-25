#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd -P)"
ENV_FILE="${ROOT_DIR}/.env"
MANIFEST="${ROOT_DIR}/mates/MANIFEST.md"
SOURCE_INPUT=''
SLUG=''
DIFF=false

log() { printf '[STORY import] %s\n' "$*"; }
fail() { printf '[STORY import] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
    printf '%s\n' \
        'Usage: bash execs/scpts/import.sh [--source PATH] [--slug NAME] [--diff]' \
        '' \
        'Snapshots selected evidence from a STAR, STAGE, STORY, or structured' \
        'generic research repository into mates/<slug>/ and fingerprints it.'
}

while (( $# > 0 )); do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --source) (( $# >= 2 )) || fail '--source requires a path.'; SOURCE_INPUT="$2"; shift 2 ;;
        --source=*) SOURCE_INPUT="${1#*=}"; shift ;;
        --slug) (( $# >= 2 )) || fail '--slug requires a name.'; SLUG="$2"; shift 2 ;;
        --slug=*) SLUG="${1#*=}"; shift ;;
        --diff) DIFF=true; shift ;;
        *) fail "unknown argument: $1" ;;
    esac
done

env_value() {
    local key="$1" val
    [[ -f "${ENV_FILE}" ]] || return 0
    val="$(sed -n "s/^[[:space:]]*${key}=//p" "${ENV_FILE}" | tail -1)"
    val="${val%$'\r'}"; val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
    printf '%s' "${val}"
}

RESEARCH_HOME="${RESEARCH_HOME:-$(env_value RESEARCH_HOME)}"
SOURCE_INPUT="${SOURCE_INPUT:-${RESEARCH_HOME:-}}"
[[ -n "${SOURCE_INPUT}" ]] || fail 'pass --source PATH or set RESEARCH_HOME in .env.'
[[ -d "${SOURCE_INPUT}" ]] || fail "source is not a directory: ${SOURCE_INPUT}"
SOURCE_DIR="$(cd -- "${SOURCE_INPUT}" && pwd -P)"

if [[ -z "${SLUG}" ]]; then
    SLUG="$(basename -- "${SOURCE_DIR}" | tr '[:upper:]' '[:lower:]')"
fi
[[ "${SLUG}" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || fail "invalid slug '${SLUG}'."
[[ "${SLUG}" != manual ]] || fail "slug 'manual' is reserved."

if [[ -d "${SOURCE_DIR}/.story" ]]; then
    SOURCE_TYPE=story
elif [[ -d "${SOURCE_DIR}/.stage" || -f "${SOURCE_DIR}/notes/claims.md" && -d "${SOURCE_DIR}/manus/secs" ]]; then
    SOURCE_TYPE=stage
elif [[ -d "${SOURCE_DIR}/metds" ]]; then
    SOURCE_TYPE=star
else
    SOURCE_TYPE=generic
fi

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "${TEMP_DIR}"' EXIT
LIST_FILE="${TEMP_DIR}/files"
: > "${LIST_FILE}"

add_file() {
    local rel="$1"
    if [[ -f "${SOURCE_DIR}/${rel}" && "$(basename -- "${rel}")" != .* ]]; then
        printf '%s\n' "${rel}" >> "${LIST_FILE}"
    fi
}

add_tree() {
    local tree="$1" pattern="${2:-*}"
    [[ -d "${SOURCE_DIR}/${tree}" ]] || return 0
    (cd "${SOURCE_DIR}" && find "${tree}" -type f -name "${pattern}" -not -name '.*' | sort) >> "${LIST_FILE}"
}

case "${SOURCE_TYPE}" in
    star)
        for rel in metds/adopt.md metds/codearc.md metds/overview.md metds/framework.md \
                   metds/dataset.md metds/training.md metds/evaluation.md; do add_file "${rel}"; done
        add_tree metds/ideas '*.md'; add_tree metds/refs '*'
        add_tree wkdrs/results '*.md'; add_tree wkdrs/digests '*.md'
        ;;
    stage)
        for rel in notes/story.md notes/outline.md notes/claims.md manus/bibs/reference.bib mates/MANIFEST.md; do add_file "${rel}"; done
        add_tree notes/refs '*.md'; add_tree manus/secs '*.tex'; add_tree manus/tabs '*.tex'; add_tree manus/figs '*'
        ;;
    story)
        for rel in notes/story.md notes/outline.md notes/claims.md notes/contributions.md \
                   notes/publications.md manus/bibs/reference.bib mates/MANIFEST.md; do add_file "${rel}"; done
        add_tree notes/refs '*.md'; add_tree manus/chaps '*.tex'; add_tree manus/tabs '*.tex'; add_tree manus/figs '*'
        ;;
    generic)
        for tree in evidence results reports artifacts; do
            add_tree "${tree}" '*.md'; add_tree "${tree}" '*.csv'; add_tree "${tree}" '*.json'
            add_tree "${tree}" '*.yml'; add_tree "${tree}" '*.yaml'; add_tree "${tree}" '*.bib'
        done
        ;;
esac
sort -u "${LIST_FILE}" -o "${LIST_FILE}"
[[ -s "${LIST_FILE}" ]] || fail "no importable ${SOURCE_TYPE} artifacts found in ${SOURCE_DIR}."

DEST_DIR="${ROOT_DIR}/mates/${SLUG}"
if [[ "${DIFF}" == true ]]; then
    drift=0
    while IFS= read -r rel; do
        if [[ ! -f "${DEST_DIR}/${rel}" ]]; then
            printf 'new upstream  %s\n' "${rel}"; drift=$((drift + 1))
        elif ! cmp -s "${SOURCE_DIR}/${rel}" "${DEST_DIR}/${rel}"; then
            printf 'stale         %s\n' "${rel}"; drift=$((drift + 1))
        fi
    done < "${LIST_FILE}"
    # 2, not 1: fail() uses 1 for every hard error, so a caller could not
    # otherwise distinguish "the snapshot is stale" from "the check itself
    # broke" — the same contract update.sh --diff keeps.
    (( drift == 0 )) || exit 2
    log "mates/${SLUG}/ matches ${SOURCE_DIR}."
    exit 0
fi

sha256() {
    if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
    else printf 'n/a'; fi
}

replace_entry() {
    local key="$1" block="$2" out="${TEMP_DIR}/manifest"
    awk -v key="## ${key}" -v block="${block}" '
        $0 == key {
            while ((getline line < block) > 0) print line
            close(block); print ""; skip=1; next
        }
        /^## / { skip=0 }
        !skip { print }
        END { if (!found) {} }
    ' "${MANIFEST}" > "${out}"
    if ! grep -qxF "## ${key}" "${MANIFEST}"; then
        printf '\n' >> "${out}"
        printf '%s\n' "$(<"${block}")" >> "${out}"
    fi
    mv "${out}" "${MANIFEST}"
}

mkdir -p "${ROOT_DIR}/mates"
[[ -f "${MANIFEST}" ]] || printf '# Evidence manifest\n' > "${MANIFEST}"
SOURCE_COMMIT="$(git -C "${SOURCE_DIR}" rev-parse HEAD 2>/dev/null || printf 'n/a')"
# A fingerprint stamped with a commit the imported bytes may not match is a
# provenance lie; mark a dirty source so the manifest says what was true.
if [[ "${SOURCE_COMMIT}" != n/a ]] && \
   [[ -n "$(git -C "${SOURCE_DIR}" status --porcelain 2>/dev/null)" ]]; then
    SOURCE_COMMIT="${SOURCE_COMMIT}-dirty"
    log "WARN: source repository has uncommitted changes; recording source-commit ${SOURCE_COMMIT}."
fi
TODAY="$(date +%Y-%m-%d)"
count=0
while IFS= read -r rel; do
    dst="${DEST_DIR}/${rel}"
    mkdir -p "$(dirname -- "${dst}")"
    cp -p "${SOURCE_DIR}/${rel}" "${dst}"
    key="${SLUG}/${rel}"
    block="${TEMP_DIR}/block"
    {
        printf '## %s\n' "${key}"
        printf -- '- source-type: %s\n' "${SOURCE_TYPE}"
        printf -- '- source: %s/%s\n' "${SOURCE_DIR}" "${rel}"
        printf -- '- source-commit: %s\n' "${SOURCE_COMMIT}"
        printf -- '- sha256: %s\n' "$(sha256 "${dst}")"
        printf -- '- imported: %s\n' "${TODAY}"
        printf -- '- covers: imported graduate-research evidence\n'
    } > "${block}"
    replace_entry "${key}" "${block}"
    count=$((count + 1))
done < "${LIST_FILE}"

for bib in metds/refs/reference.bib manus/bibs/reference.bib; do
    if [[ ! -f "${ROOT_DIR}/manus/bibs/reference.bib" && -f "${SOURCE_DIR}/${bib}" ]]; then
        cp -p "${SOURCE_DIR}/${bib}" "${ROOT_DIR}/manus/bibs/reference.bib"
        log "seeded manus/bibs/reference.bib from ${bib}."
        break
    fi
done

log "Imported ${count} ${SOURCE_TYPE} artifact(s) into mates/${SLUG}/ from commit ${SOURCE_COMMIT}."
