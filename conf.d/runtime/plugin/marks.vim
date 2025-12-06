if Planned('vim-signature')
    let g:SignatureMap = {
                \ 'Leader'           : "m",
                \ 'ToggleMarkAtLine' : "m.",
                \ 'PlaceNextMark'    : "m<Cr>",
                \ 'PurgeMarksAtLine' : "m,",
                \ 'PurgeMarks'       : "m;",
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
if PlannedFzf()
    nnoremap <silent><leader>M :FzfMarks<CR>
endif
PlugOpt 'vim-bookmarks'
nnoremap ms :BookmarkSave<Space>
nnoremap ml :BookmarkLoad<Space>
