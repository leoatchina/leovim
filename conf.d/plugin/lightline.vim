function! Mode()
    let l:modes_dict={
                \ "\<C-V>": 'V·Block',
                \ 'Rv': 'V·Replace',
                \ 'n':  'NORMAL',
                \ 'v':  'VISUAL',
                \ 'V':  'V·Line',
                \ 'i':  'INSERT',
                \ 'R':  'R',
                \ 'c':  'Command',
                \}
    let m = mode()
    if has_key(l:modes_dict, m)
        let m = l:modes_dict[m]
    else
        let m = ""
    endif
    return m
endfunction
" ---------------------------
" lightline global settings
" ---------------------------
set laststatus=2
let g:lightline#bufferline#unnamed = ''
let g:lightline#bufferline#show_number = 0
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#enable_devicons = 0
let g:lightline#bufferline#enable_nerdfont = 1
function! LightlineBufferlineMaxWidth() abort
    let left = &columns - len(FileReadonly() . RelativeDir() . RelativePath() . GitBranch() . Mode())
    return left > 60 ? left - 60 : 0
endfunction
let g:lightline#bufferline#max_width = "LightlineBufferlineMaxWidth"
function! LightlineBufferlineFilter(buffer) abort
    return getbufvar(a:buffer, '&buftype') !=# 'terminal' && getbufvar(a:buffer, '&filetype') !=# '' && getbufvar(a:buffer, '&filetype') !=# 'startify'
endfunction
let g:lightline#bufferline#buffer_filter = "LightlineBufferlineFilter"
nmap ;b <Plug>lightline#bufferline#go_next()
nmap ,b <Plug>lightline#bufferline#go_previous()
nmap ;B <Plug>lightline#bufferline#go_next_category()
nmap ,B <Plug>lightline#bufferline#go_previous_category()
nmap ]b <Plug>lightline#bufferline#move_next()
nmap [b <Plug>lightline#bufferline#move_previous()
nmap [B <Plug>lightline#bufferline#move_first()
nmap ]B <Plug>lightline#bufferline#move_last()
PlugAddOpt 'lightline.vim'
PlugAddOpt 'lightline-bufferline'
" ------------------------
" lightline init
" ------------------------
let g:lightline = {
                \ 'component': {
                    \ 'lineinfo': '%l/%L:%c'
                    \ },
                \ 'component_function': {
                    \ 'readonly': 'FileReadonly',
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
let g:lightline.active.right = [['filetype', 'fileencoding', 'lineinfo']]
let g:lightline.inactive.right = [['filetype', 'fileencoding', 'lineinfo']]
let s:component_type = {}
if Installed('lightline-ale')
    let g:lightline.component_expand =  {
                \ 'linter_checking': 'lightline#ale#checking',
                \ 'linter_errors': 'lightline#ale#errors',
                \ 'linter_warnings': 'lightline#ale#warnings',
                \ }
    let s:component_type = {
                \ 'linter_checking': 'right',
                \ 'linter_errors': 'error',
                \ 'linter_warnings': 'warning',
                \ }
    let lint_info = ['linter_checking', 'linter_errors', 'linter_warnings']
    let g:lightline.active.right += [lint_info]
elseif Installed('nvim-lightline-lsp')
    let g:lightline.component_expand ={
                \ 'lsp_warnings': 'lightline#lsp#warnings',
                \ 'lsp_errors': 'lightline#lsp#errors',
                \ 'lsp_info': 'lightline#lsp#info',
                \ 'lsp_hints': 'lightline#lsp#hints',
                \ 'lsp_ok': 'lightline#lsp#ok',
                \ }
    " Set color to the component
    let s:component_type = {
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
    " origin buffers list
    let buffers = copy(lightline#bufferline#buffers())
    try
        let b:file_icon = buffers[1][0][:3]
    catch
        let b:file_icon = ''
    endtry
    " reorder buffers
    if empty(buffers[2])
        let res = buffers
    else
        if empty(buffers[0])
            let res = [buffers[2], buffers[1], []]
        else
            let res = [buffers[0] + buffers[2], buffers[1], []]
        endif
    endif
    let res[1] = [b:file_icon . RelativeDir()]
    return res
endfunction
let g:lightline['component_expand']['branch'] = 'GitBranch'
let g:lightline['component_expand']['buffers'] = 'Buffers'
let g:lightline['component_expand']['relativepath'] = 'RelativePath'
" ------------------------
" lightline component_type
" ------------------------
let g:lightline.component_type = extend(s:component_type, {
            \ 'branch': 'raw',
            \ 'buffers': 'tabsel',
            \ 'relativepath': 'info'
            \ })
" ------------------------
" XXX:left part
" ------------------------
let g:lightline.active.left = [['mode', 'paste'], ['buffers', 'relativepath', 'modified', 'branch']]
let g:lightline.inactive.left = [['mode'], ['abspath']]
" ---------------------
" UpdateLightline
" ---------------------
function! UpdateLightline() abort
    let colors_name = get(g:, 'colors_name', '')
    if index(['sonokai', 'edge', 'codedark', 'one', 'wombat'], colors_name) >= 0
        let g:lightline.colorscheme = g:colors_name
    elseif colors_name =~ 'fox' || colors_name =~ 'fly'
        let g:lightline.colorscheme = g:colors_name
    elseif colors_name =~ 'catppuccin'
        let g:lightline.colorscheme = "catppuccin"
    elseif colors_name =~ 'gruvbox'
        let g:lightline.colorscheme = "gruvboxdark"
    elseif colors_name =~ 'tokyonight'
        let g:lightline.colorscheme = "tokyonight"
    elseif colors_name == 'space-vim-dark'
        let g:lightline.colorscheme = 'simpleblack'
    elseif colors_name == 'sublime'
        let g:lightline.colorscheme = 'molokai'
    elseif colors_name == 'hybrid'
        let g:lightline.colorscheme = 'jellybeans'
    else
        let g:lightline.colorscheme = 'wombat'
    endif
    call lightline#init()
    call lightline#colorscheme()
endfunction
augroup UpdateLightline
    autocmd!
    autocmd ColorScheme * call UpdateLightline()
    autocmd BufCreate,BufEnter,BufWinEnter,VimEnter,BufWritePost * call lightline#update()
    if InstalledCoc()
        autocmd User CocGitStatusChange,CocDiagnosticChange call lightline#update()
    endif
augroup END
nnoremap <silent><C-l> :redraw \| call lightline#update()<Cr>
