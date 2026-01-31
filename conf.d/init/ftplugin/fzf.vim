setlocal laststatus=0 noshowmode noruler
autocmd BufLeave <buffer> set laststatus=2 showmode ruler
tnoremap <buffer><C-j> <Down>
tnoremap <buffer><C-k> <Up>
tnoremap <buffer><C-n> <Nop>
tnoremap <buffer><C-p> <Nop>
