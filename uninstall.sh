#!/usr/bin/env sh
rm -f $HOME/.leovim.clean
rm -f $HOME/.vimrc
rm -f $HOME/.gvimrc
rm -f $HOME/.config/nvim/init.vim
rm -f $HOME/.config/zed/keymap.json
rm -f $HOME/.vimrc.opt

# start scripts installed by install.sh into ~/.local/bin
rm -f $HOME/.local/bin/v.sh
rm -f $HOME/.local/bin/vi.sh
rm -f $HOME/.local/bin/n.sh
rm -f $HOME/.local/bin/nv.sh
rm -f $HOME/.local/bin/ni.sh
rm -f $HOME/.local/bin/nn.sh
rm -f $HOME/.local/bin/z.sh
rm -f $HOME/.local/bin/dirdiff

# NOTE: ~/.inputrc, ~/.configrc and ~/.bash_profile are intentionally kept:
# install.sh copies them with cp -n (no-clobber), so they may predate leovim
# and contain user modifications.

rm -rf $HOME/.leovim*
rm -rf ~/.vim/swap
mkdir ~/.vim/swap
rm -rf ~/.vim/shada.main*
echo "vim temp files cleaned"
