#!/usr/bin/env bash
# fmt.sh keeps a reformat only when the typeset text is unchanged, and what
# latexindent does to a sentence beside a brace is behavior a grep cannot pin,
# so this runs it: fmt.sh and the repository's .latexindent.yaml are copied
# into a scratch repository, and fixture chapters are checked, reformatted, and
# refused there. A newline before a closing brace is a space the PDF prints, so
# a sentence that ends a group has to keep its `}` or `]` on the same line, and
# a rewrite that would add or drop that space has to be refused, never copied
# over the source. Each case compares the typeset text before and after under
# a whitespace normalization of its own, not fmt.sh's. Without latexindent
# there is nothing to run, and it skips.
# check_consistency.sh runs it, so pre-push and CI both do.
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"

if ! command -v latexindent >/dev/null 2>&1; then
    printf 'skip  fmt: latexindent is not installed, so the reformat guard is not exercised\n'
    exit 0
fi

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/story-fmt.XXXXXX")" || exit 1
trap 'rm -rf "${WORK_DIR}"' EXIT
FAILURES=0

fail() { printf 'FAIL  fmt: %s\n' "$*"; FAILURES=$((FAILURES + 1)); }

mkdir -p "${WORK_DIR}/execs/scpts" "${WORK_DIR}/manus/chaps" "${WORK_DIR}/orig" "${WORK_DIR}/indent"
cp "${ROOT_DIR}/execs/scpts/fmt.sh" "${WORK_DIR}/execs/scpts/fmt.sh"
cp "${ROOT_DIR}/.latexindent.yaml" "${WORK_DIR}/.latexindent.yaml"

