" ------------------------
" shortmess
" ------------------------
if has('patch-9.0.1568')
    set sms
endif
if has('patch-8.1.1270')
    set shortmess+=S
endif
if has('patch-7.4.1829')
    set shortmess+=a
    set shortmess+=c
endif
" --------------------------
" complete engine
" --------------------------
set completeopt=menu,menuone
try
    set completeopt+=noinsert
    set completeopt+=noselect
    if exists('+completepopup') != 0
        set completeopt+=popup
        set completepopup=align:menu,border:off,highlight:WildMenu
    endif
catch
    call AddRequire('mcm')
endtry
if Require('nocomplete')
    let g:complete_engine = ''
elseif Require('mcm')
    let g:complete_engine = 'mcm'
elseif Require('apm')
    if v:version >= 800
        let g:complete_engine = 'apm'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('cmp')
    if has('nvim-0.9')
        let g:complete_engine = 'cmp'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('coc')
    if g:node_version >= 16.18 && (has('nvim-0.8.1') || has('patch-8.2.0750'))
        let g:complete_engine = 'coc'
    else
        let s:smart_engine_select = 1
    endif
else
    let s:smart_engine_select = 1
endif
if get(s:, 'smart_engine_select', 0)
    if has('nvim-0.9')
        let g:complete_engine = 'cmp'
    elseif g:node_version >= 16.18 && has('nvim-0.8.1')
        let g:complete_engine = 'coc'
    elseif UNIX()
        let g:complete_engine = 'mcm'
    elseif v:version >= 800
        let g:complete_engine = 'apm'
    endif
endif
" ------------------------------
" complete_engine
" ------------------------------
if g:complete_engine == 'cmp'
    " complete related
    PlugAdd 'hrsh7th/nvim-cmp'
    PlugAdd 'hrsh7th/cmp-nvim-lsp'
    PlugAdd 'hrsh7th/cmp-nvim-lua'
    PlugAdd 'hrsh7th/cmp-buffer'
    PlugAdd 'hrsh7th/cmp-cmdline'
    PlugAdd 'FelipeLema/cmp-async-path'
    PlugAdd 'petertriho/cmp-git'
    PlugAdd 'hrsh7th/cmp-nvim-lsp-signature-help'
    PlugAdd 'onsails/lspkind-nvim'
    PlugAdd 'saadparwaiz1/cmp_luasnip'
    " snippet
    PlugAdd 'L3MON4D3/luasnip'
    " lsp related
    PlugAdd 'neovim/nvim-lspconfig'
    PlugAdd 'williamboman/mason-lspconfig.nvim'
    PlugAdd 'mfussenegger/nvim-lint'
    PlugAdd 'DNLHC/glance.nvim'
    PlugAdd 'gfanto/fzf-lsp.nvim'
    PlugAdd 'josa42/nvim-lightline-lsp'
    PlugAdd 'lvimuser/lsp-inlayhints.nvim'
    PlugAdd 'camilledejoye/nvim-lsp-selection-range'
    PlugAdd 'fgheng/winbar.nvim'
    PlugAdd 'VonHeikemen/lsp-zero.nvim'
    PlugAdd 'Wansmer/symbol-usage.nvim'
    PlugAdd 'aznhe21/actions-preview.nvim'
    PlugAdd 'stevanmilic/nvim-lspimport'
    if UNIX()
        PlugAdd 'folke/neoconf.nvim'
    endif
elseif g:complete_engine == 'coc'
    if get(g:, 'coc_install_release', 0) == 0
        PlugAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
    else
        PlugAdd 'neoclide/coc.nvim', {'branch': 'release'}
    endif
    PlugAddOpt 'coc-fzf'
endif
if g:complete_engine != '' && g:complete_engine != 'apm' && exists('v:true') && exists("##TextChangedP")
    PlugAdd 'hrsh7th/vim-vsnip'
    PlugAdd 'rafamadriz/friendly-snippets'
    if g:complete_engine == 'mcm'
        PlugAdd 'hrsh7th/vim-vsnip-integ'
    endif
endif
PlugAddOpt 'vim-dict'
" ------------------------------
" AI completion
" ------------------------------
if has('patch-9.0.0185') || has('nvim')
    if Require('codeium')
        PlugAdd 'Exafunction/codeium.vim'
    elseif Require('copilot') && g:node_version >= 16.18
        PlugAdd 'github/copilot.vim'
        if has('nvim-0.9.5')
            PlugAdd 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
        endif
    endif
endif
if has('nvim') && UNIX() && filereadable(expand("~/.gp.key"))
    PlugAdd 'Robitx/gp.nvim'
endif
" ------------------------------
" check tool
" ------------------------------
if g:complete_engine == 'cmp'
    let g:check_tool = 'lsp'
elseif g:complete_engine == 'coc'
    if g:python_version > 3.06 && Require('ale')
        let g:check_tool = 'ale'
    else
        let g:check_tool = 'coc'
    endif
elseif g:python_version > 3.06 && v:version >= 800
    let g:check_tool = 'ale'
else
    let g:check_tool = ''
endif
if g:check_tool == 'ale'
    PlugAdd 'dense-analysis/ale'
    PlugAdd 'maximbaz/lightline-ale'
