# easy-align
rm -rf vim-easy-align
git clone --depth 1 https://github.com/junegunn/vim-easy-align.git

# indentline
rm -rf indentLine
git clone --depth 1 https://github.com/Yggdroot/indentLine.git

# winresize
rm -rf winresizer
git clone --depth 1 https://github.com/simeji/winresizer.git

# ctrlp
rm -rf ctrlp.vim
git clone --depth 1 https://github.com/ctrlpvim/ctrlp.vim.git

# ctrlp-funky
rm -rf ctrlp-funky
git clone --depth 1 https://github.com/tacahiroy/ctrlp-funky.git

# ctrlp-py-mather
rm -rf ctrlp-py-matcher
git clone --depth 1 https://github.com/FelikZ/ctrlp-py-matcher.git

# ctrlp-extensions
rm -rf ctrlp-extensions.vim
git clone --depth 1 https://github.com/sgur/ctrlp-extensions.vim.git

# textobj
rm -rf vim-textobj-user
git clone --depth 1 https://github.com/kana/vim-textobj-user.git

rm -rf vim-textobj-syntax
git clone --depth 1 https://github.com/kana/vim-textobj-syntax.git

rm -rf vim-textobj-uri
git clone --depth 1 https://github.com/jceb/vim-textobj-uri.git

rm -rf vim-textobj-line
git clone --depth 1 https://github.com/kana/vim-textobj-line.git

# vinger
rm -rf vim-vinegar
git clone --depth 1 https://github.com/tpope/vim-vinegar.git

# vim-tmux-navigator
rm -rf vim-tmux-navigator
git clone --depth 1 https://github.com/christoomey/vim-tmux-navigator.git

# vim-repl
rm -rf vim-repl
git clone --depth 1 https://github.com/sillybun/vim-repl.git

# .gitignore
find . -type f | grep \.gitignore$ | xargs rm -f
find . -type d | grep \.github$ | xargs rm -rf
find . -type d | grep \.git$ | xargs rm -rf
find . -type d | grep test$ | xargs rm -rf
find . -type d | grep assets$ | xargs rm -rf
