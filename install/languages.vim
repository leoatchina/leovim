" --------------------------
" file syntax support
" --------------------------
if has('nvim') || v:version >= 800
    MyPlug 'sheerun/vim-polyglot'
endif
" --------------------------
" R language
" --------------------------
if HasPlug('R') && executable('R') && (has('nvim') || v:version >= 801)
    MyPlug 'jalvesaq/Nvim-R', {'for': 'r'}
endif
" --------------------------
" C language
" --------------------------
if HasPlug('c')
    MyPlug 'chxuan/cpp-mode', {'for': ['c', 'cpp']}
    au Filetype c,cpp nnoremap <M-y>y :CopyCode<cr>
    au Filetype c,cpp nnoremap <M-y>p :PasteCode<cr>
    au Filetype c,cpp nnoremap <M-y>g :GoToFunImpl<cr>
    au Filetype c,cpp nnoremap <M-y>s :Switch<cr>
    au Filetype c,cpp nnoremap <M-y>f :FormatFunParam<cr>
    au Filetype c,cpp nnoremap <M-y>i :FormatIf<cr>
    au Filetype c,cpp nnoremap <M-y>g :GenTryCatch<cr>
    au Filetype c,cpp xnoremap <M-y>g :GenTryCatch<cr>
    if executable('cppman')
        MyPlug 'skywind3000/vim-cppman', {'for': ['c', 'cpp']}
        autocmd FileType c,cpp setlocal keywordprg=:Cppman
        autocmd FileType c,cpp nnoremap <leader>cm :Cppman<Space>
        autocmd FileType c,cpp nnoremap <leader>cM :Cppman!<Space>
        autocmd FileType c,cpp nnoremap <M-y>k :Cppman <C-r><C-w>
        autocmd FileType c,cpp xnoremap <M-y>k :Cppman <C-r>=GetVisualSelection()<Cr>
    endif
    if executable('ccls')
        MyPlug 'm-pilia/vim-ccls', {'for': ['c', 'cpp']}
        au Filetype c,cpp nnoremap <M-y>l  :Ccls
        au Filetype c,cpp nnoremap <M-y>b  :CclsBase<Cr>
        au Filetype c,cpp nnoremap <M-y>hb :CclsBaseHierarchy<Cr>
        au Filetype c,cpp nnoremap <M-y>d  :CclsDerived<Cr>
        au Filetype c,cpp nnoremap <M-y>hd :CclsDerivedHierarchy<Cr>
        au Filetype c,cpp nnoremap <M-y>c  :CclsCallers<Cr>
        au Filetype c,cpp nnoremap <M-y>hc :CclsCallHierarchy<Cr>
        au Filetype c,cpp nnoremap <M-y>e  :CclsCallees<Cr>
        au Filetype c,cpp nnoremap <M-y>he :CclsCalleeHierarchy<Cr>
        au Filetype c,cpp xnoremap <M-y>v  :CclsVars<Cr>
        au Filetype c,cpp nnoremap <M-y>mm :CclsMembers<Cr>
        au Filetype c,cpp nnoremap <M-y>hm :CclsMemberHierarchy<Cr>
        au Filetype c,cpp nnoremap <M-y>mf :CclsMemberFunctions<Cr>
        au Filetype c,cpp nnoremap <M-y>hf :CclsMemberFunctionHierarchy<Cr>
        au Filetype c,cpp nnoremap <M-y>mt :CclsMemberTypes<Cr>
        au Filetype c,cpp nnoremap <M-y>ht :CclsMemberTypeHierarchy<Cr>
    endif
endif
" --------------------------
" web
" --------------------------
if HasPlug('web') && g:complete_engine != 'coc'
    MyPlug 'hail2u/vim-css3-syntax', {'for': ['css', 'css3']}
    MyPlug 'mattn/emmet-vim', {'for': 'php'}
    let g:user_emmet_mode           = 'a'
    let g:user_emmet_leader_key     = '<C-y>'
    let g:user_emmet_install_global = 0
    autocmd FileType html,php,css,vue,haml EmmetInstall
endif
" --------------------------
" javascript
" --------------------------
if HasPlug('javascript')
    MyPlug 'posva/vim-vue', {'for': ['javascript', 'typescript']}
    MyPlug 'pangloss/vim-javascript', {'for': ['javascript', 'typescript']}
    let g:javascript_plugin_jsdoc = 1
    let g:javascript_plugin_ngdoc = 1
    let g:javascript_plugin_flow  = 1
endif
" --------------------------
" typescript
" --------------------------
if HasPlug('typescript')
    MyPlug 'HerringtonDarkholme/yats.vim', {'for': 'typescript'}
endif
" --------------------------
" perl
" --------------------------
if HasPlug('perl')
    MyPlug 'vim-perl/vim-perl', {'for': 'perl'}
endif
" --------------------------
" julia rust
" --------------------------
if has('nvim') || has('patch-7.4.1154')
    " julia
    if HasPlug('julia') && executable('julia')
        MyPlug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}
    endif
    " rust
    if HasPlug('rust') && executable('rustc')
        MyPlug 'rust-lang/rust.vim', {'for': 'rust'}
    endif
endif
" --------------------------
" bioinfo
" --------------------------
if HasPlug('bioinfo')
    MyPlug 'bioSyntax/bioSyntax-vim', {'for': ['fq', 'fa', 'fasta', 'fastq', 'gtf', 'gtt', 'sam', 'bam']}
endif
" --------------------------
" writing
" --------------------------
if HasPlug('writing')
    MyPlug 'junegunn/vim-journal', {'for': 'markdown'}
    MyPlug 'ferrine/md-img-paste.vim', {'for': 'markdown'}
    " markdown preview
    if executable('node') &&  (has('nvim') || v:version >= 801)
        let g:markdown_tool = 'markdown-preview.nvim'
        if executable('yarn')
            MyPlug 'iamcco/markdown-preview.nvim', {'for': ['markdown', 'vim-plug'], 'do': 'cd app & yarn install'}
        else
            MyPlug 'iamcco/markdown-preview.nvim', {'for': ['markdown', 'vim-plug'], 'do': { -> mkdp#util#install() }}
        endif
        MyPlug 'iamcco/mathjax-support-for-mkdp', {'for':'markdown'}
    elseif g:python_version > 0
        let g:markdown_tool = 'markdown-preview.vim'
        MyPlug 'iamcco/markdown-preview.vim', {'for':'markdown'}
        MyPlug 'iamcco/mathjax-support-for-mkdp', {'for':'markdown'}
    endif
    if executable('mdr') && (has('nvim') || has('patch-8.1.1401'))
        MyPlug 'skanehira/preview-markdown.vim', {'for':'markdown'}
    endif
endif
" --------------------------
" latex
" --------------------------
if HasPlug('latex')
    if exists("g:vimtex_view_method")
        if executable(g:vimtex_view_method)
            MyPlug 'lervag/vimtex', {'for': 'latex'}
            au FileType tex set conceallevel=1
            let g:tex_flavor           = get(g:, 'tex_flaver', 'latex')
            let g:tex_conceal          = get(g:, 'tex_conceal', 'abdmg')
            let g:vimtex_quickfix_mode = get(g:, 'vimtex_quickfix_mode', 0)
        else
            echoe g:vimtex_view_method . " is not executable"
        endif
    else
        echoe "g:vimtex_view_method is not configed in your .local file"
    endif
endif
