# vim-plug
rm -rf vim-plug
git clone --depth 1 https://github.com/junegunn/vim-plug.git
mv ./vim-plug/plug.vim ../
rm -rf vim-plug
mkdir -p vim-plug/autoload
mv ../plug.vim vim-plug/autoload

# easymotion
rm -rf vim-easymotion
git clone --depth 1 https://github.com/easymotion/vim-easymotion.git

# clever-f
rm -rf clever-f.vim
git clone --depth 1 https://github.com/rhysd/clever-f.vim.git

# far.vim
rm -rf far.vim
git clone --depth 1 https://github.com/brooth/far.vim.git

# vim-visual-multi
rm -rf vim-visual-multi
git clone --depth 1 https://github.com/mg979/vim-visual-multi.git

# vim-which-key
rm -rf vim-which-key
git clone --depth 1 --single-branch --branch meta_key https://github.com/leoatchina/vim-which-key.git

# asyncrun
rm -rf asyncrun.vim
git clone --depth 1 https://github.com/skywind3000/asyncrun.vim.git
rm -rf asyncrun.extra
git clone --depth 1 https://github.com/skywind3000/asyncrun.extra.git

# asynctasks.vim
rm -rf asynctasks.vim
git clone --depth 1 https://github.com/skywind3000/asynctasks.vim.git

# vim-cycle
rm -rf vim-cycle
git clone --depth 1 https://github.com/bootleq/vim-cycle.git

# vim-terminal-help
rm -rf vim-terminal-help
git clone --depth 1 https://github.com/skywind3000/vim-terminal-help.git

# vim-sandwich
rm -rf vim-sandwich
git clone --depth 1 https://github.com/machakann/vim-sandwich.git

# lightline 
rm -rf lightline.vim 
git clone --depth 1 https://github.com/itchyny/lightline.vim 

# startify
rm -rf vim-startify 
git clone --depth 1 https://github.com/mhinz/vim-startify

# vim-floaterm
rm -rf vim-floaterm
git clone --depth 1 https://github.com/voldikss/vim-floaterm.git

# vim-dict 
rm -rf vim-dict
git clone --depth 1 https://github.com/skywind3000/vim-dict.git

# vim-grepper
rm -rf vim-grepper 
git clone --depth 1  https://github.com/mhinz/vim-grepper.git
rm -rf vim-grepper/pictures


find . -type f | grep \.gitignore$ | xargs rm -f
find . -type d | grep \.github$ | xargs rm -rf
find . -type d | grep \.git$ | xargs rm -rf
find . -type d | grep test$ | xargs rm -rf
find . -type d | grep asses$ | xargs rm -rf
