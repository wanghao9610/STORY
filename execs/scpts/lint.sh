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

# Awk functions every check that reads TeX puts in front of its program.
# strip_comment drops a line's comment: a % starts one after an even run of
# backslashes, none included, so \\% is a line break and then a comment, and \%
# a percent sign. A \verb|...| span on the line becomes one space, since a % or
# an include inside it is typeset as it stands; it sets comment_cut when it
# dropped a comment. tex_line is what TeX reads of one input line: its leading
# spaces and tabs skipped, and its end joining it to the next line with nothing
# when a comment was stripped, and otherwise, trailing spaces dropped, with one
# space. physical_lines splits a record at a lone CR as well, since TeX ends a
# line at CR, LF, or CRLF, and awk splits only at LF. Other verbatim text (a
# verbatim environment, a % inside \url) is still read as TeX.
TEX_AWK='
function strip_comment(text,    kept, piece, delimiter, rest, end) {
    comment_cut = 0
    kept = ""
    while (1) {
        if (substr(text, 1, 1) == "%") { comment_cut = 1; return kept }
        if (!match(text, /(^|[^\\])(\\\\)*(%|\\verb[*]?[^*[:alpha:][:space:]])/)) return kept text
        piece = substr(text, RSTART, RLENGTH)
        if (piece !~ /\\verb[*]?[^*[:alpha:][:space:]]$/) {
            comment_cut = 1
            return kept substr(text, 1, RSTART + RLENGTH - 2)
        }
        delimiter = substr(piece, length(piece), 1)
        kept = kept substr(text, 1, RSTART + index(piece, "\\verb") - 2) " "
        rest = substr(text, RSTART + RLENGTH)
        end = index(rest, delimiter)
        if (!end) return kept
        text = substr(rest, end + 1)
    }
}
function tex_line(text,    kept) {
    sub(/\r$/, "", text)
    sub(/^[ \t]+/, "", text)
    kept = strip_comment(text)
    if (comment_cut) return kept
    sub(/[ \t]+$/, "", kept)
    return kept " "
}
function physical_lines(text, parts,    count) {
    sub(/\r$/, "", text)
    count = split(text, parts, "\r")
    if (count == 0) { parts[1] = ""; count = 1 }
    return count
}
'

# Under a UTF-8 locale a byte that is not UTF-8 stops macOS awk (towc:
# multibyte conversion failure) and sed (illegal byte sequence), and makes grep
# skip its line, so lint would end without a verdict or miss what it counts. A
# check of TeX syntax or of the build log matches ASCII only and reads with
# LC_ALL=C. A check of a value the author typed (the profile, a milestone
# record) keeps the caller's locale for a valid file, whose [[:space:]] also
# takes a full-width space, and reads any other file byte by byte (meta_lc),
# with one warning. The prose review matches Chinese on purpose, so it skips,
# by name, a file that is not UTF-8. utf8_valid asks iconv, when iconv rejects
# a byte that is not UTF-8, else perl, and then awk and sed in the caller's
# locale: macOS iconv takes a sequence past U+10FFFF that macOS awk and sed
# reject, and with neither iconv nor perl the two probes alone decide.
UTF8_TOOL=none
if command -v iconv >/dev/null 2>&1 \
    && printf 'caf\303\251\n' | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1 \
    && ! printf 'caf\351\n' | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1; then
    UTF8_TOOL=iconv
elif command -v perl >/dev/null 2>&1; then
    UTF8_TOOL=perl
fi
utf8_valid() {
    case "${UTF8_TOOL}" in
        iconv)
            iconv -f UTF-8 -t UTF-8 2>/dev/null < "$1" >/dev/null || return 1 ;;
        perl)
            perl -MEncode -e 'local $/; my $s = <STDIN>; $s = "" unless defined $s;
                    eval { Encode::decode("UTF-8", $s, Encode::FB_CROAK); 1 } or exit 1' 2>/dev/null < "$1" || return 1 ;;
    esac
    awk '{ sub(/^[[:space:]]+/, "") }' 2>/dev/null < "$1" >/dev/null \
        && sed -nE 's/^[[:space:]]*x(.*)$/\1/p' 2>/dev/null < "$1" >/dev/null
}
# has_nul FILE — whether FILE holds a NUL byte, as UTF-16 and UTF-32 text does:
# its ASCII letters are NUL-separated, so no TeX check can match them.
has_nul() {
    local count
    count="$(LC_ALL=C tr -cd '\000' 2>/dev/null < "$1" | LC_ALL=C wc -c | LC_ALL=C tr -d '[:space:]' || true)"
    (( ${count:-0} > 0 ))
}
# meta_lc FILE — sets META_LC to the LC_ALL to read FILE with: the caller's own
# for valid UTF-8 (empty when unset, which every program reads as unset), C for
# any other file, which draws one warning the first time. It runs in lint's own
# shell, never inside $(...), so the warning counts.
META_WARNED=$'\n'
META_LC=''
meta_lc() {
    if utf8_valid "$1"; then
        META_LC="${LC_ALL-}"
        return 0
    fi
    META_LC=C
    case "${META_WARNED}" in
        *$'\n'"$1"$'\n'*) return 0 ;;
    esac
    META_WARNED="${META_WARNED}$1"$'\n'
    warn "$1 is not valid UTF-8, so lint read it byte by byte; save it as UTF-8."
}

