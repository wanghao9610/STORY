#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
WORK_DIR="$(mktemp -d)"
# A case that fails while a directory is unreadable must not leave it behind.
trap 'chmod -R u+rwx "${WORK_DIR}" 2>/dev/null || true; rm -rf "${WORK_DIR}"' EXIT

mkdir -p "${WORK_DIR}/degree" "${WORK_DIR}/execs/scpts" \
    "${WORK_DIR}/manus/chaps" "${WORK_DIR}/wkdrs/builds"
cp "${ROOT_DIR}/execs/scpts/lint.sh" "${WORK_DIR}/execs/scpts/lint.sh"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "${WORK_DIR}/execs/scpts/fmt.sh"
printf '%s\n' '\documentclass{book}' '\begin{document}' 'Test' '\end{document}' > "${WORK_DIR}/manus/main.tex"
: > "${WORK_DIR}/wkdrs/builds/main.log"
: > "${WORK_DIR}/wkdrs/builds/main.pdf"

write_profile() {
    local level="$1" title="$2" degree="$3" language="${4-en}"
    {
        printf '%% degree_level: %s\n' "${level}"
        printf '%% dissertation_language: %s\n' "${language}"
        printf '\\title{%s}\n' "${title}"
        printf '\\submissionstatement{A thesis submitted for the degree of}\n'
        printf '\\degree{%s}\n' "${degree}"
        printf '\\author{Test Author}\n'
        printf '\\university{Test University}\n'
        printf '\\advisor{Test Advisor}\n'
        printf '\\graduationdate{2026}\n'
    } > "${WORK_DIR}/degree/profile.tex"
}

# LINT_PATH, when set, replaces PATH for lint.sh, e.g. to hide or stub pdfinfo.
LINT_PATH=''
# A UTF-8 locale, where one exists, for the cases about bytes that are not UTF-8.
UTF8_LOCALE="$(locale -a 2>/dev/null | grep -Eix 'c\.utf-?8|en_us\.utf-?8' | head -n 1 || true)"

expect_pass() {
    local name="$1"
    if ! (cd "${WORK_DIR}" && PATH="${LINT_PATH:-${PATH}}" bash execs/scpts/lint.sh --no-build) > "${WORK_DIR}/${name}.log" 2>&1; then
        printf 'FAIL  degree-level case should pass: %s\n' "${name}" >&2
        sed -n '1,120p' "${WORK_DIR}/${name}.log" >&2
        exit 1
    fi
}

expect_fail() {
    local name="$1"
    if (cd "${WORK_DIR}" && PATH="${LINT_PATH:-${PATH}}" bash execs/scpts/lint.sh --no-build) > "${WORK_DIR}/${name}.log" 2>&1; then
        printf 'FAIL  degree-level case should fail: %s\n' "${name}" >&2
        sed -n '1,120p' "${WORK_DIR}/${name}.log" >&2
        exit 1
    fi
}

expect_log() {
    local name="$1" expected="$2"
    grep -Fq -- "${expected}" "${WORK_DIR}/${name}.log" || {
        printf 'FAIL  %s case omitted: %s\n' "${name}" "${expected}" >&2
        sed -n '1,160p' "${WORK_DIR}/${name}.log" >&2
        exit 1
    }
}

refute_log() {
    local name="$1" unexpected="$2"
    if grep -Fq -- "${unexpected}" "${WORK_DIR}/${name}.log"; then
        printf 'FAIL  %s case reported: %s\n' "${name}" "${unexpected}" >&2
        sed -n '1,160p' "${WORK_DIR}/${name}.log" >&2
        exit 1
    fi
}

write_profile master "A Master's Thesis" 'Master of Science'
expect_pass master

write_profile doctoral 'A Doctoral Dissertation' 'Doctor of Philosophy'
expect_pass doctoral

write_profile master 'A Doctoral Dissertation' 'Doctor of Philosophy'
expect_fail master_with_doctoral_title

write_profile doctoral "A Master's Thesis" 'Master of Science'
expect_fail doctoral_with_master_title

# Only the degree field names the level: a subject word in an approved title, or
# a commented-out degree line, is not a conflict, while a conflicting degree is.
write_profile master 'Doctor--Patient Communication in Rural Clinics' 'Master of Science'
expect_pass master_with_doctor_subject_title
refute_log master_with_doctor_subject_title 'conflicts with'
write_profile doctoral 'Master Equation Approaches to Open Quantum Systems' 'Doctor of Philosophy'
printf '%s\n' '% \degree{Master of Science}' >> "${WORK_DIR}/degree/profile.tex"
expect_pass doctoral_with_master_subject_title
refute_log doctoral_with_master_subject_title 'conflicts with'
write_profile doctoral '硕士研究生培养质量研究' '\storylocalized{Doctor of Education}{教育学博士}'
expect_pass doctoral_with_chinese_master_subject_title
refute_log doctoral_with_chinese_master_subject_title 'conflicts with'
write_profile doctoral 'A Doctoral Dissertation' 'Master of Engineering'
expect_fail doctoral_with_master_degree
expect_log doctoral_with_master_degree 'doctoral degree_level conflicts with master wording in the degree field.'
write_profile master "A Master's Thesis" '\storylocalized{Doctor of Philosophy}{哲学博士}'
expect_fail master_with_doctoral_degree
expect_log master_with_doctoral_degree 'master degree_level conflicts with doctoral wording in the degree field.'

write_profile undergraduate 'A Thesis' 'Degree'
expect_fail invalid_level

write_profile '' 'A Thesis' 'Degree'
expect_pass unset_level
grep -q 'degree_level is unset' "${WORK_DIR}/unset_level.log" || {
    printf 'FAIL  unset degree-level case did not report its warning.\n' >&2
    exit 1
}

# A missing profile must reach the graceful absent-or-empty warning, not die
# silently in a failing command substitution under set -e.
rm "${WORK_DIR}/degree/profile.tex"
expect_pass missing_profile
grep -q 'degree/profile.tex is absent or empty' "${WORK_DIR}/missing_profile.log" || {
    printf 'FAIL  missing-profile case did not report the absent-or-empty warning.\n' >&2
    sed -n '1,60p' "${WORK_DIR}/missing_profile.log" >&2
    exit 1
}
if grep -q 'degree_level is unset' "${WORK_DIR}/missing_profile.log"; then
    printf 'FAIL  missing-profile case double-reported the unset warning.\n' >&2
    exit 1
fi
if grep -q 'No such file or directory' "${WORK_DIR}/missing_profile.log"; then
    printf 'FAIL  missing-profile case leaked a raw tool error.\n' >&2
    exit 1
fi

write_profile master "A Master's Thesis" 'Master of Science'
printf '%s\n' \
    'It is important to note that this pivotal result underscores the importance of the evolving landscape.' \
    'Experts believe it is not only useful but also transformative, highlighting a bright future.' \
    '' \
    '值得注意的是，这一结果不仅具有重要意义，而且彰显了研究的重要性。' \
    '已有研究表明，该方法能够赋能协同创新，从而体现不断演变的技术格局。' \
    '' \
    'I hope this helps. Would you like me to continue?' \
    '' \
    '% I hope this helps. This pivotal result underscores the importance.' \
    'The key parameter is fixed; however, the passive construction is deliberate.' \
    > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
