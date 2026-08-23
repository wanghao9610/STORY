#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd -P)"
ENV_FILE="${ROOT_DIR}/.env"
BUILD_DIR="${ROOT_DIR}/wkdrs/builds"
MAIN_TEX=""
NO_BUILD=false
HARD=0
WARNS=0

log() { printf '[STORY lint] %s\n' "$*"; }
hard() { printf '[STORY lint] FAIL: %s\n' "$*" >&2; HARD=$((HARD + 1)); }
warn() { printf '[STORY lint] WARN: %s\n' "$*"; WARNS=$((WARNS + 1)); }

while (( $# > 0 )); do
    case "$1" in
        --no-build) NO_BUILD=true ;;
        --main)
            (( $# >= 2 )) || { printf '[STORY lint] ERROR: --main requires a .tex path.\n' >&2; exit 2; }
            MAIN_TEX="$2"
            [[ "${MAIN_TEX}" == /* ]] || MAIN_TEX="${PWD}/${MAIN_TEX}"
            shift
            ;;
        -h|--help)
            printf '%s\n' \
                'Usage: bash execs/scpts/lint.sh [--main FILE.tex] [--no-build]' \
                '' \
                'Checks the entry point selected by --main, STORY_MAIN, or manus/main.tex.'
            exit 0 ;;
        *) printf '[STORY lint] ERROR: unknown argument %s\n' "$1" >&2; exit 2 ;;
    esac
    shift
done

env_value() {
    local key="$1" val
    [[ -f "${ENV_FILE}" ]] || return 0
    val="$(sed -n "s/^[[:space:]]*${key}=//p" "${ENV_FILE}" | tail -1)"
    val="${val%$'\r'}"; val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
    printf '%s' "${val}"
}

if [[ -z "${MAIN_TEX}" ]]; then
    MAIN_TEX="${STORY_MAIN:-$(env_value STORY_MAIN)}"
    MAIN_TEX="${MAIN_TEX:-manus/main.tex}"
    [[ "${MAIN_TEX}" == /* ]] || MAIN_TEX="${ROOT_DIR}/${MAIN_TEX}"
fi

cd "${ROOT_DIR}"
[[ -f "${MAIN_TEX}" ]] || { printf '[STORY lint] ERROR: entry point not found: %s\n' "${MAIN_TEX}" >&2; exit 2; }
MAIN_BASE="$(basename -- "${MAIN_TEX}" .tex)"
MAIN_DIR="$(cd -- "$(dirname -- "${MAIN_TEX}")" && pwd -P)"
LOG_FILE="${BUILD_DIR}/${MAIN_BASE}.log"
PDF_FILE="${BUILD_DIR}/${MAIN_BASE}.pdf"
log "Entry point: ${MAIN_TEX}."
if [[ "${NO_BUILD}" == false ]]; then
    bash execs/run.sh --main "${MAIN_TEX}"
elif [[ ! -f "${LOG_FILE}" || ! -f "${PDF_FILE}" ]]; then
    hard "--no-build requested but wkdrs/builds/${MAIN_BASE}.log or ${MAIN_BASE}.pdf is absent."
fi

if [[ -f "${LOG_FILE}" ]]; then
    if grep -Eqi 'undefined citations|Citation .* undefined|There were undefined references|Reference .* undefined' "${LOG_FILE}"; then
        hard 'undefined citation or cross-reference reported by LaTeX.'
    fi
    OVERFULL="$(grep -Ec 'Overfull \\hbox' "${LOG_FILE}" || true)"
    (( OVERFULL == 0 )) || warn "${OVERFULL} overfull hbox warning(s)."
fi

TODO_COUNT="$({
    find manus -type f -name '*.tex' -print0
} | xargs -0 awk '
    {
        line=$0
        sub(/(^|[^\\])%.*/, "", line)
        if (line ~ /\\todo[[:space:]]*\{/) n++
    }
    END { print n+0 }
' 2>/dev/null || printf '0')"
if (( TODO_COUNT > 0 )); then
    hard "${TODO_COUNT} visible \\todo marker(s) remain under manus/."
fi

if grep -Eq 'Untitled Doctoral Dissertation|University Name|Author Name|Advisor Name|Graduation Date' degree/profile.tex; then
    warn 'title-page placeholders remain in degree/profile.tex.'
fi

if [[ ! -s degree/profile.tex ]]; then
    warn 'degree/profile.tex is absent or empty.'
fi

limit=''
active=''
if [[ -f notes/story.md ]]; then
    active="$(sed -nE 's/^active_milestone:[[:space:]]*"?([^"[:space:]]*)"?.*/\1/p' notes/story.md | head -1)"
fi
if [[ -n "${active}" && -f "milestones/${active}/milestone.yml" ]]; then
    limit="$(sed -nE 's/^max_pages:[[:space:]]*([0-9]+).*/\1/p' "milestones/${active}/milestone.yml" | head -1)"
fi
if [[ -z "${limit}" ]]; then
    limit="$(sed -nE 's/^[[:space:]]*%?[[:space:]]*max_pages:[[:space:]]*([0-9]+).*/\1/p' degree/profile.tex 2>/dev/null | head -1)"
fi
if [[ -n "${limit}" && -f "${PDF_FILE}" ]] && command -v pdfinfo >/dev/null 2>&1; then
    pages="$(pdfinfo "${PDF_FILE}" 2>/dev/null | awk '/^Pages:/ {print $2}')"
    if [[ -n "${pages}" ]] && (( pages > limit )); then
        hard "${pages} pages exceeds the confirmed limit ${limit}."
    else
        log "Page limit: ${pages:-?}/${limit}."
    fi
fi

if ! bash execs/scpts/fmt.sh --check >/dev/null 2>&1; then
    warn 'manuscript is not in one-sentence-per-line format; run bash execs/scpts/fmt.sh.'
fi

if command -v texcount >/dev/null 2>&1; then
    WORDS="$(cd "${MAIN_DIR}" && TEXINPUTS="${ROOT_DIR}/manus/stys:${TEXINPUTS:-}" texcount -inc -sum -1 "$(basename -- "${MAIN_TEX}")" 2>/dev/null | tail -1 || true)"
    [[ "${WORDS}" =~ ^[0-9]+$ ]] && log "Approximate words: ${WORDS}."
fi

if (( HARD > 0 )); then
    log "Result: ${HARD} hard failure(s), ${WARNS} warning(s)."
    exit 1
fi
log "Result: pass with ${WARNS} warning(s)."
