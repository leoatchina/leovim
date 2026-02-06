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
" AI complete
" ------------------------------
if has('nvim-0.10') && pack#get('minuet-ai') && (
    \  exists('$DEEPSEEK_API_KEY') ||
    \  exists('$GEMINI_API_KEY') ||
    \  exists('$OPENAI_API_KEY') ||
    \  exists('$CODESTRAL_API_KEY') ||
    \  exists('$ANTHROPIC_API_KEY') ||
    \  get(g:, 'openai_compatible_api_key', '') != '' &&
    \  get(g:, 'openai_compatible_model', '') != '' &&
    \  get(g:, 'openai_compatible_url', '') != ''
    \  )
    PlugAdd 'milanglacier/minuet-ai.nvim'
elseif has('patch-9.0.0185') || has('nvim')
    if pack#get('windsurf')
        if has('nvim')
            PlugAdd 'Exafunction/windsurf.lua'
        else
            PlugAdd 'Exafunction/windsurf.vim'
        endif
    elseif pack#get('copilot') && g:node_version > 18
        if has('nvim')
            PlugAdd 'zbirenbaum/copilot.lua'
        else
            PlugAdd 'github/copilot.vim'
        endif
    endif
endif
if has('nvim-0.10') && executable('opencode') && pack#get('opencode')
    PlugAdd 'NickvanDyke/opencode.nvim'
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
    " codesettings
    PlugAdd 'mrjones2014/codesettings.nvim'
elseif g:python_version > 3.06 && pack#get('ale')
    let g:lint_tool = 'ale'
    PlugAdd 'dense-analysis/ale'
    PlugAdd 'maximbaz/lightline-ale'
elseif pack#planned_coc()
    let g:lint_tool = 'coc'
else
    let g:lint_tool = ''
endif
" ------------------------------
" debug tool install
" ------------------------------
if g:python_version >= 3.1 && pack#get('debug') && (has('patch-8.2.4797') || has('nvim') && !pack#planned_lsp())
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PlugAdd 'puremourning/vimspector', { 'do': g:python_prog . vimspector_install }
elseif has('nvim-0.9.5') && pack#get('debug') || pack#planned_lsp() && pack#get('java')
    PlugAdd 'mfussenegger/nvim-dap'
    PlugAdd 'nvim-neotest/nvim-nio'
    PlugAdd 'rcarriga/nvim-dap-ui'
    PlugAdd 'jay-babu/mason-nvim-dap.nvim'
endif
" ------------------------------
" textobj install
" ------------------------------
if has('nvim-0.9.2') && get(g:, 'nvim_treesitter_install', utils#is_unix())
    PlugAdd 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'master'}
    PlugAdd 'nvim-treesitter/nvim-treesitter-textobjects', {'branch': 'master'}
    PlugAdd 'nvim-treesitter/nvim-treesitter-context', {'for': ['toml', 'yaml', 'json']}
    PlugAdd 'nvim-treesitter/nvim-treesitter-refactor'
    PlugAdd 'm-demare/hlargs.nvim'
elseif exists('*search') && exists('*getpos') && g:complete_engine != 'coc'
    PlugAdd 'bps/vim-textobj-python', {'for': 'python'}
    PlugAdd 'thinca/vim-textobj-function-perl', {'for': 'perl'}
    PlugAdd 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    PlugAdd 'gcmt/wildfire.vim'
endif
" -----------------------
" format install
" -----------------------
PlugAdd 'sbdchd/neoformat'
" --------------------------------
" run
" --------------------------------
if has('nvim') || has('timers') && has('channel') && has('job')
    PlugAdd 'asyncrun.vim'
    if !has("nvim")
        let g:lightline#asyncrun#indicator_none = ''
        PlugAdd 'lightline-asyncrun'
    endif
endif
if has('nvim') || v:version >= 801
    PlugAdd 'asynctasks.vim'
endif
" ------------------------------
" fuzzy finders
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
    PlugAdd 'fzf-registers'
    PlugAdd 'fzf-tabs'
    if has('nvim')
        PlugAdd 'stevearc/oil.nvim'
        PlugAdd 'benomahony/oil-git.nvim'
    endif
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 3 && !pack#get('noleaderf') && !pack#get('no-leaderf')
    PlugAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
endif
if !pack#planned_leaderf() && !pack#planned_fzf()
    source $CFG_DIR/ctrlp.vim
    PlugAdd 'ctrlp.vim'
endif
" ------------------------------
" Git
" ------------------------------
if executable('git') && v:version >= 800 && g:git_version >= 1.85
    PlugAdd 'tpope/vim-fugitive'
    PlugAdd 'junegunn/gv.vim'
    " blamer.nvim installed when without virtual text or without leaderf
    if g:has_popup_floating
        PlugAdd 'skywind3000/vim-git-diffview'
        if utils#is_unix() && (!pack#planned_leaderf() || pack#planned_leaderf() && !has('nvim') && !has('patch-9.0.200'))
            PlugAdd 'APZelos/blamer.nvim'
        endif
    endif
endif
if has('nvim') || has('patch-8.0.902')
    PlugAdd 'vim-signify'
endif
" --------------------------
" terminal && tmux
" --------------------------
if g:has_terminal
    PlugAdd 'vim-floaterm'
    PlugAdd 'vim-floaterm-enhance'
endif
if utils#is_unix() && utils#has_gui() == 0 && executable('tmux') && v:version >= 800
    PlugAdd 'vim-tmux-navigator'
    PlugAdd 'vim-tmux-clipboard'
