# STORY 学位论文工作流规范

**语言：** [English](writing-workflow-conventions.md) | 简体中文

本文是所有 `story-*` skill 的共享契约。STORY 全称为 **Systematic Toolchain for Organizing Research over Years**；一个仓库对应一部硕士或博士学位论文。

## 1. 事实源

| 问题 | 权威文件或目录 |
| --- | --- |
| 适用什么学位与学校规定？ | `degree/profile.tex`、`degree/requirements.md` |
| 委员会由谁组成？ | `degree/committee.md` |
| 学位论文的中心论点是什么？ | `notes/story.md` |
| 学位贡献有哪些？ | `notes/contributions.md` |
| 复用了哪些已发表材料，怎样复用？ | `notes/publications.md` |
| 每章应承担什么任务？ | `notes/outline.md` |
| 一项论断在哪里陈述、由什么证据支持？ | `notes/claims.md` |
| 被引文献实际支持什么？ | `notes/refs/` |
| 一次考核、答辩或归档尝试提出了什么要求？ | `milestones/<slug>/` |
| 还有什么尚未解决？ | `tasks/` |

聊天记录和 `.story/memory/` 永远不能覆盖这些文件。

### 学位层级契约

`degree/profile.tex` 记录经作者确认的 `% degree_level: master|doctoral`。只有这两个值合法。缺失或非法值均为 `unknown`：只读工作流应报告该状态；任何将作出层级相关判断的工作流都应停止，请作者确认并写入档案。不得从题名、学位名称、章节数量、出版物或对话中推断学位层级。

工作流中的通用称呼使用“学位论文”；只有在层级或正式文种名称重要时，才使用“硕士学位论文”“博士学位论文”或学校规定的正式措辞。`degree/requirements.md` 中的学校要求始终优先于通用预期。

- `doctoral` 模式按照已确认的博士要求，检查成果是否形成原创、重要且达到学位论文层级的贡献；研究主线需要时，还要检查跨研究综合。
- `master` 模式按照已确认的硕士要求，界定范围适当的学位贡献。贡献可以是原创结果、应用、复现、验证、设计或基于证据的综合。除非培养项目或已确认的研究设计要求，不得强制要求出版物、多项研究、领域级原创性或独立综合章节。
- 两种模式采用相同的证据、引用、作者归属、可复现与禁止虚构标准。学位层级改变的是预期范围和审查量尺，不改变来源追溯门槛。
- 只创建并检查培养项目明确要求的里程碑。开题、年度考核、预答辩、外审或口头答辩不会仅因出现在通用名册中就自动成为必需项。

### 写作元数据的延迟创建

新克隆的 STORY 只包含 `notes/.gitkeep` 和 `notes/refs/.gitkeep`。
`notes/` 下的 Markdown 产物不再作为空模板预置，而是在首次使用时由负责它的 skill 创建：

| 产物 | 首次创建者 |
| --- | --- |
| `notes/adopt.md` | `story-proj-adopt` |
| `notes/story.md`、`notes/contributions.md`、`notes/publications.md`、`notes/claims.md` | `story-syns-coach`；接入已有草稿时，`story-proj-adopt` 可以初始化 `notes/claims.md` |
| `notes/outline.md`、`notes/notation.md` | `story-outl-planner` |
| `notes/style.md` | `story-copy-editor style` |
| `notes/refs/refs_index.md`、`notes/refs/<key>.md` | `story-refs-curator` |

产物缺失表示对应工作流阶段尚未初始化，本身不代表仓库损坏。
负责的 skill 应在第一次持久写入前创建该文件，保留任何已有内容，并在同一次修改中创建英文与简体中文 Markdown 对照文件。
消费方 skill 发现必需产物缺失时，应停止并路由给首次创建者，不能自行发明替代 schema。
改变 `STORY_LANG` 绝不能翻译或替换已有产物。

## 2. 证据契约

1. 文件只有在 `mates/MANIFEST.md` 中有条目且指纹匹配后，才能成为证据。
2. `mates/` 不得原地修改。应从来源刷新已导入材料，或把修正版登记为新记录。
3. `manus/` 中每项定量或比较性陈述，都要有邻近的 `% src: mates/<path>#<anchor>` 注释或 claim ledger 证据链接。
4. 缺少证据时写成 `\todo{...}`。绝不能插值、凭记忆补全或编造一个看似合理的数值。
5. 对文献内容的陈述必须有本轮核查过的阅读笔记或已导入来源。
6. STAGE 论文可以提供措辞和已发表结果，但不能取代底层 STAR 证据、合作者归属或复用政策。

## 3. 论断与贡献状态

论断 ID 使用 `C001`、`C002`，依此类推。有效状态为：

- `proposed`：已纳入论文计划，但尚未写入正文；
- `drafted`：已写入 `manus/`，但尚未审计；
- `verified`：表述与证据一致；
- `weakened`：根据证据或审查意见缩小了适用范围；
- `unsourced`：已陈述内容缺少充分证据；
- `retired`：有意移除，正文中不再陈述。

