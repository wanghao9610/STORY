# STORY skill roots (Pi)

Pi can discover the same workflow skills under `.pi/skills/` and `.agents/skills/`. This project excludes `.agents/skills/` from Pi discovery in `.pi/settings.json`; always load the Pi-owned copy under `.pi/skills/`.

Invoke skills through the prompt templates under `.pi/prompts/`: `/story-<name>`, `/story` to route a request, or `/story-auto <goal>` to pursue a goal across the unmarked skills, stopping at any skill marked †. The `.agents` tree is the tool-neutral shared source and does not replace Pi's entry points.
