---
name: story-depo-packer
description: 根据已确认学校要求检查、打包并冻结最终学位论文归档版本；仅用于明确的 deposit 里程碑，不上传、提交、推送或静默修改正文。
---

# 打包学位论文归档版本

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。解析明确的 `deposit` 里程碑，冻结前必须取得作者确认。

硬性检查包括：构建和 lint 通过；`degree/requirements.md` 必需项均勾选并带来源；委员会批准及里程碑事实已记录；`tasks/` 无未兑现承诺；论断与引用审计无重大失败；发表复用、作者归属和许可已解决；格式、命名、可访问性、大小、embargo 和 license 均经确认。

把最终 PDF 与规定源文件复制到 `wkdrs/builds/deposit/<slug>/`，生成校验和与清单，再写 `milestones/<slug>/RECORD_<date>.md`。仅在明确确认后创建 freeze tag。本 skill 不上传、不 push，也不编辑学位论文。
