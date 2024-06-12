" -----------------------------------
" choosewin
" -----------------------------------
PlugAddOpt 'vim-choosewin'
nmap <silent><Tab><Cr> <Plug>(choosewin)
" ------------------------
" tab control
" ------------------------
set showtabline=2
set tabpagemax=10
" TabSwitch
nnoremap <M-n> gt
nnoremap <M-p> gT
nnoremap <silent><M-w>  :tabclose!<Cr>
nnoremap <silent><M-W>  :tabonly!<Cr>
nnoremap <silent><Tab>n :tabm +1<CR>
nnoremap <silent><Tab>p :tabm -1<CR>
nnoremap <Tab><Space>   :tabm<Space>
" move current buffer to tab
nnoremap <C-w><Cr> <C-w>T
" round current buffer
nnoremap <C-w><Tab> <C-w>r
" open window in tab
nnoremap <leader><Tab> :tabe<Space>
" tab choose
nnoremap <silent><M-1> :tabn1<Cr>
nnoremap <silent><M-2> :tabn2<Cr>
nnoremap <silent><M-3> :tabn3<Cr>
nnoremap <silent><M-4> :tabn4<Cr>
nnoremap <silent><M-5> :tabn5<Cr>
nnoremap <silent><M-6> :tabn6<Cr>
nnoremap <silent><M-7> :tabn7<Cr>
nnoremap <silent><M-8> :tabn8<Cr>
nnoremap <silent><M-9> :tabn9<Cr>
nnoremap <silent><M-0> :tablast<Cr>
" ---------------------------------------
" choose tab using fuzzy_findeer
" ---------------------------------------
if PlannedFzf()
    PlugAddOpt 'fzf-tabs'
    nnoremap <silent><Tab><Tab> :FzfTabs<Cr>
endif
" -----------------------------------
" choosewin
" -----------------------------------
PlugAddOpt 'vim-choosewin'
nmap <silent><Tab><Cr> <Plug>(choosewin)