check_prose_patterns() {
    local file file_output prose_output='' location patterns snippet program
    local prose_count=0 prose_rc stopped=0 skipped=0
    local -a prose_files=()

    # A file the \todo count could not read is named there already. The
    # Chinese patterns need the UTF-8 locale, so a file that is not UTF-8 is
    # left out of the scan, by name, rather than read as bytes.
    while IFS= read -r file; do
        [[ -n "${file}" ]] || continue
        case "${UNREAD_TEX}" in
            *$'\n'"${file}"$'\n'*) skipped=$((skipped + 1)); continue ;;
        esac
        if [[ ! -r "${file}" ]]; then
            warn "${file} cannot be read, so its prose went unreviewed."
            skipped=$((skipped + 1))
        elif utf8_valid "${file}"; then
            prose_files+=("${file}")
        else
            warn "${file} is not valid UTF-8, so its prose went unreviewed; save it as UTF-8."
            skipped=$((skipped + 1))
        fi
    done < <(find manus/fronts manus/chaps manus/backs -type f -name '*.tex' -print 2>/dev/null | sort)

    if (( ${#prose_files[@]} == 0 )); then
        (( skipped > 0 )) || log 'Prose review: no front-matter, chapter, or back-matter TeX files found.'
        return
    fi

    program="${TEX_AWK}"'
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
    '
    # One awk per file, so a byte no validator caught, or a locale that is not
    # UTF-8, stops the review of that file alone, and the warning names it.
    for file in "${prose_files[@]}"; do
        prose_rc=0
        file_output="$(awk "${program}" "${file}")" || prose_rc=$?
        if (( prose_rc != 0 )); then
            warn "the prose review of ${file} stopped early (awk exit ${prose_rc}), so part of it went unreviewed."
            stopped=$((stopped + 1))
        fi
        [[ -z "${file_output}" ]] || prose_output="${prose_output}${file_output}"$'\n'
    done

    if [[ -z "${prose_output}" ]]; then
        (( stopped > 0 )) || log 'Prose review: no high-confidence chatbot residue or clustered formulaic prose found.'
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

# A directory lists identically in git/ls (byte order) and in VS Code, Overleaf and Finder
# (numeric collation) iff  LC_ALL=C sort  ==  natural_key_sort  over its names, PROVIDED the
# names follow the grammar and no two differ only in a number's leading zeros (validated
# against the real collators; an underscore inside a slug is the one grammar case this model
# misses, and the grammar check catches it; natural_key_ties catches the leading zeros,
# 03_seed1.pdf beside 03_seed01.pdf, which the two sorts agree on and Finder orders the
# other way). Every awk, grep, and sed in these checks runs with LC_ALL=C: under a UTF-8
# locale, macOS awk aborts on a byte that is not UTF-8 (towc: multibyte conversion failure),
# and the includes after it would go unchecked without a word.
natural_key_sort() {
    LC_ALL=C awk '{
        s = $0; k = ""
        while (match(s, /[0-9]+/)) {
            d = substr(s, RSTART, RLENGTH)
            while (length(d) < 20) d = "0" d
            k = k substr(s, 1, RSTART - 1) d
            s = substr(s, RSTART + RLENGTH)
        }
        printf "%s%s\t%s\n", k, s, $0
    }' | LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2 | LC_ALL=C cut -f2
}

# Names on stdin, one per line; prints the first two whose natural_key_sort keys
# are equal, tab-separated: names that differ only in a number's leading zeros.
natural_key_ties() {
    LC_ALL=C awk '{
        s = $0; k = ""
        while (match(s, /[0-9]+/)) {
            d = substr(s, RSTART, RLENGTH)
            while (length(d) < 20) d = "0" d
            k = k substr(s, 1, RSTART - 1) d
            s = substr(s, RSTART + RLENGTH)
        }
        k = k s
        if (k in seen) { print seen[k] "\t" $0; exit }
        seen[k] = $0
    }'
}

# Names in one managed directory, byte-sorted. A symlink lists as a file does,
# since git tracks it and a file browser shows it. Hidden files (.gitkeep,
# .DS_Store) are skipped, and so, in a git work tree, is every name git ignores
# (a latexindent backup, an in-tree .aux), since git never lists it. $2 is
# "files", or "all" where a directory is also an entry. The caller has checked
# that the directory can be read.
manuscript_names() {
    local listed ignored
    [[ -d "$1" ]] || return 0
    if [[ "$2" == files ]]; then
        listed="$(find "$1" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) ! -name '.*' 2>/dev/null | LC_ALL=C sort || true)"
    else
        listed="$(find "$1" -mindepth 1 -maxdepth 1 \( -type f -o -type d -o -type l \) ! -name '.*' 2>/dev/null | LC_ALL=C sort || true)"
    fi
    [[ -n "${listed}" ]] || return 0
    if [[ "${IN_GIT_TREE:-false}" == true ]]; then
        ignored="$(printf '%s\n' "${listed}" | LC_ALL=C tr '\n' '\0' | git check-ignore -z --stdin 2>/dev/null | LC_ALL=C tr '\0' '\n' || true)"
        if [[ -n "${ignored}" ]]; then
            listed="$(printf '%s\n' "${listed}" | LC_ALL=C grep -vxF -f <(printf '%s\n' "${ignored}") || true)"
        fi
    fi
    [[ -n "${listed}" ]] || return 0
    printf '%s\n' "${listed}" | LC_ALL=C sed 's#.*/##' | LC_ALL=C sort
}

# readable_sources FIND-ARGS... — the paths find prints for FIND-ARGS that name
# a readable regular file, a symlink to one included, one per line, byte-sorted.
# A broken link or a file lint may not read would stop the one awk that reads
# them all, and every file after it would go unchecked without a word.
readable_sources() {
    local path
    while IFS= read -r path; do
        if [[ -n "${path}" && -f "${path}" && -r "${path}" ]]; then
            printf '%s\n' "${path}"
        fi
    done <<< "$(find "$@" 2>/dev/null | LC_ALL=C sort || true)"
}

# Conventions §5 (Manuscript file names): every file under the directories below
# is <key>_<slug>.<ext>, and a figure, its source, and a table take the key of
# the one chapter or appendix file that includes them, or the zero key for front
# matter. Names are directory facts, so this needs no build and reads manus/
# whatever the entry point; lint runs it before the build, so neither a failed
# or missing build nor a later check that stops lint hides what it found.
check_file_names() {
    local slug='[a-z][a-z0-9]*(-[a-z0-9]+)*'
    local warns_before="${WARNS}" dir pattern expected name names natural diverge pair mixed
    local chapter_keys=' ' appendix_keys=' ' zero_key='00' one_digit_keys='^ ([0-9] )+$'
    local key includer includer_key kind target base asset candidate matches
    local seen_includes=$'\n'
    local width first_name first_width graphicspath_figs=false IN_GIT_TREE=false
    local -a dirs=(manus/chaps manus/backs manus/figs manus/figs/srcs manus/tabs)
    local -a modes=(files files files all files)
    local -a readable=(true true true true true)
    local -a patterns=(
        "^[0-9]{1,2}_${slug}\\.tex\$"
        "^[a-z]_${slug}\\.tex\$"
        "^([0-9]{1,2}|[a-z])_${slug}(\\.[a-z0-9]+)+\$"
        "^([0-9]{1,2}|[a-z])_${slug}(\\.[a-z0-9]+)*\$"
        "^([0-9]{1,2}|[a-z])_${slug}\\.tex\$"
    )
    local -a expects=('<nn>_<slug>.tex' '<letter>_<slug>.tex' '<owner>_<slug>.<ext>' '<owner>_<slug> or <owner>_<slug>.<ext>' '<owner>_<slug>.tex')
    local -a listings=() includers=() sources=()
    local i

    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        IN_GIT_TREE=true
    fi
    # A directory lint cannot list draws one warning, and the keys it would
    # hold are unknown rather than missing: no asset is called ownerless, and
    # no front-matter include is judged, for want of a chapter directory.
    for i in 0 1 2 3 4; do
        dir="${dirs[i]}"
        if [[ -d "${dir}" && ! ( -r "${dir}" && -x "${dir}" ) ]]; then
            warn "${dir} cannot be read, so its file names went unchecked (conventions §5)."
            readable[i]=false
            listings[i]=''
            continue
        fi
        listings[i]="$(manuscript_names "${dir}" "${modes[i]}" || true)"
    done
    if [[ -d manus/fronts && ! ( -r manus/fronts && -x manus/fronts ) ]]; then
        warn "manus/fronts cannot be read, so the keys of the assets it includes went unchecked (conventions §5)."
    fi

    # 1. Grammar.
    for i in 0 1 2 3 4; do
        dir="${dirs[i]}"; pattern="${patterns[i]}"; expected="${expects[i]}"
        while IFS= read -r name; do
            [[ -n "${name}" ]] || continue
            if [[ "${name}" =~ ${pattern} ]]; then
                continue
            fi
            warn "file name ${dir}/${name} is not ${expected} (conventions §5): one '_' after the key, a slug of lowercase letters and digits that starts with a letter and joins its words with '-', and lowercase extensions."
        done <<< "${listings[i]}"
    done

    # 2. Order: git and ls sort bytes, VS Code, Overleaf, and Finder sort numbers.
    # Where the two orders agree, keys of two widths still break the one-width
    # rule (1_intro.tex beside 01_intro.tex), and two names that differ only in
    # a leading zero inside a slug (03_seed1.pdf, 03_seed01.pdf) list
    # differently in Finder.
    for i in 0 1 2 3 4; do
        dir="${dirs[i]}"; names="${listings[i]}"
        [[ -n "${names}" ]] || continue
        natural="$(printf '%s\n' "${names}" | natural_key_sort)"
        if [[ "${names}" != "${natural}" ]]; then
            diverge="$(LC_ALL=C awk 'NR == FNR { a[FNR] = $0; next } a[FNR] != $0 { print a[FNR] "\t" $0; exit }' \
                <(printf '%s\n' "${names}") <(printf '%s\n' "${natural}"))"
            warn "file names in ${dir}/ sort differently: git and ls list ${diverge%%$'\t'*} before ${diverge#*$'\t'}, but VS Code, Overleaf, and Finder list ${diverge#*$'\t'} first; give every key in the directory one width and zero-pad digit runs inside slugs (conventions §5)."
            continue
        fi
        first_name=''; first_width=''; mixed=false
        while IFS= read -r name; do
            [[ "${name}" =~ ^([0-9]+)_ ]] || continue
            width="${#BASH_REMATCH[1]}"
            if [[ -z "${first_width}" ]]; then
                first_name="${name}"; first_width="${width}"
            elif [[ "${width}" != "${first_width}" ]]; then
                warn "file names in ${dir}/ mix key widths: ${first_name} has a ${first_width}-digit key and ${name} a ${width}-digit key; give every key in the directory one width (conventions §5)."
                mixed=true
                break
            fi
        done <<< "${names}"
        [[ "${mixed}" == false ]] || continue
        pair="$(printf '%s\n' "${names}" | natural_key_ties)"
        if [[ -n "${pair}" ]]; then
            warn "file names in ${dir}/ sort differently in Finder than in git and ls: ${pair%%$'\t'*} and ${pair#*$'\t'} differ only in a number's leading zeros; zero-pad every digit run inside a slug to one width across the directory (conventions §5)."
        fi
    done

    # 3. Owner exists: a chapter's numeric key, an appendix's letter, or the
    # zero key of front matter, 0 in a thesis whose chapter keys are one digit.
    while IFS= read -r name; do
        if [[ "${name}" =~ ^([0-9]{1,2})_.*\.tex$ ]]; then
            chapter_keys="${chapter_keys}${BASH_REMATCH[1]} "
        fi
    done <<< "${listings[0]}"
    while IFS= read -r name; do
        if [[ "${name}" =~ ^([a-z])_.*\.tex$ ]]; then
            appendix_keys="${appendix_keys}${BASH_REMATCH[1]} "
        fi
    done <<< "${listings[1]}"
    if [[ "${chapter_keys}" =~ ${one_digit_keys} ]]; then
        zero_key='0'
    fi
    for i in 2 3 4; do
        dir="${dirs[i]}"
        while IFS= read -r name; do
            [[ "${name}" =~ ^([0-9]{1,2}|[a-z])_ ]] || continue
            key="${BASH_REMATCH[1]}"
            case "${chapter_keys}${appendix_keys# } " in
                *" ${key} "*) continue ;;
            esac
            if [[ "${key}" == 0 || "${key}" == 00 ]]; then
                continue
            fi
            case "${key}" in
                [0-9]*) [[ "${readable[0]}" == true ]] || continue ;;
                *) [[ "${readable[1]}" == true ]] || continue ;;
            esac
            warn "file name ${dir}/${name} has no owner: its key ${key} names no chapter in manus/chaps/, appendix in manus/backs/, or front matter (${zero_key}); give it the key of the one file that includes it (conventions §5)."
        done <<< "${listings[i]}"
    done

    # 4. Includer matches: an include whose target under figs/ or tabs/ starts
    # with a key names the including file's key. A symlinked includer counts
    # as the file it points to. A bare \includegraphics name counts as figs/
    # only when a \graphicspath lists figs/. Both are read from each file's
    # lines joined as TeX joins them (tex_line), so an include or a
    # \graphicspath may span lines and a comment may split a name
    # ({figs/%<newline>01_x}); a \graphicspath, whose argument a blank line
    # would end, is looked for one paragraph at a time. An option value may
    # hold a ']' inside braces ([alt={A [b] c}]).
    while IFS= read -r name; do
        if [[ -n "${name}" ]]; then
            includers+=("${name}")
        fi
    done <<< "$(readable_sources manus/chaps manus/backs manus/fronts -mindepth 1 -maxdepth 1 \( -type f -o -type l \) -name '*.tex' ! -name '.*')"
    if (( ${#includers[@]} > 0 )); then
        while IFS= read -r name; do
            if [[ -n "${name}" ]]; then
                sources+=("${name}")
            fi
        done <<< "$(readable_sources manus -maxdepth 2 \( -type f -o -type l \) \( -name '*.tex' -o -name '*.sty' -o -name '*.cls' \))"
        if (( ${#sources[@]} > 0 )) && LC_ALL=C awk "${TEX_AWK}"'
                function scan() {
                    if (buffer ~ /\\graphicspath[[:space:]]*\{[[:space:]]*(\{[^{}]*\}[[:space:]]*)*\{(\.\/)?figs\/?\}/) found = 1
                    buffer = ""
                }
                found { exit }
                FNR == 1 { scan() }
                { line = tex_line($0) }
                line == " " { scan(); next }
                { buffer = buffer line }
                END { scan(); exit !found }' "${sources[@]}" 2>/dev/null; then
            graphicspath_figs=true
        fi
        while IFS=$'\t' read -r includer kind target; do
            [[ -n "${includer}" ]] || continue
            target="${target#./}"
            case "${target}" in
                figs/*|tabs/*) ;;
                */*|'') continue ;;
                *)
                    [[ "${kind}" == g && "${graphicspath_figs}" == true ]] || continue
                    target="figs/${target}"
                    ;;
            esac
            base="${target##*/}"
            [[ "${base%%.*}" =~ ^([0-9]{1,2}|[a-z])_ ]] || continue
            key="${BASH_REMATCH[1]}"
            name="${includer##*/}"
            case "${includer}" in
                manus/chaps/*) [[ "${name}" =~ ^([0-9]{1,2})_ ]] || continue; includer_key="${BASH_REMATCH[1]}" ;;
                manus/backs/*) [[ "${name}" =~ ^([a-z])_ ]] || continue; includer_key="${BASH_REMATCH[1]}" ;;
                *) [[ "${readable[0]}" == true ]] || continue; includer_key="${zero_key}" ;;
            esac
            [[ "${key}" != "${includer_key}" ]] || continue
            # Name the file on disk: \input adds .tex, and \includegraphics
            # finds the one file whose name adds an extension. A target that
            # matches no file, or several, is named as written.
            asset="manus/${target}"
            if [[ "${kind}" == i && "${target}" != *.tex && -f "${asset}.tex" ]]; then
                asset="${asset}.tex"
            elif [[ ! -f "${asset}" && "${kind}" == g ]]; then
                matches=0
                for candidate in "${asset}".*; do
                    if [[ -f "${candidate}" ]]; then
                        matches=$((matches + 1)); base="${candidate}"
                    fi
                done
                if (( matches == 1 )); then
                    asset="${base}"
                fi
            fi
            # One warning per file an includer names, however many includes
            # (with and without the extension) name it.
            case "${seen_includes}" in
                *$'\n'"${includer}"$'\t'"${asset}"$'\n'*) continue ;;
            esac
            seen_includes="${seen_includes}${includer}"$'\t'"${asset}"$'\n'
            base="${asset##*/}"
            warn "file name ${asset} does not carry the key of ${includer}, which includes it: expected key ${includer_key} (${includer_key}_${base#*_}), since an asset takes the key of the one file that includes it (conventions §5)."
        done <<< "$(LC_ALL=C awk "${TEX_AWK}"'
            function flush(    command, kind, target) {
                while (match(buffer, /\\(includegraphics[*]?([[:space:]]*\[([^]{}]|\{[^}]*\})*\])*|input)[[:space:]]*\{[^}]*\}/)) {
                    command = substr(buffer, RSTART, RLENGTH)
                    buffer = substr(buffer, RSTART + RLENGTH)
                    kind = (command ~ /^\\includegraphics/) ? "g" : "i"
                    match(command, /\{[^}]*\}$/)
                    target = substr(command, RSTART + 1, RLENGTH - 2)
                    gsub(/[[:space:]]+/, " ", target)
                    gsub(/^ | $/, "", target)
                    printf "%s\t%s\t%s\n", current_file, kind, target
                }
                buffer = ""
            }
            FNR == 1 {
                if (NR > 1) flush()
                current_file = FILENAME
            }
            { buffer = buffer tex_line($0) }
            END { flush() }
        ' "${includers[@]}")"
    fi

    if (( WARNS == warns_before )); then
        log 'File names: manus/chaps, backs, figs, figs/srcs, and tabs follow the owner-key scheme and list in the same order everywhere (conventions §5).'
    fi
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
    val="$(LC_ALL=C sed -n "s/^[[:space:]]*${key}=//p" "${ENV_FILE}" | tail -1)"
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
# An entry point lint cannot read has no class option or chapter input to
# check; the build, if lint runs one, fails on it too.
MAIN_READ=true
if [[ ! -r "${MAIN_TEX}" ]]; then
    hard "the entry point ${MAIN_TEX#"${ROOT_DIR}"/} cannot be read, so none of its text was checked, its class option, chapter inputs, and \\todo markers included."
    MAIN_READ=false
