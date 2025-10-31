" ----------------------------
" extend Planned function
" ----------------------------
function! PlannedFzf() abort
    return Planned('fzf', 'fzf.vim')
endfunction
function! PlannedCoc() abort
    return Require('coc') && g:node_version >= 16.18 && (has('nvim') || has('patch-9.0.0438'))
endfunction
function! PlannedLsp() abort
    return (Require('cmp') || Require('blink') || Require('blink.lua')) && has('nvim-0.11')
endfunction
function! PlannedAdvCompEng() abort
    return PlannedCoc() || PlannedLsp()
endfunction
function! PlannedLeaderf() abort
    return Planned('leaderf')
endfunction
function! PrefFzf()
    return PlannedFzf() && (get(g:, 'prefer_fzf', UNIX()) || !PlannedLeaderf())
endfunction
function! InstalledLsp() abort
    return Installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'call-graph.nvim',
                \ 'symbol-usage.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'formatter.nvim',
                \ 'dropbar.nvim',
                \ 'aerial.nvim',
                \ )
endfunction
function! InstalledCoc() abort
    return Installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && PlannedFzf()
endfunction
function! InstalledBlink() abort
    return Installed('blink.cmp', 'friendly-snippets', 'nvim-autopairs')
endfunction
function! InstalledCmp() abort
    return Installed(
                \ 'nvim-cmp',
                \ 'cmp-nvim-lsp',
                \ 'cmp-nvim-lua',
                \ 'cmp-buffer',
                \ 'cmp-cmdline',
                \ 'cmp-vsnip',
                \ 'cmp-nvim-lsp-signature-help',
                \ 'cmp-async-path',
                \ 'lspkind-nvim',
                \ 'colorful-menu.nvim',
                \ 'friendly-snippets',
                \ 'nvim-autopairs',
                \ )
endfunction
function! InstalledAdv() abort
    return Installed('coc.nvim') || InstalledLsp()
endfunction
