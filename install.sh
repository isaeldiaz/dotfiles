#!/bin/bash

DOTFILES_DIR="$(realpath "${BASH_SOURCE[0]}" |xargs dirname)"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ -f "$HOME/.zshrc" ]; then
  mv $HOME/.zshrc $HOME/.zshrc.backup
fi
ln -s $DOTFILES_DIR/zsh/dotzshrc $HOME/.zshrc


if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ -f "$HOME/.tmux.conf" ]; then
    mv $HOME/.tmux.conf $HOME/.tmux.conf.backup
fi

ln -s $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf
