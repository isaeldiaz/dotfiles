# Auto-attach to tmux on interactive SSH login.
# Sourced by both zsh and bash configs — keep it POSIX-compatible.

# Load machine-local feature flags (not committed to repo)
[ -f ~/.dotfiles.local ] && . ~/.dotfiles.local

# Guards, and what each one excludes:
#
#   $- = *i*      Interactive shells only. MANDATORY, not belt-and-braces: bash
#                 reads ~/.bashrc even for NON-interactive shells started by
#                 sshd, so without this `exec tmux` would corrupt the streams of
#                 scp, rsync and git-over-ssh. (zsh reads ~/.zshrc only when
#                 interactive, so the zsh path is already safe — this covers
#                 bash if ~/.bashrc ever sources this file.)
#   SSH_TTY       Set by sshd only when a pty was allocated. Preferred over
#                 SSH_CONNECTION, which is also set for pty-less sessions.
#   TMUX / STY    Already inside a multiplexer.
#   -t 0 / -t 1   Second opinion on the pty check.
#   TERM          dumb (Emacs TRAMP) and Linux VCs host tmux badly.
#   VSCODE_* etc  Editors and coding agents spawn interactive shells whose
#                 terminal integration `exec tmux` would break.
#   NO_AUTO_TMUX  Escape hatch: ssh -t host 'NO_AUTO_TMUX=1 zsh -l'
#
# Do NOT set DOTFILES_TMUX_AUTO_ATTACH on the WezTerm mux host: attaching tmux
# there would nest tmux inside every WezTerm pane. Leaf servers only.
case $- in
  *i*)
    if [ "${DOTFILES_TMUX_AUTO_ATTACH:-false}" = "true" ] \
       && [ -n "$SSH_TTY" ] && [ -z "$TMUX" ] && [ -z "$STY" ] \
       && [ -t 0 ] && [ -t 1 ] \
       && [ "$TERM" != "dumb" ] && [ "$TERM" != "linux" ] \
       && [ -z "$VSCODE_INJECTION" ] && [ "$TERM_PROGRAM" != "vscode" ] \
       && [ -z "$INSIDE_EMACS" ] && [ -z "$CLAUDECODE" ] \
       && [ -z "$NO_AUTO_TMUX" ] \
       && command -v tmux > /dev/null 2>&1
    then
      exec ~/dotfiles/scripts/tmux-auto-attach.sh
    fi
    ;;
esac
