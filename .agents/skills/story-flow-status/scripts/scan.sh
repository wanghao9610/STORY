#!/usr/bin/env bash
set -u

if [[ ! -d degree || ! -d notes || ! -d manus ]]; then
    printf 'Run this script from a STORY repository root.\n' >&2
    exit 2
fi

heading() { printf '\n## %s\n' "$1"; }
show_file() {
    local total
    printf '\n### %s\n' "$1"
    if [[ -f "$1" ]]; then
        sed -n '1,220p' "$1"
        total="$(wc -l < "$1" | tr -d '[:space:]')"
        # A silent cut would corrupt any count the reader takes from this scan.
        if (( total > 220 )); then
            printf '(truncated: 220 of %s lines shown — read %s directly before counting rows)\n' "${total}" "$1"
        fi
    else
        printf '(absent)\n'
    fi
}

# One line per Markdown table that has the named column, labeled by the heading
# above it, counting each value in first-seen order. Counts come from the whole
# file, so they stay right when show_file truncates it. A GFM-escaped \| stays
# inside its cell, so a pipe in free text never shifts the counted column.
column_counts() {
    local file="$1" column="$2"
    if [[ ! -f "${file}" ]]; then
        printf '%s: (absent)\n' "${file}"
        return 0
    fi
    awk -v want="${column}" -v file="${file}" '
        function trim(s) { gsub(/`/, "", s); gsub(/\001/, "|", s); gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        function flush(   i, where) {
            if (col) {
                where = file (label != "" ? " [" label "]" : "")
                if (rows) {
                    printf "%s %s:", where, want
                    for (i = 1; i <= nk; i++) printf " %s=%d", keys[i], count[keys[i]]
                    printf " (%d rows)\n", rows
                } else {
                    printf "%s %s: (no rows)\n", where, want
                }
                printed = 1
            }
            for (i = 1; i <= nk; i++) delete count[keys[i]]
            nk = 0; rows = 0; col = 0; header = 0
        }
        /^[[:space:]]*\|/ {
            line = $0
            gsub(/\\[|]/, "\001", line)
            n = split(line, c, "|")
            if (!header) {
                header = 1
                for (i = 2; i < n; i++) if (trim(c[i]) == want) col = i
                next
            }
            if ($0 ~ /^[[:space:]]*\|[-:| [:space:]]+\|[[:space:]]*$/) next
            if (!col) next
            v = trim(c[col])
            if (v == "") v = "(empty)"
            if (!(v in count)) keys[++nk] = v
            count[v]++
            rows++
            next
        }
        {
            if (header) flush()
            if ($0 ~ /^#+[[:space:]]/) { label = $0; sub(/^#+[[:space:]]+/, "", label) }
        }
        END {
            if (header) flush()
            if (!printed) printf "%s %s: (no table with this column)\n", file, want
        }
    ' "${file}"
}

# The value of a `key: value` line in a milestone.yml, quotes and comments dropped.
yml_value() {
    awk -v key="$2" '{
        line = $0
        if (line !~ ("^" key ":")) next
        sub("^" key ":[[:space:]]*", "", line)
        sub(/[[:space:]]*#.*$/, "", line)
        gsub(/["\047]/, "", line)
        sub(/[[:space:]]+$/, "", line)
        print line
        exit
    }' "$1"
}

# The value of a `% key: value` comment field in degree/profile.tex.
profile_value() {
    [[ -f degree/profile.tex ]] || return 0
    sed -nE "s/^[[:space:]]*%[[:space:]]*$1:[[:space:]]*(.*[^[:space:]])?[[:space:]]*\$/\\1/p" degree/profile.tex | tail -1
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
thesis_type="$(profile_value thesis_type)"
printf 'thesis-type: %s\n' "${thesis_type:-unknown (unconfirmed)}"
# Read the way degree_level is read here and in lint: the last one-word value.
dissertation_language="$(sed -nE 's/^[[:space:]]*%[[:space:]]*dissertation_language:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex 2>/dev/null | tail -1)"
case "${dissertation_language}" in
    en|zh) printf 'dissertation-language: %s\n' "${dissertation_language}" ;;
    "") printf 'dissertation-language: unknown (unconfirmed)\n' ;;
    *) printf 'dissertation-language: invalid (%s; expected en or zh)\n' "${dissertation_language}" ;;
esac
if [[ -f degree/requirements.md ]]; then
    printf 'unresolved requirement rows: %s\n' "$(grep -cE '^[[:space:]]*- \[ \]' degree/requirements.md 2>/dev/null)"
fi
show_file degree/profile.tex
show_file degree/requirements.md
show_file degree/committee.md

heading 'Narrative and ledgers'
for file in notes/story.md notes/contributions.md notes/publications.md notes/outline.md notes/claims.md notes/notation.md notes/style.md notes/adopt.md; do
    show_file "${file}"
done
# Translated twins an earlier release wrote beside each note. They belong to the
# author now; no skill reads or updates them, so they drift from the notes.
legacy_twins="$(find notes -name '*.zh-CN.md' 2>/dev/null | sort)"
if [[ -n "${legacy_twins}" ]]; then
    printf '\n### Legacy translated twins (author-owned; no skill reads or updates them)\n%s\n' "${legacy_twins}"
fi

heading 'Status counts'
column_counts notes/claims.md Status
column_counts notes/contributions.md Status
column_counts notes/publications.md Status
column_counts notes/outline.md Status
column_counts notes/refs/refs_index.md 'Verification status'

heading 'Reference index'
if [[ -f manus/bibs/reference.bib ]]; then
    # Compare with the index rows below: an entry without a row is unverified.
    printf 'bibliography entries: %s (manus/bibs/reference.bib)\n' "$(awk '
        tolower($0) ~ /^[[:space:]]*@[a-z]+[[:space:]]*[{(]/ && tolower($0) !~ /^[[:space:]]*@(comment|string|preamble)/ { n++ }
        END { print n + 0 }' manus/bibs/reference.bib)"
else
    printf 'bibliography: manus/bibs/reference.bib absent\n'
fi
show_file notes/refs/refs_index.md

heading 'Evidence manifest'
if [[ -f mates/MANIFEST.md ]]; then
    grep -nE '^## |^- (source-type|source|source-commit|sha256|imported|covers|owner|created):' mates/MANIFEST.md || printf '(no entries)\n'
    # Fingerprint integrity against the manifest. Upstream staleness needs the
    # source and is checked by `bash execs/scpts/import.sh --diff`, not here.
    hasher=''
    if command -v shasum >/dev/null 2>&1; then
        hasher='shasum -a 256'
    elif command -v sha256sum >/dev/null 2>&1; then
        hasher='sha256sum'
    fi
    if [[ -z "${hasher}" ]]; then
        printf 'integrity: not checked (no shasum or sha256sum)\n'
    else
        ok=0; tampered=''; missing=''; registered=''
        while IFS=$'\t' read -r key want; do
            [[ -n "${key}" ]] || continue
            registered="${registered}${key}"$'\n'
            if [[ ! -f "mates/${key}" ]]; then
                missing="${missing}  missing    mates/${key}"$'\n'
            elif [[ "$(${hasher} "mates/${key}" | awk '{print $1}')" == "${want}" ]]; then
                ok=$((ok + 1))
            else
                tampered="${tampered}  tampered   mates/${key}"$'\n'
            fi
        done < <(awk '/^## / { key = substr($0, 4) } /^- sha256: / && key != "" { print key "\t" substr($0, 11) }' mates/MANIFEST.md)
        unregistered=''
        while IFS= read -r path; do
            rel="${path#mates/}"
            grep -qxF "${rel}" <<< "${registered}" || unregistered="${unregistered}  unregistered mates/${rel}"$'\n'
        done < <(find mates -type f -not -name 'MANIFEST.md' -not -name '.*' 2>/dev/null | sort)
        printf 'integrity: ok=%s tampered=%s missing=%s unregistered=%s\n' "${ok}" \
            "$(printf '%s' "${tampered}" | grep -c . | tr -d '[:space:]')" \
            "$(printf '%s' "${missing}" | grep -c . | tr -d '[:space:]')" \
            "$(printf '%s' "${unregistered}" | grep -c . | tr -d '[:space:]')"
        printf '%s%s%s' "${tampered}" "${missing}" "${unregistered}"
    fi
else
    printf '(absent)\n'
fi

heading 'Manuscript files'
find manus/fronts manus/chaps manus/backs manus/figs manus/tabs manus/bibs \
    -type f -not -name '.*' 2>/dev/null | sort || true

heading 'Milestones'
# The active milestone is the one milestone.yml with status: active, the
# standing supervision record aside; a thesis from an earlier release may still
# name it as active_milestone in notes/story.md.
active=''
active_count=0
for yml in milestones/*/milestone.yml; do
    [[ -f "${yml}" ]] || continue
    slug="$(basename -- "$(dirname -- "${yml}")")"
    kind="$(yml_value "${yml}" kind)"
    status="$(yml_value "${yml}" status)"
    printf '%s: kind=%s status=%s due=%s\n' "${slug}" "${kind:-?}" "${status:-?}" "$(yml_value "${yml}" due)"
    if [[ "${status}" == active && "${kind}" != supervision ]]; then
        active_count=$((active_count + 1))
        active="${active:+${active}, }${slug}"
    fi
done
legacy_active="$(awk '/^active_milestone:/ { sub(/^active_milestone:[[:space:]]*/, ""); gsub(/["\047[:space:]]/, ""); print; exit }' notes/story.md 2>/dev/null)"
case "${active_count}" in
    0) printf 'active milestone: none%s\n' "${legacy_active:+ (legacy notes/story.md active_milestone: ${legacy_active})}" ;;
    1) printf 'active milestone: %s\n' "${active}" ;;
    *) printf 'active milestone: ambiguous — %s have status: active\n' "${active}" ;;
esac
find milestones -maxdepth 3 -type f -not -name '.*' 2>/dev/null | sort || true

heading 'Open tasks'
# Open work and feedback promises live only in tasks/; boxes in milestone
# feedback, templates, materials, or a frozen RECORD are never open work.
grep -RnE '^[[:space:]]*- \[ \]' tasks 2>/dev/null || printf '(none)\n'

heading 'Latest build'
# The same entry-point and output-directory resolution run.sh uses: STORY_MAIN
# from the environment, then .env (default manus/main.tex), wkdrs/builds/ for a
# main under manus/, <dir>/.build beside a main anywhere else.
scan_main="${STORY_MAIN:-$(sed -n 's/^[[:space:]]*STORY_MAIN=//p' .env 2>/dev/null | tail -1)}"
scan_main="${scan_main%$'\r'}"; scan_main="${scan_main%\"}"; scan_main="${scan_main#\"}"
scan_main="${scan_main%\'}"; scan_main="${scan_main#\'}"
scan_main="${scan_main:-manus/main.tex}"
scan_base="$(basename -- "${scan_main}" .tex)"
scan_dir="$(dirname -- "${scan_main}")"
if [[ "${scan_dir}" == manus || \
      "$(cd -- "${scan_dir}" 2>/dev/null && pwd -P)" == "$(pwd -P)/manus" ]]; then
    build_dir="wkdrs/builds"
else
    build_dir="${scan_dir}/.build"
fi
printf 'entry point: %s\n' "${scan_main}"
printf 'todo markers: %s\n' "$(find manus -type f -name '*.tex' -exec awk '
    { line = $0; sub(/(^|[^\\])%.*/, "", line); if (line ~ /\\todo[[:space:]]*\{/) n++ }
    END { print n + 0 }' {} + 2>/dev/null | awk '{ s += $1 } END { print s + 0 }')"
pdf="${build_dir}/${scan_base}.pdf"
if [[ -f "${pdf}" ]]; then
    if command -v pdfinfo >/dev/null 2>&1; then
        pdfinfo "${pdf}" 2>/dev/null | awk '/^(Pages|File size|CreationDate):/'
    else
        ls -l "${pdf}"
    fi
    if [[ -f "${build_dir}/${scan_base}.log" ]]; then
        printf 'undefined diagnostics: '
        grep -Eic 'undefined citations|undefined references|Citation .* undefined|Reference .* undefined' "${build_dir}/${scan_base}.log" || true
        printf 'overfull hboxes: '
        grep -Ec 'Overfull \\hbox' "${build_dir}/${scan_base}.log" || true
    fi
    newer="$(find manus degree -type f \( -name '*.tex' -o -name '*.bib' -o -name '*.cls' -o -name '*.sty' -o -name '*.bst' \) \
        -newer "${pdf}" 2>/dev/null | wc -l | tr -d '[:space:]')"
    if (( ${newer:-0} > 0 )); then
        printf 'build: stale (%s source file(s) newer than the PDF)\n' "${newer}"
        printf 'lint: not run (the build is stale; run bash execs/scpts/lint.sh)\n'
    elif [[ ! -f "${build_dir}/${scan_base}.log" ]]; then
        # lint --no-build reads the log, so a PDF whose log an editor clean
        # removed cannot be checked as it stands.
        printf 'build: stale (no build log beside the PDF)\n'
        printf 'lint: not run (the build log is missing; run bash execs/scpts/lint.sh)\n'
    else
        printf 'build: current\n'
        # --no-build reads the existing log and PDF and writes nothing.
        lint_result="$(bash execs/scpts/lint.sh --no-build --main "${scan_main}" 2>&1 | grep -F 'Result:' | tail -1)"
        printf 'lint: %s\n' "${lint_result#*Result: }"
    fi
else
    printf '(no build)\n'
    printf 'lint: not run (no build; run bash execs/scpts/lint.sh)\n'
fi

heading 'Git state'
git status --short --branch 2>/dev/null || printf '(not a git repository)\n'
