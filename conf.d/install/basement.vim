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
    if UNIX()
        call AddRequire('mcm')
    endif
endtry
if Require('nocomplete')
    let g:complete_engine = ''
elseif Require('mcm')
    if v:version >= 901 || UNIX()
        let g:complete_engine = 'mcm'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('apm')
    if v:version >= 800
        let g:complete_engine = 'apm'
    else
        let s:smart_engine_select = 1
    endif
elseif Require('vcm')
    if v:version >= 901
        let g:complete_engine = 'vcm'
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
    if has('nvim-0.10')
        if UNIX() || WINDOWS() && HAS_GUI() == 0
            let g:complete_engine = 'cmp'
        else
            let s:smart_engine_select = 1
        endif
    else
        let s:smart_engine_select = 1
    endif
else
    let s:smart_engine_select = 1
endif
if get(s:, 'smart_engine_select', 0)
    if v:version >= 901
        if UNIX()
            let g:complete_engine = 'vcm'
        else
            let g:complete_engine = 'mcm'
        endif
    elseif has('nvim-0.10')
        if UNIX() || WINDOWS() && HAS_GUI() == 0
            let g:complete_engine = 'cmp'
        else
            let g:complete_engine = 'mcm'
        endif
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
" ------------------------------
" complete_engine
" ------------------------------
if g:complete_engine == 'vcm'
    PlugAdd 'girishji/vimcomplete'
elseif g:complete_engine == 'cmp'
    PlugAdd 'hrsh7th/nvim-cmp'
    PlugAdd 'hrsh7th/cmp-nvim-lsp'
    PlugAdd 'hrsh7th/cmp-nvim-lua'
    PlugAdd 'hrsh7th/cmp-buffer'
    PlugAdd 'hrsh7th/cmp-cmdline'
    PlugAdd 'hrsh7th/cmp-path'
    PlugAdd 'petertriho/cmp-git'
    PlugAdd 'hrsh7th/cmp-nvim-lsp-signature-help'
    PlugAdd 'onsails/lspkind-nvim'
    " snippet
    PlugAdd 'hrsh7th/cmp-vsnip'
    " lsp related
    PlugAdd 'folke/neoconf.nvim'
    PlugAdd 'neovim/nvim-lspconfig'
    PlugAdd 'williamboman/mason-lspconfig.nvim'
    PlugAdd 'josa42/nvim-lightline-lsp'
    PlugAdd 'camilledejoye/nvim-lsp-selection-range'
    PlugAdd 'fgheng/winbar.nvim'
    PlugAdd 'Wansmer/symbol-usage.nvim'
    PlugAdd 'stevanmilic/nvim-lspimport'
    PlugAdd 'jinzhongjia/LspUI.nvim'
elseif g:complete_engine == 'coc'
    if get(g:, 'coc_install_release', 0) == 0
        PlugAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
    else
        PlugAdd 'neoclide/coc.nvim', {'branch': 'release'}
    endif
    PlugAddOpt 'coc-fzf'
endif
" ------------------------------
" dict && snippets
" ------------------------------
PlugAddOpt 'vim-dict'
if index(['', 'apm'], g:complete_engine) < 0 && exists('v:true') && exists("##TextChangedP")
    PlugAdd 'hrsh7th/vim-vsnip'
    PlugAdd 'rafamadriz/friendly-snippets'
    if index(['vcm', 'mcm'], g:complete_engine) >= 0
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
    PlugAdd 'kevinhwang91/nvim-treesitter', {'do': ':TSUpdate'}
endif
if Planned('nvim-treesitter')
    PlugAdd 'nvim-treesitter/nvim-treesitter-textobjects'
    PlugAdd 'nvim-treesitter/nvim-treesitter-refactor'
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
    PlugAdd 'sainnhe/everforest'
    PlugAdd 'sainnhe/gruvbox-material'
    if has('nvim-0.8.1')
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'folke/tokyonight.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
    endif
