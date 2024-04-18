" -----------------
" functions
" -----------------
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
function! GetVisualSelection() abort
	" call with visualmode() as the argument
	let [line_start, column_start] = [line("'<"), charcol("'<")]
	let [line_end, column_end]     = [line("'>"), charcol("'>")]
	let lines = getline(line_start, line_end)
    if len(lines) != 1
        return ""
    endif
	let inclusive = (&selection == 'inclusive')? 1 : 2
		" Must trim the end before the start, the beginning will shift left.
    let lines[-1] = list2str(str2list(lines[-1])[:column_end - inclusive])
    let lines[0] = list2str(str2list(lines[0])[column_start - 1:])
	return join(lines, "\n")
endfunction
" -----------------------------------
" filetypes definition
" -----------------------------------
let g:c_filetypes = get(g:, 'c_filetypes', ["c", "cpp", "objc", "objcpp", "cuda"])
let g:web_filetypes = get(g:, 'web_filetypes', ['php', 'html', 'css', 'scss', 'wxss', 'wxml', 'xml', 'toml', 'javascript', 'typescript', 'vue'])
let g:highlight_filetypes = get(g:, 'highlight_filetypes', ['python', 'r', 'lua', 'vim', 'vimdoc', 'markdown'])
" -----------------------------------
" pattern
" -----------------------------------
let g:todo_patterns = "(TODO|FIXME|WARN|ERROR|BUG)"
let g:note_patterns = "(NOTE|XXX|HINT|STEP|ETC|In\\[\\d\*\\])"
let g:root_patterns = get(g:, 'root_patterns', [".git", ".hg", ".svn", ".root", ".env", ".vscode", '.idea', ".ccls", ".project", ".next"])
let g:root_files = get(g:, 'root_files', [".task", "tsconfig.js", "Cargo.toml"])
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
map <C-q> <Nop>
map <C-s> <Nop>
map <C-i> <Nop>
map <C-z> <Nop>
nnoremap gx <Nop>
xnoremap gx <Nop>
nnoremap s <Nop>
nnoremap S <Nop>
nnoremap , <Nop>
xnoremap , <Nop>
nnoremap - <Nop>
nnoremap = <Nop>
nnoremap _ <Nop>
nnoremap + <Nop>
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
" ------------------------
" select and search
" ------------------------
function! VIW()
    set iskeyword-=_ iskeyword-=#
    call timer_start(300, {-> execute("set iskeyword+=_  iskeyword+=#")})
    call feedkeys("viwo",'n')
endfunction
nnoremap SS :call VIW()<Cr>
" ------------------------
" surround
" ------------------------
nmap SW viw<Plug>VSurround
nmap SL v$<Plug>VSurround
nmap SH v^<Plug>VSurround
nmap SJ vt<Space><Plug>VSurround
nmap SK vT<Space><Plug>VSurround
nnoremap S) va)hol
nnoremap S} va}hol
nnoremap S] va]hol
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
imap <expr><C-a> pumvisible()? "\<C-a>":"\<C-o>0"
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
" yank
" ------------------------
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
xnoremap zp "_c<ESC>p"
xnoremap zP "_c<ESC>P"
if exists("##ModeChanged")
    au ModeChanged *:s set clipboard=
    au ModeChanged s:* set clipboard=unnamedplus
endif
" ------------------------------
" load pack in OPT_DIR
" ------------------------------
if exists(':packadd') && !exists('g:vscode')
    set packpath^=$HOME/.leovim.d
