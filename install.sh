#!/bin/bash

tools=("curl" "wget" "git" "nvim" "zsh" "tmux" "rg" )

for tool in "${tools[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    echo "$tool is not installed"
    TOOL_MISSING=true
  else
    echo "$tool : OK"
  fi
done
[[ -v TOOL_MISSING ]] && exit 1;



DOTFILES_DIR="$(realpath "${BASH_SOURCE[0]}" |xargs dirname)"

########### ZSH ##################
=======
if [ ! -d "$HOME/bin" ]; then
  mkdir "$HOME/bin"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ -f "$HOME/.zshrc" ]; then
  mv $HOME/.zshrc $HOME/.zshrc.backup
fi
ln -s $DOTFILES_DIR/zsh/dotzshrc $HOME/.zshrc


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

