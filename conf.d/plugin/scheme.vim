syntax on
syntax enable
filetype on
filetype plugin on
set background=dark
function! s:tooglebg()
    if &background == "dark"
        set background=light
    else
        set background=dark
    endif
    call preview#cmdmsg(&background, 1)
endf
command! ToggleBackgroud call s:tooglebg()
nnoremap <M-k>b :ToggleBackgroud<Cr>
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
            colorscheme slate
        endtry
    endtry
endfunction
let g:edge_better_performance = 1
let g:sonokai_better_performance = 1
if g:complete_engine == 'mcm'
    call SetScheme('edge', 'one')
elseif g:complete_engine == 'cmp'
    call SetScheme('nightfox', 'codedark')
elseif g:complete_engine == 'blk'
    call SetScheme('catppuccin', 'codedark')
elseif g:complete_engine == 'coc'
    if has('nvim')
        call SetScheme('duskfox', 'space-vim-dark')
    else
        call SetScheme('sonokai', 'sublime')
    endif
elseif g:complete_engine == 'apm'
    colorscheme gruvbox
else
    colorscheme hybrid
endif
" --------------------------
" nvim-web-devicons
" --------------------------
if Installed('nvim-web-devicons')
    lua require('nvim-web-devicons').setup({})
endif
" --------------------------
" render-markdown
" --------------------------
if Installed('render-markdown.nvim')
    " 在 Vim 配置文件中添加以下内容
    augroup SetupRenderMarkdown
        autocmd!
        autocmd User avante.nvim,codecompanion.nvim,mini.pick ++once lua require('render-markdown').setup({ file_types = { "markdown", "Avante", "vimwiki" }})
        autocmd FileType markdown,Avante,vimwiki ++once lua require('render-markdown').setup({ file_types = { "markdown", "Avante", "vimwiki" }})
    augroup END
endif
