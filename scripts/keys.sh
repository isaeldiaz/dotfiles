#!/usr/bin/env bash
#
# keys.sh -- one cheatsheet for the WezTerm / tmux / Neovim stack.
#
# Each layer already dumps its own bindings (wezterm show-keys, prefix + ?,
# :Telescope keymaps), but those dumps are layer-local: none of them can tell
# you a key never arrives because the layer above swallowed it. This prints the
# cross-layer scheme and the known collisions. Use --full for the live dumps,
# which are the authoritative source if this sheet ever drifts.

set -u

usage() {
   cat <<'USAGE'
Usage: keys.sh [option]

  (no args)       cross-layer cheatsheet
  -f, --full      cheatsheet, then live dumps from every layer present here
  -w, --wezterm   live WezTerm bindings only
  -t, --tmux      live tmux bindings only
  -n, --nvim      how to list live Neovim bindings
  -h, --help      this message
USAGE
}

if [ -t 1 ] && command -v tput > /dev/null 2>&1 && [ "$(tput colors 2> /dev/null || echo 0)" -ge 8 ]; then
   BOLD=$(tput bold); DIM=$(tput dim); OFF=$(tput sgr0)
   BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
else
   BOLD=; DIM=; OFF=; BLUE=; GREEN=; YELLOW=
fi

head()  { printf '\n%s%s%s\n' "$BOLD$BLUE" "$1" "$OFF"; }
key()   { printf '  %s%-20s%s %s\n' "$GREEN" "$1" "$OFF" "$2"; }
warn()  { printf '  %s%-20s%s %s\n' "$YELLOW" "$1" "$OFF" "$2"; }
note()  { printf '  %s%s%s\n' "$DIM" "$1" "$OFF"; }

context() {
   local here=""
   [ -n "${WEZTERM_PANE:-}" ] && here="WezTerm"
   [ -n "${TMUX:-}" ] && here="${here:+$here > }tmux"
   [ -n "${SSH_TTY:-}" ] && here="${here:-shell} via ssh on $(hostname 2> /dev/null || echo remote)"
   printf '%sYou are in:%s %s\n' "$DIM" "$OFF" "${here:-a plain terminal}"
}

