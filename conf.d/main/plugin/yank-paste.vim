" Copy file path
nnoremap <leader>YA :let @"=utils#abs_path()<Cr>:echo "-= File abspath copied=-"<Cr>
" Copy file dir
nnoremap <leader>YD :let @"=utils#abs_dir()<Cr>:echo "-= File dir copied=-"<Cr>
" Copy file name
nnoremap <leader>YB :let @"=utils#file_name()<Cr>:echo "-= File basename copied=-"<Cr>
" Yank a line without leading whitespaces and line break
nnoremap <leader>YU _yg_:echo "-= Yanked line without leading whitespaces and line break=-"<Cr>
" ------------------------------------
" clipboard
" ------------------------------------
if has('clipboard')
    function! s:setup_clipboard(register, mode, label) abort
        let s:register = a:register
        let s:clipboard = a:mode
        if utils#is_vscode()
            execute 'set clipboard=' . a:mode
        else
            set clipboard=
        endif
        execute 'xnoremap Y "' . a:register . 'y:echo "Yank selection to ' . a:label . ' clipboard."<Cr>'
        execute 'nnoremap <leader>ya :let @' . a:register . '=utils#abs_path()<Cr>:echo "-= File abspath copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>yd :let @' . a:register . '=utils#abs_dir()<Cr>:echo "-= File dir copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>yb :let @' . a:register . '=utils#file_name()<Cr>:echo "-= File basename copied to ' . a:label . ' clipboard=-"<Cr>'
        execute 'nnoremap <leader>yu _"' . a:register . 'yg_:echo "-= Yanked line without leading whitespaces and line break to ' . a:label . ' clipboard=-"<Cr>'
    endfunction
    if utils#is_linux() && (utils#is_vscode() || exists('$TMUX'))
        call s:setup_clipboard('+', 'unnamedplus', 'x11')
    else
        call s:setup_clipboard('*', 'unnamed', 'system')
    endif
else
    let s:register = ""
    let s:clipboard = ""
    set clipboard=
    xnoremap Y y:echo 'Yank selection to internal clipboard.'<Cr>
