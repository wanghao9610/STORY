# Route a STORY request

Use the roster below to route a master's or doctoral thesis request to exactly one workflow skill. Degree-aware skills read `% degree_level: master|doctoral` from `degree/profile.tex`; the router never guesses it.

| Skill | | Purpose |
| --- | --- | --- |
| `story-chap-drafter` | | Draft or revise what one chapter or one front/back-matter file says, including where `\cite` goes, in the author's scholarly voice |
| `story-cite-auditor` | | Audit citation keys, literature assertions, and bibliography hygiene |
| `story-clms-auditor` | | Audit numbers, comparisons, degree contributions, and source anchors; first stop for a suspected wrong number |
| `story-copy-editor` | | Polish how one chapter, one front/back-matter file, or the whole thesis (`full`) reads — voice, terminology, transitions, formulaic prose — without changing facts, claims, or citations; record the author's style profile (`style`) |
| `story-defn-builder` | † | Build a defense narrative and deck from confirmed rules and claims |
| `story-depo-packer` | † | Preflight and freeze a named deposit package |
| `story-evid-curator` | | Import, register, refresh, or integrity-check evidence |
| `story-exam-reviewer` | | Simulate a degree-appropriate examiner or committee review |
| `story-figs-designer` | | Build one evidence-backed thesis figure |
| `story-flow-status` | | Report repository status and exactly one next action |
| `story-outl-planner` | † | Turn the confirmed story into chapter architecture and briefs |
| `story-proj-adopt` | † | Safely adopt an existing master's or doctoral thesis draft |
| `story-refs-curator` | | Curate bibliography records and reading notes; placing `\cite` in prose belongs to `story-chap-drafter` |
| `story-revs-resolver` | † | Turn received feedback into dispositions and tracked promises |
| `story-syns-coach` | † | Confirm or revise the thesis-wide argument and contribution framing, or record a publication reuse or permission fact |
| `story-tabs-builder` | | Build one evidence-backed thesis table |

The six skills marked † are explicit-only because each controls an author-owned thesis-wide, milestone, or institutional decision. This generic `/story` router never starts one and never asks whether to start it. Instead, name it, give its one-line reason and the exact `/story-<name> <argument>` command for the author to type (with `involve=<level>` spelled out when you recommend a level other than the one `INVOLVE` in `.env` resolves to, conventions §8), and stop. The other ten may be selected when the request plainly matches.

A request to pursue a goal across several steps, running whatever the thesis needs next until something is reached, is not routed to one skill: give the exact `/story-auto <goal>` command and stop. Typing it is the one standing authorization for a multi-step run (conventions §8, Goal runs), and even then a skill marked † is never started: the goal run stops at it and prints its command.

If the request is empty, select `story-flow-status`. If it is an author action no skill owns, such as a confirmed fact in `degree/` (`degree_level`, a committee row), label it an author action (conventions §8, Completion handoff), name the file and field, and stop. Otherwise, name the chosen skill, give the one-line reason, and pass through the request as its argument. Start an unmarked skill through the active harness's native skill mechanism and use that harness's owned copy. If two skills are equally plausible, ask one concise question instead of blending their scopes. A request that needs two owners in sequence, and is not a goal pursuit, goes to the first; its handoff names the second. Never bypass a skill by producing its owned artifact from general knowledge.

A status, explanation, audit, or review-only request authorizes only that deliverable. Preserve it through routing: do not start drafting, editing, imports, or another writing successor merely because a report recommends one. Explicit authorization the author already gave stays valid within its stated scope and is not asked for again, while the ask-first choices of `AGENTS.md` §1 are asked at every involve level: only the author's answer to that question authorizes one, never the wording of the request (conventions §7 and §8).
