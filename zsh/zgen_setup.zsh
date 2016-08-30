
# load zgen
source "${HOME}/config/zgen/zgen.zsh"

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen load zsh-users/fasd


    # save all to init script
    zgen save
fi
