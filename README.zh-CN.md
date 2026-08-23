<div align="center">
  <h1>STORY</h1>
  <p><strong>Systematic Toolchain for Organizing Research over Years</strong></p>
  <p><em>A STAR takes the STAGE to tell a STORY.</em></p>
</div>

**语言：** [English](README.md) | 简体中文

STORY 是一个同时面向完整硕士与博士学位论文的仓库模板和 AI 辅助工作流。它把研究生阶段的研究、适用时的已发表论文、实验证据、章节草稿、导师和委员会反馈、学位要求、答辩材料、答辩后修改以及最终归档放进同一条可追溯链路，同时守住证据与作者贡献边界。

## STAR · STAGE · STORY

三个项目覆盖研究者工作的不同尺度。它们可以各自独立使用，也可以通过带指纹的证据彼此衔接。STORY 可以同时接入任意数量的 STAR 研究仓库、STAGE 论文仓库和人工登记材料。

| 项目 | 范围 | 链接 |
| --- | --- | --- |
| **STAR** — Systematic Toolchain for AI Research | 推进一个研究项目：从想法出发，经可复现实验，产出可直接用于论文的证据。 | [官网](https://wanghao9610.github.io/STAR/) · [GitHub](https://github.com/wanghao9610/STAR) |
| **STAGE** — Systematic Toolchain for Authoring, Guiding, and Editing | 把一项研究贡献写成可追溯的论文，贯穿评审、回复与投稿打包。 | [官网](https://wanghao9610.github.io/STAGE/) · [GitHub](https://github.com/wanghao9610/STAGE) |
| **STORY** — Systematic Toolchain for Organizing Research over Years | 把研究生阶段的研究组织成可答辩、可归档的硕士或博士学位论文。 | **当前项目** · [官网](https://wanghao9610.github.io/STORY/) · [GitHub](https://github.com/wanghao9610/STORY) |

## STORY 提供什么

- 开箱可编译的英文与简体中文通用学位论文模板，前置部分、章节、附录、图、表和参考文献各归其位。
- `mates/` 下带指纹的只读证据层，支持多研究项目与多论文来源。
- 按需创建在 `notes/` 下的总叙事、贡献映射、发表与复用映射、提纲、符号表及论断记录表。
- `degree/` 下由用户确认的学校要求和委员会记录。
- 为培养项目实际要求的开题、考核、预答辩、答辩、修改与归档阶段建立持久化里程碑记录。
- `execs/` 下统一的构建、格式化、证据导入与机械检查入口。
- 供 Codex、Claude Code、Cursor、DeepSeek Harness、Kimi Code、Pi 和 Qwen Code 使用的十六个学位层级感知工作流 skill。
- 成对维护的英文与简体中文 Markdown 文档、工作流指令和 harness 入口。
- `.story/memory/` 下属于项目自己的跨会话记忆。

## 仓库结构

```text
STORY/
├── manus/                         # 学位论文源文件
│   ├── main.tex
│   ├── main-zh.tex                 # 可直接构建的简体中文起始模板
│   ├── fronts/                    # 摘要、致谢、声明等前置部分
│   ├── chaps/                     # <n>_<slug>.tex 章节
│   ├── backs/                     # 附录等后置部分
│   ├── figs/                      # 成图；figs/srcs/ 保存可编辑源文件
│   ├── tabs/                      # 由证据生成的 LaTeX 表格
│   ├── bibs/                      # reference.bib
│   └── stys/                      # story.cls、story.sty、story.bst
├── mates/                         # 带指纹的证据快照，只读
├── degree/                        # 学位档案、学校要求、委员会
├── notes/                         # 总叙事与写作元数据；按需创建
│   ├── story.md                   # 中心论点与学位研究主线
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
├── .agents/skills/                # 中立的共用 skill 源
├── .agents/commands/              # 共用的 /story 分流名册
├── .agents/plugins/               # Codex marketplace 发现链接
├── .codex/skills/                 # Codex 专属的逐 skill manifest
├── .codex/plugins/                # Codex 的 $story 分流插件与 marketplace
└── .claude/.cursor/.dsh/.kimi-code/.pi/.qwen  # 各宿主拥有的入口树
```

## 快速开始

```bash
git clone https://github.com/wanghao9610/STORY.git my-thesis
cd my-thesis
cp .env.example .env
bash execs/run.sh
bash execs/scpts/lint.sh
```

## Agent harness

所有 harness 树共用同一份事实源。与工具无关的 skill 文件只保存在 `.agents/skills/`；六棵私有入口树中逐字相同的文件通过相对软链接指向它。完整的 `/story` 路由器只在 `.agents/commands/` 编写一次；Claude、Cursor、Pi 和 Qwen 仅暴露把请求传给它的薄包装。Codex 专属的 `openai.yaml` manifest 位于 `.codex/skills/`，再链接回 Codex 会发现的路径。只有 harness 专属的 frontmatter、命令语法、prompt、hook 和设置保留在各自目录中。

| Harness | Skill 入口 | 项目设置 |
| --- | --- | --- |
| Codex | `.agents/skills/` 下的 `$story-*` | 用 `/hooks` 批准 `.codex/hooks.json` |
| Claude Code | `.claude/skills/` 下的 `/story-*` | 自动加载 `.claude/settings.json` |
| Cursor | `.cursor/skills/` 下的 `/story-*` | 自动加载 `.cursor/hooks.json` 与 rules |
| DeepSeek Harness | `.dsh/skills/` 下的 `/skill:story-*` | 每台机器运行一次 `bash .dsh/hooks/install.sh` |
| Kimi Code | `.kimi-code/skills/` 下的 `/skill:story-*` | 每台机器运行一次 `bash .kimi-code/hooks/install.sh` |
| Pi | 由 `.pi/skills/` 支持的 `/story-*` prompt | 信任项目后才会加载 `.pi/extensions/` |
| Qwen Code | `.qwen/skills/` 下的 `/story-*` | 自动加载 `.qwen/settings.json` |

Claude、Cursor、Pi 和 Qwen 可用 `/story` 把描述出来的请求准确路由到一个工作流 skill；空请求选择 `story-flow-status`。匹配明确时，路由器可以启动未标记的 skill；对于 † skill，它只返回准确的显式命令并等待确认。维护者在 `.agents/skills/` 修改中立内容，在 `.agents/commands/` 修改共享路由器，然后运行 `bash .github/scripts/port.sh --write`；CI 会同时检查生成的 guard、共用链接、路由名册与薄包装。`execs/update.sh` 安装到其他项目时会展开 skill 链接，因此单独使用任一 harness 仍然是自包含的。

Codex 还把共享路由器打包成仓库内的 `story` 插件。在仓库根目录注册并安装一次，然后新开会话：

```bash
codex plugin marketplace add .
codex plugin add story@story
```

不带参数的 `$story` 显示当前论文状态，也可以传入描述，例如 `$story 审查第 3 章的论断`。插件读取的仍是其他 harness `/story` 薄包装共用的 `.agents/commands/story.md` 名册，继续要求六个 † 工作流获得显式确认，不会维护第二份路由表。

`execs/update.sh` 默认更新全部 harness。在 `.env` 中设置 `STORY_HARNESSES=claude,pi`，或者为单次运行传入 `--harnesses claude,pi`，即可只处理这些私有目录。`all` 选择全部 harness，`none` 只选择共用骨架。未选中的目录既不会安装，也不会更新；`.agents/skills/`、`.agents/commands/`、工作流文档、脚本和 `AGENTS.md` 属于共用范围，始终更新。选择 Codex 时，同一次运行还会安装或更新 `.codex/plugins/` 及其唯一的 `.agents/plugins/marketplace.json` 发现链接。同一选择也适用于 `--adopt`，并把 `--skill` 限定为共用 skill 及选中的私有副本。

```bash
bash execs/update.sh --harnesses claude
bash execs/update.sh --harnesses codex,cursor --skill story-flow-status
bash execs/update.sh --harnesses none --diff
```

仅根据学校或培养项目的正式材料填写 `degree/profile.tex` 与 `degree/requirements.md`，并在档案中设置唯一的规范模式：

```tex
% degree_level: master
% 或：degree_level: doctoral
```

学位层级特意不放在 `.env`：它是持久的学校事实。缺失值保持为 `unknown`；非法值以及与所选层级冲突的题名/学位措辞会使 lint 失败。已有草稿时运行 `$story-proj-adopt`；从零开始时先运行 `$story-syns-coach`，再运行 `$story-outl-planner`。

新克隆有意只保留 `notes/.gitkeep` 和 `notes/refs/.gitkeep`。
上方逻辑结构中列出的 `notes/` 文件会在首次使用时由负责它们的工作流 skill 创建；`story-flow-status` 会把缺失文件报告为尚未初始化的阶段。

### 简体中文论文模板

共用的 `story.cls` 默认使用英文；增加 `zh` 类选项后，会启用中文标题页标签、章节与前置部分名称、交叉引用名称、摘要关键词以及 CTeX 中文排版。仓库提供了可直接构建的中文起始模板：

```bash
# .env
STORY_MAIN=manus/main-zh.tex
LATEX_ENGINE=

bash execs/run.sh
bash execs/scpts/lint.sh
```

`STORY_MAIN` 选择默认入口，单次命令中的 `--main` 优先于它；相对路径从仓库根目录解析。当 `LATEX_ENGINE` 留空时，`main-zh.tex` 会自动选择 XeLaTeX。`degree/profile.tex` 中的封面字段采用 `\storylocalized{English}{中文}`，两个入口会自动选择匹配的元数据。正式采用中文前，须先确认学校对论文语言的要求，并将 `degree/profile.tex` 中的 `dissertation_language` 改为 `zh`。模板只负责本地化结构，不会自动翻译已有内容，也不会虚构学位信息。

每个研究或论文仓库分别导入：

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

## 写作工作流

1. `$story-proj-adopt`：盘点并安全接入已有学位论文。
2. `$story-evid-curator`：导入、登记和审计证据。
3. `$story-syns-coach`：确立适合学位层级的研究主线、中心论点与贡献。
4. `$story-outl-planner`：建立跨章节连贯的整体结构。
5. `$story-chap-drafter`：依据章节简报和证据逐章写作。
6. `$story-tabs-builder`、`$story-figs-designer`：制作可追溯的表格和图。
7. `$story-refs-curator`：维护可核验的文献记录与阅读笔记。
8. `$story-copy-editor`：统一术语、声音和跨章节衔接。
9. `$story-clms-auditor`、`$story-cite-auditor`：审计数字、论断与引用。
10. `$story-exam-reviewer`：模拟适合学位层级的外审专家或答辩委员会审查。
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
- 带 `latexmk` 的较完整 TeX Live；中文模板还需要 CTeX 和 XeLaTeX 或 LuaLaTeX
- `pdfinfo` 用于页数统计，`texcount` 可选用于字数统计

## 许可证

见 [LICENSE](LICENSE)。
