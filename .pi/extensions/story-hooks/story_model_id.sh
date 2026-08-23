#!/usr/bin/env bash
# Pi passes the live model to the extension before each agent run and again after
# a model change, so this provenance value is current at the writing turn.
model="${1:-}"

if [[ -n "${model}" ]]; then
    printf '%s\n' "STORY provenance: this Pi run's runtime-reported model id is ${model}. When a STORY skill records model_id or model_trail (writing-workflow-conventions section 8), copy this exact string verbatim; do not write 'unrecorded'."
else
    printf '%s\n' "STORY provenance: Pi reported no model id for this run. When a STORY skill records model_id or model_trail (writing-workflow-conventions section 8), write 'unrecorded' and do not guess."
fi
