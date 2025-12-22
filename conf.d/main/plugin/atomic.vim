if pack#installed('nvim-hlslens')
    lua require('hlslens').setup()
    nnoremap <silent><nowait>n <Cmd>execute('normal! ' . v:count1 . 'n')<Cr><Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>N <Cmd>execute('normal! ' . v:count1 . 'N')<Cr><Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>* *``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait># #``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>g* g*``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>g# g#``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait><C-n> *``<Cmd>lua require('hlslens').start()<Cr>cgn
else
    nnoremap <silent><nowait>* *``
    nnoremap <silent><nowait># #``
    nnoremap <silent><nowait>g* g*``
    nnoremap <silent><nowait>g# g#``
    nnoremap <silent><nowait><C-n> *``cgn
endif
if pack#installed('flash.nvim')
    lua require("cfg/flash")
    nmap SJ vt<Space><Cr>S
    nmap SK vT<Space><Cr>S
else
    nmap ;s <Plug>(clever-f-repeat-forward)
    xmap ;s <Plug>(clever-f-repeat-forward)
    nmap ,s <Plug>(clever-f-repeat-back)
    xmap ,s <Plug>(clever-f-repeat-back)
    nmap SJ vt<Space>S
    nmap SK vT<Space>S
endif
if pack#installed('hop.nvim')
    imap <C-a> <ESC>ggVG
    xmap <C-a> <ESC>ggVG
    nmap <C-a> ggVG
    imap <C-x> <C-o>"*
    xmap <C-x> "*x
    nmap <C-x> "*x
    lua require("cfg/hop")
endif
