if pack#planned_cmp()
    PackAdd 'hrsh7th/nvim-cmp'
    PackAdd 'hrsh7th/cmp-nvim-lsp'
    PackAdd 'hrsh7th/cmp-nvim-lua'
    PackAdd 'hrsh7th/cmp-buffer'
    PackAdd 'hrsh7th/cmp-cmdline'
    PackAdd 'hrsh7th/cmp-vsnip'
    PackAdd 'hrsh7th/cmp-nvim-lsp-signature-help'
    PackAdd 'FelipeLema/cmp-async-path'
    PackAdd 'onsails/lspkind-nvim'
    PackAdd 'xzbdmw/colorful-menu.nvim'
elseif pack#planned_blink()
    if executable('cargo') && !pack#get('blink.lua')
        PackAdd 'Saghen/blink.cmp', {'do': 'cargo build --release', 'branch': 'v1'}
    else
        PackAdd 'Saghen/blink.cmp', {'branch': 'v1'}
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
" snippets install
" ------------------------------
if !pack#get('nocomplete') && exists('v:true') && exists("##TextChangedP")
    PackAdd 'rafamadriz/friendly-snippets'
    PackAdd 'hrsh7th/vim-vsnip'
endif
" ------------------------------
" lsp && linter tool install
" ------------------------------
if pack#planned_lsp()
    let g:lint_tool = 'lsp'
    " lsp related
    PackAdd 'mason-org/mason-lspconfig.nvim'
    PackAdd 'camilledejoye/nvim-lsp-selection-range'
    PackAdd 'Wansmer/symbol-usage.nvim'
    PackAdd 'ravenxrz/call-graph.nvim'
    PackAdd 'neovim/nvim-lspconfig'
    " lightline
    PackAdd 'josa42/nvim-lightline-lsp'
    " lspimport is only for pyright
    PackAdd 'leoatchina/nvim-lspimport'
    " codesettings
    PackAdd 'mrjones2014/codesettings.nvim'
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
" Vimspector requires Python 3.10+, Vim 8.2.4797+ or Neovim 0.8+.
if pack#get('debug') && g:python_version >= 3.10
            \ && ((!has('nvim') && has('patch-8.2.4797'))
            \ || (has('nvim-0.8') && !pack#planned_lsp()))
    let vimspector_install = " ./install_gadget.py --update-gadget-config"
    PackAdd 'puremourning/vimspector', { 'do': g:python_prog . vimspector_install }
elseif has('nvim-0.9.5') && pack#get('debug') || pack#planned_lsp() && pack#get('java')
    PackAdd 'mfussenegger/nvim-dap'
    PackAdd 'nvim-neotest/nvim-nio'
    PackAdd 'rcarriga/nvim-dap-ui'
    PackAdd 'jay-babu/mason-nvim-dap.nvim'
endif
" ------------------------------
" textobj install
" ------------------------------
if has('nvim-0.9.2') && !has('nvim-0.12') && get(g:, 'nvim_treesitter_install', utils#is_unix())
    PackAdd 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'master'}
    PackAdd 'nvim-treesitter/nvim-treesitter-textobjects', {'branch': 'master'}
    PackAdd 'nvim-treesitter/nvim-treesitter-context', {'for': ['toml', 'yaml', 'json']}
    PackAdd 'nvim-treesitter/nvim-treesitter-refactor'
    PackAdd 'm-demare/hlargs.nvim'
elseif exists('*search') && exists('*getpos') && pack#planned_coc()
    PackAdd 'bps/vim-textobj-python', {'for': 'python'}
    PackAdd 'thinca/vim-textobj-function-perl', {'for': 'perl'}
    PackAdd 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    PackAdd 'gcmt/wildfire.vim'
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
    if has('nvim')
        PackAdd 'stevearc/oil.nvim'
        PackAdd 'benomahony/oil-git.nvim'
    endif
endif
if (has('nvim') || has('patch-7.4.1126')) && g:python_version > 3 && !pack#get('noleaderf') && !pack#get('no-leaderf')
    PackAdd 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
endif
" Git
" ------------------------------
if executable('git')
    if v:version >= 800 && g:git_version >= 1.85
        PackAdd 'tpope/vim-fugitive'
        if has('nvim')
            if has('nvim-0.10') && g:git_version >= 2.31
                PackAdd 'dlyongemallo/diffview-plus.nvim'
            endif
            if has('nvim-0.11')
                PackAdd 'lewis6991/gitsigns.nvim'
            elseif has('nvim-0.9')
                PackAdd 'lewis6991/gitsigns.nvim', {'tag': 'v1.0.2'}
            endif
        else
            if !pack#planned_leaderf()
                PackAdd 'junegunn/gv.vim', {'on': 'GV'}
            endif
        endif
    endif
    if !has('nvim') && has('patch-8.0.902')
        PackAdd 'vim-signify'
    endif
    if g:has_popup_floating
        PackAdd 'skywind3000/vim-git-diffview'
        " LeaderF supplies inline blame on recent Vim versions.
        if utils#is_unix() && (!pack#planned_leaderf() || !has('patch-9.0.200'))
            PackAdd 'APZelos/blamer.nvim'
        endif
    endif
endif
" --------------------------
" terminal && tmux
" --------------------------
if g:has_terminal
    PackAdd 'vim-floaterm'
    PackAdd 'vim-floaterm-enhance'
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
    augroup my-glyph-palette
        autocmd!
        autocmd FileType fern,startify call glyph_palette#apply()
    augroup END
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
    PackAdd 'nvim-tree/nvim-web-devicons'
    PackAdd 'kevinhwang91/promise-async'
    PackAdd 'kevinhwang91/nvim-bqf', {'for': 'qf'}
    PackAdd 'MunifTanjim/nui.nvim'
    PackAdd 'nvim-lua/plenary.nvim'
    PackAdd 'stevearc/dressing.nvim'
    if  has('nvim-0.11')
        PackAdd 'Bekaboo/dropbar.nvim'
        if utils#is_unix()
            PackAdd 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}
        endif
    endif
    if pack#planned_lsp() || pack#planned_dap()
        PackAdd 'mason-org/mason.nvim'
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
    PackAdd 'vim-header', {'on': [
                \ 'AddHeader', 'AddMinHeader',
                \ 'AddAGPLicense', 'AddApacheLicense', 'AddSHLLicense', 'AddEUPLicense',
                \ 'AddGNULicense', 'AddLGPLLicense', 'AddMITLicense', 'AddMPLLicense',
                \ 'AddWTFPLLicense', 'AddZlibLicense']}
    nnoremap <M-k>a :AddHeader<Cr>
endif
" ----------------------------
" pairs && wiler
" ----------------------------
if pack#planned_lsp()
    PackAdd 'windwp/nvim-autopairs'
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
    PackAdd 'kevinhwang91/nvim-fundo'
endif
" ----------------------------
" indentLine plugins
" ----------------------------
if has('nvim')
    PackAdd 'lukas-reineke/indent-blankline.nvim'
elseif has('conceal')
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
