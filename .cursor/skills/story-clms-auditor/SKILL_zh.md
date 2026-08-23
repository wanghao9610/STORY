---
name: story-clms-auditor
description: 根据来源锚点、论断记录表和带指纹证据审计学位论文数字、比较和贡献论断；用于考核、答辩、归档前或证据变化后。
---

# 审计论断与数字

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

本 skill 对 `manus/` 和 `mates/` 只读。扫描目标章节、论断或全文；对每项定量/比较性陈述跟随 `% src:` 与记录表链接，核验指纹，重新读取数值与上下文，并给出 `matched`、`mismatched` 或 `unsourced`。

同时检查博士贡献是否在映射章节中得到支持、是否夸大候选人的个人贡献；可达上游运行 `import.sh --diff`。

仅更新 `notes/claims.md` 的状态和审计备注，详细临时报告写入 `wkdrs/reports/`，每项失败在 `tasks/` 建立持久任务。修复交给目标文件的拥有者。
