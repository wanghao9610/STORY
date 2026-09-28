#!/usr/bin/env bash
# What the gate and provenance hooks decide is behavior, not text a grep can pin,
# so this runs them against fixture payloads: the Claude bash gate and the three
# edit gates at INVOLVE=low, with the STORY red lines (mates/, degree/,
# miles/*/feedback/, and outward transfers) that keep their prompt; the
# Claude level resolver, on a fixture transcript, through its jq and its python3
# reader; the Claude
# model-id resolver on a delegate's transcript, and the command its SessionStart
# line injects, run as injected under zsh; the commands the Qwen Code and DSH
# lines inject, run as injected over a transcript path with a space in it, and
# the Qwen Code resolver past a malformed transcript line; Codex's post-write
# model-id check; the commit guard copies with no JSON parser on PATH; and the
# guard's push and tag rules.
# check_consistency.sh runs it, so pre-push and CI both do.
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cd "${ROOT_DIR}" || exit 1
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/story-hooks.XXXXXX")" || exit 1
trap 'rm -rf "${WORK_DIR}"' EXIT
FAILURES=0

fail() { printf 'FAIL  hooks: %s\n' "$*"; FAILURES=$((FAILURES + 1)); }

for tool in jq python3; do
    command -v "${tool}" >/dev/null 2>&1 || { fail "${tool} is needed to build the fixtures"; exit 1; }
done

PROJ="${WORK_DIR}/thesis"
mkdir -p "${PROJ}"
printf 'INVOLVE=low\n' > "${PROJ}/.env"

# A PATH with every tool the hooks call except jq, so the python3 branches run.
NOJQ="${WORK_DIR}/nojq"
mkdir -p "${NOJQ}"
for tool in bash cat dirname grep head sed tail tr python3 find basename; do
    ln -s "$(command -v "${tool}")" "${NOJQ}/${tool}"
done

# A PATH with no JSON parser at all, so the hand-written fallbacks run.
NOPARSER="${WORK_DIR}/noparser"
mkdir -p "${NOPARSER}"
for tool in bash cat dirname grep head sed tail tr wc git; do
    ln -s "$(command -v "${tool}")" "${NOPARSER}/${tool}"
done

allow_word='"permissionDecision":"allow"'

# The hook's stdout for one payload; $1 = hook, $2 = payload, the rest = env.
run_hook() {
    local hook="$1" payload="$2"
    shift 2
    printf '%s' "${payload}" | env "$@" bash "${hook}" 2>/dev/null
}

bash_payload() { # $1 = command, $2 = transcript path
    jq -cn --arg c "$1" --arg t "${2:-}" '{tool_name: "Bash", tool_input: {command: $c}, transcript_path: $t}'
}

edit_payload() { # $1 = file path, $2 = transcript path
    jq -cn --arg p "$1" --arg t "${2:-}" '{tool_name: "Edit", tool_input: {file_path: $p}, transcript_path: $t}'
}

expect_bash() { # $1 = allow|prompt, $2 = command
    local out
    out="$(run_hook .claude/hooks/story_bash_gate.sh "$(bash_payload "$2")" CLAUDE_PROJECT_DIR="${PROJ}")"
    case "$1" in
        allow) [[ "${out}" == *"${allow_word}"* ]] || fail "bash gate at low keeps a prompt for: $2" ;;
        prompt) [[ -z "${out}" ]] || fail "bash gate at low answers a red-line command: $2" ;;
    esac
}

# 1. Claude bash gate at low: ordinary commands pass, red lines keep the prompt.
for c in \
    'ls -la manus' \
    'grep -rn "src:" manus/chaps' \
    'bash execs/run.sh' \
    'bash execs/scpts/lint.sh --no-build' \
    'cat mates/MANIFEST.md' \
    "sed -n '1,20p' degree/requirements.md" \
    'shasum -a 256 mates/proj/results.md' \
    'bash execs/scpts/import.sh --source ../proj --slug proj mates/proj' \
    'git add mates/MANIFEST.md' \
    'git commit -m "register evidence in mates/"' \
    'echo done > wkdrs/reports/x.md' \
    'curl -s https://api.crossref.org/works/10.1/x' \
    'curl -sL -H "Accept: application/x-bibtex" https://doi.org/10.1/x' \
    'curl -XGET -o wkdrs/reports/x.json https://api.crossref.org/works/10.1/x' \
    'wget -T 10 -O wkdrs/reports/x.pdf https://arxiv.org/pdf/2101.00001' \
    'rsync -a manus/ wkdrs/backup/manus/'; do
    expect_bash allow "${c}"
