# Maintaining STORY harnesses

**Language:** English | [简体中文](CONTRIBUTING.zh-CN.md)

`.agents/skills/` is the neutral authored source for all sixteen dissertation skills. The six private skill roots (`.claude`, `.cursor`, `.dsh`, `.kimi-code`, `.pi`, `.qwen`) are generated entry trees; do not edit a linked file there.

Codex metadata is the exception to the storage direction: `.codex/skills/<name>/agents/openai.yaml` owns each manifest, and `.agents/skills/<name>/agents/openai.yaml` links to it because Codex discovers the neutral root. The six explicit-only skills are identified by `allow_implicit_invocation: false`; their private `SKILL.md` and `SKILL_zh.md` files are generated with `disable-model-invocation: true`.

After editing a neutral skill or a Codex policy, run:

```bash
bash .github/scripts/port.sh --write
bash .github/scripts/check_consistency.sh
```

`port.sh --check` verifies both content and storage shape. A byte-identical private file must be a relative link into `.agents`; a harness-only file must be a real file. Commands, prompts, hooks, and settings remain in their harness directories because their invocation syntax, events, payloads, or registration mechanisms differ.

`execs/update.sh` follows and materializes links when updating or adopting another dissertation repository. This keeps the upstream template deduplicated without making a downstream installation depend on an unselected harness tree.

Every English Markdown file has a Simplified Chinese counterpart. Use `*.zh-CN.md` for ordinary documents and `SKILL_zh.md` for skill instructions. The evidence manifest is the sole storage exception: because `mates/` is read-only, its translation lives at `docs/mds/story-workflow/mates-MANIFEST.zh-CN.md`. Keep paths, IDs, commands, status values, code blocks, and runtime policy equivalent across each pair; `check_consistency.sh` rejects a missing counterpart.
