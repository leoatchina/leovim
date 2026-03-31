setlocal statusline=
autocmd BufEnter <buffer> setlocal laststatus=0 noshowmode noruler
autocmd BufLeave <buffer> setlocal laststatus=2 showmode ruler
