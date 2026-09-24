#!/usr/bin/env bash
set -euo pipefail

# execs/scpts/fmt.sh — one sentence per line, mechanically (AGENTS.md §6).
#
# latexindent does the rewriting, configured by .latexindent.yaml at the
# repository root. This script decides what it is allowed to touch and — the
# part that matters — refuses any rewrite that would change the typeset text.
# A line break is a space in LaTeX, so a break moved where the text already has
# a space leaves the PDF identical byte for byte; one that lands beside a brace
# or bracket adds or drops a space the PDF prints. A reformat that changes the
# text is a tool bug, and the manuscript is left as it was rather than rebuilt
# to find out.
#
# Exit codes:
#   0  every file already reads one sentence per line (or was just made to)
#   1  --check: at least one file would be reformatted
#   2  at least one file was left untouched: its rewrite would have altered the
#      text, or latexindent failed on it
#   3  cannot run: no latexindent, no config, or a path this script may not touch

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd -P)"
CONFIG="${ROOT_DIR}/.latexindent.yaml"

CHECK=false
TARGETS=""

log() {
    printf '[STORY fmt] %s\n' "$*"
}

fail() {
    printf '[STORY fmt] ERROR: %s\n' "$*" >&2
    exit 3
}

usage() {
    cat <<'EOF'
Usage: bash execs/scpts/fmt.sh [--check] [PATH ...]

Reformat the manuscript's LaTeX to one sentence per line — latexindent's
oneSentencePerLine, configured by .latexindent.yaml at the repository root.

With no PATH, the manuscript's own sources: manus/main.tex, the Chinese starter
manus/main-zh.tex, manus/fronts/, manus/chaps/, manus/backs/, and manus/tabs/.
A PATH may be a file or a directory; directories are searched for *.tex.

Two trees are never formatted, named or not: manus/stys/ and an official
institutional template under miles/*/template/. Those are reusable or
externally supplied files, and reformatting one is editing the template.

Every rewrite is checked before it is kept. LaTeX collapses each whitespace run
to a single space, so a reformat that only moves line breaks between words
leaves the typeset text identical, while a space gained or lost beside a brace
or bracket shows in the PDF; the file is compared before and after under
exactly that normalization, and a file that fails is reported and left
untouched. It needs a hand fix — usually a closing } or ] alone on its line
(an argument spelled over several lines), which belongs at the end of the line
above, in place of the bare % that ends it if there is one: that % only ate
the line end, and the closer keeps a % after it only if its own line ended in
one (}%). A {% group around running prose (\mbox{% ... }) is refused however it
is split, since latexindent joins the sentence; write it on one line without
the %. A sentence that follows a closing } on its line (\todo{...} The end.,
or \emph{One thing.} here. The end.) goes on a line of its own. A % glued to
the end of a sentence (good.% note, or good.\footnote{...}% note) eats the
space before the next line's sentence, which the split puts back; move the
comment to a line of its own, a fix that does add that space to the PDF.

A period glued to a footnote, citation, label, index entry, or \todo
(good.\footnote{...}, et al.\cite{x}) ends a sentence only after the command,
and only before a capital, a comment, or a line end not continued in
lowercase; one before an escaped or thin space (et al.\ The, Fig.\,3) ends
none. Neither is split where the source has no space. An abbreviation read as
a sentence end before a capital or a number (et al. The, Fig. 3) is not
refused but split onto two lines, since a line break is a space; a tie keeps
it whole.

Options:
  --check       Report what would change; write nothing. Exit 1 on drift.
  -h, --help    Show this help message.

No build is run: formatting cannot move a page, a reference, or a todo count.
EOF
}

while (( $# > 0 )); do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --check)
            CHECK=true
            ;;
        -*)
            fail "Unknown option: $1. Run 'bash execs/scpts/fmt.sh --help' for usage."
            ;;
        *)
            TARGETS="${TARGETS}$1
"
            ;;
    esac
    shift
done

command -v latexindent >/dev/null 2>&1 || \
    fail "latexindent not found. It ships with TeX Live and MacTeX; install it, or install the Perl script from https://github.com/cmhughes/latexindent.pl. No script here installs anything."
[[ -f "${CONFIG}" ]] || \
    fail "no .latexindent.yaml at the repository root — the line-break rule has no definition to apply."

# A tree whose bytes are somebody else's. Matched on the repository-relative
# path, so it holds however the path was spelled on the command line.
is_protected() {
    case "$1" in
        manus/stys/*)                       return 0 ;;
        miles/*/template/*|miles/*/*/template/*) return 0 ;;
    esac
    return 1
}

# A repository-relative path for anything the caller spells: absolute, relative
# to the current directory, file or directory alike.
relative_to_root() {
    local arg="$1" dir base abs
    dir="$(dirname -- "${arg}")"
    base="$(basename -- "${arg}")"
    dir="$(cd -- "${dir}" 2>/dev/null && pwd -P)" || fail "No such path: ${arg}"
    abs="${dir%/}/${base}"
    case "${abs}" in
        "${ROOT_DIR}"/*) printf '%s' "${abs#"${ROOT_DIR}"/}" ;;
        "${ROOT_DIR}")   printf '%s' "." ;;
        *) fail "Outside this repository: ${arg}" ;;
    esac
}

# Repository-relative *.tex under one path, one per line.
expand_target() {
    local rel="$1" abs="${ROOT_DIR}/$1"
    if [[ -d "${abs}" ]]; then
        find "${abs}" -type f -name '*.tex' 2>/dev/null | sort | sed "s|^${ROOT_DIR}/||"
    elif [[ -f "${abs}" ]]; then
        printf '%s\n' "${rel}"
    fi
}

# ---- the file list ----------------------------------------------------------
FILES=""
if [[ -z "${TARGETS}" ]]; then
    for t in "manus/main.tex" "manus/main-zh.tex" "manus/fronts" "manus/chaps" "manus/backs" "manus/tabs"; do
        FILES="${FILES}$(expand_target "${t}")
"
    done
else
    while IFS= read -r arg; do
        [[ -n "${arg}" ]] || continue
        rel="$(relative_to_root "${arg}")"
        # Named explicitly, a protected path is refused rather than skipped: the
        # caller asked for something this script must not do.
        if is_protected "${rel}/"; then
            fail "${rel} is a reusable or externally supplied template and is never reformatted."
        fi
        [[ -e "${ROOT_DIR}/${rel}" ]] || fail "No such path: ${arg}"
        FILES="${FILES}$(expand_target "${rel}")
"
    done <<< "${TARGETS}"
fi

# Drop blanks, protected trees, and duplicates, keeping the order stable.
KEPT=""
while IFS= read -r rel; do
    [[ -n "${rel}" ]] || continue
    is_protected "${rel}" && continue
    case "
${KEPT}" in
        *"
${rel}
"*) continue ;;
    esac
    KEPT="${KEPT}${rel}
"
done <<< "${FILES}"
FILES="${KEPT}"

if [[ -z "${FILES}" ]]; then
    log "note: no .tex files to format."
    exit 0
fi

# ---- the guard --------------------------------------------------------------
# Everything TeX collapses: any run of whitespace is one space, and a blank line
# is a paragraph break. A space at a group edge is kept: `\emph{A.} B` and
# `\emph{A.\n} B` typeset differently, so a newline latexindent puts before a
# closing brace is a change, not layout. What survives this normalization is
# what the PDF shows — so two files that normalize alike typeset alike, whatever
# their line breaks, and two that do not are not the same document.
normalized() {
    perl -0777 -ne '
        s/\r\n/\n/g;
        my @paragraphs = split /\n[ \t]*\n[ \t\n]*/, $_;
        for (@paragraphs) {
            s/\s+/ /g;
            s/^ //;
            s/ $//;
        }
        print join("\n\n", @paragraphs);
    ' "$1"
}

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

