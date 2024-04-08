#!/bin/bash

COMMAND=$1

if [[ "$COMMAND" == "pack" ]]; then
  HOME_DIR="$HOME"
  DOTFILES_DIR="$HOME/dotfiles"
  PLUGIN_DIR="$HOME_DIR/.config/.vim/plugged"
  VIM_INIT_DIR="$HOME_DIR/dotfiles/vim"
  cd /tmp
  mkdir dotfiles; cd dotfiles
  cp -R $PLUGIN_DIR .
  cp -R $DOTFILES_DIR .
  date > "sync_date.txt"
  find . -name ".git" | xargs rm -Rf
  cd ..
  tar -cvf $HOME/dotfiles.tar ./dotfiles
  rm -Rf /tmp/dotfiles
  cd $HOME


elif [[ "$COMMAND" == "unpack" ]]; then

TARGET_OS=$2

  # Linux
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
     if [[ "$TARGET_OS" == "win" ]]; then
        # Windows dirs via WSL
        HOME_DIR="/mnt/c/Users/$USER"
        PLUGIN_DIR="$HOME_DIR/.config/nvim/plugged"
        VIM_INIT_DIR="$HOME_DIR/AppData/Local/nvim"
     else 
        #All linux distros
        HOME_DIR="$HOME"
        PLUGIN_DIR="$HOME_DIR/.config/.vim/plugged"
        VIM_INIT_DIR="$HOME_DIR/dotfiles/vim"
     fi
  fi

  # Create the directory if it doesn't exist
  mkdir -p $DIRECTORY

  # Navigate to the directory
  cd $DIRECTORY

  # Use the unzip command to extract the plugins
  unzip path_to_your_zip_file/vim_plugins.zip

fi
