let g:ZFDirDiff_ignoreEmptyDir = 1
let g:ZFDirDiffKeymap_update = ['DL', '<C-l>']
let g:ZFDirDiffKeymap_updateParent = ['DH', '<C-h>']
let g:ZFDirDiffKeymap_open = ['<Cr>', 'o']
let g:ZFDirDiffKeymap_foldOpenAll = ['O']
let g:ZFDirDiffKeymap_foldOpenAllDiff = ['A']
let g:ZFDirDiffKeymap_foldClose = ['c']
let g:ZFDirDiffKeymap_foldCloseAll = ['C']
let g:ZFDirDiffKeymap_goParent = ['U', '<BS>']
let g:ZFDirDiffKeymap_diffThisDir = ['DF']
let g:ZFDirDiffKeymap_diffParentDir = ['DU']
let g:ZFDirDiffKeymap_markToDiff = ['DM']
let g:ZFDirDiffKeymap_markToSync = ['DS']
let g:ZFDirDiffKeymap_quit = ['q', '<leader>q', 'Q']
let g:ZFDirDiffKeymap_diffNext = ['DJ', ';d']
let g:ZFDirDiffKeymap_diffPrev = ['DK', ',d']
let g:ZFDirDiffKeymap_diffNextFile = [';c']
let g:ZFDirDiffKeymap_diffPrevFile = [',c']
let g:ZFDirDiffKeymap_syncToHere = ['DO']
let g:ZFDirDiffKeymap_syncToThere = ['DT']
let g:ZFDirDiffKeymap_add = ['a', '+']
let g:ZFDirDiffKeymap_delete = ['DD']
let g:ZFDirDiffKeymap_getPath = ['y']
let g:ZFDirDiffKeymap_getFullPath = ['Y']
nnoremap <Leader>fd :ZFDirDiff<Space>
nnoremap <Leader>fm :ZFDirDiffMark<Cr>
nnoremap <Leader>fu :ZFDirDiffUnmark<Cr>
au FileType ZFDirDiff nnoremap <F1> :tabe $CFG_DIR/zfdirdiff.vim<Cr>
au FileType ZFDirDiff nnoremap g?   :tabe $CFG_DIR/zfdirdiff.vim<Cr>
