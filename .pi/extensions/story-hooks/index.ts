// STORY session context for Pi. Pi discovers this extension automatically after
// the project is trusted; no global hook registration is required.
import { CONFIG_DIR_NAME, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
    let pending = true;
    let injectedModel = "";

    const hook = (cwd: string, name: string) =>
        join(cwd, CONFIG_DIR_NAME, "extensions", "story-hooks", name);

    const context = async (cwd: string, name: string, args: string[] = []) => {
        try {
            const result = await pi.exec("bash", [hook(cwd, name), ...args], { timeout: 10000 });
            return result.code === 0 ? result.stdout.trim() : "";
        } catch {
            return "";
        }
    };

    pi.on("session_start", async () => {
        pending = true;
        injectedModel = "";
    });

    pi.on("model_select", async (event) => {
        if (modelId(event.model) !== injectedModel) pending = true;
    });

    pi.on("before_agent_start", async (_event, ctx) => {
        if (!pending) return;
        pending = false;
        injectedModel = modelId(ctx.model);

        const parts = [
            await context(ctx.cwd, "story_model_id.sh", [injectedModel]),
            await context(ctx.cwd, "story_memory.sh"),
        ].filter((part) => part.length > 0);
        if (parts.length === 0) return;

        return {
            message: {
                customType: "story-context",
                content: parts.join("\n\n"),
                display: false,
            },
        };
    });
}

function modelId(model: { id?: string; provider?: string } | undefined): string {
    if (!model?.id) return "";
    return model.provider ? `${model.provider}/${model.id}` : model.id;
}
