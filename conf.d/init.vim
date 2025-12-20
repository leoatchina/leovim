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
let $RTP_DIR = expand($LEOVIM_DIR . '/rtp')
" settings and plugins dirs
let $CONF_D_DIR = expand($LEOVIM_DIR . '/conf.d')
let $INIT_DIR = expand($CONF_D_DIR . '/init')
let $MAIN_DIR = expand($CONF_D_DIR . '/main')
let $PACK_DIR = expand($CONF_D_DIR . '/pack')
" cfg for special plugins
let $CFG_DIR = expand($MAIN_DIR . '/after/cfg')
" opt dirs
let $LEO_OPT_DIR = expand($RTP_DIR . '/leo/opt')
let $FORK_OPT_DIR = expand($RTP_DIR . '/fork/opt')
let $CLONE_OPT_DIR = expand($RTP_DIR . '/clone/opt')
" --------------------------
" set rtp && pack path
" --------------------------
set rtp^=$RTP_DIR
set rtp^=$INIT_DIR
if exists(':packadd')
    set packpath^=$CONF_D_DIR
endif
" --------------------------
" gui_running && OS
" --------------------------
if utils#is_vscode() && !has('nvim-0.10')
    echoe "vscode-neovim required nvim-0.10+!"
    finish
elseif utils#is_win()
    if !has('nvim') && v:version < 900
        echoe "In windows, please update to vim9.0+."
        finish
    elseif !has('nvim-0.8') && has('nvim')
        echoe 'neovim 0.8 is at least required when using leovim in windows.'
        finish
    endif
endif
" gui - GUI detection moved to utils.vim
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
elseif has('nvim') && exists('g:neovide')
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
nnoremap q <Nop>
nnoremap Q q
xnoremap Q q
onoremap Q q
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
" ------------------------------------
" clipboard
" ------------------------------------
xnoremap / "yy/<C-r>=utils#escape(@y)<CR><Cr>
xnoremap ? "yy?<C-r>=utils#escape(@y)<CR><Cr>
xnoremap s "yy:%s/<C-r>=utils#escape(@y)<CR>/<C-r>=utils#escape(@y)<CR>/gc<Left><Left><Left>
xnoremap <Cr> "yy:%s/<C-r>=utils#escape(@y)<CR>//gc<Left><Left><Left>
" Copy file path
nnoremap <leader>YA :let @"=utils#abs_path()<Cr>:echo "-= File path copied=-"<Cr>
" Copy file dir
nnoremap <leader>YD :let @"=utils#abs_dir()<Cr>:echo "-= File dir copied=-"<Cr>
" Copy file name
nnoremap <leader>YF :let @"=utils#file_name()<Cr>:echo "-= File name copied=-"<Cr>
" Copy bookmark position reference
nnoremap <leader>YM :let @"=utils#abs_path().":".line(".").":".col(".")<Cr>:echo "-= Current position reference copied=-"<Cr>
" Yank a line without leading whitespaces and line break
nnoremap <leader>YU _yg_:echo "-= Yanked line without leading whitespaces and line break=-"<Cr>
if has('clipboard')
    function! s:setup_clipboard(register, mode, label) abort
        let s:clipboard = a:mode
        if utils#is_vscode()
            execute 'set clipboard=' . a:mode
        else
            set clipboard=
        endif
        execute 'xnoremap Y "' . a:register . 'y:echo "Yank selection to ' . a:label . ' clipboard."<Cr>'
        execute 'nnoremap <leader>ya :let @' . a:register . '=utils#abs_path()<Cr>:echo "-= File path copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>yd :let @' . a:register . '=utils#abs_dir()<Cr>:echo "-= File dir copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>yf :let @' . a:register . '=utils#file_name()<Cr>:echo "-= File name copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>ym :let @' . a:register . '=utils#abs_path().":".line(".").":".col(".")<Cr>:echo "-= Current position reference copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>yu _"' . a:register . 'yg_:echo "-= Yanked line without leading whitespaces and line break to ' . a:label . ' clipboard=-"<Cr>'
    endfunction
    if utils#is_linux() && (utils#is_vscode() || exists('$TMUX'))
        call s:setup_clipboard('+', 'unnamedplus', 'x11')
    else
        call s:setup_clipboard('*', 'unnamed', 'system')
    endif