expect_pass prose_advisory
for expected in 'chatbot-residue' 'formulaic-contrast' 'stock-signposting' 'findings are advisory, not proof of AI authorship' \
        'does not \input manus/chaps/01_prose-test.tex'; do
    grep -Fq "${expected}" "${WORK_DIR}/prose_advisory.log" || {
        printf 'FAIL  prose advisory case omitted: %s\n' "${expected}" >&2
        sed -n '1,160p' "${WORK_DIR}/prose_advisory.log" >&2
        exit 1
    }
done

# A comment is not prose, one after \\ (a line break) included.
printf '%s\n' \
    '% I hope this helps. This pivotal result underscores the importance.' \
    'The key parameter is fixed; however, the passive construction is deliberate.' \
    '' \
    'Proof.\\% I hope this helps. Would you like me to continue?' \
    > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
expect_pass prose_false_positive
if grep -Fq 'WARN: manus/chaps/01_prose-test.tex' "${WORK_DIR}/prose_false_positive.log"; then
    printf 'FAIL  prose false-positive case emitted a warning.\n' >&2
    sed -n '1,160p' "${WORK_DIR}/prose_false_positive.log" >&2
    exit 1
fi
# Chinese directly before a comment is ordinary Chinese TeX: under a UTF-8
# locale its comment is stripped and its prose reviewed, and lint reaches its
# verdict.
cp "${WORK_DIR}/manus/chaps/01_prose-test.tex" "${WORK_DIR}/prose-test.keep"
printf '%s\n' '值得注意的是，这一结果具有重要意义。% 注释：I hope this helps.' > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
LC_ALL="${UTF8_LOCALE}" expect_pass prose_chinese_before_comment
expect_log prose_chinese_before_comment 'manus/chaps/01_prose-test.tex:1: prose review (inflated-significance,stock-signposting)'
expect_log prose_chinese_before_comment 'Result: pass'
refute_log prose_chinese_before_comment 'chatbot-residue'
refute_log prose_chinese_before_comment 'stopped early'
mv "${WORK_DIR}/prose-test.keep" "${WORK_DIR}/manus/chaps/01_prose-test.tex"

# A chapter the entry point inputs is not reported as missing from the PDF.
write_main() {
    printf '%s\n' "$@" '\begin{document}' '\input{chaps/01_prose-test}' '\end{document}' > "${WORK_DIR}/manus/main.tex"
}
write_main '\documentclass{book}'
expect_pass chapter_wired
refute_log chapter_wired 'does not \input'

# Every check strips a comment by one rule: a % after an even run of
# backslashes starts one (\\% is a line break, then a comment), and the text
# before the % stays. A chapter input only after \\% is not wired, and one
# before a comment is; a todo only after \\% is not visible, and one whose
# argument opens before a comment is.
printf '%s\n' '\documentclass{book}' '\begin{document}' 'Text.\\% \input{chaps/01_prose-test}' '\end{document}' \
    > "${WORK_DIR}/manus/main.tex"
expect_pass chapter_input_after_line_break
expect_log chapter_input_after_line_break 'does not \input manus/chaps/01_prose-test.tex'
printf '%s\n' '\documentclass{book}' '\begin{document}' '\input{chaps/01_prose-test}% results' '\end{document}' \
    > "${WORK_DIR}/manus/main.tex"
expect_pass chapter_input_before_comment
refute_log chapter_input_before_comment 'does not \input'
# The entry point is read as TeX joins its lines, so an \input whose name a
# comment or a line break splits wires its chapter, while one inside \verb is
# typeset text and wires nothing.
printf '%s\n' 'Methods.' > "${WORK_DIR}/manus/chaps/02_method.tex"
printf '%s\n' 'Results.' > "${WORK_DIR}/manus/chaps/03_results.tex"
printf '%s\n' 'Outlook.' > "${WORK_DIR}/manus/chaps/04_outlook.tex"
printf '%s\n' '\documentclass{book}' '\begin{document}' '\input{%' '  chaps/01_prose-test}' '\input' '  {chaps/02_method}' \
    '\include%' '{chaps/03_results%' '}' 'See \verb|\input{chaps/04_outlook}| in the log.' '\end{document}' > "${WORK_DIR}/manus/main.tex"
expect_pass chapter_input_joined
for chapter in 01_prose-test 02_method 03_results; do
    refute_log chapter_input_joined "does not \\input manus/chaps/${chapter}.tex"
done
expect_log chapter_input_joined 'does not \input manus/chaps/04_outlook.tex'
rm "${WORK_DIR}/manus/chaps/02_method.tex" "${WORK_DIR}/manus/chaps/03_results.tex" "${WORK_DIR}/manus/chaps/04_outlook.tex"
write_main '\documentclass{book}'
cp "${WORK_DIR}/manus/chaps/01_prose-test.tex" "${WORK_DIR}/prose-test.keep"
printf '%s\n' 'A proof.\\% \todo{tighten the bound}' > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
expect_pass todo_after_line_break
refute_log todo_after_line_break 'visible \todo'
printf '%s\n' 'A proof.' '\todo{% the bound' '  tighten it}' > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
expect_fail todo_before_comment
expect_log todo_before_comment 'FAIL: 1 visible \todo marker(s) remain under manus/.'
# Todos are counted as TeX reads them: a marker whose argument follows a
# comment or a line break counts, a % inside \verb starts no comment, a file
# with lone-CR line ends is read line by line, every marker on a line counts,
# and a marker shown inside \verb is text.
printf '%s\n' 'A claim.' '\todo%' '  {add the number}' 'The rate is \verb|50%| in the logs. \todo{cite the log}' \
    '\todo{one} and \todo{two}' 'Written as \verb|\todo{x}| or \verb+\todo{y}+ in the source.' > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
printf '\\chapter{Notes}\r%% a note\rA claim.\r\\todo{after a lone CR}\r' > "${WORK_DIR}/manus/chaps/02_notes.tex"
expect_fail todo_as_tex_reads
expect_log todo_as_tex_reads 'FAIL: 5 visible \todo marker(s) remain under manus/.'
rm "${WORK_DIR}/manus/chaps/02_notes.tex"
# A chapter saved as UTF-16 (what Windows editors call Unicode) builds under
# XeLaTeX, but its NUL bytes hide every marker from a byte count, so lint fails
# on it, once, rather than counting it as clean; with no other chapter left to
# review, the prose review prints no summary.
if command -v iconv >/dev/null 2>&1; then
    printf '\\chapter{Intro}\nA claim.\n\\todo{add the number}\n' | iconv -f UTF-8 -t UTF-16 > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
    LC_ALL="${UTF8_LOCALE}" expect_fail chapter_utf16
    expect_log chapter_utf16 'FAIL: manus/chaps/01_prose-test.tex holds NUL bytes, as UTF-16 and UTF-32 text does, so none of its text was checked, its \todo markers included; save it as UTF-8.'
    expect_log chapter_utf16 'Result: 1 hard failure(s)'
    refute_log chapter_utf16 'prose went unreviewed'
    refute_log chapter_utf16 'Prose review: no front-matter'
fi
# A chapter lint cannot read fails, once, rather than hiding the todos of the
# files beside it or counting as clean. Mode bits bind no superuser, so the case
# runs only where they bind.
printf '%s\n' 'A claim.' '\todo{add the number}' > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
printf '%s\n' 'Methods.' > "${WORK_DIR}/manus/chaps/02_method.tex"
chmod 000 "${WORK_DIR}/manus/chaps/02_method.tex"
if [[ ! -r "${WORK_DIR}/manus/chaps/02_method.tex" ]]; then
    LC_ALL="${UTF8_LOCALE}" expect_fail chapter_unreadable
    expect_log chapter_unreadable 'FAIL: 1 visible \todo marker(s) remain under manus/.'
    expect_log chapter_unreadable 'FAIL: manus/chaps/02_method.tex cannot be read, so none of its text was checked, its \todo markers included.'
    expect_log chapter_unreadable 'Result: 2 hard failure(s)'
    refute_log chapter_unreadable 'prose went unreviewed'
