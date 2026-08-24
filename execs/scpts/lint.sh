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

check_prose_patterns

DEGREE_LEVEL="$(sed -nE 's/^[[:space:]]*%[[:space:]]*degree_level:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex 2>/dev/null | tail -1)"
case "${DEGREE_LEVEL}" in
    master|doctoral)
        log "Degree level: ${DEGREE_LEVEL}."
        ;;
    "")
        warn 'degree_level is unset in degree/profile.tex; confirm master or doctoral before level-specific review.'
        ;;
    *)
        hard "invalid degree_level '${DEGREE_LEVEL}' in degree/profile.tex; expected master or doctoral."
        ;;
esac

PROFILE_DISPLAY="$(grep -E '^[[:space:]]*\\(title|degree)\{' degree/profile.tex 2>/dev/null || true)"
if [[ "${DEGREE_LEVEL}" == master ]] && grep -Eqi 'Doctor(al)?|博士' <<< "${PROFILE_DISPLAY}"; then
    hard 'master degree_level conflicts with doctoral wording in the title or degree field.'
elif [[ "${DEGREE_LEVEL}" == doctoral ]] && grep -Eqi 'Master([^a-z]|$)|硕士' <<< "${PROFILE_DISPLAY}"; then
    hard 'doctoral degree_level conflicts with master wording in the title or degree field.'
fi

if grep -Eq 'Untitled Thesis|Degree Name|未命名学位论文|学位名称|University Name|Author Name|Advisor Name|Graduation Date' degree/profile.tex; then
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
