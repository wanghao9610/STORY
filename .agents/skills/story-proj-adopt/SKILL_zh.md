---
name: story-proj-adopt
description: 安全地把已有博士论文、学位论文草稿或 Overleaf 导出接入 STORY：先盘点并确认文件映射，再保留原源文件、登记无来源论断并验证构建。
---

# 接入已有学位论文

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

1. 只读盘点草稿：入口文件、章节输入、前后置部分、图、表、参考文献、样式、构建命令、学校模板线索与候选证据。
2. 判断源文件位于仓库内还是外部；外部源目录只复制，不修改。
3. 提出映射到 `manus/fronts/`、`manus/chaps/`、`manus/backs/`、`manus/figs/`、`manus/tabs/`、`manus/bibs/` 和 `manus/stys/` 的完整方案，并列明每个路径和引用改写。
4. 移动、覆盖或更换主入口前取得作者确认。
5. 只执行已确认的映射，并写入 `notes/adopt.md`。
6. 把已有定量或比较性陈述添加到 `notes/claims.md`；除非其证据已经登记，否则状态设为 `unsourced`。把候选证据路由给 `story-evid-curator`。
7. 运行 `bash execs/run.sh`，如实报告未解决映射和编译问题。

接入阶段不重构章节；构建成功后把结构设计交给 `story-outl-planner`。
