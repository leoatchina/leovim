PlugAddOpt 'vim-easymotion'
PlugAddOpt 'vim-easymotion-chs'
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
nmap sf <Plug>(easymotion-f)
xmap sf <Plug>(easymotion-f)
omap sf <Plug>(easymotion-f)
nmap sF <Plug>(easymotion-F)
xmap sF <Plug>(easymotion-F)
omap sF <Plug>(easymotion-F)
nmap st <Plug>(easymotion-t)
xmap st <Plug>(easymotion-t)
omap st <Plug>(easymotion-t)
nmap sT <Plug>(easymotion-T)
xmap sT <Plug>(easymotion-T)
omap sT <Plug>(easymotion-T)
if !Planned('flash.nvim')
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