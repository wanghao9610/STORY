---
name: story-outl-planner
disable-model-invocation: true
description: 将已确认的总叙事和贡献映射转化为连贯章节架构、章节简报、图表计划与可编译骨架；适用于专著式或论文合集式学位论文。
---

# 规划学位论文提纲

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

读取 `degree/profile.tex`、`notes/story.md`、`notes/contributions.md`、`notes/publications.md` 和 `notes/claims.md`。确认已获认可的论文类型是专著式、基于发表论文的形式，还是学校批准的其他形式。

对每个拟议章节写明用途、研究问题、贡献与论断 ID、证据、计划中的图表、依赖和完成条件。检查方案是否满足：

- 呈现清晰可见的论文级论证，而不是论文合集；
- 基础内容先于其使用位置引入；
- 方法与相关工作只保留有限重复；
- 研究章节之间有明确过渡；
- 综合章产生跨研究洞见；
- 作者归属和发表内容复用准确。

作者确认后，更新 `notes/outline.md`，创建或重命名 `manus/chaps/<n>_<slug>.tex` 骨架，更新 `manus/main.tex` 中的 `\input` 顺序，为 `notes/notation.md` 写入初始内容，然后构建。未经明确同意不得删除已有章节。
