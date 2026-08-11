---
description: Adversarially review the current changes with fresh-context subagents hunting for mistakes, over-engineering, and bad comments
argument-hint: "[branch | PR number | path | (empty = working tree)]"
---

Run an adversarial review of the changes. Your job is to break the change, not to praise it.

Target: `$ARGUMENTS` — if empty, review the uncommitted working tree plus any commits on this branch that are not on the main branch.

## Sources of truth

Everything in this review — the stated intent, every finding, every line of the final report — must be traceable to one of three places:

1. **The code** (the diff and the surrounding files).
2. **Git history** (commit messages, blame, prior commits touching the same code).
3. **Jira** (ticket text, acceptance criteria, comments). For ULY tickets use the `uly-jira` skill; quote what the ticket actually says.

Nothing else may enter the report. In particular: no facts from our chat, no wording lifted from the prompt that produced the change, no "the author intended…" that came from a subagent's reasoning rather than from a source above. If a claim matters and you cannot point at code, a commit, or a ticket line that supports it, either go find that support or leave the claim out.

Write the report so it stands on its own for someone who reads only the repo and the ticket. When intent is genuinely unrecorded anywhere, say "intent not stated in the commits or the ticket" and review the code against what it does, not against a guess.

## 1. Scope the change yourself

Before spawning anything, get the facts:

- `git status`, and the right diff for the target (`git diff`, `git diff <base>...HEAD`, or `gh pr diff <n>`).
- Read the changed files in full, not just the diff hunks — a diff hides the code it breaks.
- Establish what the change is *supposed* to do from the commit messages, the branch name, and the linked Jira ticket. Record where you got it from; you will pass that provenance to the reviewers.

## 2. Spawn the reviewers

Spawn subagents with the `Agent` tool, `subagent_type: "general-purpose"`. They start with a clean context on purpose: they must not inherit your assumptions about the change being correct. Send them in **one message** so they run in parallel.

Pick the number from the size of the change, not from habit:

| Change | Agents |
|---|---|
| Small — one file, under ~50 changed lines | 1 agent, all four lenses |
| Medium — a few files, one subsystem | 2–3 agents |
| Large — cross-cutting, new subsystem, public API | 4 agents, one per lens |

The four lenses:

1. **Correctness vs. intent** — does the code actually do the stated thing? Hunt for wrong conditions, off-by-one, unhandled errors, null/empty/zero cases, wrong types, resource leaks, concurrency and ordering bugs, and behaviour that changed for existing callers.
2. **Simplicity** — is this the smallest code that solves the problem? Hunt for abstraction with one user, options nobody asked for, hand-rolled versions of something already in the repo or the stdlib, dead code, redundant state, and control flow that needs a second read to follow.
3. **Comments and naming** — do the comments earn their place? Flag comments that restate the code, stale comments, jargon where a plain word works, missing "why" on anything non-obvious, and names that mislead.
4. **Blast radius** — what else should have changed and did not? Callers, tests, error messages, config, docs, migrations, build files.

### The prompt each agent gets

Give every agent this, filled in for its lens. State the intent *and where it came from* — do not paraphrase anything I told you in chat:

> You are reviewing a change adversarially. Assume it is wrong until the code proves otherwise. Do not trust the author's description.
>
> Target: <exact git command(s) to get the diff>.
> Intent: <what the change claims to do> — source: <commit sha / ticket key / "not stated anywhere">.
> Your lens: <lens name and its bullet list from above>.
>
> Read the changed files in full and the code around them — callers, tests, similar existing code. Check git history for the same lines. Read the linked Jira ticket if there is one. Then report only findings you have verified in those sources.
>
> Rules:
> - Every finding needs a `file:line`, one sentence saying what is wrong, and a concrete scenario where it bites (specific inputs or state → what goes wrong). If you cannot write the scenario, drop the finding.
> - Every claim must be backed by code, a commit, or ticket text. Cite which. Do not assert intent, history, or requirements that you cannot point to. Guessing is worse than saying "not recorded".
> - No style nits, no formatting, no "consider maybe". No praise.
> - Do not edit any file. Review only.
> - If your lens turns up nothing, say so plainly and list what you checked. An empty report is a valid result.
>
> Return: a flat list of findings, worst first, each tagged `must-fix`, `worth-fixing`, or `nitpick`, plus a one-line "checked and clean" summary.

## 3. Verify before you repeat

Findings from a fresh-context agent are leads, not truth. For each one:

- Open the code and confirm it. Drop anything you cannot confirm.
- Check its backing. If the agent asserted intent or a requirement, confirm it against the commit or the ticket. Drop it if the source does not say that.
- Drop duplicates across agents; keep the clearest wording.
- Drop anything that is a matter of taste.

A short report of real problems beats a long one padded with maybes.

## 4. Report

Write it for a reader who wants to act, in plain words:

```
## Red team: <what was reviewed>
Intent per <commit sha | TICKET-123 | not stated>: <one line>

**Verdict:** ship it / fix first / rethink the approach

### Must fix
1. `path/file.c:42` — <what is wrong, one sentence>
   Happens when: <concrete case>
   Fix: <the smallest change that solves it>

### Worth fixing
...

### Nitpicks
...

### Checked and clean
<one line per area that held up>
```

Rules for the report itself — the same standard you are holding the code to:

- Plain language. Say "this crashes when the list is empty", not "insufficient defensive handling of the degenerate case".
- No jargon where a normal word works. No restating the diff back to me.
- Every statement traceable to code, git, or Jira, per **Sources of truth** above.
- If nothing is wrong, say that in one line and stop. Do not invent findings to justify the review.

Do not fix anything unless I ask. End by offering to apply the must-fixes.
