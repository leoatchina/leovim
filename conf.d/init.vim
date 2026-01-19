if v:version <= 703 || v:version == 704 && !has('patch399')
    echoe 'vim 7.4.399 is at least required when using leovim.'
    finish
elseif !has('nvim-0.8') && has('nvim')
    echoe 'neovim-0.8 is at least required to use leovim.'
    finish
else
    set nocompatible
    if !exists('g:packs') || type(g:packs) != type([])
        let g:packs = []
    endif
endif
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
set rtp^=$PACK_DIR
set rtp^=$INIT_DIR
" if exists(':packadd')
"     set packpath^=$LEOVIM_DIR
"     set packpath^=$CONF_D_DIR
" endif
let s:opt_plugs = {}
for opt_dir in [$LEO_OPT_DIR, $FORK_OPT_DIR, $CLONE_OPT_DIR]
    for plug_dir in globpath(opt_dir, '*', 0, 1)
        if !isdirectory(plug_dir)
            continue
        endif
        let abs_dir = substitute(fnamemodify(plug_dir, ':p'), '[\\/]$', '', '')
        let plugin = fnamemodify(abs_dir, ':t')
        let s:opt_plugs[plugin] = abs_dir
    endfor
endfor
" --------------------------
" gui_running && OS
" --------------------------
if utils#is_vscode() && !has('nvim-0.10')
    echoe "vscode-neovim required nvim-0.10+!"
    finish
elseif utils#is_win() && !has('nvim') && v:version < 900
    echoe "In windows, please update to vim9.0+."
    finish
endif
if has('gui_running')
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
elseif utils#is_neovide()
    let g:neovide_cursor_animation_length = 0
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
let g:root_patterns = get(g:, 'root_patterns', [".git", ".svn", ".hg", ".root", ".vscode", ".vim", ".idea", ".ccls"])
let g:root_files = get(g:, 'root_files', [".task", "tsconfig.js", "Cargo.toml", "go.mod"])
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
    set shadafile=$HOME/.vim/shada.main
    lua require('utils')
