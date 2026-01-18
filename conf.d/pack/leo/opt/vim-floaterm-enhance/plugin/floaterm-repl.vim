if exists('g:floaterm_repl_loaded')
    finish
endif
let g:floaterm_repl_loaded = 1
let g:floaterm_ft_repl_programs = get(g:, 'floaterm_ft_repl_programs', {})
" repl add_program
call floaterm#repl#update_program('python', ['ipython --no-autoindent', 'python3', 'python', 'ptipython', 'ptpython'])
call floaterm#repl#update_program('r', ['radian', 'R'])
call floaterm#repl#update_program('sh', ['bash', 'zsh', 'fish'])
call floaterm#repl#update_program('lua', ['lua'])
call floaterm#repl#update_program('vim', ['vim -e'])
call floaterm#repl#update_program('php', ['psysh', 'php -a'])
call floaterm#repl#update_program('ps1', ['powershell -noexit -executionpolicy bypass'])
call floaterm#repl#update_program('perl', ['perlconsole', 'reply', 're.pl'])
call floaterm#repl#update_program('ruby', ['irb'])
call floaterm#repl#update_program('julia', ['julia'])
call floaterm#repl#update_program('javascript', ['node'])
" block mark
let g:floaterm_repl_block_mark = get(g:, 'floaterm_repl_block_mark', {})
let g:floaterm_repl_block_mark.default = '# %%'
let g:floaterm_repl_block_mark.python = ['# %%', '# In\[\d*\]', '# STEP\d\+']
let g:floaterm_repl_block_mark.r = g:floaterm_repl_block_mark.python
let g:floaterm_repl_block_mark.javascript = ['// %%', '// In\[\d*\]', '// STEP\d\+']
let g:floaterm_repl_block_mark.vim = '" %%'
" clear command
let g:floaterm_repl_clear = get(g:, 'floaterm_repl_clear', {})
let g:floaterm_repl_clear.javascript = '.clear'
let g:floaterm_repl_clear.python = 'clear'
" exit command
let g:floaterm_repl_exit = get(g:, 'floaterm_repl_exit', {})
let g:floaterm_repl_exit.javascript = '.exit'
let g:floaterm_repl_exit.python = 'exit'
let g:floaterm_repl_exit.vim = 'vis'
let g:floaterm_repl_exit.r = 'quit'
" ----------------------------------
" commands. NOTE <bang>0 means move forword
" ----------------------------------
command! -bang FloatermReplStart call floaterm#repl#start_now()
command! -bang FloatermReplChoose call floaterm#repl#start_choose()
command! -bang -range FloatermReplSend <line1>,<line2>call floaterm#repl#send(<bang>0)
command! -bang FloatermReplSendBlock call floaterm#repl#send_border("block", <bang>0)
command! -bang FloatermReplSendFromBegin call floaterm#repl#send_border("begin", <bang>0)
command! -bang FloatermReplSendToEnd call floaterm#repl#send_border("end", <bang>0)
command! -bang FloatermReplSendAll call floaterm#repl#send_border("all", <bang>0)
" Commands for newline/clear/exit using dedicated functions
command! FloatermReplSendCrOrStart call floaterm#repl#send_cr_or_start()
command! FloatermReplSendClear call floaterm#repl#send_clear()
command! FloatermReplSendExit call floaterm#repl#send_exit()
" work
command! FloatermReplSendWord call floaterm#repl#send_word()
" mark
command! -range FloatermReplMark <line1>,<line2>call floaterm#repl#mark()
command! FloatermReplSendMark call floaterm#repl#send_mark()
command! FloatermReplShowMark call floaterm#repl#show_mark()
