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
├── .dsh/commands/                 # DSH 的 /story 命令 bundle
├── .kimi-code/plugins/            # Kimi 的 /story 插件与 marketplace
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

本地 `.env` 已被 Git 忽略。`INVOLVE=low|medium|high` 控制工作流在裁量题前询问的频率，但绝不会绕过学校事实、作者贡献、删除、覆盖或最终冻结的确认。`STORY_LANG=en|zh` 控制回复与新写入 Markdown 的语言；留空时跟随对话，改变它也不会翻译已有文件。手稿语言仍以 `degree/profile.tex` 中的持久取值为准。`STORY_HARNESSES` 决定 `execs/update.sh` 安装并持续维护哪些宿主目录。

### 或者：接入一个已经存在的学位论文仓库

如果学位论文草稿已经开工，就把 STORY 骨架装进现有仓库，而不是把草稿搬进一份全新检出。在那个仓库的根目录运行：

```bash
curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o /tmp/story-update.sh
bash /tmp/story-update.sh --adopt
```

已有内容一律不覆盖：接入只复制缺失文件，并报告每个保留的路径。加上 `--harnesses claude`——或从 `claude`、`codex`、`cursor`、`dsh`、`kimi`、`pi`、`qwen` 中任选多个并用逗号分隔——即可只安装你使用的宿主。随后运行 `$story-proj-adopt`，盘点草稿，确认学位档案与学校要求，并把已有章节、证据、里程碑和未完成工作映射进 STORY 布局。

## Agent harness

所有 harness 树共用同一份事实源。与工具无关的 skill 文件只保存在 `.agents/skills/`；六棵私有入口树中逐字相同的文件通过相对软链接指向它。完整的 `/story` 路由器只在 `.agents/commands/` 编写一次：Claude、Cursor、Pi 和 Qwen 暴露文件薄包装，Kimi 打包一个只能显式调用的 skill 包装，DSH 则注册一个零依赖命令适配器。Codex 专属的 `openai.yaml` manifest 位于 `.codex/skills/`，再链接回 Codex 会发现的路径。只有 harness 专属的 frontmatter、命令语法、prompt、hook 和设置保留在各自目录中。

| Harness | Skill 入口 | 项目设置 |
| --- | --- | --- |
| Codex | `.agents/skills/` 下的 `$story-*` | 用 `/hooks` 批准 `.codex/hooks.json` |
| Claude Code | `.claude/skills/` 下的 `/story-*` | 自动加载 `.claude/settings.json` |
| Cursor | `.cursor/skills/` 下的 `/story-*` | 自动加载 `.cursor/hooks.json` 与 rules |
| DeepSeek Harness | `.dsh/skills/` 下的 `/skill:story-*`；`.dsh/commands/` 提供 `/story` | 为各 profile 安装命令 bundle；每台机器运行一次 `bash .dsh/hooks/install.sh` |
| Kimi Code | `.kimi-code/skills/` 下的 `/skill:story-*`；`.kimi-code/plugins/` 提供 `/story` | 安装本地插件；每台机器运行一次 `bash .kimi-code/hooks/install.sh` |
| Pi | 由 `.pi/skills/` 支持的 `/story-*` prompt | 信任项目后才会加载 `.pi/extensions/` |
| Qwen Code | `.qwen/skills/` 下的 `/story-*` | 自动加载 `.qwen/settings.json` |

Claude Code、Cursor、Pi 与 Qwen Code 直接从项目文件提供 `/story [你想做什么]`。命令把请求交给 `.agents/commands/story.md`；空请求选择 `story-flow-status`，匹配到六个只能显式调用的 skill 之一时，则返回准确的 `/story-<name> <argument>` 命令并等待。

Codex 把共享分流器打包成仓库内的 `story` 插件。在仓库根目录注册并安装一次，然后新开会话：

```bash
codex plugin marketplace add .
codex plugin add story@story
```

不带参数的 `$story` 显示当前论文状态，也可以传入描述，例如 `$story 审查第 3 章的论断`。插件读取的仍是其他 harness `/story` 薄包装共用的 `.agents/commands/story.md` 名册，继续要求六个 † 工作流获得显式确认，不会维护第二份路由表。

Kimi Code 把同一个分流器作为用户级插件打包在 `.kimi-code/plugins/story/`。请从仓库根目录启动 Kimi Code，在输入框依次运行下面两条命令；也可以用 `/new` 代替 `/reload`：

```text
/plugins install ./.kimi-code/plugins/story
/reload
```

不带参数的 `/story` 显示当前论文状态，也可以传入描述；`/skill:story` 是同一个外部 skill 的完整写法。Kimi 会把本地插件复制进用户级托管目录，所以 STORY 更新了该插件后，需要重新执行安装命令。

DSH 把同一个分流器放在 `.dsh/commands/story/`；安装时要求 `PATH` 上有 `pnpm`。在仓库根目录为每个将运行 STORY 的 profile 安装一次，检查组合后的配置，再重启该 profile：

