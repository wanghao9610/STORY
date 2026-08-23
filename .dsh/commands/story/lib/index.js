// Zero-dependency `/story` slash command. It is a thin front door: the handler
// injects one follow-up turn that reads the shared router
// (`.agents/commands/story.md`) and applies it to the user's request, so the
// model routes to the right STORY skill and executes it. The router owns the
// routing table and the "empty request selects story-flow-status" rule; this
// shim only carries the argument across.
//
// No imports on purpose: this file is a project-local package linked into the
// profile, so its module path is the project directory and any `@deepseek-ai/*`
// import would fail parent-walk resolution. `ctx.commands` is injected and the
// follow-up message is built inline with the same shape `createUserMessage`
// produces.

const name = "story";
const inject = ["commands"];

function apply(ctx) {
  ctx.commands.register({
    name: "story",
    description: "Route a request to the right STORY thesis skill",
    input: { hint: "[what you want to do]" },
    // The request is injected verbatim as the follow-up message, so the
    // command/run log event must not duplicate it as `args`.
    recordInput: false,
    handler: ({ agent, rawInput }) => {
      const request = rawInput.trim();
      agent.followup({
        id: crypto.randomUUID(),
        role: "user",
        content: [{
          type: "text",
          text: request === ""
            ? "Read `.agents/commands/story.md` and apply its router to an empty request (select `story-flow-status`)."
            : `Read \`.agents/commands/story.md\` and apply its router to this request: ${request}`,
        }],
        source: { kind: "user" },
      });
      return { kind: "success" };
    },
  });
}

export { apply, inject, name };
