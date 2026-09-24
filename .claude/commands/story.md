---
description: Route a request to the right STORY skill, or report the next action
argument-hint: "[what you want to do]"
disable-model-invocation: true
---

Read `.agents/commands/story.md` and apply its router to this request: [$ARGUMENTS]

For an unmarked skill, start the Claude-owned copy with the Skill tool so the Claude-only frontmatter rendered into that copy applies, such as `effort: medium` on `story-flow-status`. An empty request selects `story-flow-status` with no argument.
