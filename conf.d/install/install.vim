" ----------------------------
" extend Planned function
" ----------------------------
function! PlannedFzf() abort
    return Planned('fzf', 'fzf.vim')
endfunction
function! PlannedCoc() abort
    return Require('coc') && g:node_version >= 16.18 && (has('nvim-0.8') || has('patch-9.0.0438'))
endfunction
function! PlannedLsp() abort
    return (Require('cmp') || Require('builtin') || Require('blink') || Require('blink.lua')) && has('nvim-0.11')
endfunction
function! PlannedAdv() abort
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
                \ )
endfunction
function! InstalledCoc() abort
    return Installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && PlannedFzf()
endfunction
function! InstalledBlink() abort
    return Installed('blink.cmp', 'blink-cmp-dictionary', 'friendly-snippets', 'nvim-autopairs')
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
                \ 'cmp-dictionary',
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
" --------------------------
" complete engine
" --------------------------
set completeopt=menu,menuone
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
try
    set completeopt+=noinsert
    set completeopt+=noselect
    if exists('+completepopup') != 0
        set completeopt+=popup
        set completepopup=align:menu,border:off,highlight:WildMenu
    endif
catch
    if UNIX()
        call AddRequire('mcm')
    endif
endtry
if Require('nocomplete') || Require('noc')
    let g:complete_engine = ''
elseif Require('mcm')
    let g:complete_engine = 'mcm'
elseif PlannedCoc()
    let g:complete_engine = 'coc'
elseif Require('builtin')
    if has('nvim-0.11')
        let g:complete_engine = 'builtin'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('cmp')
    if has('nvim-0.11')
        let g:complete_engine = 'cmp'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('blink') || Require('blink.lua')
    if has('nvim-0.11')
        let g:complete_engine = 'blink'
    else
        let s:smart_engine_select = 1
    endif
else
    let s:smart_engine_select = 1
endif
if get(s:, 'smart_engine_select', 0)
    if has('nvim-0.11')
        call AddRequire('blink.lua')
        let g:complete_engine = 'blink'
    elseif g:node_version >= 16.18 && has('nvim-0.8')
        let g:complete_engine = 'coc'
    else
        let g:complete_engine = 'mcm'
    endif
endif
" ------------------------------
" complete_engine
" ------------------------------
if g:complete_engine == 'cmp'
    PlugAdd 'hrsh7th/nvim-cmp'
    PlugAdd 'hrsh7th/cmp-nvim-lsp'
    PlugAdd 'hrsh7th/cmp-nvim-lua'
    PlugAdd 'hrsh7th/cmp-buffer'
    PlugAdd 'hrsh7th/cmp-cmdline'
    PlugAdd 'hrsh7th/cmp-vsnip'
    PlugAdd 'hrsh7th/cmp-nvim-lsp-signature-help'
    PlugAdd 'uga-rosa/cmp-dictionary'
    PlugAdd 'FelipeLema/cmp-async-path'
    PlugAdd 'onsails/lspkind-nvim'
    PlugAdd 'xzbdmw/colorful-menu.nvim'
elseif g:complete_engine == 'blink'
    if executable('cargo') && !Require('blink.lua')
        PlugAdd 'Saghen/blink.cmp', {'do': 'cargo build --release'}
    else
        PlugAdd 'Saghen/blink.cmp'
    endif
    PlugAdd 'Kaiser-Yang/blink-cmp-dictionary'
elseif g:complete_engine == 'coc'
    if get(g:, 'coc_install_release', 0)
        PlugAdd 'neoclide/coc.nvim', {'branch': 'release'}
    else
        PlugAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
    endif
    PlugAddOpt 'coc-fzf'
endif
" ------------------------------
" dict && snippets
" ------------------------------
PlugAddOpt 'vim-dict'
if g:complete_engine != '' && exists('v:true') && exists("##TextChangedP")
    PlugAdd 'rafamadriz/friendly-snippets'
    if index(['mcm', 'cmp'], g:complete_engine) >= 0
        PlugAdd 'hrsh7th/vim-vsnip'
        if g:complete_engine == 'mcm'
            PlugAdd 'hrsh7th/vim-vsnip-integ'
        endif
    endif
endif
" ------------------------------
" lsp && linter tool
" ------------------------------
if PlannedLsp()
    let g:linter_tool = 'lsp'
    " lsp related
    PlugAdd 'williamboman/mason-lspconfig.nvim'
    PlugAdd 'camilledejoye/nvim-lsp-selection-range'
    PlugAdd 'Wansmer/symbol-usage.nvim'
    PlugAdd 'ravenxrz/call-graph.nvim'
    PlugAdd 'neovim/nvim-lspconfig'
    PlugAdd 'mhartington/formatter.nvim'
    " lightline
    PlugAdd 'josa42/nvim-lightline-lsp'
    " lspimport is only for pyright
    PlugAdd 'leoatchina/nvim-lspimport'
    " neoconf
    if Require('neoconf')
        PlugAdd 'folke/neoconf.nvim'
    endif
elseif PlannedCoc()
    if g:python_version > 3.06 && Require('ale')
        let g:linter_tool = 'ale'
    else
        let g:linter_tool = 'coc'
    endif
elseif g:python_version > 3.06 && v:version >= 800
    let g:linter_tool = 'ale'
else
    let g:linter_tool = ''
endif
if g:linter_tool == 'ale'
    PlugAdd 'dense-analysis/ale'
    PlugAdd 'maximbaz/lightline-ale'
