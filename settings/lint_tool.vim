let s:flake8_ignore = "E501,E302,E251,E231,E226,E221,E127,E126,E123,W291,F405,F403"
nnoremap <M-k>, :lprev<cr>
nnoremap <M-k>; :lnext<cr>
if get(g:, 'complete_engine', '') == 'YCM'
    nnoremap <M-k>d :YcmDiags<Cr>
endif
if get(g:, 'lint_tool', '') == 'coc' && Installed('coc.nvim')
    if WINDOWS()
        if get(g:, 'fuzzy_finder', '') == 'leaderf'
            nnoremap <silent> <leader>d :CocDiagnostics<CR>:CloseQuickfix<Cr>:Leaderf loclist<Cr>
        else
            nnoremap <silent> <leader>d :CocDiagnostics<CR>
        endif
    else
        nnoremap <silent> <leader>d :CocFzfList diagnostics<CR>
    endif
    nmap <silent> <M-k>n <Plug>(coc-diagnostic-next-error)
    nmap <silent> <M-k>p <Plug>(coc-diagnostic-prev-error)
    highlight def CocUnderLine cterm=NONE gui=NONE
    highlight def link CocErrorHighlight   CocUnderLine
    highlight def link CocWarningHighlight NONE
    highlight def link CocInfoHighlight    NONE
    highlight def link CocHintHighlight    NONE
    call coc#config('diagnostic.enable', v:true)
    call coc#config('diagnostic.messageTarget', "echo")
    call coc#config('diagnostic.errorSign', 'x')
    call coc#config('diagnostic.warningSign', "!")
    call coc#config('diagnostic.infoSign', ">")
    call coc#config('diagnostic.hintSign', "-")
    call coc#config('python.linting.flake8Args', [
                \ "--max-line-length=160",
                \ "--ignore=" . s:flake8_ignore,
                \ ])
elseif get(g:, 'lint_tool', '') != ''
    function! s:showLint() abort
        if g:lint_tool == 'ale'
            silent ALELint
        elseif g:lint_tool == 'vim-lsp'
            silent LspDocumentDiagnostic
            if len(getloclist(0)) > 0
                lclose
            endif
        elseif g:lint_tool == 'neomake'
            silent Neomake!
        endif
        if g:fuzzy_finder == 'leaderf'
            LeaderfLocList
        else
            FZFLocList
        endif
    endf
    command! -bang -nargs=* ShowLint call s:showLint()
    nnoremap <silent> <leader>d :ShowLint<Cr>
    if get(g:, 'complete_engine', '') == 'coc' && Installed('coc.nvim')
        call coc#config('diagnostic.enable', v:false)
    endif
    if g:lint_tool == 'vim-lsp'
	let g:lsp_diagnostics_echo_cursor = 1
	let g:lsp_highlights_enabled      = 1
	let g:lsp_virtual_text_enabled    = 0
	let g:lsp_textprop_enabled        = 0
        nnoremap <silent> <M-k>p :LspPreviousError<Cr>
        nnoremap <silent> <M-k>n :LspNextError<Cr>
        nnoremap <silent> <M-k>, :LspPreviousDiagnostic<Cr>
        nnoremap <silent> <M-k>; :LspNextDiagnostic<Cr>
    elseif g:lint_tool == 'ale' && Installed('ale')
        nmap <M-k>c :ALE<Tab>
        nmap <M-k>p <Plug>(ale_previous_error)
        nmap <M-k>n <Plug>(ale_next_error)
        let g:ale_disable_lsp          = 0
        let g:ale_completion_enabled   = 0
        let g:ale_virtualtext_cursor   = 0
        " lint time
        let g:ale_lint_on_enter           = 1
        let g:ale_lint_on_filetype_change = 1
        let g:ale_lint_on_insert_leave    = 1
        let g:ale_lint_on_text_changed    = 'always'
        " signs
        let g:ale_sign_column_always   = 0
        let g:ale_set_signs            = 1
        let g:ale_set_highlights       = 0
        let g:ale_sign_error           = 'x'
        let g:ale_sign_warning         = '!'
        let g:ale_sign_info            = '>'
        " message format
        let g:ale_echo_msg_error_str   = 'E'
        let g:ale_echo_msg_warning_str = 'W'
        let g:ale_echo_msg_format      = '[%linter%] %s [%code%]'
        let g:ale_fix_on_save          = 0
        let g:ale_set_loclist          = 1
        let g:ale_set_quickfix         = 0
        let g:ale_statusline_format    = ['E:%d', 'W:%d', '']
        " linters
        let g:ale_linters = {
                    \ 'python': ['flake8'],
                    \ 'rust': ['cargo'],
                    \ 'vue': ['vls'],
                    \ 'zsh': ['shell']
                    \ }
        let g:ale_python_flake8_options = "--max-line-length=160 --ignore=" . s:flake8_ignore
        " 特定后缀指定lint方式
        let g:ale_pattern_options_enabled        = 1
        let g:ale_warn_about_trailing_whiteSpace = 0
        if get(g:, 'complete_engine', '') == 'coc' && Installed('coc.nvim')
            call coc#config('diagnostic.displayByAle', v:true)
        endif
    elseif g:lint_tool == 'neomake' && Installed('neomake')
        call neomake#configure#automake('rw', 500)
        let g:neomake_open_list = 0
        let g:neomake_virtualtext_current_error = 0
        let g:neomake_echo_current_error        = 1
        let g:neomake_echo_current_error        = 1
        let g:neomake_highlight_columns         = 1
        let g:neomakemp_exclude_files    = ['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
        let g:neomakemp_exclude_dirs     = ['.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn']
        let g:neomake_python_flake8_maker = {
                    \ 'args': ['--max-line-length=160', '--ignore=' . s:flake8_ignore],
                    \ 'errorformat':
                    \ '%E%f:%l: could not compile,%-Z%p^,' .
                    \ '%A%f:%l:%c: %t%n %m,' .
                    \ '%A%f:%l: %t%n %m,' .
                    \ '%-G%.%#',
                    \ }
        let g:neomake_python_enabled_makers = ['flake8']
        let g:neomake_r_lintr_maker = {
                    \ 'exe': 'R',
                    \ 'args': ['-e lintr::lint("%:p")'],
                    \ 'errorformat':
                    \ '%W%f:%l:%c: style: %m,' .
                    \ '%W%f:%l:%c: warning: %m,' .
                    \ '%E%f:%l:%c: error: %m,'
                    \ }
        let g:neomake_r_enabled_makers = ['lintr']
        let g:neomake_error_sign = {
                    \ 'text': 'x',
                    \ 'texthl': 'NeomakeError',
                    \ }
        let g:neomake_warning_sign = {
                    \ 'text': '!',
                    \ 'texthl': 'NeomakeWarning',
                    \ }
        let g:neomake_info_sign = {
                    \ 'text': '>',
                    \ 'texthl': 'NeomakeInfo'
                    \ }
        let g:neomake_message_sign = {
                    \ 'text': '-',
                    \ 'texthl': 'NeomakeMessage',
                    \ }
        nnoremap <M-k>c :Neomake<Tab>
        nnoremap <M-k>p :cprev<cr>
        nnoremap <M-k>n :cnext<cr>
    endif
endif
