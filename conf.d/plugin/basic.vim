" ------------------------------
" vim-preview
" ------------------------------
let g:preview#preview_position = "rightbottom"
let g:preview#preview_size = get(g:, 'asyncrun_open', 8)
let g:quickui_preview_h = 24
nnoremap <silent><C-w><Space> <C-w>z:call preview#cmdmsg('close preview', 0)<Cr>
PlugAddOpt 'vim-preview'
" --------------------------
" vim-quickui
" --------------------------
if v:version >= 802 || has('nvim')
    let g:quickui_border_style = 2
    if has('nvim')
        if HAS_GUI()
            let g:quickui_color_scheme = 'gruvbox'
        else
            let g:quickui_color_scheme = 'papercol dark'
        endif
    else
        if HAS_GUI()
            let g:quickui_color_scheme = 'borland'
        else
            let g:quickui_color_scheme = 'papercol light'
        endif
    endif
    PlugAddOpt 'vim-quickui'
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
    if PlannedCoc()
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
" Choose one from a list
function! s:get_char_form_lst(lst, cmd) abort
    let lst = a:lst
    let cmd = a:cmd
    for i in range(len(cmd))
        if index(lst, cmd[i]) < 0
            call add(lst, cmd[i])
            if i == 0
                return [lst, '&' . cmd]
            else
                return [lst,  cmd[:i-1] . '&' . cmd[i:]]
            endif
        endif
    endfor
    " if failed to find
    let ext = '123456789!@#$%^*-=_+'
    let l_e = len(ext)
    for i in range(l_e)
        if index(lst, ext[i]) < 0
            call add(lst, ext[i])
            return [lst, '&' . ext[i] . cmd]
        endif
    endfor
    return [lst, cmd]
endfunction
function! ChooseOne(lst, ...) abort
    let cmds = a:lst
    if len(cmds) == 0
        return ""
    endif
    if a:0
        let title = a:1
    else
        let title = "Please choose one."
    endif
    if a:0 >= 2 && a:2 >= 1
        let add_num = 1
    else
        let add_num = 0
    endif
    if len(cmds) > 9
        let cmds=cmds[:8]
    endif
    let cnt = 0
    let lines = []
    for cmd in cmds
        let cnt += 1
        if add_num
            call add(lines, '&' . cnt . ' '. cmd)
        else
            if !exists('char_lst')
                let char_lst = []
            endif
            let [char_lst, cmd] = s:get_char_form_lst(char_lst, cmd)
            call add(lines, cmd)
        endif
    endfor
    if Planned('vim-quickui')
        let opts = {'title': title, 'index':g:quickui#listbox#cursor, 'w': 64}
        let idx = quickui#listbox#inputlist(lines, opts)
        if idx >= 0
            return cmds[idx]
        endif
    else
        let cnt += 1
        if a:0 >= 3 && a:3 != ''
            call add(lines, '&' . a:3)
        else
            call add(lines, '&0None')
        endif
        let content = join(lines, "\n")
        let idx = confirm(title, content, cnt)
        if idx > 0 && idx < cnt
            return cmds[idx-1]
        endif
    endif
    return ""
endfunction
" --------------------------------
" funzzy finder
" --------------------------------
if PlannedFzf()
    source $CFG_DIR/fzf.vim
    nmap m<tab> <plug>(fzf-maps-n)
    xmap m<tab> <plug>(fzf-maps-x)
    omap m<tab> <plug>(fzf-maps-o)
    command! FzfRunCommands call FzfCallCommands('FzfRunCommands', 'Fzf', ['FzfAg', 'FzfRG'])
    nnoremap <silent><M-k><M-f> :FzfRunCommands<Cr>
endif
if PlannedLeaderf()
    nnoremap <leader>F :Leaderf
    source $CFG_DIR/leaderf.vim
    nnoremap <silent><M-k><M-l> :LeaderfSelf<Cr>
    nnoremap <silent><leader>; :Leaderf --next<Cr>
    nnoremap <silent><leader>, :Leaderf --previous<Cr>
    nnoremap <silent><leader>. :Leaderf --recall<Cr>
endif
if !PlannedLeaderf() && !PlannedFzf()
    source $CFG_DIR/ctrlp.vim
    PlugAddOpt 'ctrlp.vim'
endif
" --------------------------------
" common maps
" --------------------------------
if PrefFzf()
    nnoremap <silent><M-k>c :FzfColors<Cr>
    nnoremap <silent><M-k>t :FzfFiletypes<Cr>
    nnoremap <silent><M-k><M-k> :FzfCommands<Cr>
elseif PlannedLeaderf()
    nnoremap <silent><M-k>c :LeaderfColorscheme<Cr>
    nnoremap <silent><M-k>t :LeaderfFiletype<Cr>
    nnoremap <silent><M-k><M-k> :LeaderfCommand<Cr>
else
    nnoremap <M-k>c :colorscheme<Space>
    nnoremap <M-k>t :filetype<Space>
    nnoremap <M-k><M-k> :command<Space>
endif
if PlannedFzf() && executable('perl')
    nnoremap <silent><M-h><M-h> :FzfHelptags<Cr>
elseif PlannedLeaderf()
    nnoremap <silent><M-h><M-h> :LeaderfHelp<Cr>
else
    nnoremap <M-h><M-h> :h<Space>
endif
