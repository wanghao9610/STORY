# STORY thesis-workflow conventions

This is the shared contract for every `story-*` skill. STORY means **Systematic Toolchain for Organizing Research over Years**; one repository holds one master's thesis or doctoral dissertation.

**Adapter boundary.** §1–§10 hold for every harness STORY ships and name none of them. Invocation spelling, hook events, registration, and trust live in §11 and the harness manifests, which implement these rules without changing scope, authority, or artifact ownership.

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
| What did a review, defense, or deposit attempt require? | `miles/<slug>/` |
| What remains unresolved? | `tasks/` |

Chat history and `.story/memory/` never override these files.

### Degree-level contract

`degree/profile.tex` records the author-confirmed `% degree_level: master|doctoral`; no other value is valid. A missing or invalid entry is `unknown`: read-only workflows report it, and a workflow that would make a level-specific judgment stops and asks the author to confirm and record it. Never infer the level from the title, degree name, chapter count, publications, or conversation. `degree/` has no owning skill. The author fills it, or a run records a value the author states in that run, together with the source that `degree/requirements.md` asks for. No skill ticks a requirement row, confirms a committee row, or fills a profile field on its own judgment.

*Thesis* is the generic workflow term; say *master's thesis*, *doctoral dissertation*, or the institution's official wording when the level or title matters. `degree/requirements.md` always overrides generic expectations.

- `doctoral`: test for the original, significant, thesis-level contribution the confirmed doctoral rules require, including cross-study synthesis where the research arc calls for it.
- `master`: frame a bounded contribution fit to the confirmed master's rules — an original result, application, replication, validation, design, or evidence-based synthesis. Do not require publications, multiple studies, field-level originality, or a separate synthesis chapter unless the program or the confirmed research design does.
- Both levels keep the same evidence, citation, attribution, reproducibility, and no-invention standards: the level changes the expected scope and examination rubric, never the provenance bar.
- Create and gate only milestones the confirmed program requires; appearing in the generic roster does not make a milestone universal. The standing `supervision` record (§6) is the one exception and gates only its own promises.

### Lazy creation of writing metadata

A fresh clone holds only `notes/.gitkeep` and `notes/refs/.gitkeep`. The Markdown artifacts under `notes/`, and the other artifacts below, are created on first use by their owning skills, not shipped as empty templates:

| Artifact | First creator |
| --- | --- |
| `notes/adopt.md` | `story-proj-adopt` |
| `notes/story.md`, `notes/contributions.md`, `notes/publications.md`, `notes/claims.md` | `story-syns-coach`; `story-proj-adopt` may initialize `notes/claims.md` for an existing draft |
| `notes/outline.md`, `notes/notation.md` | `story-outl-planner` |
| `notes/style.md` | `story-copy-editor style` |
| `notes/refs/refs_index.md`, `notes/refs/<key>.md` | `story-refs-curator` |
| `manus/bibs/reference.bib` | `story-refs-curator`; `execs/scpts/import.sh` may seed it from an imported source |

An absent artifact means its stage is uninitialized; by itself it is not corruption.
The owner creates it just before its first durable write and preserves any existing content, writing it once, in the language §7 resolves for new Markdown, with no translated twin.
Structural keys — frontmatter keys, the section headings and table column headers a skill's schema names, status and verdict tokens, IDs, paths, and the `none` sentinel — stay in English exactly as the schema spells them, since the status scan and lint read them literally; prose and free-text cells follow the resolved language, and text a run adds to an existing file follows that file's.
`notes/publications.md` exists once the author confirms the reuse map, even with nothing in scope: its header and one dated line, in the resolved language, recording that confirmed absence.
A `*.zh-CN.md` twin a thesis carries from an earlier STORY release is the author's: no skill deletes it, keeps it in step, or reads it in place of the file it translates, and a run that finds one names deleting it as an author action (§8, Completion handoff) instead of offering to do it.
A consumer that finds a required artifact absent stops and routes to its first creator rather than inventing a substitute schema.
Changing `STORY_LANG` never translates or replaces an existing artifact.

## 2. Evidence contract

1. A file becomes evidence only after it has a `mates/MANIFEST.md` entry and a matching fingerprint. Registered evidence is an entry whose SHA-256 still matches; a `tampered`, `missing`, or `stale` file (§3) is not, until refreshed.
2. `mates/` is immutable in place. Refresh an imported artifact from its source or register a corrected artifact as a new record.
3. Every quantitative or comparative statement in `manus/` has a `% src: mates/<path>#<anchor>` comment in its paragraph (for a table, on its row) or a claim-ledger evidence link. `<anchor>` is a grep-able locator, unique in the file and stable across re-import: a Markdown heading slug, a CSV or TSV key-column value with its column name (never a bare row number), a JSON or YAML key path, or `p<page>` with the table or figure label for a PDF; omit it only when the whole file is the source. A claim-ledger `Evidence` cell uses the same form. A `% src:` line in `manus/bibs/reference.bib` records the fetched bibliographic record, not evidence.
4. When evidence is missing, write `\todo{...}`. Never interpolate, remember, or invent a plausible value.
5. Assertions about literature require a reading note or imported source that was checked in the current run.
6. A STAGE paper can supply wording and a published result, but it does not erase the underlying STAR evidence, coauthor attribution, or reuse policy.

## 3. Structured record IDs and states

Machine-read fields and `Status` columns use the canonical lowercase tokens below, never synonyms. Leave an unknown optional value empty; write `none` in a free-text or list cell only for a confirmed absence or non-applicability, and never as a status. Dates are `YYYY-MM-DD`, paths are repository-relative, URLs point to stable `https://` locations, and multi-value cells hold comma-separated stable IDs or paths.

`notes/story.md` frontmatter accepts:

- `status: discovery | finalized`; `discovery` means the argument or contribution map is still forming, while `finalized` requires author confirmation of the central argument and the contribution/attribution map. A substantive change returns it to `discovery` until reconfirmed.
- `updated: YYYY-MM-DD`; use the system date of the durable change.
- `active_milestone: "" | <existing milestone slug>` is a legacy key: no skill writes it, and lint and the status scan read it only when no milestone other than `miles/supervision/` has `status: active` (§6, Milestone lifecycle).

