#!/usr/bin/env bash
# STORY sessionStart hook (Cursor) — inject the runtime-reported model id into
# session context so skills record a real model_id instead of "unrecorded".
#
# Cursor puts `model_id` (structured id) and `model` on the sessionStart payload,
# and injects the returned `additional_context` string into the conversation.
# When neither is present, the injected line has the writer copy an id the
# session's own context states outright, else write "unrecorded"
# (writing-workflow-conventions section 7). Registered under
# hooks.sessionStart in .cursor/hooks.json.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  model=$(printf '%s' "$input" | jq -r '.model_id // .model // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  model=$(printf '%s' "$input" | python3 -c 'import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get("model_id") or d.get("model") or "")
except Exception:
    print("")' 2>/dev/null)
else
  model=$(printf '%s' "$input" | grep -oE '"model_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
  [ -z "$model" ] && model=$(printf '%s' "$input" | grep -oE '"model"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
fi

if [ -n "${model:-}" ]; then
  ctx="STORY provenance: this session's runtime-reported model id is ${model}. When you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), copy this exact string verbatim; do not write 'unrecorded'."
else
  ctx="STORY provenance: the sessionStart payload carried no model id for this session. When you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), copy the model id this session's own context states outright, if it states one; otherwise write 'unrecorded'. Do not guess."
fi

# ctx is controlled text with no double quotes or backslashes, so this is valid JSON.
printf '{"additional_context":"%s"}\n' "$ctx"
