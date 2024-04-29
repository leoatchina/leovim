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
function s:fern_quit(...) abort
    if tabpagenr() == tabpagenr('$')
        call feedkeys("\<C-o>", 'n')
    elseif winnr() == winnr('#')
        call feedkeys("\<C-o>", 'n')
    elseif a:0 && a:1 > 0
        ConfirmQuit
    else
        q!
    endif
endfunction
command! FernQuit call s:fern_quit()
command! FernConfirmQuit call s:fern_quit(1)
nmap <silent><buffer>q :FernConfirmQuit<Cr>
nmap <silent><buffer>Q :FernConfirmQuit<Cr>
nmap <silent><buffer><M-q> :FernQuit<Cr>
nmap <silent><buffer><leader>q :FernQuit<Cr>
