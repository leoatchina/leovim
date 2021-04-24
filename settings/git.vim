if Installed('vim-fugitive')
    nnoremap <M-g>s :Gstatus<Cr>
    nnoremap <M-g>; :Git blame<Cr>
    nnoremap <M-g>, :Git<Space>
    nnoremap <M-g>. :G
    nnoremap <M-g>m :Git commit -a -v<CR>
    nnoremap <M-g>u :Git push<CR>
    nnoremap <M-g>U :Git push<Space>
elseif executable('git')
    if &rtp =~ 'asyncrun' && g:has_terminal > 0
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
endif
if executable('git') && Installed('fzf.vim')
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
