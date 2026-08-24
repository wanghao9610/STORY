---
name: story-revs-resolver
disable-model-invocation: true
description: 将导师、委员会、外审、答辩、修改或归档反馈转成保留原文的逐点记录、处理理由和可跟踪承诺；适用于收到反馈后。
argument-hint: "[MILESTONE] [描述] [involve=high]"
---

# 处理学位论文反馈

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。解析里程碑，读取其 `feedback/` 全部文件且不修改原文件。

在 `milestones/<slug>/response/` 下创建逐点记录；每个可执行意见包含一个稳定 ID、准确来源位置、受影响的章节/论断/贡献、处理状态、理由、负责 skill 和完成证据。状态仅使用 `accepted`、`completed`、`planned`、`disagreed` 和 `needs-author`。

所有承诺的正文或产物修改都同步为 `tasks/<slug>_promises.md` 中的复选框；反馈改变某项论断的可辩护范围时，在 `notes/claims.md` 中降低该论断。实质性反对、贡献变化或面向委员会的回复须先询问作者。

本 skill 记录和分析反馈，不改写章节，也不修改收到的意见。