endif
" --------------------------------------------
" yank command and position to editors
" --------------------------------------------
function! s:yank_position_to_editor(editor) abort
    if index(['code', 'cursor', 'windsurf', 'antigravity', 'qoder', 'trae', 'positron', 'antigravity', 'zed', 'edit'], a:editor) >= 0
        let editor = a:editor
    else
        return
    endif
    if editor == 'zed'
        let cmd = printf('zed %s:%d:%d', utils#abs_path(), line("."), col("."))
    elseif editor == 'edit'
        let cmd = printf(' %s | call cursor(%d, %d)', utils#abs_path(), line("."), col("."))
    else
        let cmd = printf('%s --goto %s:%d:%d', editor, utils#abs_path(), line("."), col("."))
    endif
    if s:register == '+'
        let @+ = cmd
    elseif s:register == '*'
        let @* = cmd
    else
        let @" = cmd
    endif
    echo '=== Yank current position to ' . editor . ' ==='
endfunction
command! YankPositionToVscode      call s:yank_position_to_editor('code')
command! YankPositionToCursr       call s:yank_position_to_editor('cursor')
command! YankPositionToWindsurf    call s:yank_position_to_editor('windsurf')
command! YankPositionToAntigravity call s:yank_position_to_editor('antigravity')
command! YankPositionToQoder       call s:yank_position_to_editor('qoder')
command! YankPositionToTrae        call s:yank_position_to_editor('trae')
command! YankPositionToPositron    call s:yank_position_to_editor('positron')
command! YankPositionToZed         call s:yank_position_to_editor('zed')
command! YankPositionToEdit        call s:yank_position_to_editor('edit')
nnoremap <silent><leader>yv :YankPositionToVscode<Cr>
nnoremap <silent><leader>yc :YankPositionToCursr<Cr>
nnoremap <silent><leader>yw :YankPositionToWindsurf<Cr>
nnoremap <silent><leader>yq :YankPositionToQoder<Cr>
nnoremap <silent><leader>yp :YankPositionToPositron<Cr>
nnoremap <silent><leader>yz :YankPositionToZed<Cr>
nnoremap <silent><leader>ye :YankPositionToEdit<Cr>
" --------------------------------------------
" yank line ref with range
" --------------------------------------------
function! s:yank_line_ref(start, end) range abort
    let ref = '@' . utils#abs_path() . '#L' . a:start
    if a:start != a:end
        let ref .= '-L' . a:end
    endif
    if s:register == '+'
        let @+ = ref
    elseif s:register == '*'
        let @* = ref
    else
        let @" = ref
    endif
    echo '=== Yank line reference === '
endfunction
command! -range YankLineRef call s:yank_line_ref(<line1>, <line2>)
nnoremap <silent><leader>yl :YankLineRef<Cr>
xnoremap <silent><leader>yl :YankLineRef<Cr>
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
" ------------------------
" vim only
" ------------------------
if utils#is_vscode()
    finish
endif
" ------------------------------------
" M-x/BS
" ------------------------------------
nnoremap <M-x> x
xnoremap <M-x> x
inoremap <M-x> <Del>
cnoremap <M-x> <Del>
nnoremap <Del> x
xnoremap <Del> x
nnoremap <M-X> X
xnoremap <M-X> X
inoremap <M-X> <BS>
cnoremap <M-X> <BS>
cnoremap <C-y> <C-r>"
nnoremap <S-Insert> P
xnoremap <S-Insert> P
cnoremap <S-insert> <C-r>"
inoremap <S-Insert> <C-r>"
" switch 2 words
xnoremap X <Esc>`.``gvp``P
" m-v paste
cnoremap <M-v> <C-r>"
if g:has_terminal == 1
    tnoremap <M-v> <C-\><C-n>""pa
elseif g:has_terminal == 2
    tnoremap <M-v> <C-_>""
endif
" ------------------------------------
" registers plugins with fzf
" ------------------------------------
if pack#planned('fzf-registers')
    nnoremap <silent><M-v> :FzfRegisterPaste<Cr>
    inoremap <silent><M-v> <C-o>:FzfRegisterPaste<Cr>
    xnoremap <silent><M-v> :<C-u>FzfRegisterPasteV<Cr>
    xnoremap <silent><M-y> :<C-u>FzfRegisterYankV<Cr>
    for letter in ['{', '}', '[', ']', '(', ')', '<', '>', '"', "'", '.', 's', 'S', 'a', 'A', 'l', 'n', 't', 'w', 'u', 'v', 'b', 'c', 'k']
        execute printf("nnoremap <silent><M-y>%s :FzfRegisterYank %s<Cr>", letter, letter)
        execute printf("inoremap <silent><M-y>%s <C-o>:FzfRegisterYank %s<Cr>", letter, letter)
    endfor
else
    nnoremap <silent><M-v> :registers<Cr>
endif
" ------------------------
" paste
" ------------------------
nnoremap \pw viwp
nnoremap \p` viw"0p
xnoremap \p` "0p
for i in range(4)
    execute printf('nnoremap \p%s viw"%sp', i , i)
    execute printf('xnoremap \p%s "%sp', i , i)
endfor
" ------------------------
" yank to p regsiter
" ------------------------
augroup YankToPRegister
  autocmd!
  autocmd TextYankPost *
        \ if get(v:event, 'operator', '') ==# 'y'
        \ && get(v:event, 'regname', '') ==# ''
        \ | call setreg('p', getreg('"'), getregtype('"'))
        \ | endif
augroup END
xnoremap <M-V> "pp
" ------------------------
" pastemode toggle
" ------------------------
if has('nvim')
	inoremap <silent><M-I> <C-\><C-o>:set paste<Cr>
else
	inoremap <silent><M-I> <C-o>:set paste<Cr>
endif
onoremap <M-I> :set paste<CR>
nnoremap <M-I> :set paste<Cr>
xnoremap <M-I> :set paste<Cr>
augroup AutoPasteMode
    autocmd!
    autocmd InsertLeave,CmdlineLeave * set nopaste
augroup END
" -------------------------------
" clipboard from remote to local
" -------------------------------
if exists("##TextYankPost") && utils#is_unix()
    function! s:raw_echo(str)
        if filewritable('/dev/fd/2') && !utils#has_gui()
            call writefile([a:str], '/dev/fd/2', 'b')
        else
            call system("!echo " . shellescape(a:str))
            redraw!
        endif
    endfunction
    function! s:copy() abort
        let c = join(v:event.regcontents,"\n")
        if len(utils#trim(c)) == 0
            return
        endif
        let c64 = system("base64", c)
        if $TMUX == ''
            let s = "\e]52;c;" . utils#trim(c64) . "\x07"
        else
            let s = "\ePtmux;\e\e]52;c;" . utils#trim(c64) . "\x07\e\\"
        endif
        call s:raw_echo(s)
    endfunction
    autocmd TextYankPost * call s:copy()
endif
