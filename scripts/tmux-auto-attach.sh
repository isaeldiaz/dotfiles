#!/bin/bash
[[ -n "$TMUX" ]] && exit 0          # already inside tmux

if tmux has-session 2>/dev/null; then
  exec tmux attach
else
  exec tmux new-session
fi
