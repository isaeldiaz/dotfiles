# Load machine-local feature flags (not committed to repo)
[ -f ~/.dotfiles.local ] && . ~/.dotfiles.local

# Auto-attach to tmux on SSH login
if [ "${DOTFILES_TMUX_AUTO_ATTACH:-false}" = "true" ] && [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
  exec ~/dotfiles/scripts/tmux-auto-attach.sh
fi
