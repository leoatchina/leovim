"-----------------------------------------------------
" lightline init, NOTE: must be set before schemes
"-----------------------------------------------------
set laststatus=2
let g:modes_dict={
            \ "\<C-V>": 'V·Block',
            \ 'Rv': 'V·Replace',
            \ 'n':  'NORMAL',
            \ 'v':  'VISUAL',
            \ 'V':  'V·Line',
            \ 'i':  'INSERT',
            \ 'R':  'R',
            \ 'c':  'Command',
            \}
function! Mode()
    let m = mode()
    if has_key(g:modes_dict, m)
        let m = g:modes_dict[m]
    else
        let m = ""
    endif
    return m
endfunction
PlugAddOpt 'lightline.vim'
let g:lightline#bufferline#unnamed = ''
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#enable_devicons = 1
let g:lightline#bufferline#min_buffer_count = 8
function! LightlineBufferlineMaxWidth() abort
    let left_len = &columns - len(FileReadonly()  + GitBranch() + RootPath() + FileName() + Mode())
    let res = left_len > 50 ? left_len - 50 : 0
    return res
endfunction
let g:lightline#bufferline#max_width = "LightlineBufferlineMaxWidth"
function LightlineBufferlineFilter(buffer)
    return getbufvar(a:buffer, '&buftype') !=# 'terminal' && getbufvar(a:buffer, '&filetype') !=# ''
