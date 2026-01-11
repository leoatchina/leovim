if exists('g:floaterm_ai_loaded')
    finish
endif
let g:floatrerm_ai_loaded = 1
command! FloatermAiFzfFiles call floaterm#ai#fzf_file_list()
command! FloatermAiFileLine call floaterm#ai#send_file_line_range()
command! FloatermAiStart call floaterm#ai#start()