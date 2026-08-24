---
name: story-tabs-builder
description: Build or revise one master's or doctoral thesis table from fingerprinted evidence, with source anchors for every data row and synchronized claim/outline records; use for results, comparisons, mappings, and synthesis tables.
argument-hint: "[TABLE | new] [DESCRIPTION] [involve=low]"
---

# Build one evidence-backed table

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. Resolve one table from `notes/outline.md`, or add a `planned` row after confirming its purpose and chapter, using the outline status contract in conventions §3.

Read every source value from registered `mates/` files in this run. Generate `manus/tabs/<slug>.tex` with editable LaTeX, accessible headings, stated units, meaningful precision, and a `% src:` comment for each claim-bearing row. Missing values remain `\todo{...}`; never transcribe from chat or memory.

Check that comparisons use compatible datasets, splits, metrics, and directions. Record any necessary caveat in the caption or nearby prose instead of hiding it in formatting. Update the table row and linked claims, include the table only in its owning chapter, then build and lint.

Do not invent a visual encoding or alter evidence. Route figure-like designs to `story-figs-designer`.