endif
" ------------------------------
" textobj
" ------------------------------
if has('nvim-0.9.2') && get(g:, 'nvim_treesitter_install', UNIX())
    PlugAdd 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    PlugAdd 'nvim-treesitter/nvim-treesitter-textobjects'
    PlugAdd 'nvim-treesitter/nvim-treesitter-refactor'
    PlugAdd 'nvim-treesitter/nvim-treesitter-context', {'for': ['toml', 'yaml', 'json']}
    PlugAdd 'm-demare/hlargs.nvim'
elseif exists('*search') && exists('*getpos') && g:complete_engine != 'coc'
    PlugAdd 'bps/vim-textobj-python', {'for': 'python'}
    PlugAdd 'thinca/vim-textobj-function-perl', {'for': 'perl'}
    PlugAdd 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    PlugAdd 'gcmt/wildfire.vim'
endif
" ------------------------------
" AI completion engine
" ------------------------------
if exists('$XAI_API_KEY') ||
    \  exists('$DEEPSEEK_API_KEY') ||
    \  exists('$MISTRAL_API_KEY') ||
    \  exists('$HUGGINGFACE_API_KEY')
    let g:ai_api_key = 3
elseif Require('copilot_plus') ||
    \  exists('$OPENAI_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY') ||
    \  exists('$GEMINI_API_KEY')
    let g:ai_api_key = 2
elseif get(g:, 'openai_compatible_api_key', '') !='' &&
    \  get(g:, 'openai_compatible_model', '') != '' &&
    \  get(g:, 'openai_compatible_url', '') != ''
    let g:ai_api_key = 1
else
    let g:ai_api_key = 0
endif
if has('nvim-0.9') && Require('aider') && executable('aider') && g:ai_api_key
    PlugAdd 'milanglacier/yarepl.nvim'
elseif has('nvim-0.10.1') && Planned('nvim-treesitter')
    if executable('curl') && PlannedLsp() && (g:ai_api_key == 3 || Require('codecompanion') && g:ai_api_key)
        PlugAdd 'olimorris/codecompanion.nvim'
    elseif g:ai_api_key == 1 || g:ai_api_key == 2
        if UNIX()
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'make' }
        else
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' }
        endif
    endif
    if Planned('avante.nvim') || Planned('codecompanion.nvim')
        PlugAdd 'echasnovski/mini.pick'
        PlugAdd '0xrusowsky/nvim-ctx-ingest'
    endif
endif
if has('nvim-0.10') && (
    \  exists('$OPENAI_API_KEY') ||
    \  exists('$GEMINI_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY') ||
    \  exists('$CODESTRAL_API_KEY') ||
    \  g:ai_api_key == 1
    \  )
    PlugAdd 'milanglacier/minuet-ai.nvim'
elseif has('patch-9.0.0185') || has('nvim')
    if Require('codeium')
        PlugAdd 'Exafunction/codeium.vim'
    elseif Require('copilot') && !Require('copilot_plus') && g:node_version > 18
        PlugAdd 'github/copilot.vim'
    endif
endif
" ------------------------------
" fuzzy_finder
" ------------------------------
if exists('*systemlist') && has('patch-7.4.1304')
    PlugAdd 'junegunn/fzf.vim'
    if WINDOWS()
        PlugAdd 'junegunn/fzf', {'do': 'Powershell ./install.ps1 --all', 'dir': Expand('$HOME\\AppData\\Local\\fzf')}
    else
        PlugAdd 'junegunn/fzf', {'do': './install --all', 'dir': Expand('~/.local/fzf')}
    endif
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 2 && !Require('noleaderf') && !Require('no-leaderf')
    PlugAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
endif
" ------------------------------
" debug tool
" ------------------------------
if g:python_version >= 3.1 && Require('debug') && (has('patch-8.2.4797') || has('nvim-0.8') && !PlannedLsp())
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', {'do': g:python_prog . vimspector_install}
elseif has('nvim-0.9.5') && Require('debug')
    PlugAdd 'mfussenegger/nvim-dap'
    PlugAdd 'nvim-neotest/nvim-nio'
    PlugAdd 'rcarriga/nvim-dap-ui'
    PlugAdd 'jay-babu/mason-nvim-dap.nvim'
endif
" -----------------------
" format
" -----------------------
PlugAdd 'sbdchd/neoformat'
" ----------------------------
" scheme
" ----------------------------
if !Planned('nvim-treesitter') && Require('c') && PlannedAdv()
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'sainnhe/sonokai'
    PlugAdd 'bluz71/vim-nightfly-colors'
    if has('nvim-0.8')
        PlugAdd 'folke/tokyonight.nvim'
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
    endif
endif
" ------------------------------
" backbone nvim plugins.
" ------------------------------
if has('nvim')
    PlugAdd 'dstein64/nvim-scrollview'
    PlugAdd 'wsdjeg/quickfix.nvim'
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'kevinhwang91/promise-async'
    PlugAdd 'nvim-tree/nvim-web-devicons'
    if has('nvim-0.8')
        PlugAdd 'stevearc/quicker.nvim'
        if has('nvim-0.10') && (!PlannedCoc() || PlannedCoc() && Planned('nvim-treesitter'))
            PlugAdd 'Bekaboo/dropbar.nvim'
            if UNIX()
                PlugAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
            endif
        endif
    endif
    if PlannedLsp() || Planned('nvim-dap')
                \ || Planned('avante.nvim') || Planned('codecompanion.nvim') || Planned('minuet-ai.nvim')
        PlugAdd 'MunifTanjim/nui.nvim'
        PlugAdd 'nvim-lua/plenary.nvim'
        PlugAdd 'stevearc/dressing.nvim'
    endif
    if PlannedLsp() || Planned('nvim-dap')
        PlugAdd 'williamboman/mason.nvim'
    endif
elseif v:version >= 800
    PlugAdd 'ryanoasis/vim-devicons'
endif
