if Installed('vim-fugitive')
    nnoremap <M-G>  :Git<Cr>
    nnoremap <M-g>; :Git blame<Cr>
    nnoremap <M-g>, :Git<Space>
    nnoremap <M-g>. :G
    nnoremap <M-g>m :Git commit -a -v<CR>
    nnoremap <M-g>u :Git push<CR>
    nnoremap <M-g>U :Git push<Space>
    " compare with history version
    let g:fugitive_summary_format = "%as-[%an]: %s"
    nnoremap <M-g>h :Git log --pretty=format:"%h\|\|%as-[%an]: %s" -- %<cr>
    nnoremap <M-g>d 0"ayiw:bw<cr>:rightbelow Gvdiff <c-r>a<cr>
elseif &rtp =~ 'asyncrun' && WINDOWS()
    nnoremap <M-G>  :AsyncRun -mode=external git status<Space>
    nnoremap <M-g>, :AsyncRun -mode=external git<Space>
    nnoremap <M-g>m :AsyncRun -mode=external git commit -a -m<Space>
    nnoremap <M-g>u :AsyncRun -mode=external git push<Cr>
    nnoremap <M-g>U :AsyncRun -mode=external git push<Space>
elseif &rtp =~ 'asyncrun' && get(g:, "has_terminal", 0) > 0
    nnoremap <M-G>  :AsyncRun -mode=term -focus=1 git status<Cr>
    nnoremap <M-g>, :AsyncRun -mode=term -focus=1 git<Space>
    nnoremap <M-g>m :AsyncRun -mode=term -focus=1 git commit -a -m<Space>
    nnoremap <M-g>u :AsyncRun -mode=term -focus=1 git push<Cr>
    nnoremap <M-g>U :AsyncRun -mode=term -focus=1 git push<Space>
else
    nnoremap <M-G>  :!git status<Cr>
    nnoremap <M-g>, :!git<Space>
    nnoremap <M-g>m :!git commit -a -m<Space>"
    nnoremap <M-g>u :!git push<Cr>
    nnoremap <M-g>U :!git push<Space>
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
if get(g:, 'terminal_plus', '') =~ 'floaterm'
    if executable('lazygit')
        nnoremap <M-g>l :FloatermNew! --height=0.8 --width=0.8 --position=center lazygit<Cr>
    endif
endif

"########## Merge ##########{{{
let s:mergeSources = {
            \  'L':      1,
            \  'LOCAL':  1,
            \  'B':      2,
            \  'BASE':   2,
            \  'R':      3,
            \  'REMOTE': 3,
            \  'M':      4,
            \  'MERGE':  4,
            \}

function!  git#createMergeTab(...)
    " Map source name to buffer number
    if a:0 > 0
        let l:sources = []
        for item in a:000
            if has_key(s:mergeSources, toupper(item))
                call add(l:sources, get(s:mergeSources, toupper(item)))
            else
                echo 'Unrecognized source: ' . item
                return
            endif
        endfor
    else
        let l:sources = [1, 4, 3]
    endif
    let l:mergeBufIndex = max([index(l:sources, 4), 0]) + 1
    tabnew
    let i = 0
    while i < len(l:sources) - 1
        exec 'buf ' . l:sources[i]
        rightbelow vsp
        let i = i + 1
    endwhile
    exec 'buf ' . l:sources[i]
    windo diffthis
    exec l:mergeBufIndex . 'wincmd w'
endfunc

command! -nargs=* MergeTab call  git#createMergeTab(<f-args>)
nnoremap <M-g>t :MergeTab<space>
