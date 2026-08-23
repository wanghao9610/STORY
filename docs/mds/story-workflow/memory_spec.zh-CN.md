# STORY 项目记忆

**语言：** [English](memory_spec.md) | 简体中文

项目记忆只保存会话中发现、且没有其他仓库文件负责的持久事实。它用于导航，永远不是证据。

## 哪些内容可以记录

| 类型 | 用途 | 示例 |
| --- | --- | --- |
| `env` | 机器或 TeX 工具链事实 | 某台机器缺少一个宏包 |
| `pref` | 作者长期有效的工作流偏好 | 每次只审阅一章 |
| `insight` | 可复用的项目洞见 | 上游表格 ID 是比行号更稳定的锚点 |
| `deadend` | 已尝试并否决的路径 | 在模拟外审中失败的论述框架 |

已有其他归属的事实不得进入记忆：证据属于 `mates/`，论断属于 `notes/claims.md`，学校要求属于 `degree/`，出版物复用属于 `notes/publications.md`，反馈属于 `milestones/`，承诺属于 `tasks/`。

## 目录结构

```text
.story/memory/
├── MEMORY.md
├── <slug>.md
└── local/               # 机器专属，git 忽略
    ├── MEMORY.md
    └── <slug>.md
```

每项事实单独存放在一个文件中：

```markdown
---
type: env
scope: machine:mbp-a
language: en
verified: 2026-08-23
model_id: runtime-reported-id
source: wkdrs/builds/main.log
---

经确认的事实，以及它为何重要、应当怎样使用。
```

有效 `scope` 为 `global`、`machine:<name>`、`milestone:<slug>` 和 `manus:<path>`。日期使用系统实际日期，model ID 使用运行时报告值；两者都不得猜测。

## 索引格式

`MEMORY.md` 将最新条目放在最前：

```text
- <type> · <scope> · <verified> · [<slug>](<slug>.md) — <one-line fact>
```

会话钩子精确解析这些分隔符。只有以 `- ` 开头的行会被注入。依赖某条索引前，先打开其链接文件。超过 180 天的 `env` 记忆会被钩子标为 stale。

重新核验仍然成立的记忆时，更新其日期和 model ID。事实发生变化时，用新条目替换并移除旧条目；原本错误的记忆直接删除。Git 会保留历史。
