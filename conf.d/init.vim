if v:version <= 703 || v:version == 704 && !has('patch399')
    echoe 'vim 7.4.399 is at least required when using leovim.'
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
function! WIN32UNIX()
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
if exists('g:vscode') && !has('nvim-0.10')
    echoe "vscode-neovim required nvim-0.10+!"
    finish
elseif WINDOWS()
    if !has('nvim') && v:version < 900
        echoe "In windows, please update to vim9.0+."
        finish
    elseif has('nvim') && !has('nvim-0.8')
        echoe 'neovim 0.8 is at least required when uing leovim in windows.'
        finish
    endif
endif
" --------------------------
" set dirs
" --------------------------
let $LEOVIM_DIR = expand('~/.leovim')
let $CONF_D_DIR = expand($LEOVIM_DIR . '/conf.d')
let $INSTALL_DIR = expand($CONF_D_DIR . '/install')
let $COMMON_DIR = expand($CONF_D_DIR . '/common')
let $CFG_DIR = expand($CONF_D_DIR . '/cfg')
" opt dirs

let $LEO_OPT_DIR = expand($LEOVIM_DIR . '/pack/leo/opt')
let $FORK_OPT_DIR = expand($LEOVIM_DIR . '/pack/fork/opt')
let $CLONE_OPT_DIR = expand($LEOVIM_DIR . '/pack/clone/opt')
" --------------------------
" set rtp && pack path
" --------------------------
if WINDOWS()
    set rtp^=$LEOVIM_DIR\pack
else
    set rtp^=$LEOVIM_DIR/pack
endif
set rtp^=$COMMON_DIR
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
    set shadafile=$HOME/.vim/shada.main
    lua require('utils')
endif
" ------------------------
" mapleader
" ------------------------
nnoremap M q
nnoremap q <Nop>
let g:mapleader = ' '
let g:maplocalleader = 'q'
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
" ----------------------------
" functions
" ----------------------------
function! Trim(str) abort
    return substitute(a:str, "^\s\+\|\s\+$", "", "g")