endif
" -----------------------------------
" map
" -----------------------------------
nmap q <Nop>
nmap M q
xmap M q
omap M q
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
nnoremap <silent> gj j
nnoremap <silent> gk k
nnoremap <expr> k (v:count > 1 ? "m'" . v:count : '') . 'gk'
nnoremap <expr> j (v:count > 1 ? "m'" . v:count : '') . 'gj'
" z remap
nnoremap zs <Nop>
nnoremap zS <Nop>
nnoremap zw <Nop>
nnoremap zW <Nop>
nnoremap zg <Nop>
nnoremap zG <Nop>
nnoremap zl zL
nnoremap zh zH
nnoremap zr zR
nnoremap z= zT
nnoremap z- zB
nnoremap ZT zt
" bs tab
nnoremap <Bs> :set nohlsearch? nohlsearch!<Cr>
nnoremap <C-m> <C-i>
nnoremap <Cr> <C-i>
nnoremap gb 2g;I
" case change
nnoremap ZU m1gUiw`1
nnoremap ZD m1guiw`1
" home end
cmap <C-a> <Home>
cmap <C-e> <End>
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
nnoremap <silent>d<space> :call utils#trip_whitespace()<Cr>
" ------------------------
" open_in_other_editor
" ------------------------
if has('nvim')
    function! s:open_in_other()
        if utils#is_vscode() && executable(get(g:, 'open_neovim', ''))
            call VSCodeNotify('copyFilePath')
            let p = fnameescape(@*)
            silent! exec printf('!%s +%d "%s"', g:open_neovim, line('.'), p)
        elseif !utils#is_vscode() && executable(get(g:, 'open_editor', 'code'))
            let editor = get(g:, 'open_editor', 'code')
            silent! exec printf("!%s --goto %s:%d:%d", editor, utils#abs_path(), line("."), col("."))
        else
            echom "Cannot open current file in other editor."
        endif
    endfunction
    command! OpenInOther call s:open_in_other()
    nnoremap <silent><nowait>g<tab> :OpenInOther<Cr>
endif
" ------------------------
" open url/file under cursor
" ------------------------
function! s:get_cursor_pos(text, col)
    " Find the start location
    let col = a:col
    while col >= 0 && a:text[col] =~ '\f'
        let col = col - 1
    endwhile
    let col = col + 1
    " Match file name and position
    let m = matchlist(a:text, '\v(\f+)%([#:](\d+))?%(:(\d+))?', col)
    if len(m) > 0
        return [m[1], m[2], m[3]]
    endif
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
    if executable(get(g:, 'open_editor', 'code'))
        let editor = get(g:, 'open_editor', 'code') . ' --goto'
    else
        echom "Neither URL nor file found, and no editor executable"
        return
    endif
    " location 0: file, 1: row, 2: column
    let location = s:get_cursor_pos(a:text, a:col)
    try
        let fl = location[0]
    catch /.*/
        let fl = ''
    endtry
    if fl != '' && filereadable(fl)
        if location[1] != ''
            if location[2] != ''
                exec "!" . editor . " " . fl . ":" . str2nr(location[1]) . ":" . str2nr(location[2])
            else
                exec "!" . editor . " " . fl . ":" . str2nr(location[1])
            endif
        else
            exec "!" . editor . " " . fl
        endif
    else
        echo "Neither URL nor file path under cursor."
    endif
endfunction
command! OpenLink call s:open_link_in_editor(getline("."), col("."))
nnoremap <silent>gx :OpenLink<cr>
" -----------------------------------------------------------
" start pack install
" -----------------------------------------------------------
if filereadable(expand("~/.vimrc.opt"))
    source $HOME/.vimrc.opt
endif
let g:plugs = {}
let g:plug_threads = get(g:, 'plug_threads', 16)
set rtp^=$MAIN_DIR
call plug#begin(utils#expand("$LEOVIMD_DIR/pack/add/opt"))
" unified PlugAdd (local/remote) + PlugAdd shim
function! s:plug_add(plugin, ...) abort
    let plugin = substitute(a:plugin, '[\/]\+$', '', 'g')
    let opts = a:0 > 0 ? copy(a:1) : {}
    " derive key name for duplicate check
    if has_key(opts, 'as') && !empty(opts['as'])
        let key_name = opts['as']
    elseif plugin =~ '/'
        let key_name = split(plugin, '/')[-1]
    else
        let key_name = plugin
    endif
    if has_key(g:plugs, key_name)
        return
    endif
    if plugin =~ '/'
        call plug#(plugin, opts)
    elseif has_key(s:opt_plugs, plugin)
        let local_dir = s:opt_plugs[plugin]
        if get(opts, 'now', 0)
            if exists(':packadd')
                execute 'packadd ' . plugin
            else
                execute 'set rtp^=' . local_dir
            endif
        else
            call plug#(local_dir, opts)
        endif
    else
        echoe plugin . " not exists"
    endif
endfunction
command! -nargs=+ PlugAdd call <sid>plug_add(<args>)
function! s:plug_add_update() abort
    let vimrc_opt = utils#expand('~/.vimrc.opt')
    if filereadable(vimrc_opt)
        execute "source " . vimrc_opt
    endif
    PlugUpdate
endfunction
command! PlugAddUpdate call s:plug_add_update()
nnoremap <silent><Tab>u :PlugAddUpdate<Cr>
nnoremap <silent><Tab>i :PlugInstall<Cr>
nnoremap <silent><Tab>C :PlugClean<Cr>
nnoremap <silent><Tab>S :PlugStatus<Cr>
nnoremap <silent><Tab>O :PlugSnapshot<Cr>
nnoremap <silent><Tab>P :Plug
" addtional vim packs
if filereadable(utils#expand("~/.leovim.d/pack.vim"))
    source ~/.leovim.d/pack.vim
endif
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
" -----------------------------------------------------------
" NOTE: plug install and config end
" -----------------------------------------------------------
call plug#end()
let g:leovim_loaded = 1
