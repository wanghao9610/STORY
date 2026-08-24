# Clear writing in an evidence-bound thesis

**Language:** English | [简体中文](human-writing-guide.zh-CN.md)

This guide applies shared checks for formulaic writing to master's and doctoral thesis prose.
The goal is clear, natural scholarship in the author's voice, not authorship detection or detector evasion.
The evidence, citation, attribution, and claim rules in the [writing workflow conventions](writing-workflow-conventions.md) remain authoritative.

## 1. Preserve content and provenance

A style edit may reorganize prose, but it must not change what the thesis can defend.

- Read the relevant chapter brief, thesis story, outline, claim, contribution and publication records, mapped `mates/` evidence, reading notes, notation, style profile, and confirmed degree or institutional wording before editing what they control.
  Report conflicts instead of resolving them in prose.
- Preserve facts, numbers, dates, quotations, citations, source anchors, claim and contribution IDs and strength, technical distinctions, uncertainty, attribution, comparison sets, conditions, and required qualifiers.
- Treat titles, names, code, notation, LaTeX, institutional wording, and source-specific terminology as protected text unless the task explicitly owns them.
- Draw concrete details only from registered evidence or the author.
  Missing support stays visible through `\todo{...}` or the owning workflow; never supply a plausible value, source, fact, or degree requirement.
- If a revision would add, remove, move, weaken, or strengthen a claim, it is not style-only.
  Route it through the owning workflow and update `notes/claims.md` in the same change.
- Reused publication text must fit the thesis arc, terminology, attribution, and reuse record.
  A paper is evidence, not the thesis's default wording or voice.

## 2. Match the writer and the thesis

Follow an author-confirmed sample when one exists.
Match its observable vocabulary, sentence movement, punctuation, transitions, qualification, first-person practice, and deliberate repetition without borrowing sentences or adding facts, opinions, humor, or disorder.
Without a sample, use restrained, direct scholarly prose.

- Write manuscript prose in the language recorded in `degree/profile.tex`.
- Lead with the substantive point and prefer canonical terms and simple verbs.
  Name the actor or contributor when agency or attribution affects interpretation.
- Organize each paragraph around its mapped claim–evidence–inference sequence, its chapter brief, and the thesis-level argument in `notes/story.md`.
- Connect evidence to the local inference and the inference to the research question or contribution without claiming more than the evidence supports.
- Let sentence length and paragraph shape follow the reasoning.
  End on a supported finding, limitation, synthesis, or useful transition, not generic optimism.
- During a whole-thesis pass, check recurring openings, literature summaries, method recaps, contribution statements, limitations, and chapter endings without erasing purposeful cross-chapter consistency.
- Add personality only when the author-confirmed voice and scholarly context call for it.
  Never manufacture a persona or imply sole authorship of collaborative work.

## 3. Review pattern clusters

Treat these as editing signals, not banned forms or evidence of AI authorship.
Rewrite at paragraph scale when several signals accumulate, one template recurs, or a pattern introduces an unsupported claim.

| Review for | Rewrite toward |
| --- | --- |
| Inflated significance, sales language, name-dropping, unsupported superlatives, or stock optimism | The exact result and only its supported consequence. |
| Vague attribution, knowledge-limit disclaimers, or plausible guesses | A named, verified source and checkable proposition; otherwise an explicit gap or deletion. |
| Shallow analytical tails, abstract action chains, hidden actors, or stacked qualifiers | A direct fact–inference link, a clear actor where needed, and only evidentially necessary qualification. |
| Repeated “not X but Y,” forced triads or ranges, fake objections or alternatives, staged candor, slogans, or a claimed “deeper truth” | The real relation, constraint, or choice without drafting scaffolds. |
| Stock signposting, repeated headings, filler, greetings, praise, apologies, previews, service offers, or generic endings | The content itself and only navigation the reader needs. |
| Synonym cycling, stock diction, repeated openings, uniform cadence, dramatic fragments, excessive dashes, decorative emphasis, label-heavy lists, or emojis | Stable names and syntax, rhythm, or formatting that has a clear function. |

Do not ban a word, transition, passive construction, first person, long sentence, list, or dash in isolation.
Keep a form when it carries a real relation, preserves technical meaning, or matches the author.
Never rewrite quotations, titles, notation, data, or literal fields merely because they match a watched pattern.
`lint.sh` labels configured instances such as `chatbot-residue`, `inflated-significance`, `vague-attribution`, `formulaic-contrast`, `stock-signposting`, `shallow-analysis`, `generic-outlook`, `manufactured-depth`, and `stock-diction`.
Its warnings locate passages for review; a clean scan only means that no configured pattern fired.
Do not assign a numerical “human score.”

## 4. Rewrite and verify

1. Resolve the target, chapter brief, manuscript language, and any confirmed degree context that controls the passage.
2. Read the controlling records and mark all protected literal and semantic content.
3. Map the claim–evidence–inference sequence and its role in the thesis arc, then diagnose patterns by paragraph.
4. Rewrite the unit around its substantive point; do not patch watched words one by one.
5. Compare the revision with the original prose, ledger, evidence, reading notes, notation, contribution and publication records, and style profile.
   Restore every dropped qualifier, trace, or attribution, and remove every added or strengthened claim.
6. Preserve one sentence per source line, then run `bash execs/run.sh` and `bash execs/scpts/lint.sh` after any `manus/` edit.

Leave the passage unchanged and report the issue if smoother prose would require unimported evidence, a different claim or degree requirement, an unsupported statement about prior work, a new canonical term, changed attribution, or removal of a necessary qualifier.
A revision is ready only when claim fidelity and traceability pass, attribution remains accurate, terminology stays stable, and the passage still serves the chapter and thesis arguments.