done
for c in \
    'rm draft.tex' \
    'git push origin main' \
    'git clean -fd' \
    'git restore .' \
    'bash -c "git stash clear"' \
    'tlmgr install biblatex' \
    'mv -f a b' \
    'cd manus && sudo make install' \
    'cp notes/x.csv mates/manual/x.csv' \
    'sed -i s/0.81/0.82/ mates/proj/results.csv' \
    'echo x > miles/defense/feedback/comments.md' \
    'printf x >> degree/requirements.md' \
    'tee degree/profile.tex < /dev/null' \
    'python3 fix.py mates/proj/results.csv' \
    "$(printf 'cat > mates/manual/x.md <<EOF\nnew\nEOF')" \
    'git checkout -- mates/proj/results.md' \
    'git diff --output=mates/proj/results.md' \
    'git log --output degree/requirements.md' \
    'tree -o degree/tree.txt .' \
    'less -o degree/log.txt notes/outline.md' \
    'python3 -c "open(\"degree/profile.tex\",\"w\")"' \
    'gh release create v1 wkdrs/builds/main.pdf' \
    'scp wkdrs/builds/main.pdf me@host:/tmp/' \
    'sftp me@host' \
    'ftp ftp.example.org' \
    'rclone copy manus remote:thesis' \
    'rsync -av manus/ me@host:thesis/' \
    'rsync -a manus/ rsync://host/thesis/' \
    'curl -T wkdrs/builds/main.pdf https://example.org/upload' \
    'curl -sT wkdrs/builds/main.pdf https://example.org/upload' \
    'curl --upload-file main.pdf https://example.org/' \
    'curl -F "file=@main.pdf" https://example.org/upload' \
    'curl --form file=@main.pdf https://example.org/upload' \
    'curl --data-binary @main.pdf https://example.org/' \
    'curl -d @notes/claims.md https://example.org/' \
    'curl -sd@notes/claims.md https://example.org/' \
    'wget --post-file=main.pdf https://example.org/'; do
    expect_bash prompt "${c}"
done

# 2. The three edit gates at low: an edit in the manuscript passes, the
#    protected records and the dot-directories keep the prompt.
expect_edit() { # $1 = allow|prompt, $2 = path relative to the project
    local out
    out="$(run_hook .claude/hooks/story_involve_gate.sh "$(edit_payload "${PROJ}/$2")" CLAUDE_PROJECT_DIR="${PROJ}")"
    case "$1" in
        allow) [[ "${out}" == *"${allow_word}"* ]] || fail "Claude edit gate at low keeps a prompt for $2" ;;
        prompt) [[ -z "${out}" ]] || fail "Claude edit gate at low answers the prompt for $2" ;;
    esac
    out="$(run_hook .qwen/hooks/story_involve_gate.sh "$(edit_payload "${PROJ}/$2")" QWEN_PROJECT_DIR="${PROJ}")"
    case "$1" in
        allow) [[ "${out}" == *"${allow_word}"* ]] || fail "Qwen edit gate at low keeps a prompt for $2" ;;
        prompt) [[ -z "${out}" ]] || fail "Qwen edit gate at low answers the prompt for $2" ;;
    esac
    out="$(cd "${PROJ}" && jq -cn --arg c "$(printf '*** Begin Patch\n*** Update File: %s\n@@\n-a\n+b\n*** End Patch' "$2")" \
        '{tool_name: "apply_patch", tool_input: {command: $c}}' \
        | bash "${ROOT_DIR}/.codex/hooks/story_involve_gate.sh" 2>/dev/null)"
    case "$1" in
        allow) [[ "${out}" == *'"behavior":"allow"'* ]] || fail "Codex edit gate at low keeps a prompt for $2" ;;
        prompt) [[ -z "${out}" ]] || fail "Codex edit gate at low answers the prompt for $2" ;;
    esac
}
expect_edit allow manus/chaps/01_intro.tex
expect_edit allow miles/defense/response/points.md
expect_edit prompt mates/MANIFEST.md
expect_edit prompt degree/profile.tex
expect_edit prompt miles/defense/feedback/comments.md
expect_edit prompt .env
expect_edit prompt manus/../../outside.tex

