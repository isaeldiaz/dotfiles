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
