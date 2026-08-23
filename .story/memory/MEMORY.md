# Project Memory — index

**Language:** English | [简体中文](MEMORY.zh-CN.md)

One line per durable project memory, newest first:

The session hooks under `.claude/hooks/`, `.codex/hooks/`, `.cursor/hooks/`,
`.dsh/hooks/`, `.kimi-code/hooks/`, `.qwen/hooks/`, and `.pi/extensions/story-hooks/`
parse this English index byte-exactly, so its entry shape is fixed:

```text
- <type> · <scope> · <verified> · [<slug>](<slug>.md) — <one-line fact>
```

Valid types are `env`, `pref`, `insight`, and `deadend`. Valid scopes are `global`, `machine:<name>`, `milestone:<slug>`, and `manus:<path>`. Machine-specific entries belong in `.story/memory/local/`.

Nothing already owned by `degree/`, `mates/`, `notes/`, `milestones/`, or `tasks/` belongs here. See `docs/mds/story-workflow/memory_spec.md`.

<!-- entries below -->