# 3. The level resolver. .env says medium; the transcript decides the rest.
printf 'INVOLVE=medium\n' > "${PROJ}/.env"
TRANSCRIPT="${WORK_DIR}/session.jsonl"
typed() { # $1 = command name, $2 = its args, or nothing for a bare command
    local text="<command-message>${1#/}</command-message>\n<command-name>$1</command-name>"
    [[ $# -ge 2 ]] && text="${text}\n<command-args>$2</command-args>"
    printf '{"type":"user","isSidechain":false,"message":{"role":"user","content":"%s"}}\n' "${text}"
}
dispatch() { # $1 = skill, $2 = args
    printf '{"type":"assistant","isSidechain":false,"message":{"role":"assistant","model":"m","content":[{"type":"tool_use","id":"t","name":"Skill","input":{"skill":"%s","args":"%s"}}]}}\n' "$1" "$2"
}
meta() { # $1 = skill whose body the Skill tool loaded
    printf '{"type":"user","isMeta":true,"isSidechain":false,"message":{"role":"user","content":[{"type":"text","text":"<command-message>%s</command-message>\\n<command-name>%s</command-name>\\n<skill-format>true</skill-format>"}]}}\n' "$1" "$1"
}
chat() { # $1 = plain message text
    printf '{"type":"user","isSidechain":false,"message":{"role":"user","content":"%s"}}\n' "$1"
}
level() { # $1 = PATH to run under; prints the resolved level for TRANSCRIPT
    PATH="$1" bash -c '. .claude/hooks/story_involve_level.sh; story_involve_level "$1" "$2"' _ \
        "{\"transcript_path\":\"${TRANSCRIPT}\"}" "${PROJ}"
}
expect_level() { # $1 = expected level, $2 = case name; TRANSCRIPT holds the case
    local reader got
    for reader in jq python3; do
        if [[ "${reader}" == jq ]]; then got="$(level "${PATH}")"; else got="$(level "${NOJQ}")"; fi
        [[ "${got}" == "$1" ]] || fail "level resolver (${reader}): $2 resolved '${got}', expected '$1'"
    done
}

: > "${TRANSCRIPT}"
expect_level medium 'no STORY command falls back to .env'
typed /story-chap-drafter '3 involve=low' > "${TRANSCRIPT}"
expect_level low 'a typed involve=low sets the level'
meta story-flow-status >> "${TRANSCRIPT}"
expect_level low 'a skill body the Skill tool loads resets nothing'
chat 'about <command-name>/story-flow-status</command-name> here' >> "${TRANSCRIPT}"
expect_level low 'chat text quoting a command tag resets nothing'
dispatch story-flow-status 'involve=high' >> "${TRANSCRIPT}"
expect_level high 'a Skill call may raise the level'
dispatch story-chap-drafter '3 involve=low' >> "${TRANSCRIPT}"
expect_level low 'a Skill call may come back down to the typed level'
typed /story-flow-status >> "${TRANSCRIPT}"
expect_level medium 'a bare typed command falls back to .env'
dispatch story-chap-drafter '3 involve=low' >> "${TRANSCRIPT}"
expect_level medium 'a Skill call never lowers the level below the typed one'
typed /goal '/story-auto finish chapter 3 involve=low' >> "${TRANSCRIPT}"
expect_level low 'a command wrapping a typed STORY command counts as typed'
typed /story 'draft chapter 4' >> "${TRANSCRIPT}"
expect_level medium 'the next typed STORY command replaces the level'
typed /story-chap-drafter '3\nkeep the method section short\ninvolve=low' >> "${TRANSCRIPT}"
expect_level low 'a token typed on a later line of the args counts'
typed /story 'draft chapter 4' >> "${TRANSCRIPT}"
typed /goal '/story-auto finish chapter 3\ninvolve=low' >> "${TRANSCRIPT}"
expect_level low 'a wrapped STORY command typed over several lines counts'
# /story-auto is itself a typed STORY command: its token holds for the whole
# goal run, including a skill the run starts without repeating the token, such
# as the story-flow-status pass that opens every loop. A Skill call with no
# token changes nothing; one read as a bare typed command would fall back to
# .env's medium here.
typed /story-flow-status >> "${TRANSCRIPT}"
typed /story-auto 'chapter 3 drafted and audited involve=low' >> "${TRANSCRIPT}"
expect_level low 'a typed /story-auto sets the level for its goal run'
dispatch story-flow-status '' >> "${TRANSCRIPT}"
meta story-flow-status >> "${TRANSCRIPT}"
dispatch story-chap-drafter '3' >> "${TRANSCRIPT}"
meta story-chap-drafter >> "${TRANSCRIPT}"
expect_level low 'a skill the goal run starts without a token keeps the typed level'
# A line that does not parse is skipped by both readers, never the end of the
# read: the bare command after it still resets the level to .env.
printf '%s\n' '{"type":"user","isSidechain":false,"message":{"content":"<command-name>/story-x</command-name>' >> "${TRANSCRIPT}"
typed /story-flow-status >> "${TRANSCRIPT}"
expect_level medium 'a malformed transcript line hides no later typed command'

# ...and a gate follows the resolved level, not .env alone.
typed /story-chap-drafter '3 involve=low' > "${TRANSCRIPT}"
out="$(run_hook .claude/hooks/story_bash_gate.sh "$(bash_payload 'ls' "${TRANSCRIPT}")" CLAUDE_PROJECT_DIR="${PROJ}")"
[[ "${out}" == *"${allow_word}"* ]] || fail 'bash gate ignores the involve=low a typed command set over .env medium'
out="$(run_hook .claude/hooks/story_involve_gate.sh "$(edit_payload "${PROJ}/manus/main.tex" "${TRANSCRIPT}")" CLAUDE_PROJECT_DIR="${PROJ}")"
[[ "${out}" == *"${allow_word}"* ]] || fail 'edit gate ignores the involve=low a typed command set over .env medium'
typed /story-flow-status > "${TRANSCRIPT}"
dispatch story-chap-drafter '3 involve=low' >> "${TRANSCRIPT}"
out="$(run_hook .claude/hooks/story_bash_gate.sh "$(bash_payload 'ls' "${TRANSCRIPT}")" CLAUDE_PROJECT_DIR="${PROJ}")"
[[ -z "${out}" ]] || fail 'bash gate lets a Skill call grant itself involve=low'

# 4. The Claude model-id resolver reads a delegate's own transcript: every turn
#    there is sidechain, and a flat path finds the workflow layout by name.
SESSION_DIR="${WORK_DIR}/projects/sess"
mkdir -p "${SESSION_DIR}/subagents/workflows/wf_x"
printf '%s\n' '{"type":"assistant","isSidechain":true,"message":{"model":"claude-delegate-1"}}' \
    > "${SESSION_DIR}/subagents/workflows/wf_x/agent-a1.jsonl"
printf '%s\n' '{"type":"assistant","isSidechain":false,"message":{"model":"claude-session-1"}}' \
    '{"type":"assistant","isSidechain":true,"message":{"model":"claude-delegate-1"}}' \
    > "${WORK_DIR}/projects/sess.jsonl"
for reader in jq python3; do
    if [[ "${reader}" == jq ]]; then p="${PATH}"; else p="${NOJQ}"; fi
    got="$(PATH="${p}" bash .claude/hooks/story_model_id.sh --resolve "${SESSION_DIR}/subagents/agent-a1.jsonl")"
    [[ "${got}" == claude-delegate-1 ]] || fail "model-id resolver (${reader}) read '${got}' from a delegate's flat path, expected claude-delegate-1"
    got="$(PATH="${p}" bash .claude/hooks/story_model_id.sh --resolve "${SESSION_DIR}/subagents/workflows/wf_x/agent-a1.jsonl")"
    [[ "${got}" == claude-delegate-1 ]] || fail "model-id resolver (${reader}) read '${got}' from a workflow delegate's transcript"
    got="$(PATH="${p}" bash .claude/hooks/story_model_id.sh --resolve "${WORK_DIR}/projects/sess.jsonl" 'claude-session-1[1m]')"
    [[ "${got}" == 'claude-session-1[1m]' ]] || fail "model-id resolver (${reader}) read '${got}' from the session transcript, expected its main-loop model"
done

#    The SessionStart line hands the agent a command to run in its own shell,
#    often zsh, where a bare `[1m]` suffix is a glob and an unmatched glob fails
#    the whole command. Each argument comes out quoted — through the jq, the
#    python3, and the parser-less encoder alike — and the command runs as
#    injected. The transcript path, with a space in it, does not exist, so the
#    resolver answers with the session model.
for reader in jq python3 none; do
    case "${reader}" in jq) p="${PATH}" ;; python3) p="${NOJQ}" ;; *) p="${NOPARSER}" ;; esac
    ctx="$(jq -cn --arg t "${WORK_DIR}/projects/no such.jsonl" '{model: "claude-opus-5-5[1m]", transcript_path: $t}' \
        | PATH="${p}" bash .claude/hooks/story_model_id.sh 2>/dev/null | jq -r '.hookSpecificOutput.additionalContext' 2>/dev/null)"
    injected="${ctx#*run: }"; injected="${injected%% — then*}"
    [[ "${injected}" == 'bash .claude/hooks/story_model_id.sh --resolve '*' claude-opus-5-5\[1m\]' ]] || \
        fail "model-id SessionStart line (${reader}) injects an unquoted command: ${injected}"
    if command -v zsh >/dev/null 2>&1; then
        got="$(zsh -fc "${injected}" 2>/dev/null)"
        [[ "${got}" == 'claude-opus-5-5[1m]' ]] || \
            fail "model-id SessionStart line (${reader}) injects a command zsh cannot run: got '${got}'"
    fi
