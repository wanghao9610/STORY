---
name: story-exam-reviewer
description: Simulate a degree-appropriate examiner or committee review of a built master's thesis or doctoral dissertation, evaluating coherence, contributions, methods, evidence, literature, attribution, limitations, and defense readiness, without editing the manuscript.
argument-hint: "[MILESTONE] [DESCRIPTION]"
---

# Run a degree-appropriate mock examination

Read `docs/mds/story-workflow/writing-workflow-conventions.md` and `docs/mds/story-workflow/human-writing-guide.md` first. Resolve the degree level and the active or named milestone that applies to it, then build the thesis before reviewing it. If the institution supplies an examiner rubric, use only the confirmed copy; otherwise, label the level-appropriate generic rubric as simulated.

Evaluate:

- whether the central thesis is clear and sustained;
- whether contributions meet the confirmed level's scope, significance, evidence, and attribution standard;
- in doctoral mode, whether the thesis establishes the required original contribution and cross-study synthesis;
- in master mode, whether the bounded contribution demonstrates the required mastery and research competence, without assuming publications, multiple studies, or field-level originality;
- when publications are reused, whether research chapters form one thesis rather than a bound paper collection;
- whether the methodology is sound and the work reproducible;
- whether the thesis shows command of the literature and positions the work accurately;
- whether the synthesis, limitations, and generalization boundaries fit the degree level;
- whether the presentation holds up, including unsupported significance, vague attribution, repeated chapter or paragraph templates, generic outlook language, terminology cycling, and chatbot residue, all judged as pattern clusters rather than proof of AI authorship;
- which questions are likely in the oral examination.

Write `milestones/<slug>/feedback/SIM_EXAM_<date>.md` with an executive verdict, major concerns, minor concerns, required clarifications, the claim/contribution IDs attacked, and a defense question bank. Never edit the manuscript or the claim ledger in this skill.
