---
name: story-flow-status
description: 只读检查整个 STORY 仓库并汇报学位论文进度、证据健康、章节/论断/贡献覆盖、里程碑关口、构建状态和唯一下一步建议。
---

# 汇报博士论文工作流状态

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。本 skill 严格只读。

从仓库根目录运行随附的 `scripts/scan.sh`，再汇总学位档案和未确认学校要求、总叙事与贡献映射、章节/图/表状态、各状态论断数及证据完整性、未解决发表复用或归属、书目与阅读笔记覆盖、当前里程碑与反馈承诺、答辩/归档关口，以及最近构建、页数和 lint 信号。

明确区分 absent、unknown、stale、blocked 与 complete。只推荐一个下一步，给出拥有该任务的 `story-*` skill 和具体目标；状态检查本身不执行该动作。
