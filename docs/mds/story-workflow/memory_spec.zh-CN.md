# STORY 项目记忆

**语言：** [English](memory_spec.md) | 简体中文

项目记忆只保存会话中发现、且没有其他仓库文件认领的持久事实。它用于导航，永远不能作为证据。

## 可以记录什么

| 类型 | 用途 | 示例 |
| --- | --- | --- |
| `env` | 机器或 TeX 工具链事实 | 某台机器缺少一个宏包 |
| `pref` | 作者长期写作偏好 | 每次只审阅一章 |
| `insight` | 可复用的项目洞见 | 上游表格 ID 比行号更适合作为锚点 |
| `deadend` | 已尝试并否决的路径 | 模拟外审失败的论述框架 |

已有归属的事实不得进入记忆：证据属于 `mates/`，论断属于 `notes/claims.md`，学校要求属于 `degree/`，发表复用属于 `notes/publications.md`，反馈属于 `milestones/`，承诺属于 `tasks/`。

## 目录

```text
.story/memory/
├── MEMORY.md
├── <slug>.md
└── local/               # 机器专用，git 忽略
    ├── MEMORY.md
    └── <slug>.md
```

一个文件只记录一项事实，frontmatter 包含 `type`、`scope`、`language`、`verified`、`model_id` 和 `source`。合法 scope 为 `global`、`machine:<name>`、`milestone:<slug>`、`manus:<path>`。日期使用系统日期，模型 ID 使用运行时报告值，均不得猜测。

## 索引格式

`MEMORY.md` 按最新在前排列：

```text
- <type> · <scope> · <verified> · [<slug>](<slug>.md) — <一行事实>
```

会话钩子按字节解析分隔符，只注入以 `- ` 开头的行。使用前先打开链接文件；超过 180 天的 `env` 记忆会被标为 stale。

事实仍成立时更新日期与模型 ID；发生变化时写入替代项并删除旧项；原本错误的记忆直接删除。历史由 Git 保存。
