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
    au Filetype c,cpp nnoremap <leader>ry :CopyCode<cr>
    au Filetype c,cpp nnoremap <leader>rp :PasteCode<cr>
    au Filetype c,cpp nnoremap <leader>rg :GoToFunImpl<cr>
    au Filetype c,cpp nnoremap <leader>rs :Switch<cr>
    au Filetype c,cpp nnoremap <leader>rf :FormatFunParam<cr>
    au Filetype c,cpp nnoremap <leader>ri :FormatIf<cr>
    au Filetype c,cpp nnoremap <leader>rg :GenTryCatch<cr>
    au Filetype c,cpp xnoremap <leader>rg :GenTryCatch<cr>
    if executable('ccls')
        MyPlug 'm-pilia/vim-ccls', {'for': ['c', 'cpp']}
        au Filetype c,cpp nnoremap <leader>rl  :Ccls<Tab>
        au Filetype c,cpp nnoremap <leader>rb  :CclsBase<Cr>
        au Filetype c,cpp nnoremap <leader>rhb :CclsBaseHierarchy<Cr>
        au Filetype c,cpp nnoremap <leader>rd  :CclsDerived<Cr>
        au Filetype c,cpp nnoremap <leader>rhd :CclsDerivedHierarchy<Cr>
        au Filetype c,cpp nnoremap <leader>rc  :CclsCallers<Cr>
        au Filetype c,cpp nnoremap <leader>rhc :CclsCallHierarchy<Cr>
        au Filetype c,cpp nnoremap <leader>re  :CclsCallees<Cr>
        au Filetype c,cpp nnoremap <leader>rhe :CclsCalleeHierarchy<Cr>
        au Filetype c,cpp xnoremap <leader>rv  :CclsVars<Cr>
        au Filetype c,cpp nnoremap <leader>rmm :CclsMembers<Cr>
        au Filetype c,cpp nnoremap <leader>rhm :CclsMemberHierarchy<Cr>
        au Filetype c,cpp nnoremap <leader>rmf :CclsMemberFunctions<Cr>
        au Filetype c,cpp nnoremap <leader>rhf :CclsMemberFunctionHierarchy<Cr>
        au Filetype c,cpp nnoremap <leader>rmt :CclsMemberTypes<Cr>
        au Filetype c,cpp nnoremap <leader>rht :CclsMemberTypeHierarchy<Cr>
    endif
    if executable('cppman')
        MyPlug 'skywind3000/vim-cppman', {'for': ['c', 'cpp']}
        autocmd FileType c,cpp setlocal keywordprg=:Cppman
        autocmd FileType c,cpp nnoremap <leader>cm :Cppman<Space>
        autocmd FileType c,cpp nnoremap <leader>cM :Cppman!<Space>
        autocmd FileType c,cpp nnoremap <leader>ck :Cppman <C-r><C-w>
        autocmd FileType c,cpp xnoremap <leader>ck :Cppman <C-r>=GetVisualSelection()<Cr>
    endif
endif
" --------------------------
" web
" --------------------------
if HasPlug('web')
    if g:complete_engine != 'coc'
        MyPlug 'hail2u/vim-css3-syntax', {'for': ['css', 'css3']}
        MyPlug 'mattn/emmet-vim', {'for': 'php'}
        MyPlug 'alvan/vim-closetag', {'for': 'html'}
        let g:user_emmet_mode           = 'a'
        let g:user_emmet_leader_key     = '<C-y>'
        let g:user_emmet_install_global = 0
        autocmd FileType html,php,css,vue,haml EmmetInstall
    endif
    MyPlug 'posva/vim-vue', {'for': ['javascript', 'typescript']}
    MyPlug 'pangloss/vim-javascript', {'for': ['javascript', 'typescript']}
    MyPlug 'HerringtonDarkholme/yats.vim', {'for': 'typescript'}
    let g:javascript_plugin_jsdoc = 1
    let g:javascript_plugin_ngdoc = 1
    let g:javascript_plugin_flow  = 1
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
