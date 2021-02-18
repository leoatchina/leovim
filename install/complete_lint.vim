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
if !HasPlug('no-complete')
    if HasPlug('apc')
        let g:complete_engine = "apc"
    elseif HasPlug('YCM')
        if (has('nvim') || v:version >= 800) && g:python_version > 3.5
            if WINDOWS() && exists("$YCM_WINDIR") && isdirectory($YCM_WINDIR)
                let g:complete_engine = "YCM"
            elseif executable('cmake') && executable('g++')
                let msg = system('g++ --version')
                let gpp_version = matchstr(msg, '\zs\d\{1,\}.\d\{1,\}.\d\{1,\}\ze')
                let gpp_version = str2nr(matchstr(gpp_version, '\zs\d\{1,\}\ze'))
                if gpp_version >= 9 && g:python_version > 3.6 && (has('patch-8.1.2269') || has('nvim'))
                    let g:complete_engine = "YCM"
                else
                    let g:complete_engine = "YCM-legacy"
                endif
            else
                echoe "Cannot install YouCompleteMe, check g++ and cmake version, smart select a complete_engine."
                let s:smart_engine_select = 1
            endif
        else
            echoe "Cannot install YouCompleteMe, smart select a complete_engine."
            let s:smart_engine_select = 1
        endif
    elseif HasPlug('coc') && executable('node') && (executable('npm') || executable('yarn'))
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
endif
" ------------------------------
" lint tool
" ------------------------------
if has('timers') && get(g:, 'complete_engine', '') != 'apc' && get(g:, 'complete_engine', '') != ''
    let g:lsp_diagnostics_enabled = 0
    if get(g:, 'complete_engine', '') == "vim-lsp" && get(g:, 'lint_tool', '') == 'vim-lsp'
        let g:lsp_diagnostics_enabled = 1
        nnoremap <silent> <M-k>d :<C-u>LspDocumentDiagnostic<Cr>
    elseif get(g:, 'complete_engine', '') == 'coc' && get(g:, 'lint_tool', '') == 'coc'
        nnoremap <M-k>d :<C-u>CocDiagnostics<Cr>
    elseif (has('nvim') || v:version >= 800) && get(g:, 'lint_tool', '') != 'neomake'
        let g:lint_tool = 'ale'
        MyPlug 'dense-analysis/ale'
    elseif (has('nvim') || has('patch-7.4.503')) && index(['', 'neomake'], get(g:, 'lint_tool', '')) >= 0
        let g:lint_tool = 'neomake'
        MyPlug 'neomake/neomake'
    endif
endif
" ------------------------------
" ai_engine
" ------------------------------
if index(['coc', 'vim-lsp'], get(g:, 'complete_engine', '')) >= 0
    if HasPlug('ai')
        try
            " using try to check if kite_engine loaded
            autocmd VimEnter * call kite#enable_auto_start()
            " install kite plugin
            let g:ai_engine = 'kite'
            MyPlug 'kiteco/vim-plugin'
            let g:kite_supported_languages = ['*']
            let g:kite_tab_complete = 1
            nmap <silent> <buffer> gK <Plug>(kite-docs)
            nmap <silent> ,K         :KiteGotoDefinition<Cr>
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
    if g:python_version > 3
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
        if HasPlug('c') && !executable('ccls')
            let b:ycm_install = b:ycm_install . " --clangd-completer"
        endif
        if HasPlug('rust')
            let b:ycm_install = b:ycm_install . " --rust-completer"
        endif
        if executable('node') && HasPlug('javascript')
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
    if executable('yarn')
        MyPlug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
    else
        MyPlug 'neoclide/coc.nvim', {'branch': 'release'}
    endif
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
    if get(g:, 'ai_engine', '') == 'tabnine'
        let g:coc_global_extensions += ['coc-tabnine']
    endif
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
            \ 'coc-emmet'
            \ ]
    endif
    if HasPlug('javascript') || HasPlug('typescript')
        let g:coc_global_extensions += [
            \ 'coc-tsserver',
            \ 'coc-angular',
            \ 'coc-vetur'
            \ ]
    endif
    if HasPlug('go')
        let g:coc_global_extensions += ['coc-go']
    endif
    if HasPlug('rust')
        let g:coc_global_extensions += ['coc-rust-analyzer']
    endif
    if HasPlug('R')
        let g:coc_global_extensions += ['coc-r-lsp']
    endif
    if HasPlug('latex')
        let g:coc_global_extensions += ['coc-vimtex']
    endif
elseif get(g:, 'complete_engine', '') == "vim-lsp"
    MyPlug 'prabirshrestha/asyncomplete-lsp.vim'
    MyPlug 'prabirshrestha/asyncomplete.vim'
    MyPlug 'prabirshrestha/asyncomplete-file.vim'
    MyPlug 'prabirshrestha/asyncomplete-buffer.vim'
    MyPlug 'yuki-ycino/asyncomplete-dictionary'
    if executable('tmux')
        MyPlug 'wellle/tmux-complete.vim'
    endif
    " ctags
    if executable('ctags')
        MyPlug 'prabirshrestha/asyncomplete-tags.vim'
    endif
    " tabnine
    if get(g:, 'ai_engine', '') == 'tabine'
        if WINDOWS()
            MyPlug 'kitagry/asyncomplete-tabnine.vim', {'do': 'powershell.exe .\install.ps1'}
        else
            MyPlug 'kitagry/asyncomplete-tabnine.vim', {'do': './install.sh'}
        endif
    endif
    " snippets
    if g:complete_snippet == 'ultisnips'
        MyPlug 'prabirshrestha/asyncomplete-ultisnips.vim'
    else
        MyPlug 'prabirshrestha/asyncomplete-neosnippet.vim'
    endif
    " vim-lsp
    MyPlug 'prabirshrestha/vim-lsp'
    if !has('patch-8.1.1517') && !has('nvim')
        MyPlug 'Shougo/echodoc.vim'
        let g:echodoc_enable_at_startup = 1
        set cmdheight=2
    endif
endif
" TODO, nvim-lsp also use vim-lsp-settings to install lsp engine
if index(['vim-lsp', 'nvim-lsp'], get(g:, 'complete_engine', '')) >= 0
    MyPlug 'mattn/vim-lsp-settings'
endif
