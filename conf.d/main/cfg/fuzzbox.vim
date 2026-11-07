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

command! -nargs=* FuzzSearch call fuzzbox#Launch('grep', {'prompt_text': <q-args>})
command! -nargs=* FuzzSearchAll call fuzzbox#Launch('grep', {'cwd': utils#get_root_dir(), 'prompt_text': <q-args>})
command! -nargs=* FuzzGitSearch call fuzzbox#Launch('grep', {'command': 'git grep -n --column', 'cwd': utils#get_root_dir('.git'), 'prompt_text': <q-args>})
command! -nargs=* FuzzGitFiles call fuzzbox#Launch('files', {'command': 'git ls-files', 'cwd': utils#get_root_dir('.git'), 'prompt_text': <q-args>})
command! FuzzSearchLast FuzzyPrevious