endfunction
function! Expand(path, ...) abort
    if a:0 && a:1
        return substitute(fnameescape(expand(a:path)), '\', '/', 'g')
    else
        return fnameescape(expand(a:path))
    endif
endfunction
function! Execute(cmd)
    if exists("*execute")
        return execute(a:cmd)
    else
        redir => output
        silent! execute a:cmd
        redir END
        return output
    endif
endfunction
function! StringToFloat(str, ...) abort
    let str = a:str
    if a:0 == 0
        let digit = 1
    else
        let digit = a:1
    endif
    let lst = split(str, "\\.")
    if len(lst)
        let rst = []
        for each in lst[1:]
            if len(each) >= digit
                let e = each[:digit]
            else
                let e = repeat('0', digit - len(each)) . each
            endif
            call add(rst, e)
        endfor
        return str2float(lst[0] . '.' . join(rst, ''))
    else
        return str2float(str)
    endif
endfunction
" trip last space
function! TripTrailingWhiteSpace() abort
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
augroup TripSpaces
    autocmd FileType vim,c,cpp,java,go,php,javascript,typescript,python,rust,twig,xml,yml,perl,sql,r,conf,lua
                \ autocmd! BufWritePre <buffer> :call TripTrailingWhiteSpace()
augroup END
nnoremap <silent>d<space> :call TripTrailingWhiteSpace()<Cr>
" enhance escape
function! Escape(param)
    return substitute(escape(a:param, '/\.*$^~[#'), '\n', '\\n', 'g')
endfunction
xnoremap / "yy/<C-r>=Escape(@y)<CR><Cr>
xnoremap ? "yy?<C-r>=Escape(@y)<CR><Cr>
xnoremap s "yy:%s/<C-r>=Escape(@y)<CR>/<C-r>=Escape(@y)<CR>/gc<Left><Left><Left>
xnoremap <Cr> "yy:%s/<C-r>=Escape(@y)<CR>//gc<Left><Left><Left>
" GetVisualSelection only in one line
function! GetVisualSelection(...) abort
    " call with visualmode() as the argument
    let [line_start, column_start] = [line("'<"), charcol("'<")]
    let [line_end, column_end]     = [line("'>"), charcol("'>")]
    let lines = getline(line_start, line_end)
    if len(lines) != 1
        return ""
    endif
    let inclusive = (&selection == 'inclusive')? 1 : 2
    " Must trim the end before the start, the begin will shift left.
    let lines[-1] = list2str(str2list(lines[-1])[:column_end - inclusive])
    let lines[0] = list2str(str2list(lines[0])[column_start - 1:])
    if a:0 && a:1
        return Escape(join(lines, "\n"))
    else
        return join(lines, "\n")
    endif
endfunction
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
nnoremap zt z<CR>
" bs tab
nnoremap <Bs> :set nohlsearch? nohlsearch!<Cr>
nnoremap <C-m> <C-i>
nnoremap <Cr> <C-i>
nnoremap gb 2g;I
" ------------------------
" case change
" ------------------------
nnoremap ZU m1gUiw`1
nnoremap ZD m1guiw`1
" ------------------------
" home end
" ------------------------
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
function! MoveToEndAndAddSemicolon() abort
    execute "normal! :s/\\s\\+$//e\\r"
    normal! g_
    if index(['c', 'cpp', 'csharp', 'rust', 'java', 'perl', 'php', 'javascript', 'typescript', 'go', 'r'], &ft) >= 0
        if index([';', '{', '}'], getline('.')[col('.') - 1]) >= 0
            normal! a
        else
            normal! a;
        endif
    else
        normal! a
    endif
endfunction
inoremap <silent><C-j> <C-\><C-n>:call MoveToEndAndAddSemicolon()<CR>
" ------------------------
" select and search
" ------------------------
function! VIW()
    set iskeyword-=_ iskeyword-=#
    call timer_start(300, {-> execute("set iskeyword+=_  iskeyword+=#")})
    call feedkeys("viwo",'n')
endfunction
nnoremap SS :call VIW()<Cr>
" ------------------------------
" load pack in OPT_DIR
" ------------------------------
function! s:plug_add_opt(pack)
    let pack = a:pack
    if exists(':packadd')
        execute "packadd " . pack
    else
        for opt_dir in [$CLONE_OPT_DIR, $FORK_OPT_DIR, $LEO_OPT_DIR]
            let added = 0
            let dir = expand(opt_dir . "/" . pack)
            let after = expand(opt_dir . "/" . pack . "/after")
            if isdirectory(dir)
                execute "set rtp^=" . dir
                let added = 1
            endif
            if isdirectory(after)
                execute "set rtp+=" . after
            endif
            if added
                break
            endif
        endfor
    endif
    let g:leovim_installed[tolower(pack)] = 1
endfunction
command! -nargs=+ PlugAddOpt call <sid>plug_add_opt(<args>)
" ------------------------------
" intergrated packs
" ------------------------------
PlugAddOpt 'vim-eunuch'
" ------------------------------
" conflict marker
" ------------------------------
let g:conflict_marker_enable_mappings = 0
PlugAddOpt 'conflict-marker.vim'
nnoremap <leader>ct :ConflictMarkerThemselves<Cr>
nnoremap <leader>co :ConflictMarkerOurselves<Cr>
nnoremap <leader>cN :ConflictMarkerNone<Cr>
nnoremap <leader>cB :ConflictMarkerBoth<Cr>
nnoremap <leader>c; :ConflictMarkerNextHunk<Cr>
nnoremap <leader>c, :ConflictMarkerPrevHunk<Cr>
" ------------------------------
" nerdcommenter
" ------------------------------
nnoremap <silent><leader>c} V}:call nerdcommenter#Comment('x', 'toggle')<CR>
nnoremap <silent><leader>c{ V{:call nerdcommenter#Comment('x', 'toggle')<CR>
" Create default mappings
let g:NERDCreateDefaultMappings = 1
" Add space after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1
PlugAddOpt 'nerdcommenter'
" ------------------------
" surround
" ------------------------
nmap SW viw<Plug>VSurround
nmap SL v$<Plug>VSurround
nmap SH v^<Plug>VSurround
nnoremap S) va)hol
nnoremap S} va}hol
nnoremap S] va]hol
" --------------------------
" textobj
" --------------------------
for s:v in ['', 'v', 'V', '<c-v>']
    execute 'omap <expr>' s:v.'I%' "(v:count?'':'1').'".s:v."i%'"
    execute 'omap <expr>' s:v.'A%' "(v:count?'':'1').'".s:v."a%'"
