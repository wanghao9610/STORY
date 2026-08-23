---
name: story-refs-curator
description: 使用本轮获取的权威书目记录和阅读笔记添加、核验、去重、阅读并组织学位论文参考文献；适用于书目或文献陈述需要可靠来源时。
---

# 整理参考文献与阅读笔记

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

每项工作通过 DOI、arXiv ID、稳定 URL 或准确标题在本轮获取权威记录，再写入 `manus/bibs/reference.bib`；不得凭记忆重建元数据。保留 `% src:`，规范 citekey 时不得静默破坏正文引用。

创建或更新 `notes/refs/<key>.md`，记录研究问题、方法、证据、发现、局限和实际核验过的简短可引用事实，并同步 `refs_index.md`。

发现模式先提出候选再添加；区分书目核验与学术认可、原始来源与综述。正文缺陷交给引用审计或章节起草 skill，不顺手改写。