fi
# File names read only the tree under manus/, so they are checked before the
# build: a failed or missing build, or a later check that stops lint, cannot
# keep their warnings from printing.
check_file_names
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
elif LC_ALL=C grep -q '^!' "${LOG_FILE}"; then
    hard "the last build stopped on a LaTeX error (see ${LOG_FILE}); rebuild with bash execs/run.sh."
    BUILD_USABLE=false
else
    # find fails on a directory it cannot read (reported by check_file_names)
    # or a missing degree/; under pipefail that must not end lint here.
    STALE_SOURCES="$(find manus degree -type f \( -name '*.tex' -o -name '*.bib' -o -name '*.cls' -o -name '*.sty' -o -name '*.bst' \) \
        -newer "${PDF_FILE}" 2>/dev/null | wc -l | tr -d '[:space:]' || true)"
    if (( ${STALE_SOURCES:-0} > 0 )); then
        warn "${STALE_SOURCES} source file(s) under manus/ or degree/ are newer than the PDF; rebuild before trusting its page and reference checks."
    fi
fi

if [[ "${BUILD_USABLE}" == true && -f "${LOG_FILE}" ]]; then
    if LC_ALL=C grep -Eqi 'undefined citations|Citation .* undefined|There were undefined references|Reference .* undefined' "${LOG_FILE}"; then
        hard 'undefined citation or cross-reference reported by LaTeX.'
    fi
    OVERFULL="$(LC_ALL=C grep -Ec 'Overfull \\hbox' "${LOG_FILE}" || true)"
    (( OVERFULL == 0 )) || warn "${OVERFULL} overfull hbox warning(s)."
    # A glyph the fonts lack is dropped from the PDF, yet the build still succeeds.
    MISSING_CHARS="$(LC_ALL=C grep -c 'Missing character: There is no' "${LOG_FILE}" || true)"
    (( MISSING_CHARS == 0 )) || warn "the build log reports ${MISSING_CHARS} missing character(s): text in a script the fonts cannot typeset, such as Chinese without the cjk class option."
