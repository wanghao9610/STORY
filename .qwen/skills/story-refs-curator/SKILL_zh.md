---
name: story-refs-curator
description: 使用本轮获取的权威书目记录和阅读笔记添加、核验、去重、阅读并组织学位论文参考文献；适用于书目或文献陈述需要可靠来源时。
argument-hint: "PAPER... [描述] [involve=low]"
---

# 整理参考文献与阅读笔记

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

每项工作通过 DOI、arXiv ID、稳定 URL 或准确标题在本轮获取权威记录，再写入 `manus/bibs/reference.bib`；不得凭记忆重建元数据。保留 `% src:`，规范 citekey 时不得静默破坏正文引用。

创建或更新 `notes/refs/<key>.md`，记录研究问题、方法、证据、发现、局限和实际核验过的简短可引用事实。添加第一篇已核验文献之前，如 `notes/refs/refs_index.md` 缺失，则以 `Bibkey | Work | Reading note | Used in chapters | Verification status` 创建；状态使用规范 §3 的核验值，只有获取权威身份记录后才能设为 `metadata-verified`，只有检查来源正文并完成阅读笔记后才能设为 `content-verified`。只发现候选而没有添加任何内容时，不创建空索引。在同一次修改中创建配对的 `*.zh-CN.md` 产物。更新已有索引时不得替换其原有内容。

发现文献时，先提出候选再添加。区分书目核验与学术认可，也区分原始来源与综述。把没有支持的正文陈述路由给 `story-cite-auditor` 或 `story-chap-drafter`，不得顺手修补。
