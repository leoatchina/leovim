" ------------------------------
" snippets install
" ------------------------------
if !pack#get('nocomplete') && exists('v:true') && exists("##TextChangedP")
    PackAdd 'rafamadriz/friendly-snippets'
    PackAdd 'hrsh7th/vim-vsnip'
endif
if pack#planned_cmp()
    PackAdd 'hrsh7th/nvim-cmp', {'cfg': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-nvim-lsp', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-nvim-lua', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-buffer', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-cmdline', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-vsnip', {'deps': ['vim-vsnip', 'nvim-cmp'], 'cfg': 'cfg.cmp'}
    PackAdd 'hrsh7th/cmp-nvim-lsp-signature-help', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'FelipeLema/cmp-async-path', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'onsails/lspkind-nvim', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
    PackAdd 'xzbdmw/colorful-menu.nvim', {'deps': 'nvim-cmp', 'cfg': 'cfg.cmp'}
elseif pack#planned_blink()
    if executable('cargo') && !pack#get('blink.lua')
        PackAdd 'Saghen/blink.cmp', {'do': 'cargo build --release', 'branch': 'v1', 'cfg': 'cfg.blink'}
    else
        PackAdd 'Saghen/blink.cmp', {'branch': 'v1', 'cfg': 'cfg.blink'}
    endif
elseif pack#planned_coc()
    if get(g:, 'coc_install_release', 0)
        PackAdd 'neoclide/coc.nvim', {'branch': 'release', 'dir': utils#expand("~/.leovim.d/coc/release")}
    else
        PackAdd 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci', 'dir': utils#expand("~/.leovim.d/coc/master")}
    endif
    PackAdd 'coc-fzf'
endif
" ------------------------------
" lsp && linter tool install
" ------------------------------
if pack#planned_lsp()
    PackAdd 'mason-org/mason.nvim', {'cfg': 'cfg.mason'}
    let g:lint_tool = 'lsp'
    " lsp related
    PackAdd 'neovim/nvim-lspconfig', {'cfg': 'lsp'}
    PackAdd 'mason-org/mason-lspconfig.nvim', {'deps': ['mason.nvim', 'nvim-lspconfig'], 'cfg': 'lsp'}
    PackAdd 'camilledejoye/nvim-lsp-selection-range', {'deps': 'nvim-lspconfig', 'cfg': 'lsp'}
    PackAdd 'ravenxrz/call-graph.nvim', {'deps': 'nvim-lspconfig', 'cfg': 'lsp'}
    " lightline
    PackAdd 'josa42/nvim-lightline-lsp', {'deps': 'nvim-lspconfig', 'cfg': 'lsp'}
    " lspimport is only for pyright
    PackAdd 'leoatchina/nvim-lspimport', {'deps': 'nvim-lspconfig', 'cfg': 'lsp'}
    " codesettings
    PackAdd 'mrjones2014/codesettings.nvim', {'cfg': 'cfg.codesettings'}
elseif g:python_version > 3.06 && pack#get('ale')
    let g:lint_tool = 'ale'
    PackAdd 'dense-analysis/ale'
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
    PackAdd 'puremourning/vimspector', { 'do': g:python_prog . vimspector_install }
elseif has('nvim') && pack#get('debug') || pack#planned_lsp() && pack#get('java')
    if !pack#planned_lsp()
        PackAdd 'mason-org/mason.nvim', {'cfg': 'cfg.mason'}
    endif
    PackAdd 'mfussenegger/nvim-dap', {'cfg': 'cfg.dap'}
    PackAdd 'nvim-neotest/nvim-nio'
    PackAdd 'rcarriga/nvim-dap-ui', {'deps': ['nvim-dap', 'nvim-nio'], 'cfg': 'cfg.dap'}
    PackAdd 'jay-babu/mason-nvim-dap.nvim', {'deps': ['nvim-dap', 'mason.nvim'], 'cfg': 'cfg.dap'}
endif
" ------------------------------
" textobj install
" ------------------------------
if has('nvim') && get(g:, 'nvim_treesitter_install', utils#is_unix()) && executable('tree-sitter') && executable('curl') && executable('tar')
    PackAdd 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'main', 'cfg': 'treesitter'}
    PackAdd 'nvim-treesitter/nvim-treesitter-context', {'for': ['toml', 'yaml', 'json'], 'cfg': 'treesitter'}
    PackAdd 'nvim-treesitter/nvim-treesitter-textobjects', {'branch': 'main', 'deps': 'nvim-treesitter', 'cfg': 'treesitter'}
    PackAdd 'm-demare/hlargs.nvim', {'deps': 'nvim-treesitter', 'cfg': 'treesitter'}
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
    PackAdd 'asynctasks.vim'
endif
" ------------------------------
" fuzzy finders
" ------------------------------
if exists('*systemlist') && (has('patch-7.4.1304') || has('nvim'))
    PackAdd 'junegunn/fzf.vim'
    if utils#is_win()
        PackAdd 'junegunn/fzf', {'do': 'Powershell ./install.ps1 --all', 'dir': utils#expand('$HOME\\.local\\fzf')}
    else
        PackAdd 'junegunn/fzf', {'do': './install --all', 'dir': utils#expand('~/.local/fzf')}
    endif
    PackAdd 'fzf-registers'
    PackAdd 'fzf-tabs'
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 3 && !pack#get('noleaderf') && !pack#get('no-leaderf')
    PackAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
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
        PackAdd 'lewis6991/gitsigns.nvim', {'cfg': 'cfg.gitsigns'}
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
    PackAdd 'vim-floaterm', {'on': '^Floaterm.*$'}
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
    PackAdd 'vim-fern'
    PackAdd 'vim-nerdfont'
    PackAdd 'vim-glyph-palette'
    PackAdd 'vim-fern-git-status'
    PackAdd 'vim-fern-hijack'
    PackAdd 'vim-fern-renderer-nerdfont'
    PackAdd 'fern-mapping-fzf.vim'
    PackAdd 'fern-preview.vim'
else
    PackAdd 'vim-vinegar'
endif
" --------------------------------
" lightline
" --------------------------------
PackAdd 'lightline.vim'
PackAdd 'lightline-bufferline'
" ----------------------------
" scheme
" ----------------------------
if !pack#planned_treesitter() && pack#get('c') && pack#planned_adv_comp_eng()
    PackAdd 'jackguo380/vim-lsp-cxx-highlight', {'for': g:c_filetypes}
endif
if g:has_truecolor
    PackAdd 'sainnhe/sonokai'
    if has('nvim')
        " PackAdd 'catppuccin/nvim', {'as': 'catppuccin-nvim'}
        PackAdd 'EdenEast/nightfox.nvim'
        PackAdd 'folke/tokyonight.nvim'
        PackAdd 'craftzdog/solarized-osaka.nvim'
    else
        " PackAdd 'joshdick/onedark.vim'
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
    PackAdd 'snacks.nvim', {'cfg': 'cfg.snacks'}
    PackAdd 'Bekaboo/dropbar.nvim', {'cfg': 'cfg.dropbar'}
    if utils#is_unix()
        PackAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
    endif
elseif v:version >= 800
    PackAdd 'ryanoasis/vim-devicons'
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
    PackAdd 'vim-quickui'
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
    PackAdd 'windwp/nvim-autopairs', {'cfg': 'lsp'}
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
        Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
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
PackAdd 'vim-startify'
" -------------------
" quickfix
" -------------------
PackAdd 'romainl/vim-qf'
