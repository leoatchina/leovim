function! RelativeDir()
    let root = GitRootDir()
    let path = Expand('%:p:h', 1)
    if root == ''
        return path
    else
        return path[len(root) + 1:]
    endif
endfunction
function! AbsPath()
    return Expand('%:p', 1)
endfunction
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
let g:lightline#bufferline#unnamed = ''
let g:lightline#bufferline#show_number = 0
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#enable_devicons = 0
let g:lightline#bufferline#enable_nerdfont = 1
function! LightlineBufferlineMaxWidth() abort
    let left = &columns - len(FileReadonly() + GitBranch() + GitRootDir() + RelativeDir() + Mode())
    return left > 60 ? left - 60 : 0
endfunction
let g:lightline#bufferline#max_width = "LightlineBufferlineMaxWidth"
function! LightlineBufferlineFilter(buffer) abort
    return getbufvar(a:buffer, '&buftype') !=# 'terminal' && getbufvar(a:buffer, '&filetype') !=# '' && getbufvar(a:buffer, '&filetype') !=# 'startify'
endfunction
let g:lightline#bufferline#buffer_filter = "LightlineBufferlineFilter"
nmap ]b <Plug>lightline#bufferline#go_next()
nmap [b <Plug>lightline#bufferline#go_previous()
nmap ]B <Plug>lightline#bufferline#go_next_category()
nmap [B <Plug>lightline#bufferline#go_previous_category()
nmap <Leader>]b <Plug>lightline#bufferline#move_next()
nmap <Leader>[b <Plug>lightline#bufferline#move_previous()
nmap <Leader>[B <Plug>lightline#bufferline#move_first()
nmap <Leader>]B <Plug>lightline#bufferline#move_last()
PlugAddOpt 'lightline.vim'
PlugAddOpt 'lightline-bufferline'
" ------------------------
" init
" ------------------------
let g:lightline = {
                \ 'component': {
                    \ 'lineinfo': '%l/%L:%c'
                    \ },
                \ 'component_function': {
                    \ 'readonly': 'FileReadonly',
                    \ 'gitbranch': 'GitBranch',
                    \ 'mode': 'Mode',
                    \ 'abspath': 'AbsPath',
                    \ },
                \ 'component_expand': {},
                \ 'active': {},
                \ 'inactive':{},
                \ 'enable': {
                    \ 'statusline': 1,
                    \ 'tabline': 0
                \ },
            \ }
"------------------------
" right part
"------------------------
let g:lightline.active.right = [['gitbranch', 'filetype', 'fileencoding', 'lineinfo']]
let g:lightline.inactive.right = [['gitbranch', 'filetype', 'fileencoding', 'lineinfo']]
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
elseif PlannedCoc()
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
if !has("nvim")
    PlugAddOpt 'lightline-asyncrun'
    let g:lightline#asyncrun#indicator_none = ''
    let g:lightline.component_expand.asyncrun_status = 'lightline#asyncrun#status'
    let g:lightline.active.right += [['asyncrun_status']]
endif
" ---------------------------------------
" show buffers and current file path
" ---------------------------------------
function! Buffers()
    if WINDOWS()
        if has('nvim')
            let icon = 'Ⓡ '
        else
            let icon = '@'
        endif
    else
        let icon = 'Ⓡ '
    endif
    " origin buffers list
    let buffers = lightline#bufferline#buffers()
    " reorder buffers
    if empty(buffers[2])
        let res = copy(buffers)
    else
        if empty(buffers[0])
            let res = [buffers[2], buffers[1], []]
        else
            let res = [buffers[0] + buffers[2], buffers[1], []]
        endif
    endif
    if GitRootDir() == ''
        let res[1] = [icon . ' ' . RelativeDir()]
    else
        let res[1] = [icon . ' ' . GitRootDir()]
    endif
    return res
endfunction
let g:lightline['component_expand']['buffers'] = 'Buffers'
" ------------------------
" RelativePath
" ------------------------
function! RelativePath()
    if &ft == ''
        return ''
    elseif GitRootDir() == ''
        return Expand('%')
    else
        return RelativeDir() . '/' . expand('%')
    endif
endfunction
let g:lightline['component_expand']['relativepath'] = 'RelativePath'
" ------------------------
" left part
" ------------------------
let g:lightline.active.left = [['mode', 'paste'], ['buffers'], ['relativepath', 'modified']]
let g:lightline.inactive.left = [['mode'], ['abspath']]
" ------------------------
" lightline component_type
" ------------------------
let g:lightline.component_type = {
            \ 'gitbranch': 'info',
            \ 'buffers': 'tabsel',
            \ 'relativepath': 'info'
            \ }
" ------------------------
" tab label
" ------------------------
function! Vim_NeatBuffer(bufnr, fullname)
    let l:name = bufname(a:bufnr)
    if getbufvar(a:bufnr, '&modifiable')
        if l:name == ''
            return '[No Name]'
        else
            if a:fullname
                return fnamemodify(l:name, ':p')
            else
                return fnamemodify(l:name, ':t')
            endif
        endif
    else
        let l:buftype = getbufvar(a:bufnr, '&buftype')
        if l:buftype == 'quickfix'
            return '[Quickfix]'
        elseif l:name != ''
            if a:fullname
                return '-'.fnamemodify(l:name, ':p')
            else
                return '-'.fnamemodify(l:name, ':t')
            endif
        else
            return '[No Name]'
        endif
    endif
endfunc
" get a single tab label
function! Vim_NeatTabLabel(n, active)
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, a:active)
endfun
" make tabline in terminal mode
function! Vim_NeatTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        let nr = i + 1
        " select the highlighting
        if nr == tabpagenr()
            let a = 1
            let s .= '%#TabLineSel#'
        else
            let a = 0
            let s .= '%#TabLine#'
        endif
        " set the tab page number (for mouse clicks)
        let s .= '%' . nr . 'T'
        " set nr
        let s .= '【' . nr . '】'
        " set hl
        let s .= '%{Vim_NeatTabLabel(' . nr . ',' . a .  ')} '
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999XX'
    endif
    return s
