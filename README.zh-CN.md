<div align="center">
  <h1>STORY</h1>
  <p><strong>Systematic Toolchain for Organizing Research over Years</strong></p>
  <p><em>A STAR takes the STAGE to tell a STORY.</em></p>
</div>

**语言：** [English](README.md) | 简体中文

STORY 是一个面向完整博士学位论文的仓库模板与 AI 辅助工作流。它把多年研究、已发表论文、实验证据、章节草稿、导师和委员会反馈、学位要求、答辩材料、答辩后修改以及最终归档放进同一条可追溯的链路中，同时守住证据与作者贡献边界。

三个仓库形成自然递进：

```text
STAR   推进研究并产生证据
STAGE  将单项研究写成论文并投稿
STORY  将多年研究综合成完整博士学位论文
```

STORY 可以同时接入多个 STAR 研究仓库、多个 STAGE 论文仓库和人工登记的材料，也可以完全独立使用。

## STORY 提供什么

- 一套开箱可编译、基于 `book` 的通用学位论文模板，前置部分、章节、附录、图、表和参考文献各归其位。
- `mates/` 下带指纹的只读证据层，支持多研究项目与多论文来源。
- `notes/` 下的总叙事、贡献映射、发表与复用映射、提纲、符号表及论断记录表。
- `degree/` 下由用户确认的学校要求和委员会记录。
- 面向开题、年度考核、预答辩、答辩、修改与归档的持久化里程碑记录。
- `execs/` 下统一的构建、格式化、证据导入与机械检查入口。
- 分别供 Codex、Claude Code、Cursor 和 Kimi Code 使用的十六个博士论文工作流 skill。
- `.story/memory/` 下属于项目自己的跨会话记忆。

## 仓库结构

```text
STORY/
├── manus/                         # 学位论文源文件
│   ├── main.tex
│   ├── fronts/                    # 摘要、致谢、声明等前置部分
│   ├── chaps/                     # <n>_<slug>.tex 章节
│   ├── backs/                     # 附录等后置部分
│   ├── figs/                      # 成图；figs/srcs/ 保存可编辑源文件
│   ├── tabs/                      # 由证据生成的 LaTeX 表格
│   ├── bibs/                      # reference.bib
│   └── stys/                      # story.cls、story.sty、story.bst
├── mates/                         # 带指纹的证据快照，只读
├── degree/                        # 学位档案、学校要求、委员会
├── notes/                         # 总叙事与写作元数据
│   ├── story.md                   # 中心论点与博士研究主线
│   ├── contributions.md           # 贡献 → 证据/论文/章节
│   ├── publications.md            # 作者贡献、内容复用、许可与重叠
│   ├── outline.md                 # 章节提纲
│   ├── claims.md                  # 论断记录表
│   ├── notation.md
│   ├── style.md
│   └── refs/                      # 阅读笔记与文献索引
├── milestones/                    # 开题、考核、答辩、修改、归档
├── tasks/                         # 持久化待办与反馈承诺
├── wkdrs/                         # 构建产物和临时报告，git 忽略
├── execs/                         # 构建/更新入口与工具脚本
├── docs/mds/story-workflow/       # 工作流规范与 skill 指南
└── .agents/.claude/.cursor/.kimi-code
```

## 快速开始

```bash
git clone https://github.com/wanghao9610/STORY.git my-dissertation
cd my-dissertation
cp .env.example .env
bash execs/run.sh
bash execs/scpts/lint.sh
```

仅根据学校或培养项目的正式材料填写 `degree/profile.tex` 与 `degree/requirements.md`。已有草稿时运行 `$story-proj-adopt`；从零开始时先运行 `$story-syns-coach`，再运行 `$story-outl-planner`。

每个研究或论文仓库分别导入：

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

## 写作工作流

1. `$story-proj-adopt`：盘点并安全接入已有学位论文。
2. `$story-evid-curator`：导入、登记和审计证据。
3. `$story-syns-coach`：确立博士论文主线、中心论点与贡献。
4. `$story-outl-planner`：建立跨章节连贯的整体结构。
5. `$story-chap-drafter`：依据章节简报和证据逐章写作。
6. `$story-tabs-builder`、`$story-figs-designer`：制作可追溯的表格和图。
7. `$story-refs-curator`：维护可核验的文献记录与阅读笔记。
8. `$story-copy-editor`：统一术语、声音和跨章节衔接。
9. `$story-clms-auditor`、`$story-cite-auditor`：审计数字、论断与引用。
10. `$story-exam-reviewer`：模拟外审专家或答辩委员会审查。
11. `$story-revs-resolver`：保留原始反馈并逐点跟踪处理结果。
12. `$story-defn-builder`：准备和检查答辩演示文稿。
13. `$story-depo-packer`：检查、打包并冻结最终归档版本。
14. `$story-flow-status`：汇报整体状态并给出唯一下一步建议。

权威规则见 [writing-workflow-conventions.md](docs/mds/story-workflow/writing-workflow-conventions.md)。

## 证据与作者贡献

每项定量或比较性论断都必须指向 `mates/` 中已登记的材料，否则保持显式未解决状态。`notes/publications.md` 另外记录各章节复用了哪些已发表内容、合作者贡献、许可和文本重叠。证据可追溯不能替代作者贡献说明；STORY 同时要求两者。

## 学校模板

仓库自带的 class 是通用模板。学校的正式模板和规范必须由用户提供并确认。通用手稿保持为事实源；学校格式转换或归档包放在独立的 deposit 里程碑中处理，避免格式转换静默改写正文源文件。

## 环境要求

- Bash 3.2+
- 带 `latexmk` 的较完整 TeX Live
- `pdfinfo` 用于页数统计，`texcount` 可选用于字数统计

## 许可证

见 [LICENSE](LICENSE)。