fi

# Every .tex under manus/ is searched for visible \todo markers as TeX reads
# it (tex_line), so a marker whose argument opens on a later line counts, and
# the tail of a line that may begin one (a control word and spaces) is carried
# to the next; every marker counts, several on one line included. The count
# matches ASCII only, so it reads bytes: under a UTF-8 locale a stray byte would
# stop awk. The deposit gate needs a verified zero, so a directory or file lint
# cannot read, a file in UTF-16 or UTF-32 (whose NUL bytes hide every marker),
# or an awk that stops fails lint rather than counting as none.
UNREAD_TEX=$'\n'
TODO_FILES=()
while IFS= read -r path; do
    [[ -n "${path}" ]] || continue
    if [[ -d "${path}" ]]; then
        if [[ ! ( -r "${path}" && -x "${path}" ) ]]; then
            hard "${path} cannot be read, so the \\todo markers in it were not counted."
        fi
    elif [[ ! -f "${path}" ]]; then
        continue
    elif [[ ! -r "${path}" ]]; then
        # An entry point lint cannot read has failed once already.
        if [[ "${ROOT_DIR}/${path}" != "${MAIN_TEX}" ]]; then
            hard "${path} cannot be read, so none of its text was checked, its \\todo markers included."
        fi
        UNREAD_TEX="${UNREAD_TEX}${path}"$'\n'
    elif has_nul "${path}"; then
        hard "${path} holds NUL bytes, as UTF-16 and UTF-32 text does, so none of its text was checked, its \\todo markers included; save it as UTF-8."
        UNREAD_TEX="${UNREAD_TEX}${path}"$'\n'
    else
        TODO_FILES+=("${path}")
    fi
