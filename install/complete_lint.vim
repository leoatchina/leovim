" --------------------------
" complete shortcuts
" --------------------------
try
    set completeopt=menu,menuone,noselect,noinsert
catch
    try
        set completeopt=menu,menuone,noselect
    catch
        call AddPlug('no-complete')
    endtry
endtry
" ------------------------------
" complete engine
" ------------------------------
if HasPlug('no-complete')
    " pass
elseif HasPlug('apc')
    let g:complete_engine = "apc"
elseif HasPlug('YCM')
    if (has('nvim-0.4.4') || v:version >= 800) && g:python_version > 3.5
        if WINDOWS() && exists("$YCM_WINDIR") && isdirectory($YCM_WINDIR)
            let g:complete_engine = "YCM"
        elseif executable('cmake') && executable('gcc')
            let s:msg = system('gcc --version')
            let s:gcc_version = matchstr(s:msg, '\zs\d\{1,\}.\d\{1,\}.\d\{1,\}\ze')
            let s:gcc_version = str2nr(matchstr(s:gcc_version, '\zs\d\{1,\}\ze'))
            if s:gcc_version >= 8 && g:python_version > 3.6 && (has('patch-8.1.2269') || has('nvim'))
                let g:complete_engine = "YCM"
            else
                let g:complete_engine = "YCM-legacy"
            endif
        else
            echoe "Cannot install YouCompleteMe, check gcc and cmake version, smart select a complete_engine."
            let s:smart_engine_select = 1
        endif
    else
        echoe "Cannot install YouCompleteMe, smart select a complete_engine."
        let s:smart_engine_select = 1
    endif
elseif HasPlug('coc') && executable('node') && executable('npm')
    if v:version >= 802 || has('nvim')
        let g:complete_engine = 'coc'
    else
        echoe "Cannot install coc, smart select a complete_engine."
        let s:smart_engine_select = 1
    endif
elseif HasPlug('vim-lsp')
    if has('nvim') || v:version >= 800
        let g:complete_engine = "vim-lsp"
    else
        echoe "Cannot install vim-lsp, smart select a complete_engine."
        let s:smart_engine_select = 1
    endif
else
    let s:smart_engine_select = 1
endif
if get(s:, 'smart_engine_select', 0) == 1
    if has('nvim') || v:version >= 800
        let g:complete_engine = "vim-lsp"
    else
        let g:complete_engine = "apc"
    endif
    unlet s:smart_engine_select
endif
" ------------------------------
" lint tool
" ------------------------------
if index(['YCM', 'YCM-legacy', 'coc', 'vim-lsp', 'nvim-lsp'], get(g:, 'complete_engine', '')) >= 0
    if get(g:, 'complete_engine', '') == 'coc' && get(g:, 'lint_tool', '') != 'ale'
        let g:lint_tool = 'coc'
        nnoremap <M-k>d :<C-u>CocDiagnostics<Cr>
    elseif has('nvim') || v:version >= 800
        let g:lint_tool = 'ale'
        nnoremap <M-k>d :ALELint<Cr>
        MyPlug 'dense-analysis/ale'
    else
        let g:lint_tool = ''
    endif
else
    let g:lint_tool = ''
endif
" ------------------------------
" ai_engine
" ------------------------------
if index(['coc', 'vim-lsp', 'nvim-lsp'], get(g:, 'complete_engine', '')) >= 0
    if HasPlug('ai')
        try
            " using try to check if kite_engine loaded
            autocmd VimEnter * call kite#enable_auto_start()
            " install kite plugin
            MyPlug 'kiteco/vim-plugin'
            let g:ai_engine = 'kite'
            let g:kite_supported_languages = ['*']
            let g:kite_tab_complete = 1
            nmap <silent> <buffer> K <Plug>(kite-docs)
            nmap <silent> g<tab> :KiteGotoDefinition<Cr>
        catch
            let g:ai_engine = 'tabnine'
        endtry
    elseif HasPlug('tabnine')
        let g:ai_engine = 'tabnine'
    endif
endif
" ------------------------------
" complete_snippet
" ------------------------------
if get(g:, 'complete_engine', '') != '' && get(g:, 'complete_engine', '') != "apc"
    if g:python_version > 3 && !CYGWIN()
        let g:complete_snippet = "ultisnips"
        MyPlug 'SirVer/ultisnips'
        MyPlug 'honza/vim-snippets'
    else
        let g:complete_snippet = "neosnippet"
        MyPlug 'Shougo/neosnippet'
        MyPlug 'Shougo/neosnippet-snippets'
    endif
else
    let g:complete_snippet = ""
