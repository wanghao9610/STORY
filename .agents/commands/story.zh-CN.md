# 路由 STORY 请求

> 本文件是 [`story.md`](story.md) 的中文对照版。运行时路由以英文原文件为准。

使用下表把硕士或博士学位论文工作流请求准确路由到一个 STORY skill。涉及学位层级的 skill 从 `degree/profile.tex` 读取 `% degree_level: master|doctoral`；路由器不得猜测。

| Skill | | 用途 |
| --- | --- | --- |
| `story-chap-drafter` | | 以作者的学术声音起草或修改一个受证据约束的章节 |
| `story-cite-auditor` | | 审计引用键、文献陈述和书目质量 |
| `story-clms-auditor` | | 审计数字、比较、学位贡献和来源锚点 |
| `story-copy-editor` | | 在不改变论断的前提下删除公式化表达并编辑文风、术语、过渡与一致性 |
| `story-defn-builder` | † | 根据已确认规则和论断构建答辩叙事与演示文稿 |
| `story-depo-packer` | † | 预检并冻结一个指定的归档包 |
| `story-evid-curator` | | 导入、登记、刷新或完整性检查证据 |
| `story-exam-reviewer` | | 模拟适合学位层级的外审或答辩委员会审查 |
| `story-figs-designer` | | 构建一个由证据支持的学位论文图 |
| `story-flow-status` | | 汇报仓库状态并给出且仅给出一个下一步动作 |
| `story-outl-planner` | † | 把已确认总叙事转化为章节架构与章节简报 |
| `story-proj-adopt` | † | 安全接入已有硕士或博士学位论文草稿 |
| `story-refs-curator` | | 整理参考文献记录与阅读笔记 |
| `story-revs-resolver` | † | 把收到的反馈转化为处理决定和可跟踪承诺 |
| `story-syns-coach` | † | 确认或修改论文级论证与贡献框架 |
| `story-tabs-builder` | | 构建一个由证据支持的学位论文表格 |

标有 † 的六个 skill 只能显式调用，因为每个都控制一项属于作者的论文级、里程碑或学校制度决定。通用 `/story` 路由绝不直接启动它们：先请求明确确认，给出准确的 `/story-<name> <argument>` 命令，然后等待。任务明确匹配时，可以选择其余十个 skill。

请求为空时选择 `story-flow-status`。否则，说明选中的 skill、选择它的一句话理由，并把原请求作为参数传入。未标记的 skill 应通过当前宿主的原生 skill 机制启动，并使用该宿主拥有的副本。如果两个 skill 同样合理，只问一个简洁问题，不要混合两者范围。绝不能绕过 skill，凭一般知识直接生成归它所有的产物。
