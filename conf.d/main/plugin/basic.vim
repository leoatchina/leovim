" ------------------------------
" Skip in VSCode environment
" ------------------------------
if utils#is_vscode()
    finish
endif
" --------------------------
" vim-quickui
" --------------------------
if pack#planned('vim-quickui')
    let g:quickui_border_style = 2
    if has('nvim')
        if utils#has_gui()
            let g:quickui_color_scheme = 'gruvbox'
        else
            let g:quickui_color_scheme = 'papercol dark'
        endif
    else
        if utils#has_gui()
            let g:quickui_color_scheme = 'borland'
        else
            let g:quickui_color_scheme = 'papercol light'
        endif
    endif
    nnoremap <silent><M-k>m :call quickui#tools#display_messages()<Cr>
    function! s:preview_popup_file(filename) abort
        let filename = a:filename
        let fopts = {'cursor':-1, 'number':1, 'persist':0, 'w':80, 'h':64}
        call quickui#preview#open(filename, fopts)
    endfunction
    command! -nargs=1 -complete=file PreviewPopupFile call s:preview_popup_file(<f-args>)
    nnoremap <Tab>o :PreviewPopupFile
    nnoremap <F13> :call quickui#preview#scroll(1)<Cr>
    nnoremap <F14> :call quickui#preview#scroll(-1)<Cr>
    if pack#installed_coc()
        nmap <silent><expr><C-j> coc#float#has_scroll() ? coc#float#scroll(1) : quickui#preview#visible() > 0 ? "\<F13>" : "\%"
        nmap <silent><expr><C-k> coc#float#has_scroll() ? coc#float#scroll(0) : quickui#preview#visible() > 0 ? "\<F14>" : "\g%"
    else
        nmap <silent><expr><C-j> quickui#preview#visible() > 0 ? "\<F13>" : "\%"
        nmap <silent><expr><C-k> quickui#preview#visible() > 0 ? "\<F14>" : "\g%"
    endif
else
    nnoremap <Tab>o :PreviewFile
    nnoremap <silent><M-k>m :messages<Cr>
    nmap <C-j> %
    nmap <C-k> g%
endif
xmap <C-j> %
xmap <C-k> g%
" --------------------------------
" funzzy finder
" --------------------------------
if pack#planned_fzf()
    source $CFG_DIR/fzf.vim
    nmap m<tab> <plug>(fzf-maps-n)
    xmap m<tab> <plug>(fzf-maps-x)
    omap m<tab> <plug>(fzf-maps-o)
    command! FzfRunCommands call FzfCallCommands('FzfRunCommands', 'Fzf', ['FzfAg', 'FzfRG'])
    nnoremap <silent><M-k><M-f> :FzfRunCommands<Cr>
endif
if pack#planned_leaderf()
    nnoremap <leader>F :Leaderf
    nnoremap <silent><leader>L :Leaderf --recall<Cr>
    nnoremap <silent><leader>; :Leaderf --next<Cr>
    nnoremap <silent><leader>, :Leaderf --previous<Cr>
    nnoremap <silent><M-k><M-l> :LeaderfSelf<Cr>
    source $CFG_DIR/leaderf.vim
endif
" --------------------------------
" common maps
" --------------------------------
if pack#planned_leaderf()
    nnoremap <silent><M-k>t :LeaderfColorscheme<Cr>
    nnoremap <silent><M-k>f :LeaderfFiletype<Cr>
    nnoremap <silent><M-k><M-k> :LeaderfCommand<Cr>
elseif pack#pref_fzf()
    nnoremap <silent><M-k>t :FzfColors<Cr>
    nnoremap <silent><M-k>f :FzfFiletypes<Cr>
    nnoremap <silent><M-k><M-k> :FzfCommands<Cr>
else
    nnoremap <M-k>t :colorscheme<Space>
    nnoremap <M-k>f :filetype<Space>
    nnoremap <M-k><M-k> :command<Space>
endif
if pack#planned_leaderf()
    nnoremap <silent><M-h><M-h> :LeaderfHelp<Cr>
elseif pack#planned_fzf() && executable('perl')
    nnoremap <silent><M-h><M-h> :FzfHelptags<Cr>
else
    nnoremap <M-h><M-h> :h<Space>
endif
