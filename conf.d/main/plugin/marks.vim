" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#installed_snacks()
    nnoremap <silent><leader>m <Cmd>lua Snacks.picker.marks()<Cr>
elseif pack#installed_fuzzbox()
    nnoremap <silent><leader>m :FuzzyMarks<CR>
elseif pack#planned_fzf()
    nnoremap <silent><leader>m :FzfMarks<CR>
endif
if pack#installed('vim-signature')
    let g:SignatureMap = {
                \ 'Leader'           : "m",
                \ 'PlaceNextMark'    : "m;",
                \ 'ToggleMarkAtLine' : "m<Cr>",
                \ 'PurgeMarksAtLine' : "m.",
                \ 'PurgeMarks'       : "m,",
                \ 'PurgeMarkers'     : "m<Bs>",
                \ 'DeleteMark'       : "dm",
                \ 'ListBufferMarks'   : "m/",
                \ 'ListBufferMarkers' : "m?",
                \ 'GotoNextLineAlpha' : ";m",
                \ 'GotoPrevLineAlpha' : ",m",
                \ 'GotoNextSpotAlpha' : ";M",
                \ 'GotoPrevSpotAlpha' : ",M",
                \ 'GotoNextLineByPos' : "]m",
                \ 'GotoPrevLineByPos' : "[m",
                \ 'GotoNextSpotByPos' : "]M",
                \ 'GotoPrevSpotByPos' : "[M",
                \ }
endif
if pack#installed('vim-bookmarks')
    nmap mj <Plug>BookmarkMoveDown
    nmap mk <Plug>BookmarkMoveUp
endif
