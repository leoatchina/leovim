if Planned('ZFVimDirDiff', 'ZFVimJob')
    nnoremap <leader>fm :ZFDirDiffMark<Cr>
    nnoremap <leader>fd :ZFDirDiff<Space>
endif
try
    set diffopt+=context:20
    set diffopt+=internal,algorithm:patience
catch
    finish
endtry
let g:diff_algorithms = [
            \ "myers",
            \ "minimal",
            \ "patience",
            \ "histogram",
            \ ]
let g:diff_algorithm = "patience"
func! s:DiffToggleAlgorithm()
    let l:total_diff_algos = len(g:diff_algorithms)
    let l:i = 0
    while l:i < l:total_diff_algos && g:diff_algorithms[l:i] !=# g:diff_algorithm
        let l:i += 1
    endwhile
    if l:i < l:total_diff_algos
        let g:diff_algorithm = g:diff_algorithms[(l:i + 1) % l:total_diff_algos]
    else
        let g:diff_algorithm = "patience"
    endif
    for l:algo in g:diff_algorithms
        exec "set diffopt-=algorithm:" . l:algo
    endfor
    exec "set diffopt+=algorithm:" . g:diff_algorithm
    echo "Diff algorithm switched to " . g:diff_algorithm
    windo diffupdate
endfunc
func! s:DiffToggleContext(contextLines)
    let l:opt = substitute(&diffopt, '\v(^\|,)context:\d+', '', 'g') . ",context:" . a:contextLines
    exec "set diffopt=" . l:opt
    windo diffupdate
endfunc
func! s:DiffToggleWhiteSpace()
    if stridx(&diffopt, "iwhite") >= 0
        set diffopt-=iwhite
        echo "Not ignoring whitespaces in diff"
    else
        set diffopt+=iwhite
        echo "Whitespaces ignored in diff"
    endif
    windo diffupdate
endfunc
command! DiffToggleAlgorithm call s:DiffToggleAlgorithm()
command! DiffToggleWhiteSpace call s:DiffToggleWhiteSpace()
command! -nargs=1 DiffToggleContext call s:DiffToggleContext(<f-args>)
nnoremap <leader>fta :DiffToggleAlgorithm<Cr>
nnoremap <leader>ftw :DiffToggleWhiteSpace<Cr>
nnoremap <leader>ftc :DiffToggleContext<Space>
"----------------------------------------------------------------------
" display side by side diff in a new tabpage
" usage: DiffVsp <left_file> <right_file>
"----------------------------------------------------------------------
command! -nargs=+ -complete=file DiffVsp call s:DiffVsp(<f-args>)
function! s:DiffVsp(...) abort
    if a:0 != 2
        echohl ErrorMsg
        echom 'ERROR: Require two file names.'
        echohl None
    else
        exec 'tabe ' . fnameescape(a:1)
        exec 'rightbelow vert diffsplit ' . fnameescape(a:2)
        setlocal foldlevel=20
        exec 'wincmd p'
        setlocal foldlevel=20
        exec 'normal! gg]c'
    endif
endfunc
nnoremap <leader>fv :DiffVsp<Space>

