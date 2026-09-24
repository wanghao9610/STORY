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
    local level="$1" title="$2" degree="$3"
    {
        printf '%% degree_level: %s\n' "${level}"
        printf '\\title{%s}\n' "${title}"
        printf '\\degree{%s}\n' "${degree}"
        printf '\\author{Test Author}\n'
        printf '\\university{Test University}\n'
        printf '\\advisor{Test Advisor}\n'
        printf '\\graduationdate{2026}\n'
    } > "${WORK_DIR}/degree/profile.tex"
}

expect_pass() {
    local name="$1"
    if ! (cd "${WORK_DIR}" && bash execs/scpts/lint.sh --no-build) > "${WORK_DIR}/${name}.log" 2>&1; then
        printf 'FAIL  degree-level case should pass: %s\n' "${name}" >&2
        sed -n '1,120p' "${WORK_DIR}/${name}.log" >&2
        exit 1
    fi
}

expect_fail() {
    local name="$1"
    if (cd "${WORK_DIR}" && bash execs/scpts/lint.sh --no-build) > "${WORK_DIR}/${name}.log" 2>&1; then
        printf 'FAIL  degree-level case should fail: %s\n' "${name}" >&2
        sed -n '1,120p' "${WORK_DIR}/${name}.log" >&2
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

# A chapter the entry point inputs is not reported as missing from the PDF.
printf '%s\n' '\documentclass{book}' '\begin{document}' '\input{chaps/1_prose_test}' '\end{document}' > "${WORK_DIR}/manus/main.tex"
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

# The manuscript language and the entry point's class option must agree.
write_profile master "A Master's Thesis" 'Master of Science'
printf '%s\n' '% dissertation_language: zh' >> "${WORK_DIR}/degree/profile.tex"
expect_pass language_mismatch
expect_log language_mismatch 'dissertation_language is zh but manus/main.tex does not load the class with the zh option.'
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
expect_pass milestone_quoted_limit
if command -v pdfinfo >/dev/null 2>&1; then
    expect_log milestone_quoted_limit 'Page limit: ?/7 (milestones/defense/milestone.yml).'
fi
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

printf 'ok    degree-level metadata, English/Chinese prose-advisory, placeholder, language, requirement, milestone page-limit, chapter-wiring, and failed-build cases behave as expected\n'
