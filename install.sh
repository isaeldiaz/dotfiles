#!/bin/bash

required_tools=("curl" "git" "nvim" "tmux" "rg" "fzf" "keepassxc-cli" "jq")
optional_tools=("zsh" "wget")

for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    echo "$tool is not installed"
    TOOL_MISSING=true
  else
    echo "$tool : OK"
  fi
done
[[ -v TOOL_MISSING ]] && exit 1

for tool in "${optional_tools[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    echo "$tool : not found (optional, skipping dependent setup)"
  else
    echo "$tool : OK"
  fi
done

DOTFILES_DIR="$(realpath "${BASH_SOURCE[0]}" |xargs dirname)"

########### LOCAL CONFIG ##################
if [ ! -f "$HOME/.dotfiles.local" ]; then
  cp "$DOTFILES_DIR/local.example.sh" "$HOME/.dotfiles.local"
  echo "Created ~/.dotfiles.local from example — edit it to enable machine-specific features"
fi

########### ZSH ##################
if [ ! -d "$HOME/bin" ]; then
  mkdir "$HOME/bin"
fi

if command -v zsh > /dev/null 2>&1; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if command -v wget > /dev/null 2>&1; then
      sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
  fi

  if [ -f "$HOME/.zshrc" ]; then
    mv $HOME/.zshrc $HOME/.zshrc.backup
  fi
  ln -s $DOTFILES_DIR/zsh/dotzshrc $HOME/.zshrc
else
  echo "zsh not found — skipping oh-my-zsh and .zshrc setup"
fi


########### TMUX ##################
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ -f "$HOME/.tmux.conf" ]; then
    mv $HOME/.tmux.conf $HOME/.tmux.conf.backup
fi

ln -s $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf

########## NEOVIM ##########
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

########## CLAUDE CODE ##########
mkdir -p "$HOME/.claude"
for f in settings.json statusline-command.sh; do
  { [ -e "$HOME/.claude/$f" ] || [ -L "$HOME/.claude/$f" ]; } && mv "$HOME/.claude/$f" "$HOME/.claude/$f.backup"
  ln -s "$DOTFILES_DIR/claude/$f" "$HOME/.claude/$f"
done
# User-level custom slash commands (available in every session)
{ [ -e "$HOME/.claude/commands" ] || [ -L "$HOME/.claude/commands" ]; } && mv "$HOME/.claude/commands" "$HOME/.claude/commands.backup"
ln -s "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands"

