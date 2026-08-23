---
name: story-syns-coach
disable-model-invocation: true
description: 根据作者意图和已登记证据建立或修改博士论文总问题、中心论点、研究问题、研究主线、综合结论和博士贡献；适用于提纲前或论文像多篇文章拼接时。
---

# 建立博士论文综合叙事

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

读取 `degree/profile.tex`、相关已登记证据，以及存在的 `notes/story.md`、`notes/contributions.md`、`notes/publications.md` 和 `notes/claims.md`。仅就仓库无法给出的判断询问作者：预期中心论点、贡献边界、作者归属、排除范围和研究随时间的变化。

首次使用时，在实际写入之前初始化缺失的产物；绝不能用骨架覆盖已有文件。采用以下 schema：

- `notes/story.md`：frontmatter 键为 `status: discovery`、`active_milestone: ""` 和 `updated: <系统日期>`；标题为 `One-sentence thesis`、`Doctoral problem`、`Central argument`、`Research questions`、`Research arc`、`Cross-chapter synthesis`、`Scope and limitations`；
- `notes/contributions.md`：`ID | Contribution | Research question | Evidence | Publications | Chapters | Attribution | Status`；
- `notes/publications.md`：`ID | Citation / artifact | Authors | Candidate chapters | Reused material | Permission / policy | Author contribution | Status`；
- `notes/claims.md`：`ID | Claim | Contribution | Stated in | Evidence | Status | Notes`，状态采用规范 §3 的定义。

按照规范 §1 和 §7，在同一次修改中创建配对的 `*.zh-CN.md` 产物。

产出：

1. 一条可论证且有证据支持的一句话总论点；
2. 博士研究问题与具体研究问题；
3. 一条有序研究主线，说明每项贡献为什么承接前一项贡献；
4. 单篇论文中不存在的跨章节综合；
5. 局限与范围；
6. `notes/publications.md` 中本论文范围内每篇论文、预印本或协作产物的发表/复用记录；
7. `notes/contributions.md` 中的贡献记录，并链接到证据、发表论文、章节和作者归属；
8. `notes/claims.md` 中状态为 `proposed` 的论断记录。

中心论点与贡献/归属映射必须经作者确认后，才能把 `notes/story.md` 标为 `finalized`。本 skill 不选择学校规范或章节文件。