cheatsheet() {
   printf '\n%sThe rule: ALT is the outer layer (WezTerm). CTRL and the tmux%s\n' "$BOLD" "$OFF"
   printf '%sprefix are the inner ones (tmux, Neovim).%s\n' "$BOLD" "$OFF"
   note "WezTerm consumes ALT chords before they reach the wire, so the layers"
   note "cannot fight over a key. Anything CTRL-based belongs to whatever is"
   note "innermost: nvim if it is running, otherwise tmux."
   printf '\n'
   context

   head "WezTerm            leader = Alt+s"
   key "Alt+h/j/k/l"      "focus pane (left/down/up/right)"
   key "Alt+Ctrl+h/j/k/l" "resize pane"
   key "leader h/j/k/l"   "resize mode, repeatable; Esc or q to leave"
   key 'leader \'          'split side by side'
   key "leader -"         "split stacked"
   key "leader z"         "zoom pane"
   key "leader x"         "close pane"
   key "leader n / w"     "new tab / close tab"
   key "leader Space"     "next tab   (add Shift for previous)"
   key "leader f"         "font size mode: k bigger, j smaller, r reset"
   key "leader r"         "reload config"
   key "leader / , ."     "backdrop: random, previous, next"
   key "leader Shift+/"   "backdrop picker (fuzzy)"
   key "Alt+f"            "search scrollback"
   key "Alt+u"            "pick and open a URL"
   key "Alt+b"            "toggle backdrop focus mode"
   key "Alt+Left/Right"   "Home / End"
   key "Alt+Backspace"    "delete word before cursor"
   key "Ctrl+Shift+c/v"   "copy / paste"
   key "F1"               "copy mode"
   key "F2"               "command palette (fuzzy, shows every binding)"
   key "F3 / F4 / F5"     "launcher / tabs / workspaces"
   key "F11 / F12"        "fullscreen / debug overlay"

   head "tmux               prefix = Ctrl+s"
   key "Ctrl+h/j/k/l"     "focus pane -- no prefix, and passes into nvim"
   key "prefix h/j/k/l"   "resize pane, repeatable"
   key 'prefix | or \'     'split side by side'
   key "prefix -"         "split stacked"
   key "prefix z"         "zoom pane"
   key "prefix x"         "kill pane"
   key "prefix n / w"     "new window / kill window"
   key "prefix Space"     "next window   (add Shift for previous)"
   key "prefix Escape"    "copy mode: v select, y copy, Enter copy"
   key "prefix p"         "paste buffer"
   key "prefix Tab"       "extrakto: fzf over the pane, copy/insert anything"
   key "prefix u"         "fzf over every URL on screen"
   key "prefix m"         "toggle mouse"
   key "prefix r"         "reload config"
   key "prefix ?"         "list every live binding"
   key "prefix I"         "install plugins (needed once per server)"

   head "Neovim             leader = Space"
   key "Ctrl+h/j/k/l"     "focus split, and on into tmux panes"
   key 'Ctrl+\'            'previous split/pane'
   key "Ctrl+arrows"      "resize split"
   key "leader t f/b/h/g" "telescope: files, buffers, help, live grep"
   key "leader g s/c/p/d" "fugitive: status, commit, push, diff"
   key "leader d v/h/c"   "diffview: open, file history, close"
   key "leader c c/u"     "comment / uncomment"
   key "leader w / f / s" "easymotion: word, char, 2-char"
   key "leader q / Q"     "quit / quit all without saving"
   key "Alt+Up/Down"      "move line or selection up/down"
   key "Ctrl+n"           "cycle line numbers"
   key "Alt+m"            "toggle mouse"
   note "Full live list: :Telescope keymaps"

   head "Mouse              one rule, every layer"
   key "drag"             "selects in the innermost app (nvim visual, tmux copy)"
   key "Shift+drag"       "hands the event to WezTerm: straight to the Windows"
   note "                      clipboard, but grabs line numbers inside nvim"
   key "wheel"            "scrolls whatever is innermost (nvim buffer, tmux history)"
   key "Ctrl+click"       "open link"
   note "y in nvim or tmux copy mode reaches the Windows clipboard via OSC 52."

   head "Known collisions   the layer above wins"
   warn "F2 / F3"          "WezTerm palette/launcher beat nvim NERDTree toggle"
   note "                      and find. Unbind in WezTerm or rebind in nvim."
   warn "Ctrl+s"           "tmux prefix beats nvim save. Already handled:"
   note "                      send-prefix is bound, so Ctrl+s Ctrl+s saves."
}

dump_wezterm() {
   head "wezterm show-keys"
   if command -v wezterm > /dev/null 2>&1; then
      note "Config on THIS machine. From a remote pane that is the remote"
      note "config, not the one your keyboard is talking to."
      wezterm show-keys 2> /dev/null | cut -c1-96
   else
      note "wezterm not on PATH here."
   fi
}

dump_tmux() {
   head "tmux list-keys -N"
   if command -v tmux > /dev/null 2>&1; then
      tmux list-keys -N 2> /dev/null || note "no tmux server running."
   else
      note "tmux not installed here."
   fi
}

dump_nvim() {
   head "Neovim"
   note "Neovim can only list its live bindings from inside a session:"
   key ":Telescope keymaps" "fuzzy, with descriptions"
   key ":map / :nmap"       "raw dump"
   key ":verbose nmap <key>" "which file set this binding -- use when a key"
   note "                      does the wrong thing across layers"
}

case "${1:-}" in
   "")            cheatsheet ;;
   -f|--full)     cheatsheet; dump_wezterm; dump_tmux; dump_nvim ;;
   -w|--wezterm)  dump_wezterm ;;
   -t|--tmux)     dump_tmux ;;
   -n|--nvim)     dump_nvim ;;
   -h|--help)     usage ;;
   *)             printf 'unknown option: %s\n\n' "$1" >&2; usage >&2; exit 1 ;;
esac
