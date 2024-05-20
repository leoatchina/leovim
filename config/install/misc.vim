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
" fullscreen
" ------------------------------
if LINUX() && HAS_GUI() && executable('wmctrl')
    PlugAdd 'lambdalisue/vim-fullscreen'
    if has('nvim')
        let g:fullscreen#start_command = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)"
        let g:fullscreen#stop_command  = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)"
    endif
endif
" ------------------------------
" marks
" ------------------------------
PlugAdd 'kshenoy/vim-signature'
" --------------------------
" indentline
" --------------------------
if has('nvim-0.8')
    PlugAdd 'lukas-reineke/indent-blankline.nvim'
else
    PlugAdd 'Yggdroot/indentLine'
endif
" ------------------------------
" fold
" ------------------------------
if has('nvim-0.6.1')
    PlugAdd 'kevinhwang91/promise-async'
    PlugAdd 'kevinhwang91/nvim-ufo'
endif
" ------------------------------
" devicons
" ------------------------------
if v:version >= 800
    if has('nvim-0.8')
        PlugAdd 'nvim-tree/nvim-web-devicons'
    else
        PlugAdd 'ryanoasis/vim-devicons'
    endif
endif
" ------------------------------
" project
" ------------------------------
if has('patch-8.0.1832') && exists("v:null") || has('nvim')
    PlugAdd 'leafOfTree/vim-project'
endif
" ------------------------------
" undo && search hl
" ------------------------------
if has('nvim') && UNIX()
    PlugAdd 'kevinhwang91/nvim-fundo'
endif
PlugAdd 'mbbill/undotree'
" ------------------------------
" zfvim
" ------------------------------
if (Require('wubi') || Require('pinyin')) && g:has_terminal && (UNIX() || WINDOWS() && !has('nvim'))
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
" ------------------------------
" writing
" ------------------------------
if executable('mdr') && (has('nvim') || has('patch-8.1.1401'))
    PlugAddOpt 'preview-markdown.vim'
endif
if Require('markdown')
    PlugAdd 'leoatchina/vim-table-mode'
    PlugAdd 'junegunn/vim-journal', {'for': 'markdown'}
    PlugAdd 'ferrine/md-img-paste.vim', {'for': 'markdown'}
    if get(g:, 'node_version', 0) > 12 && (has('nvim') || v:version >= 801)
        PlugAdd 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
        PlugAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    elseif g:python_version > 0
        PlugAdd 'iamcco/markdown-preview.vim', {'for': ['markdown']}
        PlugAdd 'iamcco/mathjax-support-for-mkdp', {'for': ['markdown']}
    endif
endif
" latex
if Require('latex') && executable(get(g:, "vimtex_view_method", ''))
    PlugAdd 'lervag/vimtex', {'for': 'latex'}
endif
