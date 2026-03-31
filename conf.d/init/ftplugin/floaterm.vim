setlocal statusline=
autocmd BufEnter <buffer> call lightline#disable()
autocmd BufLeave <buffer> call lightline#enable() | call lightline#update()