endif
" ------------------------------
" debug tool
" ------------------------------
if g:python_version > 3.08 && (v:version >= 802 && (Require('debug') || Require('vimspector')) || has('nvim-0.8.1') && Require('vimspector'))
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', {'do': g:python_path . vimspector_install}
elseif has('nvim-0.9') && Require('debug')
    PlugAdd 'mfussenegger/nvim-dap'
    PlugAdd 'rcarriga/nvim-dap-ui'
    PlugAdd 'jay-babu/mason-nvim-dap.nvim'
endif
" ------------------------------
" format tools
" ------------------------------
PlugAdd 'sbdchd/neoformat'
" ------------------------------
" CVS
" ------------------------------
if executable('git') && v:version >= 800 && g:git_version >= 1.85
    PlugAdd 'tpope/vim-fugitive'
    PlugAdd 'junegunn/gv.vim'
    if g:has_popup_floating && UNIX()
        PlugAdd 'APZelos/blamer.nvim'
    endif
endif
" ------------------------------
" fuzzy_finder
" ------------------------------
if exists('*systemlist') && has('patch-7.4.1304')
    PlugAdd 'junegunn/fzf.vim'
    if WINDOWS()
        PlugAdd 'junegunn/fzf', {'do': 'Powershell ./install.ps1 --all', 'dir': expand('$HOME\\AppData\\Local\\fzf')}
    else
        PlugAdd 'junegunn/fzf', {'do': './install --all', 'dir': expand('~/.local/fzf')}
    endif
    if has('nvim')
        PlugAdd 'kevinhwang91/nvim-bqf'
    endif
endif
if has('nvim') || has('patch-7.4.1126')
    if g:python_version > 2 && !Require('noleaderf') && !Require('no-leaderf')
        PlugAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
    endif
endif
" ----------------------------
" schemes && textobj
" ----------------------------
if has('nvim-0.9.2') && get(g:, 'nvim_treesitter_install', UNIX() && !CYGWIN())
    PlugAdd 'kevinhwang91/nvim-treesitter', {'do': ':TSUpdate'}
endif
if Planned('nvim-treesitter')
    PlugAdd 'nvim-treesitter/nvim-treesitter-textobjects'
    PlugAdd 'nvim-treesitter/nvim-treesitter-refactor'
    PlugAdd 'm-demare/hlargs.nvim'
elseif exists('*search') && exists('*getpos') && g:complete_engine != 'coc'
    PlugAdd 'thinca/vim-textobj-function-perl', {'for': 'perl'}
    PlugAdd 'kentaro/vim-textobj-function-php', {'for': 'php'}
    PlugAdd 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    PlugAdd 'bps/vim-textobj-python', {'for': 'python'}
endif
if !Planned('nvim-treesitter') && Require('c') && (Planned('coc.nvim') || Planned('nvim-cmp'))
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'sainnhe/sonokai'
    PlugAdd 'sainnhe/everforest'
    PlugAdd 'sainnhe/gruvbox-material'
    PlugAdd 'bluz71/vim-moonfly-colors'
    if has('nvim-0.8.1')
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
        PlugAdd 'EdenEast/nightfox.nvim'
    endif
endif
" ----------------------------
" addtional plugins
" ----------------------------
if Planned('nvim-cmp') || Planned('nvim-dap') || Planned('CopilotChat.nvim')
    PlugAdd 'williamboman/mason.nvim'
    PlugAdd 'MunifTanjim/nui.nvim'
    PlugAdd 'nvim-lua/plenary.nvim'
    PlugAdd 'nvim-neotest/nvim-nio'
endif
if has('nvim') && Require('jupynium') && g:python_version > 3.07
    PlugAdd 'kiyoon/jupynium.nvim', {'do': get(g:, 'jupynium_install', 'pip3 install --user .')}
endif
" ----------------------------
" extend Installed function
" ----------------------------
function! InstalledFzf() abort
    return Installed('fzf', 'fzf.vim')
endfunction
function! InstalledLeaderf() abort
    return Installed('leaderf')
endfunction
function! InstalledCoc() abort
    return Installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && InstalledFzf()
endfunction
function! InstalledNvimLsp() abort
    return Installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'fzf-lsp.nvim',
                \ 'glance.nvim',
                \ 'winbar.nvim',
                \ 'actions-preview.nvim',
                \ 'lsp-zero.nvim',
                \ 'symbol-usage.nvim',
                \ 'nvim-lspimport',
                \ )
endfunction
function! InstalledCmp() abort
    return Installed(
                \ 'nvim-cmp',
                \ 'cmp-buffer',
                \ 'cmp-cmdline',
                \ 'cmp-nvim-lsp',
                \ 'cmp-nvim-lua',
                \ 'cmp-async-path',
                \ 'cmp-git',
                \ 'cmp-nvim-lsp-signature-help',
                \ 'cmp_luasnip',
                \ 'luasnip',
                \ 'friendly-snippets',
                \ 'nvim-lint',
                \ 'lspkind-nvim',
                \ )
endfunction
function! InstalledAdvCompEng() abort
    return InstalledCoc() || InstalledNvimLsp()
endfunction
function! PrefFzf()
    return InstalledFzf() && (get(g:, 'prefer_fzf', UNIX()) || !InstalledLeaderf())
endfunction
