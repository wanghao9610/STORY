#!/usr/bin/env bash
# Pi passes the live model to the extension before each agent run and again after
# a model change, so this provenance value is current at the writing turn.
model="${1:-}"

if [[ -n "${model}" ]]; then
    printf '%s\n' "STORY provenance: this Pi run's runtime-reported model id is ${model}. When you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), copy this exact string verbatim; do not write 'unrecorded'."
else
    printf '%s\n' "STORY provenance: Pi reported no model id for this run. When you write a \`model_id\` (in STORY, a \`.story/memory/\` file's frontmatter; writing-workflow-conventions section 7), copy the model id this session's own context states outright, if it states one; otherwise write 'unrecorded'. Do not guess."
fi
