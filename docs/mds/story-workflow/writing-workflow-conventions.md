# STORY thesis-workflow conventions

**Language:** English | [简体中文](writing-workflow-conventions.zh-CN.md)

This document is the shared contract for every `story-*` skill. STORY means **Systematic Toolchain for Organizing Research over Years**. One repository represents one master's thesis or doctoral dissertation.

## 1. Sources of truth

| Question | Owning file or directory |
| --- | --- |
| What degree and institutional rules apply? | `degree/profile.tex`, `degree/requirements.md` |
| Who is on the committee? | `degree/committee.md` |
| What is the thesis's central argument? | `notes/story.md` |
| What are the degree contributions? | `notes/contributions.md` |
| What published material is reused and how? | `notes/publications.md` |
| What is each chapter supposed to do? | `notes/outline.md` |
| Where is a claim stated and evidenced? | `notes/claims.md` |
| What does a cited work support? | `notes/refs/` |
| What did a review, defense, or deposit attempt require? | `milestones/<slug>/` |
| What remains unresolved? | `tasks/` |

Chat history and `.story/memory/` never override these files.

### Degree-level contract

`degree/profile.tex` records the author-confirmed `% degree_level: master|doctoral` value. These are the only valid values. A missing or invalid value is `unknown`: read-only workflows report it, while any workflow that would make level-specific judgments stops and asks the author to confirm and record it. Never infer the level from the title, degree name, chapter count, publications, or conversation.

Use *thesis* as the generic workflow term; use *master's thesis*, *doctoral dissertation*, or an institution's official wording when the level or document title matters. Institutional rules in `degree/requirements.md` always override generic expectations.

- In `doctoral` mode, test whether the work makes the original, significant, and thesis-level contribution required by the confirmed doctoral rules, including cross-study synthesis where the research arc calls for it.
- In `master` mode, frame a bounded degree contribution appropriate to the confirmed master's rules. It may be an original result, application, replication, validation, design, or evidence-based synthesis. Do not require publications, multiple studies, field-level originality, or a separate synthesis chapter unless the program or confirmed research design requires them.
- Both modes retain the same evidence, citation, attribution, reproducibility, and no-invention standards. Degree level changes the expected scope and examination rubric, never the provenance bar.
- Create and gate only milestones required by the confirmed program. A proposal, annual review, pre-defense, external examination, or oral defense is not universal merely because it appears in the generic roster.

### Lazy creation of writing metadata

A fresh STORY clone contains only `notes/.gitkeep` and `notes/refs/.gitkeep`.
The Markdown artifacts under `notes/` are created on first use by their owning skills, rather than shipped as empty templates:

| Artifact | First creator |
| --- | --- |
| `notes/adopt.md` | `story-proj-adopt` |
| `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, `notes/claims.md` | `story-syns-coach`; `story-proj-adopt` may initialize `notes/claims.md` for an existing draft |
| `notes/outline.md`, `notes/notation.md` | `story-outl-planner` |
| `notes/style.md` | `story-copy-editor style` |
| `notes/refs/refs_index.md`, `notes/refs/<key>.md` | `story-refs-curator` |

An absent artifact means that workflow stage is not initialized; it is not by itself corruption.
The owning skill creates the file immediately before its first durable write, preserves any existing content, and creates the English/Simplified-Chinese Markdown pair in the same change.
A consuming skill that finds a required artifact absent stops and routes to its first creator instead of inventing a substitute schema.
Changing `STORY_LANG` never translates or replaces an existing artifact.

## 2. Evidence contract

1. A file becomes evidence only after it has a `mates/MANIFEST.md` entry and a matching fingerprint.
2. `mates/` is immutable in place. Refresh an imported artifact from its source or register a corrected artifact as a new record.
3. Every quantitative or comparative statement in `manus/` has a nearby `% src: mates/<path>#<anchor>` comment or a claim-ledger evidence link.
4. When evidence is missing, write `\todo{...}`. Never interpolate, remember, or invent a plausible value.
5. Assertions about literature require a reading note or imported source that was checked in the current run.
6. A STAGE paper can supply wording and a published result, but it does not erase the underlying STAR evidence, coauthor attribution, or reuse policy.

## 3. Structured record IDs and states

Use the canonical lowercase tokens below in machine-read fields and `Status` columns; do not substitute synonyms. Leave an optional value empty when it is unknown. Use `none` in a free-text or list cell only when the absence or non-applicability has been confirmed; never use `none` as a status. Dates use `YYYY-MM-DD`, paths are repository-relative, URLs use stable `https://` locations, and multi-value cells use comma-separated stable IDs or paths.

`notes/story.md` frontmatter accepts:

- `status: discovery | finalized`; `discovery` means the thesis argument or contribution map is still being formed, while `finalized` requires author confirmation of the central argument and the contribution/attribution map. A substantive change returns it to `discovery` until reconfirmed.
- `active_milestone: "" | <existing milestone slug>`; a slug matches `^[a-z0-9][a-z0-9._-]*$` and names an existing `milestones/<slug>/milestone.yml`.
- `updated: YYYY-MM-DD`; use the system date of the durable change.

Claim IDs use `C001`, `C002`, and so on. Valid claim statuses are:

- `proposed`: accepted into the thesis plan but not yet stated;
- `drafted`: stated in `manus/` but not audited;
- `verified`: wording and evidence agree;
- `weakened`: scope was narrowed after evidence or review;
- `unsourced`: stated content lacks sufficient evidence;
- `retired`: intentionally removed and no longer stated.

Degree-contribution IDs use `D001`, `D002`, and so on; `D` means *degree*, not *doctoral*. Valid contribution statuses are:

- `proposed`: a candidate contribution not yet confirmed by the author;
- `confirmed`: scope and attribution are author-confirmed, but evidence or chapter mappings may remain incomplete;
- `evidenced`: the contribution's supporting claims, evidence, attribution, and chapter mappings have been verified;
- `weakened`: its scope was narrowed after evidence or review;
- `retired`: intentionally removed from the active thesis argument.

A contribution row uses free text for the contribution and attribution, comma-separated IDs for research questions and claims, and comma-separated repository-relative paths or IDs for evidence, publications, and chapters. A chapter is not automatically a contribution; a publication is not automatically a degree contribution.

Publication/reuse IDs use `P001`, `P002`, and so on. Valid publication row statuses are:

- `candidate`: identified for possible use but not author-confirmed as in scope;
- `in-scope`: author-confirmed for possible or planned reuse, with policy work possibly still open;
- `cleared`: planned reuse, attribution, overlap handling, and permission or policy checks are resolved;
- `excluded`: intentionally outside the thesis, with the reason retained in the row.

The `Permission / policy` cell starts with exactly one of `unknown | not-required | pending | cleared | restricted`, followed when available by `; source: <URL-or-path>; notes: <free text>`. Complete authorship and author-contribution cells are free text; candidate chapters and reused-material cells use comma-separated paths or concise free text as appropriate.

Every chapter, figure, and table row in `notes/outline.md` uses one of these statuses:

- `planned`: the brief exists but the manuscript artifact is not yet being developed;
- `in-progress`: an artifact or draft exists, but its exit condition is not met;
- `ready`: the exit condition is met, required mappings are current, and the manuscript builds;
- `blocked`: a named unresolved dependency prevents progress;
- `retired`: intentionally removed from the active outline without deleting its history.

The `Verification status` column in `notes/refs/refs_index.md` uses `unverified | metadata-verified | content-verified | stale`. `metadata-verified` confirms bibliographic identity only; `content-verified` means the source itself was checked and its reading note supports the recorded facts; `stale` requires re-verification before further claim-bearing use.

## 4. Publication reuse and attribution

Before adapting substantial text, figures, tables, or structure from a paper, add or confirm its row in `notes/publications.md`. Record:

- complete authorship;
- the author's contribution;
- candidate thesis chapters;
- reused or adapted material;
- copyright, license, or program policy status;
- overlap that must be rewritten or disclosed.

Never describe collaborative work as solely the candidate's. Never infer permission from public availability.

## 5. Chapter contract

Chapter files are `manus/chaps/<n>_<slug>.tex`. The numeric prefix, `notes/outline.md`, and `manus/main.tex` input order must agree.

Each chapter brief states its purpose, research questions, contribution IDs, claim IDs, required evidence, planned figures/tables, dependencies, and exit condition. When published work is reused, research chapters must be rewritten into the thesis arc; concatenating paper introductions and conclusions is not synthesis. Do not impose a publication-based architecture or separate synthesis chapter on a master's thesis without a confirmed reason.

Front matter lives in `manus/fronts/`; appendices and other back matter live in `manus/backs/`. Project-specific LaTeX commands belong in `manus/main.tex`, not the reusable class or package.

## 6. Milestone contract

Each applicable durable event lives in `milestones/<slug>/`, with a user-confirmed `milestone.yml`. Recommended fields are:

```yaml
kind: defense
official_name: ""
status: planned
due: ""
requirements_source: ""
max_pages: ""
confirmed_by: ""
confirmed_on: ""
```

Milestone slugs match `^[a-z0-9][a-z0-9._-]*$`. Fill the fields as follows:

- `kind`: `proposal | review | annual-review | pre-defense | external-examination | defense | correction | deposit | other`; this field is required. Use `other` only when no canonical kind fits.
- `official_name`: empty or the institution's confirmed name as free text; it is required when `kind: other`.
- `status`: `planned | active | blocked | completed | cancelled`; this field is required. `blocked` names a concrete unresolved gate, `completed` requires a matching `RECORD_<date>.md`, and `cancelled` requires a confirmed reason.
- `due`: empty or a confirmed `YYYY-MM-DD` date.
- `requirements_source`: empty, a stable `https://` URL, or a repository-relative path to an official supplied record.
- `max_pages`: empty or a positive integer without units. Record counting rules and exclusions in the milestone response or `degree/requirements.md`.
- `confirmed_by`: empty, `author`, a confirmed person's name, or a confirmed institutional role.
- `confirmed_on`: empty or the confirmation date in `YYYY-MM-DD` format.

Received feedback is copied unchanged into `feedback/`. A response point ledger in `response/` maps every item to a disposition: `accepted`, `completed`, `planned`, `disagreed`, or `needs-author`. Promised changes also become checkboxes under `tasks/`.

The final `deposit` milestone is blocked by unresolved `\todo` markers, failed lint, unchecked institutional requirements, open feedback promises, missing reuse permissions, or any required approval that is not recorded.

## 7. Interaction, language, and provenance

- Every skill takes the same argument shape: `<skill> [TARGET] [DESCRIPTION] [involve=<level>]`. Strip `involve=<level>` first, resolve the target next, and treat whatever remains as a description. A description is a lead, not a command: it may select among a skill's own documented paths and supply wording the run records, and it never replaces a confirmation point, settles an ambiguous target, licenses an unsourced number, or authorizes a freeze. Where a skill's first argument is already free text, that argument is the description.
- `INVOLVE=low|medium|high` controls how often a skill asks before judgment calls. It never bypasses confirmation of institutional facts, attribution, deletion, overwriting, or final freeze.
- Resolve the level once at the start of a run, in this order: `INVOLVE` in `.env` (absent, unset, or invalid means `medium`), then an `involve=<level>` token in the invocation, then plain language during the run. The last instruction holds for the rest of the run. Every skill strips the token, including one whose `argument-hint` never advertises it and one that takes no other argument; a skill matching its first argument against outline rows must never read `involve=low` as a target.
- `STORY_LANG=en|zh` controls replies and newly written Markdown. Empty follows the conversation. Existing files retain their language.
- `STORY_MAIN` selects the default manuscript entry point for build and lint. A command-line `--main` overrides it; neither setting changes the manuscript language recorded in `degree/profile.tex`.
- Degree level and manuscript language come from `degree/profile.tex`; do not switch either because of wording in the conversation.
- Dated artifacts use the system date. When model provenance is recorded, use the session-provided model ID; never invent one.
- A skill edits only the files it owns. It routes work to another skill when ownership changes.

## 8. Verification

- Any change under `manus/` ends with `bash execs/run.sh`.
- Run `bash execs/scpts/lint.sh` when citations, references, todos, metadata, page limits, or deposit readiness may have changed.
- Re-read each cited evidence value during the run; a remembered value or fingerprint is insufficient.
- Reports under `wkdrs/` are regenerable. Durable decisions update `degree/`, `notes/`, `milestones/`, or `tasks/`.
- A completion report names the built PDF, page count, lint verdict, ledger changes, and remaining gates.

## 9. Skill roster

Skills marked † are explicit-only: they change thesis-wide structure, milestone handling, or institutional packaging and run only after the author directly chooses them. Codex enforces this in `.codex/skills/*/agents/openai.yaml`; the other harness trees use `disable-model-invocation: true`.

| Skill | Owns |
| --- | --- |
| `story-proj-adopt` † | Safe adoption of existing drafts |
| `story-evid-curator` | Evidence import, registration, integrity |
| `story-syns-coach` † | Thesis-level research arc and contribution framing |
| `story-outl-planner` † | Chapter architecture and briefs |
| `story-chap-drafter` | One chapter per run |
| `story-tabs-builder` | Evidence-backed tables |
| `story-figs-designer` | Evidence-backed figures and editable sources |
| `story-refs-curator` | Bibliography and reading notes |
| `story-copy-editor` | Voice, terminology, flow, and consistency |
| `story-clms-auditor` | Quantitative and claim traceability audit |
| `story-cite-auditor` | Citation-key and literature-assertion audit |
| `story-exam-reviewer` | Mock examiner or committee review |
| `story-revs-resolver` † | Feedback point ledger and dispositions |
| `story-defn-builder` † | Defense narrative and deck |
| `story-depo-packer` † | Deposit preflight, package, and freeze record |
| `story-flow-status` | Read-only status and next action |
