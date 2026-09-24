// Zero-dependency `/story` and `/story-auto` slash commands. Each is a thin
// front door: the handler injects one follow-up turn that reads the shared
// file (`.agents/commands/story.md` or `story-auto.md`) and applies it to the
// user's request, so the model routes to the right STORY skill and executes it,
// or pursues the typed thesis goal. The shared files own the routing table, the
// "empty request selects story-flow-status" rule, and the goal-run procedure;
// this shim only carries the argument across.
//
// No imports on purpose: this file is a project-local package linked into the
// profile, so its module path is the project directory and any `@deepseek-ai/*`
// import would fail parent-walk resolution. `ctx.commands` is injected and the
// follow-up message is built inline with the same shape `createUserMessage`
// produces.

const name = "story";
const inject = ["commands"];

// DSH invokes a project skill as `/skill:story-<name>` and registers no
// `/story-<name>` command, so a command the shared files print for the author
// to type is respelled; every follow-up carries this line. `/story-auto` is the
// one exception: it is no skill but the command this package registers below.
const spelling = "In DSH, a skill's command is `/skill:story-<name> <argument>` wherever the shared file writes `/story-<name> <argument>`, except `/story-auto <goal>`, which DSH registers as a command and stays as written.";

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
            ? `Read \`.agents/commands/story.md\` and apply its router to an empty request (select \`story-flow-status\`). ${spelling}`
            : `Read \`.agents/commands/story.md\` and apply its router to this request: ${request}\n\n${spelling}`,
        }],
        source: { kind: "user" },
      });
      return { kind: "success" };
    },
  });
  ctx.commands.register({
    name: "story-auto",
    description: "Pursue a stated thesis goal across the STORY skills",
    input: { hint: "GOAL [involve=LEVEL]" },
    // Same as /story: the invocation is injected verbatim as the follow-up
    // message, so the command/run log event must not duplicate it as `args`.
    recordInput: false,
    handler: ({ agent, rawInput }) => {
      const invocation = rawInput.trim();
      agent.followup({
        id: crypto.randomUUID(),
        role: "user",
        content: [{
          type: "text",
          text: invocation === ""
            ? `Read \`.agents/commands/story-auto.md\` and follow it; the invocation carries no goal, so ask for one. ${spelling}`
            : `Read \`.agents/commands/story-auto.md\` and follow it with this invocation: ${invocation}\n\n${spelling}`,
        }],
        source: { kind: "user" },
      });
      return { kind: "success" };
    },
  });
}

export { apply, inject, name };
