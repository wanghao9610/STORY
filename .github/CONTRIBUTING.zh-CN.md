# 维护 STORY harness

**语言：** [English](CONTRIBUTING.md) | 简体中文

`.agents/skills/` 是全部十六个学位论文 skill 的中立创作源。六个私有 skill 根目录（`.claude`、`.cursor`、`.dsh`、`.kimi-code`、`.pi`、`.qwen`）是生成的入口树；不要直接编辑其中的链接文件。

Codex 元数据的存储方向例外：`.codex/skills/<name>/agents/openai.yaml` 拥有各自的 manifest，而 `.agents/skills/<name>/agents/openai.yaml` 链接到它，因为 Codex 会发现中立根目录。六个仅限显式调用的 skill 以 `allow_implicit_invocation: false` 标识；它们的私有 `SKILL.md` 和 `SKILL_zh.md` 由脚本生成，并带有 `disable-model-invocation: true`。

编辑中立 skill 或 Codex 策略后运行：

```bash
bash .github/scripts/port.sh --write
bash .github/scripts/check_consistency.sh
```

`port.sh --check` 同时核验内容和存储形态。与中立源逐字相同的私有文件必须是指向 `.agents` 的相对链接；harness 专属文件必须是普通文件。命令、prompt、hook 和设置保留在各 harness 目录中，因为它们的调用语法、事件、载荷或注册机制不同。

`execs/update.sh` 在更新或接入其他学位论文仓库时跟随并展开链接。这样既能让上游模板去重，也不会让下游安装依赖未选择的 harness 树。

每个英文 Markdown 文件都必须有简体中文对照版。普通文档使用 `*.zh-CN.md`，skill 指令使用 `SKILL_zh.md`。证据 manifest 是唯一的存储例外：由于 `mates/` 只读，其译文放在 `docs/mds/story-workflow/mates-MANIFEST.zh-CN.md`。每一对文件中的路径、ID、命令、状态值、代码块和运行策略必须等价；缺少中文对照时，`check_consistency.sh` 会失败。
