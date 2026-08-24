---
name: story-depo-packer
description: 根据已确认的学校要求检查、打包并冻结最终学位论文归档版本；仅用于明确的 deposit 里程碑，不上传、提交、推送或静默修改正文。
---

# 打包学位论文归档版本

首先完整阅读 `docs/mds/story-workflow/writing-workflow-conventions.md`。解析学位层级及明确且适用于该层级的 `deposit` 里程碑，冻结前必须取得作者确认。

预检所有硬性门槛：

1. `bash execs/run.sh` 和 `bash execs/scpts/lint.sh` 通过；
2. `degree/requirements.md` 中每个必需复选框都已勾选并附有来源；
3. 该学位层级要求的每项批准和所有里程碑事实均已记录；
4. `tasks/` 下不存在未兑现的承诺；
5. 论断与引用审计没有尚未解决的硬性失败；
6. 发表内容复用、作者归属和许可均已解决；
7. 官方格式、命名、可访问性、文件大小、延迟公开和许可证规则均已确认。

把最终 PDF 和规定的源文件复制到 `wkdrs/builds/deposit/<slug>/`，生成校验和与文件清单，再写入 `milestones/<slug>/RECORD_<date>.md`。仅在明确确认后创建冻结标签。不得上传到归档门户、推送标签或在本 skill 中编辑学位论文。
