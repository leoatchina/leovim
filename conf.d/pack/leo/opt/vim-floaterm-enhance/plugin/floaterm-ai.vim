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
command! -bang FloatermAiStart call floaterm#ai#start(<bang>0)
command! -bang FloatermAiSendCr call floaterm#ai#send_cr_or_start(0, <bang>0)
command! -bang FloatermAiSendCrOrStart call floaterm#ai#send_cr_or_start(1, <bang>0)
command! -bang FloatermAiSendFile call floaterm#ai#send_file(<bang>0)
command! -bang FloatermAiSendDir call floaterm#ai#send_dir(<bang>0)
command! -bang FloatermAiFzfFiles call floaterm#ai#fzf_file(<bang>0)
command! -bang -range FloatermAiSendLineRange <line1>,<line2>call floaterm#ai#send_line_range(<bang>0)
