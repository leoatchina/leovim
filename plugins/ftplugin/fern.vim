set nonu
nmap <silent> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
nmap <silent> <buffer> v <Plug>(fern-action-open:vsplit)
nmap <silent> <buffer> x <Plug>(fern-action-open:split)
nmap <silent> <buffer> t <Plug>(fern-action-open:tabedit)
nmap <silent> <buffer> V <Plug>(fern-action-open:edit/vsplit)
nmap <silent> <buffer> X <Plug>(fern-action-open:edit/split)
nmap <silent> <buffer> T <Plug>(fern-action-open:edit/tabedit)
nmap <silent> <buffer> r <Plug>(fern-action-rename)
" pgup pgdn
nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
" preview
nmap <silent> <buffer> p <Plug>(fern-action-preview:auto:toggle)
nmap <silent> <buffer> <Tab>      <Plug>(fern-action-preview:toggle)
nmap <silent> <buffer> <Tab><Tab> <Plug>(fern-action-preview:toggle)
" dirdiff
nmap <silent> <buffer> <M-M> :ZFDirDiffMark<Cr>
