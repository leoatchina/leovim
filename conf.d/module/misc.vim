" ------------------------------
" marks
" ------------------------------
PlugAdd 'kshenoy/vim-signature'
" ----------------------------
" pairs && wilder
" ----------------------------
if utils#is_planned_lsp()
    PlugAdd 'windwp/nvim-autopairs'
else
    if g:python_version > 3 && has('nvim') && utils#is_unix()
        function! UpdateRemotePlugins(...)
            let &rtp=&rtp
            UpdateRemotePlugins
        endfunction
        Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
    elseif !has('nvim') && v:version >= 801 || has('nvim') && !utils#is_windows()
        PlugAdd 'gelguy/wilder.nvim'
    endif
    if v:version >= 800
        PlugAdd 'tmsvg/pear-tree'
    elseif has('patch-7.4.849')
        PlugAdd 'jiangmiao/auto-pairs'
    endif
endif
" ----------------------------
" indentLine plugins
" ----------------------------
if has('nvim')
    PlugAdd 'lukas-reineke/indent-blankline.nvim'
elseif has('conceal')
    PlugAdd 'Yggdroot/indentLine'
endif
" ------------------------------
" fullscreen
" ------------------------------
if utils#is_linux() && utils#has_gui() && executable('wmctrl')
    PlugAdd 'lambdalisue/vim-fullscreen'
    if has('nvim')
        let g:fullscreen#start_command = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)"
        let g:fullscreen#stop_command  = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)"
    endif
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
        if utils#is_unix() && (!utils#is_planned('leaderf') || utils#is_planned('leaderf') && !has('nvim') && !has('patch-9.0.200'))
            PlugAdd 'APZelos/blamer.nvim'
        endif
    endif
endif
" ------------------------------
" undo
" ------------------------------
if has('nvim') && utils#is_unix()
    PlugAdd 'kevinhwang91/nvim-fundo'
endif
PlugOpt 'undotree'
" ------------------------------
" translate
" ------------------------------
if utils#is_require('translate') && v:version >= 800 && g:python_version >= 3.06
    PlugAdd 'voldikss/vim-translator'
endif
" ------------------------------
" zfvim
" ------------------------------
if (utils#is_require('wubi') || utils#is_require('pinyin')) && g:has_terminal && utils#is_unix()
    PlugAdd 'ZSaberLv0/ZFVimIM'
    if utils#is_require('wubi')
        PlugAdd 'ZSaberLv0/ZFVimIM_wubi_base'
        let g:input_method = 'zfvim_wubi'
    else
        let g:input_method = 'zfvim_pinyin'
    endif
    PlugAdd 'ZSaberLv0/ZFVimIM_pinyin'
endif