done

#    Qwen Code and DSH hand over the same kind of command. Their project-dir
#    variables may hold a space, so the command names the resolver by its path
#    from the project root; a transcript path with a space and a bracketed model
#    id are quoted, so the command, run as injected under bash and zsh, reads the
#    transcript it names rather than splitting its path into two arguments.
QWEN_CHATS="${WORK_DIR}/John Smith/chats"
mkdir -p "${QWEN_CHATS}"
printf '%s\n' '{"type":"user","message":"hi"}' '{"type":"assistant","model":"qwen3-coder-plus"}' \
    > "${QWEN_CHATS}/s.jsonl"
DSH_LOG="${WORK_DIR}/John Smith/dsh/session.jsonl"
mkdir -p "${DSH_LOG%/*}"
printf '%s\n' '{"type":"request/context","data":{"provider":"deepseek","model":"deepseek-v4"}}' > "${DSH_LOG}"
shells=(bash)
command -v zsh >/dev/null 2>&1 && shells+=(zsh)
# $1 = hook, $2 = payload, $3 = project-dir variable, set to a path with a
# space in it, $4 = the hook's PATH; prints the injected command.
injected_command() {
    local ctx out
    ctx="$(printf '%s' "$2" | env PATH="$4" "$3=${WORK_DIR}/My Thesis" bash "$1" 2>/dev/null \
        | jq -r '.hookSpecificOutput.additionalContext' 2>/dev/null)"
    out="${ctx#*run: }"
    printf '%s' "${out%% — then*}"
}
# $1 = label, $2 = injected command, $3 = expected output.
expect_resolves() {
    local sh got
    for sh in "${shells[@]}"; do
        if [[ "${sh}" == zsh ]]; then got="$(zsh -fc "$2" 2>/dev/null)"; else got="$(bash -c "$2" 2>/dev/null)"; fi
        [[ "${got}" == "$3" ]] || fail "$1 injects a command ${sh} runs to '${got}', expected '$3': $2"
    done
}
for reader in jq python3 none; do
    case "${reader}" in jq) p="${PATH}" ;; python3) p="${NOJQ}" ;; *) p="${NOPARSER}" ;; esac
    injected="$(injected_command .qwen/hooks/story_model_id.sh \
        "$(jq -cn --arg t "${QWEN_CHATS}/s.jsonl" '{model: "qwen3-coder-plus", transcript_path: $t}')" QWEN_PROJECT_DIR "${p}")"
    [[ "${injected}" == 'bash .qwen/hooks/story_model_id.sh --resolve '* ]] || \
        fail "Qwen model-id SessionStart line (${reader}) does not name the resolver from the project root: ${injected}"
    expect_resolves "Qwen model-id SessionStart line (${reader})" "${injected}" qwen3-coder-plus
    injected="$(injected_command .qwen/hooks/story_model_id.sh \
        "$(jq -cn --arg t "${QWEN_CHATS}/no such.jsonl" '{model: "qwen3-coder[1m]", transcript_path: $t}')" QWEN_PROJECT_DIR "${p}")"
    expect_resolves "Qwen model-id SessionStart line (${reader}, bracketed model)" "${injected}" 'qwen3-coder[1m]'
    injected="$(injected_command .dsh/hooks/story_model_id.sh \
        "$(jq -cn --arg t "${DSH_LOG}" '{session_id: "s", transcript_path: $t}')" CLAUDE_PROJECT_DIR "${p}")"
    [[ "${injected}" == 'bash .dsh/hooks/story_model_id.sh --resolve '* ]] || \
        fail "DSH model-id SessionStart line (${reader}) does not name the resolver from the project root: ${injected}"
    expect_resolves "DSH model-id SessionStart line (${reader})" "${injected}" deepseek/deepseek-v4
