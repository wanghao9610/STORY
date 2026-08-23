---
name: story-syns-coach
disable-model-invocation: true
description: 根据作者意图和已登记证据建立或修改硕士/博士学位论文的研究问题、中心论点、研究主线、综合结论和学位贡献；适用于提纲前或论文缺少连贯论证时。
---

# 建立适合学位层级的综合叙事

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

界定问题或贡献前，先从 `degree/profile.tex` 解析 `% degree_level: master|doctoral`。缺失或非法时停止，请作者确认并写入；不得从成果看起来有多大、是否发表过论文等信息推断层级。应用规范 §1 的分层契约和已确认的学校评审量尺。

读取 `degree/profile.tex`、相关已登记证据，以及存在的 `notes/story.md`、`notes/contributions.md`、`notes/publications.md` 和 `notes/claims.md`。仅就仓库无法给出的判断询问作者：预期中心论点、贡献边界、作者归属、排除范围和研究随时间的变化。

首次使用时，在实际写入之前初始化缺失的产物；绝不能用骨架覆盖已有文件。使用规范 §3 定义的 ID、字段格式和状态，并采用以下 schema：

- `notes/story.md`：frontmatter 键为 `status: discovery`、`active_milestone: ""` 和 `updated: <系统日期>`；标题为 `One-sentence thesis`、`Research problem`、`Central argument`、`Research questions`、`Research arc`、`Cross-chapter synthesis`、`Scope and limitations`；已有文件中的旧标题 `Doctoral problem` 可以继续识别，但未经作者确认不主动改名；
- `notes/contributions.md`：`ID | Contribution | Research question | Evidence | Publications | Chapters | Attribution | Status`；
- `notes/publications.md`：`ID | Citation / artifact | Authors | Candidate chapters | Reused material | Permission / policy | Author contribution | Status`；
- `notes/claims.md`：`ID | Claim | Contribution | Stated in | Evidence | Status | Notes`。

论文叙事初始化为 `discovery`，新贡献初始化为 `proposed`，新出版物/复用记录在作者确认纳入范围前初始化为 `candidate`，新论断初始化为 `proposed`。只有满足规范 §3 中相应定义后才能提升状态。

按照规范 §1 和 §7，在同一次修改中创建配对的 `*.zh-CN.md` 产物。

产出：

1. 一条可论证且有证据支持的一句话总论点；
2. 适合学位层级的研究问题与具体研究问题；
3. 一条说明各项贡献之间关系的有序研究主线；单项研究型硕士论文则说明其范围明确的研究路径；
4. 与已确认层级相称的论文级综合：博士模式在研究主线需要时形成原创的跨研究综合；硕士模式整合范围内证据，不虚构多论文要求；
5. 局限与范围；
6. `notes/publications.md` 中实际纳入范围的每篇论文、预印本或协作产物的发表/复用记录，不假定硕士论文一定已有发表；
7. `notes/contributions.md` 中的贡献记录，并链接到证据、发表论文、章节和作者归属；
8. `notes/claims.md` 中状态为 `proposed` 的论断记录。

中心论点与贡献/归属映射必须经作者确认后，才能把 `notes/story.md` 标为 `finalized`。硕士模式不得把范围明确的贡献夸大成博士级原创性；博士模式不得免除已确认的原创与综合要求。本 skill 不选择学校规范或章节文件。