else
    let s:clipboard = ""
    set clipboard=
    xnoremap Y y:echo 'Yank selection to internal clipboard.'<Cr>
endif
" ------------------------
" special yank
" ------------------------
function! s:yank_border(...) abort
    if a:0 == 0
        let mode = 'word'
    else
        let mode = a:1
    endif
    let original_cursor_position = getpos('.')
    if s:clipboard ==# 'unnamedplus'
        let yank = '"+y'
        let tclip = 'to x11 clipboard.'
    elseif s:clipboard ==# 'unnamed'
        let yank = '"*y'
        let tclip = 'to system clipboard.'
    else
        let yank = 'y'
        let tclip = 'to internal clipboard.'
    endif
    if mode ==# 'file'
        let action = '%'
        let target = 'whole file'
    elseif mode ==# 'line'
        let action = '0v$'
        let target = 'line'
    elseif mode ==# 'from_file_begin'
        let action = 'vgg0o'
        let target = 'from file begin'
    elseif mode ==# 'to_file_end'
        let action = 'vG'
        let target = 'to file end'
    elseif mode ==# 'from_line_begin'
        let action = 'v^'
        let target = 'from line begin'
    elseif mode ==# 'to_line_end'
        let action = 'v$'
        let target = 'to line end'
    else
        let action = 'viw'
        let target = 'word'
    endif
    exec 'normal! ' . action . yank
    call setpos('.', original_cursor_position)
    echo 'Yank ' . target . ' ' . tclip
endfunction
command! YankFile call s:yank_border('file')
command! YankLine call s:yank_border('line')
command! YankFromFileBegin call s:yank_border('from_file_begin')
command! YankToFileEnd call s:yank_border('to_file_end')
command! YankFromLineBegin call s:yank_border('from_line_begin')
command! YankToLineEnd call s:yank_border('to_line_end')
command! YankWord call s:yank_border('word')
nnoremap <silent>yY :YankWord<Cr>
nnoremap <silent><leader>YY :YankFile<Cr>
nnoremap <silent><leader>yy :YankLine<Cr>
if utils#is_vscode()
    nnoremap <silent>Y :YankToLineEnd<Cr>
else
    nnoremap Y y$:echo "Yank to line end to internal register."<Cr>
    nnoremap <silent>;y :YankToLineEnd<Cr>
    nnoremap <silent>,y :YankFromLineBegin<Cr>
    nnoremap <silent><Tab>Y :YankToFileEnd<Cr>
    nnoremap <silent><Tab>y :YankFromFileBegin<Cr>
