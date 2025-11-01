" --------------------------
" complete options
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
" 补全选项设置 - 基于版本精确判断
if has('patch-7.4.775')
    set completeopt+=noselect
endif
if has('patch-7.4.784')
    set completeopt+=noinsert
endif
if has('nvim-0.11')
    set completeopt+=fuzzy
endif
" Vim 8.1.1880+ 的 popup 补全窗口（需要 textprop 支持，Neovim 使用浮动窗口）
if !has('nvim') && has('patch-8.1.1880') && has('textprop') && exists('+completepopup')
    set completeopt+=popup
    set completepopup=align:menu,border:off,highlight:WildMenu
endif
" 补全菜单大小设置
set pumheight=20
if exists('+pumwidth')
    set pumwidth=50
endif
" 如果补全功能不够完善，在Unix下使用mcm作为备选
if !has('patch-7.4.775') && UNIX()
    call AddRequire('mcm')
endif
" ------------------------------
" complete_engine select
" ------------------------------
if Require('nocomplete') || Require('noc')
    let g:complete_engine = ''
elseif Require('mcm')
    let g:complete_engine = 'mcm'
elseif Require('builtin') && (has('nvim-0.11') || has('patch-9.1.1590'))
    let g:complete_engine = 'builtin'
elseif Require('coc')
    if g:node_version >= 16.18 && (has('nvim') || has('patch-9.0.0438'))
        let g:complete_engine = 'coc'
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
        call AddRequire('builtin')
        let g:complete_engine = 'builtin'
    else
        let g:complete_engine = 'mcm'
    endif
endif
" ------------------------------
" complete_engine install
" ------------------------------
if g:complete_engine == 'cmp'
    PlugAdd 'hrsh7th/nvim-cmp'
    PlugAdd 'hrsh7th/cmp-nvim-lsp'
    PlugAdd 'hrsh7th/cmp-nvim-lua'
    PlugAdd 'hrsh7th/cmp-buffer'
    PlugAdd 'hrsh7th/cmp-cmdline'
    PlugAdd 'hrsh7th/cmp-vsnip'
    PlugAdd 'hrsh7th/cmp-nvim-lsp-signature-help'
    PlugAdd 'FelipeLema/cmp-async-path'
    PlugAdd 'onsails/lspkind-nvim'
    PlugAdd 'xzbdmw/colorful-menu.nvim'
elseif g:complete_engine == 'blink'
    if executable('cargo') && !Require('blink.lua')
        PlugAdd 'Saghen/blink.cmp', {'do': 'cargo build --release'}
    else
        PlugAdd 'Saghen/blink.cmp'
    endif
elseif g:complete_engine == 'coc'
    if get(g:, 'coc_install_release', 0)
        PlugAdd 'neoclide/coc.nvim', {'branch': 'release'}
    else
        PlugAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
    endif
    PlugAddOpt 'coc-fzf'
endif
" ------------------------------
" snippets install
" ------------------------------
if g:complete_engine != '' && exists('v:true') && exists("##TextChangedP")
    PlugAdd 'rafamadriz/friendly-snippets'
    PlugAdd 'hrsh7th/vim-vsnip'
    if g:complete_engine == 'mcm'
        PlugAdd 'hrsh7th/vim-vsnip-integ'
    endif
endif
" ------------------------------
" textobj install
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
" AI engine install
" ------------------------------
if Require('copilot_plus') ||
    \  exists('$GEMINI_API_KEY') ||
    \  exists('$XAI_API_KEY') ||
    \  exists('$DEEPSEEK_API_KEY') ||
    \  exists('$MISTRAL_API_KEY') ||
    \  exists('$HUGGINGFACE_API_KEY') ||
    \  exists('$OPENAI_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY')
    let g:ai_api_key = 2
elseif get(g:, 'openai_compatible_api_key', '') != '' &&
    \  get(g:, 'openai_compatible_model', '') != '' &&
    \  get(g:, 'openai_compatible_url', '') != ''
    let g:ai_api_key = 1
else
    let g:ai_api_key = 0
endif
if g:ai_api_key > 0 && Planned('nvim-treesitter') && executable('curl') && PlannedLsp() && Require('codecompanion')
    PlugAdd 'olimorris/codecompanion.nvim'
    PlugAdd 'ravitemer/codecompanion-history.nvim'
    PlugAdd 'franco-ruggeri/codecompanion-spinner.nvim'
    PlugAdd 'ravitemer/mcphub.nvim'
    if executable('vectorcode')
        PlugAdd 'Davidyz/VectorCode'
    endif