endfor
if exists('*search') && exists('*getpos')
    " -------------------
    " textobj
    " -------------------
    PlugAddOpt 'vim-textobj-user'
    PlugAddOpt 'vim-textobj-uri'
    PlugAddOpt 'vim-textobj-line'
    PlugAddOpt 'vim-textobj-syntax'
    PlugAddOpt 'vim-textobj-function'
    nmap <leader>vf vafo
    nmap <leader>vF vifo
    nmap <leader>vc vaco
    nmap <leader>vC vico
    nmap <leader>vu viu
    nmap <leader>vU vau
    nmap <leader>vb vib
    nmap <leader>vB vaB
    nmap <leader>vn vin
    nmap <leader>vN vaN
    " find line
    call textobj#user#plugin('line', {
                \   '-': {
                \     'select-a-function': 'CurrentLineA',
                \     'select-a': 'ak',
                \     'select-i-function': 'CurrentLineI',
                \     'select-i': 'ik',
                \   },
                \ })
    function! CurrentLineA()
        normal! ^
        let head_pos = getpos('.')
        normal! $
        let tail_pos = getpos('.')
        return ['v', head_pos, tail_pos]
    endfunction
    function! CurrentLineI()
        normal! ^
        let head_pos = getpos('.')
        normal! g_
        let tail_pos = getpos('.')
        let non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
        return
                    \ non_blank_char_exists_p
                    \ ? ['v', head_pos, tail_pos]
                    \ : 0
    endfunction
    vnoremap ik ^o$h
    onoremap ik :normal vik<Cr>
    vnoremap ak ^o$
    onoremap ak :normal vak<Cr>
    nmap <leader>vk vik
    nmap <leader>vK vak
    " find block
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
    function! BlockA()
        let beginline = search(s:block_str, 'ebW')
        if beginline == 0
            normal! gg
        endif
        let head_pos = getpos('.')
        let endline  = search(s:block_str, 'eW')
        if endline == 0
            normal! G
        endif
        let tail_pos = getpos('.')
        return ['V', head_pos, tail_pos]
    endfunction
    function! BlockI()
        let beginline = search(s:block_str, 'ebW')
        if beginline == 0
            normal! gg
            let beginline = 1
        else
            normal! j
        endif
        let head_pos = getpos('.')
        let endline = search(s:block_str, 'eW')
        if endline == 0
            normal! G
        elseif endline > beginline
            normal! k
        endif
        let tail_pos = getpos('.')
        return ['V', head_pos, tail_pos]
    endfunction
    " select a block
    call textobj#user#plugin('block', {
                \ 'block': {
                \  'select-a-function': 'BlockA',
                \  'select-a': 'av',
                \  'select-i-function': 'BlockI',
                \  'select-i': 'iv',
                \  'region-type': 'V'
                \ },
                \ })
    nmap <leader>vv viv
    nmap <leader>vV vav
    " -------------------
    " indent textobj
    " -------------------
    let g:vindent_motion_OO_prev   = ',i' " jump to prev block of same indent.
    let g:vindent_motion_OO_next   = ';i' " jump to next block of same indent.
    let g:vindent_motion_more_prev = ',=' " jump to prev line with more indent.
    let g:vindent_motion_more_next = ';=' " jump to next line with more indent.
    let g:vindent_motion_less_prev = ',-' " jump to prev line with less indent.
    let g:vindent_motion_less_next = ';-' " jump to next line with less indent.
    let g:vindent_motion_diff_prev = ',I' " jump to prev line with different indent.
    let g:vindent_motion_diff_next = ';I' " jump to next line with different indent.
    let g:vindent_motion_XX_ss     = ',p' " jump to start of the current block scope.
    let g:vindent_motion_XX_se     = ';p' " jump to end   of the current block scope.
    let g:vindent_object_XX_ii     = 'ii' " select current block.
    let g:vindent_object_XX_ai     = 'ai' " select current block + one extra line  at beginning.
    let g:vindent_object_XX_aI     = 'aI' " select current block + two extra lines at beginning and end.
    let g:vindent_jumps            = 1    " make vindent motion count as a |jump-motion| (works with |jumplist|).
    PlugAddOpt 'vindent.vim'
    " -------------------
    " targets.vim
    " -------------------
    PlugAddOpt 'targets.vim'
    nmap <leader>vt vit
    nmap <leader>vT vat
    nmap <leader>va via
    nmap <leader>vA vaa
    nmap <leader>vl vil
    nmap <leader>vL val
    nmap <leader>vn vin
    nmap <leader>vN vaN
    nmap <leader>Vt vIt
    nmap <leader>VT vAt
    nmap <leader>Va vIa
    nmap <leader>VA vAa
    nmap <leader>Vl vIl
    nmap <leader>VL vAl
    nmap <leader>Vn vIn
    nmap <leader>VN vAN
    " -------------------
    " sandwich
    " -------------------
    PlugAddOpt 'vim-sandwich'
    xmap is <Plug>(textobj-sandwich-auto-i)
    xmap as <Plug>(textobj-sandwich-auto-a)
    omap is <Plug>(textobj-sandwich-auto-i)
    omap as <Plug>(textobj-sandwich-auto-a)
    xmap iq <Plug>(textobj-sandwich-query-i)
    xmap aq <Plug>(textobj-sandwich-query-a)
    omap iq <Plug>(textobj-sandwich-query-i)
    omap aq <Plug>(textobj-sandwich-query-a)
    nmap <leader>vs vis
    nmap <leader>vS vas
    nmap <leader>vq viq
    nmap <leader>vQ vaq
