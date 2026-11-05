" Configure before Fuzzbox's plugin script registers its mappings.
" Sourced from conf.d/plug/application.vim, before PackAdd.
let g:fuzzbox_mappings = 0
let g:fuzzbox_dropdown = 1
let g:fuzzbox_keymaps = {
            \ 'menu_down': ["\<C-j>", "\<Down>"],
            \ 'menu_up': ["\<C-k>", "\<Up>"],
            \ }
let g:fuzzbox_root_patterns = copy(g:root_patterns)
let g:fuzzbox_include_hidden = 0
let g:fuzzbox_exclude_dir = ['.git', '.hg', '.svn', '.vscode', '.idea', '.root', '.ccls']
let g:fuzzbox_exclude_file = ['*.swp', 'tags', '*.exe', '*.so', '*.dll', '*.pyd', '*.msi']
