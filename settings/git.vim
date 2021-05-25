if Installed('vim-fugitive')
    nnoremap <M-g>s :Gstatus<Cr>
    nnoremap <M-g>; :Git blame<Cr>
    nnoremap <M-g>, :Git<Space>
    nnoremap <M-g>. :G
    nnoremap <M-g>m :Git commit -a -v<CR>
    nnoremap <M-g>u :Git push<CR>
    nnoremap <M-g>U :Git push<Space>
elseif &rtp =~ 'asyncrun' && g:has_terminal > 0
    nnoremap <M-g>s :AsyncRun -mode=term -focus=1 git status<Cr>
    nnoremap <M-g>, :AsyncRun -mode=term -focus=1 git<Space>
    nnoremap <M-g>m :AsyncRun -mode=term -focus=1 git commit -a -m<Space>"
    nnoremap <M-g>u :AsyncRun -mode=term -focus=1 git push<Cr>
    nnoremap <M-g>U :AsyncRun -mode=term -focus=1 git push<Space>
else
    nnoremap <M-g>s :!git status<Cr>
    nnoremap <M-g>, :!git<Space>
    nnoremap <M-g>m :!git commit -a -m<Space>"
    nnoremap <M-g>u :!git push<Cr>
    nnoremap <M-g>U :!git push<Space>
    nnoremap <M-G>  :!git<Space>
endif
if Installed('fzf.vim')
    if Installed('coc.nvim') && WINDOWS()
        nnoremap <M-g>b :CocFzfList bcommits<Cr>
        nnoremap <M-g>c :CocFzfList commits<Cr>
        nnoremap <M-g>f :CocFzfList gfiles<CR>
    elseif !WINDOWS() && !CYGWIN()
        nnoremap <M-g>b :FzfBCommits<Cr>
        nnoremap <M-g>c :FzfCommits<Cr>
        nnoremap <M-g>f :FzfGFiles?<CR>
    endif
endif
if Installed('vim-signify')
    let g:signify_disable_by_default = 1
    nnoremap <M-g>d :SignifyDiff<Cr>
    nnoremap <M-g>i :Signify
    nnoremap <M-g>o :SignifyToggle<Cr>
    nmap ]c <plug>(signify-next-hunk)
    nmap [c <plug>(signify-prev-hunk)
    omap ic <plug>(signify-motion-inner-pending)
    xmap ic <plug>(signify-motion-inner-visual)
    omap ac <plug>(signify-motion-outer-pending)
    xmap ac <plug>(signify-motion-outer-visual)
    nmap <leader>vc vic
    nmap ,vc        vac
endif
if get(g:, 'terminal_plus', '') =~ 'floaterm'
    if executable('lazygit')
        nnoremap <M-g>l :FloatermNew! --height=0.8 --width=0.8 --position=center lazygit<Cr>
    endif
endif
