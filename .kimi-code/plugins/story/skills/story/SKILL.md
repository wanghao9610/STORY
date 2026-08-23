---
name: story
description: Route an explicitly invoked /story request to exactly one master's or doctoral STORY thesis workflow skill. With no request, show the current thesis status. Do not use after a specific story-* skill has already been selected.
disableModelInvocation: true
---

# Route a STORY request

Read `.agents/commands/story.md` from the current project root and follow it as the authoritative routing roster.
When `.env` sets `STORY_LANG=zh`, or it is unset and the conversation is in Chinese, use `.agents/commands/story.zh-CN.md` for the user-facing wording while preserving the English roster's skill names and routing decisions.

Adapt only its invocation spelling for Kimi Code:

- `/story` (shorthand for `/skill:story`) is this generic router.
- `/skill:story-<name> <argument>` invokes the selected project skill where the roster writes `/story-<name> <argument>`.

Do not reproduce a selected skill's workflow from this router.
For an unmarked skill, start it with the Skill tool and follow the Kimi-owned copy from the current project's available skills.
For a skill marked `†`, request the confirmation required by the roster, show the exact `/skill:story-<name> <argument>` invocation, and wait.

If `.agents/commands/story.md` is missing, report that the project does not contain the STORY routing roster instead of guessing from the plugin package.
