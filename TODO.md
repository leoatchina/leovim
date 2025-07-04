 TODO:
## config:
- [x] fixed GetPyxVerion when not has 'execute'
- [x] `tab drop problem` in legacy vim
- [x] better lightline schemes
- [x] leaderf popup ratio
- [x] leaderf grep postion keeped on right if not has `popup` or `floating window`
- [x] Better register insert
- [x] Easymotion, within line jump
- [x] far.vim
- [x] fern.vim as tree_browser
- [x] search_tool using leaderf or fzf
- [x] auto choose yes to kill job when confirm quit termina
- [x] install plunins in to $ADD_PATH by default
- [x] leaderf as default fuzzy_finder when with +python3 support, otherwise fzf or ctrlp
- [x] fix coc.nvim vsplitly open definition declaration etc.
- [x] Copy && Paste using tmux
- [x] fzf yank
- [x] leaderf jumps
- [x] optimize search_tool
- [x] coc-explorer keep in buffer when opened.
- [x] sidebar-manager intergrated.
- [x] trace_code for coc.nvim according to gitter chat.
- [x] vscode-neovim intergration
- [x] GrepperSearch, with the best search tool
- [x] leaderf paste/yank
- [x] rewrite gitroot getfile functions
- [x] nvim-dap
- [x] dir diff config
- [x] telescope registers
- [x] start repl if not started before send above/below/all lines
- [x] open TODO.md in b:git_root_dir
- [x] tree-sitter back, for python/markdown/vim at first, enter is used for range selection using treesitter
- [x] ~~adjuest vimspector UI.~~
- [x] cmp Ultisnips intergrated
- [x] undotree and fundo
- [x] workspace/symbol for lsp
- [x] ~~replace telescope with fzf-lua when UNIX~~, with `fzf.vim`,`fzf`
- [x] Intergrated leaderf-registers, fzf-registers, leaderf-tabs, fzf-tabs
- [x] zfvimignore config, using .wildignore
- [x] window vertical resize
- [x] floaterm run reuse
- [x] <C-h> quickui preview window size.
- [x] mason-nvim-dap
- [x] run floaterm_right in order to use <M-->
- [x] fzfdiagnostic in windows.
- [x] <M-Q> quit terminal.
- [x] Ale show message
- [x] enhanced grep! using rg
- [x] coc-fzf toggle preview shortcut.
- [x] lsp-lens.nvim or symbol-usage.nvim for cmp/nvim-lsp codeaction.
- [x] symbol-tags-search lsp check update.
- [x] leaderf TODO/NOTE bug
- [x] Neoformat, config like REPLFloaterm. using Q
  - [x] nnoremap
  - [x] xnoremap
- [x] registers enhanced, using <M-y> to copy to alphatical registers
- [x] leaderf git
- [x] update vim-which-key
- [x] wilder.nvim or change wildmode settings -> longest,full
- [x] nvim-dap conifg,
  - [x] plan to load vscode config [https://github.com/mfussenegger/nvim-dap/blob/master/doc/dap.txt#L372]
  - [x] daptab
  - [x] <F3> to reset dap and close daptab.
  - [x] <F5> load dap.json
  - [x] <F6> pause and mv to daptab
  - [x] <F7/F8> mv between breakpoints.
  - [x] optimize open json config.
- [x] ai editor cursor config
- [x] jupynium.nvim.
  - [x] local
  - [x] remote url
- [x] Add ctrl-e to edit command in FzfCallCommands
- [x] neoconf
- [x] imap <C-f> enhanced
- [x] vimspector preview template in WINDOWS()
- [x] leaderf gtags bug
- [x] targets.vim bug
- [x] yank optimize
- [x] delete lsp_zero
- [x] Expand function
- [x] run reuse
- [x] wilder.nvim && cmp-cmdline
- [x] lsp codelens warn bug
- [x] tabline add nr
- [x] glance -> lspui
- [x] grep command replace bug, using g:grepper_word
- [x] CocAction return value
- [x] ~~fzflsp -> fzfx.nvim or fzf-lua~~
- [x] ~~cmp <C-n><C-p> problem~~
- [x] ~~vim's unamed registers~~
- [x] lightline modified
- [x] run script in qf and show in lightline, refer albertomontesg/lightline-asyncrun
- [x] suppress <C-c> E5108 error messages
- [x] LeaderfSeach with as optinal second parameter
- [x] ~~fzfrg put files side by side with lines~~, using fzf --nth
- [x] ~~show current tab's all buffers in tabline~~, may using smart tab line width
- [x] search using 3 different entries: <leader>/, <c-f>, s
- [x] yank from file begin to current cursor postion
- [x] config gopls in cmp || coc
- [x] nvim-dap run to cursor
- [x] delance
- [x] jessekelighine/vindent.vim
- [x] use native vim.lsp command instead of LspUI.
- [x] FzfSearch Command optimize, 3 levels, Git/Project/Current.
- [x] show/yank current dir/file/path
- [x] codecompanion.nvim
- [x] write fzf-startify
- [x] tab nr highlighting group
- [x] ~~vim-fern in popup || floating_window~~
- [x] git branch icons
- [x] nvim-lsp
    - [x] require nvim-0.11
    - [x] nvim-java
    - [x] create .vim folder for neoconf
    - [x] ~~blink sources: https://cmp.saghen.dev/configuration/sources.html#community-sources~~
- [x] optimize nvim-0.11 builtin completion
- [x] builtin的snippets问题
- [ ] windows gvim add DETACH to  winbar 
- [ ] gtags without cscope
- [ ] config formatter.nvim
- [ ] Ai related 
    - [x] ~~yarepl.nvim + aider~~
    - [ ] copilot plus 
    - [ ] minuet.ai
- [ ] R.exe exepath in windows
- [ ] Fzf --no-sort option for different commands
- [ ] find conflicts using Git/Project/Current path.
## MyPlugins:
- [x] fzf-registers
- [ ] vim-funky
  - [x] open bug
  - [x] preview funky
  - [x] multi buffers
  - [x] jump to another window bug
  - [x] ~~FunkyAll not show buffer modified bug~~, actually should do w! before funky functions
  - [x] ~~ctrlp intergrated~~, using funky#qf#show() instead
  - [ ] README
  - [ ] deploy to github
- [x] vim-floaterm-repl updates.
  - [x] use <M-e> as prefix key
  - [x] update repl_floaterm block send command. Updated with Find_Side
  - [x] send block, but keep cusor position, NOTE:fixed by Find_Side function
  - [x] g:repl_floaterm_block_mark find without textobj.
  - [x] if REPL started, send enter in repl terminal. If not start REPL.
  - [x] g:repl_floaterm_clear for each ft
  - [x] g:repl_floaterm_quit for each ft
  - [x] send current word to terminal.
  - [x] mark content, and resend/show marked content if `quickui` installed
  - [x] README
  - [x] deploy to github
- [x] name vim-floaterm-repl to vim-floaterm-enhance
    - [x] intergrated with asyncrun.vim
    - [ ] Run is current tab related only, could not be used in other tabs, 
    - [ ] using different idx for aider, repl
    - [ ] fork vim-floaterm
## Plenty of works
- [x] ReWrite readme
- [ ] vista
  - [ ] icons bug in windows-terminal
  - [ ] open shortcuts
  - [ ] ctags enhanced, according to zhihu user `成隽`
- [ ] vim-packadd
  - [ ] floating or popup window.
  - [ ] use `:packadd` to load plugins
  - [ ] mix `vim-plug` and `vim-jetpack` together
- [ ] vim-zeal
  - [ ] view document in (neo)vim
- [ ] Introduce video