endfunction
" get a single tab label in gui
function! Vim_NeatGuiTabLabel()
    let l:num = v:lnum
    let l:buflist = tabpagebuflist(l:num)
    let l:winnr = tabpagewinnr(l:num)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfunc
" set label && tabline
set guitablabel=%{Vim_NeatGuiTabLabel()}
set tabline=%!Vim_NeatTabLine()
" ==============================================================================
" schemes
" ==============================================================================
syntax on
syntax enable
filetype on
filetype plugin on
set background=dark
function! SetScheme(scheme, ...) abort
    let scheme = a:scheme
    let defaultscheme = get(a:, 1, 'hybrid')
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
            colorscheme hybrid
        endtry
    endtry
endfunction
function! UpdateLightline() abort
    let colors_name = get(g:, 'colors_name', '')
    if colors_name == 'codedark' || colors_name == 'deus' || colors_name == 'one'
        let g:lightline.colorscheme = g:colors_name
    elseif colors_name == 'space-vim-dark'
        let g:lightline.colorscheme = 'simpleblack'
    elseif colors_name == 'sublime'
        let g:lightline.colorscheme = 'molokai'
    elseif colors_name == 'hybrid'
        let g:lightline.colorscheme = 'nord'
    elseif colors_name =~ 'gruvbox'
        if colors_name == 'gruvbox-material'
            let g:lightline.colorscheme = 'gruvbox_material'
        else
            let g:lightline.colorscheme = 'gruvboxdark'
        endif
    elseif colors_name =~ 'catppuccin'
        let g:lightline.colorscheme = "catppuccin"
    elseif colors_name =~ 'tokyonight'
        let g:lightline.colorscheme = "tokyonight"
    elseif colors_name == 'sonokai' || colors_name == 'edge' || colors_name == 'everforest' || colors_name =~ 'fox'
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
    autocmd WinEnter,VimEnter,BufWritePost * call lightline#update()
    if PlannedCoc()
        autocmd User CocGitStatusChange,CocDiagnosticChange call lightline#update()
    endif
augroup END
nnoremap <silent><C-l> <C-l>:call lightline#update()<Cr>
inoremap <silent><C-l> <C-o>:call lightline#update()<Cr>
" --------------------------
" schemes need truecolor
" --------------------------
let g:terminal_color_13 = '#000000'
let g:edge_better_performance = 1
let g:sonokai_better_performance = 1
let g:everforest_better_performance = 1
let g:gruvbox_material_better_performance = 1
if Installed('catppuccin') && Require('catppuccin')
    call SetScheme('catppuccin')
elseif Installed('tokyonight.nvim') && Require('tokyonight')
    call SetScheme('tokyonight')
elseif g:complete_engine == 'apm'
    call SetScheme('edge', 'one')
elseif g:complete_engine == 'mcm'
    call SetScheme('sonokai', 'sublime')
elseif g:complete_engine == 'vcm'
    call SetScheme('gruvbox-material', 'gruvbox')
elseif g:complete_engine == 'cmp'
    call SetScheme('nightfox', 'space-vim-dark')
elseif g:complete_engine == 'coc'
    if has('nvim')
        call SetScheme('terafox', 'deus')
    else
        call SetScheme('everforest', 'deus')
    endif
else
    colorscheme hybrid
endif
" --------------------------
" nvim-web-devicons
" --------------------------
if Installed('nvim-web-devicons')
    lua require('nvim-web-devicons').setup({})
endif
