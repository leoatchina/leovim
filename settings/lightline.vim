function! LightlineReadonly()
    return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction
function! LightlineRootpath()
    if exists('b:git_dir')
        return fnamemodify(get(b:, 'git_dir'), ':h')
    else
        return 'file'
    endif
endfunction
function! LightlineFilename()
    if exists('b:git_dir')
        let root = fnamemodify(get(b:, 'git_dir'), ':h')
        let path = expand('%:p')
        if WINDOWS()
            return substitute(path[len(root)+1:], '\\', '/', 'g')
        else
            return path[len(root)+1:]
        endif
    else
        return expand('%:p')
    endif
endfunction
function! LightlineGetFunction()
    if g:symbol_tool =~ 'tagbar' && Installed('tagbar') && exists("g:tagbar_compact") > 0
        return tagbar#currenttag("%s", "", "f")
    elseif g:symbol_tool =~ 'vista' && Installed('vista.vim') && get(b:, 'vista_nearest_method_or_function', '') != ''
        return b:vista_nearest_method_or_function
    else
        return ""
    endif
endfunction
function! LightlineFugitive()
    try
        if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler'
            let branch = fugitive#head()
            return branch !=# '' ? '@'. branch : ''
        else
            return ''
        endif
    catch
            return ''
    endtry
    return ''
endfunction
function! YwvimStatus()
    if mode() != 'i' && mode() != 'c' || !exists('b:ywvim_parameters')
        return ''
    elseif exists('b:ywvim_parameters.mode') && &iminsert == 1
        if get(b:, 'ywvim_parameters.active_mb') ==# 'wb'
            return '五'
        elseif get(b:, 'ywvim_parameters.active_mb') ==# 'py'
            return '拼'
        endif
    else
        return ''
    endif
endfunction
let g:lightline = {
            \ 'component': {
            \ 'lineinfo': '%l/%L:%c'},
            \ 'component_function': {
            \ 'gitbranch': 'LightlineFugitive',
            \ 'func':      'LightlineGetFunction',
            \ 'readonly':  'LightlineReadonly',
            \ 'rootpath':  'LightlineRootpath',
            \ 'filename':  'LightlineFilename',
            \ 'ywvim':     'YwvimStatus'}
            \ }
let g:lightline.active = {
            \ 'left': [['gitbranch', 'readonly', 'paste']]
            \ }
call add(g:lightline.active.left, ['rootpath'])
call add(g:lightline.active.left, ['filename', 'modified', 'func'])
let g:lightline.active.right = [
        \ ['filetype', 'fileencoding', 'lineinfo'],
        \ ['ywvim']
        \ ]
if get(g:, 'lint_tool', '') == 'coc' && Installed('coc.nvim')
    function! StatusDiagnostic() abort
        let info = get(b:, 'coc_diagnostic_info', {})
        if empty(info) | return '' | endif
        let msgs = []
        if get(info, 'error', 0)
            call add(msgs, 'E' . info['error'])
        endif
        if get(info, 'warning', 0)
            call add(msgs, 'W' . info['warning'])
        endif
        return join(msgs, ' '). ' ' . get(b:, 'coc_git_status', '')
    endfunction
    function! LightlineGitBlame() abort
        let blame = get(b:, 'coc_git_blame', '')
        return winwidth(0) > 80 ? blame : ''
    endfunction
    let g:lightline.component_function.coc_diag = 'StatusDiagnostic'
    let g:lightline.component_function.coc_git_blame = 'LightlineGitBlame'
    call add(g:lightline.active.right, ['coc_diag', 'coc_git_blame'])
    autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
elseif get(g:, 'lint_tool', '') == 'ale' && Installed('lightline-ale')
    let g:lightline.component_expand =  {
                \ 'linter_checking': 'lightline#ale#checking',
                \ 'linter_errors': 'lightline#ale#errors',
                \ 'linter_warnings': 'lightline#ale#warnings',
                \ 'linter_ok': 'lightline#ale#ok'
                \ }
    let g:lightline.component_type = {
                \ 'linter_checking': 'right',
                \ 'linter_errors': 'error',
                \ 'linter_warnings': 'warning',
                \ 'linter_ok': 'left'
                \ }
    call add(g:lightline.active.right, [
                \ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok'
                \ ])
endif
if get(g:, 'ai_engine', '') =~ 'kite'
    function KiteStatus()
        return kite#statusline()
    endfunction
    let g:lightline.component_function.kitestatus = 'KiteStatus'
    call add(g:lightline.active.right, ['kitestatus'])
endif
" lightline themes
function! UpdateLightline() abort
    augroup ReloadLightline
        au!
        set fillchars+=vert:│
        if g:colors_name == 'sublime'
            let g:lightline.colorscheme = 'molokai'
        elseif g:colors_name == 'atom-dark-256'
            let g:lightline.colorscheme = 'wombat'
        elseif g:colors_name == 'dracula'
            let g:lightline.colorscheme = 'darcula'
        elseif g:colors_name == 'space-vim-dark'
            let g:lightline.colorscheme = 'jellybeans'
        elseif g:colors_name == 'codedark'
            let g:lightline.colorscheme = 'codedark'
        elseif g:colors_name == 'gruvbox'
            let g:lightline.colorscheme = 'gruvboxdark'
        elseif g:colors_name == 'tokyonight'
            let g:lightline.colorscheme = 'tokyonight'
        elseif g:colors_name == 'deus'
            let g:lightline.colorscheme = 'deus'
        elseif g:colors_name == 'gruvbox-material'
            let g:lightline.colorscheme = 'gruvbox_material'
        elseif g:colors_name == 'ayu'
            let g:lightline.colorscheme = 'ayu'
        elseif g:colors_name == 'edge'
            let g:lightline.colorscheme = 'edge'
        elseif g:colors_name == 'one'
           let g:lightline.colorscheme = 'one'
        elseif g:colors_name == 'embark'
            let g:lightline.colorscheme = 'embark'
        elseif g:colors_name == 'sonokai'
            let g:lightline.colorscheme = 'sonokai'
        elseif g:colors_name == 'OceanicNext'
            let g:lightline.colorscheme = 'oceanicnext'
        elseif g:colors_name == 'dogrun'
            let g:lightline.colorscheme = 'dogrun'
        elseif g:colors_name == 'hybrid'
            let g:lightline.colorscheme = 'nord'
        else
            let g:lightline.colorscheme = 'default'
        endif
    augroup END
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
endfunction
augroup UpdateLightline
    autocmd ColorScheme,WinEnter,BufEnter,BufWritePost,VimEnter * call UpdateLightline()
augroup END
