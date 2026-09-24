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

check_prose_patterns() {
    local file prose_output location patterns snippet
    local prose_count=0
    local -a prose_files=()

    while IFS= read -r file; do
        prose_files+=("${file}")
    done < <(find manus/fronts manus/chaps manus/backs -type f -name '*.tex' -print 2>/dev/null | sort)

    if (( ${#prose_files[@]} == 0 )); then
        log 'Prose review: no front-matter, chapter, or back-matter TeX files found.'
        return
    fi

    prose_output="$(awk '
        function strip_comment(text, start) {
            start = match(text, /(^|[^\\])%/)
            if (!start) return text
            if (substr(text, start, 1) == "%") return substr(text, 1, start - 1)
            return substr(text, 1, start)
        }
        function add_pattern(name) {
            if (patterns != "") patterns = patterns ","
            patterns = patterns name
            pattern_count++
        }
        function flush_paragraph(    lower, stock_text, stock_count, chatbot, excerpt) {
            if (paragraph == "") return

            lower = tolower(paragraph)
            patterns = ""
            pattern_count = 0
            chatbot = 0

            if (lower ~ /(i hope this helps|would you like me to|let me know if|up to my last training|let.s (dive|explore|break this down)|without further ado)/ ||
                paragraph ~ /(希望这对(您|你)有帮助|如果(您|你).*(请告诉我|告诉我)|让我们(深入探讨|来看看|分析一下)|根据我最后的训练)/) {
                add_pattern("chatbot-residue")
                chatbot = 1
            }
            if (lower ~ /(stands? as (a )?(testament|reminder)|pivotal (role|moment)|underscores? (the )?(importance|significance)|evolving landscape|lays? (a |the )?foundation|sets? the stage)/ ||
                paragraph ~ /(具有[^。；;.]*(重要|深远)[^。；;.]*意义|标志着[^。；;.]*(转折|转变|里程碑)|(彰显|凸显)[^。；;.]*(重要性|意义)|奠定[^。；;.]*基础|不断演变的[^。；;.]*格局)/) {
                add_pattern("inflated-significance")
            }
            if (lower ~ /((experts?|observers?|critics?) (argue|believe|suggest|note)|industry reports? (show|suggest|indicate)|studies have shown)/ ||
                paragraph ~ /((专家|学者|业内人士)(普遍)?(认为|指出|表示)|行业报告(显示|指出|表明)|已有研究(认为|指出|表明|显示)|一些批评者认为)/) {
                add_pattern("vague-attribution")
            }
            if (lower ~ /(not (only|merely|just)[^.;]*but( also)?|not just[^.;]*it is)/ ||
                paragraph ~ /(不仅[^。；;.]*而且|不仅[^。；;.]*还|不仅[^。；;.]*更|不只是[^。；;.]*而是|不是[^。；;.]*而是)/) {
                add_pattern("formulaic-contrast")
            }
            if (lower ~ /(it is (important|worth) to note|it should be noted|this (section|chapter) (delves into|explores|examines)|in order to|the following section)/ ||
                paragraph ~ /(值得注意的是|需要指出的是|不难发现|本(节|章|文)将(深入)?(探讨|分析|研究)|为了实现这一(目标|目的))/) {
                add_pattern("stock-signposting")
            }
            if (lower ~ /, (highlighting|underscoring|showcasing|ensuring|reflecting|demonstrating) / ||
                paragraph ~ /(从而(彰显|体现|确保|促进|说明)|进而(彰显|体现|推动|促进|说明)|这(充分)?(彰显|体现|凸显))/) {
                add_pattern("shallow-analysis")
            }
            if (lower ~ /(despite (these|the) challenges|future outlook|future looks bright|continues? to (thrive|flourish))/ ||
                paragraph ~ /(尽管[^。；;.]*(挑战|困难)|未来展望|前景(十分|非常)?(广阔|光明)|继续(蓬勃发展|迈向))/) {
                add_pattern("generic-outlook")
            }
            if (lower ~ /(at its core|what really matters|the real question is|the heart of the matter)/ ||
                paragraph ~ /(归根结底|从本质上说|真正重要的是|真正的问题是|问题的核心在于)/) {
                add_pattern("manufactured-depth")
            }

            stock_text = lower
            stock_count = gsub(/(crucial|pivotal|intricate|landscape|delve|underscore|showcase|foster|tapestry)/, "&", stock_text)
            stock_text = paragraph
            stock_count += gsub(/(至关重要|深入探讨|不断演变|格局|彰显|赋能|协同|多维度)/, "&", stock_text)
            if (stock_count >= 3) add_pattern("stock-diction")

            if (chatbot || pattern_count >= 2) {
                excerpt = paragraph
                gsub(/[[:space:]]+/, " ", excerpt)
                sub(/^[[:space:]]+/, "", excerpt)
                sub(/[[:space:]]+$/, "", excerpt)
                printf "%s:%d\t%s\t%s\n", current_file, paragraph_start, patterns, excerpt
            }
            paragraph = ""
        }
        FNR == 1 {
            if (NR > 1) flush_paragraph()
            current_file = FILENAME
            paragraph = ""
        }
        {
            line = strip_comment($0)
            gsub(/\r/, "", line)
            trimmed = line
            sub(/^[[:space:]]+/, "", trimmed)
            sub(/[[:space:]]+$/, "", trimmed)

            if (trimmed == "" || trimmed ~ /^\\(begin|end|chapter|section|subsection|subsubsection|paragraph|label|input|include|bibliography|bibliographystyle)[*]?[[:space:]]*\{/) {
                flush_paragraph()
                next
            }

            clean = line
            gsub(/\\(cite|citep|citet|citeauthor|parencite|textcite|ref|eqref|autoref|label|url)(\[[^]]*\])?\{[^}]*\}/, " ", clean)
            gsub(/\$[^$]*\$/, " ", clean)
            gsub(/\\[[:alpha:]@]+[*]?/, " ", clean)
            gsub(/[{}]/, " ", clean)
            gsub(/[[:space:]]+/, " ", clean)
            sub(/^[[:space:]]+/, "", clean)
            sub(/[[:space:]]+$/, "", clean)
            if (clean == "") next

            if (paragraph == "") paragraph_start = FNR
            paragraph = paragraph " " clean
        }
        END { flush_paragraph() }
    ' "${prose_files[@]}")"

    if [[ -z "${prose_output}" ]]; then
        log 'Prose review: no high-confidence chatbot residue or clustered formulaic prose found.'
        return
    fi

    while IFS=$'\t' read -r location patterns snippet; do
        [[ -n "${location}" ]] || continue
        if (( ${#snippet} > 140 )); then
            snippet="${snippet:0:137}..."
        fi
        warn "${location}: prose review (${patterns}); ${snippet}"
        prose_count=$((prose_count + 1))
    done <<< "${prose_output}"
    log "Prose review: ${prose_count} passage(s) need human review; findings are advisory, not proof of AI authorship."
}

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
# Mirror run.sh: an entry point outside manus/ builds beside itself, so the log
# and PDF the checks below read must come from the same place run.sh writes.
if [[ "${MAIN_DIR}" != "${ROOT_DIR}/manus" ]]; then
    BUILD_DIR="${MAIN_DIR}/.build"
fi
LOG_FILE="${BUILD_DIR}/${MAIN_BASE}.log"
PDF_FILE="${BUILD_DIR}/${MAIN_BASE}.pdf"
log "Entry point: ${MAIN_TEX}."
# A failed or missing build still gets a Result line, but every check that reads
# the log or the PDF is skipped: an older PDF left by an earlier successful build
# would otherwise pass for this manuscript.
BUILD_USABLE=true
if [[ "${NO_BUILD}" == false ]]; then
    if ! bash execs/run.sh --main "${MAIN_TEX}"; then
        hard "the build failed (see ${LOG_FILE}); log and page checks were skipped."
        BUILD_USABLE=false
    fi
elif [[ ! -f "${LOG_FILE}" || ! -f "${PDF_FILE}" ]]; then
    hard "--no-build requested but ${LOG_FILE} or ${PDF_FILE} is absent."
    BUILD_USABLE=false
elif grep -q '^!' "${LOG_FILE}"; then
    hard "the last build stopped on a LaTeX error (see ${LOG_FILE}); rebuild with bash execs/run.sh."
    BUILD_USABLE=false
else
    STALE_SOURCES="$(find manus degree -type f \( -name '*.tex' -o -name '*.bib' -o -name '*.cls' -o -name '*.sty' -o -name '*.bst' \) \
        -newer "${PDF_FILE}" 2>/dev/null | wc -l | tr -d '[:space:]')"
    if (( ${STALE_SOURCES:-0} > 0 )); then
        warn "${STALE_SOURCES} source file(s) under manus/ or degree/ are newer than the PDF; rebuild before trusting its page and reference checks."
    fi
fi

if [[ "${BUILD_USABLE}" == true && -f "${LOG_FILE}" ]]; then
    if grep -Eqi 'undefined citations|Citation .* undefined|There were undefined references|Reference .* undefined' "${LOG_FILE}"; then
        hard 'undefined citation or cross-reference reported by LaTeX.'
    fi
    OVERFULL="$(grep -Ec 'Overfull \\hbox' "${LOG_FILE}" || true)"
    (( OVERFULL == 0 )) || warn "${OVERFULL} overfull hbox warning(s)."
    # A glyph the fonts lack is dropped from the PDF, yet the build still succeeds.
    MISSING_CHARS="$(grep -c 'Missing character: There is no' "${LOG_FILE}" || true)"
    (( MISSING_CHARS == 0 )) || warn "the build log reports ${MISSING_CHARS} missing character(s): text in a script the fonts cannot typeset, such as Chinese without the cjk class option."
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

check_prose_patterns

# The file-existence guard matters: a bare command substitution over a missing
# file fails the assignment under set -e and kills the script before the
# graceful absent-or-empty warning below can fire.
DEGREE_LEVEL=""
if [[ -s degree/profile.tex ]]; then
    DEGREE_LEVEL="$(sed -nE 's/^[[:space:]]*%[[:space:]]*degree_level:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex | tail -1)"
fi
case "${DEGREE_LEVEL}" in
    master|doctoral)
        log "Degree level: ${DEGREE_LEVEL}."
        ;;
    "")
        if [[ -s degree/profile.tex ]]; then
            warn 'degree_level is unset in degree/profile.tex; confirm master or doctoral before level-specific review.'
        fi
        ;;
    *)
        hard "invalid degree_level '${DEGREE_LEVEL}' in degree/profile.tex; expected master or doctoral."
        ;;
esac

# Only the degree field names the level: a title may use "Doctor" or "Master" as
# a subject word, and the run may not change an approved title.
DEGREE_FIELD="$(grep -E '^[[:space:]]*\\degree\{' degree/profile.tex 2>/dev/null || true)"
if [[ "${DEGREE_LEVEL}" == master ]] && grep -Eqi 'Doctor(al)?|博士' <<< "${DEGREE_FIELD}"; then
    hard 'master degree_level conflicts with doctoral wording in the degree field.'
elif [[ "${DEGREE_LEVEL}" == doctoral ]] && grep -Eqi 'Master([^a-z]|$)|硕士' <<< "${DEGREE_FIELD}"; then
    hard 'doctoral degree_level conflicts with master wording in the degree field.'
fi

# Placeholders are read from compiled lines only: the profile's own comments name
# the fields they describe, and matching those would warn on every profile.
if [[ -s degree/profile.tex ]]; then
    PLACEHOLDERS="$(awk '
        BEGIN { n = split("Untitled Thesis|未命名学位论文|Author Name|作者姓名|University Name|学校名称|Department or Program|院系或培养单位|Submission Statement|提交说明|Degree Name|学位名称|Advisor Name|导师姓名|Graduation Date|完成日期", p, "|") }
        /^[[:space:]]*%/ { next }
        { for (i = 1; i <= n; i++) if (index($0, p[i])) seen[i] = 1 }
        END { for (i = 1; i <= n; i++) if (i in seen) printf "%s%s", (c++ ? ", " : ""), p[i] }
    ' degree/profile.tex)"
    if [[ -n "${PLACEHOLDERS}" ]]; then
        warn "title-page placeholders remain in degree/profile.tex: ${PLACEHOLDERS}."
    fi
    # A profile from before the field existed has no line to replace, so the
    # class's own placeholder would reach the title page unnoticed.
    if ! grep -Eq '^[[:space:]]*\\submissionstatement[[:space:]]*\{' degree/profile.tex; then
        warn 'title-page placeholder: degree/profile.tex sets no \submissionstatement, so the title page prints the class placeholder.'
    fi

    # Manuscript language and entry point must agree: a zh profile built by an
    # English entry point (or the reverse) typesets the wrong title page. Only
    # STORY's class takes the zh option, so an institutional class is named but
    # not checked. An option list may span lines: it is joined, comments
    # stripped, before it is read.
    DISSERTATION_LANG="$(sed -nE 's/^[[:space:]]*%[[:space:]]*dissertation_language:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex | tail -1)"
    case "${DISSERTATION_LANG}" in
        en|zh)
            CLASS_INFO="$(awk '
                function strip_comment(text, start) {
                    start = match(text, /(^|[^\\])%/)
                    if (!start) return text
                    if (substr(text, start, 1) == "%") return substr(text, 1, start - 1)
                    return substr(text, 1, start)
                }
                { line = strip_comment($0) }
                !joining && (start = index(line, "\\documentclass")) { joining = 1; line = substr(line, start) }
                joining {
                    text = text " " line
                    if (match(text, /\\documentclass[[:space:]]*(\[[^]]*\])?[[:space:]]*\{[^}]*\}/)) {
                        text = substr(text, RSTART, RLENGTH)
                        options = ""
                        if (match(text, /\[[^]]*\]/)) options = substr(text, RSTART + 1, RLENGTH - 2)
                        match(text, /\{[^}]*\}$/)
                        name = substr(text, RSTART + 1, RLENGTH - 2)
                        gsub(/[[:space:]]/, "", name)
                        printf "%s\t%s\n", name, options
                        exit
                    }
                    if (++joined > 40) exit
                }
            ' "${MAIN_TEX}")"
            CLASS_NAME="${CLASS_INFO%%$'\t'*}"
            CLASS_OPTIONS="${CLASS_INFO#*$'\t'}"
            ZH_OPTION='(^|[^a-z])(zh|chinese)([^a-z]|$)'
            if [[ -z "${CLASS_NAME}" ]]; then
                log "${MAIN_TEX#"${ROOT_DIR}"/} has no \\documentclass lint can read; its language option is not checked."
            elif [[ "${CLASS_NAME##*/}" != story ]]; then
                log "${MAIN_TEX#"${ROOT_DIR}"/} loads the class ${CLASS_NAME}, not STORY's; its language option is not checked."
            elif [[ "${DISSERTATION_LANG}" == zh && ! "${CLASS_OPTIONS}" =~ ${ZH_OPTION} ]]; then
                warn "dissertation_language is zh but ${MAIN_TEX#"${ROOT_DIR}"/} does not load the class with the zh option."
            elif [[ "${DISSERTATION_LANG}" == en && "${CLASS_OPTIONS}" =~ ${ZH_OPTION} ]]; then
                warn "dissertation_language is en but ${MAIN_TEX#"${ROOT_DIR}"/} loads the class with the zh option."
            fi
            ;;
        "")
            warn 'dissertation_language is unset in degree/profile.tex; confirm en or zh.'
            ;;
        *)
            hard "invalid dissertation_language '${DISSERTATION_LANG}' in degree/profile.tex; expected en or zh."
            ;;
    esac