done
#    A malformed transcript line, in the middle or first, hides no later turn
#    from the Qwen Code resolver, through its jq and its python3 reader alike.
printf '%s\n' '{"type":"assistant","model":"qwen3-coder-plus"}' '{"type":"assistant","mod' \
    '{"type":"assistant","model":"qwen3-max"}' > "${QWEN_CHATS}/torn.jsonl"
printf '%s\n' '{"type":"assist' '{"type":"assistant","model":"qwen3-max"}' > "${QWEN_CHATS}/torn-first.jsonl"
for reader in jq python3; do
    if [[ "${reader}" == jq ]]; then p="${PATH}"; else p="${NOJQ}"; fi
    for torn in torn torn-first; do
        got="$(PATH="${p}" bash .qwen/hooks/story_model_id.sh --resolve "${QWEN_CHATS}/${torn}.jsonl")"
        [[ "${got}" == qwen3-max ]] || fail "Qwen model-id resolver (${reader}) read '${got}' past a malformed line in ${torn}.jsonl, expected qwen3-max"
    done
done

# 5. Codex closes provenance with a write-after check: a mismatch fails with its
#    diagnostic, an exact match passes, and `unrecorded` passes only when the
#    rollout and the session model are both absent.
ROLLOUT="${WORK_DIR}/rollout.jsonl"
ARTIFACT="${WORK_DIR}/memory-entry.md"
printf '%s\n' '{"type":"turn_context","payload":{"model":"gpt-5.6-sol"}}' > "${ROLLOUT}"
printf '%s\n' '---' 'model_id: gpt-5' '---' > "${ARTIFACT}"
out="$(bash .codex/hooks/story_model_id.sh --check "${ARTIFACT}" "${ROLLOUT}" gpt-5.6-sol 2>&1)" && \
    fail 'Codex model-id check accepted gpt-5 against rollout gpt-5.6-sol'
