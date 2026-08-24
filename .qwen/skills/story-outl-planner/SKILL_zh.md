---
name: story-outl-planner
disable-model-invocation: true
description: 将已确认的硕士或博士学位论文总叙事和贡献映射转化为连贯章节架构、章节简报、图表计划与可编译骨架；适用于专著式或基于发表论文的结构。
argument-hint: "[描述] [involve=high]"
---

# 规划学位论文提纲

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

读取 `degree/profile.tex`、`notes/story.md`、`notes/contributions.md`、`notes/publications.md` 和 `notes/claims.md`。规划前解析合法学位层级；未知时停止并请求作者确认。任何必需的 `notes/` 产物缺失时，停止并路由给 `story-syns-coach`；缺失表示综合叙事阶段尚未初始化。确认已获认可的论文类型是专著式、基于发表论文的形式，还是学校批准的其他形式。

对每个拟议章节写明用途、研究问题、贡献与论断 ID、证据、计划中的图表、依赖和完成条件。检查方案是否满足：

- 呈现清晰可见的论文级论证；复用发表论文时，整体结构不能只是论文合集；
- 基础内容先于其使用位置引入；
- 方法与相关工作只保留有限重复；
- 存在多个研究章节时，各章之间有明确过渡；
- 综合程度与学位层级相称；只有已确认规则或研究主线需要时才设置独立综合章；
- 作者归属和发表内容复用准确。

硕士模式不得推断最少章节数、研究数、贡献数或发表数。作者确认后，缺失时创建 `notes/outline.md`，存在时进行协调更新。其表格为 `Chapter | File | Purpose | Contributions | Claims | Status`，并包含 Figures 表（`ID | File | Purpose | Evidence | Chapter | Status`）以及同列结构的 Tables 表。使用规范 §3 的字段格式和统一提纲状态，新记录均初始化为 `planned`。创建或重命名 `manus/chaps/<n>_<slug>.tex` 骨架，更新 `manus/main.tex` 中的 `\input` 顺序，并创建或初始化 `notes/notation.md`，列为 `Symbol or term | Meaning | First use | Scope`；符号表单元格使用自由文本，`First use` 留空或填写手稿的仓库相对路径，`Scope` 使用 `thesis-wide | <章节路径>`。在同一次修改中创建配对的 `*.zh-CN.md` 产物，然后构建。未经明确同意不得用骨架替换已有笔记或删除已有章节。
