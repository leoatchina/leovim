setlocal nonu
setlocal nornu
" preview
nmap <silent><buffer>p      <Plug>(fern-action-preview:toggle)
nmap <silent><buffer><C-p>  <Plug>(fern-action-preview:auto:toggle)
nmap <silent><buffer><C-f>  <Plug>(fern-action-preview:scroll:down:half)
nmap <silent><buffer><C-b>  <Plug>(fern-action-preview:scroll:up:half)
