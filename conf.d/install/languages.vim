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
" R language
" --------------------------
if (Require('R') || Require('bioinfo')) && (has('nvim-0.8') || v:version >= 802) && executable(Expand(get(g:, 'R_exe', 'R')))
    let g:R_exe = Expand(exepath(get(g:, 'R_exe', 'R')))
    PlugAdd 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
else
    let g:R_exe = ''
endif
" --------------------------
" C language
" --------------------------
if Require('c')
    PlugAdd 'chxuan/cpp-mode'
    PlugAdd 'leoatchina/a.vim', {'for': g:cfile_types}
    if executable('cppman')
        PlugAdd 'skywind3000/vim-cppman'
    endif
endif
if Require('ccls') && executable(Expand(get(g:, 'ccls_exe', 'ccls')))
    let g:ccls_exe = Expand(exepath(get(g:, 'ccls_exe', 'ccls')))
    PlugAdd 'm-pilia/vim-ccls', {'for': g:cfile_types}
else
    let g:ccls_exe = ''
endif
if Require('clangd') && executable(Expand(get(g:, 'clangd_exe', 'clangd')))
    let g:clangd_exe = Expand(exepath(get(g:, 'clangd_exe', 'clangd')))
else
    let g:clangd_exe = ''
endif
" --------------------------
" rust
" --------------------------
if Require('rust') && executable(Expand(get(g:, 'cargo_exe', 'cargo'))) && v:version >= 800
    let g:cargo_exe = Expand(exepath(get(g:, 'cargo_exe', 'cargo')))
    PlugAdd 'rust-lang/rust.vim', {'for': 'rust'}
    if Planned('nvim-cmp')
        PlugAdd 'mrcjkb/rustaceanvim', {'for': 'rust'}
    endif
else
    let g:cargo_exe = ''
endif
" --------------------------
" go
" --------------------------
if Require('go') && (has('patch-8.1.2269') || has('nvim')) && executable(Expand(get(g:, 'go_exe', 'go')))
    let g:go_exe = Expand(exepath(get(g:, 'go_exe', 'go')))
    PlugAdd 'fatih/vim-go', {'for': ['go', 'gosum', 'gomod'], 'do': ':GoInstallBinaries'}
else
    let g:go_exe = ''
endif
" ------------------------------
" nvim-java
" ------------------------------
if executable(Expand(get(g:, 'java_exe', 'java')))
    let g:java_exe = Expand(exepath(get(g:, 'java_exe', 'java')))
else
    let g:java_exe = ''
endif
if Require('java') && Planned('nvim-lspconfig') && Planned('nvim-dap') && g:python_version > 3.09
    PlugAdd 'nvim-java/nvim-java-refactor'
    PlugAdd 'nvim-java/nvim-java-core'
    PlugAdd 'nvim-java/nvim-java-test'
    PlugAdd 'nvim-java/nvim-java-dap'
    PlugAdd 'nvim-java/lua-async-await'
    PlugAdd 'nvim-java/nvim-java'
    if WINDOWS()
        let g:jars_dir = Expand("$HOME/.leovim.windows/jars")
    else
        let g:jars_dir = Expand("$HOME/.leovim.unix/jars")
    endif
    if isdirectory(g:jars_dir)
        PlugAdd('JavaHello/spring-boot.nvim')
    endif
endif
