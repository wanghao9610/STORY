# STORY Agent 指令

**语言：** [English](AGENTS.md) | 简体中文

> 本文件是 [`AGENTS.md`](AGENTS.md) 的中文对照版。Agent 的运行时权威指令仍以英文原文件为准；路径、ID、状态值和命令保持英文。

本仓库使用 STORY——**Systematic Toolchain for Organizing Research over Years**——把多年博士研究整理成连贯、可答辩、可归档的学位论文。

## 1. 范围与权限

- 一个仓库对应一部博士学位论文。
- `degree/` 保存经用户确认的学校和学位事实。不得虚构截止日期、格式规则、委员会决定、作者贡献声明或归档要求。
- `mates/` 是证据库。除通过 `execs/scpts/import.sh` 和 `$story-evid-curator` 外，保持只读。
- `manus/` 是学位论文源文件。论文正文使用 `degree/profile.tex` 中记录的论文语言；结构键、ID、路径和状态保持英文。
- 改变全篇论证、章节边界、作者归属、出版物复用方式或学位要求前必须询问作者。安全的局部选择可以直接完成，不必打断作者。

## 2. 先证据，后正文

- `manus/` 中每项定量或比较性论断，都必须通过附近的 `% src:` 注释或 claim ledger 条目，追溯到带指纹的 `mates/` 文件。
- 缺少证据时必须明确写成 `\todo{...}`，绝不能填入看似合理的虚构数值。
- 对已有文献的陈述必须能在 `notes/refs/` 或已导入的参考材料中核验。
- 错误证据应在来源处修正后重新导入，绝不能静默修改 `mates/` 下的快照。
- 已发表论文是证据，并不自动成为学位论文的最终表述。复用前须协调术语、范围、作者归属和内容重叠。

## 3. 学位论文层面的连贯性

- `notes/story.md` 负责论文级问题、中心论点、研究主线和综合结论。
- `notes/contributions.md` 把博士贡献映射到证据、出版物、章节和候选答辩论断。
- `notes/publications.md` 记录作者、章节复用、许可和内容重叠。协作成果不得暗示为作者独立完成。
- `notes/outline.md` 负责章节顺序和章节简报。章节草稿必须服务于全篇论证，不能只是复刻一篇论文。
- `notes/claims.md` 是论断记录表。引入、移动、削弱或核验论断时，必须在同一次修改中更新它。

## 4. 学位里程碑

- 每次开题、年度考核、预答辩、答辩、修改轮次或归档尝试都放在 `milestones/<slug>/` 下。
- `milestone.yml` 保存用户确认的事实；`feedback/` 原样保留收到的意见；`response/` 记录处理决定；`RECORD_<date>.md` 冻结结果。
- 委员会反馈绝不能原地修改。回复必须区分已完成、计划完成、有理由不同意和需要作者决定的事项。
- `degree/requirements.md` 中仍有必需检查未完成，或 `tasks/` 中仍有未兑现承诺时，不得宣称归档包已经就绪。

## 5. 文件归属

- `manus/fronts/`：摘要、致谢、声明及其他前置部分。
- `manus/chaps/`：编号章节 `<n>_<slug>.tex`。
- `manus/backs/`：附录及其他后置部分。
- `manus/figs/`、`manus/tabs/`、`manus/bibs/`、`manus/stys/`：图、表、参考文献和模板层。
- `degree/`：学位档案、委员会记录和学校要求检查表。
- `notes/`：总叙事、提纲、论断、贡献/出版物映射、符号、风格、接入记录和阅读笔记。
- `wkdrs/`：构建产物和可再生成报告；不得将其视为持久项目状态。
- `tasks/`：持久化的未解决工作和反馈承诺。

## 6. 运行方式

- 只能用 `bash execs/run.sh` 构建；输出放在 `wkdrs/builds/` 下。
- 用 `bash execs/scpts/lint.sh` 运行确定性检查。
- 用 `bash execs/scpts/fmt.sh` 保持一句一行，同时不改变排版后的文本。
- 运行时配置来自由 `.env.example` 复制得到的 `.env`；不得硬编码机器路径。
- `.env` 中的 `STORY_MAIN` 为构建和 lint 选择默认论文入口；`--main` 可以为单次命令覆盖它。
- 创建带日期的产物时使用系统实际日期。

## 7. 工作流

- 仓库状态不清楚时，先运行 `$story-flow-status`。
- 每个工作流 skill 在操作前都读取 `docs/mds/story-workflow/writing-workflow-conventions.md`。
- 优先使用拥有目标文件的最小 skill。起草请求不得修改证据、学位要求或收到的反馈。
- 修改 `manus/` 后运行构建；引用、论断、元数据或最终完成状态可能变化时运行 lint。
- 报告已核验内容：构建路径和页数、lint 结果、变更的 ledger 行，以及仍未通过的门槛。

## 8. 语言与项目记忆

- `.env` 中的 `STORY_LANG=en|zh` 控制回复和新建 Markdown 的语言；未设置时跟随对话。它不会静默翻译已有文件。
- 每个英文 Markdown 文件都必须保留简体中文对照版：普通文档使用 `*.zh-CN.md`，skill 指令使用 `SKILL_zh.md`。由于 `mates/` 只读，`mates/MANIFEST.md` 的对照版放在 `docs/mds/story-workflow/mates-MANIFEST.zh-CN.md`。
- `degree/profile.tex` 控制论文正文语言。
- 仅当仓库没有其他文件负责某项会话知识时，才将其存入 `.story/memory/`。机器专属事实放在 `.story/memory/local/` 下。
- Memory 不是证据，也不能覆盖 `degree/`、`mates/`、`notes/` 或 `milestones/`。