fi

if [[ ! -s degree/profile.tex ]]; then
    warn 'degree/profile.tex is absent or empty.'
fi

if [[ -f degree/requirements.md ]]; then
    OPEN_ROWS="$(grep -cE '^[[:space:]]*- \[ \]' degree/requirements.md || true)"
    if (( ${OPEN_ROWS:-0} > 0 )); then
        warn "${OPEN_ROWS} unresolved row(s) in degree/requirements.md; a deposit needs every row resolved."
    fi
fi

# A chapter file the entry point never inputs is drafted but absent from the
# PDF, and nothing else notices: the build succeeds and every count looks fine.
if [[ "${MAIN_DIR}" == "${ROOT_DIR}/manus" ]]; then
    for chapter in manus/chaps/*.tex; do
        [[ -f "${chapter}" ]] || continue
        if ! awk -v base="$(basename -- "${chapter}" .tex)" '
            { line = $0; sub(/(^|[^\\])%.*/, "", line) }
            line ~ ("\\\\(input|include)[[:space:]]*\\{[[:space:]]*chaps/" base "(\\.tex)?[[:space:]]*\\}") { found = 1; exit }
            END { exit !found }
        ' "${MAIN_TEX}"; then
            warn "${MAIN_TEX#"${ROOT_DIR}"/} does not \\input ${chapter}; the built PDF omits it."
        fi
    done
