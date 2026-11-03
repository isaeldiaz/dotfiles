#!/usr/bin/env bash
# SessionStart (compact): put the project's handoff file back into context after compaction.
input=$(cat)
project_dir=$(jq -r '.cwd' <<<"$input")
handoff="$project_dir/.claude/handoff.md"
[ -f "$handoff" ] || exit 0

context="Context was just compacted. Current task state from $handoff:

$(cat "$handoff")"
jq -n --arg ctx "$context" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
