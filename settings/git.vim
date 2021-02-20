if Installed('vim-fugitive')
    nnoremap <M-g>s :Gstatus<Cr>
    nnoremap <M-g>. :Git blame<Cr>
    nnoremap <M-g>, :Git<Space>
    nnoremap <M-g>m :Git commit -a -v<CR>
    nnoremap <M-g>p :Git push<CR>
    nnoremap <M-g>u :Git push<Space>
elseif executable('git')
    if &rtp =~ 'asyncrun' && g:has_terminal > 0
        nnoremap <M-g>s :AsyncRun -mode=term -focus=1 git status<Cr>
        nnoremap <M-g>, :AsyncRun -mode=term -focus=1 git<Space>
        nnoremap <M-g>m :AsyncRun -mode=term -focus=1 git commit -a -m<Space>"
        nnoremap <M-g>p :AsyncRun -mode=term -focus=1 git push<Cr>
        nnoremap <M-g>u :AsyncRun -mode=term -focus=1 git push<Space>
    else
        nnoremap <M-G>  :!git<Space>
        nnoremap <M-g>s :!git status<Cr>
        nnoremap <M-g>, :!git<Space>
        nnoremap <M-g>m :!git commit -a -m<Space>"
        nnoremap <M-g>p :!git push<Cr>
        nnoremap <M-g>u :!git push<Space>
    endif
endif
if executable('git') && Installed('fzf.vim')
    nnoremap <M-g>b :FzfBCommits<Cr>
    nnoremap <M-g>c :FzfCommits<Cr>
    nnoremap <M-g>f :FzfGFiles?<CR>
endif
