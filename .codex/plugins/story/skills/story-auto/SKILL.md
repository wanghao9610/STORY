---
name: story-auto
description: Pursue the thesis goal an explicitly invoked $story-auto request states, starting each next unmarked STORY skill under that invocation's grant and stopping at any skill marked †. Do not use unless the user typed $story-auto.
---

# Pursue a thesis goal

Read `.agents/commands/story-auto.md` from the current project root and follow it as the authoritative procedure.
Write the user-facing wording in the language the workflow conventions §7 resolve: the author's explicit request first, then a valid `STORY_LANG` in `.env`, then the conversation's language. `.agents/commands/story-auto.md` is the only procedure; its decisions do not change with the language.

Adapt only its invocation spelling for Codex:

- `$story-auto <goal> [involve=<level>]` is this command.
- `$story-<name> <argument>` is the spelling where the shared file writes `/story-<name> <argument>`.

For an unmarked skill, load and follow that `story-*` skill from the current project's available skills.
A skill marked `†` is never started: show the exact `$story-<name> <argument>` invocation as the run's `Next action:` and stop, as the shared file says.

If `.agents/commands/story-auto.md` is missing, report that the project does not contain the STORY goal-run procedure instead of guessing from the plugin package.
