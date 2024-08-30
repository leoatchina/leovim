if v:version <= 703 || v:version == 704 && !has('patch399')
    echoe 'vim 7.4.399 is at least required when uing leovim.'
    finish
elseif !has('nvim-0.7.2') && has('nvim')
    echoe 'neovim 0.7.2 is at least required when using leovim.'
    finish
else
    set nocompatible
endif
" --------------------------
" system check functions
" --------------------------
function! WINDOWS()
    return has('win32') || has('win64')
endfunction
function! MACOS()
    return has('macunix')
endfunction
function! CYGWIN()
    return has('win32unix') && !has('macunix')
endfunction
function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
function! UNIX()
    return has('unix') && !has('win32unix')
endfunction
function! MACVIM()
    return has('gui_running') && has('macunix')
endfunction
" --------------------------
" gui_running && OS
" --------------------------
if has('gui_running')
    let s:gui_running = 1
    if get(g:, 'leovim_loaded', 0) == 0
        set guioptions-=e
        set guioptions-=T
        set guioptions-=r
        set guioptions-=R
        set guioptions-=l
        set guioptions-=L
        set guioptions-=m
        set guioptions-=
    endif
elseif has('nvim')
    if has('gui_vimr')
        let s:gui_running = 1
    elseif exists('g:neovide')
        let s:gui_running = 1
        let g:neovide_cursor_animation_length = 0
    elseif exists('g:vscode')
        let s:gui_running = 0
    else
        if exists('g:GuiLoaded') && g:GuiLoaded != 0
            let s:gui_running = 1
        elseif exists('*nvim_list_uis') && len(nvim_list_uis()) > 0
            let uis = nvim_list_uis()[0]
            let s:gui_running = get(uis, 'ext_termcolors', 0)? 0 : 1
        elseif exists("+termguicolors") && (&termguicolors) != 0
            let s:gui_running = 1
        else
            let s:gui_running = 0
        endif
    endif
else
    let s:gui_running = 0
endif
function! HAS_GUI()
    return s:gui_running
endfunction
if WINDOWS()
    if s:gui_running == 0 && !has('nvim') && v:version < 900
        echoe "In windows, please update to vim9.0+ if without gui."
        finish
    elseif v:version < 800 && !has('nvim')
        echoe 'vim 8.0 or neovim 0.8 is at least required when uing leovim in windows.'
        finish
    endif
elseif exists('g:vscode') && !has('nvim-0.9')
    echoe "vscode-neovm required nvim-0.9+!"
    finish
endif
" --------------------------
" set dirs
" --------------------------
let $LEOVIM_DIR = expand('~/.leovim')
let $CONF_D_DIR = expand($LEOVIM_DIR . '/conf.d')
let $INSTALL_DIR = expand($CONF_D_DIR . '/install')
let $ELEMENT_DIR = expand($CONF_D_DIR . '/element')
let $CFG_DIR = expand($ELEMENT_DIR . '/cfg')
" opt dirs
let $LEO_OPT_DIR = expand($LEOVIM_DIR . '/pack/leo/opt')
let $FORK_OPT_DIR = expand($LEOVIM_DIR . '/pack/fork/opt')
let $CLONE_OPT_DIR = expand($LEOVIM_DIR . '/pack/clone/opt')
" --------------------------
" set rtp && pack path
" --------------------------
if WINDOWS()
    set rtp^=$LEOVIM_DIR\pack
    set rtp^=$CONF_D_DIR\element
else
    set rtp^=$LEOVIM_DIR/pack
    set rtp^=$CONF_D_DIR/element
endif
if exists(':packadd')
    set packpath^=$LEOVIM_DIR
endif
" --------------------------
" init directories
" --------------------------
let dir_list = {
            \ 'backupdir': '~/.vim/backup',
            \ 'viewdir':   '~/.vim/views',
            \ 'directory': '~/.vim/swap',
            \ }
if has('persistent_undo')
    if has('nvim')
        let dir_list['undodir'] = '~/.vim/fundo'
    else
        let dir_list['undodir'] = '~/.vim/undo'
    endif
endif
for [settingname, dirname] in items(dir_list)
    let dir = expand(dirname)
    if !isdirectory(dir)
        try
            silent! call mkdir(dir, "p")
        catch
            echo "Unable to create it. Try mkdir -p " . dir
            continue
        endtry
    endif
    exec "set " . settingname . "=" . dir
endfor
if has('nvim')
    lua require('utils')
    set shadafile=$HOME/.vim/shada.main
endif
" ------------------------
" mapleader
" ------------------------
let g:mapleader      = ' '
let g:maplocalleader = ','
" ------------------------
" set pack related variables
" ------------------------
let g:require_group = []
let g:leovim_installed = {}
function! Require(pack)
    return count(g:require_group, a:pack) > 0
endfunction
function! AddRequire(...) abort
    if a:0 == 0
        return
    endif
    for require in a:000
        if !Require(require)
            call add(g:require_group, require)
        endif
    endfor
endfunction
function! Planned(...)
    if empty(a:000)
        return 0
    endif
    for pack in a:000
        let pack = tolower(pack)
        if !has_key(g:leovim_installed, pack)
            return 0
        endif
    endfor
    return 1
endfunction
function! Installed(...)
    if empty(a:000)
        return 0
    endif
    for pack in a:000
        let pack = tolower(pack)
        if !has_key(g:leovim_installed, pack) || get(g:leovim_installed, pack, 0) == 0
            return 0
        endif
    endfor
    return 1
endfunction
source $CFG_DIR/main.vim
let g:leovim_loaded = 1