endif
" --------------------------
" sidebar
" --------------------------
PlugAdd 'vim-sidebar-manager'
if v:version >= 801 || has('nvim')
    let g:fern_disable_startup_warnings = 1
    let g:fern#renderer = "nerdfont"
    PlugAdd 'vim-fern'
    PlugAdd 'vim-nerdfont'
    PlugAdd 'vim-glyph-palette'
    PlugAdd 'vim-fern-git-status'
    PlugAdd 'vim-fern-hijack'
    PlugAdd 'vim-fern-renderer-nerdfont'
    augroup my-glyph-palette
        autocmd!
        autocmd FileType fern,startify call glyph_palette#apply()
    augroup END
else
    PlugAdd 'vim-vinegar'
endif
" --------------------------------
" lightline
" --------------------------------
PlugAdd 'lightline.vim'
PlugAdd 'lightline-bufferline'
" ----------------------------
" scheme
" ----------------------------
if !pack#planned('nvim-treesitter') && pack#get('c') && pack#planned('advcompeng')
    PlugAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PlugAdd 'sainnhe/edge'
    PlugAdd 'sainnhe/sonokai'
    if has('nvim')
        PlugAdd 'bluz71/vim-moonfly-colors'
        PlugAdd 'folke/tokyonight.nvim'
        PlugAdd 'EdenEast/nightfox.nvim'
        PlugAdd 'catppuccin/nvim', {'as': 'catppuccin-nvim'}
    else
        PlugAdd 'bluz71/vim-nightfly-colors'
        PlugAdd 'catppuccin/vim', {'as': 'catppuccin-vim'}
    endif
endif
PlugAdd 'lightline.vim'
PlugAdd 'lightline-bufferline'
" --------------------------
" ui && frame
" --------------------------
if has('nvim')
    PlugAdd 'nvim-tree/nvim-web-devicons'
    PlugAdd 'kevinhwang91/promise-async'
    PlugAdd 'kevinhwang91/nvim-bqf'
    PlugAdd 'MunifTanjim/nui.nvim'
    PlugAdd 'nvim-lua/plenary.nvim'
    PlugAdd 'stevearc/dressing.nvim'
    if pack#planned_lsp() || has('nvim-0.11') && pack#planned('nvim-treesitter')
        PlugAdd 'Bekaboo/dropbar.nvim'
        if utils#is_unix()
            PlugAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
        endif
    endif
    if pack#planned_lsp() || pack#planned('nvim-dap')
        PlugAdd 'mason-org/mason.nvim'
    endif
elseif v:version >= 800
    PlugAdd 'ryanoasis/vim-devicons'
endif
if has('nvim-0.10')
    PlugAdd 'stevearc/quicker.nvim'
else
    PlugAdd 'romainl/vim-qf'
endif
" -------------------
" vim-preview
" -------------------
let g:preview#preview_position = "rightbottom"
let g:preview#preview_size = get(g:, 'asyncrun_open', 8)
PlugAdd 'vim-preview'
nnoremap <silent><C-w><Space> <C-w>z:call preview#cmdmsg('close preview', 0)<Cr>
" -------------------
" vim-quickui
" -------------------
if v:version >= 802 || has('nvim')
    let g:quickui_preview_h = 24
    PlugAdd 'vim-quickui'
endif
" -------------------
" startify
" -------------------
PlugAdd 'vim-startify'
" -------------------
" which-key
" -------------------
if get(g:, 'leovim_whichkey', 1)
    let g:which_key_group_dicts = ''
    let g:which_key_use_floating_win = g:has_popup_floating
    PlugAdd 'vim-which-key'
endif
" ------------------------------
" vim-header
" ------------------------------
if get(g:, 'header_field_author', '') != ''
    let g:header_auto_add_header = 0
    let g:header_auto_update_header = 0
    let g:header_field_timestamp_format = '%Y.%m.%d'
    PlugAdd 'vim-header'
    nnoremap <M-k>a :AddHeader<Cr>
endif
" --------------------------
" easyalign
" --------------------------
let g:easy_align_delimiters = {}
let g:easy_align_delimiters['#'] = {'pattern': '#', 'ignore_groups': ['String']}
let g:easy_align_delimiters['*'] = {'pattern': '*', 'ignore_groups': ['String']}
PlugAdd 'vim-easy-align'
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
xmap g, ga*,
xmap g= ga*=
xmap g: ga*:
xmap g<Space> ga*<Space>
" ----------------------------
" pairs && wiler
" ----------------------------
if pack#planned_lsp()
    PlugAdd 'windwp/nvim-autopairs'
else
    if v:version >= 800
        PlugAdd 'tmsvg/pear-tree'
    elseif has('patch-7.4.849')
        PlugAdd 'jiangmiao/auto-pairs'
    endif
    " wilder
    if g:python_version > 3 && has('nvim') && utils#is_unix()
        function! UpdateRemotePlugins(...)
            let &rtp=&rtp
            UpdateRemotePlugins
        endfunction
        Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
    elseif (!utils#is_win() || pack#get('wilder')) && (!has('nvim') && v:version >= 801 || has('nvim'))
        PlugAdd 'gelguy/wilder.nvim'
    endif
endif
" ------------------------------
" undo
" ------------------------------
if has('nvim') && utils#is_unix()
    PlugAdd 'kevinhwang91/nvim-fundo'
endif
PlugAdd 'undotree'
" ----------------------------
" indentLine plugins
" ----------------------------
if has('nvim')
    PlugAdd 'lukas-reineke/indent-blankline.nvim'
elseif has('conceal')
    PlugAdd 'Yggdroot/indentLine'
endif
" ------------------------------
" marks
" ------------------------------
PlugAdd 'kshenoy/vim-signature'
PlugAdd 'vim-bookmarks'
