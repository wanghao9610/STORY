# 模型 id 的退路

**语言：** [English](model_id_spec.md) | 简体中文

[`writing-workflow-conventions.zh-CN.md`](writing-workflow-conventions.zh-CN.md) §8 那条 `model_id` 规则背后、各运行时各自的细节。钩子注入的那行溯源信息缺失，或者带来的是一条恢复命令而不是 id 时，读这里。规则本身——把运行时为当次写入会话报出的值原样记录，绝不猜——留在 §8，这里不重复。

## 各运行时怎么报

| 运行时 | 钩子 | 事件 | 注入什么 | 值在何时读取 |
|---|---|---|---|---|
| Claude Code | `.claude/hooks/story_model_id.sh` | `SessionStart` | 一条读取本次会话 transcript 的命令；没有可指的记录时才是 id 本身 | 写入当刻 |
| Codex | `.codex/hooks/story_model_id.sh` | `SessionStart` | 一条读取本次会话 rollout 的命令；没有可指的记录时才是 id 本身 | 写入当刻 |
| Cursor | `.cursor/hooks/story_model_id.sh` | `SessionStart` | id | 会话开始时 |
| DeepSeek Harness | `.dsh/hooks/story_model_id.sh` | `SessionStart` | 一条读取 DSH 会话日志的命令 | 写入当刻 |
| Kimi | `.kimi-code/hooks/story_model_id.sh` | `UserPromptSubmit` | `~/.kimi-code/config.toml` 里的 `default_model` | 取自配置，从来不是会话 |
| Pi | `.pi/extensions/story-hooks/story_model_id.sh` | `before_agent_start` 与 `model_select` | 实时的 provider/model id | 写入轮次开始前 |
| Qwen Code | `.qwen/hooks/story_model_id.sh` | `SessionStart` | 一条读取 Qwen transcript 的命令；无记录时才是 id 本身 | 写入当刻 |

要紧的差别在最后一列。产物写入当刻读取的值不会过期；Cursor 与 Kimi 可能过期，因为会话中途换模型不会改变它们读到的值。钩子文件存在不等于已经生效：DSH 与 Kimi 需要运行一次安装器，Codex hook 需要批准，Pi extension 需要信任项目；Claude、Cursor 与 Qwen 则自动读取项目注册文件。

## Claude Code 与 Codex：为什么 id 要在写入当刻才读

`model` 字段只挂在 `SessionStart` 上：`/clear`、resume、compact、fork 之后它会缺失；即便有，它描述的也只是会话开启那一刻——之后 `/model` 换模型不会触发任何钩子，于是以某个模型开始、用另一个模型写入的会话，记下的会是开始时那个。这两个运行时都保有逐回合的实际记录，因此只要payload里给出了它，注入行带来的就是一条命令而不是 id。记录该值的当刻跑它：

```bash
bash "$CLAUDE_PROJECT_DIR"/.claude/hooks/story_model_id.sh --resolve <transcript_path> [session_model]
bash .codex/hooks/story_model_id.sh --resolve <transcript_path> [session_model]
```

参数用那行已经填好的，把打印出来的值原样记录。Claude Code 这版读的是本次会话主循环 assistant 轮次上的 `message.model`，委派出去的子 agent 轮次会跳过——要问的是哪个模型在写这份产物；Codex 这版读的是 rollout 里 `turn_context` 记录上的 `payload.model`，无需跳过任何东西，因为 Codex 的子 agent 自带独立 rollout。两者都是运行时的记录而非猜测。`session_model` 是 `SessionStart` 报出的那个：逐回合记录还没有内容时由它顶上；与解析结果是同一个 id 时以它为准，好保住记录丢掉的后缀（取 `claude-opus-5[1m]` 而非 `claude-opus-5`）；但 id 不同时绝不用它——那个不同就是会话中途换过模型，而看见这件事的是逐回合记录。

## DeepSeek Harness 与 Qwen Code

DSH 在会话日志中记录 provider/model 路由；Qwen 在 assistant transcript 行上记录模型。它们注入的溯源行已经带有应执行的完整命令和路径；退路形式是：

```bash
bash .dsh/hooks/story_model_id.sh --resolve [transcript_path]
bash .qwen/hooks/story_model_id.sh --resolve <transcript_path> [session_model]
```

Pi 不需要恢复命令：extension 会在 agent 运行前取得实时模型对象，并在 `model_select` 后重新注入溯源信息。

## Kimi：一行都没注入时

Kimi 的 `SessionStart` 无法注入上下文、也不暴露模型 id，因此它的钩子改挂在 `UserPromptSubmit` 上，注入配置里的 `default_model`——会话中途换过模型的话它就是过期的。斜杠命令激活 skill 不经过该事件，因此在任何普通用户消息之前打开的 skill 什么都看不到。写 `unrecorded` 之前自己执行一次读取：

```bash
grep -E '^[[:space:]]*default_model[[:space:]]*=' "${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
```

把读到的值原样记录——仍是自报、仍可能过期。

## 什么时候 `unrecorded` 才是对的

只有当会话里任何地方都没写明模型时：运行时确实没报，且上面每一次读取也都为空。绝不凭行为推断，绝不去想"这大概是哪个模型"，也绝不把一份产物的值抄到另一份上。
