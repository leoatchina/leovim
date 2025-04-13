" extend Planned function
" ----------------------------
function! PlannedFzf() abort
    return Planned('fzf', 'fzf.vim')
endfunction
function! PlannedCoc() abort
    return Planned('coc.nvim')
endfunction
function! PlannedLsp() abort
    return Planned(
                \ 'nvim-lsp-selection-range',
                \ 'mason-lspconfig.nvim',
                \ 'symbol-usage.nvim',
                \ 'call-graph.nvim',
                \ )
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
                \ 'nvim-lsp-selection-range',
                \ 'mason-lspconfig.nvim',
                \ 'symbol-usage.nvim',
                \ 'call-graph.nvim'
                \ )
endfunction
function! InstalledCoc() abort
    return Installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && PlannedFzf()
endfunction
function! InstalledBlink() abort
    return Installed('blink.cmp', 'friendly-snippets')
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
                \ 'cmp-git',
                \ 'cmp-dictionary',
                \ 'cmp-async-path',
                \ 'lspkind-nvim',
                \ 'colorful-menu.nvim',
                \ 'friendly-snippets',
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
elseif Require('builtin')
    if has('nvim-0.11')
        let g:complete_engine = 'builtin'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('coc')
    if g:node_version >= 16.18 && (has('nvim-0.8') || has('patch-9.0.0438'))
        let g:complete_engine = 'coc'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('blink')
    if has('nvim-0.11') && executable('cargo')
        let g:complete_engine = 'blink'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('cmp')
    if has('nvim-0.11')
        let g:complete_engine = 'cmp'
    else
        let s:smart_engine_select = 1
    endif
else
    let s:smart_engine_select = 1
endif
if get(s:, 'smart_engine_select', 0)
    if has('nvim-0.11')
        let g:complete_engine = 'cmp'
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
    PlugAdd 'petertriho/cmp-git'
    PlugAdd 'uga-rosa/cmp-dictionary'
    PlugAdd 'fcying/cmp-async-path'
    PlugAdd 'onsails/lspkind-nvim'
    PlugAdd 'xzbdmw/colorful-menu.nvim'
elseif g:complete_engine == 'blink'
    PlugAdd 'Saghen/blink.cmp', {'do': 'cargo build --release'}
elseif g:complete_engine == 'coc'
    if get(g:, 'coc_install_release', 0)
        PlugAdd 'neoclide/coc.nvim', {'branch': 'release'}
    else
        PlugAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
    endif
    PlugAddOpt 'coc-fzf'
endif
if index(['cmp', 'blink', 'builtin'], g:complete_engine) >= 0
    " lsp related
    PlugAdd 'williamboman/mason-lspconfig.nvim'
    PlugAdd 'camilledejoye/nvim-lsp-selection-range'
    PlugAdd 'Wansmer/symbol-usage.nvim'
    PlugAdd 'ravenxrz/call-graph.nvim'
    " lightline
    PlugAdd 'josa42/nvim-lightline-lsp'
    " lspimport is only for pyright
    PlugAdd 'stevanmilic/nvim-lspimport'
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
" check tool
" ------------------------------
if PlannedLsp()
    let g:check_tool = 'lsp'
elseif PlannedCoc()
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
" ----------------------------
" schemes && textobj
" ----------------------------
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
" debug tool
" ------------------------------
if g:python_version >= 3.1 && Require('debug') && (has('patch-8.2.4797') || has('nvim-0.8') && !PlannedLsp())
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', {'do': g:python_prog . vimspector_install}
elseif has('nvim-0.9.5') && Require('debug') && Planned('nvim-lspconfig')
    PlugAdd 'nvim-neotest/nvim-nio'
    PlugAdd 'mfussenegger/nvim-dap'
    PlugAdd 'rcarriga/nvim-dap-ui'
    PlugAdd 'jay-babu/mason-nvim-dap.nvim'
endif
" ------------------------------
" AI completion engine
" ------------------------------
if has('patch-9.0.0185') || has('nvim')
    if Require('codeium')
        PlugAdd 'Exafunction/codeium.vim'
    elseif Require('copilot') && !Require('copliot_enhance') && g:node_version > 18
        PlugAdd 'github/copilot.vim'
    endif
endif
if exists('$XAI_API_KEY') || exists('$DEEPSEEK_API_KEY')
    let s:ai_api_key = 2
elseif exists('$OPENAI_API_KEY') ||
    \  exists('$GEMINI_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY') ||
    \  Require('copliot_plus') ||
    \  exists('g:openai_compatible_api_key') && exists('g:openai_compatible_url') && exists('g:openai_compatible_model')
    let s:ai_api_key = 1
else
    let s:ai_api_key = 0
