#!/bin/bash
rm -rf vim-which-key 
git clone --depth 1 https://github.com/leoatchina/vim-which-key.git
for fl in `find ./vim-which-key -type f | grep vim$` ; do echo $fl; vim -c "normal ggVG=" -c "wq!" $fl ; done

rm -rf vista.vim
git clone --depth 1 https://github.com/leoatchina/vista.vim.git

rm -rf vim-floaterm
git clone --depth 1 https://github.com/leoatchina/vim-floaterm.git
for fl in `find ./vim-floaterm -type f | grep vim$` ; do echo $fl; vim -c "normal ggVG=" -c "wq!" $fl ; done

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
# delete dirs
find . -type d | grep -i \.github$ | xargs rm -rf
find . -type d | grep -i \.git$    | xargs rm -rf
find . -type d | grep -i \/test$   | xargs rm -rf
find . -type d | grep -i \/tests$  | xargs rm -rf
