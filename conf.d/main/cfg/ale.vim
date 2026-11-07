" --------------------------
" ale
" --------------------------
" basic settings
let g:ale_disable_lsp = 'auto'
let g:ale_set_balloons = 0
let g:ale_completion_enabled = 0
let g:ale_pattern_options_enabled = 1
let g:ale_use_neovim_diagnostics_api = 0
let g:ale_warn_about_trailing_blank_lines = 0
" show message type
let g:ale_virtualtext_prefix = '【%type%】:'
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
let g:ale_python_flake8_options = "--max-line-length=200 --ignore=E101,E302,E251,E231,E226,E221,E127,E126,E123,E402,E501,W291,F405,F403"
