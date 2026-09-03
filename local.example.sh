# Copy this file to ~/.dotfiles.local and adjust values.
# Sourced by both zsh and bash configs — keep it POSIX-compatible (no arrays, no [[).
# This file is NOT committed to the repo.

# Automatically attach to an existing tmux session (or create one) when
# logging in over SSH. Enable on leaf servers you regularly SSH into.
#
# Do NOT enable it on the WezTerm mux host: tmux would then nest inside every
# WezTerm pane. Only fires for interactive sessions with a real pty -- see the
# guards in bash/ssh-tmux.sh. Bypass once with:
#   ssh -t host 'NO_AUTO_TMUX=1 zsh -l'
# DOTFILES_TMUX_AUTO_ATTACH=true