endif
" ------------------------------
" debug tool
" ------------------------------
if has('nvim-0.9.5') && (Require('nvim-dap') || Require('debug') && Planned('nvim-cmp') || Require('debug') && g:python_version < 3.1)
    PlugAdd 'mfussenegger/nvim-dap'
    PlugAdd 'rcarriga/nvim-dap-ui'
    PlugAdd 'jay-babu/mason-nvim-dap.nvim'
    if Planned('nvim-treesitter')
        PlugAdd 'theHamsta/nvim-dap-virtual-text'
    endif
elseif g:python_version >= 3.1 && Require('debug') && (has('patch-8.2.4797') || has('nvim-0.8'))
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', {'do': g:python_exe . vimspector_install}
endif
if has('nvim') && Require('jupynium') && g:python_version > 3.07
    PlugAdd 'kiyoon/jupynium.nvim', {'do': get(g:, 'jupynium_install', 'pip3 install --user .')}
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
if has('nvim') || has('patch-7.4.1126')
    if g:python_version > 2 && !Require('noleaderf') && !Require('no-leaderf')
        PlugAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
    endif
endif
if has('nvim')
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'stevearc/quicker.nvim'
    PlugAdd 'stevearc/dressing.nvim'
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
" ------------------------------
" format tools
" ------------------------------
PlugAdd 'sbdchd/neoformat'
" ------------------------------
" Git
" ------------------------------
if executable('git') && v:version >= 800 && g:git_version >= 1.85
    PlugAdd 'tpope/vim-fugitive'
    PlugAdd 'junegunn/gv.vim'
    if g:has_popup_floating && UNIX() && (!Planned('leaderf') || !has('nvim') && !has('patch-9.0.200'))
        PlugAdd 'APZelos/blamer.nvim'
    endif
endif
" ------------------------------
" AI completion engine
" ------------------------------
if has('patch-9.0.0185') || has('nvim')
    if Require('codeium')
        PlugAdd 'Exafunction/codeium.vim'
    elseif Require('copilot') && g:node_version > 18
        if has('nvim-0.9.5')
            if g:complete_engine == 'cmp' && has('nvim-0.10.1')
                PlugAdd 'zbirenbaum/copilot-cmp'
            endif
            PlugAdd 'zbirenbaum/copilot.lua'
            PlugAdd 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
        else
            PlugAdd 'github/copilot.vim'
        endif
    endif
endif
if has('nvim-0.10') && Planned('nvim-treesitter') && (exists('$ANTHROPIC_API_KEY') || exists('$OPENAI_API_KEY') || Planned('copilot.lua'))
    if executable('cargo')
        if UNIX()
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'make BUILD_FROM_SOURCE=true' }
        else
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource true' }
        endif
    else
        if UNIX()
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'make' }
        else
            PlugAdd 'yetone/avante.nvim', { 'branch': 'main', 'do': 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' }
        endif
    endif
endif
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
function! InstalledNvimLsp() abort
    return Installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'symbol-usage.nvim',
                \ 'nvim-lspimport',
                \ 'lspui.nvim',
                \ 'neoconf.nvim',
                \ 'winbar.nvim',
                \ )
endfunction
function! InstalledCmp() abort
    return Installed(
                \ 'nvim-cmp',
                \ 'cmp-buffer',
                \ 'cmp-cmdline',
                \ 'cmp-nvim-lsp',
                \ 'cmp-nvim-lua',
                \ 'cmp-path',
                \ 'cmp-git',
                \ 'cmp-nvim-lsp-signature-help',
                \ 'cmp-vsnip',
                \ 'friendly-snippets',
                \ 'lspkind-nvim',
                \ )
endfunction
function! AdvCompEngine() abort
    return PlannedCoc() || Planned('nvim-cmp')
endfunction
function! PrefFzf()
    return PlannedFzf() && (get(g:, 'prefer_fzf', UNIX()) || !PlannedLeaderf())
endfunction