DRIFT=""
UNSAFE=""
BROKE=""
CHANGED=0
CLEAN=0

while IFS= read -r rel; do
    [[ -n "${rel}" ]] || continue
    src="${ROOT_DIR}/${rel}"
    cand="${WORK}/$(printf '%s' "${rel}" | tr '/' '_')"
    cp "${src}" "${cand}"

    # latexindent's own regexes make Perl warn about experimental lookbehind on
    # every run; that noise is not this script's to relay.
    if ! latexindent -m -l="${CONFIG}" -s -w -c "${WORK}" -g "${WORK}/indent.log" \
        "${cand}" >/dev/null 2>&1; then
        BROKE="${BROKE}${rel}
"
        continue
    fi

    if cmp -s "${src}" "${cand}"; then
        CLEAN=$(( CLEAN + 1 ))
        continue
    fi

    if [[ "$(normalized "${src}")" != "$(normalized "${cand}")" ]]; then
        UNSAFE="${UNSAFE}${rel}
"
        continue
    fi

    if [[ "${CHECK}" == true ]]; then
        DRIFT="${DRIFT}${rel}
"
    else
        cp "${cand}" "${src}"
        CHANGED=$(( CHANGED + 1 ))
    fi
done <<< "${FILES}"

# ---- verdict ----------------------------------------------------------------
show() {
    printf '%s' "$1" | sed '/^$/d; s/^/      /'
}