学位贡献 ID 使用 `D001`、`D002`，依此类推；`D` 表示 *degree*，不是 *doctoral*。每条贡献都必须写明研究问题、证据、已有出版物（如有）、章节、作者归属和状态。一个章节不自动构成一项贡献；一篇出版物也不自动构成一项学位贡献。

## 4. 出版物复用与作者归属

在改编一篇论文中的大段文字、图、表或结构前，先在 `notes/publications.md` 中新增或确认相应条目，并记录：

- 完整作者名单；
- 作者本人的贡献；
- 候选学位论文章节；
- 复用或改编的材料；
- 版权、许可或培养项目政策状态；
- 必须改写或披露的内容重叠。

不得把协作成果描述为候选人独立完成。不得因材料公开可访问而推定已有复用许可。

## 5. 章节契约

章节文件采用 `manus/chaps/<n>_<slug>.tex`。数字前缀、`notes/outline.md` 和 `manus/main.tex` 的输入顺序必须一致。

每份章节简报都要写明用途、研究问题、贡献 ID、claim ID、所需证据、计划图表、依赖关系和完成条件。复用已发表内容时，研究章节必须重写进学位论文的研究主线；拼接多篇论文的引言和结论不构成综合。没有已确认理由时，不得给硕士学位论文强加发表式结构或独立综合章节。

前置部分放在 `manus/fronts/`；附录及其他后置部分放在 `manus/backs/`。项目专用 LaTeX 命令写在 `manus/main.tex`，不能写入可复用的 class 或 package。

## 6. 里程碑契约

每项适用的持久事件放在 `milestones/<slug>/` 下，并带有一份由用户确认的 `milestone.yml`。建议字段为：

```yaml
kind: defense
status: planned
due: ""
requirements_source: ""
max_pages: ""
confirmed_by: ""
confirmed_on: ""
```

收到的反馈原样复制到 `feedback/`。`response/` 下的逐点记录把每条意见映射为一种处理状态：`accepted`、`completed`、`planned`、`disagreed` 或 `needs-author`。承诺的修改还要成为 `tasks/` 下的复选框。

存在未解决的 `\todo`、lint 失败、未勾选的学校要求、未兑现的反馈承诺、缺失的复用许可或任何未记录的必需批准时，最终 `deposit` 里程碑处于 blocked 状态。

## 7. 交互、语言与来源记录

- `INVOLVE=low|medium|high` 控制 skill 就判断性选择询问作者的频率。它绝不能绕过对学校事实、作者归属、删除、覆盖或最终冻结的确认。
- `STORY_LANG=en|zh` 控制回复和新写 Markdown；未设置时跟随对话。已有文件不会自动翻译。
- `STORY_MAIN` 选择构建与 lint 的默认论文入口；命令行 `--main` 可覆盖它，但两者都不会改变 `degree/profile.tex` 记录的论文语言。
- 学位层级和论文语言都来自 `degree/profile.tex`；不能因为对话措辞而切换其中任何一项。
- 带日期的产物使用系统日期。记录模型来源时使用会话提供的 model ID，绝不能编造。
- 一个 skill 只修改自己拥有的文件；目标文件归属其他 skill 时应路由工作。

## 8. 验证

- 任何 `manus/` 下的修改最后都要运行 `bash execs/run.sh`。
- 引用、参考文献、todo、元数据、页数限制或归档就绪状态可能变化时，运行 `bash execs/scpts/lint.sh`。
- 本轮重新读取每个被引用的证据值；记忆中的数值或指纹不足以构成核验。
- `wkdrs/` 下的报告可以再生成。持久决定应更新 `degree/`、`notes/`、`milestones/` 或 `tasks/`。
- 完成报告要说明构建 PDF、页数、lint 结论、ledger 变化和剩余关口。

## 9. Skill 名录

标记 † 的 skill 仅可显式调用：它们会改变论文级结构、里程碑处理或学校归档包，只有作者直接选择后才能运行。Codex 通过 `.codex/skills/*/agents/openai.yaml` 执行此限制；其他 harness 树使用 `disable-model-invocation: true`。

| Skill | 负责内容 |
| --- | --- |
| `story-proj-adopt` † | 安全接入已有草稿 |
| `story-evid-curator` | 证据导入、登记与完整性 |
| `story-syns-coach` † | 论文级研究主线与贡献框架 |
| `story-outl-planner` † | 章节架构和简报 |
| `story-chap-drafter` | 每轮起草一章 |
| `story-tabs-builder` | 证据驱动表格 |
| `story-figs-designer` | 证据驱动图及可编辑源文件 |
| `story-refs-curator` | 参考文献与阅读笔记 |
| `story-copy-editor` | 语言、术语、衔接与一致性 |
| `story-clms-auditor` | 定量内容与论断可追溯审计 |
| `story-cite-auditor` | 引用键和文献陈述审计 |
| `story-exam-reviewer` | 模拟外审或委员会审查 |
| `story-revs-resolver` † | 反馈逐点记录与处理 |
| `story-defn-builder` † | 答辩叙事与演示文稿 |
| `story-depo-packer` † | 归档预检、打包和冻结记录 |
| `story-flow-status` | 只读状态与下一步建议 |
