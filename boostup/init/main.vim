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
let g:root_patterns = get(g:, 'root_patterns', [".git", ".hg", ".svn", ".root", ".env", ".vscode", ".vim", ".idea", ".ccls", ".project", ".next"])
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
if exists('g:vscode')
    imap <C-a> <ESC>ggVG
    xmap <C-a> <ESC>ggVG
    nmap <C-a> ggVG
    imap <C-x> <C-o>"*
    xmap <C-x> "*x
    nmap <C-x> "*x
else
    imap <expr><C-a> pumvisible()? "\<C-a>":"\<C-o>0"
endif
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
function! MoveToEndAndAddSemicolon(...) abort
    execute "normal! :s/\\s\\+$//e\\r"
    normal! g_
    if index(['c', 'cpp', 'csharp', 'rust', 'java', 'perl', 'php'], &ft) >= 0
        if index([';', '{', '}'], getline('.')[col('.') - 1]) >= 0
            normal! a
        else
            normal! a;
        endif
    else
        normal! a
    endif
    " o or O
    if a:0 && a:1 > 0
        normal! o
    else
        normal! O
    endif
endfunction
inoremap <C-j> <C-\><C-n>:call MoveToEndAndAddSemicolon(1)<CR>
inoremap <C-k> <C-\><C-n>:call MoveToEndAndAddSemicolon(0)<CR>
" ------------------------
" yank
" ------------------------
nnoremap <expr>gp '`[' . strpart(getregtype(), 0, 1) . '`]'
xnoremap zp "_c<ESC>p"
xnoremap zP "_c<ESC>P"
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
    " -------------------
    " textobj
    " -------------------
    PlugAddOpt 'vim-textobj-user'
    PlugAddOpt 'vim-textobj-uri'
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
    nmap <leader>vi viio
    nmap <leader>vI vaio
    noautocmd nmap <silent>si viio<C-[>^
    noautocmd nmap <silent>sg vii<C-[>^
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
" osc52 yankpost
" ------------------------
if exists("##TextYankPost") && UNIX() && get(g:, 'leovim_osc52_yank', 1)
    function! s:raw_echo(str)
        if filewritable('/dev/fd/2')
            call writefile([a:str], '/dev/fd/2', 'b')
        else
            exec("silent! !echo " . shellescape(a:str))
            redraw!
        endif
    endfunction
    function! s:copy() abort
        let c = join(v:event.regcontents,"\n")
        if len(Trim(c)) == 0
            return
        endif
        let c64 = system("base64", c)
        if $TMUX == ''
            let s = "\e]52;c;" . Trim(c64) . "\x07"
        else
            let s = "\ePtmux;\e\e]52;c;" . Trim(c64) . "\x07\e\\"
        endif
        call s:raw_echo(s)
    endfunction
    autocmd TextYankPost * call s:copy()
endif
" ------------------------
" set optional
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
nnoremap <M-h>u :set ff=unix<Cr>:%s/\r//g<Cr>
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
call plug#begin(Expand("$DEPLOY_DIR/pack/add/opt"))
if get(g:, 'leovim_openmap', 1) && filereadable(expand("$DEPLOY_DIR/pack.vim"))
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
