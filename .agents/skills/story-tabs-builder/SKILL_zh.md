---
name: story-tabs-builder
description: 从带指纹证据生成或修改一个学位论文表格，为每个数据行保存来源锚点并同步论断和提纲；适用于结果、比较、映射与综合表。
---

# 构建一个证据驱动表格

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。从 `notes/outline.md` 解析一个表，或先确认新表的用途和所属章节。

本轮从已登记 `mates/` 文件重新读取每个数值，生成可编辑的 `manus/tabs/<slug>.tex`，使用清晰表头、明确单位、合理精度，并为每个承载论断的数据行写 `% src:`。缺失值保持 `\todo{...}`，不得从聊天或记忆抄写。

检查数据集、划分、指标和方向是否可比；必要限制写进表注或正文。同步表格行和论断，接入所属章节后构建并 lint。图形化需求交给 `story-figs-designer`。
