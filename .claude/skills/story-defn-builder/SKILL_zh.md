---
name: story-defn-builder
disable-model-invocation: true
description: 依据已核验论断、确认的时长/规则和可编辑素材规划、制作并检查硕士或博士答辩叙事与演示文稿；适用于确实要求的预答辩或正式答辩。
argument-hint: "[MILESTONE] [描述] [involve=high]"
---

# 构建学位答辩

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。解析学位层级及已确认适用于该层级的 `pre-defense` 或 `defense` 里程碑；时长、必需部分、模板、比例与提交规则来自已确认的 `milestone.yml` 或作者。

在 `milestones/<slug>/materials/` 下创建答辩计划，说明受众、一个中心信息、时间预算、与学位层级相称的贡献顺序、每张主要幻灯片的证据、过渡、局限和结束论断。使用可编辑源文件构建演示文稿；仅在学位论文插图于放映条件下仍清晰可读时复用它们。

每项数字或比较性幻灯片论断都必须追溯到状态为 `verified` 的论断和已登记证据。附录/问题库覆盖方法、假设、适用时的消融、局限、作者归属和未来工作。检查时长、字号、对比度、来源可见性，以及与学位论文和已确认评审量尺的一致性。

不得编造委员会要求或重新设计证据；未解决答辩风险要显式报告。
