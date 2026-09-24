#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

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
    > "${WORK_DIR}/manus/chaps/1_prose_test.tex"
expect_pass prose_advisory
for expected in 'chatbot-residue' 'formulaic-contrast' 'stock-signposting' 'findings are advisory, not proof of AI authorship' \
        'does not \input manus/chaps/1_prose_test.tex'; do
    grep -Fq "${expected}" "${WORK_DIR}/prose_advisory.log" || {
        printf 'FAIL  prose advisory case omitted: %s\n' "${expected}" >&2
        sed -n '1,160p' "${WORK_DIR}/prose_advisory.log" >&2
        exit 1
    }
done

printf '%s\n' \
    '% I hope this helps. This pivotal result underscores the importance.' \
    'The key parameter is fixed; however, the passive construction is deliberate.' \
    > "${WORK_DIR}/manus/chaps/1_prose_test.tex"
expect_pass prose_false_positive
if grep -Fq 'WARN: manus/chaps/1_prose_test.tex' "${WORK_DIR}/prose_false_positive.log"; then
    printf 'FAIL  prose false-positive case emitted a warning.\n' >&2
    sed -n '1,160p' "${WORK_DIR}/prose_false_positive.log" >&2
    exit 1
fi

# A chapter the entry point inputs is not reported as missing from the PDF.
write_main() {
    printf '%s\n' "$@" '\begin{document}' '\input{chaps/1_prose_test}' '\end{document}' > "${WORK_DIR}/manus/main.tex"
}
write_main '\documentclass{book}'
expect_pass chapter_wired
refute_log chapter_wired 'does not \input'

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
# checked, and its option list may span lines with comments.
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
mkdir -p "${WORK_DIR}/milestones/supervision" "${WORK_DIR}/milestones/defense"
printf '%s\n' 'kind: supervision' 'status: active' 'max_pages: 3' > "${WORK_DIR}/milestones/supervision/milestone.yml"
printf '%s\n' 'kind: defense' 'status: active' 'max_pages: "abc"' > "${WORK_DIR}/milestones/defense/milestone.yml"
expect_pass milestone_bad_limit
expect_log milestone_bad_limit "max_pages 'abc' in milestones/defense/milestone.yml is not a positive integer"
refute_log milestone_bad_limit 'milestones have status: active'
printf '%s\n' 'kind: defense' 'status: active' 'max_pages: "7"' > "${WORK_DIR}/milestones/defense/milestone.yml"
# The fake PDF is empty and so is the log: no page count, with or without pdfinfo.
expect_pass milestone_quoted_limit
expect_log milestone_quoted_limit 'WARN: page limit 7 (milestones/defense/milestone.yml) not checked: the page count could not be read (install pdfinfo).'

# Without pdfinfo, the page count comes from the engine's log line, which TeX
# wraps at 79 characters; with neither, the limit is reported as unchecked. A
# PATH holding only the tools lint.sh calls under --no-build hides pdfinfo.
NO_PDFINFO_BIN="${WORK_DIR}/no-pdfinfo-bin"
mkdir -p "${NO_PDFINFO_BIN}"
for tool in bash awk sed grep find wc tr xargs sort tail basename dirname; do
    ln -s "$(type -P "${tool}")" "${NO_PDFINFO_BIN}/${tool}"
done
LINT_PATH="${NO_PDFINFO_BIN}"
printf '%s\n' 'Output written on /Users/example/Theses/STORY/wkdrs/builds/main-zh.' 'xdv (1 page, 7276 bytes).' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_pass page_count_from_log
expect_log page_count_from_log 'Page limit: 1/7 (milestones/defense/milestone.yml).'
printf '%s\n' 'Output written on /Users/example/Theses/STORY/wkdrs/builds/main.pdf (9 pa' 'ges, 81535 bytes).' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_fail page_limit_from_log
expect_log page_limit_from_log '9 pages exceeds the confirmed limit 7 (milestones/defense/milestone.yml)'
: > "${WORK_DIR}/wkdrs/builds/main.log"
expect_pass page_limit_unchecked
expect_log page_limit_unchecked 'WARN: page limit 7 (milestones/defense/milestone.yml) not checked: the page count could not be read (install pdfinfo).'

# pdfinfo's count wins over the log's, and a pdfinfo that reads nothing falls
# back to the log.
PDFINFO_STUB_BIN="${WORK_DIR}/pdfinfo-stub-bin"
mkdir -p "${PDFINFO_STUB_BIN}"
printf '%s\n' '#!/bin/sh' 'printf "Pages:          8\n"' > "${PDFINFO_STUB_BIN}/pdfinfo"
chmod +x "${PDFINFO_STUB_BIN}/pdfinfo"
LINT_PATH="${PDFINFO_STUB_BIN}:${PATH}"
printf '%s\n' 'Output written on main.pdf (5 pages, 81535 bytes).' > "${WORK_DIR}/wkdrs/builds/main.log"
expect_fail page_count_from_pdfinfo
expect_log page_count_from_pdfinfo '8 pages exceeds the confirmed limit 7 (milestones/defense/milestone.yml)'
printf '%s\n' '#!/bin/sh' 'exit 1' > "${PDFINFO_STUB_BIN}/pdfinfo"
expect_pass page_count_pdfinfo_unreadable
expect_log page_count_pdfinfo_unreadable 'Page limit: 5/7 (milestones/defense/milestone.yml).'
LINT_PATH=''
: > "${WORK_DIR}/wkdrs/builds/main.log"

mkdir -p "${WORK_DIR}/milestones/predefense"
printf '%s\n' 'kind: pre-defense' 'status: active' > "${WORK_DIR}/milestones/predefense/milestone.yml"
expect_pass milestone_two_active
expect_log milestone_two_active '2 milestones have status: active'
rm -rf "${WORK_DIR}/milestones"

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

printf 'ok    degree-level metadata and degree-field wording, English/Chinese prose-advisory, placeholder and submission-statement, language and class-option, requirement, milestone page-limit and page-count, missing-character, chapter-wiring, and failed-build cases behave as expected\n'