[[ "${out}" == *"expected 'gpt-5.6-sol', found 'gpt-5'"* ]] || fail "Codex model-id mismatch lacks its diagnostic: ${out}"
printf '%s\n' '---' 'model_id: gpt-5.6-sol' '---' > "${ARTIFACT}"
bash .codex/hooks/story_model_id.sh --check "${ARTIFACT}" "${ROLLOUT}" gpt-5.6-sol 2>/dev/null || \
    fail 'Codex model-id check rejected gpt-5.6-sol against rollout gpt-5.6-sol'
#    The check accepts what --resolve told the run to copy, the session id's
#    suffix included.
printf '%s\n' '---' 'model_id: gpt-5.6-sol[1m]' '---' > "${ARTIFACT}"
bash .codex/hooks/story_model_id.sh --check "${ARTIFACT}" "${ROLLOUT}" 'gpt-5.6-sol[1m]' 2>/dev/null || \
    fail 'Codex model-id check rejected gpt-5.6-sol[1m], which --resolve prints for rollout gpt-5.6-sol and session gpt-5.6-sol[1m]'
printf '%s\n' '---' 'model_id: unrecorded' '---' > "${ARTIFACT}"
bash .codex/hooks/story_model_id.sh --check "${ARTIFACT}" "" "" 2>/dev/null || \
    fail 'Codex model-id check rejected unrecorded with no rollout and no session model'