fi

# The page limit comes from the active milestone — the one milestone.yml whose
# status is active, a standing supervision record aside — and otherwise from
# the profile. A thesis from before milestone status carried this may still name
# it as active_milestone in notes/story.md, which is read only as a fallback.
max_pages_of() {
    awk '{
        line = $0
        sub(/^[[:space:]]*%?[[:space:]]*/, "", line)
        if (line !~ /^max_pages:/) next
        sub(/^max_pages:[[:space:]]*/, "", line)
        sub(/[[:space:]]*#.*$/, "", line)
        gsub(/["\047[:space:]]/, "", line)
        print line
        exit
    }' "$1"
}
yml_value() {
    awk -v key="$2" '{
        line = $0
        if (line !~ ("^" key ":")) next
        sub("^" key ":[[:space:]]*", "", line)
        sub(/[[:space:]]*#.*$/, "", line)
        gsub(/["\047[:space:]]/, "", line)
        print line
        exit
    }' "$1"
}
limit=''
limit_source=''
take_limit() {
    local raw
    raw="$(max_pages_of "$1")"
    [[ -n "${raw}" ]] || return 1
    if [[ "${raw}" =~ ^[1-9][0-9]*$ ]]; then
        limit="${raw}"
        limit_source="$1"
        return 0
    fi
    warn "max_pages '${raw}' in $1 is not a positive integer; the page-limit check ignores it."
    return 1
}
active=''
active_count=0
for yml in milestones/*/milestone.yml; do
    [[ -f "${yml}" ]] || continue
    [[ "$(yml_value "${yml}" status)" == active ]] || continue
    [[ "$(yml_value "${yml}" kind)" != supervision ]] || continue
    active_count=$((active_count + 1))
    active="$(basename -- "$(dirname -- "${yml}")")"
done
if (( active_count > 1 )); then
    warn "${active_count} milestones have status: active; exactly one may be active, so none of their page limits is applied."
    active=''
elif (( active_count == 0 )) && [[ -f notes/story.md ]]; then
    active="$(awk '/^active_milestone:/ { sub(/^active_milestone:[[:space:]]*/, ""); gsub(/["\047[:space:]]/, ""); print; exit }' notes/story.md)"
fi
if [[ -n "${active}" && -f "milestones/${active}/milestone.yml" ]]; then
    take_limit "milestones/${active}/milestone.yml" || true
fi
if [[ -z "${limit}" && -s degree/profile.tex ]]; then
    take_limit degree/profile.tex || true
fi
if [[ "${BUILD_USABLE}" == true && -n "${limit}" && -f "${PDF_FILE}" ]]; then
    pages=''
    if command -v pdfinfo >/dev/null 2>&1; then
        # An unreadable PDF must not end lint under pipefail before its Result line.
        pages="$(pdfinfo "${PDF_FILE}" 2>/dev/null | awk '/^Pages:/ {print $2}' || true)"
    fi
    # Without pdfinfo, the engine's "Output written on ... (N pages" line is the
    # fallback; TeX wraps long log lines, so the path may push the count onto
    # the next line or two.
    if [[ ! "${pages}" =~ ^[0-9]+$ && -f "${LOG_FILE}" ]]; then
        pages="$(awk '
            /^Output written on / { text = ""; joining = 1; joined = 0 }
            joining {
                text = text $0
                if (match(text, /\([0-9]+ pages?[,)]/)) {
                    count = substr(text, RSTART + 1)
                    sub(/ .*/, "", count)
                    joining = 0
                } else if (++joined > 3) {
                    joining = 0
                }
            }
            END { print count }
        ' "${LOG_FILE}" || true)"
    fi
    if [[ ! "${pages}" =~ ^[0-9]+$ ]]; then
        warn "page limit ${limit} (${limit_source}) not checked: the page count could not be read (install pdfinfo)."
    elif (( pages > limit )); then
        hard "${pages} pages exceeds the confirmed limit ${limit} (${limit_source}); it counts every PDF page, so a limit with exclusions belongs in degree/requirements.md instead."
    else
        log "Page limit: ${pages}/${limit} (${limit_source})."
    fi
fi

# fmt.sh --check distinguishes drift (1) from a refused rewrite or a latexindent
# failure (2) and a missing tool (3); only drift is fixable by running fmt.sh again.
FMT_RC=0
bash execs/scpts/fmt.sh --check >/dev/null 2>&1 || FMT_RC=$?
case "${FMT_RC}" in
    0) ;;
    1) warn 'manuscript is not in one-sentence-per-line format; run bash execs/scpts/fmt.sh.' ;;
    3) log 'Format check skipped: latexindent (or its config) is unavailable.' ;;
    *) warn "fmt.sh --check could not verify formatting (exit ${FMT_RC}); run bash execs/scpts/fmt.sh --check for details." ;;
esac

if command -v texcount >/dev/null 2>&1; then
    WORDS="$(cd "${MAIN_DIR}" && TEXINPUTS="${ROOT_DIR}/manus/stys:${TEXINPUTS:-}" texcount -inc -sum -1 "$(basename -- "${MAIN_TEX}")" 2>/dev/null | tail -1 || true)"
    [[ "${WORDS}" =~ ^[0-9]+$ ]] && log "Approximate words: ${WORDS}."
fi

if (( HARD > 0 )); then
    log "Result: ${HARD} hard failure(s), ${WARNS} warning(s)."
    exit 1
fi
log "Result: pass with ${WARNS} warning(s)."
