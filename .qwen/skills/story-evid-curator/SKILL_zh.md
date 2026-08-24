---
name: story-evid-curator
description: 导入、登记、刷新并检查 mates/ 下的学位论文证据及其来源和指纹；适用于 STAR、STAGE、STORY 或人工研究材料，不用于就地修改证据。
argument-hint: "[check | import source=PATH [slug=NAME] | register path=FILE] [描述] [involve=low]"
---

# 整理学位论文证据

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。

选择一种模式：

- `check`（默认）：将 `mates/MANIFEST.md` 与磁盘逐项核对，报告 `ok`、`unregistered`、`missing`、`tampered` 或 `stale`。
- `import source=<path> [slug=<name>]`：通过 `bash execs/scpts/import.sh` 导入 STAR、STAGE、STORY 或结构化证据仓库。
- `register path=<file>`：确认来源、作者/所有者、日期和覆盖内容后，把人工材料复制到 `mates/manual/`。

为每个已登记文件记录来源类型、来源路径或记录、可用时的来源 commit、SHA-256、来自系统时钟的导入日期，以及该文件能够支持的内容。对文件覆盖范围的描述并不是某项论断的证据；起草 skill 仍须阅读该文件。

不得修复 `mates/` 下的内容；应指出上游修正位置，或登记新的已修正材料。本 skill 不更新任何正文。
