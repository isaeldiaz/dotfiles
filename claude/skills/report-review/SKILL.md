---
name: report-review
description: Review a report before delivery with two fresh-context subagents - a readability reader, and a skeptical domain expert who checks that every claim is scoped, bounded and true for the target. Use before delivering or after substantially revising a report, study write-up or analysis document, or when the user runs /report-review <path>.
argument-hint: <report path>
---

Review the report at `$ARGUMENTS`, or the report just written. Launch both subagents in
parallel, each with fresh context. Give them the inputs below, never your conclusions or
the session's history.

## 1. Readability review

Inputs: the report, and the project's report-readability rules if it has any. It judges
no sources, so the global "Weighing sources" rule is not part of its brief.
Persona: an engineer outside the project, five minutes, reading top to bottom, no sources
open. It reports:

- the takeaway from the executive summary alone;
- where it lost track or had to re-read, and why;
- paragraphs with more numbers than the conclusion needs;
- points out of order of importance;
- terms, acronyms or figures it could not explain back;
- facts with no link to why they matter.

## 2. Reader-questions review

Inputs: the report; the code, data and sources that produced it; the documents that
define the target (the project's CLAUDE.md names them); the global "Claims are bounded"
and "Weighing sources" rules; the project's environment rules (containers, read-only
remote hosts).
Persona: a domain expert who doubts every result and has time to check. For each verdict,
each figure feature (step, plateau, gap, trend) and each number a conclusion rests on:

- How was it reached? Can I redo it from the report and the code?
- What configuration does it cover? Does the nearest variant give the same answer?
- Where does each bound or constant come from? Would moving it change the result?
- Does it hold for the target, or only under the model's simplification?
- What does the estimate leave out, and which way does that bias it?
- Negative result: what would make it pass, and is that feasible?
- Count or ratio: what are the numerator and denominator?

It may read and run the code, but not edit anything. It reports only questions the report
leaves unanswered: location, the conclusion at stake, and the answer if it found one
(graded, with how it was obtained).

## Apply

- Verify each finding before acting; subagent output is graded like any other source.
- Fix what holds. A finding that changes a result goes to the summary, not only the body.
- Tell the user what was fixed, what was rejected and why, and what is left open (for
  example, needs a rerun).
- Record both reviews in the report's provenance, if it has one.
