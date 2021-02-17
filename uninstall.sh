#!/usr/bin/env sh
warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

rm $HOME/.leovim.conf
rm $HOME/.vimrc
rm $HOME/.config/nvim/init.vim
rm $HOME/.vimrc.clean
rm $HOME/.vimrc.update


rm -rf $HOME/.vim
rm -rf $HOME/.leovim.plug
