# STORY 博士论文工作流规范

本文是所有 `story-*` skill 的共享契约。STORY 全称为 **Systematic Toolchain for Organizing Research over Years**；一个仓库对应一部博士学位论文。

## 1. 事实归属

| 问题 | 权威文件或目录 |
| --- | --- |
| 学位与学校规范是什么？ | `degree/profile.tex`、`degree/requirements.md` |
| 委员会由谁组成？ | `degree/committee.md` |
| 学位论文的中心论点是什么？ | `notes/story.md` |
| 博士阶段贡献有哪些？ | `notes/contributions.md` |
| 哪些已发表内容被复用？ | `notes/publications.md` |
| 每章承担什么任务？ | `notes/outline.md` |
| 论断在哪里陈述、由什么支持？ | `notes/claims.md` |
| 被引工作实际支持什么？ | `notes/refs/` |
| 一次考核、答辩或归档发生了什么？ | `milestones/<slug>/` |
| 还有什么没有解决？ | `tasks/` |

聊天记录和 `.story/memory/` 不得覆盖这些文件。

## 2. 证据契约

1. 文件只有在 `mates/MANIFEST.md` 中登记并通过指纹校验后才是证据。
2. `mates/` 不得就地修改；应在源头修正后重新导入，或把修正版登记为新材料。
3. `manus/` 中每项定量或比较性陈述都要有邻近的 `% src: mates/<path>#<anchor>` 注释或论断记录表证据链接。
4. 缔据缺失时写成 `\todo{...}`，不得插值、凭记忆补全或编造合理数字。
5. 对文献内容的陈述必须由本轮检查过的阅读笔记或导入材料支持。
6. STAGE 论文可以提供措辞和公开结果，但不能替代底层 STAR 证据、合作者归属与复用政策。

## 3. 论断与贡献状态

论断 ID 使用 `C001`、`C002`。合法状态为 `proposed`、`drafted`、`verified`、`weakened`、`unsourced`、`retired`。

贡献 ID 使用 `D001`、`D002`。每行必须记录研究问题、证据、论文、章节、作者贡献和状态。章节不自动等于贡献；发表论文也不自动等于博士贡献。

## 4. 发表内容复用与作者贡献

在改写论文中的大段文字、图、表或结构之前，先建立或确认 `notes/publications.md` 行，记录完整作者列表、候选人贡献、拟复用章节、复用内容、版权/许可/培养项目政策，以及需要改写或披露的重叠。

不得把合作工作表述为候选人独立完成；不得因为材料公开可访问就推定具有复用许可。

## 5. 章节契约

章节文件采用 `manus/chaps/<n>_<slug>.tex`；数字前缀、`notes/outline.md` 与 `manus/main.tex` 的输入顺序必须一致。

每份章节简报应说明用途、研究问题、贡献 ID、论断 ID、所需证据、计划图表、依赖关系和完成条件。研究章节必须服务学位论文总叙事，不能简单拼接多篇论文的引言和结论。

前置部分放在 `manus/fronts/`，附录等后置部分放在 `manus/backs/`。项目专用 LaTeX 宏写在 `manus/main.tex`，不写进通用 class 或 package。

## 6. 里程碑契约

每次持久化事件位于 `milestones/<slug>/`，并带一份由用户确认的 `milestone.yml`。收到的反馈原样保存在 `feedback/`；`response/` 的逐点记录将每条意见标为 `accepted`、`completed`、`planned`、`disagreed` 或 `needs-author`，承诺的修改还要成为 `tasks/` 下的复选框。

存在未解决 `\todo`、lint 失败、未勾选学校要求、未兑现反馈、缺失复用许可或未记录委员会批准时，不得宣布 deposit 里程碑完成。

## 7. 交互、语言与来源记录

- `INVOLVE=low|medium|high` 控制判断性问题的询问频率，但不能跳过学校事实、作者贡献、删除、覆盖或最终冻结的确认。
- `STORY_LANG=en|zh` 控制回复与新写 Markdown；为空时跟随对话，已有文件不自动翻译。
- 正文语言来自 `degree/profile.tex`，不能因为对话语言不同而切换。
- 日期取系统日期；模型来源取会话提供的 model ID，不得编造。
- 每个 skill 只修改自己拥有的文件；文件归属变化时把任务路由给对应 skill。

## 8. 验证

- 修改 `manus/` 后运行 `bash execs/run.sh`。
- 引用、交叉引用、todo、元数据、页数限制或归档就绪状态变化时运行 `bash execs/scpts/lint.sh`。
- 本轮重新读取每个被引用的证据值；记忆中的数字或指纹不算验证。
- `wkdrs/` 下报告可再生；持久结论写入 `degree/`、`notes/`、`milestones/` 或 `tasks/`。
- 完成报告说明 PDF 路径、页数、lint 结果、记录表变化和剩余关口。

## 9. Skill 名录

| Skill | 职责 |
| --- | --- |
| `story-proj-adopt` | 安全接入已有草稿 |
| `story-evid-curator` | 证据导入、登记与完整性 |
| `story-syns-coach` | 总研究主线与贡献框架 |
| `story-outl-planner` | 章节架构和简报 |
| `story-chap-drafter` | 每轮起草一章 |
| `story-tabs-builder` | 证据驱动表格 |
| `story-figs-designer` | 证据驱动图及可编辑源文件 |
| `story-refs-curator` | 参考文献与阅读笔记 |
| `story-copy-editor` | 语言、术语、衔接与一致性 |
| `story-clms-auditor` | 数字与论断可追溯审计 |
| `story-cite-auditor` | 引用键和文献陈述审计 |
| `story-exam-reviewer` | 模拟外审或委员会审查 |
| `story-revs-resolver` | 反馈逐点记录与处理 |
| `story-defn-builder` | 答辩叙事与演示文稿 |
| `story-depo-packer` | 归档检查、打包和冻结记录 |
| `story-flow-status` | 只读状态与下一步建议 |
