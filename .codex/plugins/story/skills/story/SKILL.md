---
name: story
description: Route an explicitly invoked $story request to exactly one master's or doctoral STORY thesis workflow skill. With no request, show the current thesis status. Do not use after a specific story-* skill has already been selected.
---

# Route a STORY request

Read `.agents/commands/story.md` from the current project root and follow it as the authoritative routing roster.

Adapt only its invocation spelling for Codex:

- `$story` is this generic router.
- `$story-<name> <argument>` invokes the selected project skill where the roster writes `/story-<name> <argument>`.
- `$story-auto <goal>` is the spelling where the roster writes `/story-auto <goal>`: this plugin's goal-run entry, which the author types.

Do not reproduce a selected skill's workflow from this router.
For an unmarked skill, load and follow that `story-*` skill from the current project's available skills.
For a skill marked `†`, do not start it and do not ask whether to: show the exact `$story-<name> <argument>` invocation for the author to type, with `involve=<level>` where the roster says to spell it out, and stop.

If `.agents/commands/story.md` is missing, report that the project does not contain the STORY routing roster instead of guessing from the plugin package.