bash .codex/hooks/story_model_id.sh --check "${ARTIFACT}" "" gpt-5.6-sol 2>/dev/null && \
    fail 'Codex model-id check accepted unrecorded although SessionStart named gpt-5.6-sol'
bash .codex/hooks/story_model_id.sh --check "${ARTIFACT}" 2>/dev/null
[[ $? -eq 2 ]] || fail 'Codex model-id check does not exit 2 on a wrong argument count'

# 6. The commit guard still declines on a machine with no JSON parser: each
#    payload-reading copy falls back to reading the command field out of the raw
#    JSON and decoding its escapes, so the add on a command's second line is
#    still its own segment. (Pi's copy takes the command as its argument and
#    parses nothing.)
for tree in .claude .codex .dsh .kimi-code .qwen .cursor; do
    for c in 'git add -A' 'git status\ngit add -A' 'git commit -m \"say \\\"hi\\\"\"\ngit add -A'; do
        if [[ "${tree}" == .cursor ]]; then
            payload="{\"command\":\"${c}\"}"
        else
            payload="{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"${c}\"}}"
        fi
        out="$(printf '%s' "${payload}" | PATH="${NOPARSER}" bash "${tree}/hooks/story_commit_guard.sh" 2>/dev/null)"
        [[ "${out}" == *deny* ]] || fail "${tree}/hooks/story_commit_guard.sh lets a blanket add through with no JSON parser on PATH: ${c}"
    done
done

# 7. A tag or a remote ref has more ways to move or go than `tag -d`, `tag -f`
#    and `push -f`: a remote delete, a +refspec, an empty-source refspec, and
#    update-ref on a tag or with --stdin are declined too, while an ordinary
#    push, the matching push `:`, and depo-packer's `git tag -a` pass. The core
#    is shared, so the Claude copy and Pi's, the one check there, stand for all
#    seven.
expect_guard() { # $1 = deny|pass, $2 = command
    local out status
    out="$(run_hook .claude/hooks/story_commit_guard.sh "$(bash_payload "$2")")"
    case "$1" in
        deny) [[ "${out}" == *'"permissionDecision":"deny"'* ]] || fail "commit guard lets through: $2" ;;
        pass) [[ -z "${out}" ]] || fail "commit guard declines: $2" ;;
    esac
    status=0
    bash .pi/extensions/story-hooks/story_commit_guard.sh "$2" >/dev/null 2>&1 || status=$?
    case "$1" in
        deny) (( status == 1 )) || fail "Pi commit guard lets through: $2" ;;
        pass) (( status == 0 )) || fail "Pi commit guard declines: $2" ;;
    esac
}
for c in \
    'git push origin --delete v1.0-deposit' \
    'git push -d origin v1' \
    'git push origin :refs/tags/v1.0-deposit' \
    'git push origin +main' \
    'git push origin +HEAD:main' \
    "git push --prune origin 'refs/tags/*:refs/tags/*'" \
    'git update-ref -d refs/tags/v1' \
    'git update-ref refs/tags/v1 HEAD' \
    'git update-ref --stdin'; do
    expect_guard deny "${c}"
done
for c in \
    'git push origin main' \
    'git push origin :' \
    'git push -u origin main' \
    'git push origin HEAD:main' \
    'git push origin --tags' \
    'git tag -a v1.0-deposit -m "deposit freeze"'; do
    expect_guard pass "${c}"
done

if (( FAILURES > 0 )); then
    printf '%d hook fixture failure(s).\n' "${FAILURES}"
    exit 1
fi
printf 'ok    hooks: bash and edit gates keep the red lines at low, the level resolver never lets a Skill call lower the typed level, the Claude, Qwen Code and Codex model-id resolvers hold their contract, the injected Claude, Qwen Code and DSH commands run as injected over a spaced transcript path, every commit guard declines with no JSON parser, and the guard declines remote deletes, +refspecs and update-ref on a tag or with --stdin while an ordinary push passes\n'
