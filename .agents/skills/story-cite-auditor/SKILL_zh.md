---
name: story-cite-auditor
description: 根据已核验记录和阅读笔记审计硕士或博士学位论文的引用键、书目质量、文献陈述、缺失引用及跨章节引用一致性；不静默修复正文。
---

# 审计引用与文献陈述

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

本 skill 对 `manus/`、书目和阅读笔记只读。检查每个引用键能否解析、每项关于已引用工作的陈述是否有本轮核验的阅读笔记或导入来源支持，以及承载论断的背景陈述是否附有恰当引用。

识别重复记录、身份字段不完整、citekey 不一致、用二手来源代替原始来源、跨章节引用漂移和从未被引用的书目条目。手稿对某项工作作出详细论断时，不得仅凭其标题或摘要判断该工作。

可再生成报告写入 `wkdrs/reports/`，每项失败在 `tasks/audits.md` 中记一个复选框，该文件首次使用时创建；元数据工作交给 `story-refs-curator`，正文修改交给 `story-chap-drafter`。不得仅为增加引用数量而添加引用。
