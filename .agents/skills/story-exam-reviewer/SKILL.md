---
name: story-exam-reviewer
description: Use when a built thesis needs a mock examiner or committee review. Simulates a degree-appropriate examination of coherence, contributions, methods, evidence, literature, attribution, limitations, and presentation, and writes a report without editing the manuscript. For claim traceability, use story-clms-auditor; for citations, story-cite-auditor.
---

# Run a degree-appropriate mock examination

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

1. Resolve the degree level (conventions §1) and the milestone: the one the invocation names (none if it does not exist); without a name, the active one (conventions §6), else none.
2. Build the active entry point with `bash execs/run.sh`.
3. Model the examiners on the `Confirmed: yes` roles in `degree/committee.md`, and take the rubric only from the milestone's `requirements_source`; label any role you add, or the level-appropriate generic rubric used instead, as assumed.
4. Evaluate whether:
   - the central thesis is clear and sustained;
   - contributions meet the confirmed level's scope, significance, evidence, and attribution standard (conventions §1): a doctorate's required original contribution and cross-study synthesis, or the required mastery and research competence of a master's bounded contribution;
   - with reused publications, the research chapters form one thesis, not a bound paper collection; an `Inclusion: as-published` chapter (conventions §5) is judged by its preface, its linking text, and the synthesis in the introduction and conclusion, not the absence of a rewrite;
   - the methodology is sound and the work reproducible;
   - the thesis commands the literature and positions the work accurately;
   - the synthesis, limitations, and generalization boundaries fit the degree level;
   - the presentation holds up under the human-writing contract (conventions §5).
5. Write an executive verdict, major and minor concerns, required clarifications, the claim and contribution IDs attacked, and a defense bank of likely oral-examination questions to `milestones/<slug>/simulations/SIM_EXAM_<date>.md`. With no milestone, write `wkdrs/reports/SIM_EXAM_<date>.md` and say it is regenerable and untracked; to keep it, the author asks `story-revs-resolver` to copy it unchanged into a milestone's `simulations/`.

Never create a milestone, write into `feedback/` (conventions §6), or edit the manuscript or the claim ledger.
