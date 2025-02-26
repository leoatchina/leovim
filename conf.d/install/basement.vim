" ----------------------------
" extend Planned function
" ----------------------------
function! PlannedFzf() abort
    return Planned('fzf', 'fzf.vim')
endfunction
function! PlannedLeaderf() abort
    return Planned('leaderf')
endfunction
function! PlannedCoc() abort
    return Planned('coc.nvim', 'coc-fzf', 'friendly-snippets') && PlannedFzf()
endfunction
function! PrefFzf()
    return PlannedFzf() && (get(g:, 'prefer_fzf', UNIX()) || !PlannedLeaderf())
endfunction
function! InstalledNvimLsp() abort
    return Installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'symbol-usage.nvim',
                \ )
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
function! AdvCompEngine() abort
     return Installed('coc.nvim') || InstalledNvimLsp()
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
if Require('nocomplete')
    let g:complete_engine = ''
elseif Require('apm')
    if v:version >= 800
        let g:complete_engine = 'apm'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('mcm')
    if v:version >= 901 || UNIX()
        let g:complete_engine = 'mcm'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('coc')
    if g:node_version >= 16.18 && (has('nvim-0.8.1') || has('patch-9.0.0438'))
        let g:complete_engine = 'coc'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('cmp')
    if has('nvim-0.10.1')
        let g:complete_engine = 'cmp'
    else
        let s:smart_engine_select = 1
    endif
else
    let s:smart_engine_select = 1
endif
if get(s:, 'smart_engine_select', 0)
    if has('nvim-0.10.1')
        let g:complete_engine = 'cmp'
    elseif g:node_version >= 16.18 && has('nvim-0.8.1')
        let g:complete_engine = 'coc'
    elseif UNIX()
        let g:complete_engine = 'mcm'
    elseif v:version >= 800
        let g:complete_engine = 'apm'
    else
        let g:complete_engine = ''
    endif
endif
PlugAddOpt 'vim-dict'
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
    " lsp related
    PlugAdd 'neovim/nvim-lspconfig'
    PlugAdd 'williamboman/mason-lspconfig.nvim'
    PlugAdd 'josa42/nvim-lightline-lsp'
    PlugAdd 'camilledejoye/nvim-lsp-selection-range'
    PlugAdd 'Wansmer/symbol-usage.nvim'
    " lspimport is only for pyright
    PlugAdd 'stevanmilic/nvim-lspimport'
    " neoconf should be clearly required
    if Require('neoconf')
        PlugAdd 'folke/neoconf.nvim'
    endif
    " nvim-tree
    PlugAdd 'nvim-tree/nvim-tree.lua'
    " winbar
    PlugAdd 'fgheng/winbar.nvim'
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
if index(['', 'apm'], g:complete_engine) < 0 && exists('v:true') && exists("##TextChangedP")
    PlugAdd 'hrsh7th/vim-vsnip'
    PlugAdd 'rafamadriz/friendly-snippets'
    if g:complete_engine == 'mcm'
        PlugAdd 'hrsh7th/vim-vsnip-integ'
    endif
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
" ----------------------------
" schemes && textobj
" ----------------------------
if has('nvim-0.9.2') && get(g:, 'nvim_treesitter_install', LINUX() || MACOS())
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
if !Planned('nvim-treesitter') && Require('c') && Planned('coc.nvim') && Planned('nvim-cmp')
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'sainnhe/sonokai'
    if has('nvim-0.8.1')
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
    endif
endif
" ------------------------------
" debug tool
" ------------------------------
if g:python_version >= 3.1 && Require('debug') && (has('patch-8.2.4797') || has('nvim-0.8') && !Planned('nvim-lspconfig'))
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
    elseif Require('copilot') && g:node_version > 18
        PlugAdd 'github/copilot.vim'
    endif
endif
if has('nvim-0.10.1') && Planned('nvim-treesitter')
    if executable('curl') && Planned('nvim-cmp') && (exists('$XAI_API_KEY') || exists('$DEEPSEEK_API_KEY') || Require('codecompanion') &&
                \ exists('$OPENAI_API_KEY') ||
                \ exists('$ANTHROPIC_API_KEY') ||
                \ exists('$GEMINI_API_KEY') ||
                \ exists('g:openai_compatible_api_key') && exists('g:openai_compatible_url') && exists('g:openai_compatible_model')
                \ )
        PlugAdd 'olimorris/codecompanion.nvim'
    elseif exists('$OPENAI_API_KEY') ||
                \ exists('$ANTHROPIC_API_KEY') ||
                \ exists('$GEMINI_API_KEY') ||
                \ exists('g:openai_compatible_api_key') && exists('g:openai_compatible_url') && exists('g:openai_compatible_model')
        if UNIX()
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'make' }
        else
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' }
        endif
    endif
    PlugAdd 'HakonHarnes/img-clip.nvim'
    PlugAdd 'echasnovski/mini.pick'
endif
" ------------------------------
" pairs
" ------------------------------
if g:complete_engine == 'cmp'
    PlugAdd 'windwp/nvim-autopairs'
elseif v:version >= 800
    PlugAdd 'tmsvg/pear-tree'
elseif has('patch-7.4.849')
    PlugAdd 'jiangmiao/auto-pairs'
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
if has('nvim-0.8')
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'stevearc/quicker.nvim'
    PlugAdd 'stevearc/dressing.nvim'
endif
" ------------------------------
" Git
" ------------------------------
if executable('git') && v:version >= 800 && g:git_version >= 1.85
    PlugAdd 'tpope/vim-fugitive'
    PlugAdd 'junegunn/gv.vim'
    " NOTE: blamer.nvim installed condition
    if g:has_popup_floating && UNIX() && (!Planned('leaderf') || Planned('leaderf') && !has('nvim') && !has('patch-9.0.200'))
        PlugAdd 'APZelos/blamer.nvim'
    endif
endif
" -----------------------
" format
" -----------------------
PlugAdd 'sbdchd/neoformat'
