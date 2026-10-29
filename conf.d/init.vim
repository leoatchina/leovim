if v:version <= 703 || v:version == 704 && !has('patch399')
    echoe 'vim 7.4.399 is at least required when using leovim.'
    finish
elseif has('nvim') && !has('nvim-0.12')
    echoe 'Neovim 0.12+ is required.'
    finish
else
    set nocompatible
    if !exists('g:packs') || type(g:packs) != type([])
        let g:packs = []
    endif
endif
" --------------------------
" load contract
" --------------------------
" This file is the only supported entrypoint. It must initialize directory
" variables, runtimepath, g:packs, g:plugs, PackAdd, and the user config hooks
" before plugin modules are loaded.
"
" Load order:
"   1. source ~/.vimrc.opt so users fill g:packs through pack#add()
"   2. pack#begin() scans local plugins, starts vim-plug, and sources user packs
"   3. source vscode.vim or main.vim
"   4. source ~/.leovim.d/after.vim, apply first-run completion fallback
"   5. pack#end()
"
" The completion fallback before pack#end() is intentional: when advanced
" completion plugins are planned but not installed yet, the current session
" falls back to builtin/mcm so LeoVim remains usable during first install.
" --------------------------
" set dirs
" --------------------------
let $LEOVIM_DIR = expand('~/.leovim')
let $LEOVIMD_DIR = expand("~/.leovim.d")
let $PACK_DIR = expand($LEOVIM_DIR . '/pack')
" settings and plugins dirs
let $CONF_D_DIR = expand($LEOVIM_DIR . '/conf.d')
let $INIT_DIR = expand($CONF_D_DIR . '/init')
let $MAIN_DIR = expand($CONF_D_DIR . '/main')
let $PLUG_DIR = expand($CONF_D_DIR . '/plug')
" cfg for special plugins
let $CFG_DIR = expand($MAIN_DIR . '/after/cfg')
" opt dirs
let $LEO_OPT_DIR = expand($CONF_D_DIR . '/pack/leo/opt')
let $FORK_OPT_DIR = expand($PACK_DIR . '/fork/opt')
let $CLONE_OPT_DIR = expand($PACK_DIR . '/clone/opt')
" --------------------------
" set rtp && pack path
" --------------------------
if exists(':packadd')
    set packpath^=$LEOVIM_DIR
    set packpath^=$CONF_D_DIR
endif
set rtp^=$PACK_DIR
set rtp^=$INIT_DIR
" --------------------------
" gui_running && OS
" --------------------------
if utils#is_win() && !has('nvim') && v:version < 900
    echoe "In windows, please update to vim9.0+."
    finish
endif
if has('gui_running') && !has('nvim') && get(g:, 'leovim_loaded', 0) == 0
    " NOTE :h guioptions
    set guioptions=g
elseif utils#is_neovide()
    let g:neovide_cursor_animation_length = 0
    let g:neovide_cursor_trail_size = 0
    let g:neovide_scroll_animation_length = 0
    let g:neovide_position_animation_length = 0
    let g:neovide_cursor_animate_in_insert_mode = v:false
endif
" ------------------------
" mapleader
" ------------------------
let g:mapleader = ' '
let g:maplocalleader = 'q'
" -----------------------------------
" filetypes definition
" -----------------------------------
let g:c_filetypes = get(g:, 'c_filetypes', ["c", "cpp", "objc", "objcpp", "cuda"])
let g:web_filetypes = get(g:, 'web_filetypes', ['php', 'html', 'css', 'scss', 'wxss', 'wxml', 'xml', 'toml', 'javascript', 'typescript', 'vue'])
" -----------------------------------
" pattern
" -----------------------------------
let g:todo_patterns = "(TODO|FIXME|WARN|ERROR|BUG)"
let g:note_patterns = "(NOTE|XXX|HINT|ETC|HELPME|COMMENTED|NOTUSED|STEP|In\\[\\d\*\\])"
let g:root_patterns = get(g:, 'root_patterns', [".git", ".svn", ".root", ".vim", "node_modules"])
let g:root_files = get(g:, 'root_files', ["tsconfig.json", "Cargo.toml", "go.mod"])
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
    exec "set " . settingname . "=" . fnameescape(dir)
endfor
if has('nvim')
    set shadafile=$HOME/.vim/shada.main
    lua require('utils')
