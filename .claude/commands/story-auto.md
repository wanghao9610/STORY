---
description: Pursue a stated thesis goal, starting each next unmarked STORY skill and stopping at any † skill
argument-hint: "GOAL [involve=low]"
disable-model-invocation: true
---

Read `.agents/commands/story-auto.md` and follow it with this invocation: [$ARGUMENTS]

Start an unmarked skill with the Skill tool, so the Claude-only frontmatter rendered into its Claude-owned copy applies, such as `effort: medium` on `story-flow-status`. A skill marked † is never started: print the exact `/story-<name> <argument>` command as the run's `Next action:` and stop, as the shared file says. Empty brackets mean no goal: ask for one.
