---
name: story-chap-drafter
description: Draft or revise exactly one master's or doctoral thesis chapter from its confirmed brief, thesis story, contribution/publication maps, claim ledger, reading notes, and fingerprinted evidence; use for chapter-level prose rather than thesis-wide restructuring.
---

# Draft one evidence-bound chapter

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first. Resolve the target by chapter number, slug, or unique title in `notes/outline.md`; ask when it is absent or ambiguous.

Before writing, load the chapter brief, `notes/story.md`, linked contribution and publication rows, linked claim rows, relevant reading notes, and every evidence file needed in this run.

Write one sentence per source line. Keep the chapter's local argument connected to the thesis's central argument. Adapt paper material into a consistent thesis voice; preserve coauthor attribution and do not copy substantial published wording before its reuse row is resolved.

Every quantitative or comparative sentence gets a nearby `% src:` anchor. Missing support becomes `\todo{...}`. Update `notes/claims.md`, `notes/notation.md`, and the chapter status in `notes/outline.md` in the same change.

End with `bash execs/run.sh` and, when claims or citations changed, `bash execs/scpts/lint.sh`. Do not alter evidence, institutional facts, or other chapter scopes.
