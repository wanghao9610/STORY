# STORY skill 根目录（Pi）

**语言：** [English](APPEND_SYSTEM.md) | 简体中文

Pi 可以在 `.pi/skills/` 和 `.agents/skills/` 下发现同一组工作流 skill。本项目通过 `.pi/settings.json` 排除 Pi 对 `.agents/skills/` 的发现；始终读取 `.pi/skills/` 下由 Pi 拥有的副本。

通过 `.pi/prompts/` 下的 prompt 模板调用 skill：使用 `/story-<name>`，或用 `/story` 路由请求；相应的 `*.zh-CN.md` 是简体中文对照入口。`.agents` 树是与工具无关的共用源，不能替代 Pi 的入口。
