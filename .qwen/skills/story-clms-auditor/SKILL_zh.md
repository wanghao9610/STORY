---
name: story-clms-auditor
description: 根据来源锚点、论断记录表和带指纹证据审计硕士或博士学位论文的数字、比较和学位贡献论断；用于考核、答辩、归档前或证据变化后。
argument-hint: "[CHAPTER | CLAIM_ID | full] [描述]"
---

# 审计论断与数字

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

本 skill 对 `manus/` 和 `mates/` 只读。扫描目标章节、论断或全文。对每项定量或比较性陈述，跟随邻近的 `% src:` 锚点和论断记录表链接。核验证据指纹，重新读取数值及其上下文，并给出 `matched`、`mismatched` 或 `unsourced`。

检查每项学位贡献是否在其映射章节中得到支持、是否夸大候选人的个人贡献，以及论断强度是否适合已确认的学位层级。不得用通用博士原创性门槛审计硕士贡献。对可访问的已导入来源运行 `execs/scpts/import.sh --diff`。

仅更新 `notes/claims.md` 中的论断状态和审计备注；详细的可再生成发现写入 `wkdrs/reports/`，每项失败在 `tasks/` 下建立一个持久任务。把修复工作路由给正文、表格、图、证据或贡献映射各自的拥有者。
