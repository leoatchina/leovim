" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" --------------------------
" startify
" --------------------------
PlugOpt 'vim-startify'
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
    let g:startify_session_dir = utils#expand("~/.vim/session.nvim")
else
    let g:startify_session_dir = utils#expand("~/.vim/session.vim")
endif
if !isdirectory(g:startify_session_dir)
    silent! call mkdir(g:startify_session_dir, "p")
endif
nnoremap <leader>st :Startify<Cr>
nnoremap <leader>sc :SClose<Cr>
nnoremap <leader>sv :SSave<Space>
nnoremap <leader>sl :SLoad<Space>
nnoremap <leader>sd :SDelete<Space>
" --------------------------------
" Session management with fzf
" --------------------------------
if pack#planned_fzf()
    function! s:session_list()
        let lines = split(globpath(g:startify_session_dir, '*'), '\n')
        if len(lines) > 1
            return lines[1:]
        else
            return lines
        endif
    endfunction
    function! s:session_load(lines)
        if len(a:lines) == 0
            return
        endif
        execute 'SLoad ' . fnamemodify(a:lines[0], ':t')
    endfunction
    function! s:session_delete(lines)
        if len(a:lines) == 0
            return
        endif
        let confirm = ChooseOne(['yes', 'no'], "Delete selected session(s)?")
        if confirm == 'yes'
            for session in a:lines
                call startify#session_delete(1, fnamemodify(session, ':t'))
            endfor
        endif
    endfunction
    function! s:handle_key(lines, key)
        if a:key ==# 'enter'
            call s:session_load(a:lines)
        elseif a:key ==# 'ctrl-x'
            call s:session_delete(a:lines)
        endif
    endfunction
    function! s:fzf_startify_session()
        let sessions = s:session_list()
        let header = "
        \ Sessions Management:\n
        \ --------------------------------\n
        \ <Enter>   Load selected session\n
        \ <Tab>     Toggle selection mode\n
        \ <Ctrl-x>  Delete selected session(s)\n
        \ --------------------------------\n"

        let opts = {
            \ 'source': sessions,
            \ 'sink*': { lines -> s:handle_key(lines[1:], lines[0]) },
            \ 'options': [
            \   '--prompt', 'Sessions> ',
            \   '--multi',
            \   '--bind', 'tab:toggle',
            \   '--expect', 'enter,ctrl-x',
            \   '--header', header,
            \ ],
            \ }
        call fzf#run(fzf#wrap(opts))
    endfunction
    command! FzfSession call s:fzf_startify_session()
    nnoremap <silent><Leader>ss :FzfSession<Cr>
endif
