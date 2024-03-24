" nnoremap <M-g>n :!git config user.name "leoatchina"<Cr>:!git config user.email "leoatchina@outlook.com"<Cr>
let g:require_group = get(g:, 'preset_group', [])
" if v:version < 800
"     call AddRequire('notags')
" endif

" call AddRequire('wubi')
" call AddRequire('query')
" call AddRequire('write')
" call AddRequire('web')
" call AddRequire('r')
" call AddRequire('c', 'rust', 'go')

" let g:vim_path="nvim-qt.exe"
" let g:vscode_keybindings_dir = 'C:\Scoop\persist\vscode\data\user-data\User'
" let g:nvim_treesitter_install = 1
" let g:jupynium_urls = ['localhost:9999/nbclassic']

let g:highlight_filetypes = ['python', 'r', 'vim', 'markdown', 'lua']

if WINDOWS()
    " let g:python3_host_prog='C:\\Python37\\python.exe'
    " let &pythonthreedll='C:\\Python37\\python37.dll'
    " let &pythonthreehome='C:\\Python37'
elseif UNIX()
    " let g:python3_host_prog=$HOME.'/miniconda3/bin/python3'
endif


" fonts
if HAS_GUI()
    if WINDOWS()
        " set guifont=Cascadia\ Code:h10.5
        " set guifont=CascadiaCode\ Nerd\ Font:h10.5
    elseif LINUX()
        " set guifont=Cascadia\ Code\ 10.5
        " set guifont=CascadiaCode\ Nerd\ Font 10.5
    endif
endif

" NOTE: visit https://ftp.gnu.org/pub/gnu/global/
" wget latest gtags version && ./configure --prefix ~/.local && make && make install
" if executable('gtags')
    " let $GTAGSCONF=expand($HOME."/.local/gtags/share/gtags/gtags.conf")
" endif

" let g:vimtex_view_method = 'zathura'

" let g:header_field_author = 'your name'
" let g:header_field_author_email = 'your_name@email.com'
