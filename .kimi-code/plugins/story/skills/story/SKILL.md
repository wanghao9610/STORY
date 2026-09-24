---
name: story
description: Route an explicitly invoked /story request to exactly one master's or doctoral STORY thesis workflow skill. With no request, show the current thesis status. Do not use after a specific story-* skill has already been selected.
disableModelInvocation: true
---

# Route a STORY request

Read `.agents/commands/story.md` from the current project root and follow it as the authoritative routing roster.
When the reply language resolves to Chinese under the workflow conventions §7 — the author asks for Chinese; or, with no author request for a language, `.env` sets `STORY_LANG=zh`; or `STORY_LANG` is unset or invalid and the conversation is in Chinese — use `.agents/commands/story.zh-CN.md` for the user-facing wording while preserving the English roster's skill names and routing decisions.

Adapt only its invocation spelling for Kimi Code:

- `/story` (shorthand for `/skill:story`) is this generic router.
- `/skill:story-<name> <argument>` invokes the selected project skill where the roster writes `/story-<name> <argument>`.
- `/story-auto <goal>` (shorthand for `/skill:story-auto`) stays as the roster writes it: this plugin's goal-run entry, which the author types.

Do not reproduce a selected skill's workflow from this router.
For an unmarked skill, start it with the Skill tool and follow the Kimi-owned copy from the current project's available skills.
For a skill marked `†`, do not start it and do not ask whether to: show the exact `/skill:story-<name> <argument>` invocation for the author to type, with `involve=<level>` where the roster says to spell it out, and stop.

If `.agents/commands/story.md` is missing, report that the project does not contain the STORY routing roster instead of guessing from the plugin package.
