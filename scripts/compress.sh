#!/bin/bash

[ -f ~/leovim.tar.gz ] && rm ~/leovim.tar.gz

cd ~ && tar -cvzf \
  ~/leovim.tar.gz \
  --exclude .git \
  --exclude .git/* \
  --exclude .gz$ \
  --exclude .bz2$ \
  --exclude .zip$ \
  --exclude .tags$ \
  --exclude .gtags$ \
  --exclude GPATH \
  --exclude GRTAGS \
  --exclude GTAGS \
  .local/fzf \
  .local/nvim* \
  .local/node* \
  .local/ctags \
  .local/gtags \
  .local/tmux \
  .leovim.d \
  .leovim
