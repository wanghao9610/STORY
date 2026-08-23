---
name: story-evid-curator
description: Import, register, refresh, and integrity-check dissertation evidence under mates/ with provenance and fingerprints; use for STAR/STAGE/STORY sources or manual research artifacts, never for editing evidence in place.
---

# Curate dissertation evidence

Read `docs/mds/story-workflow/writing-workflow-conventions.md` first.

Choose one mode:

- `check` (default): reconcile every `mates/MANIFEST.md` entry with disk and report `ok`, `unregistered`, `missing`, `tampered`, or `stale`.
- `import source=<path> [slug=<name>]`: run `bash execs/scpts/import.sh` for a STAR, STAGE, STORY, or structured evidence repository.
- `register path=<file>`: copy a user-supplied artifact into `mates/manual/` only after its origin, author/owner, date, and coverage are known.

For each registered file, record source type, source path or record, source commit when available, SHA-256, import date from the system clock, and what the file can support. A description of what a file covers is not evidence for a claim; drafting skills must still read the file.

Never repair content under `mates/`. Identify the upstream correction or register a new corrected artifact. Update no manuscript prose in this skill.
