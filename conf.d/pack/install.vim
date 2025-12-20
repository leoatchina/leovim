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
" completion options settings - based on precise version judgment
if has('patch-7.4.775')
    set completeopt+=noselect
endif
if has('patch-7.4.784')
    set completeopt+=noinsert
endif
if has('nvim-0.11')
    set completeopt+=fuzzy
endif
" Vim 8.1.1880+ popup completion window (requires textprop support, Neovim uses floating window)
if !has('nvim') && has('patch-8.1.1880') && has('textprop') && exists('+completepopup')
    set completeopt+=popup
    set completepopup=align:menu,border:off,highlight:WildMenu
endif
" completion menu size settings
set pumheight=20
if exists('+pumwidth')
    set pumwidth=50
endif
" If completion function is not perfect enough, use mcm as alternative on Unix
if !has('patch-7.4.775') && utils#is_unix()
    call pack#add('mcm')
endif
" ------------------------------
" complete_engine select
" ------------------------------
if pack#get('nocomplete') || pack#get('noc')
    let g:complete_engine = ''
elseif pack#get('mcm')
    let g:complete_engine = 'mcm'
elseif pack#get('builtin') && (has('nvim-0.11') || has('patch-9.1.1590'))
    let g:complete_engine = 'builtin'
elseif pack#get('coc')
    if g:node_version >= 16.18 && (has('nvim') || has('patch-9.0.0438'))
        let g:complete_engine = 'coc'
    else
        let s:smart_engine_select = 1
    endif
elseif pack#get('cmp')
    if has('nvim-0.11')
        let g:complete_engine = 'cmp'
    else
        let s:smart_engine_select = 1
    endif
elseif pack#get('blink') || pack#get('blink.lua')
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
        call pack#add('builtin')
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
    if executable('cargo') && !pack#get('blink.lua')
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
    PlugAdd 'coc-fzf'
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
if has('nvim-0.9.2') && get(g:, 'nvim_treesitter_install', utils#is_unix())
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'master'}
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
if pack#get('copilot_plus') ||
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
if g:ai_api_key > 0 && pack#planned('nvim-treesitter') && executable('curl') && pack#planned_lsp() && pack#get('codecompanion')
    PlugAdd 'olimorris/codecompanion.nvim'
    PlugAdd 'ravitemer/codecompanion-history.nvim'
    PlugAdd 'franco-ruggeri/codecompanion-spinner.nvim'
    PlugAdd 'ravitemer/mcphub.nvim'
    if executable('vectorcode')
        PlugAdd 'Davidyz/VectorCode'
    endif
endif
" AI complete
if has('nvim-0.10') && pack#get('minuet-ai') && (
    \  exists('$GEMINI_API_KEY') ||
    \  exists('$DEEPSEEK_API_KEY') ||
    \  exists('$OPENAI_API_KEY') ||
    \  exists('$CODESTRAL_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY') ||
    \  g:ai_api_key == 1
    \  )
    PlugAdd 'milanglacier/minuet-ai.nvim'
elseif has('patch-9.0.0185') || has('nvim')
    if pack#get('codeium')
        PlugAdd 'Exafunction/windsurf.vim'
    elseif pack#get('copilot') && !pack#get('copilot_plus') && g:node_version > 18
        PlugAdd 'github/copilot.vim'
    endif
endif
" ------------------------------
" lsp && linter tool install
" ------------------------------
if pack#planned_lsp()
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
    if pack#get('neoconf')
        PlugAdd 'folke/neoconf.nvim'
    endif
elseif pack#planned_coc()
    if g:python_version > 3.06 && pack#get('ale')
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
if g:python_version >= 3.1 && pack#get('debug') && (has('patch-8.2.4797') || has('nvim') && !pack#planned_lsp())
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', {'do': g:python_prog . vimspector_install}
elseif has('nvim-0.9.5') && pack#get('debug') || pack#planned_lsp() && pack#get('java')
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
if !pack#planned('nvim-treesitter') && pack#get('c') && pack#planned('advcompeng')
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'leoatchina/gruvbox-material'
    if has('nvim')
        PlugAdd 'folke/tokyonight.nvim'
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin'}
    else
        PlugAdd 'sainnhe/sonokai'
        PlugAdd 'bluz71/vim-nightfly-colors'
    endif
endif
PlugAdd 'lightline.vim'
PlugAdd 'lightline-bufferline'
" ------------------------------
" backbone plugins.
" ------------------------------
if exists('*systemlist') && (has('patch-7.4.1304') || has('nvim'))
    PlugAdd 'junegunn/fzf.vim'
    if utils#is_win()
        PlugAdd 'junegunn/fzf', {'do': 'Powershell ./install.ps1 --all', 'dir': utils#expand('$HOME\\AppData\\Local\\fzf')}
    else
        if pack#get('fzfbin')
            PlugAdd 'junegunn/fzf', {'do': './install --bin', 'dir': utils#expand('~/.local/fzf')}
        else
            PlugAdd 'junegunn/fzf', {'do': './install --all', 'dir': utils#expand('~/.local/fzf')}
        endif
    endif
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 2 && !pack#get('noleaderf') && !pack#get('no-leaderf')
    PlugAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
endif
if has('nvim')
    PlugAdd 'nvim-tree/nvim-web-devicons'
    PlugAdd 'kevinhwang91/promise-async'
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'stevearc/oil.nvim'
    PlugAdd 'benomahony/oil-git.nvim'
    if pack#planned_lsp() || has('nvim-0.10') && pack#planned('nvim-treesitter')
        PlugAdd 'Bekaboo/dropbar.nvim'
        if utils#is_unix()
            PlugAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
        endif
    endif
    if pack#planned_lsp() || pack#planned('nvim-dap')
        PlugAdd 'mason-org/mason.nvim'
    endif
    if pack#planned_lsp() || pack#planned('nvim-dap') || pack#planned('codecompanion.nvim') || pack#planned('minuet-ai.nvim')
        PlugAdd 'MunifTanjim/nui.nvim'
        PlugAdd 'nvim-lua/plenary.nvim'
        PlugAdd 'stevearc/dressing.nvim'
    endif
elseif v:version >= 800
    PlugAdd 'ryanoasis/vim-devicons'
endif
if has('nvim-0.10')
    PlugAdd 'stevearc/quicker.nvim'
else
    PlugAdd 'romainl/vim-qf'
endif
PlugAdd 'vim-startify'