fi
chmod 644 "${WORK_DIR}/manus/chaps/02_method.tex"
# An awk that stops is never a silent zero: the todo gate fails, and the prose
# review names the file it could not finish and goes on to the next. A stub awk
# stops on the one program and file named by AWK_STUB_FAIL.
AWK_STUB_BIN="${WORK_DIR}/awk-stub-bin"
mkdir -p "${AWK_STUB_BIN}"
printf '#!/bin/sh\ncase "${AWK_STUB_FAIL:-}:$*" in\n    todo:*"function take(line)"*|prose:*"function add_pattern"*02_method.tex) exit 2 ;;\nesac\nexec %s "$@"\n' \
    "$(type -P awk)" > "${AWK_STUB_BIN}/awk"
chmod +x "${AWK_STUB_BIN}/awk"
printf '%s\n' 'I hope this helps. Would you like me to continue?' > "${WORK_DIR}/manus/chaps/03_results.tex"
AWK_STUB_FAIL=todo LINT_PATH="${AWK_STUB_BIN}:${PATH}" expect_fail todo_count_stopped
expect_log todo_count_stopped 'FAIL: the \todo count stopped early (awk exit 2), so visible \todo markers may remain under manus/.'
refute_log todo_count_stopped 'visible \todo marker(s) remain'
AWK_STUB_FAIL=prose LINT_PATH="${AWK_STUB_BIN}:${PATH}" expect_fail prose_review_stopped
expect_log prose_review_stopped 'WARN: the prose review of manus/chaps/02_method.tex stopped early (awk exit 2), so part of it went unreviewed.'
expect_log prose_review_stopped 'manus/chaps/03_results.tex:1: prose review (chatbot-residue)'
rm -rf "${AWK_STUB_BIN}" "${WORK_DIR}/manus/chaps/02_method.tex" "${WORK_DIR}/manus/chaps/03_results.tex"
mv "${WORK_DIR}/prose-test.keep" "${WORK_DIR}/manus/chaps/01_prose-test.tex"

# Manuscript file names follow conventions §5: a tree on the scheme gets one
# pass line and no naming warning, hidden files, commented includes (a % after
# \\ included), and in a git work tree the names git ignores aside. A name off
# the grammar, key widths that sort differently in git and in an editor, keys
# of two widths that sort alike, a key no file owns, an asset whose includer
# carries another key, on one line or across several (lines joined as TeX joins
# them, so a comment may split the name), and a figure file whose graphic under
# figs/srcs/ has another name, each warn, name the file on disk, and none of
# them fails lint.
mkdir -p "${WORK_DIR}/manus/backs" "${WORK_DIR}/manus/fronts" \
    "${WORK_DIR}/manus/figs/srcs/02_pipeline" "${WORK_DIR}/manus/tabs"
for asset in figs/.gitkeep figs/.DS_Store figs/srcs/.gitkeep figs/srcs/00_teaser.pdf figs/srcs/02_pipeline.pdf \
        figs/srcs/02_pipeline.py figs/srcs/02_pipeline.map.md figs/srcs/02_pipeline/stage.pdf \
        figs/srcs/a_lemma.pdf figs/srcs/a_lemma.pptx tabs/02_results.tex; do
    : > "${WORK_DIR}/manus/${asset}"
done
printf '%s\n' '\graphicspath{{figs/srcs/}}' \
    '\input{figs/02_pipeline} and \input{tabs/02_results}' \
    '\includegraphics{02_pipeline}' \
    '% \input{figs/a_lemma}' \
    '\input{figs/02_pipeline} \\% \input{figs/a_lemma}' \
    '\includegraphics{figs/logo.pdf}' > "${WORK_DIR}/manus/chaps/02_method.tex"
printf '%s\n' '\includegraphics[width=\linewidth]{figs/srcs/02_pipeline.pdf}' \
    '\includegraphics{figs/srcs/02_pipeline/stage.pdf}' > "${WORK_DIR}/manus/figs/02_pipeline.tex"
printf '%s\n' '\includegraphics{figs/srcs/a_lemma}' > "${WORK_DIR}/manus/figs/a_lemma.tex"
printf '%s\n' '\includegraphics{00_teaser}' > "${WORK_DIR}/manus/figs/00_teaser.tex"
printf '%s\n' '\input{figs/a_lemma}' > "${WORK_DIR}/manus/backs/a_proofs.tex"
printf '%s\n' '\input{./figs/a_lemma.tex}' > "${WORK_DIR}/manus/backs/a_proofs-zh.tex"
printf '%s\n' '\input{figs/00_teaser}' > "${WORK_DIR}/manus/fronts/abstract.tex"
expect_pass file_names_on_scheme
refute_log file_names_on_scheme 'WARN: file name'
expect_log file_names_on_scheme 'File names: manus/chaps, backs, figs, figs/srcs, and tabs follow the owner-key scheme'
if command -v git >/dev/null 2>&1; then
    git -C "${WORK_DIR}" init -q
    printf '%s\n' '*.bak[0-9]*' '*.aux' > "${WORK_DIR}/.gitignore"
    : > "${WORK_DIR}/manus/chaps/02_method.bak0"
    : > "${WORK_DIR}/manus/chaps/02_method.aux"
    expect_pass file_names_git_ignored
    refute_log file_names_git_ignored 'WARN: file name'
    expect_log file_names_git_ignored 'File names: manus/chaps, backs, figs, figs/srcs, and tabs follow the owner-key scheme'
    : > "${WORK_DIR}/manus/chaps/02_method_v2.tex"
    expect_pass file_names_git_unignored
    expect_log file_names_git_unignored 'WARN: file name manus/chaps/02_method_v2.tex is not <nn>_<slug>.tex (conventions §5)'
    refute_log file_names_git_unignored '02_method.bak0'
    rm -rf "${WORK_DIR}/.git" "${WORK_DIR}/.gitignore" "${WORK_DIR}/manus/chaps/02_method.bak0" \
        "${WORK_DIR}/manus/chaps/02_method.aux" "${WORK_DIR}/manus/chaps/02_method_v2.tex"
