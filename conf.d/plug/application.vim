" ------------------------------
" snippets install
" ------------------------------
if !pack#get('nocomplete') && exists('v:true') && exists("##TextChangedP")
    PackAdd 'rafamadriz/friendly-snippets'
    " blink/cmp 都以 vsnip 为 snippet 引擎
    PackAdd 'hrsh7th/vim-vsnip'
endif
if pack#planned_cmp()
    PackAdd 'hrsh7th/nvim-cmp', {'lua': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-nvim-lsp', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-nvim-lua', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-buffer', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-cmdline', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-vsnip', {'deps': ['vim-vsnip', 'nvim-cmp'], 'lua': 'cfg.cmp'}
    PackAdd 'FelipeLema/cmp-async-path', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
    PackAdd 'onsails/lspkind-nvim', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
    PackAdd 'xzbdmw/colorful-menu.nvim', {'deps': 'nvim-cmp', 'lua': 'cfg.cmp'}
elseif pack#planned_blink()
    PackAdd 'Saghen/blink.lib'
    PackAdd 'Mestane/blink-cmp-deps'
    PackAdd 'Saghen/blink.cmp', {'branch': 'main', 'deps': ['blink.lib', 'friendly-snippets', 'blink-cmp-deps'], 'lua': 'cfg.blink'}
elseif pack#planned_coc()
    if get(g:, 'coc_install_release', 0)
        PackAdd 'neoclide/coc.nvim', {'branch': 'release', 'dir': utils#expand("~/.leovim.d/coc/release"), 'vim': 'coc'}
    else
        PackAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci', 'dir': utils#expand("~/.leovim.d/coc/master"), 'vim': 'coc'}
    endif
    PackAdd 'coc-fzf', {'deps': 'coc.nvim', 'vim': 'coc'}
endif
" ------------------------------
" lsp && linter tool install
" ------------------------------
if pack#planned_lsp()
    let g:lint_tool = 'lsp'
    " lsp related
    PackAdd 'mason-org/mason.nvim', {'lua': 'cfg.mason'}
    PackAdd 'neovim/nvim-lspconfig', {'lua': 'lsp', 'vim': 'lsp'}
    PackAdd 'mason-org/mason-lspconfig.nvim', {'deps': ['mason.nvim', 'nvim-lspconfig'], 'lua': 'lsp'}
    PackAdd 'ravenxrz/call-graph.nvim', {'deps': 'nvim-lspconfig', 'lua': 'lsp'}
    " lightline
    PackAdd 'josa42/nvim-lightline-lsp', {'deps': 'nvim-lspconfig', 'lua': 'lsp'}
    " lspimport is only for pyright
    PackAdd 'leoatchina/nvim-lspimport', {'deps': 'nvim-lspconfig', 'lua': 'lsp'}
    " codesettings
    PackAdd 'mrjones2014/codesettings.nvim', {'lua': 'cfg.codesettings'}
    " nvim-tree
    PackAdd 'nvim-tree/nvim-tree.lua', {'lua': 'cfg.nvimtree'}
elseif g:python_version > 3.06 && pack#get('ale')
    let g:lint_tool = 'ale'
    PackAdd 'dense-analysis/ale', {'vim': 'ale'}
    PackAdd 'maximbaz/lightline-ale'
elseif pack#planned_coc()
    let g:lint_tool = 'coc'
else
    let g:lint_tool = ''
endif
" ------------------------------
" debug tool install
" ------------------------------
" Python versions use two digits per component: 3.10.0 -> 3.1000.
" Vimspector requires Python 3.10+, Vim 8.2.4797+ or Neovim.
if pack#get('debug') && g:python_version >= 3.10
            \ && ((!has('nvim') && has('patch-8.2.4797'))
            \ || (has('nvim') && !pack#planned_lsp()))
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PackAdd 'puremourning/vimspector', { 'do': g:python_prog . vimspector_install, 'vim': 'vimspector' }
elseif has('nvim') && pack#get('debug') || pack#planned_lsp() && pack#get('java')
    if !pack#planned_lsp()
        PackAdd 'mason-org/mason.nvim', {'lua': 'cfg.mason'}
    endif
    PackAdd 'mfussenegger/nvim-dap', {'lua': 'cfg.dap', 'vim': 'dap'}
    PackAdd 'nvim-neotest/nvim-nio'
    PackAdd 'rcarriga/nvim-dap-ui', {'deps': ['nvim-dap', 'nvim-nio'], 'lua': 'cfg.dap'}
    PackAdd 'jay-babu/mason-nvim-dap.nvim', {'deps': ['nvim-dap', 'mason.nvim'], 'lua': 'cfg.dap'}
endif
" ------------------------------
" textobj install
" ------------------------------
if has('nvim') && get(g:, 'nvim_treesitter_install', utils#is_unix()) && executable('tree-sitter') && executable('curl') && executable('tar')
    PackAdd 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'main', 'lua': 'treesitter'}
    PackAdd 'nvim-treesitter/nvim-treesitter-context', {'for': ['toml', 'yaml', 'json'], 'lua': 'treesitter'}
    PackAdd 'nvim-treesitter/nvim-treesitter-textobjects', {'branch': 'main', 'deps': 'nvim-treesitter', 'lua': 'treesitter'}
    PackAdd 'm-demare/hlargs.nvim', {'deps': 'nvim-treesitter', 'lua': 'treesitter'}
elseif exists('*search') && exists('*getpos')
    if !pack#planned_coc()
        PackAdd 'bps/vim-textobj-python', {'for': 'python'}
        PackAdd 'thinca/vim-textobj-function-perl', {'for': 'perl'}
        PackAdd 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    endif
    if v:version >= 800
        PackAdd 'gcmt/wildfire.vim'
    endif
endif
" -----------------------
" format install
" -----------------------
PackAdd 'sbdchd/neoformat', {'on': 'Neoformat'}
if pack#planned_lsp()
    PackAdd 'stevearc/conform.nvim', {'lua': 'lsp'}
endif
" --------------------------------
" run
" --------------------------------
if has('nvim') || has('timers') && has('channel') && has('job')
    PackAdd 'asyncrun.vim'
    if !has("nvim")
        let g:lightline#asyncrun#indicator_none = ''
        PackAdd 'lightline-asyncrun'
    endif
endif
if has('nvim') || v:version >= 801
    PackAdd 'asynctasks.vim', {'vim': 'asynctasks'}
endif
" ------------------------------
" fuzzy finders
" ------------------------------
if exists('*systemlist') && (has('patch-7.4.1304') || has('nvim'))
    PackAdd 'junegunn/fzf.vim', {'deps': 'fzf', 'vim': 'fzf'}
    if utils#is_win()
        PackAdd 'junegunn/fzf', {'do': 'Powershell ./install.ps1 --all', 'dir': utils#expand('$HOME\\.local\\fzf'), 'vim': 'fzf'}
    else
        PackAdd 'junegunn/fzf', {'do': './install --all', 'dir': utils#expand('~/.local/fzf'), 'vim': 'fzf'}
    endif
    PackAdd 'fzf-registers', {'deps': 'fzf.vim'}
    PackAdd 'fzf-tabs', {'deps': 'fzf.vim'}
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 3 && !pack#get('noleaderf') && !pack#get('no-leaderf')
    PackAdd 'Yggdroot/LeaderF', {'vim': 'leaderf', 'do': ':LeaderfInstallCExtension'}
endif
" Git
" ------------------------------
if executable('git')
    if v:version >= 800
        PackAdd 'tpope/vim-fugitive'
        PackAdd 'junegunn/gv.vim', {'on': 'GV'}
    endif
    if has('nvim')
        if git#version_at_least(2, 31, 0)
            PackAdd 'dlyongemallo/diffview-plus.nvim'
        endif
        PackAdd 'lewis6991/gitsigns.nvim', {'lua': 'cfg.gitsigns'}
    elseif has('patch-8.0.902')
        PackAdd 'vim-signify'
    endif
    if g:has_popup_floating
        PackAdd 'skywind3000/vim-git-diffview'
    endif
endif
" --------------------------
" terminal && tmux
" --------------------------
if g:has_terminal
    PackAdd 'vim-floaterm', {'on': '^Floaterm.*$', 'vim': 'floaterm'}
    PackAdd 'vim-floaterm-enhance', {'on': '^Floaterm.*$'}
endif
if v:version >= 800 && utils#has_gui() == 0
    if utils#is_unix() && $TMUX != ''
        PackAdd 'vim-tmux-navigator'
        PackAdd 'vim-tmux-clipboard'
    elseif $HERDR_PANE_ID != ''
        PackAdd 'vim-herdr-navigation'
    endif
endif
" --------------------------
" sidebar
" --------------------------
PackAdd 'vim-sidebar-manager'
if v:version >= 801 || has('nvim')
    let g:fern_disable_startup_warnings = 1
    let g:fern#renderer = "nerdfont"
    PackAdd 'vim-fern', {'vim': 'fern'}
    PackAdd 'vim-nerdfont'
    PackAdd 'vim-glyph-palette'
    PackAdd 'vim-fern-git-status', {'deps': 'vim-fern'}
    PackAdd 'vim-fern-hijack', {'deps': 'vim-fern'}
    PackAdd 'vim-fern-renderer-nerdfont', {'deps': 'vim-fern'}
    PackAdd 'fern-mapping-fzf.vim', {'deps': 'vim-fern'}
    PackAdd 'fern-preview.vim', {'deps': 'vim-fern'}
else
    PackAdd 'vim-vinegar'
endif
" --------------------------------
" lightline
" --------------------------------
PackAdd 'lightline.vim', {'vim': 'lightline'}
PackAdd 'lightline-bufferline'
if g:has_truecolor
    PackAdd 'sainnhe/sonokai'
    if has('nvim')
        PackAdd 'EdenEast/nightfox.nvim'
        PackAdd 'folke/tokyonight.nvim'
        PackAdd 'craftzdog/solarized-osaka.nvim'
    else
        PackAdd 'catppuccin/vim', {'as': 'catppuccin-vim'}
        PackAdd 'bluz71/vim-moonfly-colors'
        PackAdd 'bluz71/vim-nightfly-colors'
    endif
endif
" --------------------------
" ui && frame
" --------------------------
if has('nvim')
    PackAdd 'nvim-tree/nvim-web-devicons', {'init': "require('nvim-web-devicons').setup({})"}
    PackAdd 'kevinhwang91/promise-async'
    PackAdd 'kevinhwang91/nvim-bqf', {'for': 'qf'}
    PackAdd 'MunifTanjim/nui.nvim'
    PackAdd 'nvim-lua/plenary.nvim'
    PackAdd 'snacks.nvim', {'lua': 'cfg.snacks'}
    PackAdd 'Bekaboo/dropbar.nvim', {'lua': 'cfg.dropbar'}
elseif v:version >= 800
    PackAdd 'ryanoasis/vim-devicons'
    if has('vim9script') && has('popupwin')
        PackAdd 'fuzzbox.vim', {'vim': 'fuzzbox'}
    endif
endif
" -------------------
" vim-preview
" -------------------
let g:preview#preview_position = "rightbottom"
let g:preview#preview_size = get(g:, 'asyncrun_open', 8)
PackAdd 'vim-preview'
nnoremap <silent><C-w><Space> <C-w>z:call preview#cmdmsg('close preview', 0)<Cr>
" -------------------
" vim-quickui
" -------------------
if v:version >= 802 || has('nvim')
    let g:quickui_preview_h = 24
    PackAdd 'vim-quickui', {'vim': 'quickui'}
endif
" -------------------
" which-key
" -------------------
if get(g:, 'leovim_whichkey', 1)
    let g:which_key_group_dicts = ''
    let g:which_key_fallback_to_native_key = 0
    let g:which_key_run_map_on_popup = 0
    let g:which_key_use_floating_win = g:has_popup_floating
    PackAdd 'vim-which-key'
endif
" ------------------------------
" vim-header
" ------------------------------
if get(g:, 'header_field_author', '') != ''
    let g:header_auto_add_header = 0
    let g:header_auto_update_header = 0
    let g:header_field_timestamp_format = '%Y.%m.%d'
    PackAdd 'vim-header', {'on': '^Add.*$'}
    nnoremap <M-k>a :AddHeader<Cr>
endif
" ----------------------------
" pairs && wiler
" ----------------------------
if pack#planned_lsp()
    PackAdd 'windwp/nvim-autopairs', {'lua': 'lsp'}
else
    if v:version >= 800
        if !pack#planned_coc()
            PackAdd 'tmsvg/pear-tree'
        endif
    elseif has('patch-7.4.849')
        PackAdd 'jiangmiao/auto-pairs'
    endif
    " wilder
    if g:python_version > 3 && has('nvim') && utils#is_unix()
        function! UpdateRemotePlugins(...)
            let &rtp=&rtp
            UpdateRemotePlugins
        endfunction
        PackAdd 'gelguy/wilder.nvim', {'do': function('UpdateRemotePlugins')}
    elseif (!utils#is_win() || pack#get('wilder')) && (!has('nvim') && v:version >= 801 || has('nvim'))
        PackAdd 'gelguy/wilder.nvim'
    endif
endif
" ------------------------------
" undo
" ------------------------------
if has('nvim') && utils#is_unix()
    PackAdd 'kevinhwang91/nvim-fundo', {'init': "require('fundo').setup()"}
endif
PackAdd 'mbbill/undotree'
" ----------------------------
" indentLine plugins
" ----------------------------
if !has('nvim') && has('conceal')
    PackAdd 'Yggdroot/indentLine'
endif
" ------------------------------
" marks
" ------------------------------
PackAdd 'kshenoy/vim-signature'
PackAdd 'vim-bookmarks'
" -------------------
" startify
" -------------------
PackAdd 'vim-startify', {'vim': 'startify'}
" -------------------
" quickfix
" -------------------
PackAdd 'romainl/vim-qf'
