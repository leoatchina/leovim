" --------------------------
" C language
" --------------------------
if Require('c')
    PlugAdd 'chxuan/cpp-mode'
    PlugAdd 'leoatchina/a.vim', {'for': g:c_filetypes}
    if executable('cppman')
        PlugAdd 'skywind3000/vim-cppman'
    endif
endif
if executable('ccls') && Require('ccls')
    PlugAdd 'm-pilia/vim-ccls', {'for': g:c_filetypes}
endif
" --------------------------
" rust
" --------------------------
if Require('rust') && executable('cargo') && v:version >= 800
    PlugAdd 'rust-lang/rust.vim', {'for': 'rust'}
    if Planned('nvim-cmp')
        PlugAdd 'mrcjkb/rustaceanvim', {'for': 'rust'}
    endif
endif
" --------------------------
" go
" --------------------------
if Require('go') && (has('patch-8.1.2269') || has('nvim')) && executable('go') && exists('$GOPATH')
    PlugAdd 'fatih/vim-go', {'for': ['go', 'gosum', 'gomod'], 'do': ':GoInstallBinaries'}
endif
" --------------------------
" R language
" --------------------------
if (Require('R') || Require('bioinfo')) && (has('nvim') || v:version >= 802)
    PlugAdd 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
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
" ------------------------------
" ps1
" ------------------------------
if WINDOWS()
    PlugAdd 'pprovost/vim-ps1', {'for': 'ps1'}
endif
" ---------------------------------
" java
" ---------------------------------
if Require('java') && g:python_version > 3.09 && Planned('nvim-lspconfig') && executable(get(g:, 'java_execute', 'java'))
    redir => java
    silent! execute "!" . Expand(g:java_execute) . " --version"
    redir END
    let java_version = matchstr(java, '\v\zs\d{1,}.\d{1,}.\d{1,}\ze')
    let g:java_version = StringToFloat(java_version, 1)
    if g:java_version > 11
        let g:java_execute = Expand(g:java_execute)
        let g:java_jdtls = 1
    endif
endif
