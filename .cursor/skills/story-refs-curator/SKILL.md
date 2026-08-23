---
name: story-refs-curator
description: Add, verify, deduplicate, read, and organize dissertation references using fetched bibliographic records and reading notes; use when bibliography entries or literature assertions need trustworthy source records.
---

# Curate references and reading notes

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

For each work, fetch an authoritative record during the run using a DOI, arXiv ID, stable URL, or exact title. Transcribe fields into `manus/bibs/reference.bib`; never reconstruct metadata from memory. Keep provenance in a `% src:` line and normalize citekeys without silently breaking manuscript references.

Create or update `notes/refs/<key>.md` with the research question, method, evidence, findings, limitations, and short citable facts that were actually checked. Update `notes/refs/refs_index.md` with chapter use and verification status.

When discovering literature, propose candidates before adding them. Distinguish bibliographic verification from endorsement and distinguish primary sources from surveys. Route unsupported manuscript assertions to `story-cite-auditor` or `story-chap-drafter` rather than patching them opportunistically.
