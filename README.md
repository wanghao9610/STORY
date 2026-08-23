<div align="center">
  <h1>STORY</h1>
  <p><strong>Systematic Toolchain for Organizing Research over Years</strong></p>
  <p><em>A STAR takes the STAGE to tell a STORY.</em></p>
</div>

**Language:** English | [简体中文](README.zh-CN.md)

STORY is a repository template and AI-assisted workflow for writing a complete master's thesis or doctoral dissertation. It organizes graduate research, published papers where applicable, experimental evidence, chapter drafts, committee feedback, degree requirements, defense materials, corrections, and the final deposit without losing provenance or authorship boundaries.

## STAR · STAGE · STORY

The three projects cover successive scales of a researcher's work. Use any one independently, or connect them through fingerprinted evidence. STORY can combine any number of STAR research repositories, STAGE paper repositories, and manually registered sources.

| Project | Scope | Links |
| --- | --- | --- |
| **STAR** — Systematic Toolchain for AI Research | Runs one research project from idea through reproducible experiments and paper-ready evidence. | [Website](https://wanghao9610.github.io/STAR/) · [GitHub](https://github.com/wanghao9610/STAR) |
| **STAGE** — Systematic Toolchain for Authoring, Guiding, and Editing | Turns one research contribution into a traceable paper, review cycle, and submission package. | [Website](https://wanghao9610.github.io/STAGE/) · [GitHub](https://github.com/wanghao9610/STAGE) |
| **STORY** — Systematic Toolchain for Organizing Research over Years | Shapes graduate research into a defensible master's thesis or doctoral dissertation, defense, and deposit. | **Current project** · [Website](https://wanghao9610.github.io/STORY/) · [GitHub](https://github.com/wanghao9610/STORY) |

## What STORY provides

- Generic, compilable English and Simplified Chinese master's/doctoral thesis templates with front matter, chapters, appendices, figures, tables, and bibliography separated cleanly.
- A fingerprinted, read-only evidence store under `mates/`, supporting multiple research and paper repositories.
- A thesis-level narrative, contribution map, publication/reuse map, outline, notation table, and claim ledger created on demand under `notes/`.
- User-confirmed institutional requirements and committee records under `degree/`.
- Durable milestone records for whichever proposal, review, pre-defense, defense, correction, and deposit stages the confirmed program requires.
- Deterministic build, formatting, import, and lint entrypoints under `execs/`.
- Sixteen degree-aware workflow skills available to Codex, Claude Code, Cursor, DeepSeek Harness, Kimi Code, Pi, and Qwen Code.
- Paired English and Simplified Chinese Markdown documentation, workflow instructions, and harness entry points.
- Project-owned memory under `.story/memory/` for facts not owned by another repository file.

## Repository layout

```text
STORY/
├── manus/                         # Thesis source
│   ├── main.tex
│   ├── main-zh.tex                 # Buildable Simplified Chinese starter
│   ├── fronts/                    # Abstract, acknowledgements, declarations
│   ├── chaps/                     # <n>_<slug>.tex chapters
│   ├── backs/                     # Appendices and other back matter
│   ├── figs/                      # Rendered figures; figs/srcs/ holds sources
│   ├── tabs/                      # Evidence-backed LaTeX tables
│   ├── bibs/                      # reference.bib
│   └── stys/                      # story.cls, story.sty, story.bst
├── mates/                         # Fingerprinted evidence snapshots; read-only
├── degree/                        # Institutional profile, requirements, committee
├── notes/                         # Narrative and writing metadata; created on demand
│   ├── story.md                   # Central argument and degree research arc
│   ├── contributions.md           # Contribution → evidence/publication/chapter
│   ├── publications.md            # Authorship, reuse, permissions, overlap
│   ├── outline.md                 # Chapter plan
│   ├── claims.md                  # Claim ledger
│   ├── notation.md
│   ├── style.md
│   └── refs/                      # Reading notes and reference index
├── milestones/                    # Proposal, reviews, defense, corrections, deposit
├── tasks/                         # Durable open work and feedback promises
├── wkdrs/                         # Builds and regenerable reports; gitignored
├── execs/                         # Build/update entrypoints and utilities
├── docs/mds/story-workflow/       # Workflow conventions and skill guide
├── .agents/skills/                # Neutral shared skill source
├── .agents/commands/              # Shared /story routing roster
├── .agents/plugins/               # Codex marketplace discovery link
├── .codex/skills/                 # Codex-owned per-skill manifests
├── .codex/plugins/                # Codex $story router plugin and marketplace
├── .dsh/commands/                 # DSH /story command bundle
├── .kimi-code/plugins/            # Kimi /story plugin and marketplace
└── .claude/.cursor/.dsh/.kimi-code/.pi/.qwen  # Harness-owned entry trees
```

## Quick start

```bash
git clone https://github.com/wanghao9610/STORY.git my-thesis
cd my-thesis
cp .env.example .env
bash execs/run.sh
bash execs/scpts/lint.sh
```

The local `.env` file is ignored by Git. `INVOLVE=low|medium|high` controls how often a workflow asks before judgment calls; it never bypasses confirmation of institutional facts, attribution, deletion, overwriting, or final freeze. `STORY_LANG=en|zh` controls replies and newly written Markdown; left empty, it follows the conversation, and changing it never translates an existing file. The manuscript language remains the durable value in `degree/profile.tex`. `STORY_HARNESSES` selects which harness trees `execs/update.sh` installs and keeps current.

### Or adopt a thesis repository that already exists

If a thesis draft is already underway, install the STORY skeleton into that repository instead of moving the draft into a fresh clone. Run at its root:

```bash
curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o /tmp/story-update.sh
bash /tmp/story-update.sh --adopt
```

Nothing already there is overwritten: adoption copies only absent files and reports every path it keeps. Add `--harnesses claude` — or any comma-separated set of `claude`, `codex`, `cursor`, `dsh`, `kimi`, `pi`, and `qwen` — to install only the harnesses you use. Then run `$story-proj-adopt` to inventory the draft, confirm its degree profile and institutional requirements, and map existing chapters, evidence, milestones, and open work into the STORY layout.

## Agent harnesses

The harness trees share one source of truth. Tool-neutral skill files live once under `.agents/skills/`; byte-identical files in the six private entry trees are relative links to that source. The complete `/story` router is authored once under `.agents/commands/`: Claude, Cursor, Pi, and Qwen expose thin file wrappers, Kimi packages an explicit-only skill wrapper, and DSH registers a zero-dependency command shim. Codex-specific `openai.yaml` manifests live under `.codex/skills/` and are linked back at the path Codex discovers. Only harness-specific frontmatter, command syntax, prompts, hooks, and settings remain private.

| Harness | Skill entry | Project setup |
| --- | --- | --- |
| Codex | `$story-*` from `.agents/skills/` | Approve `.codex/hooks.json` with `/hooks` |
| Claude Code | `/story-*` from `.claude/skills/` | `.claude/settings.json` loads automatically |
| Cursor | `/story-*` from `.cursor/skills/` | `.cursor/hooks.json` and rules load automatically |
| DeepSeek Harness | `/skill:story-*` from `.dsh/skills/`; `/story` from `.dsh/commands/` | Install the command bundle into each profile; run `bash .dsh/hooks/install.sh` once per machine |
| Kimi Code | `/skill:story-*` from `.kimi-code/skills/`; `/story` from `.kimi-code/plugins/` | Install the local plugin; run `bash .kimi-code/hooks/install.sh` once per machine |
| Pi | `/story-*` prompts backed by `.pi/skills/` | Trust the project so `.pi/extensions/` can load |
| Qwen Code | `/story-*` from `.qwen/skills/` | `.qwen/settings.json` loads automatically |

Claude Code, Cursor, Pi, and Qwen Code expose `/story [what you want to do]` directly from project files. The command sends the request through `.agents/commands/story.md`; an empty request selects `story-flow-status`, and a match to one of the six explicit-only skills returns the exact `/story-<name> <argument>` command and waits.

Codex packages the shared router as the repo-local `story` plugin. Register and install it once from the repository root, then start a new session:

```bash
codex plugin marketplace add .
codex plugin add story@story
```

Use `$story` with no argument for the current thesis status, or pass a request such as `$story audit the claims in chapter 3`. The plugin reads the same `.agents/commands/story.md` roster as the other harnesses' `/story` wrappers, preserves explicit confirmation for the six † workflows, and adds no second routing table.

Kimi Code packages the same router as a user-installed plugin under `.kimi-code/plugins/story/`. Start Kimi Code from the repository root and run these commands in its prompt; `/new` may replace `/reload`:

```text
/plugins install ./.kimi-code/plugins/story
/reload
```

Use `/story` with no argument for the current thesis status, or pass a described task; `/skill:story` is the explicit spelling of the same external skill. Kimi copies a local plugin into its user-level managed directory, so repeat the install command after STORY updates this plugin.

DSH packages the same router under `.dsh/commands/story/`; installation requires `pnpm` on `PATH`. From the repository root, install it once into every profile that will run STORY, inspect the composed configuration, then restart that profile:

```bash
dsh plugin --profile YOUR_PROFILE add ./.dsh/commands/story
dsh --profile YOUR_PROFILE --dump-config
```

Use `/story` with no argument for the current thesis status, or pass a request such as `/story audit the claims in chapter 3`. The command starts one follow-up turn against the shared `.agents/commands/story.md` roster, so DSH and the other harnesses route from the same source.

Maintainers edit neutral content under `.agents/skills/` and the shared router under `.agents/commands/`, then run `bash .github/scripts/port.sh --write`; CI verifies the generated guards, shared links, router roster, and harness front doors. `execs/update.sh` dereferences skill links when installing into another project, so a selected harness remains self-contained. Its scope, version pinning, preview, and adoption modes are documented under [Updating STORY skills and workflow docs](#updating-story-skills-and-workflow-docs).

Fill `degree/profile.tex` and `degree/requirements.md` only from official university or program material confirmed by the author. Set exactly one canonical mode in the profile:

```tex
% degree_level: master
% or: degree_level: doctoral
```

The level is deliberately not an `.env` variable: it is durable institutional metadata. Missing values remain `unknown`; invalid values and title/degree wording that conflicts with the selected level fail lint. Then run `$story-proj-adopt` for an existing draft, or start with `$story-syns-coach` and `$story-outl-planner`.

A fresh clone intentionally contains only `notes/.gitkeep` and `notes/refs/.gitkeep`.
The files shown under `notes/` in the logical layout above are materialized by their owning workflow skills on first use; `story-flow-status` reports an absent file as an uninitialized stage.

### Simplified Chinese template

The shared `story.cls` uses English by default and enables localized Chinese headings, title-page labels, cross-reference names, abstract keywords, and CTeX typesetting with the `zh` class option. A buildable starter is included:

```bash
# .env
STORY_MAIN=manus/main-zh.tex
LATEX_ENGINE=

bash execs/run.sh
bash execs/scpts/lint.sh
```

`STORY_MAIN` selects the default entry point; `--main` overrides it for a single command. Relative `STORY_MAIN` paths are resolved from the repository root. `main-zh.tex` selects XeLaTeX when `LATEX_ENGINE` is empty. Title-page fields in `degree/profile.tex` use `\storylocalized{English}{中文}` so the two entry points select matching metadata automatically. Before adopting Chinese as the canonical thesis language, confirm the institutional rule and change `dissertation_language` in `degree/profile.tex` to `zh`. The template localizes structure; it does not translate existing content or invent degree metadata.

Import each research source separately:

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

## Workflow

1. `$story-proj-adopt` inventories and adopts an existing thesis safely.
2. `$story-evid-curator` imports, registers, and audits evidence.
3. `$story-syns-coach` establishes a degree-appropriate thesis-level research arc and contributions.
4. `$story-outl-planner` creates a coherent chapter architecture.
5. `$story-chap-drafter` drafts one chapter from evidence and its brief.
6. `$story-tabs-builder` and `$story-figs-designer` build traceable visuals.
7. `$story-refs-curator` maintains verified bibliography records and reading notes.
8. `$story-copy-editor` harmonizes voice, terminology, and cross-chapter flow.
9. `$story-clms-auditor` and `$story-cite-auditor` audit numbers, claims, and citations.
10. `$story-exam-reviewer` simulates a degree-appropriate examiner or committee review.
11. `$story-revs-resolver` tracks and resolves feedback without editing received comments.
12. `$story-defn-builder` prepares and checks the defense deck.
13. `$story-depo-packer` preflights and freezes the final deposit package.
14. `$story-flow-status` reports the current state and one recommended next action.

The authoritative workflow rules are in [writing-workflow-conventions.md](docs/mds/story-workflow/writing-workflow-conventions.md).

## Project memory

What a session learns that no repository file owns — a machine-specific TeX limitation, a standing author preference, or a framing already rejected in a mock examination — is recorded under `.story/memory/`, not in whichever harness happened to be running. One fact lives in one file, one line per fact appears in `.story/memory/MEMORY.md`, and a session hook puts that index in front of the agent in every supported harness.

Four types keep the entries legible: `env` for machine or toolchain facts, `pref` for durable workflow preferences, `insight` for reusable project judgments, and `deadend` for tried and rejected approaches. A fact is recorded only when no durable source already owns it: evidence belongs to `mates/`, claims to `notes/claims.md`, institutional requirements to `degree/`, publication reuse to `notes/publications.md`, feedback to `milestones/`, and promises to `tasks/`. Memory is a navigation aid, never evidence, and repository files win whenever they disagree with it.

Machine-only facts go under `.story/memory/local/`, which Git ignores like `.env`; an `env` entry older than 180 days is marked stale. Nothing is recorded without your approval, while `INVOLVE=low` changes that to record-and-tell. The file format, index syntax, and retirement rules are in [Project Memory](docs/mds/story-workflow/memory_spec.md).

## Updating STORY skills and workflow docs

After creating a thesis from STORY, later skill and workflow-document releases can be synced without changing the manuscript, evidence, degree records, notes, milestones, memory store, or Git remotes:

```bash
bash execs/update.sh
```

By default, the command updates from STORY's `main` branch: the shared `.agents/skills/` and `.agents/commands/` roots; the selected harness skill, hook, command, prompt, agent, and extension trees; Codex manifests; the Codex, Kimi, and DSH router packages; both editions of the shared agent instructions and workflow docs; and every script under `execs/`. Harness configuration is installed only when absent and otherwise kept unless `--force` is supplied.

The source is `STORY_REPOSITORY`, resolved from the environment, then `.env`, then `https://github.com/wanghao9610/STORY.git`. `STORY_HARNESSES` is resolved the same way and defaults to `all`; use a comma-separated set of `claude`, `codex`, `cursor`, `dsh`, `kimi`, `pi`, and `qwen`, or `none` for shared paths only. An unselected harness tree is neither installed nor updated.

The general forms are `bash execs/update.sh [--diff] [ref] [--harnesses LIST] [--skill NAME] [--force]` and `bash execs/update.sh [ref] [--harnesses LIST] --adopt`:

```bash
bash execs/update.sh --diff
bash execs/update.sh TAG_OR_BRANCH
bash execs/update.sh --harnesses claude
bash execs/update.sh --skill story-flow-status
```

- `--diff` previews without writing and exits `2` when an update is available, `0` when everything matches, and `1` on error.
- A `ref` pins the update to a tag or branch.
- When a pinned ref predates `.dsh/commands/` or `.kimi-code/plugins/`, both a normal update and `--adopt` report the absent optional package and continue; a missing required path still stops the run.
- `--harnesses LIST` overrides `STORY_HARNESSES` for one run; unselected trees remain outside the write set and the uncommitted-change check.
- `--skill NAME` updates only that skill across the shared root and selected harness trees, leaving agent instructions, workflow docs, and entrypoints alone.
- `--force` overwrites managed local changes and kept harness configuration without widening the update scope.
- `--adopt` installs the skeleton into an existing thesis repository, copying only absent files; it cannot be combined with `--force`.

`bash execs/update.sh --help` carries the complete usage summary. Matching managed files are overwritten, new upstream files are added, upstream removals are not deleted locally, and project-specific files are preserved. Commit current work before updating, then review the result with `git status` and `git diff`.

## Evidence and authorship

Every quantitative or comparative claim must lead to a registered `mates/` artifact or remain visibly unresolved. `notes/publications.md` separately records which chapters reuse published material, coauthor contributions, permissions, and overlap. Evidence traceability does not replace attribution; STORY requires both.

## Institutional formats

The bundled class is intentionally generic. Official university templates and rules are user-supplied facts. Keep the generic manuscript intact; generate or maintain institution-specific packaging as a separate deposit milestone so a format conversion cannot silently rewrite the thesis's source of truth.

## Requirements

- Bash 3.2+
- A reasonably complete TeX Live distribution with `latexmk`; the Chinese template also needs CTeX and XeLaTeX or LuaLaTeX
- `pdfinfo` for page counts and `texcount` for optional word counts

## License

See [LICENSE](LICENSE).
