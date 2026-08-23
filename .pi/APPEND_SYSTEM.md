# STORY skill roots (Pi)

**Language:** English | [简体中文](APPEND_SYSTEM.zh-CN.md)

Pi can discover the same workflow skills under `.pi/skills/` and `.agents/skills/`. This project excludes `.agents/skills/` from Pi discovery in `.pi/settings.json`; always load the Pi-owned copy under `.pi/skills/`.

Invoke skills through the prompt templates under `.pi/prompts/`: `/story-<name>`, or `/story` to route a request. The `.agents` tree is the tool-neutral shared source and does not replace Pi's entry points.
