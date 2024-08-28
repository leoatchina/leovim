let g:require_group = get(g:, 'preset_group', [])

let g:leovim_osc52_yank = 1
let g:leovim_whichkey = 1
let g:leovim_openmap = 1
let g:nvim_treesitter_install = 0

" if v:version < 800
"     call AddRequire('notags')
" endif

" call AddRequire('r')
" call AddRequire('web')
" call AddRequire('wubi')
" call AddRequire('query')
" call AddRequire('markdown')

" call AddRequire('c', 'rust', 'go', 'java')

" let g:open_vim="nvim.exe"

" let g:jupynium_urls = ['localhost:9999/nbclassic']
" let g:vscode_user_dir = 'C:\Scoop\persist\vscode\data\user-data\User'
" let g:cursor_user_dir = 'C:\Users\Admin\AppData\Roaming\Cursor\User'

let g:highlight_filetypes = ['python', 'r', 'vim', 'vimdoc', 'markdown', 'lua', 'c', 'cpp', 'go', 'rust', 'java']

if has('nvim') && HAS_GUI()
    " set guifont=Cascadia\ Code:h10.5
    " set guifont=CascadiaCode\ Nerd\ Font:h11.5
endif

if WINDOWS()
    " let g:python3_host_prog='C:\\Python37\\python.exe'
    " let &pythonthreedll='C:\\Python37\\python37.dll'
    " let &pythonthreehome='C:\\Python37'
elseif UNIX()
    " let g:python3_host_prog=$HOME.'/miniconda3/bin/python3'
endif

" NOTE: visit https://ftp.gnu.org/pub/gnu/global/
" wget https://ftp.gnu.org/pub/gnu/global/global-6.6.12.tar.gz && tar xvf global-6.6.12.tar.gz && cd global-6.6.12  && ./configure --prefix ~/.local/gtags && make && make install && cd ..
" if executable('gtags') && UNIX()
    " let $GTAGSCONF=expand($HOME."/.local/gtags/share/gtags/gtags.conf")
" endif

" let g:vimtex_view_method = 'zathura'

" let g:header_field_author = 'leoatchina'
" let g:header_field_author_email = 'leoatchina@outlook.com'
" nnoremap <M-g>n :!git config user.name "leoatchina"<Cr>:!git config user.email "leoatchina@outlook.com"<Cr>
