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
" --------------------
" ZFIgnore
" --------------------
PlugAddOpt 'ZFVimJob'
function! s:ZFIgnore_LeaderF()
    let ignore = ZFIgnoreGet()
    let g:Lf_WildIgnore = {'file' : ignore['file'], 'dir' : ignore['dir']}
endfunction
autocmd User ZFIgnoreOnUpdate call s:ZFIgnore_LeaderF()
autocmd User ZFIgnoreOnUpdate let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
let g:ZFIgnoreOption_ZFDirDiff = {
            \ 'bin' : 0,
            \ 'media' : 0,
            \ 'ZFDirDiff' : 1,
            \ }
let g:ZFIgnore_ignore_gitignore_detectOption = {
            \ 'pattern' : '\.wildignore',
            \ 'path' : '',
            \ 'cur' : 1,
            \ 'parent' : 1,
            \ 'parentRecursive' : 0,
            \ }
PlugAddOpt 'ZFVimIgnore'
autocmd User ZFIgnoreOnToggle let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
" --------------------
" ZFVimBackup
" --------------------
let g:ZFBackup_autoEnable = 0
nnoremap <M-j><M-s> :ZFBackupSave<Cr>
nnoremap <M-j><M-l> :ZFBackupList<Cr>
nnoremap <M-j><M-d> :ZFBackupListDir<Cr>
nnoremap <M-j><M-m> :ZFBackupRemove<Cr>
nnoremap <M-j><M-r> :ZFBackupRemoveDir<Cr>
function! s:zfbackup_cleanup() abort
    let confirm = ChooseOne(['yes', 'no'], "Cleanup all ZFBackup files")
    if confirm == 'yes'
        if WINDOWS()
            exec printf('!del %s\*.* /a /f /q', ZFBackup_backupDir())
        else
            exec printf('!rm -rf %s/*.*', ZFBackup_backupDir())
        endif
    endif
endfunction
nnoremap <silent><M-j><M-c> :call <SID>zfbackup_cleanup()<Cr>
function! s:zfbackup_savedir() abort
    let confirm = ChooseOne(['yes', 'no'], "Save current dir using ZFBackup?")
    if confirm == 'yes'
        call preview#cmdmsg("Start to save files under current dir", 1)
        ZFBackupSaveDir
    endif
endfunction
nnoremap <silent><M-j><M-b> :call <SID>zfbackup_savedir()<Cr>
PlugAddOpt 'ZFVimBackup'
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
let g:ZFDirDiffKeymap_diffThisDir = ['DF', 'cd']
let g:ZFDirDiffKeymap_diffParentDir = ['u']
let g:ZFDirDiffKeymap_goParent = ['U', '<BS>']
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
let g:ZFDirDiffKeymap_delete = ['dd']
let g:ZFDirDiffKeymap_getPath = ['y']
let g:ZFDirDiffKeymap_getFullPath = ['Y']
nnoremap <Leader>fd :ZFDirDiff<Space>
nnoremap <Leader>fm :ZFDirDiffMark<Cr>
nnoremap <Leader>fu :ZFDirDiffUnmark<Cr>
PlugAddOpt 'ZFVimDirDiff'
au FileType ZFDirDiff nnoremap M :tabe +77 $HOME/.leovim/conf.d/plugin/zdiff.vim<Cr>
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
nnoremap <leader>fta :DiffToggleAlgorithm<Cr>
nnoremap <leader>ftw :DiffToggleWhiteSpace<Cr>
nnoremap <leader>ftc :DiffToggleContext<Space>
