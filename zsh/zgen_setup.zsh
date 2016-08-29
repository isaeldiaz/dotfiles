
# load zgen
source "${HOME}/.zsh/plugins/zgen/zgen.zsh"

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen load zsh-users/fasd

     # Nordic specific plugins
    zgen oh-my-zsh plugins/svn-fast-info
    zgen oh-my-zsh themes/pygmalion

    # save all to init script
    zgen save
fi
