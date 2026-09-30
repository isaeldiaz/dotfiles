# Personal preferences

Applies to all my projects. A project's own CLAUDE.md overrides anything here.

## Recording decisions

Write the current state of things, not how we got here. When a decision changes
mid-session, replace the old version — don't document the change.

- Code and comments describe what the code does now. No "changed from X because
  Y", no "we used to ...", no comment defending a choice against an alternative
  that was never shipped.
- Docs state the current design. Rejected approaches belong in a commit message
  or a ticket, not in the doc.
- Commit messages say what this commit does. One line of "why" when it isn't
  obvious; no narrative of the attempts that got there.

Git history already holds the archaeology. Keep a rationale inline only when
someone would otherwise reintroduce the bug — then one line, saying what breaks.

## Work items and tickets

Applies to any tracker. The reader is someone who was not in the room and has a
few minutes.

**Granularity**

- One ticket is one deliverable, one owner, one component. Phases, sub-steps and
  checklists live inside the scope section, not in tickets of their own.
- Split work only where the outcomes can genuinely diverge. Two things that
  always succeed or fail together are one ticket.
- If a change cannot compile, elaborate or pass CI without another change, they
  are the same ticket.

**Content**

- Say what has to become true, not how to make it true. Scope bullets state an
  outcome; naming a file is allowed only as where to start. Directive verbs —
  apply, drive, assert, plumb, untie, fold, update — are a sign the bullet has
  turned into a design spec.
- Context leads with the problem, not the mechanism. Keep it short. No signal or
  port names in the context section, and no jargon where a plain word works.
- Every acceptance criterion must be judgeable true or false by someone who was
  not in the room. No escape clauses ("...or the regression is recorded and
  accepted"), and no "X is clean" without naming the baseline it is clean
  against.
- An epic split so that one branch may prove infeasible must say that a "no" on
  that branch is a successful outcome, not a failure.

**Before drafting**

- Open every file:line before citing it. Memory and an earlier grep are both
  wrong often enough to matter.
- Before naming a tool, target or command in a ticket, confirm it runs — in the
  record, or by running it.
- Search every related project and read the sibling module's docs first.
  Somebody has usually filed part of it already.
- Cross-project links point at durable items: link the epic, not a story that is
  about to close.
- If the tracker cannot express a dependency, say it in the ticket text. Do not
  approximate it with a link that contradicts the epic.

**Before creating**

Re-read each scope bullet and ask: does this say what, or how? Fix the ones that
say how. This check exists because the rule above it is easy to agree with and
easy to break three drafts running.
