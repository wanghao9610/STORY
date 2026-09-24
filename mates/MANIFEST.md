# Evidence manifest

Every file under `mates/` requires one `## <relative-path>` entry with the lines `- source-type:`, `- source:`, `- source-commit:` (`n/a` when the source has none), `- sha256:`, `- imported:`, and `- covers:`. A manual registration uses `source-type: manual` and adds `- owner:` (the person or group that produced the file) and `- created:` (its original date, `YYYY-MM-DD`, or `unknown` only when the author confirms no date exists). Files without an entry are not evidence.

<!-- Entries are managed by execs/scpts/import.sh and story-evid-curator. -->
