---
name: story-evid-curator
description: Use when thesis evidence under mates/ must be imported, registered, refreshed, or integrity-checked with provenance and fingerprints, from STAR/STAGE/STORY sources or manual research artifacts. Never edits evidence in place and never writes the claim ledger.
argument-hint: "[check | import source=PATH [slug=NAME] | register path=FILE...] [DESCRIPTION] [involve=LEVEL]"
---

# Curate thesis evidence

**Shared conventions.** Read `docs/mds/story-workflow/writing-workflow-conventions.md` in full before acting. Read `.env` once for the `STORY_LANG`, `INVOLVE`, and `STORY_MAIN` values this run needs, and reuse them. Resolve the language of replies and new Markdown under conventions §7: an explicit author request first, then a valid `STORY_LANG`, then the dialogue language, or the invocation language when there is no user turn. Manuscript prose follows `degree/profile.tex`, and an existing file keeps its language. A clear instruction may select the target and scope and authorize the corresponding action within this skill's documented paths, and work already authorized in this run is not asked for again; it never replaces a confirmation point or an `AGENTS.md` §1 ask-first choice (conventions §7).

Choose one mode:

- `check` (default, read-only): recompute every SHA-256 and report each file's conventions §3 integrity verdict, by the rules the status scan's `integrity:` line applies. For each imported slug whose source is reachable, run `bash execs/scpts/import.sh --diff --source <dir> --slug <slug>` and read its exit code as §3 does; `<dir>` is the entry's `- source:` minus the file's path under `mates/<slug>/` (`## proj/results/a.csv` with `- source: /work/proj/results/a.csv` gives `/work/proj`).
- `import source=<path> [slug=<name>]`: run `bash execs/scpts/import.sh --source <path> [--slug <name>]` on a STAR, STAGE, STORY, or structured evidence repository; the same slug refreshes it. When the author wants, replace the placeholder `covers: imported graduate-research evidence` with what the file can support; a re-import keeps a curated `covers:`, so re-confirm it when a refresh changes that entry's SHA-256.
- `register path=<file>...`: copy user-supplied artifacts into `mates/manual/` after one batch confirmation of each file's origin, owner, creation date, and coverage, asked at every involve level because owner is attribution (`AGENTS.md` §1).

A manifest entry is `## <path under mates/>` with `- source-type:`, `- source:`, `- source-commit:` (`n/a` when the source has none), `- sha256:`, `- imported:` (the system date), and `- covers:`. A `register` entry uses `source-type: manual` and the origin as `source:`, and adds `- owner:` (the person or group that produced it) and `- created:` (`YYYY-MM-DD`, or `unknown` only when the author confirms no date exists). `covers:` is not evidence for a claim: drafting skills must still read the file.

Never repair content under `mates/` (conventions §2), and never edit manuscript prose or `notes/claims.md`. When a refresh or registration changes an existing entry's SHA-256, hand every claim whose `Evidence` cell or `% src:` anchor names that path to `story-clms-auditor` as one comma-separated list, such as `story-clms-auditor C003,C007` (conventions §3); when the import log reports a seeded `manus/bibs/reference.bib`, hand it to `story-refs-curator reconcile`. The `Next action:` names the earlier of these gates (conventions §8, Completion handoff). Tick any `tasks/` line this change resolves (conventions §6).
