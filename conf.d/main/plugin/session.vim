" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" startify settings live in cfg/startify.vim
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
        return split(globpath(g:startify_session_dir, '*'), '\n')
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
        let confirm = utils#choose_one(['yes', 'no'], "Delete selected session(s)?")
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