fi
: > "${WORK_DIR}/manus/chaps/03_related_work.tex"
: > "${WORK_DIR}/manus/backs/b_extra_zh.tex"
: > "${WORK_DIR}/manus/figs/accuracy.pdf"
expect_pass file_names_grammar
expect_log file_names_grammar 'WARN: file name manus/chaps/03_related_work.tex is not <nn>_<slug>.tex (conventions §5)'
expect_log file_names_grammar 'WARN: file name manus/backs/b_extra_zh.tex is not <letter>_<slug>.tex (conventions §5)'
expect_log file_names_grammar 'WARN: file name manus/figs/accuracy.pdf is not <owner>_<slug>.tex (conventions §5)'
refute_log file_names_grammar 'File names:'
rm "${WORK_DIR}/manus/chaps/03_related_work.tex" "${WORK_DIR}/manus/backs/b_extra_zh.tex" "${WORK_DIR}/manus/figs/accuracy.pdf"
: > "${WORK_DIR}/manus/chaps/9_late.tex"
: > "${WORK_DIR}/manus/chaps/10_later.tex"
expect_pass file_names_mixed_widths
expect_log file_names_mixed_widths 'WARN: file names in manus/chaps/ sort differently: git and ls list 10_later.tex before 9_late.tex, but VS Code, Overleaf, and Finder list 9_late.tex first'
refute_log file_names_mixed_widths 'WARN: file name manus/'
refute_log file_names_mixed_widths 'mix key widths'
rm "${WORK_DIR}/manus/chaps/9_late.tex" "${WORK_DIR}/manus/chaps/10_later.tex"
: > "${WORK_DIR}/manus/chaps/3_results.tex"
expect_pass file_names_one_width
expect_log file_names_one_width 'WARN: file names in manus/chaps/ mix key widths: 01_prose-test.tex has a 2-digit key and 3_results.tex a 1-digit key'
refute_log file_names_one_width 'sort differently'
refute_log file_names_one_width 'File names:'
rm "${WORK_DIR}/manus/chaps/3_results.tex"
for asset in figs/07_orphan.tex figs/srcs/a_bars.pdf figs/srcs/a_diagram.pdf figs/srcs/a_note.pdf figs/srcs/a_plot.pdf \
        figs/srcs/a_split.pdf tabs/a_notation.tex; do
    : > "${WORK_DIR}/manus/${asset}"
done
printf '%s\n' 'See \includegraphics[trim={0 0 1 1}]{a_lemma}.' \
    'In 50\% of runs \includegraphics{figs/srcs/a_bars}' \
    '\includegraphics[' '  width=\linewidth,' ']{figs/srcs/a_diagram}' \
    '\includegraphics[width=\linewidth]%' '  {figs/srcs/a_plot}' \
    '\includegraphics[width=\linewidth]{%' '  figs/srcs/00_teaser}' \
    '\includegraphics{figs/srcs/%' '  a_split}' \
    '\includegraphics{figs/srcs/%' '%% a note on its own line' '  a_note}' \
    '\input{%' '  tabs/a_notation}' >> "${WORK_DIR}/manus/chaps/02_method.tex"
printf '%s\n' '\input{tabs/02_results}' >> "${WORK_DIR}/manus/fronts/abstract.tex"
printf '%s\n' '\includegraphics{figs/srcs/02_pipeline}' '\includegraphics{figs/srcs/02_pipeline/stage.pdf}' \
    > "${WORK_DIR}/manus/figs/02_flow.tex"
printf '%s\n' '\includegraphics{a_bars}' > "${WORK_DIR}/manus/figs/02_chart.tex"
expect_pass file_names_owners
expect_log file_names_owners 'WARN: file name manus/figs/07_orphan.tex has no owner: its key 07 names no chapter in manus/chaps/, appendix in manus/backs/, or front matter (00)'
for expected in 'manus/figs/srcs/a_lemma.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_lemma.pdf)' \
        'manus/figs/srcs/a_bars.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_bars.pdf)' \
        'manus/figs/srcs/a_diagram.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_diagram.pdf)' \
        'manus/figs/srcs/a_plot.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_plot.pdf)' \
        'manus/figs/srcs/00_teaser.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_teaser.pdf)' \
        'manus/figs/srcs/a_split.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_split.pdf)' \
        'manus/figs/srcs/a_note.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_note.pdf)' \
        'manus/tabs/a_notation.tex does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_notation.tex)' \
        'manus/tabs/02_results.tex does not carry the key of manus/fronts/abstract.tex, which includes it: expected key 00 (00_results.tex)' \
        'manus/figs/srcs/02_pipeline.pdf does not share the key and slug of manus/figs/02_flow.tex, which includes it: expected 02_flow.pdf' \
        'manus/figs/srcs/02_pipeline does not share the key and slug of manus/figs/02_flow.tex, which includes it: expected 02_flow,' \
        'manus/figs/srcs/a_bars.pdf does not share the key and slug of manus/figs/02_chart.tex, which includes it: expected 02_chart.pdf'; do
    expect_log file_names_owners "WARN: file name ${expected}"
done
refute_log file_names_owners 'manus/figs/02_pipeline'
refute_log file_names_owners 'a_lemma.pptx'
refute_log file_names_owners 'manus/figs/srcs/02_pipeline/stage.pdf'
rm -rf "${WORK_DIR}/manus/backs" "${WORK_DIR}/manus/fronts" "${WORK_DIR}/manus/figs" "${WORK_DIR}/manus/tabs" \
    "${WORK_DIR}/manus/chaps/02_method.tex"

# The naming check reads what git tracks and a file browser lists. Two names
# that differ only in a leading zero inside a slug warn: a byte sort and a
# numeric sort agree on them, but Finder lists them the other way. An option
# value may hold a ']' inside braces, and the two-bracket form still parses. A
# symlinked asset, chapter, or preamble counts as the file it points to, and a
# broken link is listed but never read. A byte that is not UTF-8 hides no
# include under a UTF-8 locale. A directory lint cannot read draws one
# warning, makes no asset ownerless, and ends neither the naming check nor
# lint; a missing build still gets every naming warning.
SHARED_DIR="${WORK_DIR}/shared"
mkdir -p "${WORK_DIR}/manus/backs" "${WORK_DIR}/manus/fronts" "${WORK_DIR}/manus/figs/srcs" \
    "${WORK_DIR}/manus/tabs" "${WORK_DIR}/manus/stys" "${SHARED_DIR}"
for asset in backs/a_proofs.tex figs/srcs/01_plot.pdf figs/srcs/a_alt.pdf figs/srcs/a_box.pdf tabs/01_scores.tex; do
    : > "${WORK_DIR}/manus/${asset}"
done
printf '%s\n' 'Method.' > "${WORK_DIR}/manus/chaps/02_method.tex"
: > "${WORK_DIR}/manus/figs/01_seed1.tex"
: > "${WORK_DIR}/manus/figs/01_seed01.tex"
expect_pass file_names_leading_zeros
expect_log file_names_leading_zeros 'WARN: file names in manus/figs/ sort differently in Finder than in git and ls: 01_seed01.tex and 01_seed1.tex differ only in a number'
refute_log file_names_leading_zeros 'WARN: file name '
rm "${WORK_DIR}/manus/figs/01_seed1.tex" "${WORK_DIR}/manus/figs/01_seed01.tex"
printf '%s\n' '\includegraphics[alt={A [b] c}]{figs/srcs/a_alt}' '\includegraphics[0,0][1,1]{figs/srcs/a_box}' \
    > "${WORK_DIR}/manus/chaps/02_method.tex"
expect_pass file_names_option_brackets
for asset in alt box; do
    expect_log file_names_option_brackets "WARN: file name manus/figs/srcs/a_${asset}.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_${asset}.pdf)"
