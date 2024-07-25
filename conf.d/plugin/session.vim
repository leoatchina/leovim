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
nnoremap <leader>st :Startify<Cr>
nnoremap <leader>sc :SClose<Cr>
nnoremap <leader>ss :SSave<Space>
nnoremap <leader>sl :SLoad<Space>
nnoremap <leader>sd :SDelete<Space>