endif
" ------------------------------
" complete_engine
" ------------------------------
if get(g:, 'complete_engine', '') =~ "YCM"
    if WINDOWS()
        set rtp+=$YCM_WINDIR
    else
        let b:ycm_install = " ./install.py"
        if HasPlug('c')
            let b:ycm_install = b:ycm_install . " --clangd-completer"
        endif
        if HasPlug('rust')
            let b:ycm_install = b:ycm_install . " --rust-completer"
        endif
        if executable('node') && HasPlug('web')
            let b:ycm_install = b:ycm_install . " --ts-completer"
        endif
        if executable('go') && HasPlug('go')
            let b:ycm_install = b:ycm_install . " --go-completer"
        endif
        if g:complete_engine =~ 'legacy'
            if g:python_version > 3.6
                MyPlug 'ycm-core/YouCompleteMe', {'do': g:python_exe_path . b:ycm_install, 'branch': 'legacy-vim'}
            elseif g:python_version > 3.5
                MyPlug 'ycm-core/YouCompleteMe', {'do': g:python_exe_path . b:ycm_install, 'commit':'9f77732bde3'}
            endif
        else
            MyPlug 'ycm-core/YouCompleteMe', {'do': g:python_exe_path . b:ycm_install}
        endif
        " ycm_lsp
        let b:ycm_lsp_install = ' ./install.py'
        if executable('node')
            let b:ycm_lsp_install = b:ycm_lsp_install . " --enable-json --enable-vue --enable-viml"
        endif
        if executable('julia')
            let b:ycm_lsp_install = b:ycm_lsp_install . " --enable-julia"
        endif
        MyPlug 'ycm-core/lsp-examples', {'do': g:python_exe_path . b:ycm_lsp_install}
        if !has('patch-8.1.1517') && !has('nvim')
            MyPlug 'Shougo/echodoc.vim'
            let g:echodoc_enable_at_startup = 1
            set cmdheight=2
        endif
    endif
elseif get(g:, 'complete_engine', '') == 'coc'
    MyPlug 'neoclide/coc.nvim', {'branch': 'release'}
    MyPlug 'antoinemadec/coc-fzf', {'branch': 'release'}
    let g:coc_global_extensions = [
            \ 'coc-json',
            \ 'coc-git',
            \ 'coc-sql',
            \ 'coc-lists',
            \ 'coc-xml',
            \ 'coc-marketplace',
            \ 'coc-vimlsp',
            \ 'coc-pyright',
            \ 'coc-snippets',
            \ 'coc-dictionary',
            \ 'coc-explorer',
            \ ]
    if WINDOWS()
        let g:coc_global_extensions += ['coc-powershell']
    else
        let g:coc_global_extensions += ['coc-sh']
    endif
    if HasPlug('c')
        if executable('ccls')
            let g:coc_global_extensions += ['coc-ccls']
        else
            let g:coc_global_extensions += ['coc-clangd']
        endif
    endif
    if HasPlug('web')
        let g:coc_global_extensions += [
            \ 'coc-html',
            \ 'coc-css',
            \ 'coc-yaml',
            \ 'coc-phpls',
            \ 'coc-emmet',
            \ 'coc-tsserver',
            \ 'coc-angular',
            \ 'coc-vetur'
            \ ]
    endif
    if HasPlug('R')
        let g:coc_global_extensions += ['coc-r-lsp']
    endif
    if HasPlug('rust')
        let g:coc_global_extensions += ['coc-rust-analyzer']
    endif
    if HasPlug('go')
        let g:coc_global_extensions += ['coc-go']
    endif
    if HasPlug('latex')
        let g:coc_global_extensions += ['coc-vimtex']
    endif
    if get(g:, 'ai_engine', '') == 'tabnine'
        let g:coc_global_extensions += ['coc-tabnine']
    endif
elseif get(g:, 'complete_engine', '') == "vim-lsp"
    MyPlug 'mattn/vim-lsp-settings'
    MyPlug 'prabirshrestha/vim-lsp'
    MyPlug 'prabirshrestha/asyncomplete.vim'
    MyPlug 'prabirshrestha/asyncomplete-lsp.vim'
    MyPlug 'prabirshrestha/asyncomplete-file.vim'
    MyPlug 'prabirshrestha/asyncomplete-buffer.vim'
    if executable('tmux')
        MyPlug 'wellle/tmux-complete.vim'
    endif
    if executable('ctags')
        MyPlug 'prabirshrestha/asyncomplete-tags.vim'
    endif
    if get(g:, 'ai_engine', '') == 'tabine'
        if WINDOWS()
            MyPlug 'kitagry/asyncomplete-tabnine.vim', {'do': 'powershell.exe .\install.ps1'}
        else
            MyPlug 'kitagry/asyncomplete-tabnine.vim', {'do': './install.sh'}
        endif
    endif
    if g:complete_snippet == 'ultisnips'
        MyPlug 'prabirshrestha/asyncomplete-ultisnips.vim'
    else
        MyPlug 'prabirshrestha/asyncomplete-neosnippet.vim'
    endif
    if !has('patch-8.1.1517') && !has('nvim')
        MyPlug 'Shougo/echodoc.vim'
        let g:echodoc_enable_at_startup = 1
        set cmdheight=2
    endif
endif