done
printf 'Method.\n\\includegraphics{01_plot}\n' > "${WORK_DIR}/manus/chaps/02_method.tex"
printf '\\newcommand{\\thesisname}{Fran\347ais}\n\\graphicspath{{figs/srcs/}}\n' > "${WORK_DIR}/manus/stys/latin.sty"
LC_ALL="${UTF8_LOCALE}" expect_pass file_names_latin1_preamble
expect_log file_names_latin1_preamble 'WARN: file name manus/figs/srcs/01_plot.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_plot.pdf)'
rm "${WORK_DIR}/manus/stys/latin.sty"
# A \graphicspath is read from lines joined as TeX joins them, so it may span
# lines, and only a figs/srcs/ group among its own path groups counts.
printf '%s\n' '\graphicspath{%' '  {figs/srcs/}}' > "${WORK_DIR}/manus/stys/paths.sty"
expect_pass file_names_graphicspath_comment
expect_log file_names_graphicspath_comment 'WARN: file name manus/figs/srcs/01_plot.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_plot.pdf)'
printf '%s\n' '\graphicspath{' '  {./figs/srcs/}' '}' > "${WORK_DIR}/manus/stys/paths.sty"
expect_pass file_names_graphicspath_lines
expect_log file_names_graphicspath_lines 'WARN: file name manus/figs/srcs/01_plot.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_plot.pdf)'
printf '%s\n' '\graphicspath{{images/} {figs/}} \newcommand{\figdir}{figs/srcs/}' > "${WORK_DIR}/manus/stys/paths.sty"
expect_pass file_names_graphicspath_elsewhere
refute_log file_names_graphicspath_elsewhere 'manus/figs/srcs/01_plot.pdf'
rm "${WORK_DIR}/manus/stys/paths.sty"
printf '%s\n' '\graphicspath{{figs/srcs/}}' > "${SHARED_DIR}/thesis.sty"
printf '%s\n' '\input{tabs/01_scores}' > "${SHARED_DIR}/03_linked.tex"
ln -s "${SHARED_DIR}/thesis.sty" "${WORK_DIR}/manus/stys/thesis.sty"
ln -s "${SHARED_DIR}/03_linked.tex" "${WORK_DIR}/manus/chaps/03_linked.tex"
ln -s 01_plot.pdf "${WORK_DIR}/manus/figs/srcs/07_linked.pdf"
ln -s missing.tex "${WORK_DIR}/manus/backs/a_gone.tex"
expect_pass file_names_symlinks
for expected in 'manus/figs/srcs/07_linked.pdf has no owner: its key 07' \
        'manus/tabs/01_scores.tex does not carry the key of manus/chaps/03_linked.tex, which includes it: expected key 03 (03_scores.tex)' \
        'manus/figs/srcs/01_plot.pdf does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_plot.pdf)'; do
    expect_log file_names_symlinks "WARN: file name ${expected}"
done
refute_log file_names_symlinks 'a_gone'
rm "${WORK_DIR}/manus/stys/thesis.sty" "${WORK_DIR}/manus/chaps/03_linked.tex" \
    "${WORK_DIR}/manus/figs/srcs/07_linked.pdf" "${WORK_DIR}/manus/backs/a_gone.tex"
# A chapter that is not UTF-8 still reaches the verdict under a UTF-8 locale:
# its todo is counted and its includes are checked, and the prose review, the
# one check that needs the locale, skips it by name. perl tells, or iconv
# without perl; with neither, the verdict still comes.
printf 'Caf\351.\n\\input{tabs/01_scores}\n\\todo{check the accent}\n' > "${WORK_DIR}/manus/chaps/02_method.tex"
LC_ALL="${UTF8_LOCALE}" expect_fail file_names_latin1_chapter
for expected in 'WARN: file name manus/tabs/01_scores.tex does not carry the key of manus/chaps/02_method.tex, which includes it: expected key 02 (02_scores.tex)' \
        'WARN: manus/chaps/02_method.tex is not valid UTF-8, so its prose went unreviewed; save it as UTF-8.' \
        'FAIL: 1 visible \todo marker(s) remain under manus/.' 'Result: 1 hard failure(s)'; do
    expect_log file_names_latin1_chapter "${expected}"
done
NO_ICONV_BIN="${WORK_DIR}/no-iconv-bin"
mkdir -p "${NO_ICONV_BIN}"
for tool in bash awk sed grep find wc tr xargs sort cut tail basename dirname; do
    ln -s "$(type -P "${tool}")" "${NO_ICONV_BIN}/${tool}"
done
if type -P perl >/dev/null 2>&1; then
    ln -s "$(type -P perl)" "${NO_ICONV_BIN}/perl"
    LINT_PATH="${NO_ICONV_BIN}" LC_ALL="${UTF8_LOCALE}" expect_fail latin1_chapter_perl
    for expected in 'WARN: manus/chaps/02_method.tex is not valid UTF-8, so its prose went unreviewed; save it as UTF-8.' \
            'FAIL: 1 visible \todo marker(s) remain under manus/.' 'Result: 1 hard failure(s)'; do
        expect_log latin1_chapter_perl "${expected}"
    done
    rm "${NO_ICONV_BIN}/perl"
fi
# With neither iconv nor perl, awk and sed in the caller's locale tell, so a
# profile that is not UTF-8 still has its level read.
write_profile master "A Master's Thesis" "$(printf 'Master of Science, Universit\351 de Paris')"
LINT_PATH="${NO_ICONV_BIN}" LC_ALL="${UTF8_LOCALE}" expect_fail latin1_chapter_unvalidated
expect_log latin1_chapter_unvalidated 'FAIL: 1 visible \todo marker(s) remain under manus/.'
expect_log latin1_chapter_unvalidated 'Degree level: master.'
expect_log latin1_chapter_unvalidated 'Result: 1 hard failure(s)'
write_profile master "A Master's Thesis" 'Master of Science'
rm -rf "${NO_ICONV_BIN}"
# A chapter whose Chinese runs long is valid UTF-8, and lint reads it so:
# perl's strict decoder tells, and without perl an iconv that rejects such a
# run, as the macOS 26 one does, is never asked, so the prose review still
# reads the chapter. Without perl a Latin-1 chapter is still caught.
NO_PERL_BIN="${WORK_DIR}/no-perl-bin"
mkdir -p "${NO_PERL_BIN}"
for tool in bash awk sed grep find wc tr xargs sort cut tail basename dirname iconv; do
    if type -P "${tool}" >/dev/null 2>&1; then
        ln -s "$(type -P "${tool}")" "${NO_PERL_BIN}/${tool}"
    fi
done
LINT_PATH="${NO_PERL_BIN}" LC_ALL="${UTF8_LOCALE}" expect_fail latin1_chapter_no_perl
expect_log latin1_chapter_no_perl 'WARN: manus/chaps/02_method.tex is not valid UTF-8, so its prose went unreviewed; save it as UTF-8.'
LC_ALL=C awk 'BEGIN { for (i = 0; i < 2000; i++) printf "\344\270\255"; print "\343\200\202" }' \
    > "${WORK_DIR}/manus/chaps/02_method.tex"
LC_ALL="${UTF8_LOCALE}" expect_pass long_chinese_chapter
refute_log long_chinese_chapter 'is not valid UTF-8'
LINT_PATH="${NO_PERL_BIN}" LC_ALL="${UTF8_LOCALE}" expect_pass long_chinese_chapter_no_perl
refute_log long_chinese_chapter_no_perl 'is not valid UTF-8'
rm -rf "${NO_PERL_BIN}"
printf 'Caf\351.\n\\input{tabs/01_scores}\n\\todo{check the accent}\n' > "${WORK_DIR}/manus/chaps/02_method.tex"

# A profile that is not UTF-8 is read byte by byte, its level and degree field
# still checked, with one warning for the Chinese that reading may miss; an
# entry point that is not UTF-8 still has its class and chapter inputs read.
printf '%s\n' 'Method.' > "${WORK_DIR}/manus/chaps/02_method.tex"
write_profile master "A Master's Thesis" "$(printf 'Doctor of Philosophy, Universit\351 de Paris')"
LC_ALL="${UTF8_LOCALE}" expect_fail profile_latin1
for expected in 'Degree level: master.' \
        'WARN: degree/profile.tex is not valid UTF-8, so Chinese in another encoding in its degree field and title-page placeholders went unchecked; save it as UTF-8.' \
        'FAIL: master degree_level conflicts with doctoral wording in the degree field.' 'Result: 1 hard failure(s)'; do
    expect_log profile_latin1 "${expected}"