endif
function! s:plug_add_opt(pack)
    let pack = a:pack
    if exists(':packadd')
        execute "packadd " . pack
    else
        for opt_path in [$CLONE_OPT_DIR, $FORK_OPT_DIR, $LEO_OPT_DIR]
            let added = 0
            let dir = expand(opt_path . "/" . pack)
            let after = expand(opt_path . "/" . pack . "/after")
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
nnoremap <leader>c; :ConflictMarkerNextHunk<Cr>
nnoremap <leader>c, :ConflictMarkerPrevHunk<Cr>
nnoremap <leader>c/ /\v^[<\|=>]{7}( .*\|$)<CR>
nnoremap <leader>c? ?\v^[<\|=>]{7}( .*\|$)<CR>
nnoremap <leader>cN :ConflictMarkerNone<Cr>
nnoremap <leader>cB :ConflictMarkerBoth<Cr>
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
" quick jump in buffer
" ------------------------
let g:EasyMotion_key = "123456789asdghklqwertyuiopzxcvbnmfj,;"
if has('nvim-0.8')
    PlugAddOpt 'flash.nvim'
    luafile $LUA_DIR/flash.lua
else
    let g:clever_f_smart_case = 1
    let g:clever_f_repeat_last_char_inputs = ['<Tab>']
    nmap ; <Plug>(clever-f-repeat-forward)
    xmap ; <Plug>(clever-f-repeat-forward)
    nmap ,, <Plug>(clever-f-repeat-back)
    xmap ,, <Plug>(clever-f-repeat-back)
    PlugAddOpt 'clever-f.vim'
endif
if exists('g:vscode')
    PlugAddOpt 'hop.nvim'
    luafile $LUA_DIR/hop.lua
else
    PlugAddOpt 'vim-easymotion'
    PlugAddOpt 'vim-easymotion-chs'
    source $OPTIONAL_DIR/easymotion.vim
endif
" --------------------------
" textobj
" --------------------------
for s:v in ['', 'v', 'V', '<c-v>']
    execute 'omap <expr>' s:v.'I%' "(v:count?'':'1').'".s:v."i%'"
    execute 'omap <expr>' s:v.'A%' "(v:count?'':'1').'".s:v."a%'"
