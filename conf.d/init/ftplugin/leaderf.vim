setlocal nonu
nmap <buffer><C-c> q
if has('nvim')
    autocmd BufLeave <buffer> stopinsert
endif
