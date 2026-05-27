#!/bin/bash
[[ -n "$TMUX" ]] && exit 0          # already inside tmux
[[ $- != *i* ]] && exit 0           # non-interactive shell

if tmux has-session 2>/dev/null; then
  exec tmux attach
else
  exec tmux new-session
fi