endfunction
let g:lightline#bufferline#buffer_filter = "LightlineBufferlineFilter"
PlugAddOpt 'lightline-bufferline'
nmap ]b <Plug>lightline#bufferline#go_next()
nmap [b <Plug>lightline#bufferline#go_previous()
nmap ]B <Plug>lightline#bufferline#go_next_category()
nmap [B <Plug>lightline#bufferline#go_previous_category()
nmap <Leader>]b <Plug>lightline#bufferline#move_next()
nmap <Leader>[b <Plug>lightline#bufferline#move_previous()
nmap <Leader>[B <Plug>lightline#bufferline#move_first()
nmap <Leader>]B <Plug>lightline#bufferline#move_last()
" ------------------------
" init
" ------------------------
function! FileName()
    let root = RootPath()
    let path = fnameescape(substitute(Expand('%:p'), '\\', '/', 'g'))
    if root == ''
        return path
    else
        return path[len(root):]
    endif
endfunction
function! RootPath()
    let root = GitRootDir()
    if root == ''
        return ''
    else
        return root . '/'
    endif
endfunction
let g:lightline = {
                \ 'component': {
                    \ 'lineinfo': '%l/%L:%c'
                    \ },
                \ 'component_function': {
                    \ 'readonly': 'FileReadonly',
                    \ 'gitbranch': 'GitBranch',
                    \ 'rootpath': 'RootPath',
                    \ 'filename': 'FileName',
                    \ 'mode': 'Mode',
                    \ },
                \ 'component_expand': {
                    \   'buffers': 'lightline#bufferline#buffers'
                    \ },
                \ 'component_type': {
                    \   'buffers': 'tabsel'
                    \ },
                \ 'active': {}
            \ }
"------------------------
" left part
"------------------------
let g:lightline.active.left = [['mode', 'readonly', 'paste' ], ['rootpath'], ['modified', 'filename'], ['buffers']]
"------------------------
" right part
"------------------------
let g:lightline.active.right = [['gitbranch', 'filetype', 'fileencoding', 'lineinfo']]
if Installed('lightline-ale')
    let g:lightline.component_expand =  {
                \ 'linter_checking': 'lightline#ale#checking',
                \ 'linter_errors': 'lightline#ale#errors',
                \ 'linter_warnings': 'lightline#ale#warnings',
                \ }
    let g:lightline.component_type = {
                \ 'linter_checking': 'right',
                \ 'linter_errors': 'error',
                \ 'linter_warnings': 'warning',
                \ }
    let lint_info = ['linter_checking', 'linter_errors', 'linter_warnings']
    let g:lightline.active.right += [lint_info]
elseif Installed('nvim-lightline-lsp')
    let g:lightline.component_expand = {
                \ 'lsp_warnings': 'lightline#lsp#warnings',
                \ 'lsp_errors': 'lightline#lsp#errors',
                \ 'lsp_info': 'lightline#lsp#info',
                \ 'lsp_hints': 'lightline#lsp#hints',
                \ 'lsp_ok': 'lightline#lsp#ok',
                \ }
    " Set color to the component
    let g:lightline.component_type = {
                \ 'lsp_warnings': 'warning',
                \ 'lsp_errors': 'error',
                \ 'lsp_info': 'info',
                \ 'lsp_hints': 'hints',
                \ 'lsp_ok': 'left',
                \ }
    let lint_info = ['lsp_ok', 'lsp_info', 'lsp_hints', 'lsp_errors', 'lsp_warnings']
    let g:lightline.active.right += [lint_info]
elseif InstalledCoc()
    function! CocDiagnostic()
        let info = get(b:, 'coc_diagnostic_info', {})
        if empty(info) | return get(b:, 'coc_git_status', '')  | endif
        let msgs = []
        if get(info, 'error', 0)
            call add(msgs, 'E' . info['error'])
        endif
        if get(info, 'warning', 0)
            call add(msgs, 'W' . info['warning'])
        endif
        if get(info, 'hint', 0)
            call add(msgs, 'H' . info['hint'])
        endif
        return get(b:, 'coc_git_status', '') . ' ' . join(msgs, ' ')
    endfunction
    let g:lightline.component_function.coc_diag = 'CocDiagnostic'
    let g:lightline.active.right += [['coc_diag']]
endif
" ------------------------
" lightline themes
" ------------------------
function! UpdateLightline() abort
    let colors_name = get(g:, 'colors_name', '')
    if colors_name == 'codedark'
        let g:lightline.colorscheme = 'codedark'
    elseif colors_name == 'space-vim-dark'
        let g:lightline.colorscheme = 'simpleblack'
    elseif colors_name == 'sublime'
        let g:lightline.colorscheme = 'molokai'
    elseif colors_name == 'deus'
        let g:lightline.colorscheme = 'deus'
    elseif colors_name == 'one'
        let g:lightline.colorscheme = 'one'
    elseif colors_name == 'hybrid'
        let g:lightline.colorscheme = 'nord'
    elseif colors_name == 'gruvbox-material'
        let g:lightline.colorscheme = 'gruvbox_material'
    elseif colors_name == 'sonokai'
        let g:lightline.colorscheme = 'sonokai'
    elseif colors_name == 'edge'
        let g:lightline.colorscheme = 'edge'
    elseif colors_name == 'everforest'
        let g:lightline.colorscheme = 'everforest'
    elseif colors_name =~ 'gruvbox'
        let g:lightline.colorscheme = 'gruvboxdark'
    elseif colors_name =~ 'catppuccin'
        let g:lightline.colorscheme = 'catppuccin'
    elseif colors_name =~ 'fox' || colors_name =~ 'fly'
        let g:lightline.colorscheme = g:colors_name
    else
        let g:lightline.colorscheme = 'default'
    endif
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
endfunction
augroup UpdateLightline
    autocmd!
    autocmd ColorScheme * call UpdateLightline()
    autocmd WinEnter,VimEnter * call lightline#update()
    if InstalledCoc()
        autocmd User CocGitStatusChange,CocDiagnosticChange call lightline#update()
    endif
augroup END
nnoremap <silent><C-l> <C-l>:call lightline#update()<Cr>
inoremap <silent><C-l> <C-o>:call lightline#update()<Cr>
" --------------------------
" scheme
" --------------------------
syntax on
syntax enable
filetype on
filetype plugin on
set background=dark
function! SetScheme(scheme, ...) abort
    let scheme = a:scheme
    let defaultscheme = get(a:, 1, 'space-vim-dark')
    try
        if g:has_truecolor
            execute('colorscheme '. scheme)
        else
            execute('colorscheme '. defaultscheme)
        endif
    catch
        try
            execute('colorscheme '. defaultscheme)
        catch
            colorscheme space-vim-dark
        endtry
    endtry
endfunction
" --------------------------
" schemes need truecolor
" --------------------------
if Installed('catppuccin')
    luafile $LUA_DIR/catppuccin.lua
endif
let g:everforest_background = 'hard'
let g:edge_better_performance = 1
let g:sonokai_better_performance = 1
let g:everforest_better_performance = 1
let g:gruvbox_material_better_performance = 1
if Require('gruvbox')
    call SetScheme('gruvbox-material', 'gruvbox')
elseif Require('everforest')
    call SetScheme('everforest', 'deus')
elseif Require('sonokai')
    call SetScheme('sonokai', 'sublime')
elseif Require('edge')
    call SetScheme('edge', 'one')
elseif Require('nightfox')
    call SetScheme('nightfox', 'hybrid')
elseif Require('catppuccin')
    call SetScheme('catppuccin', 'codedark')
elseif Require('nightfly')
    call SetScheme('nightfly', 'space-vim-dark')
elseif Require('moonfly')
    call SetScheme('moonfly', 'space-vim-dark')
elseif g:complete_engine == 'coc'
    if has('nvim')
        call SetScheme('nightfox', 'hybrid')
    else
        call SetScheme('gruvbox-material', 'gruvbox')
    endif
elseif g:complete_engine == 'cmp'
    call SetScheme('catppuccin', 'codedark')
elseif g:complete_engine == 'mcm'
    call SetScheme('sonokai', 'sublime')
elseif g:complete_engine == 'apm'
    call SetScheme('edge', 'one')
else
    colorscheme hybrid
endif
" --------------------------
" nvim-web-devicons
" --------------------------
if Installed('nvim-web-devicons')
    lua require('nvim-web-devicons').setup({})
endif
