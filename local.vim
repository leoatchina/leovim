if WINDOWS()
    " set guifont=Consolas:h10
    " set guifont=Cascadia_Code:h12
    " let g:python3_host_prog='C:\\Python37\\python.exe'
    " let &pythonthreedll='C:\\Python37\\python37.dll'
    " let &pythonthreehome='C:\\Python37'
else
    " let g:python3_host_prog=$HOME.'/miniconda3/bin/python3'
    if MACOS()
        " set guifont=Consolas:h10
        " set guifont=Cascadia\ Code:h12
    else
        " set guifont=Consolas\ h10
        " set guifont=Cascadia\ Code\ h12
    endif
endif

" gtags settings
if executable('gtags') && executable('gtags-cscope')
    " let $GTAGSCONF=$HOME."/.local/share/gtags/gtags.conf"
endif

" let g:vimtex_view_method = 'zathura'

" let g:header_field_author = 'Your Name'
" let g:header_field_author_email = 'your@mail.com'