done
write_profile master "A Master's Thesis" 'Master of Science'
printf '\\newcommand{\\thesisname}{Th\350se}\n\\documentclass[oneside]{stys/story}\n\\begin{document}\n\\input{chaps/01_prose-test}\n\\input{chaps/02_method}\n\\end{document}\n' \
    > "${WORK_DIR}/manus/main.tex"
LC_ALL="${UTF8_LOCALE}" expect_pass main_latin1
refute_log main_latin1 'does not \input'
refute_log main_latin1 'language option is not checked'
expect_log main_latin1 'Result: pass'
# .env is read byte by byte, so a comment that is not UTF-8 hides no key.
cp "${WORK_DIR}/manus/main.tex" "${WORK_DIR}/manus/other.tex"
: > "${WORK_DIR}/wkdrs/builds/other.log"
: > "${WORK_DIR}/wkdrs/builds/other.pdf"
printf '# Th\350se\nSTORY_MAIN=manus/other.tex\n' > "${WORK_DIR}/.env"
LC_ALL="${UTF8_LOCALE}" expect_pass env_latin1
expect_log env_latin1 '/manus/other.tex.'
rm "${WORK_DIR}/.env" "${WORK_DIR}/manus/other.tex" "${WORK_DIR}/wkdrs/builds/other.log" "${WORK_DIR}/wkdrs/builds/other.pdf"
# A sequence past U+10FFFF, which macOS iconv takes but awk and sed in a UTF-8
# locale reject (cp1252 text can hold one: F6 A0 96 A0 is "ö – " with
# no-break spaces), stops neither the profile checks nor the prose review, and
# the chapters after it are still reviewed.
write_profile master "A Master's Thesis" 'Master of Science'
printf '%s\n' "$(printf '\\author{Malm\366\240\226\240Lund}')" >> "${WORK_DIR}/degree/profile.tex"
cp "${WORK_DIR}/manus/chaps/01_prose-test.tex" "${WORK_DIR}/prose-test.keep"
printf 'Seminar in Malm\366\240\226\240Lund.\n' > "${WORK_DIR}/manus/chaps/01_prose-test.tex"
printf '%s\n' 'I hope this helps. Would you like me to continue?' > "${WORK_DIR}/manus/chaps/02_method.tex"
LC_ALL="${UTF8_LOCALE}" expect_pass beyond_unicode
expect_log beyond_unicode 'Degree level: master.'
expect_log beyond_unicode 'manus/chaps/02_method.tex:1: prose review (chatbot-residue)'
expect_log beyond_unicode 'Result: pass'
refute_log beyond_unicode 'stopped early'
refute_log beyond_unicode 'illegal byte sequence'
mv "${WORK_DIR}/prose-test.keep" "${WORK_DIR}/manus/chaps/01_prose-test.tex"
write_main '\documentclass{book}'
printf '%s\n' 'Method.' > "${WORK_DIR}/manus/chaps/02_method.tex"
printf '%s\n' '\todo{cite the proof}' > "${WORK_DIR}/manus/backs/a_proofs.tex"
printf '%s\n' '\input{tabs/01_scores}' > "${WORK_DIR}/manus/fronts/abstract.tex"
chmod 000 "${WORK_DIR}/manus/chaps" "${WORK_DIR}/manus/figs" "${WORK_DIR}/manus/fronts"
# Mode bits bind no superuser, so the case runs only where they bind.
if [[ ! -r "${WORK_DIR}/manus/chaps" ]]; then
    expect_fail file_names_unreadable
    for dir in chaps figs; do
        expect_log file_names_unreadable "WARN: manus/${dir} cannot be read, so its file names went unchecked (conventions §5)."
    done
    expect_log file_names_unreadable 'WARN: manus/fronts cannot be read, so the keys of the assets it includes went unchecked (conventions §5).'
    expect_log file_names_unreadable '1 visible \todo marker(s) remain under manus/.'
    # The todo gate needs a verified zero, so a directory it cannot search fails.
    for dir in chaps figs fronts; do
        expect_log file_names_unreadable "FAIL: manus/${dir} cannot be read, so the \\todo markers in it were not counted."
    done
    expect_log file_names_unreadable 'Result: 4 hard failure(s)'
    refute_log file_names_unreadable 'has no owner'
    refute_log file_names_unreadable 'does not carry the key'
    if [[ "$(grep -c 'went unchecked (conventions §5)' "${WORK_DIR}/file_names_unreadable.log")" != 3 ]]; then
        printf 'FAIL  file_names_unreadable case warned other than once per unreadable directory.\n' >&2
        sed -n '1,160p' "${WORK_DIR}/file_names_unreadable.log" >&2
        exit 1
    fi
fi
chmod 755 "${WORK_DIR}/manus/chaps" "${WORK_DIR}/manus/figs" "${WORK_DIR}/manus/fronts"
rm "${WORK_DIR}/wkdrs/builds/main.pdf"
expect_fail file_names_without_build
expect_log file_names_without_build 'FAIL: --no-build requested but'
expect_log file_names_without_build 'WARN: file name manus/tabs/01_scores.tex does not carry the key of manus/fronts/abstract.tex, which includes it: expected key 00 (00_scores.tex)'
: > "${WORK_DIR}/wkdrs/builds/main.pdf"
rm -rf "${WORK_DIR}/manus/backs" "${WORK_DIR}/manus/fronts" "${WORK_DIR}/manus/figs" "${WORK_DIR}/manus/tabs" \
    "${WORK_DIR}/manus/stys" "${WORK_DIR}/manus/chaps/02_method.tex" "${SHARED_DIR}"

# Placeholders are read from compiled lines only: the profile's own comments
# name the fields, while an unreplaced department or Chinese half is a real one.
write_profile master "A Master's Thesis" 'Master of Science'
printf '%s\n' '%% The degree name must agree with degree_level above.（学位名称必须与上方 degree_level 一致。）' >> "${WORK_DIR}/degree/profile.tex"
expect_pass placeholder_comment
refute_log placeholder_comment 'title-page placeholders'
printf '%s\n' '\department{\storylocalized{Department or Program}{院系或培养单位}}' >> "${WORK_DIR}/degree/profile.tex"
expect_pass placeholder_department
expect_log placeholder_department 'title-page placeholders remain in degree/profile.tex: Department or Program, 院系或培养单位.'

# The submission statement is a title-page field too: its placeholder is
# reported, and so is a profile that never sets it (a commented line does not
# count), while an empty statement is a confirmed choice.
write_profile master "A Master's Thesis" 'Master of Science'
printf '%s\n' '\submissionstatement{\storylocalized{Submission Statement}{提交说明}}' >> "${WORK_DIR}/degree/profile.tex"
expect_pass placeholder_statement
expect_log placeholder_statement 'title-page placeholders remain in degree/profile.tex: Submission Statement, 提交说明.'
refute_log placeholder_statement 'sets no \submissionstatement'
grep -v '^\\submissionstatement' "${WORK_DIR}/degree/profile.tex" > "${WORK_DIR}/profile.tmp"
mv "${WORK_DIR}/profile.tmp" "${WORK_DIR}/degree/profile.tex"
printf '%s\n' '% \submissionstatement{A thesis submitted for the degree of}' >> "${WORK_DIR}/degree/profile.tex"
expect_pass placeholder_statement_missing
expect_log placeholder_statement_missing 'WARN: title-page placeholder: degree/profile.tex sets no \submissionstatement, so the title page prints the class placeholder.'
refute_log placeholder_statement_missing 'title-page placeholders remain'
printf '%s\n' '\submissionstatement{}' >> "${WORK_DIR}/degree/profile.tex"
expect_pass placeholder_statement_empty
refute_log placeholder_statement_empty 'title-page placeholder'

