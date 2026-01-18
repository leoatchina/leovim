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
        call floaterm#ai#update_ai_bufnr(bufnr)
    endif
endfunction
augroup UpdateAiBufnr
    autocmd!
    autocmd User FloatermOpen call s:update_ai_bufnr()
augroup END
command! -bang -range FloatermAiSendLineRange <line1>,<line2>call floaterm#ai#send_line_range(<bang>0)