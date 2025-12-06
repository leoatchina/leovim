let s:python_lint_ignore = "E101,E302,E251,E231,E226,E221,E127,E126,E123,E402,E501,W291,F405,F403"
if utils#is_installed('coc.nvim')
    " highlight group
    let g:diagnostic_virtualtext_underline = v:false
    highlight def link CocErrorHighlight   NONE
    highlight def link CocWarningHighlight NONE
    highlight def link CocInfoHighlight    NONE
    highlight def link CocHintHighlight    NONE
    function! s:toggle_diagnostics_highlight()
        if g:diagnostic_virtualtext_underline
            echo "virtualtext_underline off"
            let g:diagnostic_virtualtext_underline = v:false
            highlight! def link CocErrorHighlight   NONE
            highlight! def link CocWarningHighlight NONE
            highlight! def link CocInfoHighlight    NONE
            highlight! def link CocHintHighlight    NONE
        else
            echo "virtualtext_underline on"
            let g:diagnostic_virtualtext_underline = v:true
            highlight! def link CocErrorHighlight   DiagnosticUnderLineError
            highlight! def link CocWarningHighlight DiagnosticUnderLineWarn
            highlight! def link CocInfoHighlight    DiagnosticUnderLineInfo
            highlight! def link CocHintHighlight    DiagnosticUnderLineHint
        endif
    endfunction
    command! ToggleDiagnosticsHighLight call s:toggle_diagnostics_highlight()
    nnoremap <silent><leader>O :ToggleDiagnosticsHighLight<Cr>
    if g:lint_tool == 'ale'
        call coc#config('diagnostic.displayByAle', v:true)
    else
        function! s:Diagnostics(...) abort
            if a:0 && a:1 ==# 'error'
                let l:all = CocAction('diagnosticList')
                if type(l:all) != type([])
                    echo "No diagnostics"
                    return
                endif
                let l:errs = filter(copy(l:all), {_, d -> has_key(d, 'severity') && (d.severity ==# 'Error' || d.severity ==# 'error' || d.severity ==# 'E' || d.severity ==# 1)})
                if empty(l:errs)
                    echo "No errors"
                    call setqflist([], 'r')
                    cclose
                    return
                endif
                let l:items = map(l:errs, {_, d -> {'filename': d.file, 'lnum': d.lnum, 'col': d.col, 'text': d.message, 'type': 'E'}})
                call setqflist(l:items, 'r')
                copen
            else
                CocDiagnostics
            endif
        endfunction
        command! Diagnostics call s:Diagnostics()
        command! DiagnosticsError call s:Diagnostics('error')
        nnoremap <silent><leader>d :Diagnostics<Cr>
        nnoremap <silent><leader>D :CocFzfList diagnostics<CR>
        nnoremap <silent><leader>e :DiagnosticsError<Cr>
        nmap <silent>;d <Plug>(coc-diagnostic-next)
        nmap <silent>,d <Plug>(coc-diagnostic-prev)
        nmap <silent>;e <Plug>(coc-diagnostic-next-error)
        nmap <silent>,e <Plug>(coc-diagnostic-prev-error)
        " config ignore
        call coc#config('python.linting.flake8Args', [
                    \ "--max-line-length=200",
                    \ "--ignore=" . s:python_lint_ignore,
                    \ ])
        call coc#config('python.linting.pylintArgs', [
                    \ "--max-line-length=200",
                    \ "--ignore=" . s:python_lint_ignore,
                    \ ])
        " toggle diagnostic
        function! s:CocDiagnosticToggleBuffer()
            call CocAction('diagnosticToggleBuffer')
            if b:coc_diagnostic_disable > 0
                setlocal signcolumn=no
            else
                setlocal signcolumn=yes
            endif
        endfunction
        command! CocDiagnosticToggleBuffer call s:CocDiagnosticToggleBuffer()
        nnoremap <silent><leader>o :CocDiagnosticToggleBuffer<Cr>
    endif
endif
if utils#is_planned('ale')
    " basic settings
    let g:ale_disable_lsp = 'auto'
    let g:ale_set_balloons = 0
    let g:ale_completion_enabled = 0
    let g:ale_pattern_options_enabled = 1
    let g:ale_use_neovim_diagnostics_api = 0
    let g:ale_warn_about_trailing_blank_lines = 0
    " show message type
    let g:ale_virtualtext_prefix = ' ã€?type%ã€? '
    let g:ale_hover_cursor = 0
    if g:has_popup_floating
        let g:ale_virtualtext_cursor = 1
        let g:ale_echo_cursor = 0
    else
        let g:ale_virtualtext_cursor = 0
        let g:ale_echo_cursor = 1
    endif
    " lint time
    let g:ale_lint_on_save = 1
    let g:ale_lint_on_enter = 1
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_text_changed = 'normal'
    let g:ale_lint_on_filetype_change = 1
    " signs
    let g:ale_set_signs      = 1
    let g:ale_set_highlights = 1
    let g:ale_sign_error   = 'E'
    let g:ale_sign_warning = 'W'
    let g:ale_sign_hint    = 'H'
    let g:ale_sign_info    = 'I'
    let g:ale_sign_column_always = 0
    " message format
    let g:ale_echo_msg_error_str   = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format      = '[%linter%] %s [%code%]'
    let g:ale_fix_on_save          = 0
    let g:ale_set_loclist          = 1
    let g:ale_set_quickfix         = 0
    let g:ale_statusline_format    = ['E:%d', 'W:%d', 'H:%d','']
    " linters
    let g:ale_linters = {
                \ 'python': ['flake8'],
                \ 'rust': ['cargo'],
                \ 'vue': ['vls'],
                \ 'zsh': ['shell']
                \ }
    let g:ale_python_flake8_options = "--max-line-length=200 --ignore=" . s:python_lint_ignore
    " map
    command! ALECommands call FzfCallCommands('ALECommands', 'ALE')
    command! -bang -nargs=* ALEDiag call s:ale_diag()
    if !utils#is_installed('coc.nvim')
        nnoremap <silent><leader>d :ALELint<Cr>
        nnoremap <silent><leader>o :ALEToggleBuffer<Cr>
        nnoremap <silent><leader>O :ALEToggle<Cr>
        nmap ;d <Plug>(ale_next)
        nmap ,d <Plug>(ale_previous)
        nmap ;e <Plug>(ale_next_error)
        nmap ,e <Plug>(ale_previous_error)
    endif
endif