done <<< "$(find manus \( -type d -o \( -type f -o -type l \) -name '*.tex' \) -print 2>/dev/null | LC_ALL=C sort || true)"
# The status scan (story-flow-status scripts/scan.sh) counts with the same
# TEX_AWK and TODO_AWK text; check_consistency.sh keeps the copies identical.
TODO_AWK='
function take(line) {
    if (line == " ") { carry = ""; return }
    carry = carry line
    n += gsub(/\\todo[[:space:]]*\{/, "", carry)
    if (match(carry, /\\[[:alpha:]]*[[:space:]]*$/)) carry = substr(carry, RSTART)
    else carry = ""
}
FNR == 1 { carry = "" }
{
    count = physical_lines($0, parts)
    for (i = 1; i <= count; i++) take(tex_line(parts[i]))
}
END { print n + 0 }
'
TODO_COUNT=0
if (( ${#TODO_FILES[@]} > 0 )); then
    TODO_RC=0
    TODO_COUNT="$(LC_ALL=C awk "${TEX_AWK}${TODO_AWK}" "${TODO_FILES[@]}" 2>/dev/null)" || TODO_RC=$?
    if (( TODO_RC != 0 )) || [[ ! "${TODO_COUNT}" =~ ^[0-9]+$ ]]; then
        hard "the \\todo count stopped early (awk exit ${TODO_RC}), so visible \\todo markers may remain under manus/."
        TODO_COUNT=0
    fi
fi
if (( TODO_COUNT > 0 )); then
    hard "${TODO_COUNT} visible \\todo marker(s) remain under manus/."
fi

check_prose_patterns

# The file-existence guard matters: a bare command substitution over a missing
# file fails the assignment under set -e and kills the script before the
# graceful absent-or-empty warning below can fire.
# The profile is what the author typed: a UTF-8 one keeps the caller's locale,
# so a full-width space after a value still reads as a space, and any other is
# read byte by byte, where Chinese in another encoding matches nothing. A
# profile lint cannot read fails: its level, language, and title page would
# otherwise pass unread. PROFILE_READ gates every read below.
DEGREE_LEVEL=""
PROFILE_LC="${LC_ALL-}"
PROFILE_READ=false
if [[ -s degree/profile.tex && ! -r degree/profile.tex ]]; then
    hard 'degree/profile.tex cannot be read, so its degree level, language, and title-page fields went unchecked.'
elif [[ -s degree/profile.tex ]]; then
    PROFILE_READ=true
    if ! utf8_valid degree/profile.tex; then
        PROFILE_LC=C
        META_WARNED="${META_WARNED}degree/profile.tex"$'\n'
        warn 'degree/profile.tex is not valid UTF-8, so Chinese in another encoding in its degree field and title-page placeholders went unchecked; save it as UTF-8.'
    fi
    DEGREE_LEVEL="$(LC_ALL="${PROFILE_LC}" sed -nE 's/^[[:space:]]*%[[:space:]]*degree_level:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex | tail -1)"
fi
case "${DEGREE_LEVEL}" in
    master|doctoral)
        log "Degree level: ${DEGREE_LEVEL}."
        ;;
    "")
        if [[ "${PROFILE_READ}" == true ]]; then
            warn 'degree_level is unset in degree/profile.tex; confirm master or doctoral before level-specific review.'
        fi
        ;;
    *)
        hard "invalid degree_level '${DEGREE_LEVEL}' in degree/profile.tex; expected master or doctoral."
        ;;
esac

# Only the degree field names the level: a title may use "Doctor" or "Master" as
# a subject word, and the run may not change an approved title.
DEGREE_FIELD=''
if [[ "${PROFILE_READ}" == true ]]; then
    DEGREE_FIELD="$(LC_ALL="${PROFILE_LC}" grep -E '^[[:space:]]*\\degree\{' degree/profile.tex 2>/dev/null || true)"
fi
if [[ "${DEGREE_LEVEL}" == master ]] && LC_ALL="${PROFILE_LC}" grep -Eqi 'Doctor(al)?|博士' <<< "${DEGREE_FIELD}"; then
    hard 'master degree_level conflicts with doctoral wording in the degree field.'
elif [[ "${DEGREE_LEVEL}" == doctoral ]] && LC_ALL="${PROFILE_LC}" grep -Eqi 'Master([^a-z]|$)|硕士' <<< "${DEGREE_FIELD}"; then
    hard 'doctoral degree_level conflicts with master wording in the degree field.'
fi

# Placeholders are read from compiled lines only: the profile's own comments name
# the fields they describe, and matching those would warn on every profile.
if [[ "${PROFILE_READ}" == true ]]; then
    PLACEHOLDERS="$(LC_ALL="${PROFILE_LC}" awk '
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
    if ! LC_ALL="${PROFILE_LC}" grep -Eq '^[[:space:]]*\\submissionstatement[[:space:]]*\{' degree/profile.tex; then
        warn 'title-page placeholder: degree/profile.tex sets no \submissionstatement, so the title page prints the class placeholder.'
    fi

    # Manuscript language and entry point must agree: a zh profile built by an
    # English entry point (or the reverse) typesets the wrong title page. Only
    # STORY's class takes the zh option, so an institutional class is named but
    # not checked. An option list may span lines: it is joined, comments
    # stripped, before it is read.
    DISSERTATION_LANG="$(LC_ALL="${PROFILE_LC}" sed -nE 's/^[[:space:]]*%[[:space:]]*dissertation_language:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' degree/profile.tex | tail -1)"
    case "${DISSERTATION_LANG}" in
        en|zh)
            CLASS_INFO=''
            [[ "${MAIN_READ}" == true ]] && CLASS_INFO="$(LC_ALL=C awk "${TEX_AWK}"'
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
            ' "${MAIN_TEX}" || true)"
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