```bash
dsh plugin --profile YOUR_PROFILE add ./.dsh/commands/story
dsh --profile YOUR_PROFILE --dump-config
```

不带参数的 `/story` 显示当前论文状态，也可以传入描述，例如 `/story 审查第 3 章的论断`。命令会从共享的 `.agents/commands/story.md` 名册发起一个后续轮次，因此 DSH 与其他宿主始终从同一来源分流。

维护者在 `.agents/skills/` 修改中立内容，在 `.agents/commands/` 修改共享路由器，然后运行 `bash .github/scripts/port.sh --write`；CI 会同时检查生成的 guard、共用链接、路由名册与各宿主入口。`execs/update.sh` 安装到其他项目时会展开 skill 链接，因此单独使用任一 harness 仍然是自包含的。更新范围、版本固定、预览与接入模式见[更新 STORY 的 skill 与工作流文档](#更新-story-的-skill-与工作流文档)。

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

## 项目记忆

一次会话学到、又没有任何仓库文件认领的事实——本机特有的 TeX 限制、作者的长期偏好、模拟外审已经否决过的一种论述方式——记在 `.story/memory/`，而不是当时运行的那个宿主里。一事一文件，每条在 `.story/memory/MEMORY.md` 中占一行；会话钩子会在每个受支持宿主的会话开头把这份索引交给 agent。

四种类型让条目含义清楚：`env` 保存机器或工具链事实，`pref` 保存长期工作流偏好，`insight` 保存可复用的项目判断，`deadend` 保存已经尝试并否决的路径。只有没有其他持久来源认领的事实才能进入记忆：证据属于 `mates/`，论断属于 `notes/claims.md`，学校要求属于 `degree/`，出版物复用属于 `notes/publications.md`，反馈属于 `milestones/`，承诺属于 `tasks/`。记忆只帮助导航，永远不是证据；与仓库文件冲突时，以文件为准。

只在本机成立的事实放进 `.story/memory/local/`，Git 像忽略 `.env` 一样忽略它；`env` 条目超过 180 天未核验时会标为过期。任何内容都先征得你的同意再记录，`INVOLVE=low` 则改为先记下再说明。文件格式、索引语法和退场规则见[项目记忆](docs/mds/story-workflow/memory_spec.zh-CN.md)。

## 更新 STORY 的 skill 与工作流文档

基于 STORY 创建学位论文后，可以同步后续发布的 skill 与工作流文档，而不改动手稿、证据、学位档案、笔记、里程碑、记忆库或 Git remote：

```bash
bash execs/update.sh
```

该命令默认从 STORY 的 `main` 分支更新：共享的 `.agents/skills/` 与 `.agents/commands/`；所选宿主的 skill、hook、command、prompt、agent 与 extension 目录；Codex manifest；Codex、Kimi 与 DSH 的分流包；中英两版共享 agent 指令与工作流文档；以及 `execs/` 下的全部脚本。宿主配置只在缺失时安装，除非加 `--force`，否则已有文件保持不变。

拉取来源由 `STORY_REPOSITORY` 指定，按环境变量、`.env`、内置默认值 `https://github.com/wanghao9610/STORY.git` 的顺序解析。`STORY_HARNESSES` 按同样顺序解析，默认 `all`；可以从 `claude`、`codex`、`cursor`、`dsh`、`kimi`、`pi`、`qwen` 中任选多个并用逗号分隔，也可以用 `none` 只更新共享路径。未选中的宿主目录既不安装，也不更新。

命令的两种通用形式为 `bash execs/update.sh [--diff] [ref] [--harnesses LIST] [--skill NAME] [--force]` 与 `bash execs/update.sh [ref] [--harnesses LIST] --adopt`：

```bash
bash execs/update.sh --diff
bash execs/update.sh TAG_OR_BRANCH
bash execs/update.sh --harnesses claude
bash execs/update.sh --skill story-flow-status
```

- `--diff` 只预览、不写入；有可更新内容时以 `2` 退出，完全一致时以 `0` 退出，出错时以 `1` 退出。
- `ref` 把更新固定到某个 tag 或分支。
- 如果固定的 ref 早于 `.dsh/commands/` 或 `.kimi-code/plugins/`，普通更新与 `--adopt` 都会报告并跳过这个尚不存在的可选包；缺少其他必需路径仍会中止。
- `--harnesses LIST` 仅对本次运行覆盖 `STORY_HARNESSES`；未选中的目录不在写入范围，也不纳入未提交改动检查。
- `--skill NAME` 只更新共享根与所选宿主目录中的该 skill，不动 agent 指令、工作流文档和入口脚本。
- `--force` 覆盖更新范围内的本地改动和原本会保留的宿主配置，但不会扩大更新范围。
- `--adopt` 把骨架装进已有学位论文仓库，只复制缺失文件；不能与 `--force` 同用。

`bash execs/update.sh --help` 保存完整用法摘要。上游同路径的受管文件会被覆盖，新文件会加入，上游删除的文件不会在本地自动删除，项目自有文件保持不变。更新前先提交当前工作，更新后用 `git status` 与 `git diff` 检查结果。

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
