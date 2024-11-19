" --------------------
" diff opt
" --------------------
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
nnoremap <leader>fDa :DiffToggleAlgorithm<Cr>
nnoremap <leader>fDw :DiffToggleWhiteSpace<Cr>
nnoremap <leader>fDc :DiffToggleContext<Space>
" --------------------
" ZFVimDirDiff
" --------------------
let g:ZFDirDiff_ignoreEmptyDir = 1
let g:ZFDirDiffKeymap_update = ['DL', '<C-l>']
let g:ZFDirDiffKeymap_updateParent = ['DH', '<C-h>']
let g:ZFDirDiffKeymap_open = ['<Cr>', 'o']
let g:ZFDirDiffKeymap_foldOpenAll = ['O']
let g:ZFDirDiffKeymap_foldOpenAllDiff = ['A']
let g:ZFDirDiffKeymap_foldClose = ['x']
let g:ZFDirDiffKeymap_foldCloseAll = ['X']
let g:ZFDirDiffKeymap_goParent = ['U', '<BS>']
let g:ZFDirDiffKeymap_diffThisDir = ['DF']
let g:ZFDirDiffKeymap_diffParentDir = ['DU']
let g:ZFDirDiffKeymap_markToDiff = ['DM']
let g:ZFDirDiffKeymap_markToSync = ['DS']
let g:ZFDirDiffKeymap_quit = ['q', '<leader>q', 'Q']
let g:ZFDirDiffKeymap_diffNext = [']c', 'DN']
let g:ZFDirDiffKeymap_diffPrev = ['[c', 'DP']
let g:ZFDirDiffKeymap_diffNextFile = ['DJ']
let g:ZFDirDiffKeymap_diffPrevFile = ['DK']
let g:ZFDirDiffKeymap_syncToHere = ['DO']
let g:ZFDirDiffKeymap_syncToThere = ['DT']
let g:ZFDirDiffKeymap_add = ['a', '+']
let g:ZFDirDiffKeymap_delete = ['DD']
let g:ZFDirDiffKeymap_getPath = ['y']
let g:ZFDirDiffKeymap_getFullPath = ['Y']
nnoremap <Leader>fd :ZFDirDiff<Space>
nnoremap <Leader>fm :ZFDirDiffMark<Cr>
nnoremap <Leader>fu :ZFDirDiffUnmark<Cr>
PlugAddOpt 'ZFVimDirDiff'
au FileType ZFDirDiff nnoremap M :tabe $HOME/.leovim/conf.d/plugin/zfvim.vim<Cr>/ZFVimDirDiff<Cr>zz
