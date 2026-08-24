---
name: story-proj-adopt
description: 安全地把已有硕士或博士学位论文草稿、Overleaf 导出接入 STORY：先盘点并确认文件映射，再保留原源文件、登记无来源论断并验证构建。
---

# 接入已有学位论文

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

读取 `degree/profile.tex` 中的 `degree_level`。缺失或非法时可以继续盘点，但在映射层级相关的前置材料、里程碑或要求前，必须请作者确认 `master` 或 `doctoral`；不得从导入稿的标题页推断。

1. 只读盘点草稿：入口文件、章节输入、前后置部分、图、表、参考文献、样式、构建命令、学校模板线索与候选证据。
2. 判断源文件位于仓库内还是外部；外部源目录只复制，不修改。
3. 提出映射到 `manus/fronts/`、`manus/chaps/`、`manus/backs/`、`manus/figs/`、`manus/tabs/`、`manus/bibs/` 和 `manus/stys/` 的完整方案，并列明每条路径和每处引用改写。
4. 移动、覆盖或更换主入口前取得作者确认。
5. 只执行已确认的映射；首次记录获批的接入时创建 `notes/adopt.md`，再次运行时更新已有记录，不得用骨架替换。
6. 把草稿中已有的定量或比较性陈述添加到 `notes/claims.md`；除非其证据已经登记，否则状态设为 `unsourced`。论断记录表缺失时，在添加第一行之前立即用 `ID | Claim | Contribution | Stated in | Evidence | Status | Notes` 初始化。把候选证据路由给 `story-evid-curator`。
7. 运行 `bash execs/run.sh`；如实报告未解决的映射和编译失败，不猜测修复办法。

在同一次修改中创建配对的 `notes/adopt.zh-CN.md`；如本轮初始化论断记录表，也同时创建 `notes/claims.zh-CN.md`。接入期间不得创建其他 `notes/*.md` 产物。

接入阶段不重新设计章节架构；待导入的论文构建成功后，再把这项工作交给 `story-outl-planner`。
