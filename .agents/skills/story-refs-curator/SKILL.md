---
name: story-refs-curator
description: Add, verify, deduplicate, read, and organize dissertation references using fetched bibliographic records and reading notes; use when bibliography entries or literature assertions need trustworthy source records.
---

# Curate references and reading notes

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

For each work, fetch an authoritative record during the run using a DOI, arXiv ID, stable URL, or exact title. Transcribe fields into `manus/bibs/reference.bib`; never reconstruct metadata from memory. Keep provenance in a `% src:` line and normalize citekeys without silently breaking manuscript references.

Create or update `notes/refs/<key>.md` with the research question, method, evidence, findings, limitations, and short citable facts that were actually checked. Immediately before adding the first verified work, create `notes/refs/refs_index.md` when absent with `Bibkey | Work | Reading note | Used in chapters | Verification status`; do not create an empty index during a discovery-only run that adds nothing. Create paired `*.zh-CN.md` artifacts in the same change. Update an existing index without replacing its content.

When discovering literature, propose candidates before adding them. Distinguish bibliographic verification from endorsement and distinguish primary sources from surveys. Route unsupported manuscript assertions to `story-cite-auditor` or `story-chap-drafter` rather than patching them opportunistically.
