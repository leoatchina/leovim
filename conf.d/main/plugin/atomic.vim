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
else
    nmap <M-f> <Plug>(easymotion-w)
    xmap <M-f> <Plug>(easymotion-w)
    omap <M-f> <Plug>(easymotion-w)
    imap <M-f> <C-o><Plug>(easymotion-w)
    nmap <M-b> <Plug>(easymotion-b)
    xmap <M-b> <Plug>(easymotion-b)
    omap <M-b> <Plug>(easymotion-b)
    imap <M-b> <C-o><Plug>(easymotion-b)
    imap <M-g> <C-o><Plug>(easymotion-lineanywhere)
    nmap s; <Plug>(easymotion-W)
    xmap s; <Plug>(easymotion-W)
    omap s; <Plug>(easymotion-W)
    nmap s, <Plug>(easymotion-B)
    xmap s, <Plug>(easymotion-B)
    omap s, <Plug>(easymotion-B)
    nmap sl <Plug>(easymotion-lineanywhere)
    xmap sl <Plug>(easymotion-lineanywhere)
    omap sl <Plug>(easymotion-lineanywhere)
    nmap sL <Plug>(easymotion-bd-jk)
    xmap sL <Plug>(easymotion-bd-jk)
    omap sL <Plug>(easymotion-bd-jk)
    if !pack#planned('flash.nvim')
        nmap sj <Plug>(easymotion-f2)
        xmap sj <Plug>(easymotion-f2)
        omap sj <Plug>(easymotion-f2)
        nmap sk <Plug>(easymotion-F2)
        xmap sk <Plug>(easymotion-F2)
        omap sk <Plug>(easymotion-F2)
        nmap so <Plug>(easymotion-sn)
        xmap so <Plug>(easymotion-sn)
        omap so <Plug>(easymotion-sn)
    endif
endif
