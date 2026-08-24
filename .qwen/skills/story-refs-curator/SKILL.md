---
name: story-refs-curator
description: Add, verify, deduplicate, read, and organize master's or doctoral thesis references using fetched bibliographic records and reading notes; use when bibliography entries or literature assertions need trustworthy source records.
argument-hint: "PAPER... [DESCRIPTION] [involve=low]"
---

# Curate references and reading notes

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

For each work, fetch an authoritative record during the run using a DOI, arXiv ID, stable URL, or exact title. Transcribe fields into `manus/bibs/reference.bib`; never reconstruct metadata from memory. Keep provenance in a `% src:` line and normalize citekeys without silently breaking manuscript references.

Create or update `notes/refs/<key>.md` with the research question, method, evidence, findings, limitations, and short citable facts that were actually checked. Immediately before adding the first verified work, if `notes/refs/refs_index.md` is absent, create it with `Bibkey | Work | Reading note | Used in chapters | Verification status`. Use the verification values in conventions §3: set `metadata-verified` only after fetching an authoritative identity record, and set `content-verified` only after checking the source itself and completing the reading note. Do not create an empty index during a discovery-only run that adds nothing. Create paired `*.zh-CN.md` artifacts in the same change. Update an existing index without replacing its content.

When discovering literature, propose candidates before adding them. Distinguish bibliographic verification from endorsement, and primary sources from surveys. Route unsupported manuscript assertions to `story-cite-auditor` or `story-chap-drafter` rather than patching them opportunistically.
