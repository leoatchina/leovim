" -----------------------------------
" choosewin
" -----------------------------------
PlugAddOpt 'vim-choosewin'
nmap <silent><Tab><Cr> <Plug>(choosewin)
" ---------------------------------------
" choose tab using fuzzy_findeer
" ---------------------------------------
if PlannedFzf()
    PlugAddOpt 'fzf-tabs'
    nnoremap <silent><Tab><Tab> :FzfTabs<Cr>
endif
" ------------------------
" tab control
" ------------------------
set showtabline=2
set tabpagemax=10
" Tab move
nnoremap <silent><Tab>n :tabm +1<CR>
nnoremap <silent><Tab>p :tabm -1<CR>
nnoremap <Tab><Space>   :tabm<Space>
" move current buffer to tab
nnoremap <C-w><Cr> <C-w>T
" round current buffer
nnoremap <C-w><Tab> <C-w>r
" open window in tab
nnoremap <leader><Tab> :tabe<Space>
" --------------------------
" TabSwitch / close
" --------------------------
" TabClose
nnoremap <silent><M-w> :tabclose!<Cr>
nnoremap <silent><M-W> :tabonly!<Cr>
" TabSwitch
nnoremap <M-n> gt
nnoremap <M-p> gT
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
" Map in terminal
if g:has_terminal == 0
    finish
endif
" TabClose
tnoremap <silent><M-w> <C-\><C-n>:tabclose!<Cr>
tnoremap <silent><M-W> <C-\><C-n>:tabonly!<Cr>
" TabSwitch
tnoremap <M-n> <C-\><C-n>gt
tnoremap <M-p> <C-\><C-n>gT
tnoremap <silent><M-1> <C-\><C-n>:tabn1<Cr>
tnoremap <silent><M-2> <C-\><C-n>:tabn2<Cr>
tnoremap <silent><M-3> <C-\><C-n>:tabn3<Cr>
tnoremap <silent><M-4> <C-\><C-n>:tabn4<Cr>
tnoremap <silent><M-5> <C-\><C-n>:tabn5<Cr>
tnoremap <silent><M-6> <C-\><C-n>:tabn6<Cr>
tnoremap <silent><M-7> <C-\><C-n>:tabn7<Cr>
tnoremap <silent><M-8> <C-\><C-n>:tabn8<Cr>
tnoremap <silent><M-9> <C-\><C-n>:tabn9<Cr>
tnoremap <silent><M-0> <C-\><C-n>:tablast<Cr>