Evidence integrity verdicts, reported by `story-evid-curator check` and, except `stale`, by the status scan, are `ok` (the file's SHA-256 matches its manifest entry), `tampered` (it differs), `missing` (an entry without its file), `unregistered` (a file under `mates/` without an entry), and `stale` (the snapshot matches its entry, but `bash execs/scpts/import.sh --diff --source <dir> --slug <slug>` prints a `stale <rel>` line for it because its source changed). `stale` is a per-file verdict: a `new upstream <rel>` line (a source file with no snapshot under `mates/<slug>/`) or a `removed upstream <rel>` line (an entry whose source file is gone) marks no existing file `stale`, and a `removed upstream` line is reported to the author while the snapshot stays. The run exits 2 when it printed at least one `stale` or `new upstream` line, and 1 when the check could not run.

Claim IDs use `C001`, `C002`, and so on, and `notes/claims.md` has the columns `ID | Claim | Contribution | Stated in | Evidence | Status | Notes`. Valid claim statuses are:

- `proposed`: accepted into the thesis plan but not yet stated;
- `drafted`: stated in `manus/` but not audited;
- `verified`: wording and evidence agree;
- `weakened`: the author confirmed a narrower scope after evidence or review, but the manuscript wording is not yet narrowed to it; the claim's `## Claims` line in `tasks/audits.md` stays open until an audit finds the narrowed wording `matched` and sets `verified`, and `Notes` keeps the narrowing and its source (audit date or feedback point ID);
- `unsourced`: stated content lacks sufficient evidence;
- `retired`: intentionally removed and no longer stated.

Degree-contribution IDs use `D001`, `D002`, and so on; `D` means *degree*, not *doctoral*. Valid contribution statuses are:

- `proposed`: a candidate contribution not yet confirmed by the author;
- `confirmed`: scope and attribution are author-confirmed, but evidence or chapter mappings may remain incomplete;
- `evidenced`: the contribution's supporting claims, evidence, attribution, and chapter mappings have been verified;
- `weakened`: its scope was narrowed after evidence or review;
- `retired`: intentionally removed from the active thesis argument.

A contribution row holds free text for the contribution and attribution, comma-separated IDs for research questions, and comma-separated paths or IDs for evidence, publications, and chapters. Research-question IDs are `RQ1`, `RQ2`, and so on, declared under the `Research questions` heading of `notes/story.md`. Claims map to contributions through the `Contribution` column of `notes/claims.md`, not a column of their own. A chapter is not automatically a contribution, and a publication is not automatically a degree contribution.

Publication/reuse IDs use `P001`, `P002`, and so on. Valid publication row statuses are:

- `candidate`: identified for possible use but not author-confirmed as in scope;
- `in-scope`: author-confirmed for possible or planned reuse, with policy work possibly still open;
- `cleared`: planned reuse, attribution, overlap handling, and permission or policy checks are resolved;
- `excluded`: intentionally outside the thesis, with the reason retained in the row.

The `Permission / policy` cell starts with exactly one of `unknown | not-required | pending | cleared | restricted`, followed when available by `; source: <URL-or-path>; notes: <free text>`. Complete-authorship and author-contribution cells are free text; candidate-chapter and reused-material cells hold comma-separated paths or concise free text as appropriate.

Figure and table IDs are `F001` and `T001` onward, and a figure or table row's `Chapter` cell holds the chapter file path. Every chapter, figure, and table row in `notes/outline.md` uses one of these statuses:

- `planned`: the brief exists but the manuscript artifact is not yet being developed;
- `in-progress`: an artifact or draft exists, but its exit condition is not met;
- `ready`: the exit condition is met, no `\todo` remains in the artifact, every claim the artifact states has current `Stated in` and `Evidence` cells in `notes/claims.md`, and the manuscript builds; a substantive change to its brief, or a write that leaves a `\todo` in the artifact or its exit condition unmet, returns it to `in-progress`;
- `blocked`: a named unresolved dependency prevents progress;
- `retired`: intentionally removed from the active outline without deleting its history.

The `Verification status` column in `notes/refs/refs_index.md` uses `unverified | metadata-verified | content-verified | stale`. `metadata-verified` confirms bibliographic identity only; `content-verified` means the source itself was checked and its reading note supports the recorded facts; `stale` requires re-verification before further claim-bearing use. An entry in `manus/bibs/reference.bib` without an index row counts as `unverified`, and `Used in chapters` derives from the `\cite` keys in `manus/`.

### Who sets each status

Only a run of the skill named here moves a status, in the same change as the edit that justifies it; a run that finds a status it may not move reports and routes it (§7, Ownership).

- **Thesis story.** `story-syns-coach` writes `discovery`, and `finalized` only after the author confirms the central argument and the contribution/attribution map; a run that changes the argument, a contribution's scope, or attribution returns it to `discovery`, listing the affected contribution, claim, and chapter IDs. Planning from a `discovery` story is an `AGENTS.md` §1 choice the author answers.
- **Claims.** `story-syns-coach` enters a planned claim as `proposed`, or as `drafted` with `Stated in` filled when `manus/` already states it. A drafting run — `story-chap-drafter` (including `trace`), `story-tabs-builder`, `story-figs-designer` — sets a claim it states to `drafted`, or `unsourced` when a `\todo` is its only support, filling `Stated in` and `Evidence`; a substantive change to a `verified` or `weakened` claim's number, comparison, scope, or anchor returns it to `drafted`. A drafting run other than `trace` adds a row for a claim it states for the first time, as `drafted`, or `unsourced` when a `\todo` is its only support, leaving `Contribution` empty for `story-syns-coach`; `trace` only reports a stated claim without a row. Only `story-clms-auditor` sets `verified`, adding `verified <date> @<first 12 hex digits of the cited file's SHA-256>` to `Notes`; it also sets `unsourced`, and `weakened` once the author confirms the narrower scope. `story-proj-adopt` enters an adopted draft's claims as `unsourced`, or `drafted` when their evidence is already registered. `story-revs-resolver` moves no claim status: for a conceded claim it appends the point ID and the conceded scope to `Notes` and records the point `planned`. The drafting run that keeps that promise removes or narrows the statement; a narrowed claim returns to `drafted`, and the next audit applies its usual verdict map, so a narrowed claim that now matches its evidence becomes `verified`. `retired` keeps the row, and is set by the drafting run that removes a claim's last statement; by `story-syns-coach` for a `proposed` claim the author drops; and by `story-outl-planner` on an author-approved chapter removal (not a split or merge), which drops the removed chapter's path from each claim's `Stated in` and retires a claim left with no path in a file the entry point builds. Each asks first when the claim maps to a confirmed contribution, and ticks any `## Claims` line in `tasks/audits.md` keyed by a claim it retires, appending `— done YYYY-MM-DD: <claim ID> retired`. `Notes` is append-only; `story-copy-editor` never changes a claim. When a refresh changes an evidence file's SHA-256, `story-evid-curator` lists the claims citing it and hands them to `story-clms-auditor`.
- **Contributions.** `story-syns-coach` sets `proposed`, `confirmed` (after the author confirms scope and attribution), `weakened`, and `retired`. `story-clms-auditor` moves only `Status`, between `confirmed` and `evidenced`: up when every non-retired claim mapped to the contribution is `verified` or `weakened` and its chapter mapping and attribution pass the audit, down when one no longer does.
- **Publications.** Only `story-syns-coach` writes rows; once an outline exists, `story-outl-planner` keeps `Candidate chapters` (§7, Ownership). `story-syns-coach` sets `candidate`, then `in-scope` or `excluded` on the author's answer; the `Permission / policy` prefix only from an author-supplied or fetched source named in `source:`; and `cleared` only when that prefix is `cleared` or `not-required` and the overlap handling is recorded. Reusing substantial published wording, a figure, or a table needs a `cleared` row.
- **Outline rows.** `story-outl-planner` sets `planned` for an artifact not yet created, `in-progress` for an existing draft it maps, `retired` on an author-approved removal, and `in-progress` again for a `ready` row whose purpose, contributions, claims, or exit condition it changes. The skill that writes the artifact — `story-chap-drafter`, `story-tabs-builder`, or `story-figs-designer`, the last two of which may add their own `planned` row — sets the row whenever a run writes the artifact or stops on a missing input, in that run's change: `blocked` when it stops on a missing input, recording the blocker in a `tasks/blocked.md` line (§6, Feedback and promises); otherwise `ready` only when the brief's exit condition holds, no `\todo` remains in the artifact, every claim the artifact states has current `Stated in` and `Evidence` cells in `notes/claims.md`, and `bash execs/run.sh` passed in that run; and otherwise `in-progress`, including for a `planned`, `blocked`, or `ready` row it writes. A run that moves a row off `blocked` ticks that row's `tasks/blocked.md` line.
- **References.** Only `story-refs-curator` writes `notes/refs/refs_index.md`: `unverified` for an existing bibliography entry it indexes without fetching, `metadata-verified` and `content-verified` as defined above, and `stale` when a re-fetched record shows a new version, erratum, or retraction. It recomputes `Used in chapters` whenever a run writes the index, and `story-cite-auditor` reports drift.
- **Milestones and feedback.** §6.

## 4. Publication reuse and attribution

Before adapting substantial text, figures, tables, or structure from a paper, add or confirm its row in `notes/publications.md`, recording complete authorship; the author's contribution; candidate thesis chapters; reused or adapted material; copyright, license, or program-policy status; and, in the reused-material cell, overlap that must be rewritten or disclosed. Never describe collaborative work as solely the candidate's, and never infer permission from public availability.

## 5. Chapter contract

Chapter files are `manus/chaps/<n>_<slug>.tex`; the numeric prefix, `notes/outline.md`, and the `\input` order of the active entry point (§7) must agree.

A chapter brief is the chapter's row in `notes/outline.md` plus its `### <n>_<slug>` block under that file's `## Chapter briefs` heading, stating purpose, research questions, contribution and claim IDs, required evidence, planned figures and tables, dependencies, exit condition, and inclusion. Inclusion is `adapt` unless the confirmed `thesis_type` and the published-work row of `degree/requirements.md` require a paper to appear as published: an `as-published` chapter keeps the confirmed published or accepted text, adding only a confirmed preface (co-authorship statement, place in the arc) and linking text, and thesis-level synthesis lives in the introduction, linking sections, and conclusion. Otherwise reused published work is rewritten into the thesis arc: concatenating paper introductions and conclusions is not synthesis. Do not impose a publication-based architecture or a separate synthesis chapter on a master's thesis without a confirmed reason.

Front matter lives in `manus/fronts/`, appendices and other back matter in `manus/backs/`. A front- or back-matter target is a file the active entry point inputs, and a whole-thesis pass skips the starter files it does not input. When `degree/requirements.md` requires abstracts in more than one language, each is manuscript content in its required language, and together they are one target kept consistent in the same change. The class supports this: each `storyabstract` environment and `\storykeywords` names its language (`[en]` or `[zh]`, defaulting to the class language), and an English entry point typesets a Chinese abstract only with the `cjk` class option under XeLaTeX or LuaLaTeX. Project-specific LaTeX commands belong in the active entry point, not the reusable class or package.

### Human-writing contract

Thesis prose keeps the author's scholarly voice and never uses formulaic language to inflate a claim, hide a source, or simulate significance; the aim is clear, natural scholarship, not authorship detection or detector evasion. Chapter drafting, copy-editing, and mock examination apply four rules, under the evidence, citation, attribution, and claim rules elsewhere in this document.

**Preserve the record.** A style edit may reorganize prose but never changes what the thesis can defend. Before editing, read every record that governs the passage — the chapter brief, `notes/story.md`, the outline, claim, contribution, and publication records, mapped `mates/` evidence, reading notes, notation, the style profile, and confirmed degree or institutional wording — and report a conflict instead of resolving it in prose. Keep facts, numbers, thresholds, dates, quotations, citations, `% src:` anchors, `\todo{...}` markers, claim and contribution IDs with their strength and ledger status, technical distinctions, uncertainty, negative results, attribution, comparison sets, conditions, and required qualifiers; titles, names, code, notation, LaTeX, institutional wording, and source terminology are protected unless the task owns them. Concrete detail comes only from registered evidence or the author: missing support stays a visible `\todo{...}` or routes to the owning workflow, never becoming a plausible value, source, fact, or degree requirement. Adding, removing, moving, weakening, or strengthening a claim is not style: route it through the owning workflow and update `notes/claims.md` in the same change. Reused publication text must fit the thesis arc, terminology, attribution, and reuse record (§2, §4), except in an `as-published` chapter.

**Match the writer.** Follow the author-confirmed sample `notes/style.md` records — vocabulary, sentence movement, punctuation, transitions, qualification, first-person practice, deliberate repetition — without borrowing its sentences or adding facts, opinions, humor, or disorder; without one, write restrained, direct scholarly prose. Write in the manuscript language of `degree/profile.tex`, lead with the substantive point, prefer canonical terms and simple verbs, and name the actor or contributor where agency or attribution affects interpretation. Build each paragraph on its mapped claim–evidence–inference sequence toward the chapter brief and `notes/story.md`, connecting evidence to the local inference and the inference to the research question or contribution, and claiming no more than the evidence supports; let the reasoning set length and shape, and end on a supported finding, limitation, synthesis, or transition rather than generic optimism. A whole-thesis pass also checks recurring openings, literature summaries, method recaps, contribution statements, limitations, and chapter endings, keeping purposeful consistency. Add personality only where the author-confirmed voice and the scholarly context call for it; never manufacture a persona or imply sole authorship of collaborative work.

**Review pattern clusters, not words.** Rewrite at paragraph scale when signals accumulate, a template recurs, or a pattern carries an unsupported claim. The families are inflation (overstated significance, sales language), evasion (vague attribution, hidden actors, stacked qualifiers), false depth (shallow analytical tails, "not X but Y", forced triads), padding (signposting, filler, generic endings, chatbot residue), and monotony (stock diction, repeated openings, uniform cadence). Aim for the exact result and its supported consequence, a named and verified source or an explicit gap, a direct fact–inference link with a clear actor and only the qualification the evidence needs, and only the structure the reader needs. These are signals, not bans or evidence of AI authorship: no word, transition, passive, first person, long sentence, list, or dash is wrong in isolation, a form stays when it carries a real relation, technical meaning, or the author's habit, and quotations, titles, notation, data, and literal fields are never rewritten to avoid a pattern.

**Rewrite and verify.** Mark every protected literal and semantic element, diagnose by paragraph, and rewrite each unit around its point rather than patching words; then compare with the original and the records above, restoring every dropped qualifier, trace, or attribution and removing every added or strengthened claim. Keep one sentence per source line, and after a `manus/` edit build and lint (§8). Leave a passage unchanged and report it when smoother prose would need unimported evidence, a different claim or degree requirement, an unsupported statement about prior work, a new canonical term (report it for `notes/notation.md`), changed attribution, or the removal of a necessary qualifier. A revision is ready only when claim fidelity and traceability pass, attribution stays accurate, terminology stays stable, and it still serves the chapter and thesis arguments.

`bash execs/scpts/lint.sh` flags high-confidence chatbot residue and clustered formulaic prose with advisory warnings — `chatbot-residue`, `inflated-significance`, `vague-attribution`, `formulaic-contrast`, `stock-signposting`, `shallow-analysis`, `generic-outlook`, `manufactured-depth`, `stock-diction` — that mark passages for human review, establish nothing about authorship, and never block deposit alone, and a clean scan means only that no configured pattern fired. `lint.sh` holds the English and Chinese patterns for each label; a field term that matches a watched word, such as 协同过滤, is protected terminology, not stock diction. Never assign a numerical "human score".

## 6. Milestone contract

Each applicable durable event lives in `miles/<slug>/` with an author-confirmed `milestone.yml`. Like `notes/`, a milestone directory is created on first use: the first milestone-scoped run (`story-revs-resolver`, `story-defn-builder`, or `story-depo-packer`) creates `miles/<slug>/milestone.yml` from author-confirmed facts just before its first durable write, asking rather than inventing a kind, date, or requirement. `story-exam-reviewer` writes into an existing milestone but never creates one. Recommended fields are:

```yaml
kind: defense
official_name: ""
status: planned
due: ""
requirements_source: ""
max_pages: ""
blocked_by: ""
parent: ""
confirmed_by: ""
confirmed_on: ""
```

Milestone slugs match `^[a-z0-9][a-z0-9._-]*$`. Fill the fields as follows:

- `kind`: `proposal | review | annual-review | pre-defense | external-examination | defense | correction | deposit | supervision | other`; this field is required. `supervision` is the standing record below; use `other` only when no canonical kind fits.
- `official_name`: empty or the institution's confirmed name as free text; it is required when `kind: other`.
- `status`: `planned | active | blocked | completed | cancelled`; this field is required. `blocked` names its gate in `blocked_by`, `completed` requires a matching `RECORD_<date>.md` (a `supervision` record never completes), and `cancelled` requires a confirmed reason.
- `due`: empty or a confirmed `YYYY-MM-DD` date.
- `requirements_source`: empty, a stable `https://` URL, or a repository-relative path to an official supplied record, including an examiner rubric the institution supplies.
- `max_pages`: empty or a positive integer without units. Lint compares it with the built PDF's total page count, so a limit with exclusions (front matter, appendices, bibliography) stays empty here and is recorded with its counting rule in `degree/requirements.md` for `story-depo-packer` to check.
- `blocked_by`: empty, or the gate a `blocked` milestone waits on, as free text.
- `parent`: empty, or the slug of the milestone a `correction` milestone continues.
- `confirmed_by`: empty, `author`, a confirmed person's name, or a confirmed institutional role.
- `confirmed_on`: empty or the confirmation date in `YYYY-MM-DD` format.

### Milestone lifecycle

`miles/<slug>/` holds `milestone.yml`; `feedback/`, received comments copied unchanged; `simulations/`, generated reviews; `response/`, point ledgers; `materials/`, defense plans and deck sources; `template/`, an official template the author supplied, never generated or reformatted; and `RECORD_<date>.md`, a frozen outcome.

`status` is an author-confirmed fact. The run that creates `milestone.yml` records the confirmed initial status: `planned`, or `active` for an event under way. A run moves a milestone between `planned` and `active` only on the author's confirmation. It sets `blocked`, with `blocked_by`, only for a gate that outlives the run, and returns a `blocked` milestone to its prior status, on the author's confirmation, once `blocked_by` clears. The active milestone is the one milestone, other than `miles/supervision/`, whose `status` is `active`; at most one may be, and lint takes its page limit from it. When the author supplies an official outcome — a defense result, an examination decision, a correction approval — `story-revs-resolver` copies it unchanged into `feedback/`, writes `RECORD_<date>.md` (the outcome, its conditions, the confirming document's path, `confirmed_by`, and the date), and sets `completed` in the same change; when the outcome requires corrections, it asks whether to open a `kind: correction` milestone, its `parent` naming this one, to carry the open promises. `story-depo-packer` sets `completed` with its deposit RECORD. Only the author cancels a milestone.

`miles/supervision/` (`kind: supervision`, `status: active`, empty `due`) is the standing record for informal supervisor or coauthor feedback tied to no institutional event. Each item is saved unchanged as `feedback/<YYYY-MM-DD>_<sender-role>.<ext>`, and its points join one rolling point ledger in `response/`. It needs no RECORD, is never the active milestone, and gates only its own promises.

### Feedback and promises

`story-revs-resolver` owns feedback ingestion: it copies received feedback unchanged into `feedback/` before reading it, and nothing else writes there. Generated review material — a mock examination, a simulated committee pass — lives in `simulations/`, or in `wkdrs/reports/` when no milestone applies, never in `feedback/`, and enters the point ledger only when the author explicitly asks. The point ledger in `response/` gives every item one disposition:

- `accepted`: agreed, and nothing is owed beyond the reply;
- `planned`: agreed, with a promised manuscript or artifact change;
- `completed`: a `planned` change made, with completion evidence naming the path, claim ID, or commit;
- `disagreed`: a reasoned disagreement the author has confirmed;
- `needs-author`: awaiting the author's decision.

Only `planned` and `needs-author` points open a checkbox in `tasks/<slug>_promises.md`, and a `planned` point becomes `completed` only when its box is ticked.

`tasks/` holds durable open work, one checkbox line per item, each with a stable key (a point ID, a claim ID or citekey with its location, an outline row, a manuscript location, a notation term, or an adopted file's source path) and the skill that opened it: `tasks/<slug>_promises.md` (`story-revs-resolver`); `tasks/audits.md`, with `## Claims` owned by `story-clms-auditor` and `## Citations` by `story-cite-auditor`, each section headed by a `Last full run: YYYY-MM-DD` line (`Last full run: none` until a thesis-wide run dates it); `tasks/adopt.md` (`story-proj-adopt`); `tasks/blocked.md` (the skill that set a `blocked` outline row); and `tasks/prose.md` (`story-copy-editor`), which is advisory and never a deposit gate. The skill whose change resolves a line ticks it in that change and appends `— done YYYY-MM-DD: <path or ID>`. An auditor's rerun reconciles only its own section against this run's verdicts: it ticks open lines whose key now passes, keeps open lines that still fail without adding a duplicate, and opens an unchecked line for every other failure, including a key whose earlier line is ticked; the ticked line stays as history, and the new line ends `— reopened YYYY-MM-DD: <earlier done date>`. A ticked line is never unticked, and the rule against duplicates applies among unchecked lines only.

### Deposit gates

A `deposit` milestone is ready only when `story-depo-packer` reports every gate below as passing, each with its evidence; nothing else declares deposit readiness.

1. `bash execs/run.sh` builds the active entry point, and `bash execs/scpts/lint.sh` reports no hard failure (so no visible `\todo`) and none of these warnings: a title-page placeholder; an unset `dissertation_language`, or a `dissertation_language` mismatch with the STORY class's options; an unparsable `max_pages`; an unchecked page limit; more than one active milestone; missing characters in the build log; an unwired chapter, meaning a chapter file the entry point does not input, unless its outline row is `retired`. Lint checks this milestone's `max_pages` only when its `Page limit:` line cites this milestone's `milestone.yml`; otherwise `story-depo-packer` compares the PDF's page count with it directly.
2. Every row of `degree/requirements.md` is checked, with its applicability and source, including format, naming, accessibility, file size, embargo, and license.
3. Every approval the confirmed degree level requires, and every fact of this milestone's `milestone.yml`, is recorded.
4. No unchecked box remains under `tasks/`, except in the advisory `tasks/prose.md`.
5. Both sections of `tasks/audits.md` record a full run dated after the last change under `manus/` and `mates/`, and no claim stated in a file the entry point builds is `unsourced`.
6. `notes/publications.md` exists, and every row that is not `excluded` is `cleared`.
7. No starter text remains: `degree/profile.tex` sets `\copyrightyear` to a confirmed four-digit year (neither `\the\year` nor absent, since the class default is `\the\year`), no shipped abstract or appendix placeholder sentence is left, every front- or back-matter file the entry point inputs has an uncommented body, and the entry point loads the class with `final`, since the class defaults to draft.
8. `git status --porcelain -- manus degree notes mates tasks miles/<slug>` is empty before the final build, so the package and the freeze name one commit.

The deposit `RECORD_<date>.md` embeds the package inventory (path, size, and SHA-256 of every file), the entry point and engine, the source commit (`git rev-parse HEAD`) and that the tree was clean, the final lint `Result:` line, and the freeze tag's name if one was made; `wkdrs/builds/deposit/<slug>/` holds only a regenerable working copy.

## 7. Interaction, language, and provenance

- **Arguments.** Every skill takes `<skill> [TARGET] [DESCRIPTION] [involve=<level>]`. It strips `involve=<level>` first — even where its `argument-hint` omits the token or it takes no other argument, and a skill matching outline rows never reads `involve=low` as a target — then resolves the target and treats the rest as the description. A free-text first argument is the description.
- **Authorization.** Background or a vague preference in a description authorizes nothing. A clear instruction to perform a specified operation within the skill's documented paths may select that path, target, and scope and authorizes that routine action, and work the author already authorized in the run is not asked for again. The description's intent and limits still bind: it may set emphasis and supply wording the run records, an explicit read-only request or limit holds, and a run never silently widens its mode, target, or scope. No description replaces a confirmation point (next item) or an `AGENTS.md` §1 ask-first choice — the thesis-wide argument, chapter boundaries, attribution, publication reuse, a degree requirement — and none settles an ambiguous target, licenses an unsourced number, or authorizes a freeze. Only a typed `story-auto` goal run authorizes more than its own run (§8, Goal runs), and it authorizes none of these either. A §1 choice is authorized only by the author's answer to that question, which then holds within its scope.
- **Involvement.** `INVOLVE=low|medium|high` sets how much unresolved judgment a skill asks about; no level creates authority. `low` takes the recommended safe option on a judgment call and says so in its report, `medium` (the default) asks as each skill documents, and `high` asks each consequential call on its own and waits. At every level, explicit approval already given stays valid for its scope, and confirmation points and §1 choices are asked. The confirmation points are: recording an institutional, degree-requirement, or milestone fact as confirmed; deleting a file or ledger row; replacing an existing file wholesale, such as a scaffold or regenerated file over author content (an in-place edit of the run's own target, or of rows and fields it owns, is not an overwrite); freezing or tagging a deposit; and any confirmation a skill names as one. Any other confirmation a skill asks for is a judgment call, and the skill says what `low` takes instead. The level resolves once, at the start of a run, from `INVOLVE` in `.env` (absent, unset, or invalid means `medium`), then the invocation's `involve=` token, then plain language during the run; the last instruction holds for the rest of the run. A hook that answers permission prompts sees neither plain language nor a run's end, so where one reads the level from the session it takes the `involve=` token of the most recent STORY command the user typed, or `.env` when that command carried none, until the next typed STORY command. Where a hook can answer the permission prompt, `low` also skips it for an edit inside the project and, where supported, for a shell command outside the red lines. A permission prompt is not a confirmation point, and a write into `mates/` (other than through `bash execs/scpts/import.sh`), `degree/`, or `miles/*/feedback/` keeps its prompt at every level.
- **Language and profile.** Resolve the language once per run: replies and newly written Markdown follow an explicit author request for what it names, else a valid `STORY_LANG=en|zh`, else the dialogue language: that of the author's latest message in their own prose, never of code, paths, commands, skill names, pasted text, file contents, tool output, or the English manifests a run loads, so a turn that is only a skill command keeps the language the conversation already has. Where the conversation has been compacted to a summary, or a sub-agent works from a task text, the language that summary or task records stands, and a run that starts a sub-agent names the resolved language in its task; with no user turn, use the invocation's language. When none of these yields a language, ask once before the run's first new Markdown artifact (at `low`, take the manuscript language and say so). Existing files keep their language, and degree level and manuscript language come only from `degree/profile.tex` (`% degree_level`, `% dissertation_language`), never from conversation wording. Text for examiners, the committee, or the institution — a committee-facing response, a defense plan, slides and speaker notes, a deposit cover note — uses the language the milestone's `milestone.yml` or `degree/requirements.md` records, else the manuscript language; before finalizing such text, the run names the language it used and asks the author to confirm it. Working records follow the resolved language. `AGENTS.md`, every `SKILL.md`, and this document are English only; a run in Chinese follows them and replies in Chinese. `STORY_MAIN` selects the build and lint entry point, and a command-line `--main` overrides it; the selected file is the active entry point, used in place of a fixed `manus/main.tex` by every skill that wires an `\input` or reads front and back matter. Neither `STORY_MAIN` nor `--main` changes the manuscript language.
- **Shared controls.** A skill reads `.env` once for the controls it needs — `INVOLVE`, `STORY_LANG`, `STORY_MAIN` — and reuses the values for the rest of the run; a later author instruction still changes level or language as above. Every skill manifest opens with a short **Shared conventions** paragraph restating these controls, the language order, and the authorization rule; this section is its source.
- **Dates and provenance.** Dated artifacts use the system date. An artifact recording model provenance (in STORY, a memory's `model_id`, §10) copies the writing session's id verbatim from the provenance line the session hook injects (§11), read in this order: a resolver command, run at the moment of the write, whose output is copied; an id stated outright, copied even though a mid-session model switch may have staled it; or nothing, and then an id the runtime's own session context states outright, else §11's fallback read tried once, and `unrecorded` only when the session names no model anywhere. Never infer the id from behavior, copy one artifact's value into another, or take a model-family description for an id. Where the session also supplies a post-write check (§11), run it once per artifact that records `model_id`, after its last write and before reporting completion or committing; a nonzero exit blocks both until the value is corrected and the check passes.
- **Ownership.** A skill edits only the files it owns and routes work when ownership changes. To route is to leave an item undone, name its owning skill in the report, and add a `tasks/` line when the item must outlive the run; routing never starts that skill (§8). Shared records are owned by row and field, as each skill's contract names: `notes/outline.md`, `notes/claims.md`, `notes/contributions.md` (`Status`, §3), `notes/publications.md` (`Candidate chapters`), and `notes/notation.md`; checkbox lines under `tasks/` (§6); and these lines of the active entry point:
  - `story-outl-planner`: the chapter `\input` lines;
  - `story-refs-curator`: the bibliography lines;
  - `story-tabs-builder` and `story-figs-designer`: `\listoftables` and `\listoffigures`, uncommented when wiring the first table or figure, unless `degree/requirements.md` excludes the list;
  - `story-chap-drafter`: the `\input` of a front- or back-matter file it first fills, placed in the order `degree/requirements.md` confirms, and, when that file is a second-language abstract the entry point cannot typeset under STORY's class, the `cjk` class option, the `% !TeX program` line, and any `% !LW recipe` line beside it (§5).

  After an author-confirmed rename, renumber, split, or merge, `story-outl-planner` rewrites every cell naming the old chapter path, and after an author-confirmed removal it drops the removed chapter's path from each claim's `Stated in` (§3, Who sets each status); either way it keeps `Chapters` in `notes/contributions.md` and `Candidate chapters` in `notes/publications.md` in step with the outline; after an author-confirmed citekey rename, `story-refs-curator` rewrites the key arguments of citation commands in `manus/`, listing each site.
- **Git and outward transfer.** A run stages only the paths it wrote, by name, and commits only when the author asks. It never amends, rebases, resets, force-pushes, deletes a remote branch, force-cleans, drops stashes, or deletes or moves a tag; only `story-depo-packer` creates a local freeze tag, after explicit confirmation. Build outputs and files over 10 MB stay out of commits. No run pushes, uploads, publishes, or submits manuscript, evidence, or package files off the machine: that is an author action. The commit guard (§11) enforces a floor of this rule.

## 8. Verification

- A run that changed `manus/` ends with `bash execs/run.sh` and, only when that succeeds, `bash execs/scpts/lint.sh --no-build`; after a failed build it reports lint as `not run (build failed)`. A run that left `manus/` unchanged but may have changed citations, references, todos, metadata, page limits, or deposit readiness runs `bash execs/scpts/lint.sh`, which builds first.
- Besides its hard failures, lint warns on a source newer than the PDF (under `--no-build`), a chapter file the entry point does not input, unresolved rows in `degree/requirements.md`, an unset `dissertation_language` or one that contradicts the options of the STORY class the entry point loads (an institutional class's language option is not checked), a page limit it could not check because the page count could not be read, and missing characters in the build log, among other warnings; §6 (Deposit gates) says which warnings block a deposit.
- A visible `\todo` fails lint by design: red lint is the normal state of a manuscript with open evidence gaps. It blocks the deposit milestone, not drafting, and is reported as a remaining gate, not an error to silence.
- Re-read each cited evidence value during the run; a remembered value or fingerprint is insufficient.
- Reports under `wkdrs/` are regenerable; durable decisions update `degree/`, `notes/`, `miles/`, or `tasks/`.
- A completion report names the built PDF, page count, lint verdict, ledger changes, and remaining gates, writing `not run` or `not applicable` for a check that does not apply rather than omitting it.

### Completion handoff

- After every completed workflow step, end the user-facing handoff with exactly one localized line beginning `Next action:` (English) or `下一步：` (Chinese); do not scatter alternatives across the report.
- A gate is a precondition of a later stage, and an unmet gate blocks that stage. Gates follow the pipeline: the degree profile; evidence (`missing` or `tampered`); the thesis story (absent, or `discovery`); the outline; chapters, tables, figures, and references, in outline order; polish; audits; the active milestone; and the deposit (§6, Deposit gates). A visible `\todo` is a gate only for the audit and deposit stages.
- Name the earliest unmet gate that can make useful progress: its owning `story-*` skill with a concrete target or exact command, spelling out `involve=<level>` when that differs from what `.env` resolves to (§7) — `story-outl-planner involve=high` — so the line works pasted as printed; at the level `.env` already gives, print the bare command. When no skill owns the needed institutional fact, attribution decision, or other author-only input, label it an author action and name the file or fact to confirm.
- The handoff is a recommendation, not authorization to start a different skill. Continue only when the request already authorizes a multi-step workflow (a typed `story-auto <goal>` is its one standing form: Goal runs, below), stating the handoff first; otherwise stop after the report. A status, explanation, audit, or review-only request authorizes only that deliverable: it ends there and never starts a writing successor, whatever the handoff recommends. Thesis-wide argument, chapter-boundary, attribution, publication-reuse, milestone, and degree-requirement choices still need the author's answer (§7 confirmation points; `AGENTS.md` §1).
- When the requested workflow is complete and no applicable gate remains anywhere in the pipeline (completing the request clears none of them), write `Next action: none — the requested workflow is complete.` (in Chinese, `下一步：无——请求的工作流已完成。`) instead of inventing work. A blocked or failed step still gives one next action: the concrete action most likely to clear the block.

### Goal runs

`story-auto <goal> [involve=<level>]` is a command, not a skill: the one standing authorization for a multi-step workflow. Its procedure, [`.agents/commands/story-auto.md`](../../../.agents/commands/story-auto.md), defines how it picks each step toward the goal, turns the goal into a check on repository state, and when it stops; §11 gives each harness's spelling. The grant's limits:

- It starts only unmarked skills of §9, one unit of work per start, each as if the author had typed it, at the goal run's `involve=` level, else `INVOLVE` in `.env` (§7), raised to the level a handoff line spells out when that one asks more, and never lowered by one. It never starts a skill marked †: a † skill, an author action, or an action outside the grant ends the run, with that exact command or action as its `Next action:`.
- Every confirmation point of §7 and every ask-first choice of `AGENTS.md` §1 is still asked at every level; the run never answers one itself and stops where nobody can.
- It never imports, registers, or refreshes evidence, writes `degree/`, writes or edits received feedback under `miles/*/feedback/`, declares a deposit ready, commits, pushes, tags, or launches or waits on background work, and green lint is never its goal.

## 9. Skill roster

Skills marked † are explicit-only: they change thesis-wide structure, milestone handling, or institutional packaging and run only when the author directly chooses them. A goal run never starts one (§8), and §11 says how each harness enforces this.

| Skill | Owns |
| --- | --- |
| `story-proj-adopt` † | Safe adoption of existing drafts |
| `story-evid-curator` | Evidence import, registration, integrity |
| `story-syns-coach` † | Thesis-level research arc and contribution framing |
| `story-outl-planner` † | Chapter architecture and briefs |
| `story-chap-drafter` | One chapter or front/back-matter file per run |
| `story-tabs-builder` | Evidence-backed tables |
| `story-figs-designer` | Evidence-backed figures and editable sources |
| `story-refs-curator` | Bibliography and reading notes |
| `story-copy-editor` | Authorial voice, natural scholarly prose, terminology, flow, and consistency |
| `story-clms-auditor` | Quantitative and claim traceability audit |
| `story-cite-auditor` | Citation-key and literature-assertion audit |
| `story-exam-reviewer` | Mock examiner or committee review |
| `story-revs-resolver` † | Feedback point ledger and dispositions |
| `story-defn-builder` † | Defense narrative and deck |
| `story-depo-packer` † | Deposit preflight, package, and freeze record |
| `story-flow-status` | Read-only status and next action |

## 10. Project memory

`.story/memory/` holds what a session learned that no repository file owns, one fact per file, and reaches later sessions as an index a session hook builds from the files' frontmatter. Evidence, claims, institutional requirements, publication reuse, feedback, and promises already have owners (§1, §2); memory is the residue, a navigation aid that is never evidence and yields to any repository file it contradicts. `AGENTS.md` §8 says when a memory is offered and when `INVOLVE=low` records one unasked. The types are `env`, a machine or TeX-toolchain fact and the one type that ages; `pref`, a standing author workflow preference; `insight`, a reusable project judgment; and `deadend`, an approach tried and rejected.

**Where it lives.** `.story/memory/<slug>.md` is versioned and travels with a clone; the STORY template ships only `.story/memory/.gitkeep`. The git-ignored `.story/memory/local/<slug>.md` holds a `machine:` scoped fact and any memory the author keeps off the repository, whatever its scope: the split follows where a fact travels, not where it holds.

**The file.** A frontmatter block between bare `---` lines, with lowercase English keys: `type`; `scope` (`global`, `machine:<name>`, `milestone:<slug>`, or `manus:<path>`); `summary`, required because it is the index line, stating what the fact *is* ("biber is missing here; the bibliography builds only with bibtex") rather than what it is about; `language`, `en` or `zh`, the language of the summary and body as §7 resolved it; `verified`, the system date it was last confirmed; `model_id` (§7); `source`, the originating artifact or `conversation`; and an optional `supersedes`. The body states the fact in one sentence, then why it matters and how to apply it. A memory takes no translated twin.

**The index.** Nothing is hand-written. The hook lists every `<slug>.md` in both directories, newest `verified` first, the versioned store before `local/`, and nothing for an empty store:

    - <type> · <scope> · <verified> · [<slug>](<slug>.md) — <summary>

Frontmatter is read literally: an unclosed block or a CRLF file is not listed, values keep any quotes (a quoted `verified` date still ages and sorts as the date it quotes), a file without `summary` is listed by its first body line, and an `env` memory (by its type token, whatever the summary's language) whose `verified` date is more than 180 days old is marked stale; other types never age. Every copy of the hook prints the same lines as plain text with `--list` (§11). Open the file before relying on a line, and past roughly 60 memories retire rather than accumulate. An earlier release's hand-written `MEMORY.md` indexes are no longer read and its `<slug>.zh-CN.md` twins list as second memories: the author carries each index line into its memory's `summary`, folds each twin into its English file, and deletes the old files; no skill deletes a twin (§1). A run that finds an old index or twin names these steps as an author action (§8, Completion handoff) instead of offering to perform any of them, and `execs/update.sh` reports the files until then and deletes none.

**Retiring.** Re-verified: set `verified` to today and `model_id` to the checking model. Superseded: write the new memory with `supersedes: <old-slug>` and delete the old file. Wrong: delete it. A deletion is confirmed with the author at every involve level (§7).

## 11. Harness adapters

This is the one section of this file that names a harness: everything above holds for all of them, and a manifest implements it without changing scope, authority, or artifact ownership.

### Invocation and tags

| Harness | Tag | Skill | Router | Goal run (§8) |
| --- | --- | --- | --- | --- |
| Claude Code | `claude` | `/story-<name>` | `/story` | `/story-auto` |
| Codex | `codex` | `$story-<name>` | `$story`, from the repository's `story` plugin | `$story-auto`, from the same plugin |
| Cursor | `cursor` | `/story-<name>` | `/story` | `/story-auto` |
| DeepSeek Harness (DSH) | `dsh` | `/skill:story-<name>` | `/story`, from `.dsh/commands/story` | `/story-auto`, from the same package |
| Kimi Code | `kimi` | `/skill:story-<name>` | `/story`, from `.kimi-code/plugins/story` | `/story-auto` (`/skill:story-auto`), from the same plugin |
| Pi | `pi` | `/story-<name>`, a prompt template | `/story` | `/story-auto`, a prompt template |
| Qwen Code | `qwen` | `/story-<name>` | `/story` | `/story-auto` |

The tag is what `STORY_HARNESSES` and `execs/update.sh --harnesses` take; `kimi` owns `.kimi-code/`. The explicit-only skills of §9 carry `allow_implicit_invocation: false` in Codex's `.codex/skills/<name>/agents/openai.yaml` (linked from `.agents/skills/<name>/agents/openai.yaml`) and `disable-model-invocation: true` in every other tree's generated `SKILL.md`. The neutral `.agents/skills/<name>/SKILL.md` cannot carry that key, since Codex validates that root: Pi excludes the root in `.pi/settings.json`, but Cursor also discovers `.agents/skills/` and can surface that unguarded copy, so in Cursor the always-apply rule `.cursor/rules/skill-roots.mdc` enforces † as well. The goal run starts only when typed: Claude Code's command sets `disable-model-invocation: true`, the Codex plugin's `story-auto` skill `allow_implicit_invocation: false`, and the Kimi plugin `disableModelInvocation: true`, while Cursor, DSH, Pi, and Qwen Code run a command only when it is typed. Codex and Kimi Code copy their plugin when it is installed, so an installed copy gains a new entry, such as `story-auto`, only after the plugin is installed again. Only Claude Code and Qwen Code show a skill's `argument-hint`, and Pi reads it from the skill's prompt template under `.pi/prompts/`; only Claude Code reads `effort:`, which its copy of `story-flow-status` alone sets (`effort: medium`).

### Hooks and model provenance

Each tree's `hooks/` directory (Pi: `.pi/extensions/story-hooks/`) holds `story_model_id.sh`, which injects the provenance line §7 reads, `story_memory.sh` (§10), and `story_commit_guard.sh`, which runs before a shell command: on `PreToolUse` in Claude Code, Codex, DSH, Kimi Code, and Qwen Code, on `beforeShellExecution` in Cursor, and on `tool_call` in Pi. Claude Code, Codex, and Qwen Code add `story_involve_gate.sh`, which answers the edit permission prompt at `INVOLVE=low` (§7); Claude Code alone adds `story_bash_gate.sh` for its shell prompt and `story_involve_level.sh`, which gives both gates the `involve=` token of the session's latest typed STORY command. The memory hook fires on the provenance hook's event, except in Codex, where it takes every `SessionStart` source, `/clear` included, and the provenance hook only `startup` and `resume`.

| Harness | Registered in | Provenance event → what it injects → when the id is read |
| --- | --- | --- |
| Claude Code | `.claude/settings.json` | `SessionStart` → a `--resolve` command over the transcript, or the id when no transcript is named → as you write |
| Codex | `.codex/hooks.json`, active once approved with `/hooks` | `SessionStart` (`startup`, `resume`) → the exact `session_model_id`, a `--resolve` command over the rollout, and the `--check` command → as you write, then after |
| Cursor | `.cursor/hooks.json` | `sessionStart` → the id → at session start |
| DSH | `.dsh/hooks.json`, enabled by `bash .dsh/hooks/install.sh` and the per-profile hooks bridge | `SessionStart` via the bridge → a `--resolve` command over the session log (`zstd` on PATH when it is compressed) → as you write |
| Kimi Code | the global `config.toml`, once per machine: `bash .kimi-code/hooks/install.sh` writes the entries `.kimi-code/hooks.example.toml` shows | `UserPromptSubmit` → `default_model` from `~/.kimi-code/config.toml` → from config, never the session |
| Pi | `.pi/extensions/story-hooks/index.ts`, once the project is trusted | `before_agent_start`, again after `model_select` → the live provider/model id → at the prompt that uses it |
| Qwen Code | `.qwen/settings.json` | as Claude Code |

Claude Code, Cursor, and Qwen Code load their registration automatically. `execs/update.sh` keeps a thesis's own registration files and names any STORY hook they do not register, to be added by hand. An id read as you write cannot be stale; Cursor's and Kimi's can, because a mid-session model switch changes nothing they read, while Pi's latest line names the writing model.

Run a resolver from the project root exactly as the injected line quotes it — `bash .claude/hooks/story_model_id.sh --resolve <transcript_path> [session_model]`, the same under `.codex/hooks/` and `.qwen/hooks/`, or `bash .dsh/hooks/story_model_id.sh --resolve [transcript_path]` — and copy its output; `.claude/settings.json` pre-allows the Claude Code command. The Claude Code and Codex resolvers read the runtime's per-turn record and keep the session-start id only when it names the same model, for the suffix the record drops (`claude-opus-5[1m]` over `claude-opus-5`); Qwen Code's prints the transcript's id whenever it has one, and DSH's reads `DSH_SESSION_JSONL` when no path is given and takes no session model. A Claude Code delegate resolves its own transcript under `subagents/`, with no session model; STORY registers no `SubagentStart` hook, because no skill dispatches a delegate that records `model_id`. Claude Code also states the model in its system prompt, so a Claude session without a hook line still names one. Kimi's line does not reach a skill opened by slash command before any plain user message, so read the value once before writing `unrecorded`:

```bash
grep -E '^[[:space:]]*default_model[[:space:]]*=' "${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
```

Codex supplies §7's post-write check: `bash .codex/hooks/story_model_id.sh --check <artifact> <rollout> <session_model>` compares the artifact's `model_id` with the output of `--resolve <rollout> <session_model>`, else `unrecorded`, and exits nonzero on a mismatch. `bash .claude/hooks/story_memory.sh --list`, or the same under any other tree's hook directory, prints the §10 index.
