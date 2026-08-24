---
name: story-revs-resolver
description: 将导师、委员会、外审、答辩、修改或归档环节的反馈转成保留原文的逐点记录、附理由的处理决定和可跟踪承诺；适用于收到反馈后。
---

# 处理学位论文反馈

先阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。然后解析里程碑，通读其 `feedback/` 目录下的全部文件；这些文件一律不修改。

在 `milestones/<slug>/response/` 下创建逐点记录。每个可执行意见记下一个稳定 ID、准确来源位置、受影响的章节/论断/贡献、处理状态、理由、负责 skill 和完成证据。状态仅使用 `accepted`、`completed`、`planned`、`disagreed` 和 `needs-author`。

所有承诺的正文或产物修改都同步为 `tasks/<slug>_promises.md` 中的复选框。当反馈改变某项论断的可辩护范围时，在 `notes/claims.md` 中下调该论断。实质性反对、贡献变化或面向委员会的回复，须先询问作者。

本 skill 记录反馈、权衡处理方案；不改写章节，也不改动收到的意见。
