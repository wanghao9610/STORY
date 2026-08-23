<div align="center">
  <h1>STORY</h1>
  <p><strong>Systematic Toolchain for Organizing Research over Years</strong></p>
  <p><em>A STAR takes the STAGE to tell a STORY.</em></p>
</div>

**Language:** English | [简体中文](README.zh-CN.md)

STORY is a repository template and AI-assisted workflow for writing a complete doctoral dissertation. It organizes years of research, published papers, experimental evidence, chapter drafts, committee feedback, degree requirements, defense materials, corrections, and the final deposit without losing provenance or authorship boundaries.

The three repositories form a progression:

```text
STAR   conducts research and produces evidence
STAGE  turns one research contribution into a paper
STORY  synthesizes years of contributions into a dissertation
```

STORY works with any combination of STAR repositories, STAGE paper repositories, and manually registered evidence. Pairing is optional.

## What STORY provides

- A generic, compilable `book`-based dissertation template with front matter, chapters, appendices, figures, tables, and bibliography separated cleanly.
- A fingerprinted, read-only evidence store under `mates/`, supporting multiple research and paper repositories.
- A thesis-level narrative, contribution map, publication/reuse map, outline, notation table, and claim ledger under `notes/`.
- User-confirmed institutional requirements and committee records under `degree/`.
- Durable milestone records for proposal, annual review, pre-defense, defense, corrections, and deposit.
- Deterministic build, formatting, import, and lint entrypoints under `execs/`.
- Sixteen focused workflow skills mirrored for Codex, Claude Code, Cursor, and Kimi Code.
- Project-owned memory under `.story/memory/` for facts not owned by another repository file.

## Repository layout

```text
STORY/
├── manus/                         # Dissertation source
│   ├── main.tex
│   ├── fronts/                    # Abstract, acknowledgements, declarations
│   ├── chaps/                     # <n>_<slug>.tex chapters
│   ├── backs/                     # Appendices and other back matter
│   ├── figs/                      # Rendered figures; figs/srcs/ holds sources
│   ├── tabs/                      # Evidence-backed LaTeX tables
│   ├── bibs/                      # reference.bib
│   └── stys/                      # story.cls, story.sty, story.bst
├── mates/                         # Fingerprinted evidence snapshots; read-only
├── degree/                        # Institutional profile, requirements, committee
├── notes/                         # Narrative and writing metadata
│   ├── story.md                   # Central argument and doctoral research arc
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
└── .agents/.claude/.cursor/.kimi-code
```

## Quick start

```bash
git clone https://github.com/wanghao9610/STORY.git my-dissertation
cd my-dissertation
cp .env.example .env
bash execs/run.sh
bash execs/scpts/lint.sh
```

Fill `degree/profile.tex` and `degree/requirements.md` only from official university or program material confirmed by the author. Then run `$story-proj-adopt` for an existing draft, or start with `$story-syns-coach` and `$story-outl-planner`.

Import each research source separately:

```bash
bash execs/scpts/import.sh --source ../my-star-project --slug project-a
bash execs/scpts/import.sh --source ../my-stage-paper --slug paper-a
bash execs/scpts/import.sh --diff --source ../my-star-project --slug project-a
```

## Workflow

1. `$story-proj-adopt` inventories and adopts an existing dissertation safely.
2. `$story-evid-curator` imports, registers, and audits evidence.
3. `$story-syns-coach` establishes the thesis-level research arc and contributions.
4. `$story-outl-planner` creates a coherent chapter architecture.
5. `$story-chap-drafter` drafts one chapter from evidence and its brief.
6. `$story-tabs-builder` and `$story-figs-designer` build traceable visuals.
7. `$story-refs-curator` maintains verified bibliography records and reading notes.
8. `$story-copy-editor` harmonizes voice, terminology, and cross-chapter flow.
9. `$story-clms-auditor` and `$story-cite-auditor` audit numbers, claims, and citations.
10. `$story-exam-reviewer` simulates an examiner or committee review.
11. `$story-revs-resolver` tracks and resolves feedback without editing received comments.
12. `$story-defn-builder` prepares and checks the defense deck.
13. `$story-depo-packer` preflights and freezes the final deposit package.
14. `$story-flow-status` reports the current state and one recommended next action.

The authoritative workflow rules are in [writing-workflow-conventions.md](docs/mds/story-workflow/writing-workflow-conventions.md).

## Evidence and authorship

Every quantitative or comparative claim must lead to a registered `mates/` artifact or remain visibly unresolved. `notes/publications.md` separately records which chapters reuse published material, coauthor contributions, permissions, and overlap. Evidence traceability does not replace attribution; STORY requires both.

## Institutional formats

The bundled class is intentionally generic. Official university templates and rules are user-supplied facts. Keep the generic manuscript intact; generate or maintain institution-specific packaging as a separate deposit milestone so a format conversion cannot silently rewrite the dissertation's source of truth.

## Requirements

- Bash 3.2+
- A reasonably complete TeX Live distribution with `latexmk`
- `pdfinfo` for page counts and `texcount` for optional word counts

## License

See [LICENSE](LICENSE).