# The typeset text, as TeX reads the source: a whitespace run is one space, a
# blank line ends a paragraph, a space at a group edge is kept, and a `%` drops
# the rest of its line, the line end, and the next line's indent.
typeset_text() {
    perl -0777 -ne 's/(?<!\\)%.*\n[ \t]*(?=\n)/\n/g; s/(?<!\\)%.*\n?[ \t]*//g;
        print join "\n\n", map { s/\s+/ /g; s/^ | $//g; $_ } split /\n[ \t]*\n\s*/, $_' "$1"
}

# A fixture chapter from stdin, with a pristine copy to compare against.
fixture() {
    cat > "${WORK_DIR}/manus/chaps/$1.tex"
    cp "${WORK_DIR}/manus/chaps/$1.tex" "${WORK_DIR}/orig/$1.tex"
}

# fmt.sh on one fixture from the scratch repository root; its exit code in RC.
RC=0
run_fmt() {
    local log="$1"
    shift
    RC=0
    (cd "${WORK_DIR}" && bash execs/scpts/fmt.sh "$@") > "${log}" 2>&1 || RC=$?
}

show_log() { sed 's/^/      /' "$1"; }

# --check reports the drift and writes nothing; the rewrite then keeps the
# typeset text, carries the expected line, leaves no closer at a line start, and
# is itself clean.
expect_reformat() {
    local name="$1" want="$2"
    local file="${WORK_DIR}/manus/chaps/${name}.tex" log="${WORK_DIR}/${name}.log"

    run_fmt "${log}" --check "manus/chaps/${name}.tex"
    if (( RC != 1 )) || ! grep -qF 'are not one sentence per line' "${log}"; then
        fail "${name}: --check did not report drift (exit ${RC})"
        show_log "${log}"
    fi
    cmp -s "${WORK_DIR}/orig/${name}.tex" "${file}" || fail "${name}: --check wrote to the file"

    run_fmt "${log}" "manus/chaps/${name}.tex"
    if (( RC != 0 )) || ! grep -qF 'reformatted 1 file(s)' "${log}"; then
        fail "${name}: fmt.sh did not reformat it (exit ${RC})"
        show_log "${log}"
        return
    fi
    grep -qF -- "${want}" "${file}" || { fail "${name}: the result has no line with '${want}'"; show_log "${file}"; }
    if grep -qE '^[[:space:]]*[]}]' "${file}"; then
        fail "${name}: a closing brace or bracket was moved to a line of its own"
        show_log "${file}"
    fi
    [[ "$(typeset_text "${WORK_DIR}/orig/${name}.tex")" == "$(typeset_text "${file}")" ]] || \
        fail "${name}: the kept reformat changed the typeset text"

    run_fmt "${log}" --check "manus/chaps/${name}.tex"
    (( RC == 0 )) || { fail "${name}: the reformatted file is not clean on --check (exit ${RC})"; show_log "${log}"; }
}

# latexindent's rewrite really does change the typeset text, so the refusal is
# for the right reason; fmt.sh then refuses it with the hand-fix hint (the line
# that carries the given phrase), in both modes, and the source keeps every byte.
expect_refused() {
    local name="$1" hint="${2:-alone on its line}"
    local file="${WORK_DIR}/manus/chaps/${name}.tex" log="${WORK_DIR}/${name}.log"
    local cand="${WORK_DIR}/indent/${name}.tex"

    cp "${file}" "${cand}"
    if ! latexindent -m -l="${WORK_DIR}/.latexindent.yaml" -s -w -c "${WORK_DIR}/indent" \
        -g "${WORK_DIR}/indent/indent.log" "${cand}" >/dev/null 2>&1; then
        fail "${name}: latexindent failed on the fixture"
        return
    fi
    if [[ "$(typeset_text "${file}")" == "$(typeset_text "${cand}")" ]]; then
        fail "${name}: latexindent's rewrite keeps the typeset text, so this case no longer exercises the guard"
        return
    fi

    for mode in --check write; do
        if [[ "${mode}" == write ]]; then
            run_fmt "${log}" "manus/chaps/${name}.tex"
        else
            run_fmt "${log}" --check "manus/chaps/${name}.tex"
        fi
        if (( RC != 2 )) || ! grep -qF 'REFUSED: 1 file(s)' "${log}"; then
            fail "${name}: fmt.sh ${mode} did not refuse a rewrite that changes the typeset text (exit ${RC})"
            show_log "${log}"
        fi
        grep -qF -- "${hint}" "${log}" || fail "${name}: the refusal does not give the hand fix ('${hint}')"
        cmp -s "${WORK_DIR}/orig/${name}.tex" "${file}" || fail "${name}: fmt.sh ${mode} wrote to a refused file"
    done
}

# A file already one sentence per line: --check passes it and writes nothing.
# Given the refused fixture it hand-fixes, it also typesets exactly as that one
# does, so a hint whose fix changes the text fails here.
expect_clean() {
    local name="$1" refused="${2:-}"
    local file="${WORK_DIR}/manus/chaps/${name}.tex" log="${WORK_DIR}/${name}.log"

    run_fmt "${log}" --check "manus/chaps/${name}.tex"
    if (( RC != 0 )) || ! grep -qF 'ok: 1 file(s)' "${log}"; then
        fail "${name}: the file is not clean on --check (exit ${RC})"
        show_log "${log}"
    fi
    cmp -s "${WORK_DIR}/orig/${name}.tex" "${file}" || fail "${name}: --check wrote to the file"
    if [[ -n "${refused}" ]] && \
        [[ "$(typeset_text "${WORK_DIR}/orig/${refused}.tex")" != "$(typeset_text "${file}")" ]]; then
        fail "${name}: the hand fix for ${refused} changes the typeset text"
    fi
}

# 1. A sentence that ends a group keeps the group's closer on its line: the
#    defect-review reproductions, a single sentence in a group after a sentence
#    break, a multi-sentence caption, and an optional argument.
fixture emph <<'EOF'
We counted. \emph{Two things. Three things.} and More.
EOF
expect_reformat emph 'Three things.} and More.'

fixture emph_single <<'EOF'
We found it. Some text \emph{One thing.} and more.
EOF
expect_reformat emph_single 'Some text \emph{One thing.} and more.'

fixture table_title <<'EOF'
\textbf{Table 1. Main results.}
EOF
expect_reformat table_title 'Main results.}'

fixture caption <<'EOF'
\begin{figure}
    \centering
    \caption{Accuracy on the test set. Higher is better.}
    \label{fig:accuracy}
\end{figure}
EOF
expect_reformat caption 'Higher is better.}'

fixture short_title <<'EOF'
\section[Short. Title.]{Long title. Here.}
EOF
expect_reformat short_title 'Title.]{Long title.'

# 2. A closer already alone on its line, as an earlier fmt.sh left a sentence
#    and its `}`, or as an argument spelled over several lines, holds a space
#    the rewrite would drop: refused, and untouched.
fixture split_closer <<'EOF'
\textbf{Table 1.
    Main results.
}
EOF
expect_refused split_closer

fixture split_options <<'EOF'
\includegraphics[
    width=\linewidth
]{figs/accuracy.pdf}
EOF
expect_refused split_options

# 3. The hand fixes the refusal names are clean and typeset as the refused file
#    does. A `{%` wrapper's closer takes the place of the bare `%` above it: that
#    `%` only ate the line end before the `}`, while the line end after it is a
#    space, here between two boxes, that a `%` kept after the `}` would eat. A
#    `{%` group around running prose goes on one line without the `%`, and a
#    sentence that follows a closing brace on its line, which latexindent would
#    join to what precedes it without a space, goes on a line of its own.
fixture wrapper <<'EOF'
\begin{table}
    \centering
    \resizebox{0.4\linewidth}{!}{%
        \begin{tabular}{l}
            a \\
        \end{tabular}%
    }
    \resizebox{0.4\linewidth}{!}{%
        \begin{tabular}{l}
            b \\
        \end{tabular}%
    }
\end{table}
EOF
expect_refused wrapper 'in place of the bare %'

fixture wrapper_fixed <<'EOF'
\begin{table}
    \centering
    \resizebox{0.4\linewidth}{!}{%
        \begin{tabular}{l}
            a \\
        \end{tabular}}
    \resizebox{0.4\linewidth}{!}{%
        \begin{tabular}{l}
            b \\
        \end{tabular}}
\end{table}
EOF
expect_clean wrapper_fixed wrapper

# A closer whose own line ends in `%` keeps that `%` after it.
fixture wrapper_kept <<'EOF'
\begin{figure}
    \centering
    \resizebox{0.4\linewidth}{!}{%
        \begin{tabular}{l}
            a \\
        \end{tabular}%
    }%
    \hfill
\end{figure}
EOF

fixture wrapper_kept_fixed <<'EOF'
\begin{figure}
    \centering
    \resizebox{0.4\linewidth}{!}{%
        \begin{tabular}{l}
            a \\
        \end{tabular}}%
    \hfill
\end{figure}
EOF
expect_clean wrapper_kept_fixed wrapper_kept

fixture prose_group <<'EOF'
The box \mbox{%
the first result%
}
and more.
EOF
expect_refused prose_group 'write it on one line without the %'

fixture prose_group_fixed <<'EOF'
The box \mbox{the first result} and more.
EOF
expect_clean prose_group_fixed prose_group

fixture todo_sentence <<'EOF'
We know. \todo{Fill in the value.} The end.
EOF
expect_refused todo_sentence 'goes on a line of its own'

fixture todo_sentence_fixed <<'EOF'
We know.
\todo{Fill in the value.}
The end.
EOF
expect_clean todo_sentence_fixed todo_sentence

fixture group_sentence <<'EOF'
We see \emph{One thing.} here. The end.
EOF
expect_refused group_sentence 'goes on a line of its own'

fixture group_sentence_fixed <<'EOF'
We see \emph{One thing.} here.
The end.
EOF
expect_clean group_sentence_fixed group_sentence

# A `%` glued to a sentence end, after a command or not, eats the space before
# the next line's sentence, and the split puts it back: refused. Its hand fix,
# the comment on a line of its own, is the one that does not typeset as the
# refused file does: it adds exactly that space, as the hint says.
fixture glued_comment <<'EOF'
The results hold.\footnote{See the log.}% keep tight
More here.
EOF
expect_refused glued_comment "a '%' glued to the end of a sentence"

fixture glued_comment_plain <<'EOF'
The results hold.% keep tight
More here.
EOF
expect_refused glued_comment_plain "a '%' glued to the end of a sentence"

fixture glued_comment_fixed <<'EOF'
The results hold.\footnote{See the log.}
% keep tight
More here.
EOF
expect_clean glued_comment_fixed
[[ "$(typeset_text "${WORK_DIR}/orig/glued_comment_fixed.tex")" == \
    "$(typeset_text "${WORK_DIR}/orig/glued_comment.tex" | sed 's/}More/} More/')" ]] || \
    fail "glued_comment_fixed: the hand fix does more than add the space the glued % ate"

# 4. A period glued to a footnote, a citation, or a label ends its sentence after
#    the command, and one before an escaped or thin space ends none: a break
#    between the period and what follows it would add a space. Such a sentence
#    stays whole on its own line: a sentence after it is split off, and a line
#    that continues it in lowercase is joined to it.
fixture glued <<'EOF'
The results are good.\footnote{See the appendix.}
The value rose by 3.\cite[p.~4]{x}
As shown in the table.\label{tab:x}
We cite Smith et al.\cite{x} and more.
We cite Smith et al.\cite{x}, and more.
We follow Smith et al.\ The results hold.
EOF
expect_clean glued

fixture glued_footnote <<'EOF'
It works well.\footnote{See the appendix.} It is fast.
EOF
expect_reformat glued_footnote 'It works well.\footnote{See the appendix.}'

fixture glued_wrapped <<'EOF'
We cite Smith et al.\cite{x}
and more work.
EOF
expect_reformat glued_wrapped 'We cite Smith et al.\cite{x} and more work.'

fixture glued_thin <<'EOF'
See Fig.\,3 for more. It holds.
EOF
expect_reformat glued_thin 'See Fig.\,3 for more.'

if (( FAILURES > 0 )); then
    printf '%d fmt fixture failure(s).\n' "${FAILURES}"
    exit 1
fi
printf 'ok    fmt: a sentence that ends a group keeps its closing brace or bracket on its line with the typeset text unchanged, --check reports drift without writing, a period glued to a command stays with its sentence, a rewrite that would add or drop a space at a group edge is refused and left untouched, and the hand fixes the refusal names are clean and typeset as the refused file does, but for the one for a glued comment, which adds only the space the %% ate\n'