endif
" AI complete
if has('nvim-0.10') && Require('minuet-ai') && (
    \  exists('$GEMINI_API_KEY') ||
    \  exists('$DEEPSEEK_API_KEY') ||
    \  exists('$OPENAI_API_KEY') ||
    \  exists('$CODESTRAL_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY') ||
    \  g:ai_api_key == 1
    \  )
    PlugAdd 'milanglacier/minuet-ai.nvim'
elseif has('patch-9.0.0185') || has('nvim')
    if Require('codeium')
        PlugAdd 'Exafunction/windsurf.vim'
    elseif Require('copilot') && !Require('copilot_plus') && g:node_version > 18
        PlugAdd 'github/copilot.vim'
    endif
endif
" ------------------------------
" lsp && linter tool install
" ------------------------------
if PlannedLsp()
    let g:lint_tool = 'lsp'
    " lsp related
    PlugAdd 'mason-org/mason-lspconfig.nvim'
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
        let g:lint_tool = 'ale'
        PlugAdd 'dense-analysis/ale'
        PlugAdd 'maximbaz/lightline-ale'
    else
        let g:lint_tool = 'coc'
    endif
else
    let g:lint_tool = ''
endif
" ------------------------------
" debug tool install
" ------------------------------
if g:python_version >= 3.1 && Require('debug') && (has('patch-8.2.4797') || has('nvim') && !PlannedLsp())
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', {'do': g:python_prog . vimspector_install}
elseif has('nvim-0.9.5') && Require('debug') || PlannedLsp() && Require('java')
    PlugAdd 'mfussenegger/nvim-dap'
    PlugAdd 'nvim-neotest/nvim-nio'
    PlugAdd 'rcarriga/nvim-dap-ui'
    PlugAdd 'jay-babu/mason-nvim-dap.nvim'
endif
" -----------------------
" format install
" -----------------------
PlugAdd 'sbdchd/neoformat'
" ----------------------------
" scheme
" ----------------------------
if !Planned('nvim-treesitter') && Require('c') && PlannedAdvCompEng()
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'sainnhe/sonokai'
    PlugAdd 'leoatchina/gruvbox-material'
    PlugAdd 'bluz71/vim-nightfly-colors'
    if has('nvim')
        PlugAdd 'folke/tokyonight.nvim'
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
    endif
endif
" ------------------------------
" backbone plugins.
" ------------------------------
if exists('*systemlist') && (has('patch-7.4.1304') || has('nvim'))
    PlugAdd 'junegunn/fzf.vim'
    if WINDOWS()
        PlugAdd 'junegunn/fzf', {'do': 'Powershell ./install.ps1 --all', 'dir': Expand('$HOME\\AppData\\Local\\fzf')}
    else
        if Require('fzfbin')
            PlugAdd 'junegunn/fzf', {'do': './install --bin', 'dir': Expand('~/.local/fzf')}
        else
            PlugAdd 'junegunn/fzf', {'do': './install --all', 'dir': Expand('~/.local/fzf')}
        endif
    endif
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 2 && !Require('noleaderf') && !Require('no-leaderf')
    PlugAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
endif
if has('nvim')
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'kevinhwang91/promise-async'
    PlugAdd 'nvim-tree/nvim-web-devicons'
    if has('nvim')
        PlugAdd 'stevearc/quicker.nvim'
    endif
    if PlannedLsp() || has('nvim-0.10') && Planned('nvim-treesitter')
        PlugAdd 'Bekaboo/dropbar.nvim'
        if UNIX()
            PlugAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
        endif
    endif
    if PlannedLsp() || Planned('nvim-dap')
        PlugAdd 'mason-org/mason.nvim'
    endif
    if PlannedLsp() || Planned('nvim-dap') || Planned('codecompanion.nvim') || Planned('minuet-ai.nvim')
        PlugAdd 'MunifTanjim/nui.nvim'
        PlugAdd 'nvim-lua/plenary.nvim'
        PlugAdd 'stevearc/dressing.nvim'
    endif
elseif v:version >= 800
    PlugAdd 'ryanoasis/vim-devicons'
endif
