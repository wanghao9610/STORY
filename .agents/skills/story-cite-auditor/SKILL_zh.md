---
name: story-cite-auditor
description: 根据已核验记录和阅读笔记审计引用键、书目质量、文献陈述、缺失引用及跨章节引用一致性；不静默修复正文。
---

# 审计引用与文献陈述

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

本 skill 对 `manus/`、参考文献库和阅读笔记只读。检查每个引用键是否能够解析、每项有关已引用工作的陈述是否由本轮核验的阅读笔记或导入来源支持，以及承载论断的背景陈述是否具有合适引用。

识别重复记录、关键字段不完整、citekey 不一致、用二手来源代替原始来源、跨章节引用漂移和未被引用的书目条目。详细论断不能仅凭标题或摘要判断。

临时报告写入 `wkdrs/reports/`，失败写为持久任务；元数据工作交给 `story-refs-curator`，正文工作交给 `story-chap-drafter`。不得为了数量而添加引用。
