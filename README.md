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

STORY has two layers: this repository is the **template**; one degree thesis = one **instance**, created by cloning the template or installing its skeleton into an existing thesis repository with `execs/update.sh --adopt`. An instance may import any number of [STAR](https://github.com/wanghao9610/STAR) research repositories, [STAGE](https://github.com/wanghao9610/STAGE) paper repositories, other STORY theses, and manually registered sources. The pairing is optional—STORY also works as a standalone thesis repository.

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
  - [Hooks and permissions](#hooks-and-permissions)
- [Project memory](#project-memory)
- [Updating STORY skills and workflow docs](#updating-story-skills-and-workflow-docs)
- [Project conventions](#project-conventions)
- [Adapting STORY to a thesis](#adapting-story-to-a-thesis)
- [Requirements](#requirements)
- [Change log](#change-log)
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
- **Institutional facts kept separate from guesses**: official requirements, title-page wording, committee records, templates, limits, approvals, and deadlines enter only from author-confirmed sources under `degree/` and `miles/`.
- **The full thesis lifecycle through sixteen skills**: adoption, evidence curation, synthesis, outlining, chapter drafting, figures, tables, references, copy editing, audits, mock examination, feedback resolution, defense, deposit, and status reporting.
- **Deterministic build and checks**: `execs/run.sh` builds out of tree; `lint.sh` checks references, todos, degree-profile consistency, page limits, and formatting; `fmt.sh` keeps English prose at one sentence per line; `import.sh --diff` detects evidence drift.
- **One workflow across seven agent harnesses**: Codex, Claude Code, Cursor, DeepSeek Harness, Kimi Code, Pi, and Qwen Code share the same neutral skills and request router.
- **Project-owned memory** under `.story/memory/` for durable session knowledge that no evidence, degree, note, milestone, or task file already owns.
- **Replies and notes in English or Simplified Chinese**: `STORY_LANG` sets the language a run replies and writes in, and this README and the skills guide also ship in Simplified Chinese, while paths, IDs, states, commands, and machine-readable fields remain stable in English.

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
│   ├── bibs/                      # reference.bib (created on first use)
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
├── miles/                         # Proposal, reviews, examination, defense, deposit
│   └── <slug>/                    # milestone.yml, feedback/, simulations/, response/, materials/, template/, RECORD_*.md
├── tasks/                         # Durable unresolved work and feedback promises
├── wkdrs/                         # Builds and regenerable reports; gitignored
├── execs/
│   ├── run.sh                     # Thesis build entry point
│   ├── update.sh                  # Sync upstream workflow files; --adopt installs the skeleton
│   └── scpts/                     # import.sh, lint.sh, fmt.sh
├── docs/                          # Documentation site and workflow guides
├── .story/memory/                 # Project memory; local/ is git-ignored
├── .agents/                       # Neutral skills, shared /story router, /story-auto procedure
├── .codex/                        # Codex hooks, manifests, and $story / $story-auto plugin
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
| `miles/` | Milestones | One directory per proposal, review, defense, correction round, or deposit attempt |
| `execs/` | Executions | Build and update entry points; `scpts/` holds utilities |
| `wkdrs/` | Work directories | Builds and ephemeral reports, never durable project state |
| `mds/` | Markdowns | Markdown documentation grouped by topic |
| `srcs/` | Static sources | Documentation images and editable visual sources |

Three rules matter more than the directory names. `mates/` is read-only except through `execs/scpts/import.sh` and `story-evid-curator`; `wkdrs/` is regenerable, so durable outcomes belong in `notes/`, `miles/`, or `tasks/`; and a fresh clone intentionally contains only `notes/.gitkeep` and `notes/refs/.gitkeep`. The workflow that owns a `notes/*.md` artifact creates it on first use—absence means “not initialized,” not “missing from the template.”

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

The class accepts normal `book` options plus `draft|final`, `en|english|zh|chinese`, and `cjk`. The default is English draft mode. The included English entry point uses `\documentclass[oneside]{stys/story}`; the Chinese starter uses `\documentclass[oneside,zh]{stys/story}` and a `% !TeX program = xelatex` directive. `cjk` lets an English thesis typeset Chinese text: under XeLaTeX or LuaLaTeX it loads ctex with `scheme=plain`, which leaves the English headings and layout as they are; under pdfLaTeX the class stops with an error asking for `% !TeX program = xelatex`; with `zh` it has no effect.

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

When `degree/requirements.md` requires abstracts in both languages, each abstract names its language: `\begin{storyabstract}[en]` and `\storykeywords[en]{...}` in `fronts/abstract.tex`, `[zh]` in `fronts/abstract-zh.tex`. The argument defaults to the class language and sets the heading, the table-of-contents entry, and the keyword label: `Abstract` and `Keywords:` for `en`, `摘要` and `关键词：` for `zh`. `main-zh.tex` carries a commented `% \input{fronts/abstract}` for an English abstract, which needs nothing more. `main.tex` carries a commented `% \input{fronts/abstract-zh}`; a Chinese abstract there also needs the `cjk` class option and XeLaTeX, so load the class as `\documentclass[oneside,cjk]{stys/story}` and change the first two lines to `% !TeX program = xelatex` and `% !LW recipe = XeLaTeX`. Built under XeLaTeX without `cjk`, Chinese text comes out blank while the build still succeeds, so lint warns when the build log reports missing characters.

### Degree profile and institutional formats

Set exactly one author-confirmed degree mode in `degree/profile.tex`:

```tex
% degree_level: master
% or: degree_level: doctoral
```

The level is deliberately not an `.env` option: it is a durable institutional fact. Missing stays unknown. An invalid value, and wording in the `\degree` field that conflicts with the selected level, fail lint; the title is not checked, so an approved title may use a subject word such as “Doctor” or “Master”. `% dissertation_language` takes `en` or `zh`: lint warns while it is empty and fails on any other value. STORY applies only the selected level's contribution expectations and only those milestones the institution actually requires.

The bundled class is intentionally generic. Official university templates, title-page wording, margins, front-matter order, page limits, deadlines, submission portals, embargo choices, and approval rules must come from official material confirmed by the author. Record the canonical profile in `degree/profile.tex`, the sourced checklist in `degree/requirements.md`, and milestone-specific rules in `miles/<slug>/milestone.yml`. The title page's submission statement, printed above the degree name, is one of those profile fields: set `\submissionstatement{...}` to the official template's exact wording, or to `\submissionstatement{}` when the template prints none, which drops the line. Until then the title page prints the placeholder `Submission Statement` (`提交说明` in Chinese), which lint reports with the other title-page placeholders; lint also warns when a profile has no `\submissionstatement` line at all. Keep an official template you were given, unchanged, under `miles/<slug>/template/`, which `fmt.sh` never reformats; a class the thesis actually builds with belongs in `manus/stys/`. Do not silently rewrite STORY's generic source tree from memory.

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

If you use GitHub's **Use this template** action, the new repository already has its own Git history; remove `.github/` unless you intend to maintain a fork of STORY itself. The upstream workflow checks STORY's seven generated skill trees and documentation, not the contents of an individual thesis.

### 1b. Or adopt a thesis repository that already exists

If a draft is already underway—an Overleaf export, a working LaTeX tree, years of chapters, or results already in the text—install the STORY skeleton into that repository instead of moving it into a fresh clone. Run at the existing repository root:

```bash
curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o /tmp/story-update.sh
bash /tmp/story-update.sh --adopt
```

Adoption never overwrites an existing path: it copies only absent files and reports what it keeps. Add `--harnesses claude`—or a comma-separated set of `claude`, `codex`, `cursor`, `dsh`, `kimi`, `pi`, and `qwen`—to install only the agent trees you use. Then invoke `story-proj-adopt`; it inventories the draft, asks you to confirm the degree level before mapping level-specific material, has you commit first and records that commit, asks before the file map or entry point changes, copies the original sources rather than moving them, records existing unsourced statements as audit work, and verifies the resulting build. It does not fill `degree/requirements.md` or the rest of the profile: you do. A draft built on an institutional class keeps that class in `manus/stys/`; lint checks the `zh` class option against `% dissertation_language` only when the entry point loads STORY's class, and for any other class it logs that the language option is not checked, without a warning.

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

`.env` is ignored by Git. `STORY_MAIN` selects the default entry point for both build and lint, while `--main` overrides it for one command. `INVOLVE=low|medium|high` sets how much unresolved judgment a skill asks about under the authority you already gave: `low` takes the recommended safe option and says so, `medium` asks as each skill documents, and `high` asks each consequential choice on its own. Approval you already gave stays valid for its scope and is not asked for again, and a status, audit, or mock-review request ends with its own report and never starts a writing skill after it. No level skips a confirmation point — recording an institutional, requirement, or milestone fact as confirmed, deleting a file or ledger row, replacing a file wholesale, or freezing or tagging a deposit ([conventions §7](docs/mds/story-workflow/writing-workflow-conventions.md#7-interaction-language-and-provenance)) — or an ask-first choice of `AGENTS.md` §1: the thesis-wide argument, chapter boundaries, attribution, publication reuse, or a degree requirement. It is the project default, and an `involve=<level>` token in a single invocation overrides it for that run. In Claude Code the token also reaches the permission hooks, which read it off the most recent STORY command you typed and keep it after the run ends, until you type the next one; elsewhere the prompts follow `.env` alone. At `low`, the permission hooks also skip the harness's prompt before an edit inside the project and, in Claude Code, before a shell command outside the red lines; writes into `mates/`, `degree/`, and `miles/*/feedback/` keep the prompt at every level ([Hooks and permissions](#hooks-and-permissions)). `STORY_LANG=en|zh` controls replies and newly written Markdown unless you ask for a language in the conversation; empty follows the language of your own messages (a run with none asks once), and an existing file is never translated. Text for examiners, the committee, or the institution uses the language the milestone or `degree/requirements.md` records, else the manuscript language, and the run asks before finalizing it. The manuscript language and degree level remain in `degree/profile.tex`.

Next, fill `degree/profile.tex`, `degree/requirements.md`, and `degree/committee.md` only from official material or records the author has confirmed. Unknown values stay empty; do not infer a degree level from the thesis title or degree name.

### 3. Path A: import existing research

Import each source under a stable slug:

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --source ../earlier-story --slug prior-thesis
```

`import.sh` recognizes STAR, STAGE, STORY, and structured generic repositories; it selects writing-relevant artifacts, copies them under `mates/<slug>/`, and records source type, absolute source path, source commit, SHA-256 fingerprint, import date, and coverage in `mates/MANIFEST.md`; a re-import rewrites each entry but keeps a `covers:` line you curated. If `--source` is omitted, it uses `RESEARCH_HOME`. Re-run after upstream work changes, or check without writing:

```bash
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

The diff prints one line per file that differs: `stale` for a snapshotted file whose source changed, `new upstream` for a source file with no snapshot under `mates/<slug>/`, and `removed upstream` for a manifest entry whose source file is gone. It exits `2` when it prints a `stale` or `new upstream` line, `0` otherwise, and `1` when the check itself cannot run. Only a file with a `stale` line is `stale`, and a stale snapshot is not registered evidence until you re-import it. A `removed upstream` line is reported for you to decide on; the snapshot stays, since a re-import never deletes one. Imported evidence flows one way: correct it upstream and re-import it.

### 4. Path B: register standalone evidence

If the thesis has no STAR or STAGE source repository, keep supplied results, reports, tables, or other research artifacts at their source path and invoke `story-evid-curator register path=<file>`; one run can register a batch. The curator records their origin, owner, date, and coverage before copying them into `mates/manual/` and fingerprinting them in `mates/MANIFEST.md`. A file without a manifest entry is not evidence. A corrected artifact becomes a new registered record; it is never silently edited in place.

Both paths can be mixed. Multiple research projects, published papers, collaboration records, and manual evidence drops may feed the same thesis as long as each source is namespaced and its authorship boundary remains explicit.

### 5. Build and lint

```bash
bash execs/run.sh
bash execs/scpts/lint.sh
bash execs/scpts/fmt.sh --check
```

`run.sh` invokes `latexmk`, builds out of tree under `wkdrs/builds/` (an entry point outside `manus/`, such as a defense deck, builds into a git-ignored `.build/` beside it), and prints the PDF path and page count when `pdfinfo` is available. `lint.sh` builds by default, then fails on a failed build, undefined citations or references, visible `\todo` markers, invalid or conflicting degree metadata, and a confirmed page-limit overrun. The limit is the active milestone's `max_pages` (the one non-supervision milestone with `status: active`). When there is none, it is the `max_pages` of the milestone the legacy `active_milestone` in `notes/story.md` names, and otherwise the value in `degree/profile.tex`; lint compares it with the PDF's total page count, which it reads with `pdfinfo` or, without it, from the build log's `Output written on` line, and it warns that the limit was not checked when neither gives a count. It warns about title-page placeholders (a profile with no `\submissionstatement` line included), an unset `% dissertation_language`, an entry point that loads STORY's class with a language option, or without one, that disagrees with it, unresolved rows in `degree/requirements.md`, a chapter file the entry point never inputs, more than one active milestone, a `max_pages` that is not a positive integer, sources newer than the PDF, overfull boxes, missing characters in the build log, formatting drift, an unknown degree level, high-confidence chatbot residue, and clustered formulaic prose. The requirement count covers only unchecked boxes; whether a checked row cites its source is still read by `story-depo-packer`, and [§6 of the conventions (Deposit gates)](docs/mds/story-workflow/writing-workflow-conventions.md#deposit-gates) says which warnings block a deposit. Prose findings are advisory review signals, not proof of AI authorship and not hard failures. Every run ends with a `Result:` line, a failed build included. A red lint result is the expected state of a mid-draft manuscript — the `\todo` markers the evidence contract requires you to write are themselves hard failures until resolved, and they block only deposit, not drafting. `--no-build` reuses the last build: it fails when that build's log is missing or stopped on an error, and warns when a source is newer than the PDF.

`fmt.sh` uses the repository's `latexindent` configuration to preserve one sentence per line without changing typeset text. It keeps a closing `}` or `]` on the line of the sentence it ends, and it refuses any rewrite that would change the typeset text, leaving that file untouched and exiting `2`. A refused file needs a hand fix: usually a closing `}` or `]` alone on its line, which goes at the end of the line above in place of the bare `%` that ends it, if there is one (that `%` only ate the line end, and the closer keeps a `%` after it only if its own line ended in one); a `{%` group around running prose (`\mbox{%` … `}`), which goes on one line without the `%`; or a sentence that follows a closing `}` on its line (`\todo{...} The end.`, `\emph{One thing.} here. The end.`), which goes on a line of its own. A period glued to a footnote, citation, label, index entry, or `\todo` (`good.\footnote{...}`, `et al.\cite{x}`) ends a sentence only after the command, and one before an escaped or thin space (`et al.\ The`, `Fig.\,3`) ends none, so neither is split where the source has no space. An abbreviation read as a sentence end before a capital or a number (`et al. The`, `Fig. 3`) is not refused but split onto two lines, since a line break is a space; a tie keeps the sentence whole. It does not yet split or check Chinese sentences, so keep one sentence per line by hand in Chinese prose; `--check` passes a multi-sentence Chinese line. It excludes reusable styles (`manus/stys/`) and official institutional templates (`miles/*/template/`). Run it without `--check` to apply formatting.

### 6. Start the thesis workflow

The repository structure and scripts work without an AI harness. When using the workflow skills, start from the state that describes the thesis:

| Current state | Start with |
| --- | --- |
| Existing draft or Overleaf export | `story-proj-adopt` |
| Fresh repository with source research ready | `story-evid-curator` |
| Evidence registered, thesis argument still unclear | `story-syns-coach` |
| Argument and contributions confirmed, chapters not planned | `story-outl-planner` |
| Unsure what is initialized or blocked | `story-flow-status` |

The exact command prefix depends on the harness: `$story-*` in Codex, `/story-*` in Claude Code, Cursor, Pi, and Qwen Code, and `/skill:story-*` in DSH and Kimi Code. The generic `$story` or `/story` router accepts a plain-language request and selects one workflow; six thesis-wide or milestone workflows require explicit invocation. `/story-auto <goal>` (`$story-auto` in Codex) pursues a stated goal across several steps, starting the ten unmarked skills itself and stopping at any † skill or author decision.

## Writing workflow

The sixteen skills form a pipeline, not a rigid sequence. Use the smallest skill that owns the artifact in question. Every skill first loads the shared workflow conventions.
After every skill finishes, its report closes with exactly one `Next action:` handoff: the owning skill and concrete target or command for the earliest remaining gate in the pipeline order of [§8 of the conventions (Completion handoff)](docs/mds/story-workflow/writing-workflow-conventions.md#completion-handoff), an author action when only the author can clear it, or `Next action: none — the requested workflow is complete.` The handoff recommends what to do next; it does not silently start another skill.

<div align="center">
  <img src="docs/srcs/story-writing-workflow.png" alt="STORY thesis workflow: fifteen skills in the order they run in plus one that reads across them, what each one writes, and how the drafting loop and the correction loop close" width="100%">
</div>

| Skill | Use it when | Primary output |
| --- | --- | --- |
| `story-proj-adopt` † | An existing thesis or Overleaf export must enter STORY safely | `notes/adopt.md`, copied and mapped sources, unsourced-claim backlog |
| `story-evid-curator` | Evidence must be imported, registered, refreshed, or integrity-checked | `mates/`, `mates/MANIFEST.md` |
| `story-syns-coach` † | The thesis problem, central argument, questions, research arc, or contributions need confirmation | `notes/story.md`, `contributions.md`, `publications.md`, `claims.md` |
| `story-outl-planner` † | The confirmed thesis story must become a chapter architecture | `notes/outline.md` with chapter briefs, `notation.md`, scaffolds for chapters that have no file |
| `story-chap-drafter` | One chapter, or one front- or back-matter file, needs evidence-bound drafting or revision in the author's scholarly voice; `trace` adds missing source anchors without redrafting | One `manus/chaps/`, `manus/fronts/`, or `manus/backs/` file and synchronized ledgers |
| `story-tabs-builder` | One result, comparison, mapping, or synthesis table is needed | One `manus/tabs/*.tex` file with a source anchor on every row that carries a number or comparison |
| `story-figs-designer` | One conceptual, method, result, or synthesis figure is needed | Rendered figure plus editable source under `manus/figs/` |
| `story-refs-curator` | A source must be added, verified, read, deduplicated, or positioned | Bibliography entries and `notes/refs/` reading notes |
| `story-copy-editor` | Authorial voice, formulaic prose, terminology, transitions, repetition, or notation need polishing in one chapter, one front- or back-matter file, or the whole thesis (`full`) | Manuscript edits, report, advisory `tasks/prose.md`, or `notes/style.md` |
| `story-clms-auditor` | Numbers, comparisons, and degree-contribution claims need traceability checks, or a number looks wrong | Claim and contribution statuses, a regenerable report, lines in `tasks/audits.md` |
| `story-cite-auditor` | Citation keys, literature assertions, and bibliography hygiene need checking | Citation report and lines in `tasks/audits.md` |
| `story-exam-reviewer` | A degree-appropriate mock examiner or committee review is needed | `miles/<slug>/simulations/SIM_EXAM_<date>.md`, or `wkdrs/reports/SIM_EXAM_<date>.md` when no milestone is named or active |
| `story-revs-resolver` † | Supervisor, committee, examiner, defense, correction, or deposit feedback, or an official outcome, arrived | Point ledger, responses, promises in `tasks/<slug>_promises.md`, an outcome's RECORD |
| `story-defn-builder` † | An applicable pre-defense or defense narrative and deck are needed | Defense plan and editable deck sources under `miles/<slug>/materials/` |
| `story-depo-packer` † | A named deposit milestone is ready for preflight and freeze | Gate report, deposit bundle, a RECORD with checksums and the source commit, optional local freeze tag |
| `story-flow-status` | The next action is unclear | Read-only status report and exactly one next action |

The slugs abbreviate: `proj` project, `evid` evidence, `syns` synthesis, `outl` outline, `chap` chapter, `tabs` tables, `figs` figures, `refs` references, `clms` claims, `cite` citations, `exam` examination, `revs` reviews, `defn` defense, `depo` deposit, `flow` workflow.

The six skills marked † control thesis-wide argument, chapter boundaries, institutional milestones, or finalization. The generic router never starts one; it returns the exact command for you to type, and a `/story-auto` goal run stops at one and prints its command. This boundary keeps an agent from silently changing the thesis's central claim, structure, response position, defense, or deposit state.

Chapter drafting, copy-editing, mock examination, and lint share the [human-writing contract](docs/mds/story-workflow/writing-workflow-conventions.md#human-writing-contract) in §5 of the workflow conventions. It adapts Humanizer patterns to academic prose while preserving evidence, qualifications, terminology, and author-confirmed voice; it does not classify authorship from isolated words or punctuation.

## The path from research to deposit

The common path is:

1. **Establish the instance** — clone STORY or run `update.sh --adopt`; confirm `degree/profile.tex` from official records.
2. **Curate evidence** — import each STAR, STAGE, STORY, or generic repository and register manual artifacts; every evidence file receives a fingerprint.
3. **Shape the thesis** — `story-syns-coach` turns the research history into one degree-level problem, central argument, research arc, questions, contributions, publication/reuse map, and proposed claims.
4. **Plan the chapters** — once the author finalizes the story, `story-outl-planner` maps every chapter, drafted ones included, to its purpose, questions, contributions, claims, evidence, visuals, dependencies, and exit condition.
5. **Build the literature base** — `story-refs-curator` verifies bibliographic identity, reads claim-bearing sources, and creates checkable notes under `notes/refs/`.
6. **Draft one chapter at a time** — `story-chap-drafter` writes from the confirmed brief and evidence; `story-tabs-builder` and `story-figs-designer` create traceable visuals. Claim, notation, and outline records change in the same edit.
7. **Polish without moving the facts** — `story-copy-editor` removes clustered formulaic prose and harmonizes terminology, authorial voice, transitions, and cross-chapter synthesis while preserving numbers, citations, attribution, uncertainty, and claim scope.
8. **Audit** — `story-clms-auditor` traces numbers and contribution claims; `story-cite-auditor` checks citation keys and literature assertions. Failures become open lines in `tasks/audits.md` rather than disappearing in a report, and each audit records the date of its last full run.
9. **Examine and revise** — `story-exam-reviewer` simulates the applicable degree-level examination; received feedback remains immutable under `feedback/`; `story-revs-resolver` records a disposition and completion evidence for every point, records an official outcome, and asks before opening a correction milestone.
10. **Prepare the defense** — when the confirmed program requires it, `story-defn-builder` creates the narrative and editable deck from verified claims and confirmed timing and format rules.
11. **Pack and freeze the deposit** — `story-depo-packer` checks every gate in [§6 of the conventions (Deposit gates)](docs/mds/story-workflow/writing-workflow-conventions.md#deposit-gates), among them a clean build and lint, every requirement row checked, no open box under `tasks/`, both audits run after the last change, cleared reuse, no starter text, and a clean Git tree, before producing the local bundle and a RECORD that cites it by checksum. It never commits, uploads, or submits on the author's behalf, and it tags the recorded commit only when you confirm.

`story-flow-status` can be run at any point. It reads the degree profile, evidence integrity (`ok`, `tampered`, `missing`, `unregistered`), status counts from each ledger, publication attribution, the active milestone, open boxes under `tasks/`, the visible `\todo` count, whether the build is current, the latest lint `Result:` line, and any legacy translated twins, then recommends exactly one next action.

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

Each applicable proposal, review, annual review, pre-defense, external examination, defense, correction round, deposit, or institution-specific event gets one `miles/<slug>/` directory. STORY never creates a milestone merely because another institution or degree level uses it.

```text
miles/<slug>/
├── milestone.yml          # Confirmed kind, status, due date, source, and limits
├── feedback/              # Received comments, preserved unchanged
├── simulations/           # Generated mock reviews (story-exam-reviewer)
├── response/              # Point ledgers, dispositions, and completion evidence
├── materials/             # Applicable proposal, examination, or defense artifacts
├── template/              # Official template as supplied, never reformatted
└── RECORD_<date>.md        # Frozen outcome; required before status: completed
```

`milestone.yml` accepts `proposal`, `review`, `annual-review`, `pre-defense`, `external-examination`, `defense`, `correction`, `deposit`, `supervision`, or `other`, with status `planned`, `active`, `blocked`, `completed`, or `cancelled`. `supervision` is the standing `miles/supervision/` record for informal supervisor or coauthor feedback: it is never the active milestone, needs no RECORD, and gates only its own promises. Dates, page limits, official names, and requirements sources remain empty until confirmed.

Received feedback is never edited in place. A response records each point as `accepted`, `completed`, `planned`, `disagreed`, or `needs-author`, and promised changes also become checkboxes under `tasks/`. A deposit is ready only when `story-depo-packer` reports every gate of [§6 of the conventions (Deposit gates)](docs/mds/story-workflow/writing-workflow-conventions.md#deposit-gates) as passing.

## Agent harnesses

The harness trees share one source of truth. Neutral skills live under `.agents/skills/`; the shared request roster lives under `.agents/commands/story.md` and the goal-run procedure beside it in `story-auto.md`; each harness owns only the frontmatter, prompts, hooks, settings, and command adapters its runtime requires.

| Harness | Skill entry | Project setup |
| --- | --- | --- |
| Codex | `$story-*`; generic `$story` and `$story-auto` plugin | Approve `.codex/hooks.json` with `/hooks`; install the plugin below |
| Claude Code | `/story-*`; generic `/story` and `/story-auto` | `.claude/settings.json` loads automatically |
| Cursor | `/story-*`; generic `/story` and `/story-auto` | `.cursor/hooks.json` and rules load automatically |
| DeepSeek Harness | `/skill:story-*`; generic `/story` and `/story-auto` | Install `.dsh/commands/story`; run `bash .dsh/hooks/install.sh` once per machine |
| Kimi Code | `/skill:story-*`; generic `/story` and `/story-auto` | Install `.kimi-code/plugins/story`; run `bash .kimi-code/hooks/install.sh` once per machine |
| Pi | `/story-*` prompts; generic `/story` and `/story-auto` | Trust the project so `.pi/extensions/` can load |
| Qwen Code | `/story-*`; generic `/story` and `/story-auto` | `.qwen/settings.json` loads automatically |

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

Use `$story` or `/story` with no request for thesis status, or pass a plain-language request such as `audit the claims in chapter 3`. All wrappers route from the same roster.

Use `/story-auto <goal>` (`$story-auto` in Codex; `/skill:story-auto` is Kimi Code's explicit spelling) when you want the agent to keep going toward a goal, such as `/story-auto chapter 3 drafted and audited involve=low`. It runs `story-flow-status`, then the next action each run names, starting the ten unmarked skills itself until the goal's check passes. It stops and hands back the exact command at any † skill, and the author action at any gate only you can clear. Confirmation points and the ask-first choices of `AGENTS.md` §1 still come to you at every involve level. A goal run never imports or refreshes evidence, writes `degree/` or received feedback, declares a deposit ready, commits, or pushes, and it does not wait for green lint. Its level is the `involve=` token you type, else `INVOLVE` in `.env`. The rule is [§8 of the workflow conventions (Goal runs)](docs/mds/story-workflow/writing-workflow-conventions.md#goal-runs); every harness reads the same procedure, `.agents/commands/story-auto.md`. Codex and Kimi Code copy the plugin when it is installed, so an existing install picks up `/story-auto`, and any later change to the plugin, only once you install it again. In Codex, run `codex plugin remove story@story`, then `codex plugin add story@story`, and start a new session; in Kimi Code, repeat the plugin install above.

Claude Code runs `story-flow-status` at `effort: medium`: its generated `.claude/skills/story-flow-status/SKILL.md` carries that field, because a read-only status scan needs less reasoning depth than drafting. No other skill, and no other harness, carries a model or effort setting; which model runs a skill, and how deeply it reasons, is your harness's choice.

Maintainers of STORY itself edit neutral content under `.agents/skills/` and `.agents/commands/`, then run `bash .github/scripts/port.sh --write`; thesis instances normally receive those files through `execs/update.sh` instead.

### Hooks and permissions

Two hooks run at the start of a session in every harness: one states the model id to copy into a memory file's `model_id` (the recovery order is §7 of the workflow conventions; each harness's resolver command, fallback read, hook events, and registration are in [§11, harness adapters](docs/mds/story-workflow/writing-workflow-conventions.md#11-harness-adapters)), the other puts the [project memory](#project-memory) index in front of the agent. All seven harnesses also carry `story_commit_guard.sh`, at every involve level: it declines blanket or forced staging, history rewrites, forced branch operations, blanket discards of uncommitted work, forced pushes (a `+refspec` included), deleting a remote branch or tag (`push -d`, `--delete`, `--prune`, or a `:dst` refspec), moving or deleting a tag (`update-ref` on `refs/tags/` or with `--stdin` included), and a commit whose staged files exceed 10 MB. Claude Code, Codex, DSH, Kimi Code and Qwen Code run it before a shell command on `PreToolUse`, Cursor on `beforeShellExecution`, and Pi on its `tool_call` event, where it is the only check between a git command and the repository, since Pi has no permission prompts.

At `INVOLVE=low` the gate hooks answer permission prompts. They never answer a confirmation point: the questions a skill must ask still reach you. In Claude Code, Codex and Qwen Code, `story_involve_gate.sh` allows an edit inside the project. Paths under a dot-directory at the project root, and paths that climb out through `..`, keep their prompt. Claude Code also registers `story_bash_gate.sh`, which allows a shell command at `low` unless it crosses a red line: deletion, `sudo`, disk and device writes, system or TeX package installs (`tlmgr` included), process control, service control, kernel modules, scheduled jobs (`crontab`), a `find` that deletes or executes, `git push`, `git clean`, `git stash drop`/`clear`, a whole-tree `git restore`/`checkout`, a forced `mv`/`cp`, or an outward transfer (`gh`, `scp`/`sftp`/`ftp`, `rclone`, `rsync` to a host, or a `curl`/`wget` upload; a plain download stays allowed). Both gates keep the prompt for a write into the thesis's protected records at every level: the evidence store `mates/`, the confirmed institutional facts in `degree/`, and received feedback in `miles/*/feedback/`. The bash gate lets `bash execs/scpts/import.sh` write into `mates/`, which is its job, and lets read-only commands such as `cat`, `grep` and `sed -n` read there. `story-evid-curator`'s own registration therefore asks you before it copies a file into `mates/manual/`. In Claude Code, both gates take the level from the `involve=` token of the session's most recent STORY command you typed, falling back to `.env` when that command names none. A token the agent writes into a skill it dispatches can raise the level, but never lower it. That level outlasts the run: after `/story-chap-drafter 3 involve=low` finishes, later edits and shell commands in the same session are still answered at `low`, and a plain-language request such as "ask me more" changes what a skill asks but not what the hooks answer. Type a bare STORY command, such as `/story-flow-status`, to return the hooks to `.env`, or one carrying a new `involve=` token to set another level. Codex and Qwen Code follow `.env` alone. Cursor, DSH, Kimi Code and Pi have no edit gate, because their harnesses offer no prompt a hook can answer before an edit.

The gates only read the paths a command names, so they are a floor, not a proof. A script that opens a protected file on its own is not seen, and the conventions still forbid that write.

Claude Code needs nothing else on a fresh install: `.claude/settings.json` ships three allow rules, one for the read-only model-id resolver the provenance hook hands a skill and two for `story-flow-status`'s read-only collector. `execs/update.sh` keeps an existing `settings.json`; it names any STORY hook a kept file does not register and reports a missing resolver rule. Merge the rules into a kept file yourself:

```json
"permissions": {
  "allow": [
    "Bash(bash .claude/hooks/story_model_id.sh --resolve:*)",
    "Bash(bash .claude/skills/story-flow-status/scripts/scan.sh)",
    "Bash(bash .claude/skills/story-flow-status/scripts/scan.sh:*)"
  ]
}
```

A kept file also needs the `story_bash_gate.sh` command beside `story_commit_guard.sh` in the `Bash` entry under `hooks.PreToolUse`; the guard's deny outranks the gate's allow, so the order does not matter. Qwen Code's `.qwen/settings.json` ships its own `scan.sh` rules. Elsewhere, approve the collector once when asked.

## Project memory

What a session learns that no repository file owns—a machine-specific TeX limitation, a standing author preference, a reusable project judgment, or a framing already tried and rejected—may live under `.story/memory/`. Each fact lives in its own file; a session hook builds a one-line-per-fact index from those files' frontmatter and puts it in front of the agent at every session start, in all seven harnesses (`--list` on any copy prints it, for example `bash .claude/hooks/story_memory.sh --list`).

Four types keep the store legible: `env`, `pref`, `insight`, and `deadend`. `.story/memory/local/`, git-ignored like `.env`, holds what is true only of this machine and anything you would rather keep off the repository; every other memory is versioned and travels with a clone. An `env` fact older than 180 days is marked stale. A memory is never evidence and cannot override a file that already owns the fact: values belong to `mates/`, claims to `notes/claims.md`, institutional requirements to `degree/`, publication reuse to `notes/publications.md`, feedback to `miles/`, and promises to `tasks/`.

The agent offers before recording memory; `INVOLVE=low` changes that to record-and-tell. The file format (including the required one-line `summary`), the index line, and retirement rules are in [§10 (project memory)](docs/mds/story-workflow/writing-workflow-conventions.md#10-project-memory) of the workflow conventions; a memory's `model_id` follows the provenance rule in [§7](docs/mds/story-workflow/writing-workflow-conventions.md#7-interaction-language-and-provenance).

## Updating STORY skills and workflow docs

An instance can sync later STORY workflow releases without changing its manuscript, evidence, degree records, notes, milestones, tasks, memory store, Git branch, or remotes:

```bash
bash execs/update.sh
```

The updater manages shared agent instructions, neutral skills, the `/story` router and `/story-auto` procedure, selected harness entry trees and hooks, Codex manifests, router packages, workflow documentation, and every script under `execs/`. Harness registration files are installed when absent and otherwise kept unless `--force` is supplied. When a kept file does not register a STORY hook, the updater names the hook, and it reports a kept `.claude/settings.json` that does not allow the model-id resolver. Merge those entries from upstream by hand. It also reports a kept `.codex/hooks.json` whose `story_memory.sh` entry still shares a `SessionStart` group that has a matcher (`startup|resume` in earlier releases); move that entry into a `SessionStart` group of its own with no matcher, as upstream does, so memory also loads after `/clear`. Instance-owned thesis state stays outside the update set.

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

The source is `STORY_REPOSITORY`, resolved from the environment, then `.env`, then the official GitHub repository. Matching managed files are overwritten and new upstream files are added. An update deletes nothing: a file that exists only locally, your own included, is kept, and `--diff` lists one under a managed path as `extra`. STORY no longer ships its Chinese instruction twins (a `SKILL_zh.md` beside each skill, `AGENTS.zh-CN.md`, `CLAUDE.zh-CN.md`, `.pi/APPEND_SYSTEM.zh-CN.md`, the Chinese `/story` router (`.agents/commands/story.zh-CN.md`), its wrappers, and Pi prompts, and the Chinese workflow specs) or the three standalone workflow specs (the human-writing guide, the memory spec, and the model-id fallbacks), whose rules now live in the workflow conventions (§5, §10, and §7 with §11). An update leaves in place any of these files a thesis still has, and no skill reads them, so delete them by hand. The `notes/**/*.zh-CN.md` twins earlier skills wrote beside your notes are yours: an update keeps them, no skill reads or updates them any more, and `story-flow-status` lists them so you can fold them in or delete them. An updater from before STORY dropped those files stops with `Upstream ref is missing AGENTS.zh-CN.md` before it can replace itself. Replace it once by hand with `execs/update.sh` from the repository you update from (`STORY_REPOSITORY`; for the official one, `curl -fsSL https://raw.githubusercontent.com/wanghao9610/STORY/main/execs/update.sh -o execs/update.sh`), commit the replacement so the updater's uncommitted-changes check passes, and run it again. An older release also seeded `.story/memory/MEMORY.md` and `.story/memory/MEMORY.zh-CN.md`, read `.story/memory/local/MEMORY.md` as the machine-local index, and paired every memory file with a `<slug>.zh-CN.md` twin. The memory store is the thesis's, so the update keeps all of them, but the hooks no longer read the index files and now list each twin as a second memory. Carry each index line into its memory file's `summary`, fold each twin into its English file, then delete the old files; the update reports them until you do. Milestone records now live under `miles/` rather than `milestones/`: the update moves nothing, and reports a leftover `milestones/` until you run `git mv milestones miles` and commit it. Commit current work before updating, preview when unsure, and review the result with `git status` and `git diff`. `bash execs/update.sh --help` is the authoritative flag reference.

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

The complete collaboration rules are in [`AGENTS.md`](AGENTS.md); the authoritative workflow rules are in the [Writing Workflow Conventions](docs/mds/story-workflow/writing-workflow-conventions.md). Both are English only; a run in Chinese follows them and replies in Chinese.

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

- Git 2.25+ and Bash 3.2+
- A reasonably complete TeX Live or MacTeX installation with `latexmk`
- `latexindent` for manuscript formatting
- CTeX plus XeLaTeX or LuaLaTeX for the Simplified Chinese template and for a Chinese abstract under the `cjk` option
- `pdfinfo` for page counts: `run.sh` reports one only with it, and lint otherwise reads the build log and warns when neither gives a count
- `texcount` for optional word counts
- `curl` for adoption and upstream updates
- `shasum` or `sha256sum` for evidence fingerprints

Individual agent harnesses may add their own runtime requirements; DSH's local router installation, for example, requires `pnpm` on `PATH`.

## Change log

Highlights, newest first. STORY does not tag releases yet, so `bash execs/update.sh` follows `main`; once a release is tagged, passing the tag as `ref` pins an update to it.

- **2026-09-24** — The milestone directory `milestones/` is now `miles/`, matching the other abbreviated names such as `mates/`, `manus/`, `notes/`, and `tasks/`; every skill, `lint.sh`, the status scan, and the gates that guard received feedback read only `miles/`. An update moves nothing: run `git mv milestones miles` in an existing thesis and commit it, and the updater reports a leftover `milestones/` until you do ([Updating STORY](#updating-story-skills-and-workflow-docs)). An existing thesis keeps its own `.editorconfig`, so change its two `milestones/` template sections to `miles/` by hand.
- **2026-09-24** — A thesis can carry abstracts in both languages: `\begin{storyabstract}[en|zh]` and `\storykeywords[en|zh]{...}` name each abstract's language, and the new `cjk` class option lets an English thesis typeset a Chinese abstract under XeLaTeX or LuaLaTeX ([English and Simplified Chinese](#english-and-simplified-chinese)). `degree/profile.tex` gains `\submissionstatement`, the title-page statement above the degree name, which ships as a placeholder. `lint.sh` reads level wording from the degree field only and checks the language option only under STORY's class; it takes the page count from the build log when `pdfinfo` is missing and warns when it cannot check a page limit, warns on missing characters, an unset `dissertation_language`, or a profile with no `\submissionstatement`, and fails on an invalid `dissertation_language`. `import.sh --diff` prints a `stale`, `new upstream`, or `removed upstream` line per file and exits `2` only for the first two, and only a `stale` line makes a file stale. `fmt.sh` keeps a closing `}` or `]` on its sentence's line and refuses a rewrite that adds or drops a space beside one. The commit guard also declines a `+refspec` push, deleting a remote branch or tag, and `update-ref` on a tag. `execs/update.sh` now works with Git 2.25–2.36, whose sparse checkout does not start in cone mode; `--adopt` also installs `manus/main-zh.tex` and, when it keeps a `.gitignore`, notes one that leaves `.env` unignored or ignores evidence under `mates/`, which the template's own `.gitignore` never ignores. An update deletes nothing, so delete by hand a leftover Chinese instruction twin, such as `.agents/commands/story.zh-CN.md`, which this release drops, or `skills/story/SKILL_zh.md` in either plugin tree (`.codex/plugins/story/`, `.kimi-code/plugins/story/`), or a folded workflow spec. An update or `--adopt` that keeps a `.latexindent.yaml` without the closing-brace rules says so, `import.sh` warns when an ignore rule would leave an imported file untracked, and the status scan reports a PDF whose build log is missing as a stale build. The conventions settle what `weakened` means (a confirmed narrower scope not yet in the wording), reopen an audit line whose failure returns, return an outline row to `in-progress` when a write leaves it unfinished, name who retires a claim, and tighten deposit gates 1 and 7; `story-chap-drafter` adapts published material only under an `in-scope` or `cleared` publication row, and `/story-auto` asks each target only for the inputs it needs. The memory hooks read a quoted `verified` date as a date; the Qwen Code resolver reads past a malformed transcript line, Kimi Code's provenance line says to copy the configured model id verbatim, and Codex's `--check` accepts the id `--resolve` gives. An existing thesis keeps its own `.gitignore`, `.cursorignore`, `.vscode/settings.json`, `.latexindent.yaml`, `.editorconfig`, `degree/profile.tex`, and `manus/`, which an update does not overwrite, so apply these changes by hand: add `!/mates/**` to `.gitignore` after the LaTeX build-file rules and before `.DS_Store`, with a `.env` line right after it, and `!mates/**` at the same place in `.cursorignore`; set `latex-workshop.latex.autoClean.run` to `"never"`, so an editor build stops deleting the log that `lint.sh --no-build` and the status scan read; copy the two closing-brace rules under `modifyLineBreaks` from upstream's `.latexindent.yaml`, without which the new `fmt.sh` refuses any file where a sentence ends a group; set `charset`, `end_of_line`, and `insert_final_newline` to `unset` in `.editorconfig`'s style-layer and template sections; add a `\submissionstatement` line before `\degree` in `degree/profile.tex`; copy `manus/stys/story.cls` from upstream for per-language abstracts and `cjk`; and copy `manus/main-zh.tex` from upstream if an earlier `--adopt` left it out, since `STORY_MAIN=manus/main-zh.tex` needs it.
- **2026-09-23** — Who sets each ledger status is now one rule, [§3 of the conventions (Who sets each status)](docs/mds/story-workflow/writing-workflow-conventions.md#who-sets-each-status), and a deposit is ready only when `story-depo-packer` reports every gate of [§6 (Deposit gates)](docs/mds/story-workflow/writing-workflow-conventions.md#deposit-gates) as passing, a clean Git tree and both audits run after the last change among them; it records the source commit in the RECORD and tags it only when you confirm. `story-chap-drafter` also drafts one front- or back-matter file, and `trace CHAPTER` adds missing source anchors without changing typeset text. Informal supervisor or coauthor feedback goes to a standing `milestones/supervision/` record, and `story-exam-reviewer` writes `wkdrs/reports/SIM_EXAM_<date>.md` when no milestone is named or active, never creating one. `story-proj-adopt` copies the draft rather than moving it, after you commit a checkpoint. The template's `degree/profile.tex` now ships `% thesis_type:` empty rather than `monograph`, and `story-outl-planner` asks for it; every skill's argument hint ends with `[involve=LEVEL]`.
- **2026-09-23** — `/story-auto <goal>` (`$story-auto` in Codex) pursues a goal: it runs `story-flow-status`, starts the ten unmarked skills each handoff names, asks you at every `AGENTS.md` §1 ask-first choice, and stops at a † skill or a gate only the author can clear; it never imports evidence, writes `degree/` or received feedback, declares a deposit ready, commits, or pushes ([Goal runs](docs/mds/story-workflow/writing-workflow-conventions.md#goal-runs)). Claude Code gains `story_bash_gate.sh`, which answers its shell prompt at `INVOLVE=low` outside the red lines and follows the `involve=` token you last typed; every gate keeps the prompt for a write into `mates/`, `degree/`, or `milestones/*/feedback/`, and Pi gains the commit guard. The provenance read is quoted for zsh and pre-allowed in `.claude/settings.json`, and Codex adds a post-write `--check`. Each memory file now carries a one-line `summary`, from which the hooks build the index (`--list` prints it), and the template ships only `.story/memory/.gitkeep`. The human-writing guide, the memory spec, and the model-id fallbacks fold into the [workflow conventions](docs/mds/story-workflow/writing-workflow-conventions.md) as §5, §10, and the new §11 harness adapters, the one section that names a harness. Instructions are English only: `SKILL_zh.md`, `AGENTS.zh-CN.md`, and the other instruction twins are gone, a Chinese run still replies in Chinese, and a thesis deletes its leftover copies by hand, as [Updating STORY](#updating-story-skills-and-workflow-docs) lists. `story-flow-status` runs at `effort: medium` in Claude Code, and `lint.sh` fails on a failed build and reads the page limit from the active milestone. An older updater stops with `Upstream ref is missing AGENTS.zh-CN.md`: replace `execs/update.sh` once by hand, as [Updating STORY](#updating-story-skills-and-workflow-docs) describes. An existing thesis keeps its own `.claude/settings.json` and `.codex/hooks.json`: merge the bash-gate registration and the three allow rules ([Hooks and permissions](#hooks-and-permissions)) and Codex's separate memory `SessionStart` group by hand (the updater reports a missing gate, a missing resolver rule, and the old grouping), and install the Codex or Kimi Code plugin again to get `/story-auto`.

## License

See [LICENSE](LICENSE).
