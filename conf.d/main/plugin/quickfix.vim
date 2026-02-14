if !has('quickfix') || utils#is_vscode()
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
if pack#planned_leaderf()
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
    nnoremap <silent><M-:> :LeaderfQfLoc<Cr>
else
    nnoremap <silent><M-:> :call fzf#quickfix()<Cr>
endif
" ----------------------------
" bqf
" ----------------------------
if pack#installed('nvim-bqf')
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
" quickfix
" ----------------------------
if pack#installed('quicker.nvim')
    lua require("cfg/quicker")
elseif pack#installed('vim-qf')
    let g:qf_statusline = {}
    let g:qf_statusline.before = '%<\ '
    let g:qf_statusline.after = '\ %f%=%l\/%-6L\ \ \ \ \'
elseif exists('&quickfixtextfunc')
    function! quickfix#format(info)
        let qflist = getqflist({'id' : a:info.id, 'items' : 1}).items
        let qflist = map(qflist,
                    \ 'extend(v:val, {"filename" : bufname(v:val.bufnr)})')
        let prefix_len = 2 + max(map(copy(qflist),
                    \ 'strchars(v:val.filename . v:val.lnum)'))
        let fmt = '%-' . prefix_len . 's' . '%s'
        return map(qflist,
                    \ 'printf(fmt, v:val.filename . "|" . v:val.lnum, "|" . v:val.text)')
    endfunction
    set quickfixtextfunc=quickfix#format
else
    function! quickfix#format()
        let qflist = map(getqflist(),
                    \ 'extend(v:val, {"filename" : bufname(v:val.bufnr)})')
        let prefix_len = 2 + max(map(copy(qflist),
                    \ 'strchars(v:val.filename . v:val.lnum)'))
        let fmt = '%-' . prefix_len . 's' . '%s'
        setlocal modifiable
        call setline('1', map(qflist,
                    \ 'printf(fmt, v:val.filename . "|" . v:val.lnum, "|" . v:val.text)'))
        setlocal nomodifiable nomodified
    endfunction
    autocmd BufReadPost quickfix call QuickFixFormat()
endif