endif
" ----------------------------------
" hl searchindex && multi replace
" ----------------------------------
if has('nvim')
    PlugAddOpt 'nvim-hlslens'
    lua require('hlslens').setup()
    nnoremap <silent><nowait>n <Cmd>execute('normal! ' . v:count1 . 'n')<Cr><Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>N <Cmd>execute('normal! ' . v:count1 . 'N')<Cr><Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>* *``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait># #``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>g* g*``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait>g# g#``<Cmd>lua require('hlslens').start()<Cr>
    nnoremap <silent><nowait><C-n> *``<Cmd>lua require('hlslens').start()<Cr>cgn
else
    PlugAddOpt 'vim-searchindex'
    nnoremap <silent><nowait>* *``
    nnoremap <silent><nowait># #``
    nnoremap <silent><nowait>g* g*``
    nnoremap <silent><nowait>g# g#``
    nnoremap <silent><nowait><C-n> *``cgn
endif
function! EnhancedSearch() range
    let l:saved_reg = @"
    execute 'normal! vgvy'
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
xnoremap <silent><C-n> :<C-u>call EnhancedSearch()<Cr>/<C-R>=@/<Cr><Cr>gvc
" ------------------------------------
" clipboard
" ------------------------------------
" Copy file path
nnoremap <leader>YP :let @"=AbsPath()<cr>:echo '-= File path copied=-'<Cr>
" Copy file dir
nnoremap <leader>YD :let @"=AbsDir()<cr>:echo '-= File path copied=-'<Cr>
" Copy file name
nnoremap <leader>YF :let @"=FileName()<cr>:echo '-= File name copied=-'<Cr>
" Copy bookmark position reference
nnoremap <leader>YM :let @"=AbsPath().':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark copied=-'<cr>'
if has('clipboard')
    if LINUX() && (exists('g:vscode') || exists('$TMUX'))
        let s:clipboard = 'unnamedplus'
        if exists('g:vscode')
            set clipboard=unnamedplus
        else
            set clipboard=
        endif
        xnoremap Y "+y:echo 'Yank selection to x11 clipboard.'<Cr>
        nnoremap <leader>yp :let @+=AbsPath()<cr>:echo '-= File path copied to x11 clipboard=-'<Cr>
        nnoremap <leader>yd :let @+=AbsDir()<cr>:echo '-= File dir copied to x11 clipboard=-'<Cr>
        nnoremap <leader>yf :let @+=FileName()<cr>:echo '-= File name copied to x11 clipboard=-'<Cr>
        nnoremap <leader>ym :let @+=AbsPath().':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark copied to x11 clipboard=-'<cr>'
    else
        let s:clipboard = 'unnamed'
        if exists('g:vscode')
            set clipboard=unnamed
        else
            set clipboard=
        endif
        xnoremap Y "*y:echo 'Yank selection to system clipboard.'<Cr>
        nnoremap <leader>yp :let @*=AbsPath()<cr>:echo '-= File path copied to system clipboard=-'<Cr>
        nnoremap <leader>yd :let @*=AbsDir()<cr>:echo '-= File dir copied to system clipboard=-'<Cr>
        nnoremap <leader>yf :let @*=FileName()<cr>:echo '-= File name copied to system clipboard=-'<Cr>
        nnoremap <leader>ym :let @*=AbsPath().':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark copied to system clipboard=-'<cr>'
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
    if a:0
        let yankmode = a:1
    else
        let yankmode = 0
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
    if yankmode == 6
        let action = '%'
        let target = ' whole file'
    elseif yankmode == 5
        let action = '0v$'
        let target = 'line'
    elseif yankmode == 4
        let action = 'vgg0o'
        let target = 'from file begin'
    elseif yankmode == 3
        let action = 'vG'
        let target = 'to file end'
    elseif yankmode == 2
        let action = 'v^'
        let target = 'from line begin'
    elseif yankmode == 1
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
command! YankFile call s:yank_border(6)
command! YankLine call s:yank_border(5)
command! YankFromFileBegin call s:yank_border(4)
command! YankToFileEnd call s:yank_border(3)
command! YankFromLineBegin call s:yank_border(2)
command! YankToLineEnd call s:yank_border(1)
command! YankWord call s:yank_border()
nnoremap <silent>gY :YankWord<Cr>
nnoremap <silent>yY :YankFile<Cr>
nnoremap <silent><leader>yy :YankLine<Cr>
if exists('g:vscode')
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
" ------------------------
" quick jump in buffer
" ------------------------
nnoremap ; <Nop>
nnoremap , <Nop>
let g:EasyMotion_key = "123456789asdghklqwertyuiopzxcvbnmfj,;"
if has('nvim-0.8')
    PlugAddOpt 'flash.nvim'
    lua require("cfg/flash")
    nmap SJ vt<Space><Cr>S
    nmap SK vT<Space><Cr>S
