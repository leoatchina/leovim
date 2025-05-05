let g:floaterm_repl_programs = get(g:, 'floaterm_repl_programs', {})
" repl add_program
call floaterm#repl#add_program('python', 'ipython --no-autoindent', 'python3', 'python', 'ptipython', 'ptpython')
call floaterm#repl#add_program('r', 'radian', 'R')
call floaterm#repl#add_program('sh', 'bash', 'zsh', 'fish')
call floaterm#repl#add_program('php', 'psysh', 'php -a')
call floaterm#repl#add_program('ps1', 'powershell -noexit -executionpolicy bypass')
call floaterm#repl#add_program('perl', 'perlconsole', 'reply', 're.pl')
call floaterm#repl#add_program('lua', 'lua')
call floaterm#repl#add_program('vim', 'vim -e')
call floaterm#repl#add_program('rudy', 'irb')
call floaterm#repl#add_program('julia', 'julia')
call floaterm#repl#add_program('javascript', 'node')
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
" update open postion
" ----------------------------------
call floaterm#repl#update_open_position()
au VimResized * call floaterm#repl#update_open_position()
" ----------------------------------
" commands. NOTE <bang>0 means move forword
" ----------------------------------
command! -bang FloatermReplStart call floaterm#repl#start(<bang>0)
command! -bang -range FloatermReplSend call floaterm#repl#send(<line1>, <line2>, <bang>0)
command! -bang -range FloatermReplSendVisual call floaterm#repl#send(<line1>, <line2>, <bang>0, 1)
command! -bang FloatermReplSendBlock call floaterm#repl#send_border("block", <bang>0)
command! -bang FloatermReplSendFromBegin call floaterm#repl#send_border("begin", <bang>0)
command! -bang FloatermReplSendToEnd call floaterm#repl#send_border("end", <bang>0)
command! -bang FloatermReplSendAll call floaterm#repl#send_border("all", <bang>0)
" Commands for newline/clear/exit using dedicated functions
command! FloatermReplSendNewlineOrStart call floaterm#repl#send_newline()
command! FloatermReplSendClear call floaterm#repl#send_clear()
command! FloatermReplSendExit call floaterm#repl#send_exit()
command! -bang -range FloatermReplSendWord call floaterm#repl#send_word(<bang>0)
" mark
command! -bang -range FloatermReplMark call floaterm#repl#mark(<bang>0)
command! FloatermReplSendMark call floaterm#repl#send_mark()
command! FloatermReplShowMark call floaterm#repl#show_mark()
