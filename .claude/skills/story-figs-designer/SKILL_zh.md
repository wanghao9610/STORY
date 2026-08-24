---
name: story-figs-designer
description: 规划、创建或修改一个学位论文图，保存可编辑源文件、论断性图元与图注的证据映射，以及 manus/figs/ 下的渲染 PDF。
argument-hint: "[FIGURE | new] [描述] [involve=low]"
---

# 设计一个可追溯图

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。从 `notes/outline.md` 解析一个图；添加新图前，先确认其用途、所属章节和论断 ID，再按规范 §3 的提纲状态契约将其记为 `planned`。

选择能最直接表达目标关系的形式。可编辑源文件放在 `manus/figs/srcs/`，渲染产物放在 `manus/figs/`，并在源文件内或旁边保存可搜索的证据映射。

每个数据图元、数字标签和比较性图注都要指向本轮读取的已登记证据；生成或装饰性像素不是证据。保证字体、对比度、非纯颜色区分和图注的可访问性。

同步提纲与论断、接入所属章节后构建并 lint。不得丢弃唯一可编辑源文件。
