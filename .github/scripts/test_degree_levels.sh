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
for expected in 'chatbot-residue' 'formulaic-contrast' 'stock-signposting' 'findings are advisory, not proof of AI authorship'; do
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

printf 'ok    degree-level metadata and English/Chinese prose-advisory cases behave as expected\n'
