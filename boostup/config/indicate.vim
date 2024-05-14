" --------------------
" indentline
" --------------------
filetype plugin indent on
if Installed('indent-blankline.nvim')
    luafile $LUA_DIR/ibl.lua
elseif Installed('indentline')
    let g:vim_json_conceal = 0
    let g:indentLine_enabled = 0
    let g:markdown_syntax_conceal = 0
    let g:indentLine_char_list = ['|', '¦', '┆', '┊']
    nnoremap <silent><leader>i :IndentLinesToggle<Cr>
endif
" --------------------
" WhichKey
" --------------------
set timeout
set ttimeout
set ttimeoutlen=60
set timeoutlen=300
set updatetime=200
if get(g:, 'leovim_whichkey', 1)
    nnoremap ]c ]c
    nnoremap [c [c
    let g:which_key_group_dicts = ''
    let g:which_key_use_floating_win = g:has_popup_floating
    PlugAddOpt 'vim-which-key'
    nnoremap [ :WhichKey '['<Cr>
    nnoremap ] :WhichKey ']'<Cr>
    " basic keys
    nnoremap <Tab> :WhichKey '<Tab>'<Cr>
    nnoremap <Space> :WhichKey ' '<Cr>
    nnoremap , :WhichKey ','<Cr>
    nnoremap \ :WhichKey '\'<Cr>
    nnoremap yo :WhichKey 'yo'<Cr>
    xnoremap <Space> :WhichKeyVisual ' '<Cr>
    xnoremap , :WhichKeyVisual ','<Cr>
    xnoremap \ :WhichKeyVisual '\'<Cr>
    " gmzs whichkey
    nnoremap g<Space> :WhichKey 'g'<Cr>
    nnoremap m<Space> :WhichKey 'm'<Cr>
    nnoremap s<Space> :WhichKey 's'<Cr>
    nnoremap S<Space> :WhichKey 'S'<Cr>
    nnoremap z<Space> :WhichKey 'z'<Cr>
    nnoremap Z<Space> :WhichKey 'Z'<Cr>
    " C- keys
    nnoremap <C-\> :WhichKey "\<C-Bslash\>"<Cr>
    nnoremap <C-f> :WhichKey "\<C-f\>"<Cr>
    xnoremap <C-f> :WhichKeyVisual "\<C-f\>"<Cr>
    " M- keys
    nnoremap <M-g> :WhichKey "\<M-g\>"<Cr>
    nnoremap <M-h> :WhichKey "\<M-h\>"<Cr>
    nnoremap <M-j> :WhichKey "\<M-j\>"<Cr>
    nnoremap <M-k> :WhichKey "\<M-k\>"<Cr>
    nnoremap <M-l> :WhichKey "\<M-l\>"<Cr>
    nnoremap <M-y> :WhichKey "\<M-y\>"<Cr>
    inoremap <M-y> <C-o>:WhichKey "\<M-y\>"<Cr>
    if Installed("copilotchat.nvim") || Installed("gp.nvim")
        nnoremap <M-i> :WhichKey "\<M-i\>"<Cr>
        xnoremap <M-i> :WhichKeyVisual "\<M-i\>"<Cr>
        inoremap <M-i> <C-o>:WhichKey "\<M-i\>"<Cr>
    endif
    if Installed("vim-table-mode")
        nnoremap <M-t> :WhichKey "\<M-t\>"<Cr>
        xnoremap <M-t> :WhichKeyVisual "\<M-t\>"<Cr>
    endif
    if g:has_terminal
        nnoremap <M-e> :WhichKey "\<M-e\>"<Cr>
        xnoremap <M-e> :WhichKeyVisual "\<M-e\>"<Cr>
    endif
    if get(g:, 'debug_tool', '') != ''
        nnoremap <M-d> :WhichKey "\<M-d\>"<Cr>
        nnoremap <M-m> :WhichKey "\<M-m\>"<Cr>
    endif
    if Installed('vim-fugitive')
        au FileType fugitive nnoremap <buffer>g :WhichKey "g"<Cr>
        au FileType fugitive nnoremap <buffer>c :WhichKey "c"<Cr><Cr>
        au FileType fugitive nnoremap <buffer>d :WhichKey "d"<Cr>
        au FileType fugitive nnoremap <buffer>r :WhichKey "r"<Cr>
    endif
    if Installed('gv.vim')
        au FileType GV nnoremap <buffer><C-c>
    endif
endif
" --------------------------
" show impport config
" --------------------------
function! s:getVimVersion()
    let l:result=[]
    if has('nvim')
        if HAS_GUI()
            call add(l:result, 'gnvim-')
        else
            call add(l:result, 'nvim-')
        endif
        let v = api_info().version
        call add(l:result, printf('%d.%d.%d', v.major, v.minor, v.patch))
    else
        if HAS_GUI()
            call add(l:result, 'gvim-')
        else
            call add(l:result, 'vim-')
        endif
        redir => l:msg | silent! execute ':version' | redir END
        call add(l:result, matchstr(l:msg, 'VIM - Vi IMproved\s\zs\d.\d\ze'))
        call add(l:result, '.')
        call add(l:result, matchstr(l:msg, '\v\zs\d{1,5}\ze\n'))
    endif
    return join(l:result, "")
endfunction
function! Version()
    let params_dict = {
                \ 'version':         s:getVimVersion(),
                \ 'python_version':  g:python_version,
                \ 'tree_browser':    g:tree_browser,
                \ 'colors_name':     g:colors_name,
                \ 'complete_engine': g:complete_engine
                \ }
    if get(g:, 'python3_host_prog', '') != ''
        let params_dict['python3_host_prog'] = g:python3_host_prog
    endif
    if get(g:, 'python_path', '') != ''
        let params_dict['python_path'] = g:python_path
    endif
    if get(g:, 'search_tool', '') != ''
        let params_dict['search_tool'] = g:search_tool
    endif
    if get(g:, 'debug_tool', '') != ''
        let params_dict['debug_tool'] = g:debug_tool
    endif
    if get(g:, 'symbol_tool', '') != ''
        let params_dict['symbol_tool'] = g:symbol_tool
    endif
    if get(g:, 'check_tool', '') != ''
        let params_dict['check_tool'] = g:check_tool
    endif
    if get(g:, 'input_method', '') != ''
        let params_dict['input_method'] = g:input_method
    endif
    if has('nvim') && exists('$TERM') && $TERM != ''
        let params_dict['term'] = $TERM
    elseif !has('nvim') && exists('&term') && &term != ''
        let params_dict['term'] = &term
    endif
    echom string(params_dict)
endfunction
command! Version call Version()
nnoremap <M-k>v :Version<Cr>
nnoremap <M-k>V :version<Cr>
" --------------------------
" startify
" --------------------------
PlugAddOpt 'vim-startify'
autocmd User Startified setlocal buflisted
let g:startify_session_before_save = ['call sidebar#close_all()']
let g:startify_custom_header = [
            \ '        LLLLLLLLLLL             EEEEEEEEEEEEEEEEEEEEEE     OOOOOOOOO     VVVVVVVV           VVVVVVVVIIIIIIIIIIMMMMMMMM               MMMMMMMM ',
            \ '        L:::::::::L             E::::::::::::::::::::E   OO:::::::::OO   V::::::V           V::::::VI::::::::IM:::::::M             M:::::::M ',
            \ '        L:::::::::L             E::::::::::::::::::::E OO:::::::::::::OO V::::::V           V::::::VI::::::::IM::::::::M           M::::::::M ',
            \ '        LL:::::::LL             EE::::::EEEEEEEEE::::EO:::::::OOO:::::::OV::::::V           V::::::VII::::::IIM:::::::::M         M:::::::::M ',
            \ '          L:::::L                 E:::::E       EEEEEEO::::::O   O::::::O V:::::V           V:::::V   I::::I  M::::::::::M       M::::::::::M ',
            \ '          L:::::L                 E:::::E             O:::::O     O:::::O  V:::::V         V:::::V    I::::I  M:::::::::::M     M:::::::::::M ',
            \ '          L:::::L                 E::::::EEEEEEEEEE   O:::::O     O:::::O   V:::::V       V:::::V     I::::I  M:::::::M::::M   M::::M:::::::M ',
            \ '          L:::::L                 E:::::::::::::::E   O:::::O     O:::::O    V:::::V     V:::::V      I::::I  M::::::M M::::M M::::M M::::::M ',
            \ '          L:::::L                 E:::::::::::::::E   O:::::O     O:::::O     V:::::V   V:::::V       I::::I  M::::::M  M::::M::::M  M::::::M ',
            \ '          L:::::L                 E::::::EEEEEEEEEE   O:::::O     O:::::O      V:::::V V:::::V        I::::I  M::::::M   M:::::::M   M::::::M ',
            \ '          L:::::L                 E:::::E             O:::::O     O:::::O       V:::::V:::::V         I::::I  M::::::M    M:::::M    M::::::M ',
            \ '          L:::::L         LLLLLL  E:::::E       EEEEEEO::::::O   O::::::O        V:::::::::V          I::::I  M::::::M     MMMMM     M::::::M ',
            \ '        LL:::::::LLLLLLLLL:::::LEE::::::EEEEEEEE:::::EO:::::::OOO:::::::O         V:::::::V         II::::::IIM::::::M               M::::::M ',
            \ '        L::::::::::::::::::::::LE::::::::::::::::::::E OO:::::::::::::OO           V:::::V          I::::::::IM::::::M               M::::::M ',
            \ '        L::::::::::::::::::::::LE::::::::::::::::::::E   OO:::::::::OO              V:::V           I::::::::IM::::::M               M::::::M ',
            \ '        LLLLLLLLLLLLLLLLLLLLLLLLEEEEEEEEEEEEEEEEEEEEEE     OOOOOOOOO                 VVV            IIIIIIIIIIMMMMMMMM               MMMMMMMM ',
            \ ]
let g:startify_files_number = 10
let g:startify_session_number = 10
let g:startify_list_order = [
            \ ['   最近项目:'],
            \ 'sessions',
            \ ['   最近文件:'],
            \ 'files',
            \ ['   快捷命令:'],
            \ 'commands',
            \ ['   常用书签:'],
            \ 'bookmarks',
            \ ]
let g:startify_commands = [
            \ {'v': ['重要插件', 'call Version()']},
            \ {'V': ['基本信息', 'version']},
            \ ]
if has('nvim')
    let g:startify_session_dir = Expand("~/.vim/session.nvim")
else
    let g:startify_session_dir = Expand("~/.vim/session.vim")
endif
if !isdirectory(g:startify_session_dir)
    silent! call mkdir(g:startify_session_dir, "p")
endif
nnoremap <leader>fS :Startify<Cr>
nnoremap <leader>fs :SSave<Space>
nnoremap <leader>fl :SLoad<Space>
nnoremap <leader>fx :SDelete<Space>