endfor
if exists('*search') && exists('*getpos')
    PlugAddOpt 'vim-textobj-user'
    PlugAddOpt 'vim-textobj-function'
    PlugAddOpt 'vim-textobj-syntax'
    PlugAddOpt 'vim-textobj-uri'
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
    " goto first/last indent
    nmap <leader>vi viio
    nmap <leader>vI vaio
    noautocmd nmap <silent>si viio<C-[>^
    noautocmd nmap <silent>sg vii<C-[>^
    " targets.vim
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
    " line yank enhanced
    vnoremap ik ^o$h
    onoremap ik :normal vik<Cr>
    vnoremap ak ^o$
    onoremap ak :normal vak<Cr>
    nmap <leader>vk vik
    nmap <leader>vK vak
    vnoremap iK 0o$h
    onoremap iK :normal viK<Cr>
    vnoremap aK 0o$
    onoremap aK :normal vaK<Cr>
    nmap <leader>Vk viK
    nmap <leader>VK vaK
    " --------------------------
    " sandwich
    " --------------------------
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
    " ------------------------
    " find block
    " ------------------------
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
endif
" ----------------------------------
" hl searchindex && multi replace
" ----------------------------------
nnoremap gb 2g;I
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
" ------------------------
" after
" ------------------------
if WINDOWS()
    set rtp+=$BOOSTUP_DIR\\after
else
    set rtp+=$BOOSTUP_DIR/after
endif
" ------------------------
" set optinal
" ------------------------
if filereadable(expand("~/.vimrc.opt"))
    source $HOME/.vimrc.opt
endif
if exists('g:vscode')
    source $INIT_DIR/vscode.vim
    finish
endif
" ============================================ below is (neo)vim only ===============================================
let &termencoding=&enc
let s:vscode_dir = substitute(fnameescape(get(g:, "vscode_keybindings_dir", "")), '/', '\', 'g')
let s:cursor_dir = substitute(fnameescape(get(g:, "cursor_keybindings_dir", "")), '/', '\', 'g')
if isdirectory(s:vscode_dir) || isdirectory(s:cursor_dir)
    function! s:link_keybindings() abort
        for dir in [s:vscode_dir, s:cursor_dir]
            if !isdirectory(dir)
                continue
            endif
            if WINDOWS()
                let delete_cmd = printf('!del /Q /S %s\keybindings.json', dir)
                execute(delete_cmd)
                let template = '!mklink %s %s'
                let cmd = printf(template, dir . '\keybindings.json', $INIT_DIR . '\keybindings.json')
            else
                let template = '!ln -sf %s %s'
                let cmd = printf(template, $INIT_DIR . '/keybindings.json', dir)
            endif
            execute(cmd)
        endfor
    endfunction
    command! LinkKeyBindings call s:link_keybindings()
    nnoremap <M-h>K :LinkKeyBindings<Cr>
endif
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
endfunc
function! s:open_file_in_editor(editor, text, col)
    let location = s:get_cursor_pos(a:text, a:col)
    if a:editor == 'code'
        let editor = 'code --goto'
    else
        let editor = a:editor
    endif
    " location 0: file, 1: row, 2: column
    if location[0] != ''
        if location[1] != ''
            if location[2] != ''
                if editor =~ 'code'
                    let command = editor . " " . location[0] . ":" . str2nr(location[1]) . ":" . str2nr(location[2])
                else
                    let command = editor . " --column " . str2nr(location[2]) . " " . location[0] . ":" . str2nr(location[1])
                endif
                if Installed('asyncrun.vim')
                    exec "AsyncRun -silent " . command
                else
                    exec "! " . command
                endif
            else
                let command = editor . " " . location[0] . ":" . str2nr(location[1])
                if Installed('asyncrun.vim')
                    exec "AsyncRun -silent " . command
                else
                    exec "! " . command
                endif
            endif
        else
            let command = editor . " " . location[0]
            if Installed('asyncrun.vim')
                exec "AsyncRun -silent " . command
            else
                exec "! " . command
            endif
        endif
    else
        echo "Not a valid file path"
    endif
endfunc
if executable('code')
    function! s:open_in_vscode()
        if Installed('asyncrun.vim')
            let cmd = printf("AsyncRun code --goto %s:%d", expand("%:p"), line("."))
        else
            let cmd = printf("!code --goto %s:%d", expand("%:p"), line("."))
        endif
        silent! exec cmd
    endfunction
    command! OpenInVSCode call s:open_in_vscode()
    nnoremap <silent><M-j>o :OpenInVSCode<Cr>
    " NOTE: open file under line in vscode
    command! OpenFileLinkInVSCode call s:open_file_in_editor("code", getline("."), col("."))
    nnoremap <silent><M-j>f :OpenFileLinkInVSCode<cr>
endif
" ------------------------------------
" <M-Key> map to <Nop> if need
" ------------------------------------
let s:metacode_group = ["'", ",", ".", ";", ":", "/", "?", "{", "}", "-", "_", "=", "+"]
if !exists("g:vscode") && (has('nvim') || HAS_GUI())
    function! s:map_metacode_nop(key)
        exec "map <M-".a:key."> <Nop>"
    endfunction
    for c in s:metacode_group
        call s:map_metacode_nop(c)
    endfor
endif
for i in range(26)
    " 65 is ascii of A
    call add(s:metacode_group, nr2char(65 + i))
    " 97 is ascii of a
    call add(s:metacode_group, nr2char(97 + i))
endfor
for i in range(10)
    " 48 is ascii of 0
    call add(s:metacode_group, nr2char(48 + i))
endfor
nnoremap <C-m> <Tab>
nnoremap gQ gw
xnoremap gQ gw
nnoremap <M-A> ggVG
" remap for cusor move insert mode
inoremap <M-l> <Right>
inoremap <M-h> <Left>
inoremap <M-j> <Down>
inoremap <M-k> <Up>
" save
nnoremap <M-s> :w!<Cr>
onoremap <M-s> :w!<Cr>
cnoremap <M-s> w!<Cr>
inoremap <M-s> <C-o>:w!<Cr>
xnoremap <M-s> <ESC>:w!<Cr>
nnoremap <M-S> :wa!<Cr>
cnoremap <M-S> wa!<Cr>
inoremap <M-S> <C-o>:wa!<Cr>
xnoremap <M-S> <ESC>:wa!<Cr>
" buffers mark messages
nnoremap <leader>b :ls<Cr>:b<Space>
nnoremap <leader><leader> <C-^>
" map to <esc>
inoremap <M-q> <ESC>
xnoremap <M-q> <ESC>
cnoremap <M-q> <ESC>
inoremap <M-w> <ESC>
xnoremap <M-w> <ESC>
cnoremap <M-w> <ESC>
" ----------------------------
" functions
" ----------------------------
function! Trim(str) abort
    return substitute(a:str, "^\s\+\|\s\+$", "", "g")
endfunction
function! Expand(path, ...) abort
    if a:0 && a:1 == 0
        return substitute(expand(a:path), '\', '/', 'g')
    else
        return substitute(fnameescape(expand(a:path)), '\', '/', 'g')
    endif
endfunction
function! FileDir(file) abort
    return Expand(fnamemodify(a:file , ':p:h'))
endfunction
function! FilePath(file) abort
    return Expand(fnamemodify(a:file , ':h'))
endfunction
function! FileReadonly()
    return &readonly && &filetype !=# 'help' ? 'RO' : ''
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
function! GetRootDir(...)
    let init_dir = Expand('%:p:h')
    let curr_dir = init_dir
    while 1
        if WINDOWS() && curr_dir[-2:-1] == ':/' || UNIX() && curr_dir ==# '/'
            return init_dir
        endif
        for each in g:root_patterns + g:root_files
            let chk_path = curr_dir . '/' . each
            if isdirectory(chk_path) || filereadable(chk_path)
                if a:0 && a:1 > 0
                    return substitute(curr_dir, '/', '\', 'g')
                else
                    return curr_dir
                endif
            endif
        endfor
        let curr_dir = fnamemodify(curr_dir, ":h")
    endwhile
endfunction
nnoremap <M-h>R :echo GetRootDir()<Cr>
" --------------------------
" python_support
" --------------------------
function! s:get_python_path()
    let python = ""
    try
        if executable('python')
            let python = exepath('python')
        elseif executable('python3')
            let python = exepath('python3')
        elseif executable('python2')
            let python = exepath('python2')
        endif
        return python
    catch
        return ""
    endtry
endfunction
if has('nvim')
    let g:python3_host_prog = get(g:, 'python3_host_prog', s:get_python_path())
endif
function! s:get_python_version()
    if CYGWIN()
        return 0
    endif
    try
        let py_version = Execute('py3 print(sys.version)')
    catch /.*/
        try
            let py_version = Execute('py print(sys.version)')
        catch /.*/
            return 0
        endtry
    endtry
    let pyx_version_raw = matchstr(py_version, '\v\zs\d{1,}.\d{1,}.\d{1,}\ze')
    if pyx_version_raw == ''
        return 0
    endif
    let pyx_version = StringToFloat(pyx_version_raw, 2)
    if pyx_version > 3
        try
            execute("py3 import pygments")
            let g:pygments_import = get(g:, 'pygments_import', 1)
        catch /.*/
            let g:pygments_import = get(g:, 'pygments_import', 0)
        endtry
        if !has('nvim')
            let g:python3_host_prog = Trim(Execute('py3 print(sys.executable.strip())'))
        endif
    endif
    return pyx_version
endfunction
let g:python_version = s:get_python_version()
let g:python_path = s:get_python_path()
" --------------------------
" has_terminal
" --------------------------
if exists(':tnoremap')
    if has('patch-8.1.1')
        set termwinkey=<C-_>
        let g:has_terminal = 2
    else
        let g:has_terminal = 1
    endif
else
    let g:has_terminal = 0
endif
if has("popupwin") || exists('*nvim_open_win')
    let g:has_popup_floating = 1
else
    let g:has_popup_floating = 0
endif
" ------------------------
" has_truecolor
" ------------------------
if has('termguicolors') || WINDOWS() || HAS_GUI()
    try
        set termguicolors
        hi LineNr ctermbg=NONE guibg=NONE
        if !has('nvim')
            let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
            let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        endif
        let g:has_truecolor = 1
        nnoremap <M-k>g :set notermguicolors! notermguicolors?<Cr>
    catch
        let g:has_truecolor = 0
    endtry
else
    let g:has_truecolor = 0
endif
" -----------------------------------
" git version
" -----------------------------------
if executable('git')
    let s:git_version_raw = matchstr(system('git --version'), '\v\zs\d{1,4}.\d{1,4}.\d{1,4}\ze')
    let g:git_version = StringToFloat(s:git_version_raw)
else
    let g:git_version = 0
endif
" ------------------------------
" node install tool
" ------------------------------
if executable('node') && executable('npm')
    let s:node_version_raw = matchstr(system('node --version'), '\vv\zs\d{1,4}.\d{1,4}\ze')
    let g:node_version = StringToFloat(s:node_version_raw)
else
    let g:node_version = 0
endif
" --------------------------
" set PATH && term
" --------------------------
if WINDOWS()
    if get(g:,'leovim_loaded',0) == 0
        if isdirectory($HOME . "\\.leovim.windows")
            let $PATH = $HOME . "\\.leovim.windows\\cppcheck;" . $PATH
            let $PATH = $HOME . "\\.leovim.windows\\gtags\\bin;" . $PATH
            let $PATH = $HOME . "\\.leovim.windows\\tools;" . $PATH
        endif
    endif
    set winaltkeys=no
    if HAS_GUI()
        set lines=999
        set columns=999
    endif
    if has('libcall') && !has('nvim') && HAS_GUI()
        let g:gvimfullscreendll = $HOME ."\\.leovim.windows\\tools\\gvimfullscreen.dll"
        function! ToggleFullScreen()
            call libcallnr(g:gvimfullscreendll, "ToggleFullScreen", -1)
        endfunction
        nnoremap <C-cr> <ESC>:call ToggleFullScreen()<Cr>
        let g:VimAlpha = 255
        function! SetAlpha(alpha)
            let g:VimAlpha = g:VimAlpha + a:alpha
            if g:VimAlpha < 95
                let g:VimAlpha = 95
            endif
            if g:VimAlpha > 255
                let g:VimAlpha = 255
            endif
            call libcall(g:gvimfullscreendll, 'SetAlpha', g:VimAlpha)
        endfunction
        nnoremap <silent><M-\>  :call SetAlpha(5)<Cr>
        nnoremap <silent><M-\|> :call SetAlpha(-5)<Cr>
    endif
else
    if get(g:, 'leovim_loaded', 0) == 0 && isdirectory($HOME . "/.leovim.unix")
        if LINUX()
            let $PATH = $HOME . "/.leovim.unix/linux:" . $PATH
        elseif MACOS()
            let $PATH = $HOME . "/.leovim.unix/macos:" . $PATH
        endif
    endif
    " --------------------------
    " terminal comparability
    " --------------------------
    set t_ut=
    if exists('+t_TI') && exists('+t_TE')
        let &t_TI = ''
        let &t_TE = ''
    endif
    if exists('+t_RS') && exists('+t_SH')
        let &t_RS = ''
        let &t_SH = ''
    endif
    if has('nvim') && $TMUX != ''
        let $TERM = "xterm-256color"
    elseif HAS_GUI() == 0 && !has('nvim')
        if $TMUX != ''
            try
                set term=xterm-256color
            catch
                set term=$TERM
            endtry
        else
            set term=$TERM
        endif
    endif
endif
" ------------------------------
" tags conf
" ------------------------------
if Require('notags')
    let g:ctags_type = ''
    let g:gtags_version = 0
elseif WINDOWS() && Require('tags') || UNIX()
    if WINDOWS() && filereadable(Expand("~/.leovim.windows/tools/ctags.exe"))
        let g:ctags_type = 'Universal-json'
    elseif executable('ctags')
        let g:ctags_type = split(system('ctags --version'), ' ')[0]
        if g:ctags_type =~ 'Universal'
            if system('ctags --list-features | grep json') =~ 'json'
                let g:ctags_type = 'Universal-json'
            else
                let g:ctags_type = 'Universal'
            endif
        endif
    else
        let g:ctags_type = ''
    endif
    if WINDOWS()
        let $GTAGSCONF = Expand($HOME . "/.leovim.windows/gtags/share/gtags/gtags.conf")
    endif
    if executable('gtags') && get(g:, 'ctags_type', '') != '' && exists('$GTAGSCONF') && filereadable($GTAGSCONF)
        let s:gtags_version = matchstr(system('gtags --version'), '\v\zs\d{1,2}.\d{1,2}.\d{1,2}\ze')
        let g:gtags_version = StringToFloat(s:gtags_version, 2)
        if get(g:, 'pygments_import', 0)
            let $GTAGSLABEL = 'native-pygments'
        else
            let $GTAGSLABEL = 'native'
        endif
    else
        let g:gtags_version = 0
    endif
else
    let g:ctags_type = ''
    let g:gtags_version = 0
endif
" ------------------------
" set tab label
" ------------------------
function! Vim_NeatBuffer(bufnr, fullname)
    let l:name = bufname(a:bufnr)
    if getbufvar(a:bufnr, '&modifiable')
        if l:name == ''
            return '[No Name]'
        else
            if a:fullname
                return fnamemodify(l:name, ':p')
            else
                return fnamemodify(l:name, ':t')
            endif
        endif
    else
        let l:buftype = getbufvar(a:bufnr, '&buftype')
        if l:buftype == 'quickfix'
            return '[Quickfix]'
        elseif l:name != ''
            if a:fullname
                return '-'.fnamemodify(l:name, ':p')
            else
                return '-'.fnamemodify(l:name, ':t')
            endif
        else
            return '[No Name]'
        endif
    endif
endfunc
" get a single tab label
function! Vim_NeatTabLabel(n)
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfun
" make tabline in terminal mode
function! Vim_NeatTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'
        " the label is made by MyTabLabel()
        let s .= ' %{Vim_NeatTabLabel(' . (i + 1) . ')} '
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999XX'
    endif
    return s
endfunction
" get a single tab label in gui
function! Vim_NeatGuiTabLabel()
    let l:num = v:lnum
    let l:buflist = tabpagebuflist(l:num)
    let l:winnr = tabpagewinnr(l:num)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfunc
" set label && tabline
set guitablabel=%{Vim_NeatGuiTabLabel()}
set tabline=%!Vim_NeatTabLine()
" -----------------------------------------------------------
" pack_tool
" -----------------------------------------------------------
let g:plug_threads = get(g:, 'plug_threads', 8)
function! s:plug_add(plugin, ...)
    " delete last / or \
    let plugin = substitute(a:plugin, '[\/]\+$', '', 'g')
    let pack = split(plugin, '\/')[1]
    if has_key(g:leovim_installed, pack)
        return
    else
        if a:0 == 0
            call plug#(plugin)
        else
            call plug#(plugin, a:1)
        endif
        if a:0 >0 && has_key(a:1, 'as') && a:1['as'] != ''
            let pack = tolower(a:1['as'])
        else
            let pack = tolower(pack)
        endif
    endif
    let g:leovim_installed[pack] = 0
endfunction
command! -nargs=+ PlugAdd call <sid>plug_add(<args>)
" ------------------------------
" install packs
" ------------------------------
let $DEPLOY_DIR = Expand("~/.leovim.d")
let opt_path = Expand("$DEPLOY_DIR/pack/add/opt")
call plug#begin(opt_path)
if filereadable(expand("$DEPLOY_DIR/pack.vim"))
    source ~/.leovim.d/pack.vim
endif
for vim in split(glob("$INSTALL_DIR/*.vim"), "\n")
    exec "source " . vim
endfor
function! s:plug_update() abort
    let opt_vim = Expand('~/.vimrc.opt')
    if filereadable(opt_vim)
        execute "source " . opt_vim
    endif
    PlugUpdate
endfunction
command! PlugOptUpdate call s:plug_update()
noremap <silent><leader>U :PlugOptUpdate<Cr>
call plug#end()
" ------------------------------
" set installed
" ------------------------------
for [plug, value] in items(g:plugs)
    let dir = value['dir']
    if isdirectory(dir)
        let g:leovim_installed[tolower(plug)] = 1
    endif
endfor
" ------------------------------
" set $PATH
" ------------------------------
let mason_bin = expand('~/.leovim.d/mason/bin')
if g:complete_engine != 'cmp' && isdirectory(mason_bin)
    if WINDOWS()
        let $PATH = mason_bin . ';' . $PATH
    else
        let $PATH = mason_bin . ':' . $PATH
    endif
endif
" ------------------------------
" source config cfg
" ------------------------------
for vim in split(glob("$CONFIG_DIR/*.vim"), "\n")
    exec "source " . vim
endfor
" -------------------------------
" set filetype unix and trim \r
" -------------------------------
nnoremap <M-h>u :set ff=unix<Cr>:%s/\r//g<Cr>
" ------------------------
" open config file
" ------------------------
nnoremap <M-h><Cr> :source ~/.leovim/boostup/init.vim<Cr>
nnoremap <M-h>o :tabe ~/.vimrc.opt<Cr>
nnoremap <M-h>O :tabe ~/.leovim/boostup/optional/opt.vim<Cr>
nnoremap <M-h>p :tabe ~/.leovim/pack
function! TabeOpen(f) abort
    let f = expand(a:f)
    exec "tabe " . f
endfunction
nnoremap <silent><M-h>i :call TabeOpen("$BOOSTUP_DIR/init.vim")<Cr>
nnoremap <silent><M-h>b :call TabeOpen("$INSTALL_DIR/basement.vim")<Cr>
nnoremap <silent><M-h>l :call TabeOpen("$LUA_DIR/lsp.lua")<Cr>
nnoremap <silent><M-h>m :call TabeOpen("$INIT_DIR/main.vim")<Cr>
nnoremap <silent><M-h>k :call TabeOpen("$INIT_DIR/keybindings.json")<Cr>
nnoremap <silent><M-h>v :call TabeOpen("$INIT_DIR/vscode.vim")<Cr>
nnoremap <silent><M-h>d :call TabeOpen("$CONFIG_DIR/debug-terminal.vim")<Cr>
nnoremap <silent><M-h>F :call TabeOpen("$OPTIONAL_DIR/fzf.vim")<Cr>
nnoremap <silent><M-h>L :call TabeOpen("$OPTIONAL_DIR/leaderf.vim")<Cr>
if PrefFzf()
    nnoremap <silent><M-h>f :FzfFiles <C-r>=expand('$CONFIG_DIR')<Cr><Cr>
elseif InstalledLeaderf()
    nnoremap <silent><M-h>f :LeaderfFile <C-r>=expand('$CONFIG_DIR')<Cr><Cr>
else
    nnoremap <silent><M-h>f :call TabeOpen("$CONFIG_DIR/file.vim")<Cr>
endif
" --------------------------
" open other ides config
" --------------------------
nnoremap <silent><M-h>V :call TabeOpen("$LEOVIM_DIR/msvc/vs.vim")<Cr>
nnoremap <silent><M-h>I :tabe TabeOpen("$LEOVIM_DIR/jetbrains/idea.vim")<Cr>
" --------------------------
" open or add file
" --------------------------
function! s:open_or_create_file(file, ...) abort
    let file = Expand(a:file)
    if filereadable(file)
        try
            execute "tabe " . file
            return 1
        catch /.*/
            call preview#errmsg("Could not open file " . a:file)
            return 0
        endtry
    else
        let dir = FileDir(file)
        try
            if !isdirectory(dir)
                call mkdir(dir, "p")
            endif
            let content = []
            for each in a:000
                if type(each) == v:t_list
                    let content += each
                elseif type(each) == v:t_dict
                    let content += keys(each)
                elseif type(each) == v:t_number
                    call add(content, string(num))
                elseif type(each) == v:t_string
                    call add(content, each)
                elseif index([v:t_func, v:t_job, v:t_none, v:t_channel]) < 0
                    call add(content, string(each))
                endif
            endfor
            let b:content = content
            if len(content) > 0
                call writefile(content, file)
            endif
            execute "tabe " . file
            return 1
        catch /.*/
            call preview#errmsg("Could not create or write to file " . a:file)
            return 0
        endtry
    endif
endfunction
" ssh/config
nnoremap <M-h>c :call <SID>open_or_create_file("~/.ssh/config")<Cr>
" gitconfig
command! OpenGitConfig call <SID>open_or_create_file("~/.gitconfig")
nnoremap <M-h>G :OpenGitConfig<Cr>
" bashrc
nnoremap <M-h>B :call <SID>open_or_create_file("~/.bashrc")<Cr>
nnoremap <M-h>C :call <SID>open_or_create_file("~/.configrc")<Cr>
" addtional vim config
if filereadable(expand("~/.leovim.d/after.vim"))
    source ~/.leovim.d/after.vim
endif
nnoremap <M-h>A :call <SID>open_or_create_file("~/.leovim.d/after.vim")<Cr>
nnoremap <M-h>P :call <SID>open_or_create_file("~/.leovim.d/pack.vim")<Cr>
" ------------------
" create root file
" ------------------
function! s:open_or_create_rootfile(fl, ...) abort
    let fl = GetRootDir() . '/' . a:fl
    if a:0
        call s:open_or_create_file(fl, a:000)
    else
        call s:open_or_create_file(fl)
    endif
endfunction
command! OpenTODO call s:open_or_create_rootfile('TODO.md', '# TODO:', '- [ ]')
nnoremap <M-h>t :OpenTODO<Cr>
command! OpenREADME call s:open_or_create_rootfile('README.md', '# README')
nnoremap <M-h>r :OpenREADME<Cr>
command! OpenGitignore call s:open_or_create_rootfile('.gitignore')
nnoremap <M-h>g :OpenGitignore<Cr>
command! OpenWildignore call s:open_or_create_rootfile('.wildignore')
nnoremap <M-h>w :OpenWildignore<Cr>
" ------------------
" delete tmp files
" ------------------
if WINDOWS()
    nnoremap <leader>x :!powershell <C-r>=Expand("~/_leovim.clean.cmd")<Cr><Cr> \| e %<Cr><C-o>
else
    nnoremap <leader>x :!bash <C-r>=Expand("~/.leovim.clean")<Cr><Cr> \| e %<Cr><C-o>
endif
" ----------------------
" <M-Key> map for vim
" ----------------------
if !has('nvim') && HAS_GUI() == 0
    function! s:set_metacode(key)
        exec "set <M-".a:key.">=\e".a:key
    endfunction
    for c in s:metacode_group
        call s:set_metacode(c)
    endfor
endif
