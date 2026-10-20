" --------------------------
" R & python
" --------------------------
if utils#is_win()
    let g:R_exe = utils#expand(exepath(get(g:, 'R_exe', 'R.exe')))
else
    let g:R_exe = utils#expand(exepath(get(g:, 'R_exe', 'R')))
endif
if has('nvim') && pack#get('jupynium') && g:python_version > 3.07
    PackAdd 'kiyoon/jupynium.nvim', {'do': get(g:, 'jupynium_install', 'pip3 install --user .'), 'cfg': 'cfg.jupynium'}
elseif pack#get('nvim-r') && (has('nvim') || v:version >= 802) && executable(g:R_exe)
    PackAdd 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
endif
" ------------------------------
" helpful
" ------------------------------
PackAdd 'tweekmonster/helpful.vim', {'for': ['vim', 'lua', 'help']}
" ------------------------------
" ps1
" ------------------------------
if utils#is_win()
    PackAdd 'pprovost/vim-ps1', {'for': 'ps1'}
endif
" ------------------------------
" web
" ------------------------------
if pack#get('web')
    PackAdd 'mattn/emmet-vim', {'for': g:web_filetypes}
    PackAdd 'chemzqm/wxapp.vim', {'for': g:web_filetypes}
endif
" --------------------------
" perl
" --------------------------
if pack#get('perl') || pack#get('bioinfo')
    PackAdd 'vim-perl/vim-perl', {'for': 'perl'}
endif
" --------------------------
" bioinfo
" --------------------------
if pack#get('bioinfo')
    PackAdd 'bioSyntax/bioSyntax-vim', {'for': ['fq', 'fa', 'fasta', 'fastq', 'gtf', 'gtt', 'sam', 'bam']}
endif
" --------------------------
" C language
" --------------------------
if pack#get('c')
    PackAdd 'leoatchina/a.vim', {'for': g:c_filetypes}
    if executable('cppman')
        PackAdd 'skywind3000/vim-cppman', {'for': g:c_filetypes}
    endif
endif
if pack#get('clangd') && executable(utils#expand(get(g:, 'clangd_exe', 'clangd')))
    let g:clangd_exe = utils#expand(exepath(get(g:, 'clangd_exe', 'clangd')))
else
    let g:clangd_exe = ''
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
    PackAdd 'rust-lang/rust.vim', {'for': 'rust'}
    if pack#planned_lsp() && has('nvim-0.12')
        PackAdd 'mrcjkb/rustaceanvim', {'for': 'rust'}
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
    PackAdd 'fatih/vim-go', {'for': ['go', 'gosum', 'gomod'], 'do': ':GoInstallBinaries'}
endif
" ------------------------------
" nvim-java
" ------------------------------
if pack#planned_lsp() && pack#get('java')
    PackAdd 'nvim-java/nvim-java-dap'
    PackAdd 'nvim-java/nvim-java-core'
    PackAdd 'nvim-java/nvim-java-test'
    PackAdd 'nvim-java/nvim-java-refactor'
    PackAdd 'nvim-java/lua-async-await'
    PackAdd 'JavaHello/spring-boot.nvim', {'deps': 'nvim-lspconfig', 'cfg': 'cfg.springboot'}
    PackAdd 'nvim-java/nvim-java', {
                \ 'deps': [
                \   'nvim-java-dap', 'nvim-java-core', 'nvim-java-test',
                \   'nvim-java-refactor', 'lua-async-await',
                \   'spring-boot.nvim', 'nvim-dap',
                \ ],
                \ 'init': "require('java').setup()",
                \ }
endif
" ------------------------------
" latex
" ------------------------------
if pack#get('latex') && executable(get(g:, "vimtex_view_method", ''))
    PackAdd 'lervag/vimtex', {'for': 'latex'}
endif
" ------------------------------
" markdown
" ------------------------------
if has('nvim-0.10.3')
    let g:lazyload_render_markdown_config = {'file_types': ['markdown', 'vimwiki']}
    PackAdd 'MeanderingProgrammer/render-markdown.nvim', {'for': ['markdown', 'vimwiki']}
    augroup LeoRenderMarkdown
        autocmd!
        " Reattach the first buffer using only the renderer's own FileType hook.
        autocmd User render-markdown.nvim ++once lua
                    \ require('render-markdown').setup(vim.g.lazyload_render_markdown_config);
                    \ vim.api.nvim_exec_autocmds('FileType', { group = 'RenderMarkdown', buffer = 0 })
    augroup END
endif
if pack#get('markdown')
    PackAdd 'leoatchina/vim-table-mode'
    PackAdd 'junegunn/vim-journal', {'for': 'markdown'}
    PackAdd 'ferrine/md-img-paste.vim', {'for': ['markdown', 'vim-plug', 'txt', 'latex']}
    if g:node_version > 12 && (has('nvim') || v:version >= 801)
        PackAdd 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
        PackAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    elseif g:python_version > 0
        PackAdd 'iamcco/markdown-preview.vim', {'for': ['markdown']}
        PackAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    endif
endif
" ------------------------------
" translate
" ------------------------------
if pack#get('translate') && v:version >= 800 && g:python_version >= 3.06
    PackAdd 'voldikss/vim-translator', {'on': [
                \ 'Translate', 'TranslateW', 'TranslateR', 'TranslateX', 'TranslateH', 'TranslateL',
                \ '<Plug>Translate', '<Plug>TranslateV', '<Plug>TranslateW', '<Plug>TranslateWV',
                \ '<Plug>TranslateR', '<Plug>TranslateRV', '<Plug>TranslateX']}
endif
