setlocal nonu
nmap <silent><buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
nmap <silent><buffer> <C-]> <Plug>(fern-action-open:vsplit)
nmap <silent><buffer> <C-x> <Plug>(fern-action-open:split)
nmap <silent><buffer> <C-t> <Plug>(fern-action-open:tabedit)
" preview
nmap <silent><buffer> P <Plug>(fern-action-preview:toggle)
nmap <silent><buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
nmap <silent><buffer> <C-f> <Plug>(fern-action-preview:scroll:down:half)
nmap <silent><buffer> <C-b> <Plug>(fern-action-preview:scroll:up:half)
" smart close preview
nmap <silent><buffer>q :call feedkeys("\<C-o>", 'n')<Cr>
nmap <silent><buffer>Q :call feedkeys("\<C-o>", 'n')<Cr>
