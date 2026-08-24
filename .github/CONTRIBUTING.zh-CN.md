# 维护 STORY harness

**语言：** [English](CONTRIBUTING.md) | 简体中文

`.agents/skills/` 是全部十六个学位论文 skill 的中立创作源。六个私有 skill 根目录（`.claude`、`.cursor`、`.dsh`、`.kimi-code`、`.pi`、`.qwen`）是生成的入口树；不要直接编辑其中的链接文件。

Codex 元数据是存储方向上唯一的例外：`.codex/skills/<name>/agents/openai.yaml` 拥有各自的 manifest，而 `.agents/skills/<name>/agents/openai.yaml` 链接到它，因为 Codex 会发现中立根目录。`allow_implicit_invocation: false` 标记出六个仅限显式调用的 skill；它们的私有 `SKILL.md` 和 `SKILL_zh.md` 由脚本生成，并带有 `disable-model-invocation: true`。

## `argument-hint` 不做跨 harness 移植

`argument-hint` **不在**中立源里。`port.sh` 为每个 skill 的每种语言各持有一条 hint，只注入到真正读取该字段的 harness，因此 `.claude` 与 `.qwen` 下的 `SKILL.md` 和 `SKILL_zh.md` 是生成的普通文件而不是链接。

| 树 | `argument-hint` | 原因 |
|---|---|---|
| `.claude` | 生成进 manifest | Claude Code 读取该字段并在 `/` 菜单中显示 |
| `.qwen` | 生成进 manifest | Qwen Code 读取该字段；`allowedTools` 不移植，因为它是授予而不是限制 |
| `.agents` | 从不写入 | 这是 Codex 的发现根目录，其市场校验器拒绝 `name`、`description`、`license`、`allowed-tools`、`metadata` 之外的任何键 |
| `.cursor` | 从不写入 | Cursor 的 frontmatter 字段表是封闭的，不含该字段 |
| `.dsh`、`.kimi-code` | 从不写入 | 该键会被保留并忽略——一个无人报错的失效字段 |
| `.pi` | 仅 prompt 模板 | 在 Pi 中它不是 skill 字段，因此 hint 写在 `.pi/prompts/<skill>.md` 里 |

每条 hint 都遵循[规约 §7](../docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md) 的形状：`[TARGET] [DESCRIPTION] [involve=<level>]`。大写占位符是作者填入的值，小写单词是字面模式；`SKILL_zh.md` 中只翻译自由文本占位符 `DESCRIPTION`，因为目标、模式和 token 在任何语言下都保持英文。新增 skill 时必须同时在 `port.sh` 的 `argument_hint()` 中补上它的 hint——缺失时移植会直接失败，而不会发布一个没有 hint 的 skill。任何树都不携带 `allowed-tools`：Claude 之外的预授权属于项目级或用户级配置改动，作用范围比 Claude 的单轮授权更广。

编辑中立 skill 或 Codex 策略后运行：

```bash
bash .github/scripts/port.sh --write
bash .github/scripts/check_consistency.sh
```

`port.sh --check` 同时核验内容和存储形态。与中立源逐字相同的私有文件必须是指向 `.agents` 的相对链接；harness 专属文件必须是普通文件。命令、prompt、hook 和设置保留在各 harness 目录中，因为它们的调用语法、事件、载荷或注册机制不同。

`execs/update.sh` 在更新或接入其他学位论文仓库时跟随并展开链接，使上游模板保持去重，下游安装也不必依赖未选择的 harness 树。

每个英文 Markdown 文件都必须有简体中文对照版。普通文档使用 `*.zh-CN.md`，skill 指令使用 `SKILL_zh.md`。证据 manifest 是唯一的存储例外：由于 `mates/` 只读，其译文放在 `docs/mds/story-workflow/mates-MANIFEST.zh-CN.md`。每一对文件中的路径、ID、命令、状态值、代码块和运行策略必须等价；缺少中文对照时，`check_consistency.sh` 会失败。