else
    let g:clever_f_smart_case = 1
    let g:clever_f_repeat_last_char_inputs = ['<Tab>']
    PlugAddOpt 'clever-f.vim'
    nmap ;s <Plug>(clever-f-repeat-forward)
    xmap ;s <Plug>(clever-f-repeat-forward)
    nmap ,s <Plug>(clever-f-repeat-back)
    xmap ,s <Plug>(clever-f-repeat-back)
    nmap SJ vt<Space>S
    nmap SK vT<Space>S
endif
if exists('g:vscode')
    imap <C-a> <ESC>ggVG
    xmap <C-a> <ESC>ggVG
    nmap <C-a> ggVG
    imap <C-x> <C-o>"*
    xmap <C-x> "*x
    nmap <C-x> "*x
    PlugAddOpt 'hop.nvim'
    lua require("cfg/hop")
else
    imap <expr><C-a> pumvisible()? "\<C-a>":"\<C-o>0"
    source $CFG_DIR/easymotion.vim
endif
" ------------------------
" set optional
" ------------------------
if filereadable(expand("~/.vimrc.opt"))
    source $HOME/.vimrc.opt
endif
" ------------------------
" open_in_other
" ------------------------
function! s:open_in_other()
    if !has('nvim')
        return
    endif
    if exists('g:vscode') && executable(get(g:, 'open_neovim', ''))
        call VSCodeNotify('copyFilePath')
        let p = fnameescape(@*)
        execute printf('!%s +%d "%s"', g:open_neovim, line('.'), p)
    elseif !exists('g:vscode') && executable(get(g:, 'open_editor', 'code'))
        let editor = get(g:, 'open_editor', 'code')
        silent! exec printf("!%s --goto %s:%d", editor, Expand("%:p"), line("."))
    else
        echom "Cannot open current file in other editor."
    endif
endfunction
command! OpenInOther call s:open_in_other()
nnoremap <silent><nowait>gc :OpenInOther<Cr>
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
    if executable(get(g:, 'open_edior', 'code'))
        let editor = get(g:, 'open_edior', 'code') . ' --goto'
    else
        echom "Neither URL nor file found, and no editor executable"
        return
    endif
    " location 0: file, 1: row, 2: column
    let location = s:get_cursor_pos(a:text, a:col)
    if location[0] != '' && filereadable(location[0])
        if location[1] != ''
            if location[2] != ''
                exec "!" . editor . " " . location[0] . ":" . str2nr(location[1]) . ":" . str2nr(location[2])
            else
                exec "!" . editor . " " . location[0] . ":" . str2nr(location[1])
            endif
        else
            exec "!" . editor . " " . location[0]
        endif
    else
        echo "Neigher URL nor file path under cursor."
    endif
endfunction
command! OpenLink call s:open_link_in_editor(getline("."), col("."))
nnoremap <silent>gx :OpenLink<cr>
" --------------------------------------------
" vscode or (neo)vim 's differnt config
" --------------------------------------------
if exists('g:vscode')
    source $CFG_DIR/vscode.vim
else
    source $CFG_DIR/main.vim
endif
let g:leovim_loaded = 1
