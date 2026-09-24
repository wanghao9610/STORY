---
name: story-defn-builder
disable-model-invocation: true
description: Use for an applicable pre-defense or final defense. Plans, builds, and checks the thesis defense narrative, an editable slide deck, and a question bank from `verified` thesis claims, registered evidence, and confirmed timing and rules. For a mock examination report, use story-exam-reviewer.
argument-hint: "[MILESTONE] [DESCRIPTION] [involve=LEVEL]"
---

# Build the degree defense

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Resolve the degree level and the milestone: the one the invocation names, else the active one, when it is a `pre-defense` or `defense` milestone the confirmed program requires; otherwise ask. Create a missing `milestone.yml` or change its status only per conventions §6 (Milestone lifecycle). Timing, required sections, aspect ratio, deck format, and submission rules come only from `milestone.yml` or the author; an official template only from the author's copy in `template/`; the rubric only from the milestone's `requirements_source`; and the audience from the milestone and the `Confirmed: yes` rows of `degree/committee.md`. Label any other audience or rubric as assumed.

1. Write a defense plan under `miles/<slug>/materials/`: audience, one central message, timing budget, degree-appropriate contribution sequence, evidence for each major slide, transitions, limitations, and closing claims.
2. Keep the editable deck source at `materials/deck.<ext>`. Build a LaTeX deck with `bash execs/run.sh --main miles/<slug>/materials/deck.tex` (into a self-ignoring `.build/` beside it) and report its slide count against the timing budget; for another format, report the build as `not applicable` (conventions §8) and name the exported file checked.
3. Trace every numeric or comparative slide claim to a `verified` claim and its registered evidence (conventions §2); report any other as a defense risk, not a slide. Reuse a thesis figure or table only if it stays legible in presentation conditions; a slide may simplify or redraw it but keeps every value, scale, baseline, and comparison of its evidence.
4. Cover methods, assumptions, ablations where applicable, limitations, attribution, and future work in an appendix or question bank, then check timing, type size, contrast, source visibility, and consistency with the thesis and the rubric.

Plan, slides, and speaker notes are committee-facing text (conventions §7). Write only under `miles/<slug>/`, and report unresolved defense risks explicitly.
