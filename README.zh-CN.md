<div align="center">
  <img src="docs/srcs/story-project-icon.png" alt="STORY 项目图标" width="128">
  <h1>STORY</h1>
  <p><strong>Systematic Toolchain for Organizing Research over Years</strong></p>
  <p><em>A STAR takes the STAGE to tell a STORY.</em></p>
  <p><a href="https://wanghao9610.github.io/STORY/"><strong>文档网站</strong></a></p>
</div>

**语言：** [English](README.md) | 简体中文

STORY 把多年的研究生阶段研究组织成一部连贯、可答辩、可归档的硕士学位论文或博士学位论文。它把手稿、研究证据、出版物复用、学位要求、章节计划、贡献与论断记录、委员会反馈、答辩材料、修改过程及归档历史放在可预测的位置。研究者和 AI 写作 agent 依据同一套由仓库拥有的指令协作，因此即使一次对话早已结束，学位论文仍可在后续会话中继续推进并接受复核。

这套系统的核心契约是来源可追溯。论文中的每项定量或比较性陈述，都必须追溯到 `mates/` 下带指纹的文件，否则就以 `\todo{...}` 显式保留为未解决项；关于引用文献的每项断言，都必须能由阅读笔记或已导入材料核验；每项学位贡献都要记录对应的证据、章节、出版物和作者贡献边界。因此，STORY 把学位论文视为对研究的综合，而不是把若干论文简单拼接在一起。

