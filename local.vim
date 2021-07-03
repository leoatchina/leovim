let g:plugs_group = []

if get(g:, 'gui_running', 0) == 1
    " let &guifont="Consolas:h10"
    " let &guifont="Cascadia Code:h12"
endif

if WINDOWS()
    " let g:python3_host_prog='C:\\Python37\\python.exe'
    " let &pythonthreedll='C:\\Python37\\python37.dll'
    " let &pythonthreehome='C:\\Python37'
elseif UNIX
    " let g:python3_host_prog=$HOME.'/miniconda3/bin/python3'
endif

if MACOS()

elseif LINUX()

elseif CYGWIN()

endif

" gtags settings
" https://ftp.gnu.org/pub/gnu/global/
" wget latest && ./configure --prefix ~/.local && make && make install
if executable('gtags') && executable('gtags-cscope')
    " let $GTAGSCONF=$HOME."/.local/share/gtags/gtags.conf"
endif

" let g:vimtex_view_method = 'zathura'

" let g:header_field_author = 'Your Name'
" let g:header_field_author_email = 'your@mail.com'
