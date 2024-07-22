nnoremap <Bs> :set nohlsearch? nohlsearch!<Cr>
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
		" Must trim the end before the start, the beginning will shift left.
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
let g:cfile_types = get(g:, 'cfile_types', ["c", "cpp", "objc", "objcpp", "cuda"])
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
    lua require("flash_cfg")
else
    let g:clever_f_smart_case = 1
    let g:clever_f_repeat_last_char_inputs = ['<Tab>']
    nmap ; <Plug>(clever-f-repeat-forward)
    xmap ; <Plug>(clever-f-repeat-forward)
    nmap ,, <Plug>(clever-f-repeat-back)
    xmap ,, <Plug>(clever-f-repeat-back)
    PlugAddOpt 'clever-f.vim'
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
    imap <C-a> <ESC>ggVG
    xmap <C-a> <ESC>ggVG
    nmap <C-a> ggVG
    imap <C-x> <C-o>"*
    xmap <C-x> "*x
    nmap <C-x> "*x
    " hop for neovim-vscode only
    PlugAddOpt 'hop.nvim'
    lua require("hop_cfg")
    source $CFG_DIR/vscode.vim
else
    imap <expr><C-a> pumvisible()? "\<C-a>":"\<C-o>0"
    source $CFG_DIR/easymotion.vim
    source $CFG_DIR/vim.vim
endif
