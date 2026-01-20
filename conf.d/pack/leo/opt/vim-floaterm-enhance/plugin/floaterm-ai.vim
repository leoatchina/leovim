if exists('g:floaterm_ai_loaded')
    finish
endif
let g:floaterm_ai_loaded = 1
command! FloatermAiFzfFiles call floaterm#ai#fzf_file_list()
command! FloatermAiFileLine call floaterm#ai#send_file_line_range()
command! FloatermAiStart call floaterm#ai#start()
function! s:update_ai_bufnr() abort
    let bufnr = floaterm#buflist#curr()
    if bufnr && floaterm#config#get(bufnr, 'program', 'PROG') == 'AI'
        call floaterm#ai#set_ai_bufnr(bufnr)
    endif
endfunction
augroup UpdateAiBufnr
    autocmd!
    autocmd User FloatermOpen call s:update_ai_bufnr()
augroup END
" ------------------------------------------------------------
" Start. NOTE ! = <bang>0  means `no choose` == start_now
" ------------------------------------------------------------
command! -bang FloatermAiStart call floaterm#ai#start(<bang>0)
" ------------------------------------------------------------
" SendCrOrStart. NOTE ! = <bang>0 means stay in floaterm
" ------------------------------------------------------------
command! -bang FloatermAiSendCr call floaterm#ai#send_cr(0, <bang>0)
" -------------------------------------------------------------------------------
" commands. NOTE <bang>0 means ! in Send commands means stay in floaterm
" -------------------------------------------------------------------------------
command! -bang FloatermAiSendFile call floaterm#ai#send_file(<bang>0)
command! -bang FloatermAiSendDir call floaterm#ai#send_dir(<bang>0)
command! -bang FloatermAiFzfFiles call floaterm#ai#fzf_file(<bang>0)
command! -bang -range FloatermAiSendLineRange <line1>,<line2>call floaterm#ai#send_line_range(<bang>0)
