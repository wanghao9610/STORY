---
name: story-chap-drafter
description: 依据已确认章节简报、总叙事、贡献/发表映射、论断表、阅读笔记和带指纹证据起草或修改恰好一章；适用于章节写作而非全篇结构重构。
argument-hint: "CHAPTER [描述] [involve=low]"
---

# 起草一章可追溯正文

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。通过 `notes/outline.md` 中的章节编号、slug 或唯一标题解析目标；目标缺失或存在歧义时询问作者。

写作前读取章节简报、`notes/story.md`、关联的贡献与发表记录、关联的论断记录、相关阅读笔记及本轮需要的全部证据文件。

源文件保持一句一行。让章节的局部论证始终连接到学位论文的中心论点。把已发表论文材料改写成统一的学位论文声音；保留合作者归属，并且在复用记录尚未解决时，不得复制大段已发表措辞。

每个定量或比较性句子都要有邻近的 `% src:` 锚点；缺失支持写成 `\todo{...}`。在同一次修改中更新 `notes/claims.md`、`notes/notation.md` 和 `notes/outline.md` 中的章节状态。

最后运行 `bash execs/run.sh`；论断或引用发生变化时再运行 `bash execs/scpts/lint.sh`。不得修改证据、学校事实或其他章节的范围。