STORY 有两层：本仓库是**模板**；一部学位论文对应一个**实例**，可以克隆模板创建，也可以用 `execs/update.sh --adopt` 把骨架装入已有学位论文仓库。一个实例可以导入任意数量的 [STAR](https://github.com/wanghao9610/STAR) 研究仓库、[STAGE](https://github.com/wanghao9610/STAGE) 论文仓库、其他 STORY 学位论文仓库和人工登记来源。这种配套关系并非强制——STORY 也可以作为独立的学位论文仓库使用。

## 目录

- [目录](#目录)
- [STAR · STAGE · STORY](#star-·-stage-·-story)
- [STORY 提供什么](#story-提供什么)
- [项目结构](#项目结构)
- [学位论文模板](#学位论文模板)
  - [英文与简体中文](#英文与简体中文)
  - [学位档案与学校格式](#学位档案与学校格式)
- [快速开始](#快速开始)
  - [1. 创建学位论文仓库](#1-创建学位论文仓库)
  - [1b. 或者接入已有学位论文仓库](#1b-或者接入已有学位论文仓库)
  - [2. 配置本地运行环境和学位档案](#2-配置本地运行环境和学位档案)
  - [3. 路径 A：导入已有研究](#3-路径-a导入已有研究)
  - [4. 路径 B：登记独立证据](#4-路径-b登记独立证据)
  - [5. 构建与检查](#5-构建与检查)
  - [6. 启动学位论文工作流](#6-启动学位论文工作流)
- [写作工作流](#写作工作流)
- [从研究到归档的路径](#从研究到归档的路径)
- [证据、作者贡献与论断记录表](#证据作者贡献与论断记录表)
- [学位里程碑](#学位里程碑)
- [Agent harness](#agent-harness)
- [项目记忆](#项目记忆)
- [更新 STORY 的 skill 与工作流文档](#更新-story-的-skill-与工作流文档)
- [项目约定](#项目约定)
- [把 STORY 适配到实际学位论文](#把-story-适配到实际学位论文)
- [环境要求](#环境要求)
- [许可证](#许可证)

## STAR · STAGE · STORY

三个项目覆盖研究者工作中相继递进的尺度。它们可以各自独立使用，也可以通过带指纹的证据彼此衔接。

| 项目 | 范围 | 链接 |
| --- | --- | --- |
| **STAR** — Systematic Toolchain for AI Research | 推进一个研究项目：从想法出发，经可复现实验，产出可直接用于论文的证据。 | [官网](https://wanghao9610.github.io/STAR/) · [GitHub](https://github.com/wanghao9610/STAR) |
| **STAGE** — Systematic Toolchain for Authoring, Guiding, and Editing | 把一项研究贡献写成可追溯的论文，贯穿评审、回复与投稿打包。 | [官网](https://wanghao9610.github.io/STAGE/) · [GitHub](https://github.com/wanghao9610/STAGE) |
| **STORY** — Systematic Toolchain for Organizing Research over Years | 把研究生阶段的研究组织成可答辩、可归档的硕士或博士学位论文。 | **当前项目** · [官网](https://wanghao9610.github.io/STORY/) · [GitHub](https://github.com/wanghao9610/STORY) |

三者之间的交接是单向且可审计的：STAR 产出研究记录与实验结果；STAGE 把一项贡献写成论文并保存其评审历史；STORY 把相关材料快照为只读证据，并在学位尺度上进行综合。上游数值有误时，应在来源处修正后重新导入，绝不能直接修改快照。

## STORY 提供什么

- **完整的学位论文工作区**：前置部分、章节、附录、图、表、参考文献、学校记录、里程碑和持久化待办各归其位。
- **通用且可构建的 LaTeX 模板**：同时支持英文与简体中文的硕士、博士学位论文，把可复用 class、写作宏和参考文献样式与论文内容分离。
- **带指纹的证据层**：`mates/` 可以从多个 STAR、STAGE、STORY 或结构化通用仓库导入指定材料，并保留来源路径、commit、导入日期和 SHA-256 指纹。
- **学位论文层面的事实源**：`notes/` 下的中心论点、研究主线、贡献映射、出版与复用映射、章节结构、符号表、风格、阅读笔记和论断记录表由各自负责的工作流按需创建。
- **学位层级感知标准**：`degree/profile.tex` 选择 `master` 或 `doctoral`；该事实未知时，层级相关的综合、外审、答辩和归档门槛不会启用。
- **学校事实与猜测分离**：正式要求、标题页措辞、委员会记录、模板、限制、批准和截止日期只能来自作者确认过的来源，并放在 `degree/` 与 `milestones/` 下。
- **由十六个 skill 覆盖完整生命周期**：接入、证据整理、综合、提纲、章节起草、图、表、参考文献、文字润色、审计、模拟外审、反馈处理、答辩、归档和状态汇报。
- **确定性的构建与检查**：`execs/run.sh` 在源目录外构建；`lint.sh` 检查引用、todo、学位档案一致性、页数限制和格式；`fmt.sh` 维持一句一行；`import.sh --diff` 检测证据漂移。
- **七个 agent harness 共用一套工作流**：Codex、Claude Code、Cursor、DeepSeek Harness、Kimi Code、Pi 与 Qwen Code 共享中立 skill 和请求分流器。
- **属于项目的跨会话记忆**：`.story/memory/` 保存那些没有被证据、学位档案、笔记、里程碑或任务文件认领的持久知识。
- **成对的英文与简体中文文档**：方便人类读者，同时路径、ID、状态、命令和机器可读字段始终保持英文稳定值。

[写作工作流](#写作工作流)列出每个 skill 的职责与产物；[STORY 工作流 Skill 指南](docs/mds/story-workflow/writing-workflow-skills.zh-CN.md)给出紧凑流程图；[写作工作流规范](docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md)定义所有 skill 共同遵守的证据、学位、里程碑、语言与验证契约。

## 项目结构

```text
STORY/
├── manus/                         # 学位论文源文件
│   ├── main.tex                   # 英文入口
│   ├── main-zh.tex                # 可构建的简体中文起始模板
│   ├── fronts/                    # 摘要、致谢、声明等前置部分
│   ├── chaps/                     # 编号章节：<n>_<slug>.tex
│   ├── backs/                     # 附录等后置部分
│   ├── figs/                      # 成图；figs/srcs/ 保存可编辑源文件
│   ├── tabs/                      # 有证据支持的 LaTeX 表格
│   ├── bibs/                      # reference.bib
│   └── stys/                      # story.cls、story.sty、story.bst
├── mates/                         # 导入的证据快照，只读
│   ├── <source-slug>/             # 一个具有独立命名空间的来源仓库
│   ├── manual/                    # 人工提供的研究材料
│   └── MANIFEST.md                # 来源与 SHA-256 台账
├── degree/                        # 经作者确认的学校事实
│   ├── profile.tex                # 学位层级、论文语言、标题页元数据
│   ├── requirements.md            # 带来源的学位与归档检查表
│   └── committee.md               # 经确认的导师与委员会记录
├── notes/                         # 学位论文叙事与写作元数据
│   ├── story.md                   # 中心论点与学位研究主线
│   ├── contributions.md           # 贡献 → 证据/出版物/章节
│   ├── publications.md            # 作者贡献、复用、许可、重叠
│   ├── outline.md                 # 章节简报与视觉计划
│   ├── claims.md                  # 论断记录表
│   ├── notation.md                # 全文符号约定
│   ├── style.md                   # 可衡量的文字风格约定
│   └── refs/                      # 阅读笔记与参考文献索引
├── milestones/                    # 开题、考核、外审、答辩、归档
│   └── <slug>/                    # milestone.yml、feedback/、response/、materials/、RECORD_*.md
├── tasks/                         # 持久化未解决工作与反馈承诺
├── wkdrs/                         # 构建产物和可再生成报告，git 忽略
├── execs/
│   ├── run.sh                     # 学位论文构建入口
│   ├── update.sh                  # 同步上游工作流；--adopt 安装骨架
│   └── scpts/                     # import.sh、lint.sh、fmt.sh
├── docs/                          # 文档网站与工作流指南
├── .story/memory/                 # 项目记忆；local/ 仅属于本机
├── .agents/                       # 中立 skill 与共享 /story 分流器
├── .codex/                        # Codex hook、manifest 与 $story 插件
├── .claude/ .cursor/ .dsh/        # 各 harness 的入口与 hook
├── .kimi-code/ .pi/ .qwen/        # 各 harness 的入口与 hook
├── .env.example                   # 本地配置示例
├── AGENTS.md                      # AI 写作 agent 的共享规则
└── README.md
```

这些缩写目录沿用 STAR 与 STAGE 的约定：

| 目录 | 全称 | 内容 |
| --- | --- | --- |
| `manus/` | Manuscript | 学位论文的 LaTeX 源文件 |
| `fronts/` | Front matter | 摘要、致谢、声明等前置材料 |
| `chaps/` | Chapters | 每章一个带编号的 `.tex` 文件 |
| `backs/` | Back matter | 正文章节后的附录及其他材料 |
| `figs/` | Figures | PDF 或图片成图；`srcs/` 保存可编辑源文件 |
| `tabs/` | Tables | 有证据支持的表格 `.tex` 文件 |
| `bibs/` | Bibliographies | 学位论文参考文献 |
| `stys/` | Styles | 可复用 class、package 与参考文献样式 |
| `mates/` | Materials | 带指纹的只读证据快照 |
| `execs/` | Executions | 构建与更新入口；`scpts/` 保存工具脚本 |
| `wkdrs/` | Work directories | 构建产物与临时报告，不是持久项目状态 |
| `mds/` | Markdowns | 按主题组织的 Markdown 文档 |
| `srcs/` | Static sources | 文档图片与可编辑视觉源文件 |

有三条规则比目录名称更重要。`mates/` 除 `execs/scpts/import.sh` 与 `story-evid-curator` 外一律只读；`wkdrs/` 可以重新生成，因此持久结果应写入 `notes/`、`milestones/` 或 `tasks/`；新克隆有意只包含 `notes/.gitkeep` 与 `notes/refs/.gitkeep`。各工作流在第一次使用时创建自己拥有的 `notes/*.md`——文件缺席表示“尚未初始化”，而不是“模板里缺了它”。

## 学位论文模板

模板把可复用排版、作者拥有的内容和学校事实分成不同层：

| 层 | 文件 | 负责内容 |
| --- | --- | --- |
| 学位论文入口 | `manus/main.tex` 或 `manus/main-zh.tex` | 前置/章节/后置顺序、全文宏、参考文献启用 |
| 外观层 | `manus/stys/story.cls` | book 布局、页面尺寸、标题页、标题、本地化、链接与引用 |
| 写作层 | `manus/stys/story.sty` | 章节和表格使用的 `\todo`、交叉引用辅助、表格列与写作宏 |
| 参考文献样式 | `manus/stys/story.bst` | 参考文献条目的排版方式 |
| 学位事实 | `degree/profile.tex` | 学位层级、论文语言、正式标题页字段、经确认页数上限 |

项目专属命令，例如 `\newcommand{\method}{...}`，应写在入口文件中，而不是写入 `story.cls` 或 `story.sty`。这种分层便于审查学校格式适配；实例拥有整个 `manus/` 树，`execs/update.sh` 永远不会替换它。

class 接受常规 `book` 选项，以及 `draft|final` 与 `en|english|zh|chinese`。默认模式是英文草稿。英文入口使用 `\documentclass[oneside]{stys/story}`；中文起始模板使用 `\documentclass[oneside,zh]{stys/story}`，并包含 `% !TeX program = xelatex` 指令。

### 英文与简体中文

`manus/main.tex` 和 `manus/main-zh.tex` 共用 `story.cls`、`story.sty` 和唯一一份 `degree/profile.tex`。标题页字段采用 `\storylocalized{English}{中文}`，两个入口各自选择对应形式，无需复制学校元数据。

本地试用中文起始模板：

```dotenv
STORY_MAIN=manus/main-zh.tex
LATEX_ENGINE=
```

```bash
bash execs/run.sh
bash execs/scpts/lint.sh
```

当 `LATEX_ENGINE` 为空时，`run.sh` 遵循入口文件中的 TeX program 指令，因此会为 `main-zh.tex` 选择 XeLaTeX；显式引擎可以是 `pdflatex`、`xelatex` 或 `lualatex`。把中文设为正式论文语言前，应先确认学校规则，并在 `degree/profile.tex` 中设置 `% dissertation_language: zh`。class 只负责本地化结构，不会翻译论文内容，也不会虚构学位元数据。

### 学位档案与学校格式

在 `degree/profile.tex` 中只设置一个经作者确认的学位模式：

```tex
% degree_level: master
% 或：degree_level: doctoral
```

学位层级特意不做成 `.env` 选项，因为它是持久的学校事实。缺失值保持未知；非法值，以及与所选层级冲突的题名或学位措辞，会使 lint 失败。STORY 只应用已选层级的贡献标准，也只应用学校实际要求的里程碑。

仓库自带的 class 有意保持通用。学校正式模板、标题页措辞、页边距、前置部分顺序、页数限制、截止日期、提交门户、延迟公开选择和审批规则，都必须来自作者确认过的正式材料。规范档案写在 `degree/profile.tex`，带来源的检查表写在 `degree/requirements.md`，里程碑专属规则写在 `milestones/<slug>/milestone.yml`。学校提供的模板保存在适用里程碑下；不得凭记忆静默改写 STORY 的通用源文件树。

## 快速开始

### 1. 创建学位论文仓库

使用 GitHub 模板功能，或克隆后让副本脱离上游——一部学位论文，一个仓库：

```bash
git clone https://github.com/wanghao9610/STORY
cd STORY
rm -rf .git
rm -rf .github        # 上游维护者 CI；它检查 STORY 生成的 harness 镜像。
cd ..
mv STORY YOUR_THESIS_NAME
cd YOUR_THESIS_NAME
git init
git add .
git commit -m "First commit."
```

如果使用 GitHub 的 **Use this template** 功能，新仓库已经有自己的 Git 历史；除非你打算维护 STORY fork，否则应删除 `.github/`。上游 workflow 检查的是 STORY 的七棵生成 skill 树和双语文档，而不是一部具体学位论文的内容。

### 1b. 或者接入已有学位论文仓库

如果草稿已经开工——例如 Overleaf 导出、可工作的 LaTeX 树、多年积累的章节，或正文里已有结果——应把 STORY 骨架装进现有仓库，而不是把已有内容搬进全新克隆。在现有仓库根目录运行：

```bash
curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o /tmp/story-update.sh
bash /tmp/story-update.sh --adopt
```

接入不会覆盖任何已有路径：它只复制缺失文件，并报告保留了什么。加上 `--harnesses claude`——或从 `claude`、`codex`、`cursor`、`dsh`、`kimi`、`pi`、`qwen` 中任选多个并用逗号分隔——即可只安装实际使用的 agent 树。随后调用 `story-proj-adopt`；它会盘点草稿，在修改文件映射前征求确认，确认学位档案和要求，保留原始源文件，把已有但无来源的陈述记录为审计工作，并验证接入后的构建。

### 2. 配置本地运行环境和学位档案

复制本地配置：

```bash
cp .env.example .env
```

```dotenv
# 可选的默认证据仓库；额外仓库通过 --source 导入。
RESEARCH_HOME=

# 默认学位论文入口，相对于仓库根目录。
STORY_MAIN=manus/main.tex

# pdflatex | xelatex | lualatex；留空先遵循入口文件，再回退到 pdflatex。
LATEX_ENGINE=

# execs/update.sh 维护的上游模板与 harness 树。
STORY_REPOSITORY=https://github.com/wanghao9610/STORY.git
STORY_HARNESSES=all

# 工作流交互程度，以及 Markdown/回复语言。
INVOLVE=medium
STORY_LANG=
```

`.env` 已被 Git 忽略。`STORY_MAIN` 为构建与 lint 选择默认入口，单次命令中的 `--main` 优先。`INVOLVE=low|medium|high` 控制 skill 在一般裁量事项前询问的频率，但绝不会绕过学校事实、作者贡献、删除、覆盖或最终冻结的确认。它是项目默认值；单次调用中的 `involve=<level>` token 只覆盖那一次运行。`STORY_LANG=en|zh` 控制回复与新写入 Markdown 的语言；留空时跟随对话，且永远不会翻译已有文件。手稿语言和学位层级仍保存在 `degree/profile.tex`。

随后，只依据正式材料或作者确认过的记录填写 `degree/profile.tex`、`degree/requirements.md` 和 `degree/committee.md`。未知值保持为空；不得根据论文题名或学位名称推断学位层级。

### 3. 路径 A：导入已有研究

为每个来源选择一个稳定 slug 后分别导入：

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --source ../earlier-story --slug prior-thesis
```

`import.sh` 能识别 STAR、STAGE、STORY 和结构化通用仓库；它选择与写作相关的材料，复制到 `mates/<slug>/`，并在 `mates/MANIFEST.md` 中记录来源类型、来源绝对路径、来源 commit、SHA-256 指纹、导入日期和覆盖范围。省略 `--source` 时使用 `RESEARCH_HOME`。上游工作变化后重新导入，或用只读方式检查：

```bash
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

上游出现新材料或已有材料过期时，diff 以 `1` 退出。导入证据只能单向流动：在上游修正后重新导入。

### 4. 路径 B：登记独立证据

如果学位论文没有 STAR 或 STAGE 来源仓库，先把已提供的结果、报告、表格或其他研究材料保留在其来源路径，再调用 `story-evid-curator register path=<file>`。curator 会先记录来源、所有者、日期和覆盖范围，再把材料复制到 `mates/manual/`，并在 `mates/MANIFEST.md` 中登记指纹。没有 manifest 条目的文件不是证据。修正后的材料应成为新的登记记录，绝不能在原位置静默修改。

两条路径可以混用。只要每个来源都有独立命名空间，并且作者贡献边界保持清楚，同一部学位论文可以同时接入多个研究项目、已发表论文、协作记录和人工证据。

### 5. 构建与检查

```bash
bash execs/run.sh
bash execs/scpts/lint.sh
bash execs/scpts/fmt.sh --check
```

`run.sh` 调用 `latexmk`，在 `wkdrs/builds/` 中进行源目录外构建，并在 `pdfinfo` 可用时打印 PDF 路径与页数。`lint.sh` 默认先构建，再把未定义引用或交叉引用、可见 `\todo`、非法或冲突的学位元数据，以及超出已确认页数限制视为失败；占位符、overfull box、格式漂移、未知学位层级、高置信度聊天机器人残留和集中出现的公式化表达会被明确报告。针对正文的检查发现只是建议性复核信号，既不能证明文本由 AI 创作，也不构成硬失败。只有当前 PDF 与日志已经存在时才使用 `--no-build`。

`fmt.sh` 使用仓库的 `latexindent` 配置，在不改变排版文本的前提下维持一句一行。它排除可复用样式和学校正式模板。不带 `--check` 运行即可应用格式化。

### 6. 启动学位论文工作流

即使不使用 AI harness，仓库结构与脚本也能独立工作。使用工作流 skill 时，从最符合当前论文状态的一项开始：

| 当前状态 | 从这里开始 |
| --- | --- |
| 已有草稿或 Overleaf 导出 | `story-proj-adopt` |
| 新仓库，来源研究已经准备好 | `story-evid-curator` |
| 证据已登记，但论文中心论点仍不清楚 | `story-syns-coach` |
| 论点与贡献已确认，但章节尚未规划 | `story-outl-planner` |
| 不确定哪些部分已初始化或被阻塞 | `story-flow-status` |

准确的命令前缀取决于 harness：Codex 使用 `$story-*`；Claude Code、Cursor、Pi 与 Qwen Code 使用 `/story-*`；DSH 与 Kimi Code 使用 `/skill:story-*`。通用 `$story` 或 `/story` 分流器接收自然语言请求并选择一个工作流；其中六个涉及论文整体或里程碑的工作流必须显式调用。

## 写作工作流

十六个 skill 组成一条流水线，而不是一套固定不变的顺序。始终使用拥有目标产物的最小 skill。每个 skill 都会先加载共享工作流规范。
每个 skill 完成后，报告都以唯一一行 `下一步：` 交接结束：指出负责最早剩余关口的 skill 及具体目标或命令；若只能由作者解除关口，则写明作者行动；若请求的工作流已经完成，则明确说明。该交接只建议接下来如何做，不会静默启动另一个 skill。

| Skill | 适用情形 | 主要产物 |
| --- | --- | --- |
| `story-proj-adopt` † | 已有学位论文或 Overleaf 导出需要安全接入 STORY | `notes/adopt.md`、映射后的源文件、无来源论断积压 |
| `story-evid-curator` | 需要导入、登记、刷新或完整性检查证据 | `mates/`、`mates/MANIFEST.md` |
| `story-syns-coach` † | 需要确认论文问题、中心论点、研究问题、主线或贡献 | `notes/story.md`、`contributions.md`、`publications.md`、`claims.md` |
| `story-outl-planner` † | 已确认的论文总叙事需要转化为章节结构 | `notes/outline.md`、`notation.md`、章节骨架 |
| `story-chap-drafter` | 一个章节需要以作者的学术声音依据证据起草或修改 | 一个 `manus/chaps/*.tex` 文件及同步台账 |
| `story-tabs-builder` | 需要一张结果、比较、映射或综合表格 | 一个带逐行来源锚点的 `manus/tabs/*.tex` 文件 |
| `story-figs-designer` | 需要一张概念、方法、结果或综合图 | `manus/figs/` 下的成图与可编辑源文件 |
| `story-refs-curator` | 需要添加、核验、阅读、去重或定位一项来源 | 参考文献条目与 `notes/refs/` 阅读笔记 |
| `story-copy-editor` | 需要润色作者声音、公式化表达、术语、衔接、重复或符号一致性 | 手稿修改、报告或 `notes/style.md` |
| `story-clms-auditor` | 数值、比较和学位贡献论断需要可追溯性检查 | 论断结论、可再生成发现、持久任务 |
| `story-cite-auditor` | 引用键、文献断言和参考文献卫生需要检查 | 引用报告与持久任务 |
| `story-exam-reviewer` | 需要适合当前学位层级的模拟外审或委员会审查 | `milestones/<slug>/feedback/SIM_EXAM_<date>.md` |
| `story-revs-resolver` † | 收到导师、委员会、外审、答辩、修改或归档反馈 | 逐点台账、回复、跟踪承诺 |
| `story-defn-builder` † | 适用的预答辩或答辩需要叙事与演示文稿 | 里程碑下的答辩计划和可编辑演示材料 |
| `story-depo-packer` † | 一个具名归档里程碑已经可以预检和冻结 | 归档包、校验和、记录、可选本地冻结 tag |
| `story-flow-status` | 不清楚下一步做什么 | 只读状态报告与唯一下一步行动 |

标有 † 的六个 skill 控制论文总论点、章节边界、学校里程碑或最终定稿。通用分流器不会直接启动它们，而是返回准确的显式命令并等待确认。这条边界防止 agent 静默改变论文中心论点、整体结构、反馈立场、答辩或归档状态。

章节起草、润色、模拟审查和 lint 共用[学术自然写作指南](docs/mds/story-workflow/human-writing-guide.zh-CN.md)。该指南把 Humanizer 模式适配到学术正文，同时保留证据、限定、术语和经作者确认的声音；它不会依据孤立词语或标点判断作者身份。

## 从研究到归档的路径

常见路径如下：

1. **建立论文实例**——克隆 STORY 或运行 `update.sh --adopt`；依据正式记录确认 `degree/profile.tex`。
2. **整理证据**——分别导入 STAR、STAGE、STORY 或通用仓库，并登记人工材料；每份证据文件都获得指纹。
3. **塑造学位论文**——`story-syns-coach` 把研究历史组织成一个适合当前学位层级的问题、中心论点、研究主线、研究问题、贡献、出版/复用映射和候选论断。
4. **规划章节**——`story-outl-planner` 为每章映射目的、研究问题、贡献、论断、证据、视觉材料、依赖和退出条件。
5. **建立文献基础**——`story-refs-curator` 核验书目身份，阅读承载论断的来源，并在 `notes/refs/` 下创建可检查的笔记。
6. **逐章起草**——`story-chap-drafter` 依据已确认简报和证据写作；`story-tabs-builder` 与 `story-figs-designer` 创建可追溯视觉材料；同一次修改同步更新论断、符号与提纲记录。
7. **润色而不移动事实**——`story-copy-editor` 删除集中出现的公式化表达，统一术语、作者声音、衔接与跨章节综合，同时保持数值、引用、作者贡献、不确定性和论断范围不变。
8. **审计**——`story-clms-auditor` 追溯数值和贡献论断；`story-cite-auditor` 检查引用键与文献断言。失败项成为持久任务，而不会埋在报告里消失。
9. **外审与修改**——`story-exam-reviewer` 模拟适用于当前学位层级的审查；收到的反馈在 `feedback/` 下保持不变；`story-revs-resolver` 为每点记录处理方式和完成证据。
10. **准备答辩**——培养项目确认要求答辩时，`story-defn-builder` 依据已核验论断以及已确认时长和格式规则创建叙事与可编辑演示文稿。
11. **打包并冻结归档**——只有构建和 lint 通过、学校检查与承诺全部解决、复用许可清楚且所需批准已有记录时，`story-depo-packer` 才会生成本地归档包与冻结记录；它绝不会代替作者上传或提交。

任何阶段都可以运行 `story-flow-status`。它读取学位档案、证据健康度、叙事与贡献就绪情况、章节/论断/参考文献覆盖、出版物作者贡献、里程碑、承诺和最近构建，然后只推荐一个下一步行动。

## 证据、作者贡献与论断记录表

三份台账让学位论文保持可答辩：

**A. 证据只能单向流动。** 只有 `mates/MANIFEST.md` 保存了匹配的指纹和来源后，一个文件才成为证据：

```markdown
## project-a/wkdrs/results/results.md
- source-type: star
- source: /path/to/project-a/wkdrs/results/results.md
- source-commit: 3f2a91c
- sha256: 8a31...
- imported: 2026-08-23
- covers: imported graduate-research evidence
```

随后，`manus/` 中每个定量或比较性句子都必须有邻近来源锚点，或论断记录表中的证据链接：

```tex
% src: mates/project-a/wkdrs/results/results.md#main-comparison
所提出方法把经确认的指标提高了……。
```

如果支持缺失，就写 `\todo{...}`。凭记忆、插值或看起来合理的数值不构成第三种选择。

**B. 论断记录表是枢纽。** `notes/claims.md` 使用 `ID | Claim | Contribution | Stated in | Evidence | Status | Notes`。论断 ID 保持稳定（`C001`、`C002`……）；其生命周期是 `proposed` → `drafted` → `verified`，并用 `unsourced`、`weakened`、`retired` 保存失败与决定，而不是删除历史。综合工作提出论断，章节陈述论断，审计核验论断，评审攻击的仍是同一行记录。

**C. 作者贡献与证据相互独立。** `notes/contributions.md` 把学位贡献（`D001`、`D002`……）映射到研究问题、论断、证据、出版物、章节与作者贡献。`notes/publications.md` 另外记录完整作者列表、候选人的贡献、复用材料、重叠及许可或政策状态。出版物不会自动成为学位贡献；证据具有指纹，也绝不意味着 STORY 可以把合作研究描述为候选人独立完成。

关于引用文献的断言遵守同样边界：元数据核验只能确认“这是哪篇论文”；内容核验表示已经阅读来源本身，并且 `notes/refs/` 能支持该断言。公开可访问也绝不等于获得复用许可。

## 学位里程碑

每个适用的开题、考核、年度考核、预答辩、外审、答辩、修改轮、归档或学校专属事件，都有一个 `milestones/<slug>/` 目录。STORY 不会仅仅因为其他学校或另一学位层级使用某个里程碑，就要求当前论文也创建它。

```text
milestones/<slug>/
├── milestone.yml          # 经确认的类型、状态、日期、来源和限制
├── feedback/              # 收到的意见，原样保存
├── response/              # 逐点台账、处理方式与完成证据
├── materials/             # 适用的开题、外审或答辩材料
└── RECORD_<date>.md        # 冻结结果；status: completed 前必须存在
```

`milestone.yml` 的类型可以是 `proposal`、`review`、`annual-review`、`pre-defense`、`external-examination`、`defense`、`correction`、`deposit` 或 `other`；状态可以是 `planned`、`active`、`blocked`、`completed` 或 `cancelled`。日期、页数限制、正式名称和要求来源在确认前保持为空。

收到的反馈永远不在原处编辑。回复为每点记录 `accepted`、`completed`、`planned`、`disagreed` 或 `needs-author`，承诺的修改也会成为 `tasks/` 下的复选框。任何 lint 失败、可见 todo、未勾选学校要求、未完成承诺、缺失的复用许可或尚未记录的必要批准，都会阻塞归档。

## Agent harness

各 harness 树共用一个事实源。中立 skill 位于 `.agents/skills/`；共享请求名册位于 `.agents/commands/story.md`；每个 harness 只拥有其运行时需要的 frontmatter、prompt、hook、设置和命令适配器。

| Harness | Skill 入口 | 项目设置 |
| --- | --- | --- |
| Codex | `$story-*`；通用 `$story` 插件 | 用 `/hooks` 批准 `.codex/hooks.json`；按下文安装插件 |
| Claude Code | `/story-*`；通用 `/story` | 自动加载 `.claude/settings.json` |
| Cursor | `/story-*`；通用 `/story` | 自动加载 `.cursor/hooks.json` 与 rules |
| DeepSeek Harness | `/skill:story-*`；通用 `/story` | 安装 `.dsh/commands/story`；每台机器运行一次 `bash .dsh/hooks/install.sh` |
| Kimi Code | `/skill:story-*`；通用 `/story` | 安装 `.kimi-code/plugins/story`；每台机器运行一次 `bash .kimi-code/hooks/install.sh` |
| Pi | `/story-*` prompt | 信任项目后才会加载 `.pi/extensions/` |
| Qwen Code | `/story-*`；通用 `/story` | 自动加载 `.qwen/settings.json` |

在仓库根目录安装一次 Codex 仓库内分流器，然后新开会话：

```bash
codex plugin marketplace add .
codex plugin add story@story
```

对于 Kimi Code，从仓库根目录启动后在输入框运行；也可以用 `/new` 代替 `/reload`：

```text
/plugins install ./.kimi-code/plugins/story
/reload
```

对于 DSH，把命令 bundle 安装进每个 profile，再重启该 profile：

```bash
dsh plugin --profile YOUR_PROFILE add ./.dsh/commands/story
dsh --profile YOUR_PROFILE --dump-config
```

不带请求的 `$story` 或 `/story` 显示学位论文状态，也可以传入自然语言请求，例如“审计第 3 章的论断”。所有包装器都从同一份名册分流。维护 STORY 本身时，应修改 `.agents/skills/` 与 `.agents/commands/` 下的中立内容，再运行 `bash .github/scripts/port.sh --write`；一般学位论文实例通过 `execs/update.sh` 获取这些文件。

## 项目记忆

一次会话学到、但没有任何仓库文件认领的知识——本机特有的 TeX 限制、作者的长期偏好、可复用的项目判断，或已经尝试并否决的一种论述方式——可以放在 `.story/memory/` 下。一事一文件，每条在 `.story/memory/MEMORY.md` 中占一行；会话 hook 会在每个受支持 harness 的会话开头把索引交给 agent。

四种类型让记忆库保持清楚：`env`、`pref`、`insight` 和 `deadend`。只在本机成立的事实写入 `.story/memory/local/`，Git 会忽略该目录；超过 180 天的 `env` 事实会标为过期。记忆永远不是证据，也不能覆盖已经拥有该事实的文件：数值属于 `mates/`，论断属于 `notes/claims.md`，学校要求属于 `degree/`，出版物复用属于 `notes/publications.md`，反馈属于 `milestones/`，承诺属于 `tasks/`。

agent 会先询问是否记录记忆；`INVOLVE=low` 把它改为先记录再说明。文件格式、索引语法、退役规则和来源契约见[项目记忆](docs/mds/story-workflow/memory_spec.zh-CN.md)。

## 更新 STORY 的 skill 与工作流文档

学位论文实例可以同步 STORY 后续工作流版本，而不修改自己的手稿、证据、学位档案、笔记、里程碑、任务、记忆库、Git 分支或 remote：

```bash
bash execs/update.sh
```

更新器管理共享 agent 指令、中立 skill 与分流器、所选 harness 的入口树与 hook、Codex manifest、分流器包、工作流文档，以及 `execs/` 下的全部脚本。harness 注册文件仅在缺失时安装，除非使用 `--force`，否则已有配置保持不变。实例拥有的学位论文状态不在更新范围内。

命令的通用形式是：

```text
bash execs/update.sh [--diff] [ref] [--harnesses LIST] [--skill NAME] [--force]
bash execs/update.sh [ref] [--harnesses LIST] --adopt
```

常用示例：

```bash
bash execs/update.sh --diff
bash execs/update.sh TAG_OR_BRANCH
bash execs/update.sh --harnesses claude,pi
bash execs/update.sh --skill story-chap-drafter
bash execs/update.sh --skill story-flow-status
```

- `--diff` 只预览、不写入；有可更新内容时以 `2` 退出，完全一致时以 `0` 退出，出错时以 `1` 退出。
- `ref` 把更新固定到一个分支或 tag。
- `--harnesses` 可从 `claude`、`codex`、`cursor`、`dsh`、`kimi`、`pi`、`qwen` 中任选多个并用逗号分隔；默认值 `all` 更新全部，`none` 只更新共享路径。
- `--skill` 只更新一个 skill 在中立源、所选 harness 树、Codex manifest 和 Pi prompt 中的副本。
- `--force` 允许覆盖受管路径中的本地修改及原本会保留的 harness 配置，但不会扩大路径范围。
- `--adopt` 只把缺失的骨架文件复制进已有 Git 仓库，绝不覆盖现有路径；它不能与 `--force` 同用。

拉取来源为 `STORY_REPOSITORY`，依次从环境变量、`.env`、官方 GitHub 仓库解析。上游同路径的受管文件会被覆盖，新文件会加入，上游删除的文件不会在本地自动删除，项目专属文件保持不变。更新前先提交当前工作，不确定时先预览，再用 `git status` 与 `git diff` 检查结果。`bash execs/update.sh --help` 是权威参数说明。

## 项目约定

1. 学位层级和手稿语言的规范值写在 `degree/profile.tex`，而不是 `.env`；未知学校事实保持为空。
2. 学位论文正文使用学位档案选择的语言；结构路径、键、ID 和状态使用英文稳定值。
3. `notes/story.md` 拥有论文总论点，`notes/outline.md` 拥有章节结构，`notes/claims.md` 是论断记录表。它们应与所管辖的手稿事实放在同一次修改中更新。
4. 手稿中的每项定量或比较性陈述都要有邻近 `% src:` 锚点，或论断记录表中的证据链接；证据缺失时使用 `\todo{...}`。
5. 绝不原地修改导入证据；在来源处修正后重新导入，或把修正后的人工材料登记为新记录。
6. 出版物作者列表、候选人贡献、复用、重叠、许可和政策，应与证据可追溯性分开记录。
7. 收到的反馈保持原样；解释、处理方式、承诺和完成证据写在旁边，而不是写进原反馈。
8. 只用 `bash execs/run.sh` 构建；生成产物放在 `wkdrs/`；引用、论断、元数据、页数限制、里程碑或定稿状态变化后运行 lint。
9. 手稿源文件保持一句一行，让 diff 显示实际修改的句子，而不是它所在的整段。
10. 每次修改由最小的适用工作流负责。章节起草请求不会静默改变证据、学位要求、论文总论点或收到的反馈。

完整协作规则见 [`AGENTS.zh-CN.md`](AGENTS.zh-CN.md)；权威工作流规则见[写作工作流规范](docs/mds/story-workflow/writing-workflow-conventions.zh-CN.md)。

## 把 STORY 适配到实际学位论文

创建真实学位论文实例时：

- 只用正式且经作者确认的值替换 `degree/profile.tex` 中的占位符，并完成 `degree/` 下带来源的检查表。
- 选择唯一规范入口，让 `STORY_MAIN`、`% dissertation_language` 和手稿源文件彼此一致。
- 为每个研究或论文仓库使用稳定 slug；登记人工材料，不要把未跟踪证据直接写入手稿。
- 确定章节边界前运行 `story-syns-coach`。出版物式结构、独立综合章节、答辩或某个里程碑，只有在已确认学位层级和学校要求下适用时才启用。
- 把可复用 class/package、项目专属宏和学校正式模板彼此分离。
- 把 `STORY_HARNESSES` 设置为项目实际使用的工具，避免后续更新重新安装不需要的 harness 树。
- 如果实例将公开，应把通用 README 与文档首页替换为该学位论文自己的身份，同时保留 `docs/mds/story-workflow/` 供工作流使用。
- 除非实例有意继续作为 STORY fork，否则删除上游维护者 CI。

这套骨架的作用是承载学位论文的来源和决定，而不是规定论文的学术论点或学校格式。

## 环境要求

- Git 与 Bash 3.2+
- 带 `latexmk` 的较完整 TeX Live 或 MacTeX
- 用于手稿格式化的 `latexindent`
- 简体中文模板所需的 CTeX，以及 XeLaTeX 或 LuaLaTeX
- 用于报告页数的 `pdfinfo`
- 用于可选字数统计的 `texcount`
- 用于接入和上游更新的 `curl`
- 用于证据指纹的 `shasum` 或 `sha256sum`

各 agent harness 可能还有自己的运行要求；例如，安装 DSH 本地分流器要求 `PATH` 上有 `pnpm`。

## 许可证

见 [LICENSE](LICENSE)。
