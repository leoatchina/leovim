" --------------------------
" R & python
" --------------------------
if WINDOWS()
    let g:R_exe = Expand(exepath(get(g:, 'R_exe', 'R.exe')))
else
    let g:R_exe = Expand(exepath(get(g:, 'R_exe', 'R')))
endif
if has('nvim') && Require('jupynium') && g:python_version > 3.07
    PlugAdd 'kiyoon/jupynium.nvim', {'do': get(g:, 'jupynium_install', 'pip3 install --user .')}
elseif Require('nvim-R') && (has('nvim-0.8') || v:version >= 802) && executable(g:R_exe)
    PlugAdd 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
endif
" ------------------------------
" helpful
" ------------------------------
PlugAdd 'tweekmonster/helpful.vim', {'for': ['vim', 'lua', 'help']}
" ------------------------------
" ps1
" ------------------------------
if WINDOWS()
    PlugAdd 'pprovost/vim-ps1', {'for': 'ps1'}
endif
" ------------------------------
" web
" ------------------------------
if Require('web')
    PlugAdd 'mattn/emmet-vim', {'for': g:web_filetypes}
    PlugAdd 'chemzqm/wxapp.vim', {'for': g:web_filetypes}
endif
" --------------------------
" perl
" --------------------------
if Require('perl') || Require('bioinfo')
    PlugAdd 'vim-perl/vim-perl', {'for': 'perl'}
endif
" --------------------------
" bioinfo
" --------------------------
if Require('bioinfo')
    PlugAdd 'bioSyntax/bioSyntax-vim', {'for': ['fq', 'fa', 'fasta', 'fastq', 'gtf', 'gtt', 'sam', 'bam']}
endif
" --------------------------
" C language
" --------------------------
if Require('c')
    PlugAdd 'leoatchina/a.vim', {'for': g:c_filetypes}
    if executable('cppman')
        PlugAdd 'skywind3000/vim-cppman', {'for': g:c_filetypes}
    endif
endif
if Require('clangd') && executable(Expand(get(g:, 'clangd_exe', 'clangd')))
    let g:clangd_exe = Expand(exepath(get(g:, 'clangd_exe', 'clangd')))
else
    let g:clangd_exe = ''
endif
if Require('ccls') && executable(Expand(get(g:, 'ccls_exe', 'ccls')))
    let g:ccls_exe = Expand(exepath(get(g:, 'ccls_exe', 'ccls')))
    PlugAdd 'm-pilia/vim-ccls', {'for': g:c_filetypes}
else
    let g:ccls_exe = ''
endif
" --------------------------
" rust
" --------------------------
if executable(Expand(get(g:, 'cargo_exe', 'cargo')))
    let g:cargo_exe = Expand(exepath(get(g:, 'cargo_exe', 'cargo')))
else
    let g:cargo_exe = ''
endif
if get(g:, 'cargo_exe', '') != '' && Require('rust') && v:version >= 800
    PlugAdd 'rust-lang/rust.vim', {'for': 'rust'}
    if Planned('nvim-cmp')
        PlugAdd 'mrcjkb/rustaceanvim', {'for': 'rust'}
    endif
endif
" --------------------------
" go
" --------------------------
if executable(Expand(get(g:, 'gobin_exe', 'go')))
    let g:gobin_exe = Expand(exepath(get(g:, 'gobin_exe', 'go')))
else
    let g:gobin_exe = ''
endif
if get(g:, 'gobin_exe', '') != '' && Require('go') && (has('patch-8.1.2269') || has('nvim'))
    PlugAdd 'fatih/vim-go', {'for': ['go', 'gosum', 'gomod'], 'do': ':GoInstallBinaries'}
endif
" ------------------------------
" nvim-java
" ------------------------------
if Require('java') && Planned('nvim-lspconfig') && Planned('nvim-dap')
    PlugAdd 'nvim-java/nvim-java'
    PlugAdd 'nvim-java/nvim-java-dap'
    PlugAdd 'nvim-java/nvim-java-core'
    PlugAdd 'nvim-java/nvim-java-test'
    PlugAdd 'nvim-java/lua-async-await'
    PlugAdd 'nvim-java/nvim-java-refactor'
    PlugAdd 'JavaHello/spring-boot.nvim'
endif
" ------------------------------
" latex
" ------------------------------
if Require('latex') && executable(get(g:, "vimtex_view_method", ''))
    PlugAdd 'lervag/vimtex', {'for': 'latex'}
endif
" ------------------------------
" markdown
" ------------------------------
if executable('mdr') && (has('nvim') || has('patch-8.1.1401'))
    PlugAddOpt 'preview-markdown.vim'
endif
if has('nvim-0.10')
    PlugAdd 'MeanderingProgrammer/render-markdown.nvim'
endif
if Require('markdown')
    PlugAdd 'leoatchina/vim-table-mode'
    PlugAdd 'junegunn/vim-journal', {'for': 'markdown'}
    PlugAdd 'ferrine/md-img-paste.vim', {'for': 'markdown'}
    if get(g:, 'node_version', 0) > 12 && (has('nvim') || v:version >= 801)
        PlugAdd 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
        PlugAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    elseif g:python_version > 0
        PlugAdd 'iamcco/markdown-preview.vim', {'for': ['markdown']}
        PlugAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    endif
endif