endif
" ------------------------
" special paste
" ------------------------
nnoremap <expr>gp '`[' . strpart(getregtype(), 0, 1) . '`]'
xnoremap zp "_c<ESC>p"
xnoremap zP "_c<ESC>P"
" --------------------------------------------
" yank command and position to editors
" --------------------------------------------
function! s:yank_position_to_editor(editor) abort
    if index(['code', 'cursor', 'windsurf', 'qoder', 'trae', 'positron', 'zed', 'vim'], a:editor) >= 0
        let editor = a:editor
        let register = (s:clipboard ==# 'unnamedplus') ? '+' : (s:clipboard ==# 'unnamed') ? '*' : ''
    else
        return
    endif
    if editor == 'zed'
        let cmd = printf('zed %s:%d:%d', utils#abs_path(), line("."), col("."))
    elseif editor == 'vim'
        let cmd = printf(' %s | call cursor(%d, %d)', utils#abs_path(), line("."), col("."))
    else
        let cmd = printf('%s --goto %s:%d:%d', editor, utils#abs_path(), line("."), col("."))
    endif
    if register == '+'
        let @+ = cmd
    elseif register == '*'
        let @* = cmd
    else
        let @" = cmd
    endif
    echo '=== Yank current position to ' . editor . ' ==='
endfunction
command! YankPositionToVscode   call s:yank_position_to_editor('code')
command! YankPositionToCursr    call s:yank_position_to_editor('cursor')
command! YankPositionToWindsurf call s:yank_position_to_editor('windsurf')
command! YankPositionToQoder    call s:yank_position_to_editor('qoder')
command! YankPositionToTrae     call s:yank_position_to_editor('trae')
command! YankPositionToPositron call s:yank_position_to_editor('positron')
command! YankPositionToVim      call s:yank_position_to_editor('vim')
command! YankPositionToZed      call s:yank_position_to_editor('zed')
nnoremap <silent><leader>yv :YankPositionToVscode<Cr>
nnoremap <silent><leader>yc :YankPositionToCursr<Cr>
nnoremap <silent><leader>yw :YankPositionToWindsurf<Cr>
nnoremap <silent><leader>yq :YankPositionToQoder<Cr>
nnoremap <silent><leader>yt :YankPositionToTrae<Cr>
nnoremap <silent><leader>yp :YankPositionToPositron<Cr>
nnoremap <silent><leader>ye :YankPositionToVim<Cr>
nnoremap <silent><leader>yz :YankPositionToZed<Cr>
" ------------------------
" open_in_other
" ------------------------
function! s:open_in_other()
    if !has('nvim')
        return
    endif
    if utils#is_vscode() && executable(get(g:, 'open_neovim', ''))
        call VSCodeNotify('copyFilePath')
        let p = fnameescape(@*)
        execute printf('!%s +%d "%s"', g:open_neovim, line('.'), p)
    elseif !utils#is_vscode() && executable(get(g:, 'open_editor', 'code'))
        let editor = get(g:, 'open_editor', 'code')
        silent! exec printf("!%s --goto %s:%d:%d", editor, utils#abs_path(), line("."), col("."))
    else
        echom "Cannot open current file in other editor."
    endif
endfunction
command! OpenInOther call s:open_in_other()
nnoremap <silent><nowait>g<tab> :OpenInOther<Cr>
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
" g:packs
" -----------------------------------------------------------
if filereadable(expand("~/.vimrc.opt"))
    source $HOME/.vimrc.opt
endif
" -------------------------------------------------------------
" unified PlugAdd (local/remote) + PlugAdd shim
" -------------------------------------------------------------
let g:plugs = {}
let g:plug_threads = get(g:, 'plug_threads', 8)
set rtp^=$MAIN_DIR
call plug#begin(utils#expand("$LEOVIMD_DIR/pack/add/opt"))
function! s:plug_add(plugin, ...) abort
    let plugin = substitute(a:plugin, '[\/]\+$', '', 'g')
    let opts = a:0 > 0 ? copy(a:1) : {}

    " immediate load when now>0: skip vim-plug
    if has_key(opts, 'now')
        if get(opts, 'now', 0) && plugin !~ '/'
            let local_dir = ''
            for opt_dir in [$CLONE_OPT_DIR, $FORK_OPT_DIR, $LEO_OPT_DIR]
                let try_dir = utils#expand(opt_dir . '/' . plugin)
                if isdirectory(try_dir)
                    let local_dir = try_dir
                    break
                endif
            endfor
            if local_dir != ''
                execute 'set rtp^=' . fnameescape(local_dir)
                return
            endif
        endif
        call remove(opts, 'now')
    endif

    " derive key name for duplicate check
    if has_key(opts, 'as') && !empty(opts['as'])
        let key_name = tolower(opts['as'])
    elseif plugin =~ '/'
        let parts = split(plugin, '/')
        let key_name = tolower(parts[len(parts)-1])
    else
        let key_name = tolower(plugin)
    endif

    if has_key(g:plugs, key_name)
        return
    endif

    " remote repo path (owner/repo) passes through
    if plugin =~ '/'
        call plug#(plugin, opts)
        return
    endif

    " local opt plugin lookup
    let local_dir = ''
    for opt_dir in [$CLONE_OPT_DIR, $FORK_OPT_DIR, $LEO_OPT_DIR]
        let try_dir = utils#expand(opt_dir . '/' . plugin)
        if isdirectory(try_dir)
            let local_dir = try_dir
            break
        endif
    endfor

    if local_dir != ''
        let opts['dir'] = local_dir
        call plug#(local_dir, opts)
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
noremap <silent><Tab>u :PlugAddUpdate<Cr>
noremap <silent><Tab>i :PlugInstall<Cr>
noremap <silent><Tab>C :PlugClean<Cr>
noremap <silent><Tab>S :PlugStatus<Cr>
noremap <silent><Tab>O :PlugSnapshot<Cr>
noremap <silent><Tab>P :Plug
" vscode or (neo)vim 's differnt config
if utils#is_vscode()
    source $INIT_DIR/vscode.vim
else
    source $MAIN_DIR/main.vim
endif
call plug#end()
" set loaded
let g:leovim_loaded = 1