# The manuscript language and the entry point's class option must agree. The
# profile's last dissertation_language line counts; only STORY's class is
# checked, and its option list may span lines with comments, one after \\ (a
# line break) included.
write_profile master "A Master's Thesis" 'Master of Science'
printf '%s\n' '% dissertation_language: zh' >> "${WORK_DIR}/degree/profile.tex"
expect_pass language_other_class
expect_log language_other_class "[STORY lint] manus/main.tex loads the class book, not STORY's; its language option is not checked."
refute_log language_other_class 'dissertation_language is'
write_main '\documentclass[oneside]{stys/story}'
expect_pass language_mismatch
expect_log language_mismatch 'dissertation_language is zh but manus/main.tex does not load the class with the zh option.'
write_main '\documentclass[degree=doctor]{ustcthesis}'
expect_pass language_institutional_class
expect_log language_institutional_class "[STORY lint] manus/main.tex loads the class ustcthesis, not STORY's; its language option is not checked."
refute_log language_institutional_class 'dissertation_language is'
write_profile master "A Master's Thesis" 'Master of Science' zh
write_main '\documentclass[%' '    oneside, % one-sided print [see 1]' '    zh% Chinese title page' ']{stys/story}'
expect_pass language_multiline
refute_log language_multiline 'dissertation_language is'
refute_log language_multiline 'not checked'
write_profile master "A Master's Thesis" 'Master of Science' en
write_main '\documentclass[oneside,' '    zh]{stys/story} % a comment after the class'
expect_pass language_en_with_zh
expect_log language_en_with_zh 'dissertation_language is en but manus/main.tex loads the class with the zh option.'
write_main '\documentclass[oneside,\\% zh' ']{stys/story}'
expect_pass language_option_after_line_break
refute_log language_option_after_line_break 'loads the class with the zh option'
write_profile master "A Master's Thesis" 'Master of Science' english
expect_fail language_invalid
expect_log language_invalid "invalid dissertation_language 'english' in degree/profile.tex; expected en or zh."
write_profile master "A Master's Thesis" 'Master of Science' ''
expect_pass language_unset
expect_log language_unset 'WARN: dissertation_language is unset in degree/profile.tex; confirm en or zh.'
write_main '\documentclass{book}'
write_profile master "A Master's Thesis" 'Master of Science'

# Unresolved requirement rows are counted; resolved ones are not.
printf '%s\n' '- [ ] Title-page wording confirmed — applicability: — source: — notes:' \
    '- [x] Degree level confirmed — applicability: applies — source: degree/x.pdf — notes:' \
    > "${WORK_DIR}/degree/requirements.md"
expect_pass requirement_rows
expect_log requirement_rows '1 unresolved row(s) in degree/requirements.md'
rm "${WORK_DIR}/degree/requirements.md"

# The active milestone is the one milestone.yml with status: active, a standing
# supervision record aside; a malformed limit is reported, a quoted one is read.
mkdir -p "${WORK_DIR}/miles/supervision" "${WORK_DIR}/miles/defense"
printf '%s\n' 'kind: supervision' 'status: active' 'max_pages: 3' > "${WORK_DIR}/miles/supervision/milestone.yml"
printf '%s\n' 'kind: defense' 'status: active' 'max_pages: "abc"' > "${WORK_DIR}/miles/defense/milestone.yml"
expect_pass milestone_bad_limit
expect_log milestone_bad_limit "max_pages 'abc' in miles/defense/milestone.yml is not a positive integer"
refute_log milestone_bad_limit 'milestones have status: active'
printf '%s\n' 'kind: defense' 'status: active' 'max_pages: "7"' > "${WORK_DIR}/miles/defense/milestone.yml"
# The fake PDF is empty and so is the log: no page count, with or without pdfinfo.
expect_pass milestone_quoted_limit
expect_log milestone_quoted_limit 'WARN: page limit 7 (miles/defense/milestone.yml) not checked: the page count could not be read (install pdfinfo).'

# Without pdfinfo, the page count comes from the engine's log line, which TeX
# wraps at 79 characters; with neither, the limit is reported as unchecked. A
# PATH holding only the tools lint.sh calls under --no-build hides pdfinfo.
NO_PDFINFO_BIN="${WORK_DIR}/no-pdfinfo-bin"
mkdir -p "${NO_PDFINFO_BIN}"
for tool in bash awk sed grep find wc tr xargs sort cut tail basename dirname; do
    ln -s "$(type -P "${tool}")" "${NO_PDFINFO_BIN}/${tool}"
done
LINT_PATH="${NO_PDFINFO_BIN}"
printf '%s\n' 'Output written on /Users/example/Theses/STORY/wkdrs/builds/main-zh.' 'xdv (1 page, 7276 bytes).' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_pass page_count_from_log
expect_log page_count_from_log 'Page limit: 1/7 (miles/defense/milestone.yml).'
printf '%s\n' 'Output written on /Users/example/Theses/STORY/wkdrs/builds/main.pdf (9 pa' 'ges, 81535 bytes).' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_fail page_limit_from_log
expect_log page_limit_from_log '9 pages exceeds the confirmed limit 7 (miles/defense/milestone.yml)'
: > "${WORK_DIR}/wkdrs/builds/main.log"
expect_pass page_limit_unchecked
expect_log page_limit_unchecked 'WARN: page limit 7 (miles/defense/milestone.yml) not checked: the page count could not be read (install pdfinfo).'

# pdfinfo's count wins over the log's, and a pdfinfo that reads nothing falls
# back to the log.
PDFINFO_STUB_BIN="${WORK_DIR}/pdfinfo-stub-bin"
mkdir -p "${PDFINFO_STUB_BIN}"
printf '%s\n' '#!/bin/sh' 'printf "Pages:          8\n"' > "${PDFINFO_STUB_BIN}/pdfinfo"
chmod +x "${PDFINFO_STUB_BIN}/pdfinfo"
LINT_PATH="${PDFINFO_STUB_BIN}:${PATH}"
printf '%s\n' 'Output written on main.pdf (5 pages, 81535 bytes).' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_fail page_count_from_pdfinfo
expect_log page_count_from_pdfinfo '8 pages exceeds the confirmed limit 7 (miles/defense/milestone.yml)'
printf '%s\n' '#!/bin/sh' 'exit 1' > "${PDFINFO_STUB_BIN}/pdfinfo"
expect_pass page_count_pdfinfo_unreadable
expect_log page_count_pdfinfo_unreadable 'Page limit: 5/7 (miles/defense/milestone.yml).'
LINT_PATH=''
: > "${WORK_DIR}/wkdrs/builds/main.log"