endif
" -----------------------------------
" map
" -----------------------------------
map ÏP <F1>
map ÏQ <F2>
map ÏR <F3>
map ÏS <F4>
map <F1>  <Nop>
map <F2>  <Nop>
map <F3>  <Nop>
map <F4>  <Nop>
map <F5>  <Nop>
map <F6>  <Nop>
map <F7>  <Nop>
map <F8>  <Nop>
map <F9>  <Nop>
map <F10> <Nop>
map <F11> <Nop>
map <F12> <Nop>
map <C-i> <Nop>
map <C-z> <Nop>
nnoremap s <Nop>
nnoremap S <Nop>
nnoremap ; <Nop>
xnoremap ; <Nop>
nnoremap , <Nop>
xnoremap , <Nop>
" enhanced remap
xmap >> >gv
xmap << <gv
" F1 as keymap help (g?)
nmap <F1> g?
nnoremap <silent>gj j
nnoremap <silent>gk k
nnoremap <expr>k (v:count > 1 ? "m'" . v:count : '') . 'gk'
nnoremap <expr>j (v:count > 1 ? "m'" . v:count : '') . 'gj'
" bs tab
nnoremap <Bs> :set nohlsearch? nohlsearch!<Cr>
nnoremap <Cr> <C-i>
nnoremap gb 2g;I
" case change && Z map
nnoremap ZU m1gUiw`1
nnoremap ZD m1guiw`1
nnoremap ZT zt
" home end
cmap <C-a> <Home>
cmap <C-e> <End>
" Completion backends may override this; native menus still use Ctrl-e to cancel.
inoremap <expr><C-e> pumvisible() ? "\<C-e>" : "\<End>"
imap <expr><C-a> pumvisible()? "\<C-a>":"\<C-o>0"
imap <expr><C-b> pumvisible()? "\<C-b>":"\<C-o>I"
imap <expr><C-f> pumvisible()? "\<C-f>":"\<C-o>A"
nnoremap H ^
xnoremap H ^
onoremap H ^
nnoremap L g_
xnoremap L g_
onoremap L g_
nnoremap $ g_
xnoremap $ g_
onoremap $ g_
nnoremap g_ $
xnoremap g_ $
onoremap g_ $
" ------------------------
" enhanced edit
" ------------------------
inoremap <silent><C-j> <C-\><C-n>:call utils#move_to_end_and_add_semicolon()<CR>
nnoremap <silent>d<space> :call utils#trim_whitespace()<Cr>
" ------------------------
" open_in_other_editor
" ------------------------
if has('nvim')
    function! s:open_in_other()
        if utils#is_vscode()
            let opener = get(g:, 'open_neovim', '')
            let target = printf('+%d %s', line('.'), shellescape(utils#abs_path()))
        else
            let opener = get(g:, 'open_editor', 'code')
            let target = printf('--goto %s', shellescape(printf('%s:%d:%d', utils#abs_path(), line('.'), col('.'))))
        endif
        if !executable(opener)
            if utils#is_vscode()
                echoe 'g:open_neovim is not set or not executable.'
            else
                echoe 'g:open_editor is not executable: ' . opener
            endif
            return
        endif
        silent! execute '!' . opener . ' ' . target
    endfunction
    command! OpenInOther call s:open_in_other()
    nnoremap <silent><nowait>g<tab> :OpenInOther<Cr>
endif
" ------------------------
" open url/file under cursor
" ------------------------
function! s:get_cursor_pos(text, col)
    let cursor = a:col - 1
    let start = 0
    while 1
        let m = matchlist(a:text, '\v(\f+)%([#:](\d+))?%(:(\d+))?', start)
        if empty(m)
            break
        endif
        let begin = match(a:text, '\v(\f+)%([#:](\d+))?%(:(\d+))?', start)
        if begin <= cursor && cursor < begin + strlen(m[0])
            return [m[1], m[2], m[3]]
        endif
        let start = begin + 1
    endwhile
    return []
endfunction
function! s:open_link_in_editor(text, col)
    let l:url = textobj#uri#open_uri()
    redraw!
    if exists('l:url') && len(l:url)
        echom 'Opening "' . l:url . '"'
        return
    elseif a:text == ''
        echom "No file under cursor"
        return
    endif
    let editor = get(g:, 'open_editor', 'code')
    if !executable(editor)
        echom "Neither URL nor file found, and no editor executable"
        return
    endif
    let location = s:get_cursor_pos(a:text, a:col)
    if empty(location) || !filereadable(location[0])
        echo "Neither URL nor file path under cursor."
        return
    endif
    let target = location[0]
    if location[1] != ''
        let target .= ':' . str2nr(location[1])
        if location[2] != ''
            let target .= ':' . str2nr(location[2])
        endif
    endif
    execute '!' . shellescape(editor) . ' --goto ' . shellescape(target)
endfunction
command! OpenLink call s:open_link_in_editor(getline("."), col("."))
nnoremap <silent>gx :OpenLink<cr>
" -----------------------------------------------------------
" start pack install
" -----------------------------------------------------------
if filereadable(expand("~/.vimrc.opt"))
    source $HOME/.vimrc.opt
endif
call pack#begin(utils#expand("$LEOVIMD_DIR/pack/add/opt"))
" different for vscode and main config
if utils#is_vscode()
    source $INIT_DIR/vscode.vim
else
    source $MAIN_DIR/main.vim
endif
" addtional vim config
if filereadable(utils#expand("~/.leovim.d/after.vim"))
    source ~/.leovim.d/after.vim
endif
call pack#end()
let g:leovim_loaded = 1
