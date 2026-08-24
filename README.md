<div align="center">
  <img src="docs/srcs/story-project-icon.png" alt="STORY project icon" width="128">
  <h1>STORY</h1>
  <p><strong>Systematic Toolchain for Organizing Research over Years</strong></p>
  <p><em>A STAR takes the STAGE to tell a STORY.</em></p>
  <p><a href="https://wanghao9610.github.io/STORY/"><strong>Documentation site</strong></a></p>
</div>

**Language:** English | [简体中文](README.zh-CN.md)

STORY turns years of graduate research into one coherent, defensible, and deposit-ready master's thesis or doctoral dissertation. It keeps the manuscript, research evidence, publication reuse, degree requirements, chapter plans, contribution and claim records, committee feedback, defense materials, corrections, and deposit history in predictable locations. Researchers and AI writing agents work from the same repository-owned instructions, so the thesis can be resumed across sessions and examined long after a particular chat has disappeared.

The central contract is provenance. Every quantitative or comparative statement in the thesis traces to a fingerprinted file under `mates/` or remains visibly unresolved as `\todo{...}`; every assertion about cited work is checked against a reading note or imported source; every degree contribution records its evidence, chapter, publication, and attribution boundaries. STORY therefore treats a thesis as a synthesis of research rather than a stack of papers pasted together.