mkdir -p "${WORK_DIR}/miles/predefense"
printf '%s\n' 'kind: pre-defense' 'status: active' > "${WORK_DIR}/miles/predefense/milestone.yml"
expect_pass milestone_two_active
expect_log milestone_two_active '2 milestones have status: active'
rm -rf "${WORK_DIR}/miles"
# A milestone record or story file that is not UTF-8 is still read.
mkdir -p "${WORK_DIR}/miles/defense" "${WORK_DIR}/notes"
printf 'kind: defense\nstatus: planned\nvenue: Universit\351\nmax_pages: 7\n' > "${WORK_DIR}/miles/defense/milestone.yml"
printf '# Th\350se\n\nactive_milestone: defense\n' > "${WORK_DIR}/notes/story.md"
LC_ALL="${UTF8_LOCALE}" expect_pass milestone_latin1
expect_log milestone_latin1 'page limit 7 (miles/defense/milestone.yml)'
for file in miles/defense/milestone.yml notes/story.md; do
    expect_log milestone_latin1 "WARN: ${file} is not valid UTF-8, so lint read it byte by byte; save it as UTF-8."
done
rm "${WORK_DIR}/notes/story.md"
# The byte may come before the status line, and a sequence past U+10FFFF,
# which macOS iconv takes but awk rejects, is read as bytes too.
printf 'kind: defense\nvenue: Universit\351\nstatus: active\nmax_pages: 7\n' > "${WORK_DIR}/miles/defense/milestone.yml"
LC_ALL="${UTF8_LOCALE}" expect_pass milestone_latin1_active
expect_log milestone_latin1_active 'page limit 7 (miles/defense/milestone.yml)'
if [[ "$(grep -c 'miles/defense/milestone.yml is not valid UTF-8' "${WORK_DIR}/milestone_latin1_active.log")" != 1 ]]; then
    printf 'FAIL  milestone_latin1_active case warned other than once for its milestone record.\n' >&2
    sed -n '1,160p' "${WORK_DIR}/milestone_latin1_active.log" >&2
    exit 1
fi
printf 'kind: defense\nnote: seminar in Malm\366\240\226\240Lund\nstatus: active\nmax_pages: 7\n' > "${WORK_DIR}/miles/defense/milestone.yml"
LC_ALL="${UTF8_LOCALE}" expect_pass milestone_beyond_unicode
expect_log milestone_beyond_unicode 'page limit 7 (miles/defense/milestone.yml)'
rm -rf "${WORK_DIR}/miles" "${WORK_DIR}/notes"

# A file lint cannot read stops no check in silence and ends nothing early: an
# entry point or profile fails, since what it holds went unchecked; a milestone
# record, the requirements, and the story file each warn.
mkdir -p "${WORK_DIR}/miles/defense" "${WORK_DIR}/notes"
printf '%s\n' 'kind: defense' 'status: active' 'max_pages: 7' > "${WORK_DIR}/miles/defense/milestone.yml"
printf '%s\n' '# Story' 'active_milestone: defense' > "${WORK_DIR}/notes/story.md"
printf '%s\n' '- [ ] Title-page wording confirmed' > "${WORK_DIR}/degree/requirements.md"
chmod 000 "${WORK_DIR}/miles/defense/milestone.yml" "${WORK_DIR}/notes/story.md" "${WORK_DIR}/degree/requirements.md" \
    "${WORK_DIR}/degree/profile.tex" "${WORK_DIR}/manus/main.tex"
if [[ ! -r "${WORK_DIR}/degree/profile.tex" ]]; then
    LC_ALL="${UTF8_LOCALE}" expect_fail metadata_unreadable
    for expected in 'FAIL: the entry point manus/main.tex cannot be read, so none of its text was checked, its class option, chapter inputs, and \todo markers included.' \
            'FAIL: degree/profile.tex cannot be read, so its degree level, language, and title-page fields went unchecked.' \
            'WARN: degree/requirements.md cannot be read, so its unresolved rows went uncounted.' \
            'WARN: miles/defense/milestone.yml cannot be read, so whether it is active, and its page limit, went unchecked.' \
            'WARN: notes/story.md cannot be read, so its legacy active_milestone went unchecked.' \
            'Result: 2 hard failure(s)'; do
        expect_log metadata_unreadable "${expected}"
    done
    refute_log metadata_unreadable 'absent or empty'
    refute_log metadata_unreadable 'Permission denied'
    refute_log metadata_unreadable 'FAIL: manus/main.tex cannot be read'
fi
chmod 644 "${WORK_DIR}/miles/defense/milestone.yml" "${WORK_DIR}/notes/story.md" "${WORK_DIR}/degree/requirements.md" \
    "${WORK_DIR}/degree/profile.tex" "${WORK_DIR}/manus/main.tex"
rm -rf "${WORK_DIR}/miles" "${WORK_DIR}/notes" "${WORK_DIR}/degree/requirements.md"

# --no-build trusts an earlier build only when that build finished cleanly.
printf '%s\n' '! Undefined control sequence.' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_fail last_build_error
expect_log last_build_error 'the last build stopped on a LaTeX error'
expect_log last_build_error 'Result:'
: > "${WORK_DIR}/wkdrs/builds/main.log"

# Glyphs the fonts lack are dropped from the PDF; the build log counts them.
printf '%s\n' \
    'Missing character: There is no 此 (U+6B64) in font [lmroman10-regular]:mapping=tex-text;!' \
    'Missing character: There is no 文 (U+6587) in font [lmroman10-regular]:mapping=tex-text;!' \
    > "${WORK_DIR}/wkdrs/builds/main.log"
expect_pass missing_characters
expect_log missing_characters 'WARN: the build log reports 2 missing character(s): text in a script the fonts cannot typeset, such as Chinese without the cjk class option.'
: > "${WORK_DIR}/wkdrs/builds/main.log"
expect_pass no_missing_characters
refute_log no_missing_characters 'missing character'

# run.sh reads its engine line past a byte that is not UTF-8 under a UTF-8
# locale. The latexmk stub fails at once, after run.sh has named its engine.
cp "${ROOT_DIR}/execs/run.sh" "${WORK_DIR}/execs/run.sh"
LATEXMK_STUB_BIN="${WORK_DIR}/latexmk-stub-bin"
mkdir -p "${LATEXMK_STUB_BIN}"
printf '%s\n' '#!/bin/sh' 'exit 1' > "${LATEXMK_STUB_BIN}/latexmk"
chmod +x "${LATEXMK_STUB_BIN}/latexmk"
printf '%% Th\350se de doctorat\n%% !TeX program = xelatex\n\\documentclass{book}\n\\begin{document}\nTest\n\\end{document}\n' \
    > "${WORK_DIR}/manus/latin1.tex"
(cd "${WORK_DIR}" && env -u LATEX_ENGINE PATH="${LATEXMK_STUB_BIN}:${PATH}" LC_ALL="${UTF8_LOCALE}" bash execs/run.sh --main manus/latin1.tex) \
    > "${WORK_DIR}/run_latin1.log" 2>&1 || true
expect_log run_latin1 'engine: xelatex'
refute_log run_latin1 'illegal byte sequence'
rm -rf "${WORK_DIR}/manus/latin1.tex" "${WORK_DIR}/execs/run.sh" "${LATEXMK_STUB_BIN}"

printf 'ok    degree-level metadata and degree-field wording, English/Chinese prose-advisory, placeholder and submission-statement, language and class-option, requirement, milestone page-limit and page-count, missing-character, chapter-wiring, todo-count, comment-stripping, non-UTF-8 and unreadable-source, owner-key file-name, failed-build, and run.sh engine-line cases behave as expected\n'
