#!/bin/bash

COMMAND=$1


if [[ "$COMMAND" == "pack" ]]; then
  HOME_DIR="$HOME"
  DOTFILES_DIR="$HOME/dotfiles"
  PLUGIN_DIR="$HOME_DIR/.config/.vim/plugged"

  nvim -c "PlugUpdate"
  cd /tmp
  mkdir dotfiles; cd dotfiles
  cp -R $PLUGIN_DIR .
  cp -R $DOTFILES_DIR .
  date > "sync_date.txt"
  find dotfiles -name ".git" | xargs rm -Rf
  cd ..
  tar -cvf $HOME/dotfiles.tar ./dotfiles
  rm -Rf /tmp/dotfiles
  cd $HOME


elif [[ "$COMMAND" == "unpack" ]]; then

  if [[ -z $2 ]]; then
    TARGET_OS="linux"
  else
    TARGET_OS=$2
  fi

  # Linux
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
     export WIN_USER=$(powershell.exe '$env:USERNAME' | tr -d '\r')
     if [[ "$TARGET_OS" == "win" ]]; then
        # Windows dirs via WSL
        HOME_DIR="/mnt/c/Users/$WIN_USER"
        PLUGIN_DIR="$HOME_DIR/.config/nvim/plugged"
        DOTFILES_DIR="$HOME_DIR/dotfiles"
     else 
        #All linux distros
        HOME_DIR="$HOME"
        PLUGIN_DIR="$HOME_DIR/.config/.vim/plugged"
        DOTFILES_DIR="$HOME_DIR/dotfiles"
     fi
  fi

  CURRENT_DIR=$(basename "$PWD")
  if [[ "$CURRENT_DIR" == "dotfiles" && "$PWD" !=  "$DOTFILES_DIR" ]]; then
    rsync -av ../plugged/ "$PLUGIN_DIR/"
    rsync -av ../dotfiles/ "$DOTFILES_DIR/"

    echo "Unpacked completed"
  else
    echo "ERROR - Cannot unpack from current location"
  fi


fi
