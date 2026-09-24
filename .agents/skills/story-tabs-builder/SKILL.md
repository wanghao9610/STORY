---
name: story-tabs-builder
description: Use to build or revise one thesis table (results, comparisons, mappings, synthesis) from fingerprinted evidence, with a source anchor on every quantitative or comparative row and synchronized claim, outline, and notation records. For a design whose message depends on visual encoding, use story-figs-designer.
---

# Build one evidence-backed table

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Resolve one table by its `T` ID or file in `notes/outline.md`, or `new`; without `notes/outline.md` or `notes/notation.md`, route to `story-outl-planner` (conventions §1). For `new`, confirm its purpose, chapter, and claim IDs, then add its `planned` row with them in `Purpose`, `Chapter`, and `Claims` (conventions §3); confirming is a judgment call, and `low` adds the row with the recommended values and reports them.

Generate `manus/tabs/<slug>.tex` as editable LaTeX with accessible headings, stated units, and meaningful precision from registered evidence read in this run, with a source anchor (conventions §2) on every row that carries a number or comparison and `\todo{...}` for a missing value. Use `notes/notation.md` symbols and terms, adding a row (`First use`: the chapter path) for a new one. Without a `cleared` row in `notes/publications.md` (conventions §3), route adapted published material to `story-syns-coach`.

Check that comparisons use compatible datasets, splits, metrics, and directions; put a caveat in the caption or table notes, and route a sentence the chapter text must carry to `story-chap-drafter`. Formatting that marks a value (bold best result, shading, arrows) follows a rule the caption states, computed from the same evidence; a design whose message depends on visual encoding goes to `story-figs-designer`. Never alter evidence.

Include the table only in its owning chapter, and handle `\listoftables` as conventions §7 (Ownership) assigns. In the same change, update the outline row and the claims the table states (conventions §3, Who sets each status), and tick any `tasks/` line the change resolves (§6); then build and lint (§8).
