if !has('quickfix')
    finish
endif
function! s:loc_opened()
    return get(getloclist(0, {'winid' : 0}), 'winid', 0) > 0
endfunction
function! s:qf_opened()
    return get(getqflist({'winid' : 0}), 'winid', 0) > 0 && !s:loc_opened()
endfunction
" open close
function! s:open_close_qfloc(buftype, type) abort
    let buftype = a:buftype
    let type = a:type
    if type < 0
        let type = 0
    endif
    if type > 2
        let type = 2
    endif
    if type < 2
        if s:qf_opened() && buftype == "qf"
            cclose
            return
        elseif s:loc_opened()
            lclose
            return
        endif
    endif
    if type > 0
        let curr_win = winnr()
        if buftype == 'qf'
            let qflist = getqflist()
            if len(qflist) == 0
                echom "No Quickfix"
            else
                copen
            endif
        else
            let loclist = getloclist(0)
            if len(loclist) == 0
                echom "No LocList"
            else
                lopen
            endif
        endif
        execute curr_win . 'wincmd w'
        sleep 100m
    endif
endfunction
command! QuickfixClose  call s:open_close_qfloc('qf', 0)
command! QuickfixToggle call s:open_close_qfloc('qf', 1)
command! QuickfixOpen   call s:open_close_qfloc('qf', 2)
command! LoclistClose  call s:open_close_qfloc('loc', 0)
command! LoclistToggle call s:open_close_qfloc('loc', 1)
command! LoclistOpen   call s:open_close_qfloc('loc', 2)
" quickfix toggle
nnoremap <silent><M-,> :QuickfixToggle<Cr>
nnoremap <silent><M-;> :LoclistToggle<Cr>
if g:has_terminal
    tnoremap <silent><M-,> <C-\><C-n>:QuickfixToggle<Cr>
    tnoremap <silent><M-;> <C-\><C-n>:LoclistToggle<Cr>
endif
if PlannedLeaderf()
    function! s:leaderf_qf_loc()
        if s:loc_opened()
            lclose
            LeaderfLocList
        elseif s:qf_opened()
            cclose
            LeaderfQuickFix
        else
            call preview#errmsg("Neigher quickfix nor loclist opened!")
        endif
    endfunction
    command! LeaderfQfLoc call s:leaderf_qf_loc()
    nnoremap <silent>Z? :LeaderfQfLoc<Cr>
endif
" ----------------------------
" bqf
" ----------------------------
if Installed('nvim-bqf')
    hi default link BqfPreviewFloat Normal
    hi default link BqfPreviewBorder Normal
    hi default link BqfPreviewCursor Cursor
    hi default link BqfPreviewRange IncSearch
    hi link BqfPreviewRange Search
    hi default BqfSign ctermfg=14 guifg=Cyan
    hi BqfPreviewBorder guifg=#50a14f ctermfg=71
    lua require("cfg/bqf")
endif
" ----------------------------
" quicker
" ----------------------------
if Installed('quicker.nvim')
    lua << EOF
    require("quicker").setup({
    keys = {
        {
                ">",
                function()

                require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                end,
                desc = "Expand quickfix context",
        },
        {
                "<",
                function()
                require("quicker").collapse()
                end,
                desc = "Collapse quickfix context",
        },
    },
    })
EOF
endif