endif
if has('nvim-0.10.1') && Planned('nvim-treesitter')
    if executable('curl') && PlannedLsp() && (s:ai_api_key == 2 || Require('codecompanion') && s:ai_api_key)
        PlugAdd 'olimorris/codecompanion.nvim'
    elseif s:ai_api_key == 1
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
" pairs
" ------------------------------
if PlannedLsp()
    PlugAdd 'windwp/nvim-autopairs'
elseif v:version >= 800
    PlugAdd 'tmsvg/pear-tree'
elseif has('patch-7.4.849')
    PlugAdd 'jiangmiao/auto-pairs'
endif
" -----------------------
" format
" -----------------------
PlugAdd 'sbdchd/neoformat'
" ------------------------------
" Git
" ------------------------------
if executable('git') && v:version >= 800 && g:git_version >= 1.85
    PlugAdd 'tpope/vim-fugitive'
    PlugAdd 'junegunn/gv.vim'
    " NOTE: blamer.nvim installed when without virtual text
    if g:has_popup_floating && UNIX() && (!Planned('leaderf') || Planned('leaderf') && !has('nvim') && !has('patch-9.0.200'))
        PlugAdd 'APZelos/blamer.nvim'
    endif
endif
" ----------------------------
" nvim plugins
" ----------------------------
if has('nvim')
    PlugAdd 'dstein64/nvim-scrollview'
    PlugAdd 'wsdjeg/quickfix.nvim'
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'kevinhwang91/promise-async'
    PlugAdd 'nvim-tree/nvim-web-devicons'
    if has('nvim-0.8')
        PlugAdd 'stevearc/quicker.nvim'
        PlugAdd 'lukas-reineke/indent-blankline.nvim'
        if PlannedLsp()
            PlugAdd 'stevearc/dressing.nvim'
        endif
        if PlannedAdv() && Require('neoconf')
            PlugAdd 'folke/neoconf.nvim'
        endif
        if has('nvim-0.10') && (!PlannedCoc() || PlannedCoc() && Planned('nvim-treesitter'))
            PlugAdd 'Bekaboo/dropbar.nvim'
            if UNIX()
                PlugAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
            endif
        endif
    endif
elseif has('conceal')
    PlugAdd 'Yggdroot/indentLine'
    if v:version >= 800
        PlugAdd 'ryanoasis/vim-devicons'
    endif
endif
" backbone nvim plugins.
if PlannedLsp() || Planned('nvim-dap') || Planned('avante.nvim') || Planned('codecompanion.nvim')
    PlugAdd 'MunifTanjim/nui.nvim'
    PlugAdd 'nvim-lua/plenary.nvim'
    if PlannedLsp() || Planned('nvim-dap')
        PlugAdd 'williamboman/mason.nvim'
    endif
endif
" ------------------------------
" fullscreen
" ------------------------------
if LINUX() && HAS_GUI() && executable('wmctrl')
    PlugAdd 'lambdalisue/vim-fullscreen'
    if has('nvim')
        let g:fullscreen#start_command = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)"
        let g:fullscreen#stop_command  = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)"
    endif
endif
" ----------------------------
" wilder
" ----------------------------
if !PlannedLsp()
    if g:python_version > 3 && has('nvim') && UNIX()
        function! UpdateRemotePlugins(...)
            let &rtp=&rtp
            UpdateRemotePlugins
        endfunction
        Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
    elseif !has('nvim') && v:version >= 801 || has('nvim') && !WINDOWS()
        PlugAdd 'gelguy/wilder.nvim'
    endif
endif
" ------------------------------
" marks
" ------------------------------
PlugAdd 'kshenoy/vim-signature'
" ------------------------------
" undo
" ------------------------------
if has('nvim') && UNIX()
    PlugAdd 'kevinhwang91/nvim-fundo'
endif
PlugAddOpt 'undotree'
" ------------------------------
" zfvim
" ------------------------------
if (Require('wubi') || Require('pinyin')) && g:has_terminal && UNIX()
    PlugAdd 'ZSaberLv0/ZFVimIM'
    if Require('wubi')
        PlugAdd 'ZSaberLv0/ZFVimIM_wubi_base'
        let g:input_method = 'zfvim_wubi'
    else
        let g:input_method = 'zfvim_pinyin'
    endif
    PlugAdd 'ZSaberLv0/ZFVimIM_pinyin'
endif
" ------------------------------
" translate && query
" ------------------------------
if Require('query') && v:version >= 800
    if g:python_version >= 3.06
        PlugAdd 'voldikss/vim-translator'
    endif
    if MACOS()
        PlugAdd 'rizzatti/dash.vim'
    else
        PlugAdd 'KabbAmine/zeavim.vim'
    endif
endif
