# Maintaining STORY harnesses

**Language:** English | [简体中文](CONTRIBUTING.zh-CN.md)

`.agents/skills/` is the neutral authored source for all sixteen master's/doctoral thesis skills. The six private skill roots (`.claude`, `.cursor`, `.dsh`, `.kimi-code`, `.pi`, `.qwen`) are generated entry trees; do not edit a linked file there.

Codex metadata is the one exception to this storage direction: `.codex/skills/<name>/agents/openai.yaml` owns each manifest, and `.agents/skills/<name>/agents/openai.yaml` links to it because Codex discovers the neutral root. `allow_implicit_invocation: false` marks the six explicit-only skills, and their private `SKILL.md` and `SKILL_zh.md` files are generated with `disable-model-invocation: true`.

## `argument-hint` does not port

`argument-hint` is **not** in the neutral source. `port.sh` owns one hint per skill per language and injects it only where the harness reads it, so `.claude` and `.qwen` hold generated `SKILL.md` and `SKILL_zh.md` files rather than links.

| Tree | `argument-hint` | Why |
|---|---|---|
| `.claude` | generated into the manifest | Claude Code reads it and shows it in the `/` menu |
| `.qwen` | generated into the manifest | Qwen Code reads it; `allowedTools` stays out, because it grants rather than restricts |
| `.agents` | never | this is Codex's discovery root, and its marketplace validator rejects any key outside `name`, `description`, `license`, `allowed-tools`, and `metadata` |
| `.cursor` | never | Cursor's frontmatter table is closed without it |
| `.dsh`, `.kimi-code` | never | the key is kept and ignored — an inert field nothing reports |
| `.pi` | prompt templates only | not a skill field in Pi, so the hint rides in `.pi/prompts/<skill>.md` instead |

Every hint follows the shape in [conventions §7](../docs/mds/story-workflow/writing-workflow-conventions.md): `[TARGET] [DESCRIPTION] [involve=<level>]`. Uppercase placeholders are author-supplied values and lowercase words are literal modes; for `SKILL_zh.md`, translate only the free-text `DESCRIPTION` placeholder, because targets, modes, and tokens stay English everywhere. A new skill needs its hint in `argument_hint()` in `port.sh`; the port fails loudly rather than shipping a skill without one. No tree carries `allowed-tools`: pre-approval outside Claude is a project- or user-level config change with a wider scope than the turn-scoped Claude equivalent.

After editing a neutral skill or a Codex policy, run:

```bash
bash .github/scripts/port.sh --write
bash .github/scripts/check_consistency.sh
```

`port.sh --check` verifies both content and storage shape. A byte-identical private file must be a relative link into `.agents`; a harness-only file must be a real file. Commands, prompts, hooks, and settings remain in their harness directories because their invocation syntax, events, payloads, or registration mechanisms differ.

`execs/update.sh` follows and materializes links when updating or adopting another thesis repository, so the upstream template stays deduplicated and no downstream installation depends on an unselected harness tree.

Every English Markdown file has a Simplified Chinese counterpart. Use `*.zh-CN.md` for ordinary documents and `SKILL_zh.md` for skill instructions. The evidence manifest is the sole storage exception: because `mates/` is read-only, its translation lives at `docs/mds/story-workflow/mates-MANIFEST.zh-CN.md`. Keep paths, IDs, commands, status values, code blocks, and runtime policy equivalent across each pair; `check_consistency.sh` rejects a missing counterpart.