count() {
    printf '%s' "$1" | sed '/^$/d' | wc -l | tr -d '[:space:]'
}

STATUS=0

if [[ -n "${BROKE}" ]]; then
    log "warn: latexindent failed on $(count "${BROKE}") file(s), left untouched:"
    show "${BROKE}"
    log "      reproduce with: latexindent -m -l=.latexindent.yaml -s <file>"
    # Unchecked is not clean: without this a broken latexindent install would
    # turn every --check into a silent pass.
    STATUS=2
fi

if [[ -n "${UNSAFE}" ]]; then
    log "REFUSED: $(count "${UNSAFE}") file(s) whose reformat would have changed the typeset text — left untouched:"
    show "${UNSAFE}"
    log "      a closing } or ] alone on its line (an argument spelled over several lines, or a sentence and its '}' split by an earlier fmt.sh) goes at the end of the line above, by hand, in place of the bare % that ends it if there is one, which only ate that line end; keep a % after the closer only if its own line ended in one ('}%')."
    log "      a '{%' group around running prose ('\\mbox{%', 'the first result%', '}') is refused however it is split, since latexindent joins the sentence: write it on one line without the % ('\\mbox{the first result}'), by hand."
    log "      a sentence that follows a closing } on its line ('\\todo{...} The end.', or '\\emph{One thing.} here. The end.') goes on a line of its own, by hand."
    log "      a '%' glued to the end of a sentence ('good.% note', or 'good.\\footnote{...}% note') eats the space before the next line's sentence, which the split puts back: move the comment to a line of its own, by hand, a fix that does add that space to the PDF."
    STATUS=2
fi

# The all-clear is only that when nothing was refused: a file left untouched is
# not a file that reads one sentence per line.
if [[ "${CHECK}" == true ]]; then
    if [[ -n "${DRIFT}" ]]; then
        log "$(count "${DRIFT}") file(s) are not one sentence per line:"
        show "${DRIFT}"
        log "      fix with: bash execs/scpts/fmt.sh"
        if (( STATUS == 0 )); then STATUS=1; fi
    elif [[ -z "${UNSAFE}${BROKE}" ]]; then
        log "ok: ${CLEAN} file(s) already read one sentence per line."
    fi
elif (( CHANGED > 0 )); then
    log "reformatted ${CHANGED} file(s); ${CLEAN} already clean."
elif [[ -z "${UNSAFE}${BROKE}" ]]; then
    log "ok: ${CLEAN} file(s) already read one sentence per line."
fi

exit "${STATUS}"
