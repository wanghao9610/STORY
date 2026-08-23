#!/usr/bin/env bash
set -u

if [[ ! -d degree || ! -d notes || ! -d manus ]]; then
    printf 'Run this script from a STORY repository root.\n' >&2
    exit 2
fi

heading() { printf '\n## %s\n' "$1"; }
show_file() {
    printf '\n### %s\n' "$1"
    if [[ -f "$1" ]]; then
        sed -n '1,220p' "$1"
    else
        printf '(absent)\n'
    fi
}

printf '# STORY workflow scan\n'
printf 'date: %s\n' "$(date +%Y-%m-%d)"

heading 'Runtime'
if [[ -f .env ]]; then
    grep -sE '^(RESEARCH_HOME|STORY_MAIN|LATEX_ENGINE|STORY_REPOSITORY|STORY_LANG|INVOLVE)=' .env || printf '(defaults)\n'
else
    printf '.env absent; defaults apply.\n'
fi

heading 'Degree'
degree_level="$(sed -nE 's/^[[:space:]]*%[[:space:]]*degree_level:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex 2>/dev/null | tail -1)"
case "${degree_level}" in
    master|doctoral) printf 'degree-level: %s\n' "${degree_level}" ;;
    "") printf 'degree-level: unknown (set degree_level to master or doctoral in degree/profile.tex)\n' ;;
    *) printf 'degree-level: invalid (%s; expected master or doctoral)\n' "${degree_level}" ;;
esac
show_file degree/profile.tex
show_file degree/requirements.md
show_file degree/committee.md

heading 'Narrative and ledgers'
for file in notes/story.md notes/contributions.md notes/publications.md notes/outline.md notes/claims.md notes/notation.md notes/style.md notes/adopt.md; do
    show_file "${file}"
done

heading 'Reference index'
show_file notes/refs/refs_index.md

heading 'Evidence manifest'
if [[ -f mates/MANIFEST.md ]]; then
    grep -nE '^## |^- (source-type|source|source-commit|sha256|imported|covers):' mates/MANIFEST.md || printf '(no entries)\n'
else
    printf '(absent)\n'
fi

heading 'Manuscript files'
find manus/fronts manus/chaps manus/backs manus/figs manus/tabs manus/bibs \
    -type f -not -name '.*' 2>/dev/null | sort || true

heading 'Milestones'
find milestones -maxdepth 3 -type f -not -name '.*' 2>/dev/null | sort || true

heading 'Open tasks'
grep -RnE '^[[:space:]]*- \[ \]' tasks milestones 2>/dev/null || printf '(none)\n'

heading 'Latest build'
if [[ -f wkdrs/builds/main.pdf ]]; then
    if command -v pdfinfo >/dev/null 2>&1; then
        pdfinfo wkdrs/builds/main.pdf 2>/dev/null | awk '/^(Pages|File size|CreationDate):/'
    else
        ls -l wkdrs/builds/main.pdf
    fi
    if [[ -f wkdrs/builds/main.log ]]; then
        printf 'undefined diagnostics: '
        grep -Eic 'undefined citations|undefined references|Citation .* undefined|Reference .* undefined' wkdrs/builds/main.log || true
        printf 'overfull hboxes: '
        grep -Ec 'Overfull \\hbox' wkdrs/builds/main.log || true
    fi
else
    printf '(no build)\n'
fi

heading 'Git state'
git status --short --branch 2>/dev/null || printf '(not a git repository)\n'