STORY is double-layered: this repository is the **template**; one degree thesis = one **instance**, created by cloning the template or installing its skeleton into an existing thesis repository with `execs/update.sh --adopt`. An instance may import any number of [STAR](https://github.com/wanghao9610/STAR) research repositories, [STAGE](https://github.com/wanghao9610/STAGE) paper repositories, other STORY theses, and manually registered sources. The pairing is optional—STORY also works as a standalone thesis repository.

## Contents

- [Contents](#contents)
- [STAR · STAGE · STORY](#star-·-stage-·-story)
- [What STORY provides](#what-story-provides)
- [Project structure](#project-structure)
- [Thesis template](#thesis-template)
  - [English and Simplified Chinese](#english-and-simplified-chinese)
  - [Degree profile and institutional formats](#degree-profile-and-institutional-formats)
- [Quick start](#quick-start)
  - [1. Create the thesis repository](#1-create-the-thesis-repository)
  - [1b. Or adopt a thesis repository that already exists](#1b-or-adopt-a-thesis-repository-that-already-exists)
  - [2. Configure the local runtime and degree profile](#2-configure-the-local-runtime-and-degree-profile)
  - [3. Path A: import existing research](#3-path-a-import-existing-research)
  - [4. Path B: register standalone evidence](#4-path-b-register-standalone-evidence)
  - [5. Build and lint](#5-build-and-lint)
  - [6. Start the thesis workflow](#6-start-the-thesis-workflow)
- [Writing workflow](#writing-workflow)
- [The path from research to deposit](#the-path-from-research-to-deposit)
- [Evidence, attribution, and the claim ledger](#evidence-attribution-and-the-claim-ledger)
- [Degree milestones](#degree-milestones)
- [Agent harnesses](#agent-harnesses)
- [Project memory](#project-memory)
- [Updating STORY skills and workflow docs](#updating-story-skills-and-workflow-docs)
- [Project conventions](#project-conventions)
- [Adapting STORY to a thesis](#adapting-story-to-a-thesis)
- [Requirements](#requirements)
- [License](#license)

## STAR · STAGE · STORY

The three projects cover successive scales of a researcher's work. Use any one independently, or connect them through fingerprinted evidence.

| Project | Scope | Links |
| --- | --- | --- |
| **STAR** — Systematic Toolchain for AI Research | Runs one research project from idea through reproducible experiments and paper-ready evidence. | [Website](https://wanghao9610.github.io/STAR/) · [GitHub](https://github.com/wanghao9610/STAR) |
| **STAGE** — Systematic Toolchain for Authoring, Guiding, and Editing | Turns one research contribution into a traceable paper, review cycle, and submission package. | [Website](https://wanghao9610.github.io/STAGE/) · [GitHub](https://github.com/wanghao9610/STAGE) |
| **STORY** — Systematic Toolchain for Organizing Research over Years | Shapes graduate research into a defensible master's thesis or doctoral dissertation, defense, and deposit. | **Current project** · [Website](https://wanghao9610.github.io/STORY/) · [GitHub](https://github.com/wanghao9610/STORY) |

The handoff is one-way and auditable: STAR produces research records and results; STAGE turns a contribution into a paper and its review history; STORY snapshots the relevant artifacts as read-only evidence and synthesizes them at degree scale. Fix an upstream value at its source, then re-import it—never edit the snapshot in place.

## What STORY provides

- **A complete thesis workspace** for front matter, chapters, appendices, figures, tables, bibliography, institutional records, milestones, and durable open work.
- **A generic, buildable LaTeX template** for English and Simplified Chinese master's theses and doctoral dissertations, with the reusable class, authoring macros, and bibliography style separated from thesis content.
- **A fingerprinted evidence layer** under `mates/`, importing selected artifacts from multiple STAR, STAGE, STORY, or structured generic repositories while preserving source paths, commits, import dates, and SHA-256 fingerprints.
- **A thesis-level source of truth** under `notes/`: the central argument, research arc, contribution map, publication/reuse map, chapter architecture, notation, style, reading notes, and claim ledger are created on demand by their owning workflows.
- **Degree-aware standards**: `degree/profile.tex` selects `master` or `doctoral`; level-specific synthesis, examination, defense, and deposit gates remain disabled while that fact is unknown.
- **Institutional facts kept separate from guesses**: official requirements, title-page wording, committee records, templates, limits, approvals, and deadlines enter only from author-confirmed sources under `degree/` and `milestones/`.
- **A complete thesis lifecycle through sixteen skills**: adoption, evidence curation, synthesis, outlining, chapter drafting, figures, tables, references, copy editing, audits, mock examination, feedback resolution, defense, deposit, and status reporting.
- **Deterministic build and checks**: `execs/run.sh` builds out of tree; `lint.sh` checks references, todos, degree-profile consistency, page limits, and formatting; `fmt.sh` preserves one sentence per line; `import.sh --diff` detects evidence drift.
- **One workflow across seven agent harnesses**: Codex, Claude Code, Cursor, DeepSeek Harness, Kimi Code, Pi, and Qwen Code share the same neutral skills and request router.
- **Project-owned memory** under `.story/memory/` for durable session knowledge that no evidence, degree, note, milestone, or task file already owns.
- **Paired English and Simplified Chinese documentation** for human readers, while paths, IDs, states, commands, and machine-readable fields remain stable in English.

See [Writing workflow](#writing-workflow) for each skill's responsibility and output. The [STORY Workflow Skills Guide](docs/mds/story-workflow/writing-workflow-skills.md) gives the compact pipeline; the [Writing Workflow Conventions](docs/mds/story-workflow/writing-workflow-conventions.md) define the evidence, degree, milestone, language, and verification contracts every skill follows.

## Project structure

```text
STORY/
├── manus/                         # Thesis source
│   ├── main.tex                   # English entry point
│   ├── main-zh.tex                # Buildable Simplified Chinese starter
│   ├── fronts/                    # Abstract, acknowledgements, declarations
│   ├── chaps/                     # Numbered chapters: <n>_<slug>.tex
│   ├── backs/                     # Appendices and other back matter
│   ├── figs/                      # Rendered figures; figs/srcs/ holds editable sources
│   ├── tabs/                      # Evidence-backed LaTeX tables
│   ├── bibs/                      # reference.bib
│   └── stys/                      # story.cls, story.sty, story.bst
├── mates/                         # Imported evidence snapshots—read-only
│   ├── <source-slug>/             # One namespaced source repository
│   ├── manual/                    # Manually supplied research artifacts
│   └── MANIFEST.md                # Provenance and SHA-256 ledger
├── degree/                        # Author-confirmed institutional facts
│   ├── profile.tex                # Degree level, language, title-page metadata
│   ├── requirements.md            # Sourced degree and deposit checklist
│   └── committee.md               # Confirmed supervision and committee record
├── notes/                         # Thesis narrative and writing metadata
│   ├── story.md                   # Central argument and degree research arc
│   ├── contributions.md           # Contribution → evidence/publication/chapter
│   ├── publications.md            # Authorship, reuse, permissions, overlap
│   ├── outline.md                 # Chapter briefs and visual plans
│   ├── claims.md                  # Claim ledger
│   ├── notation.md                # Thesis-wide notation
│   ├── style.md                   # Measurable prose conventions
│   └── refs/                      # Reading notes and reference index
├── milestones/                    # Proposal, reviews, examination, defense, deposit
│   └── <slug>/                    # milestone.yml, feedback/, response/, materials/, RECORD_*.md
├── tasks/                         # Durable unresolved work and feedback promises
├── wkdrs/                         # Builds and regenerable reports; gitignored
├── execs/
│   ├── run.sh                     # Thesis build entry point
│   ├── update.sh                  # Sync upstream workflow files; --adopt installs the skeleton
│   └── scpts/                     # import.sh, lint.sh, fmt.sh
├── docs/                          # Documentation site and workflow guides
├── .story/memory/                 # Project memory; local/ is machine-only
├── .agents/                       # Neutral skills and shared /story router
├── .codex/                        # Codex hooks, manifests, and $story plugin
├── .claude/ .cursor/ .dsh/        # Harness-specific entry points and hooks
├── .kimi-code/ .pi/ .qwen/        # Harness-specific entry points and hooks
├── .env.example                   # Local configuration example
├── AGENTS.md                      # Shared rules for AI writing agents
└── README.md
```

The abbreviated directory names follow STAR and STAGE:

| Directory | Stands for | Contents |
| --- | --- | --- |
| `manus/` | Manuscript | The thesis's LaTeX sources |
| `fronts/` | Front matter | Abstract, acknowledgements, declarations, and other preliminary material |
| `chaps/` | Chapters | One numbered `.tex` file per thesis chapter |
| `backs/` | Back matter | Appendices and other material after the main chapters |
| `figs/` | Figures | Rendered PDFs or images, with editable sources under `srcs/` |
| `tabs/` | Tables | Evidence-backed table `.tex` files |
| `bibs/` | Bibliographies | The thesis bibliography |
| `stys/` | Styles | Reusable class, package, and bibliography style |
| `mates/` | Materials | Fingerprinted, read-only evidence snapshots |
| `execs/` | Executions | Build and update entry points; `scpts/` holds utilities |
| `wkdrs/` | Work directories | Builds and ephemeral reports, never durable project state |
| `mds/` | Markdowns | Markdown documentation grouped by topic |
| `srcs/` | Static sources | Documentation images and editable visual sources |

Three rules matter more than the directory names. `mates/` is read-only except through `execs/scpts/import.sh` and `story-evid-curator`; `wkdrs/` is regenerable, so durable outcomes belong in `notes/`, `milestones/`, or `tasks/`; and a fresh clone intentionally contains only `notes/.gitkeep` and `notes/refs/.gitkeep`. The workflow that owns a `notes/*.md` artifact creates it on first use—absence means “not initialized,” not “missing from the template.”

## Thesis template

The template separates reusable typesetting from author-owned content and institutional facts:

| Layer | File | Owns |
| --- | --- | --- |
| Thesis entry point | `manus/main.tex` or `manus/main-zh.tex` | Front/chapter/back order, thesis-wide macros, bibliography activation |
| The look | `manus/stys/story.cls` | Book layout, page geometry, title page, headings, localization, hyperlinks, citations |
| The authoring layer | `manus/stys/story.sty` | `\todo`, reference helpers, table columns, and writing macros used by chapters and tables |
| Bibliography style | `manus/stys/story.bst` | How bibliography entries are typeset |
| Degree facts | `degree/profile.tex` | Degree level, thesis language, official title-page fields, confirmed page limit |

Project-specific commands such as `\newcommand{\method}{...}` belong in the entry point, not in `story.cls` or `story.sty`. The separation makes an institutional-format adaptation reviewable; an instance owns its entire `manus/` tree, and `execs/update.sh` never replaces it.

The class accepts normal `book` options plus `draft|final` and `en|english|zh|chinese`. The default is English draft mode. The included English entry point uses `\documentclass[oneside]{stys/story}`; the Chinese starter uses `\documentclass[oneside,zh]{stys/story}` and a `% !TeX program = xelatex` directive.

### English and Simplified Chinese

`manus/main.tex` and `manus/main-zh.tex` share `story.cls`, `story.sty`, and one `degree/profile.tex`. Title-page fields use `\storylocalized{English}{中文}`, so each entry point selects the appropriate form without duplicating institutional metadata.

To try the Chinese starter locally:

```dotenv
STORY_MAIN=manus/main-zh.tex
LATEX_ENGINE=
```

```bash
bash execs/run.sh
bash execs/scpts/lint.sh
```

When `LATEX_ENGINE` is empty, `run.sh` honors the entry point's TeX-program directive and therefore selects XeLaTeX for `main-zh.tex`; an explicit engine may be `pdflatex`, `xelatex`, or `lualatex`. Before making Chinese the canonical thesis language, confirm the institutional rule and set `% dissertation_language: zh` in `degree/profile.tex`. The class localizes the structure; it never translates thesis content or invents degree metadata.

### Degree profile and institutional formats

Set exactly one author-confirmed degree mode in `degree/profile.tex`:

```tex
% degree_level: master
% or: degree_level: doctoral
```

The level is deliberately not an `.env` option: it is a durable institutional fact. Missing stays unknown. Invalid values and title or degree wording that conflicts with the selected level fail lint. STORY applies only the selected level's contribution expectations and only those milestones the institution actually requires.

The bundled class is intentionally generic. Official university templates, title-page wording, margins, front-matter order, page limits, deadlines, submission portals, embargo choices, and approval rules must come from official material confirmed by the author. Record the canonical profile in `degree/profile.tex`, the sourced checklist in `degree/requirements.md`, and milestone-specific rules in `milestones/<slug>/milestone.yml`. Keep a supplied institutional template under the applicable milestone; do not silently rewrite STORY's generic source tree from memory.

## Quick start

### 1. Create the thesis repository

Use this repository as a GitHub template, or clone it and detach the copy—one degree thesis, one repository:

```bash
git clone https://github.com/wanghao9610/STORY
cd STORY
rm -rf .git
rm -rf .github        # Upstream maintainer CI; it checks STORY's generated harness mirrors.
cd ..
mv STORY YOUR_THESIS_NAME
cd YOUR_THESIS_NAME
git init
git add .
git commit -m "First commit."
```

If you use GitHub's **Use this template** action, the new repository already has its own Git history; remove `.github/` unless you intend to maintain a fork of STORY itself. The upstream workflow checks STORY's seven generated skill trees and bilingual documentation, not the contents of an individual thesis.

### 1b. Or adopt a thesis repository that already exists

If a draft is already underway—an Overleaf export, a working LaTeX tree, years of chapters, or results already in the text—install the STORY skeleton into that repository instead of moving it into a fresh clone. Run at the existing repository root:

```bash
curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o /tmp/story-update.sh
bash /tmp/story-update.sh --adopt
```

Adoption never overwrites an existing path: it copies only absent files and reports what it keeps. Add `--harnesses claude`—or a comma-separated set of `claude`, `codex`, `cursor`, `dsh`, `kimi`, `pi`, and `qwen`—to install only the agent trees you use. Then invoke `story-proj-adopt`; it inventories the draft, asks before the file map changes, confirms the degree profile and requirements, preserves the original source, records existing unsourced statements as audit work, and verifies the resulting build.

### 2. Configure the local runtime and degree profile

Copy the local configuration:

```bash
cp .env.example .env
```

```dotenv
# Optional default evidence repository; --source imports additional repositories.
RESEARCH_HOME=

# Default thesis entry point, relative to the repository root.
STORY_MAIN=manus/main.tex

# pdflatex | xelatex | lualatex; empty honors the entry point, then uses pdflatex.
LATEX_ENGINE=

# Upstream template and harness trees maintained by execs/update.sh.
STORY_REPOSITORY=https://github.com/wanghao9610/STORY.git
STORY_HARNESSES=all

# Workflow interaction and Markdown/reply language.
INVOLVE=medium
STORY_LANG=
```

`.env` is ignored by Git. `STORY_MAIN` selects the default entry point for both build and lint, while `--main` overrides it for one command. `INVOLVE=low|medium|high` controls how often skills ask before ordinary judgment calls; it never bypasses confirmation of institutional facts, attribution, deletion, overwriting, or a final freeze. It is the project default, and an `involve=<level>` token in a single invocation overrides it for that run only. `STORY_LANG=en|zh` controls replies and newly written Markdown; empty follows the conversation and never translates an existing file. The manuscript language and degree level remain in `degree/profile.tex`.

Next, fill `degree/profile.tex`, `degree/requirements.md`, and `degree/committee.md` only from official material or records the author has confirmed. Unknown values stay empty; do not infer a degree level from the thesis title or degree name.

### 3. Path A: import existing research

Import each source under a stable slug:

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --source ../earlier-story --slug prior-thesis
```

`import.sh` recognizes STAR, STAGE, STORY, and structured generic repositories; it selects writing-relevant artifacts, copies them under `mates/<slug>/`, and records source type, absolute source path, source commit, SHA-256 fingerprint, import date, and coverage in `mates/MANIFEST.md`. If `--source` is omitted, it uses `RESEARCH_HOME`. Re-run after upstream work changes, or check without writing:

```bash
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

The diff exits `1` when an upstream artifact is new or stale. Imported evidence flows one way: correct it upstream and re-import it.

### 4. Path B: register standalone evidence

If the thesis has no STAR or STAGE source repository, keep supplied results, reports, tables, or other research artifacts at their source path and invoke `story-evid-curator register path=<file>`. The curator records their origin, owner, date, and coverage before copying them into `mates/manual/` and fingerprinting them in `mates/MANIFEST.md`. A file without a manifest entry is not evidence. A corrected artifact becomes a new registered record; it is never silently edited in place.

Both paths can be mixed. Multiple research projects, published papers, collaboration records, and manual evidence drops may feed the same thesis as long as each source is namespaced and its authorship boundary remains explicit.

### 5. Build and lint

```bash
bash execs/run.sh
bash execs/scpts/lint.sh
bash execs/scpts/fmt.sh --check
```

`run.sh` invokes `latexmk`, builds out of tree under `wkdrs/builds/`, and prints the PDF path and page count when `pdfinfo` is available. `lint.sh` builds by default, then fails on undefined citations or references, visible `\todo` markers, invalid or conflicting degree metadata, and a confirmed page-limit overrun; placeholders, overfull boxes, formatting drift, and an unknown degree level are reported explicitly. Use `--no-build` only when a current PDF and log already exist.

`fmt.sh` uses the repository's `latexindent` configuration to preserve one sentence per line without changing typeset text. It excludes reusable styles and official institutional templates. Run it without `--check` to apply formatting.

### 6. Start the thesis workflow

The repository structure and scripts work without an AI harness. When using the workflow skills, start from the state that describes the thesis:

| Current state | Start with |
| --- | --- |
| Existing draft or Overleaf export | `story-proj-adopt` |
| Fresh repository with source research ready | `story-evid-curator` |
| Evidence registered, thesis argument still unclear | `story-syns-coach` |
| Argument and contributions confirmed, chapters not planned | `story-outl-planner` |
| Unsure what is initialized or blocked | `story-flow-status` |

The exact command prefix depends on the harness: `$story-*` in Codex, `/story-*` in Claude Code, Cursor, Pi, and Qwen Code, and `/skill:story-*` in DSH and Kimi Code. The generic `$story` or `/story` router accepts a plain-language request and selects one workflow; six thesis-wide or milestone workflows require explicit invocation.

## Writing workflow

The sixteen skills form a pipeline, not a rigid sequence. Use the smallest skill that owns the artifact in question. Every skill first loads the shared workflow conventions.

| Skill | Use it when | Primary output |
| --- | --- | --- |
| `story-proj-adopt` † | An existing thesis or Overleaf export must enter STORY safely | `notes/adopt.md`, mapped sources, unsourced-claim backlog |
| `story-evid-curator` | Evidence must be imported, registered, refreshed, or integrity-checked | `mates/`, `mates/MANIFEST.md` |
| `story-syns-coach` † | The thesis problem, central argument, questions, research arc, or contributions need confirmation | `notes/story.md`, `contributions.md`, `publications.md`, `claims.md` |
| `story-outl-planner` † | The confirmed thesis story must become a chapter architecture | `notes/outline.md`, `notation.md`, chapter scaffolds |
| `story-chap-drafter` | One chapter needs evidence-bound drafting or revision | One `manus/chaps/*.tex` file and synchronized ledgers |
| `story-tabs-builder` | One result, comparison, mapping, or synthesis table is needed | One `manus/tabs/*.tex` file with row-level source anchors |
| `story-figs-designer` | One conceptual, method, result, or synthesis figure is needed | Rendered figure plus editable source under `manus/figs/` |
| `story-refs-curator` | A source must be added, verified, read, deduplicated, or positioned | Bibliography entries and `notes/refs/` reading notes |
| `story-copy-editor` | Voice, terminology, transitions, repetition, or notation need polishing | Manuscript edits, report, or `notes/style.md` |
| `story-clms-auditor` | Numbers, comparisons, and degree-contribution claims need traceability checks | Claim verdicts, regenerable report, durable tasks |
| `story-cite-auditor` | Citation keys, literature assertions, and bibliography hygiene need checking | Citation report and durable tasks |
| `story-exam-reviewer` | A degree-appropriate mock examiner or committee review is needed | `milestones/<slug>/feedback/SIM_EXAM_<date>.md` |
| `story-revs-resolver` † | Supervisor, committee, examiner, defense, correction, or deposit feedback arrived | Point ledger, responses, tracked promises |
| `story-defn-builder` † | An applicable pre-defense or defense narrative and deck are needed | Defense plan and editable deck artifacts under the milestone |
| `story-depo-packer` † | A named deposit milestone is ready for preflight and freeze | Deposit bundle, checksums, record, optional local freeze tag |
| `story-flow-status` | The next action is unclear | Read-only status report and exactly one next action |

The six skills marked † control thesis-wide argument, chapter boundaries, institutional milestones, or finalization. The generic router never starts one without returning the exact explicit command and waiting for confirmation. This is the workflow boundary that keeps an agent from silently changing the thesis's central claim, structure, response position, defense, or deposit state.

## The path from research to deposit

The common path is:

1. **Establish the instance** — clone STORY or run `update.sh --adopt`; confirm `degree/profile.tex` from official records.
2. **Curate evidence** — import each STAR, STAGE, STORY, or generic repository and register manual artifacts; every evidence file receives a fingerprint.
3. **Shape the thesis** — `story-syns-coach` turns the research history into one degree-level problem, central argument, research arc, questions, contributions, publication/reuse map, and proposed claims.
4. **Plan the chapters** — `story-outl-planner` maps every chapter to its purpose, questions, contributions, claims, evidence, visuals, dependencies, and exit condition.
5. **Build the literature base** — `story-refs-curator` verifies bibliographic identity, reads claim-bearing sources, and creates checkable notes under `notes/refs/`.
6. **Draft one chapter at a time** — `story-chap-drafter` writes from the confirmed brief and evidence; `story-tabs-builder` and `story-figs-designer` create traceable visuals. Claim, notation, and outline records change in the same edit.
7. **Polish without moving the facts** — `story-copy-editor` harmonizes terminology, voice, transitions, and cross-chapter synthesis while preserving numbers, citations, attribution, and claim scope.
8. **Audit** — `story-clms-auditor` traces numbers and contribution claims; `story-cite-auditor` checks citation keys and literature assertions. Failures become durable tasks rather than disappearing in a report.
9. **Examine and revise** — `story-exam-reviewer` simulates the applicable degree-level examination; received feedback remains immutable under `feedback/`; `story-revs-resolver` records a disposition and completion evidence for every point.
10. **Prepare the defense** — when the confirmed program requires it, `story-defn-builder` creates the narrative and editable deck from verified claims and confirmed timing and format rules.
11. **Pack and freeze the deposit** — `story-depo-packer` requires a passing build and lint, resolved institutional checks and promises, cleared reuse, and recorded approvals before producing the local bundle and freeze record. It never uploads or submits on the author's behalf.

`story-flow-status` can be run at any point. It reads the degree profile, evidence health, narrative and contribution readiness, chapter/claim/reference coverage, publication attribution, milestones, promises, and latest build, then recommends exactly one next action.

## Evidence, attribution, and the claim ledger

Three ledgers keep the thesis defensible:

**A. Evidence flows one way.** A file becomes evidence only when `mates/MANIFEST.md` records a matching fingerprint and provenance:

```markdown
## project-a/wkdrs/results/results.md
- source-type: star
- source: /path/to/project-a/wkdrs/results/results.md
- source-commit: 3f2a91c
- sha256: 8a31...
- imported: 2026-08-23
- covers: imported graduate-research evidence
```

Every quantitative or comparative sentence in `manus/` then has either a nearby source anchor or a claim-ledger evidence link:

```tex
% src: mates/project-a/wkdrs/results/results.md#main-comparison
The proposed method improves the confirmed metric by ... .
```

If support is missing, write `\todo{...}`. Remembered, interpolated, or plausible-looking values are not a third option.

**B. The claim ledger is the hub.** `notes/claims.md` uses `ID | Claim | Contribution | Stated in | Evidence | Status | Notes`. Claim IDs are stable (`C001`, `C002`, …); their lifecycle is `proposed` → `drafted` → `verified`, with `unsourced`, `weakened`, and `retired` preserving failures and decisions instead of erasing history. The synthesis proposes claims, chapters state them, audits verify them, and reviews attack the same rows.

**C. Attribution is separate from evidence.** `notes/contributions.md` maps degree contributions (`D001`, `D002`, …) to research questions, claims, evidence, publications, chapters, and attribution. `notes/publications.md` separately records complete authorship, the candidate's contribution, reused material, overlap, and permission or policy status. A publication is not automatically a degree contribution, and fingerprinted evidence never licenses STORY to imply sole authorship of collaborative work.

Assertions about cited work follow the same boundary: metadata verification proves which paper it is; content verification means the source itself was read and `notes/refs/` supports the assertion. Public availability never implies reuse permission.

## Degree milestones

Each applicable proposal, review, annual review, pre-defense, external examination, defense, correction round, deposit, or institution-specific event gets one `milestones/<slug>/` directory. STORY never creates a milestone merely because another institution or degree level uses it.

```text
milestones/<slug>/
├── milestone.yml          # Confirmed kind, status, due date, source, and limits
├── feedback/              # Received comments, preserved unchanged
├── response/              # Point ledgers, dispositions, and completion evidence
├── materials/             # Applicable proposal, examination, or defense artifacts
└── RECORD_<date>.md        # Frozen outcome; required before status: completed
```

`milestone.yml` accepts `proposal`, `review`, `annual-review`, `pre-defense`, `external-examination`, `defense`, `correction`, `deposit`, or `other`, with status `planned`, `active`, `blocked`, `completed`, or `cancelled`. Dates, page limits, official names, and requirements sources remain empty until confirmed.

Received feedback is never edited in place. A response records each point as `accepted`, `completed`, `planned`, `disagreed`, or `needs-author`, and promised changes also become checkboxes under `tasks/`. A deposit remains blocked by any failed lint, visible todo, unchecked institutional requirement, open promise, missing reuse permission, or absent required approval.

## Agent harnesses

The harness trees share one source of truth. Neutral skills live under `.agents/skills/`; the shared request roster lives under `.agents/commands/story.md`; each harness owns only the frontmatter, prompts, hooks, settings, and command adapters its runtime requires.

| Harness | Skill entry | Project setup |
| --- | --- | --- |
| Codex | `$story-*`; generic `$story` plugin | Approve `.codex/hooks.json` with `/hooks`; install the plugin below |
| Claude Code | `/story-*`; generic `/story` | `.claude/settings.json` loads automatically |
| Cursor | `/story-*`; generic `/story` | `.cursor/hooks.json` and rules load automatically |
| DeepSeek Harness | `/skill:story-*`; generic `/story` | Install `.dsh/commands/story`; run `bash .dsh/hooks/install.sh` once per machine |
| Kimi Code | `/skill:story-*`; generic `/story` | Install `.kimi-code/plugins/story`; run `bash .kimi-code/hooks/install.sh` once per machine |
| Pi | `/story-*` prompts | Trust the project so `.pi/extensions/` can load |
| Qwen Code | `/story-*`; generic `/story` | `.qwen/settings.json` loads automatically |

Install the repository-local Codex router once from the repository root, then start a new session:

```bash
codex plugin marketplace add .
codex plugin add story@story
```

For Kimi Code, run in its prompt from the repository root; `/new` may replace `/reload`:

```text
/plugins install ./.kimi-code/plugins/story
/reload
```

For DSH, install the command bundle into each profile and restart that profile:

```bash
dsh plugin --profile YOUR_PROFILE add ./.dsh/commands/story
dsh --profile YOUR_PROFILE --dump-config
```

Use `$story` or `/story` with no request for thesis status, or pass a plain-language request such as `audit the claims in chapter 3`. All wrappers route from the same roster. Maintainers of STORY itself edit neutral content under `.agents/skills/` and `.agents/commands/`, then run `bash .github/scripts/port.sh --write`; thesis instances normally receive those files through `execs/update.sh` instead.

## Project memory

What a session learns that no repository file owns—a machine-specific TeX limitation, a standing author preference, a reusable project judgment, or a framing already tried and rejected—may live under `.story/memory/`. One fact lives in one file and one index line appears in `.story/memory/MEMORY.md`; session hooks put the index in front of each supported harness.

Four types keep the store legible: `env`, `pref`, `insight`, and `deadend`. Machine-only facts live under `.story/memory/local/`, which Git ignores; an `env` fact older than 180 days is marked stale. A memory is never evidence and cannot override a file that already owns the fact: values belong to `mates/`, claims to `notes/claims.md`, institutional requirements to `degree/`, publication reuse to `notes/publications.md`, feedback to `milestones/`, and promises to `tasks/`.

The agent offers before recording memory; `INVOLVE=low` changes that to record-and-tell. The file format, index syntax, retirement rules, and provenance contract are in [Project Memory](docs/mds/story-workflow/memory_spec.md).

## Updating STORY skills and workflow docs

An instance can sync later STORY workflow releases without changing its manuscript, evidence, degree records, notes, milestones, tasks, memory store, Git branch, or remotes:

```bash
bash execs/update.sh
```

The updater manages shared agent instructions, neutral skills and router, selected harness entry trees and hooks, Codex manifests, router packages, workflow documentation, and every script under `execs/`. Harness registration files are installed when absent and otherwise kept unless `--force` is supplied. Instance-owned thesis state stays outside the update set.

The general forms are:

```text
bash execs/update.sh [--diff] [ref] [--harnesses LIST] [--skill NAME] [--force]
bash execs/update.sh [ref] [--harnesses LIST] --adopt
```

Common examples:

```bash
bash execs/update.sh --diff
bash execs/update.sh TAG_OR_BRANCH
bash execs/update.sh --harnesses claude,pi
bash execs/update.sh --skill story-chap-drafter
bash execs/update.sh --skill story-flow-status
```

- `--diff` previews without writing and exits `2` when an update is available, `0` when everything matches, and `1` on error.
- A `ref` pins the update to a branch or tag.
- `--harnesses` selects any comma-separated set of `claude`, `codex`, `cursor`, `dsh`, `kimi`, `pi`, and `qwen`; `all` is the default and `none` updates shared paths only.
- `--skill` updates only one skill across the neutral source, selected harness trees, Codex manifest, and Pi prompt.
- `--force` permits managed local changes and kept harness configurations to be overwritten without widening the path set.
- `--adopt` copies absent skeleton files into an existing Git repository and never overwrites an existing path; it cannot be combined with `--force`.

The source is `STORY_REPOSITORY`, resolved from the environment, then `.env`, then the official GitHub repository. Matching managed files are overwritten, new upstream files are added, upstream removals are not deleted locally, and project-specific files are preserved. Commit current work before updating, preview when unsure, and review the result with `git status` and `git diff`. `bash execs/update.sh --help` is the authoritative flag reference.

## Project conventions

1. Record the canonical degree level and manuscript language in `degree/profile.tex`, not `.env`; unknown institutional facts remain empty.
2. Keep thesis prose in the language selected by the degree profile. Keep structural paths, keys, IDs, and statuses in English.
3. Treat `notes/story.md` as the thesis-level argument, `notes/outline.md` as chapter ownership, and `notes/claims.md` as the claim ledger. Update them in the same change as the manuscript facts they govern.
4. Put every quantitative or comparative manuscript statement behind a nearby `% src:` anchor or claim-ledger evidence link. Use `\todo{...}` when evidence is missing.
5. Never edit imported evidence in place. Correct it at the source and re-import it, or register a corrected manual artifact as a new record.
6. Record publication authorship, candidate contribution, reuse, overlap, permission, and policy separately from evidence traceability.
7. Keep received feedback unchanged. Put interpretations, dispositions, promises, and completion evidence beside it, not inside it.
8. Build only with `bash execs/run.sh`; keep generated outputs under `wkdrs/`; run lint whenever citations, claims, metadata, page limits, milestones, or finalization state may have changed.
9. Use one sentence per line in manuscript sources so a diff shows the sentence that changed rather than the paragraph around it.
10. Make the smallest workflow own each change. A chapter drafting request does not silently alter evidence, degree requirements, thesis-wide argument, or received feedback.

The complete collaboration rules are in [`AGENTS.md`](AGENTS.md); the authoritative workflow rules are in the [Writing Workflow Conventions](docs/mds/story-workflow/writing-workflow-conventions.md).

## Adapting STORY to a thesis

When starting a real thesis instance:

- Replace the placeholders in `degree/profile.tex` only with official, author-confirmed values and complete the sourced checklists under `degree/`.
- Choose one canonical entry point and make `STORY_MAIN`, `% dissertation_language`, and the thesis sources agree.
- Import each research or paper repository under a stable slug; register manual artifacts rather than dropping untracked evidence into the manuscript.
- Run `story-syns-coach` before committing to chapter boundaries. A publication-based structure, synthesis chapter, defense, or milestone applies only when the confirmed degree and institution require it.
- Keep reusable class/package files separate from project-specific macros and any official institutional template.
- Set `STORY_HARNESSES` to the tools the project actually uses so later updates do not reinstall unwanted harness trees.
- Replace the generic README and documentation landing page with the thesis's identity if the instance will be public, while keeping `docs/mds/story-workflow/` available for the workflow.
- Remove upstream maintainer CI from the instance unless it intentionally remains a STORY fork.

The skeleton is meant to carry the thesis's provenance and decisions, not dictate its scholarly argument or institutional format.

## Requirements

- Git and Bash 3.2+
- A reasonably complete TeX Live or MacTeX installation with `latexmk`
- `latexindent` for manuscript formatting
- CTeX plus XeLaTeX or LuaLaTeX for the Simplified Chinese template
- `pdfinfo` for reported page counts
- `texcount` for optional word counts
- `curl` for adoption and upstream updates
- `shasum` or `sha256sum` for evidence fingerprints

Individual agent harnesses may add their own runtime requirements; DSH's local router installation, for example, requires `pnpm` on `PATH`.

## License

See [LICENSE](LICENSE).