if [[ -f degree/requirements.md && ! -r degree/requirements.md ]]; then
    warn 'degree/requirements.md cannot be read, so its unresolved rows went uncounted.'
elif [[ -f degree/requirements.md ]]; then
    meta_lc degree/requirements.md
    OPEN_ROWS="$(LC_ALL="${META_LC}" grep -cE '^[[:space:]]*- \[ \]' degree/requirements.md || true)"
    if (( ${OPEN_ROWS:-0} > 0 )); then
        warn "${OPEN_ROWS} unresolved row(s) in degree/requirements.md; a deposit needs every row resolved."
    fi
fi

# A chapter file the entry point never inputs is drafted but absent from the
# PDF, and nothing else notices: the build succeeds and every count looks fine.
# The entry point is read once, its lines joined as TeX joins them (tex_line),
# so an \input whose name a comment or a line break splits still counts; each
# \input and \include target is printed on its own line, its ends trimmed.
if [[ "${MAIN_DIR}" == "${ROOT_DIR}/manus" && "${MAIN_READ}" == true ]]; then
    MAIN_INPUTS="$(LC_ALL=C awk "${TEX_AWK}"'
        function flush(    command) {
            while (match(buffer, /\\(input|include)[[:space:]]*\{[^}]*\}/)) {
                command = substr(buffer, RSTART, RLENGTH)
                buffer = substr(buffer, RSTART + RLENGTH)
                match(command, /\{[^}]*\}$/)
                command = substr(command, RSTART + 1, RLENGTH - 2)
                sub(/^[[:space:]]+/, "", command)
                sub(/[[:space:]]+$/, "", command)
                print command
            }
            buffer = ""
        }
        {
            count = physical_lines($0, parts)
            for (i = 1; i <= count; i++) {
                line = tex_line(parts[i])
                if (line == " ") flush(); else buffer = buffer line
            }
        }
        END { flush() }
    ' "${MAIN_TEX}" || true)"
    for chapter in manus/chaps/*.tex; do
        [[ -f "${chapter}" ]] || continue
        base="$(basename -- "${chapter}" .tex)"
        case $'\n'"${MAIN_INPUTS}"$'\n' in
            *$'\n'"chaps/${base}"$'\n'*|*$'\n'"chaps/${base}.tex"$'\n'*) ;;
            *) warn "${MAIN_TEX#"${ROOT_DIR}"/} does not \\input ${chapter}; the built PDF omits it." ;;
        esac
    done
fi

# The page limit comes from the active milestone — the one milestone.yml whose
# status is active, a standing supervision record aside — and otherwise from
# the profile. A thesis from before milestone status carried this may still name
# it as active_milestone in notes/story.md, which is read only as a fallback.
# Each reads FILE in the locale meta_lc chose for it, passed as $2 or $3.
max_pages_of() {
    LC_ALL="$2" awk '{
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
    LC_ALL="$3" awk -v key="$2" '{
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
    local raw lc="${PROFILE_LC}"
    [[ -r "$1" ]] || return 1
    if [[ "$1" != degree/profile.tex ]]; then
        meta_lc "$1"
        lc="${META_LC}"
    fi
    raw="$(max_pages_of "$1" "${lc}")"
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
for yml in miles/*/milestone.yml; do
    [[ -f "${yml}" ]] || continue
    if [[ ! -r "${yml}" ]]; then
        warn "${yml} cannot be read, so whether it is active, and its page limit, went unchecked."
        continue
    fi
    meta_lc "${yml}"
    [[ "$(yml_value "${yml}" status "${META_LC}")" == active ]] || continue
    [[ "$(yml_value "${yml}" kind "${META_LC}")" != supervision ]] || continue
    active_count=$((active_count + 1))
    active="$(basename -- "$(dirname -- "${yml}")")"
