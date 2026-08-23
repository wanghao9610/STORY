# STORY workflow skills

**Language:** English | [简体中文](writing-workflow-skills.zh-CN.md)

The skills form a dissertation pipeline rather than a rigid sequence. Use the smallest skill that owns the requested artifact.

```mermaid
flowchart LR
  A[Adopt or initialize] --> E[Curate evidence]
  E --> S[Shape synthesis]
  S --> O[Plan chapters]
  O --> D[Draft chapters]
  D --> V[Build figures and tables]
  D --> R[Curate references]
  V --> P[Polish]
  R --> P
  P --> Q[Audit claims and citations]
  Q --> X[Mock examination]
  X --> F[Resolve feedback]
  F --> B[Build defense]
  B --> Z[Pack deposit]
```

| Skill | Use it when | Primary output |
| --- | --- | --- |
| `story-proj-adopt` | An existing thesis or Overleaf export must enter STORY | `notes/adopt.md` and mapped sources |
| `story-evid-curator` | Evidence must be imported, registered, refreshed, or checked | `mates/` and `mates/MANIFEST.md` |
| `story-syns-coach` | The thesis-level problem, argument, questions, or contributions are unclear | `notes/story.md`, `notes/contributions.md` |
| `story-outl-planner` | The research arc must become a chapter plan | `notes/outline.md`, chapter scaffolds |
| `story-chap-drafter` | One chapter needs drafting or evidence-bound revision | one `manus/chaps/*.tex` file and ledger updates |
| `story-tabs-builder` | A table must be generated from registered evidence | `manus/tabs/*.tex` |
| `story-figs-designer` | A figure and editable source must be planned or built | `manus/figs/` and `manus/figs/srcs/` |
| `story-refs-curator` | A source must be added, verified, read, or positioned | bibliography and `notes/refs/` |
| `story-copy-editor` | Voice, terminology, transitions, or repetition need polishing | manuscript edits and a report |
| `story-clms-auditor` | Numbers and contribution claims need traceability checks | claim verdicts and tasks |
| `story-cite-auditor` | Citation keys or literature assertions need checking | citation report and tasks |
| `story-exam-reviewer` | The dissertation needs a realistic mock examination | milestone review file |
| `story-revs-resolver` | Supervisor, committee, examiner, or deposit feedback arrived | point ledger, responses, promises |
| `story-defn-builder` | The defense narrative or deck needs preparation | defense plan and deck artifacts |
| `story-depo-packer` | A final package needs preflight and a freeze record | deposit bundle and record |
| `story-flow-status` | The next action is unclear | read-only status summary |

Every skill first reads [writing-workflow-conventions.md](writing-workflow-conventions.md).
