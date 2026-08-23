# Route a STORY request

Use the roster below to route a dissertation request to exactly one workflow skill.

| Skill | | Purpose |
| --- | --- | --- |
| `story-chap-drafter` | | Draft or revise one evidence-bound chapter |
| `story-cite-auditor` | | Audit citation keys, literature assertions, and bibliography hygiene |
| `story-clms-auditor` | | Audit numbers, comparisons, contributions, and source anchors |
| `story-copy-editor` | | Edit voice, terminology, transitions, and consistency without changing claims |
| `story-defn-builder` | † | Build a defense narrative and deck from confirmed rules and claims |
| `story-depo-packer` | † | Preflight and freeze a named deposit package |
| `story-evid-curator` | | Import, register, refresh, or integrity-check evidence |
| `story-exam-reviewer` | | Simulate an examiner or committee review |
| `story-figs-designer` | | Build one evidence-backed dissertation figure |
| `story-flow-status` | | Report repository status and exactly one next action |
| `story-outl-planner` | † | Turn the confirmed story into chapter architecture and briefs |
| `story-proj-adopt` | † | Safely adopt an existing dissertation or thesis draft |
| `story-refs-curator` | | Curate bibliography records and reading notes |
| `story-revs-resolver` | † | Turn received feedback into dispositions and tracked promises |
| `story-syns-coach` | † | Confirm or revise the thesis-wide argument and contribution framing |
| `story-tabs-builder` | | Build one evidence-backed dissertation table |

The six skills marked † are explicit-only because each controls an author-owned thesis-wide, milestone, or institutional decision. This generic `/story` router never starts one: ask for explicit confirmation, give the exact `/story-<name> <argument>` command, and wait. The other ten may be selected when the request plainly matches.

If the request is empty, select `story-flow-status`. Otherwise, name the chosen skill, give the one-line reason, and pass through the request as its argument. Start an unmarked skill through the active harness's native skill mechanism and use that harness's owned copy. If two skills are equally plausible, ask one concise question instead of blending their scopes. Never bypass a skill by producing its owned artifact from general knowledge.
