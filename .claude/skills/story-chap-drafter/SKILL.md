---
name: story-chap-drafter
description: Draft or revise exactly one master's or doctoral thesis chapter from its confirmed brief, thesis story, contribution/publication maps, claim ledger, reading notes, fingerprinted evidence, and authorial style; use for chapter-level prose rather than thesis-wide restructuring.
argument-hint: "CHAPTER [DESCRIPTION] [involve=low]"
---

# Draft one evidence-bound chapter

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. Resolve the target by chapter number, slug, or unique title in `notes/outline.md`; ask when it is absent or ambiguous.

Before writing, load the chapter brief, `notes/story.md`, linked contribution and publication rows, linked claim rows, relevant reading notes, every evidence file needed in this run, and `notes/style.md` where present. Read `docs/mds/story-workflow/human-writing-guide.md` before drafting prose; a missing style profile is not a blocker.

Write one sentence per source line. Keep the chapter's local argument connected to the thesis's central argument. Lead with the substantive point, use stable technical terms, and let sentence and paragraph rhythm follow the reasoning rather than a repeated template. Adapt paper material into a consistent thesis voice; preserve coauthor attribution and do not copy substantial published wording before its reuse row is resolved.

Every quantitative or comparative sentence gets a nearby `% src:` anchor. Missing support becomes `\todo{...}`. Update `notes/claims.md`, `notes/notation.md`, and the chapter status in `notes/outline.md` in the same change.

Before delivery, review the draft at paragraph scale using the human-writing guide. Remove unsupported significance, vague attribution, stock signposting, terminology cycling, and repeated paragraph shapes without adding detail or personality. Compare the revision with its source material and restore any changed number, citation, source comment, claim boundary, technical distinction, uncertainty, or attribution.

End with `bash execs/run.sh` and, when claims or citations changed, `bash execs/scpts/lint.sh`. Do not alter evidence, institutional facts, or other chapter scopes.
