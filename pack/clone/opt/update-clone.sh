#!/bin/env bash

# ctrlp
rm -rf ctrlp.vim
git clone --depth 1 https://github.com/ctrlpvim/ctrlp.vim.git

# tagbar
rm -rf tagbar
git clone --depth 1 https://github.com/preservim/tagbar.git

# vim-signify
rm -rf vim-signify
git clone --depth 1 https://github.com/mhinz/vim-signify.git

# easy-align
rm -rf vim-easy-align
git clone --depth 1 https://github.com/junegunn/vim-easy-align.git

# vim-dict
rm -rf vim-dict
git clone --depth 1 https://github.com/skywind3000/vim-dict.git

# conflict-marker
rm -rf conflict-marker.vim
git clone --depth 1 https://github.com/rhysd/conflict-marker.vim.git

# easymotion
rm -rf vim-easymotion
git clone --depth 1 https://github.com/easymotion/vim-easymotion.git

# easymotion-chs
rm -rf vim-easymotion-chs
git clone --depth 1 https://github.com/ZSaberLv0/vim-easymotion-chs.git

# clever-f
rm -rf clever-f.vim
git clone --depth 1 https://github.com/rhysd/clever-f.vim.git

# flash
rm -rf flash.nvim
git clone --depth 1 https://github.com/folke/flash.nvim.git

# hop.nvim
rm -rf hop.nvim
git clone --depth 1 https://github.com/smoka7/hop.nvim.git

# vim-matchup
rm -rf vim-matchup
git clone --depth 1 https://github.com/andymass/vim-matchup.git

# hlslens
rm -rf nvim-hlslens
git clone --depth 1 https://github.com/kevinhwang91/nvim-hlslens.git

# vim-eunuch
rm -rf vim-eunuch
git clone --depth 1 https://github.com/tpope/vim-eunuch.git

# vim-sandwich
rm -rf vim-sandwich
git clone --depth 1 https://github.com/machakann/vim-sandwich.git

# targets.vim
rm -rf targets.vim
git clone --depth 1 https://github.com/wellle/targets.vim

# vindent.vim
rm -rf vindent.vim
git clone --depth 1 https://github.com/jessekelighine/vindent.vim

# tmux
rm -rf vim-tmux-navigator
git clone --depth 1 https://github.com/christoomey/vim-tmux-navigator.git
rm -rf vim-tmux-clipboard
git clone --depth 1 https://github.com/roxma/vim-tmux-clipboard.git

# lightline
rm -rf lightline.vim
git clone --depth 1 https://github.com/itchyny/lightline.vim.git

# marks
rm -rf vim-bookmarks
git clone --depth 1 https://github.com/MattesGroeger/vim-bookmarks.git

# asyncrun
rm -rf asyncrun.vim
git clone --depth 1 https://github.com/skywind3000/asyncrun.vim.git

# asynctasks.vim
rm -rf asynctasks.vim
git clone --depth 1 https://github.com/skywind3000/asynctasks.vim.git

# vim-mucomplete
rm -rf vim-mucomplete
git clone --depth 1 https://github.com/lifepillar/vim-mucomplete.git

# undotree
rm -rf undotree
git clone --depth 1 https://github.com/mbbill/undotree.git

# fern
rm -rf vim-fern* fern-*
git clone --depth 1 https://github.com/lambdalisue/vim-fern
git clone --depth 1 https://github.com/lambdalisue/vim-fern-git-status
git clone --depth 1 https://github.com/lambdalisue/vim-fern-hijack
git clone --depth 1 https://github.com/lambdalisue/vim-fern-renderer-nerdfont
git clone --depth 1 https://github.com/lambdalisue/vim-nerdfont
git clone --depth 1 https://github.com/lambdalisue/vim-glyph-palette
git clone --depth 1 https://github.com/LumaKernel/fern-mapping-fzf.vim
git clone --depth 1 https://github.com/yuki-yano/fern-preview.vim

# quickui
rm -rf vim-quickui
git clone --depth 1 https://github.com/leoatchina/vim-quickui

# zfvim
rm -rf ZFVim*
git clone --depth 1 https://github.com/ZSaberLv0/ZFVimJob.git
git clone --depth 1 https://github.com/ZSaberLv0/ZFVimIgnore.git
git clone --depth 1 https://github.com/ZSaberLv0/ZFVimBackup.git
git clone --depth 1 https://github.com/ZSaberLv0/ZFVimDirDiff.git

# delete files
find . -type f | grep -i \.jpg$ | xargs rm -f
find . -type f | grep -i \.png$ | xargs rm -f
find . -type f | grep -i \.gif$ | xargs rm -f
find . -type f | grep -i \.bmp$ | xargs rm -f
find . -type f | grep -i \.mp4$ | xargs rm -f
find . -type f | grep -i \.mkv$ | xargs rm -f
find . -type f | grep -i \.avi$ | xargs rm -f
find . -type f | grep -i \.tag$ | xargs rm -f
find . -type f | grep -i \.tags$ | xargs rm -f
find . -type f | grep -i \.gitignore$ | xargs rm -f
find . -type f | grep -i \.lock$ | xargs rm -f
# delete dirs
find . -type d | grep -i \.github$   | xargs rm -rf
find . -type d | grep -i \.git$      | xargs rm -rf
find . -type d | grep -i \/test$     | xargs rm -rf
find . -type d | grep -i \/tests$    | xargs rm -rf
find . -type d | grep -i \/example*$ | xargs rm -rf
find . -type d | grep -i \/t$        | xargs rm -rf
