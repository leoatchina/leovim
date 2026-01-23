" --------------------------
" R & python
" --------------------------
if utils#is_win()
    let g:R_exe = utils#expand(exepath(get(g:, 'R_exe', 'R.exe')))
else
    let g:R_exe = utils#expand(exepath(get(g:, 'R_exe', 'R')))
endif
if has('nvim') && pack#get('jupynium') && g:python_version > 3.07
    PlugAdd 'kiyoon/jupynium.nvim', {'do': get(g:, 'jupynium_install', 'pip3 install --user .')}
elseif pack#get('nvim-r') && (has('nvim') || v:version >= 802) && executable(g:R_exe)
    PlugAdd 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
endif
" ------------------------------
" helpful
" ------------------------------
PlugAdd 'tweekmonster/helpful.vim', {'for': ['vim', 'lua', 'help']}
" ------------------------------
" ps1
" ------------------------------
if utils#is_win()
    PlugAdd 'pprovost/vim-ps1', {'for': 'ps1'}
endif
" ------------------------------
" web
" ------------------------------
if pack#get('web')
    PlugAdd 'mattn/emmet-vim', {'for': g:web_filetypes}
    PlugAdd 'chemzqm/wxapp.vim', {'for': g:web_filetypes}
endif
" --------------------------
" perl
" --------------------------
if pack#get('perl') || pack#get('bioinfo')
    PlugAdd 'vim-perl/vim-perl', {'for': 'perl'}
endif
" --------------------------
" bioinfo
" --------------------------
if pack#get('bioinfo')
    PlugAdd 'bioSyntax/bioSyntax-vim', {'for': ['fq', 'fa', 'fasta', 'fastq', 'gtf', 'gtt', 'sam', 'bam']}
endif
" --------------------------
" C language
" --------------------------
if pack#get('c')
    PlugAdd 'leoatchina/a.vim', {'for': g:c_filetypes}
    if executable('cppman')
        PlugAdd 'skywind3000/vim-cppman', {'for': g:c_filetypes}
    endif
endif
if pack#get('clangd') && executable(utils#expand(get(g:, 'clangd_exe', 'clangd')))
    let g:clangd_exe = utils#expand(exepath(get(g:, 'clangd_exe', 'clangd')))
else
    let g:clangd_exe = ''
endif
if pack#get('ccls') && executable(utils#expand(get(g:, 'ccls_exe', 'ccls')))
    let g:ccls_exe = utils#expand(exepath(get(g:, 'ccls_exe', 'ccls')))
    PlugAdd 'm-pilia/vim-ccls', {'for': g:c_filetypes}
else
    let g:ccls_exe = ''
endif
" --------------------------
" rust
" --------------------------
if executable(utils#expand(get(g:, 'cargo_exe', 'cargo')))
    let g:cargo_exe = utils#expand(exepath(get(g:, 'cargo_exe', 'cargo')))
else
    let g:cargo_exe = ''
endif
if get(g:, 'cargo_exe', '') != '' && pack#get('rust') && v:version >= 800
    PlugAdd 'rust-lang/rust.vim', {'for': 'rust'}
    if pack#planned_lsp()
        PlugAdd 'mrcjkb/rustaceanvim', {'for': 'rust'}
    endif
endif
" --------------------------
" go
" --------------------------
if executable(utils#expand(get(g:, 'gobin_exe', 'go')))
    let g:gobin_exe = utils#expand(exepath(get(g:, 'gobin_exe', 'go')))
else
    let g:gobin_exe = ''
endif
if get(g:, 'gobin_exe', '') != '' && pack#get('go') && (has('patch-8.1.2269') || has('nvim'))
    PlugAdd 'fatih/vim-go', {'for': ['go', 'gosum', 'gomod'], 'do': ':GoInstallBinaries'}
endif
" ------------------------------
" nvim-java
" ------------------------------
if pack#planned_lsp() && pack#get('java')
    PlugAdd 'nvim-java/nvim-java'
    PlugAdd 'nvim-java/nvim-java-dap'
    PlugAdd 'nvim-java/nvim-java-core'
    PlugAdd 'nvim-java/nvim-java-test'
    PlugAdd 'nvim-java/nvim-java-refactor'
    PlugAdd 'nvim-java/lua-async-await'
    PlugAdd 'JavaHello/spring-boot.nvim'
endif
" ------------------------------
" latex
" ------------------------------
if pack#get('latex') && executable(get(g:, "vimtex_view_method", ''))
    PlugAdd 'lervag/vimtex', {'for': 'latex'}
endif
" ------------------------------
" markdown
" ------------------------------
if has('nvim-0.10.3')
    PlugAdd 'MeanderingProgrammer/render-markdown.nvim'
endif
if pack#get('markdown')
    PlugAdd 'leoatchina/vim-table-mode'
    PlugAdd 'junegunn/vim-journal', {'for': 'markdown'}
    PlugAdd 'ferrine/md-img-paste.vim', {'for': 'markdown'}
    if g:node_version > 12 && (has('nvim') || v:version >= 801)
        PlugAdd 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
        PlugAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    elseif g:python_version > 0
        PlugAdd 'iamcco/markdown-preview.vim', {'for': ['markdown']}
        PlugAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    endif
endif
" ------------------------------
" translate
" ------------------------------
if pack#get('translate') && v:version >= 800 && g:python_version >= 3.06
    PlugAdd 'voldikss/vim-translator'
endif