done
if (( active_count > 1 )); then
    warn "${active_count} milestones have status: active; exactly one may be active, so none of their page limits is applied."
    active=''
elif (( active_count == 0 )) && [[ -f notes/story.md && ! -r notes/story.md ]]; then
    warn 'notes/story.md cannot be read, so its legacy active_milestone went unchecked.'
elif (( active_count == 0 )) && [[ -f notes/story.md ]]; then
    meta_lc notes/story.md
    active="$(LC_ALL="${META_LC}" awk '/^active_milestone:/ { sub(/^active_milestone:[[:space:]]*/, ""); gsub(/["\047[:space:]]/, ""); print; exit }' notes/story.md)"
fi
if [[ -n "${active}" && -f "miles/${active}/milestone.yml" ]]; then
    take_limit "miles/${active}/milestone.yml" || true
fi
if [[ -z "${limit}" && "${PROFILE_READ}" == true ]]; then
    take_limit degree/profile.tex || true
fi
if [[ "${BUILD_USABLE}" == true && -n "${limit}" && -f "${PDF_FILE}" ]]; then
    pages=''
    if command -v pdfinfo >/dev/null 2>&1; then
        # An unreadable PDF must not end lint under pipefail before its Result line.
        pages="$(pdfinfo "${PDF_FILE}" 2>/dev/null | LC_ALL=C awk '/^Pages:/ {print $2}' || true)"
    fi
    # Without pdfinfo, the engine's "Output written on ... (N pages" line is the
    # fallback; TeX wraps long log lines, so the path may push the count onto
    # the next line or two.
    if [[ ! "${pages}" =~ ^[0-9]+$ && -f "${LOG_FILE}" ]]; then
        pages="$(LC_ALL=C awk '
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
