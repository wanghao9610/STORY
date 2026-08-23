#!/usr/bin/env bash
set -euo pipefail

EXEC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "${EXEC_DIR}/.." && pwd -P)"
ENV_FILE="${ROOT_DIR}/.env"
MAIN_TEX="${ROOT_DIR}/manus/main.tex"
BUILD_DIR=""

log() { printf '[STORY run] %s\n' "$*"; }
fail() { printf '[STORY run] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
    printf '%s\n' \
        'Usage: bash execs/run.sh [--main FILE.tex] [--outdir DIR] [latexmk args...]' \
        '' \
        'Builds manus/main.tex out-of-tree in wkdrs/builds/. LATEX_ENGINE may be' \
        'pdflatex, xelatex, or lualatex; the default is pdflatex.'
}

while (( $# > 0 )); do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --main)
            (( $# >= 2 )) || fail '--main requires a .tex path.'
            MAIN_TEX="$2"; [[ "${MAIN_TEX}" == /* ]] || MAIN_TEX="${PWD}/${MAIN_TEX}"
            shift 2 ;;
        --outdir)
            (( $# >= 2 )) || fail '--outdir requires a directory.'
            BUILD_DIR="$2"; [[ "${BUILD_DIR}" == /* ]] || BUILD_DIR="${PWD}/${BUILD_DIR}"
            shift 2 ;;
        *) break ;;
    esac
done

env_value() {
    local key="$1" val
    [[ -f "${ENV_FILE}" ]] || return 0
    val="$(sed -n "s/^[[:space:]]*${key}=//p" "${ENV_FILE}" | tail -1)"
    val="${val%$'\r'}"; val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
    printf '%s' "${val}"
}

LATEX_ENGINE="${LATEX_ENGINE:-$(env_value LATEX_ENGINE)}"
LATEX_ENGINE="${LATEX_ENGINE:-pdflatex}"
case "${LATEX_ENGINE}" in
    pdflatex) ENGINE_FLAG='-pdf' ;;
    xelatex) ENGINE_FLAG='-xelatex' ;;
    lualatex) ENGINE_FLAG='-lualatex' ;;
    *) fail "Unsupported LATEX_ENGINE '${LATEX_ENGINE}'." ;;
esac

command -v latexmk >/dev/null 2>&1 || fail 'latexmk not found; install TeX Live or MacTeX.'
[[ -f "${MAIN_TEX}" ]] || fail "Entry point not found: ${MAIN_TEX}"

MAIN_DIR="$(cd -- "$(dirname -- "${MAIN_TEX}")" && pwd -P)"
MAIN_BASE="$(basename -- "${MAIN_TEX}" .tex)"
if [[ -z "${BUILD_DIR}" ]]; then
    if [[ "${MAIN_DIR}" == "${ROOT_DIR}/manus" ]]; then
        BUILD_DIR="${ROOT_DIR}/wkdrs/builds"
    else
        BUILD_DIR="${MAIN_DIR}/.build"
    fi
fi
mkdir -p "${BUILD_DIR}"

export TEXINPUTS="${MAIN_DIR}/stys:${TEXINPUTS:-}"
export BSTINPUTS="${MAIN_DIR}/stys:${BSTINPUTS:-}"
log "Engine: ${LATEX_ENGINE}; output: ${BUILD_DIR}"

if ! latexmk "${ENGINE_FLAG}" -interaction=nonstopmode -halt-on-error -cd \
        -outdir="${BUILD_DIR}" ${1+"$@"} "${MAIN_TEX}"; then
    fail "latexmk failed; inspect ${BUILD_DIR}/${MAIN_BASE}.log."
fi

PDF_FILE="${BUILD_DIR}/${MAIN_BASE}.pdf"
[[ -f "${PDF_FILE}" ]] || fail "latexmk completed without ${PDF_FILE}."
if command -v pdfinfo >/dev/null 2>&1; then
    PAGES="$(pdfinfo "${PDF_FILE}" 2>/dev/null | awk '/^Pages:/ {print $2}')"
    log "Built ${PDF_FILE} (${PAGES:-?} pages)"
else
    log "Built ${PDF_FILE} (install pdfinfo for a page count)"
fi
