" --------------------------
" version require
" --------------------------
if v:version < 703 && !has('nvim')
    echoe 'If vim, to use leovim config vim 7.3 is at least required.'
    finish
elseif !has('nvim-0.4.4') && has('nvim')
    echoe 'If neovim, to use leovim config neovim 0.4.4 is at least required.'
    finish
else
    " set rtp
    let $CONFIG_PATH   = expand('~/.leovim.conf')
    let $ADDINS_PATH   = expand('~/.leovim.conf/addins')
    let $PLUGINS_PATH  = expand('~/.leovim.conf/plugins')
    let $SETTINGS_PATH = expand('~/.leovim.conf/settings')
    " plugs install path, please NOTE the plugs installed would not be deleted by command :PlugClean
    let $INSTALL_PATH  = expand('~/.leovim.plug')
endif
" --------------------------
" important plugins
" --------------------------
if !exists('g:leovim_loaded')
    set rtp=$ADDINS_PATH/vim-startify,$PLUGINS_PATH,$VIMRUNTIME
endif
let g:startify_custom_header = [
            \ '             LLLLLLLLLLL             EEEEEEEEEEEEEEEEEEEEEE     OOOOOOOOO     VVVVVVVV           VVVVVVVVIIIIIIIIIIMMMMMMMM               MMMMMMMM ',
            \ '             L:::::::::L             E::::::::::::::::::::E   OO:::::::::OO   V::::::V           V::::::VI::::::::IM:::::::M             M:::::::M ',
            \ '             L:::::::::L             E::::::::::::::::::::E OO:::::::::::::OO V::::::V           V::::::VI::::::::IM::::::::M           M::::::::M ',
            \ '             LL:::::::LL             EE::::::EEEEEEEEE::::EO:::::::OOO:::::::OV::::::V           V::::::VII::::::IIM:::::::::M         M:::::::::M ',
            \ '               L:::::L                 E:::::E       EEEEEEO::::::O   O::::::O V:::::V           V:::::V   I::::I  M::::::::::M       M::::::::::M ',
            \ '               L:::::L                 E:::::E             O:::::O     O:::::O  V:::::V         V:::::V    I::::I  M:::::::::::M     M:::::::::::M ',
            \ '               L:::::L                 E::::::EEEEEEEEEE   O:::::O     O:::::O   V:::::V       V:::::V     I::::I  M:::::::M::::M   M::::M:::::::M ',
            \ '               L:::::L                 E:::::::::::::::E   O:::::O     O:::::O    V:::::V     V:::::V      I::::I  M::::::M M::::M M::::M M::::::M ',
            \ '               L:::::L                 E:::::::::::::::E   O:::::O     O:::::O     V:::::V   V:::::V       I::::I  M::::::M  M::::M::::M  M::::::M ',
            \ '               L:::::L                 E::::::EEEEEEEEEE   O:::::O     O:::::O      V:::::V V:::::V        I::::I  M::::::M   M:::::::M   M::::::M ',
            \ '               L:::::L                 E:::::E             O:::::O     O:::::O       V:::::V:::::V         I::::I  M::::::M    M:::::M    M::::::M ',
            \ '               L:::::L         LLLLLL  E:::::E       EEEEEEO::::::O   O::::::O        V:::::::::V          I::::I  M::::::M     MMMMM     M::::::M ',
            \ '             LL:::::::LLLLLLLLL:::::LEE::::::EEEEEEEE:::::EO:::::::OOO:::::::O         V:::::::V         II::::::IIM::::::M               M::::::M ',
            \ '             L::::::::::::::::::::::LE::::::::::::::::::::E OO:::::::::::::OO           V:::::V          I::::::::IM::::::M               M::::::M ',
            \ '             L::::::::::::::::::::::LE::::::::::::::::::::E   OO:::::::::OO              V:::V           I::::::::IM::::::M               M::::::M ',
            \ '             LLLLLLLLLLLLLLLLLLLLLLLLEEEEEEEEEEEEEEEEEEEEEE     OOOOOOOOO                 VVV            IIIIIIIIIIMMMMMMMM               MMMMMMMM ',
            \ ]
let g:startify_files_number   = 10
let g:startify_session_number = 10
let g:startify_list_order = [
            \ ['   最近项目:'],
            \ 'sessions',
            \ ['   最近文件:'],
            \ 'files',
            \ ['   快捷命令:'],
            \ 'commands',
            \ ['   常用书签:'],
            \ 'bookmarks',
            \ ]
let g:startify_commands = [
            \ {'v': ['重要插件', 'call Version()']},
            \ {'V': ['基本信息', 'version']},
            \ ]
let g:startify_session_dir = expand("~/.cache/session")
if !isdirectory(g:startify_session_dir)
    silent! call mkdir(g:startify_session_dir, "p")
endif
" --------------------------
" check gui_running
" --------------------------
if has('gui_running')
    let g:gui_running = 1
elseif has('nvim')
    if has('gui_vimr')
        let g:gui_running = 1
    else
        try
            call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
            call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
            let g:gui_running = 1
        catch
            let g:gui_running = 0
        endtry
    endif
else
    let g:gui_running = 0
endif
" --------------------------
" System Type
" --------------------------
function! WINDOWS() abort
    return has('win32') || has('win64')
endfunction
function! LINUX() abort
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
function! CYGWIN()
    return has('win32unix') && !has('macunix')
endfunction
function! MACOS() abort
    return has('macunix')
endfunction
function! MACVIM() abort
    return has('gui_running') && MACOS()
endfunction
function! UNIX() abort
    return LINUX() || MACOS()
endfunction
" --------------------------
" terminal and lambda
" --------------------------
if exists(':tnoremap')
    if exists(':terminal') == 2 && has('patch-8.1.1')
        set termwinkey=<C-_>
        let g:has_terminal = 2
    else
        let g:has_terminal = 1
    endif
else
    let g:has_terminal  = 0
endif
" lambda is for sidebar
try
    let Lambda = {a, b -> a + b}
    let g:has_lambda = 1
    try
        let Lambda = {-> exists('t:__terminal_bid__') ? bufwinnr(t:__terminal_bid__) : 0}
        let g:has_lambda = 2
        unlet Lambda
    catch
        unlet Lambda
    endtry
catch
    let g:has_lambda = 0
endtry
" -----------------------------------
" Initialize directories
" -----------------------------------
function! InitializeDirectories()
    let dir_list = {
        \ 'backupdir': '.vim/backup',
        \ 'viewdir':   '.vim/views',
        \ 'directory': '.vim/swap',
        \ }
    if has('persistent_undo')
        if has('nvim')
            let dir_list['undodir'] = '.vim/undo-nvim'
        else
            let dir_list['undodir'] = '.vim/undo-vim'
        endif
    endif
    for [settingname, dirname] in items(dir_list)
        if WINDOWS()
            let directory = $HOME . '\\'. dirname
        else
            let directory = $HOME . '/'. dirname
        endif
        if isdirectory(directory)
            exec "set " . settingname . "=" . directory
        else
            try
                silent! call mkdir(directory, "p")
            catch
                echo "Unable to create it. Try mkdir -p " . directory
            endtry
        endif
    endfor
endfunction
call InitializeDirectories()
" --------------------------
" leader key
" --------------------------
let g:mapleader      = ' '
let g:maplocalleader = '\'
" ------------------------
" open config file
" ------------------------
nnoremap <leader>eo :tabe ~/.leovim.conf/init.vim<CR>
nnoremap <leader>el :tabe ~/.vimrc.local<CR>
" --------------------------
" plugs_group settings
" --------------------------
let g:plugs_group=[]
if filereadable(expand("~/.vimrc.local")) | source $HOME/.vimrc.local | endif
function! HasPlug(plug)
    return count(g:plugs_group, a:plug)
endfunction
function! AddPlug(plug)
    if !HasPlug(a:plug)
        let g:plugs_group += [a:plug]
    endif
endfunction
function! Installed(dir)
    return isdirectory(expand("$INSTALL_PATH/".a:dir)) && &rtp =~ a:dir
endfunction
nnoremap <M-k><M-a> ggVG
" ------------------------
" terminal
" ------------------------
if get(g:, 'has_terminal', 0) > 0
    tnoremap <expr> <C-R> '<C-\><C-n>"'.nr2char(getchar()).'pi'
    tnoremap <M-q> <C-\><C-n>:q!<CR>
    if has('nvim')
        if WINDOWS()
            nnoremap <Tab>m :tabe term://cmd<cr>i
        else
            nnoremap <Tab>m :tabe term://bash<cr>i
        endif
    else
        if WINDOWS()
            nnoremap <Tab>m :tab terminal<Cr>cmd<Cr>
        else
            nnoremap <Tab>m :tab terminal<Cr>bash<Cr>
        endif
    endif
    " --------------------------
    " terminal-help
    " --------------------------
    if has('nvim') || g:has_terminal == 2
        if !exists('g:leovim_loaded')
            set rtp+=$ADDINS_PATH/vim-terminal-help
            let g:terminal_plus = 'help'
        endif
        if get(g:, 'terminal_shell', '') == ''
            if WINDOWS()
                let g:terminal_shell = 'cmd'
            else
                let g:terminal_shell = 'bash'
            endif
        endif
        let g:terminal_key             = '<M-->'
        let g:terminal_auto_insert     = 1
        let g:terminal_skip_key_init   = 1
        let g:terminal_default_mapping = 0
        let g:terminal_kill            = 'term'
        if has('nvim')
            if has('clipboard')
                tnoremap <M-v> <C-\><C-n>"*pa
            else
                tnoremap <M-v> <C-\><C-n>"0pa
            endif
        else
            if has('clipboard')
                tnoremap <M-v> <C-_>"*
            else
                tnoremap <M-v> <C-_>"0
            endif
        endif
    endif
    " --------------------------
    " floaterm
    " --------------------------
    if (has('nvim') || v:version >= 802 && !has('nvim')) && !HasPlug('inweb')
        autocmd User Startified setlocal buflisted
        if !exists('g:leovim_loaded')
            set rtp+=$ADDINS_PATH/vim-floaterm
            let g:floaterm_keymap_new   = '<Nop>'
            let g:floaterm_keymap_prev  = '<M-{>'
            let g:floaterm_keymap_next  = '<M-}>'
            let g:floaterm_open_command = 'drop'
        endif
        nnoremap <M-h>t :FloatermNew --height=0.8 --width=0.8 --position=center<Cr>
        if get(g:, 'terminal_plus', '') == ''
            let g:terminal_plus = 'floaterm'
        else
            let g:terminal_plus .= '-floaterm'
        endif
        if has('nvim') || has('patch-8.1.1615')
            let g:floaterm_position = 'topright'
            let g:floaterm_width    = 0.5
            let g:floaterm_height   = 0.65
        else
            let g:floaterm_position = 'right'
        endif
        nnoremap <M-h>n :FloatermNew<Space>
        nnoremap <M-h>f :Floaterm<Tab>
        nnoremap <M-h>1 :FloatermFirst<Cr>
        nnoremap <M-h>0 :FloatermLast<Cr>
        nnoremap <silent> <M-=> :FloatermToggle<CR>
        tnoremap <silent> <M-=> <C-\><C-n>:FloatermToggle<CR>
    endif
endif
" --------------------------
" GetVisualSelection
" --------------------------
function! GetVisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ""
    endif
    let lines[-1] = lines[-1][:column_end - (&selection == "inclusive" ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
" --------------------------
" StripTrailingWhiteSpace
" --------------------------
function! StripTrailingWhiteSpace()
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
command! StripTrailingWhiteSpace call StripTrailingWhiteSpace()
nnoremap <leader>es :StripTrailingWhiteSpace<Cr>
nnoremap <leader>eu :set ff=unix<Cr>:%s/\r//g<Cr>
augroup TrailSpace
    autocmd FileType vim,c,cpp,java,go,php,javascript,typescript,python,rust,twig,xml,yml,perl,sql,r,conf
        \ autocmd! BufWritePre <buffer> :call StripTrailingWhiteSpace()
augroup END
" --------------------------
" set TERM && screen
" --------------------------
if WINDOWS()
    if isdirectory($HOME. "\\.leovim.plug\\windows-tools")
        let $PATH = $HOME . "\\.leovim.plug\\windows-tools\\tools;" . $HOME . "\\.leovim.plug\\windows-tools\\tools\\gtags\\bin;" . $HOME . "\\.leovim.plug\\windows-tools\\tools\\cppcheck;" . $PATH
    endif
    set winaltkeys=no
    if get(g:,'gui_running', 0) > 0
        set lines=999
        set columns=999
    endif
    if has('libcall') && !has('nvim') && g:gui_running > 0
        let g:gvimfullscreendll = $HOME."\\.leovim.plug\\windows-tools\\tools\\gvimfullscreen.dll"
        function! ToggleFullScreen()
            call libcallnr(g:gvimfullscreendll, "ToggleFullScreen", -1)
        endfunction
        nnoremap <C-cr> <ESC>:call ToggleFullScreen()<CR>
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
        nnoremap <silent> <M-+> :call SetAlpha(5)<Cr>
        nnoremap <silent> <M-_> :call SetAlpha(-5)<Cr>
    endif
elseif UNIX()
    if $PATH !~ 'addins'
        let $PATH = $ADDINS_PATH . "/bin:" . $PATH
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
    elseif !has('gui_running') && !has('nvim')
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
    if MACVIM() && !has('gui_vimr')
        set macmeta
    endif
endif
" --------------------------
" Alt_to_meta
" --------------------------
let s:punctuation_list = [',', '.', ';', ':', '/', '?', '-', '_', '{', '}', '=', '+', "'"]
function! MetaCode(key)
    if !has('nvim') && g:gui_running == 0 || CYGWIN()
        exec "set <M-".a:key.">=\e".a:key
    endif
    exec "imap <M-".a:key."> <Nop>"
    exec "smap <M-".a:key."> <Nop>"
endfunction
for i in range(26)
    " 97 ascii of a
    call MetaCode(nr2char(97 + i))
    " 65 ascii of A
    call MetaCode(nr2char(65 + i))
endfor
for c in s:punctuation_list
    call MetaCode(c)
endfor
for i in range(10)
    call MetaCode(nr2char(char2nr('0') + i))
endfor
unlet s:punctuation_list
" ------------------------
" has_truecolor
" ------------------------
if has('termguicolors') || WINDOWS() || g:gui_running > 0
    let g:has_truecolor = 1
else
    let g:has_truecolor = 0
endif
if g:has_truecolor == 1
    set termguicolors
    if !has('nvim')
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    nnoremap <M-k>g :set notermguicolors! notermguicolors?<CR>
endif
" ------------------------
" easy-align
" ------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-easy-align
    let g:easy_align_delimiters = {}
    let g:easy_align_delimiters['#'] = { 'pattern': '#', 'ignore_groups': ['String'] }
endif
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
xmap g,       ga*,
xmap g<tab>   ga*=
xmap g<space> ga*<space>
" ------------------------
" choosewin
" ------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-choosewin
endif
nmap <M-w> <Plug>(choosewin)
" ------------------------
" winresizer
" ------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/winresizer
    let g:winresizer_enable        = 1
    let g:winresizer_gui_enable    = 1
    let g:winresizer_start_key     = "-"
    let g:winresizer_gui_start_key = "-"
endif
try
    let g:has_winnr = winnr('h') || 1
    " 判断方向上有没有窗口
    function! s:has_left() abort
        return winnr() != winnr('h')
    endfunction
    function! s:has_right() abort
        return winnr() != winnr('l')
    endfunction
    function! s:has_down() abort
        return winnr() != winnr('j')
    endfunction
    function! s:has_up() abort
        return winnr() != winnr('k')
    endfunction
    " 判断位置
    function! s:position() abort
        if !s:has_left() && !s:has_right()
            return 's'
        elseif s:has_left() && s:has_right()
            return 'm'
        elseif s:has_left()
            return 'r'
        else
            return 'l'
        endif
    endfunction
    " smartverticalresize, c-h/c-l left line, _+ right line
    let g:adjust_size = get(g:, 'adjust_size', 4)
    function! SmartVerticalResize(direction, ...) abort
        if a:0 != 1
            return
        endif
        let pos = s:position()
        let di  = a:direction
        let lp  = a:1
        if pos == 'l' || pos == 'm' && lp == 'r'
            if di == 'l'
                exec 'vertical resize -' . g:adjust_size
            else
                exec 'vertical resize +' . g:adjust_size
            endif
        elseif pos == 'r'
            if di == 'l'
                exec 'vertical resize +' . g:adjust_size
            else
                exec 'vertical resize -' . g:adjust_size
            endif
        elseif pos == 'm'
            if di == 'l'
                exec 'vertical ' . winnr('h') . 'resize -' . g:adjust_size
            else
                exec 'vertical ' . winnr('h') . 'resize +' . g:adjust_size
            endif
        endif
    endfunc
    nnoremap <silent> <Tab>j :call SmartVerticalResize('l', 'r')<Cr>
    nnoremap <silent> <Tab>k :call SmartVerticalResize('r', 'r')<Cr>
    nnoremap <silent> <Tab>h :call SmartVerticalResize('l', 'l')<Cr>
    nnoremap <silent> <Tab>l :call SmartVerticalResize('r', 'l')<Cr>
		function! SmartCtrlJ() abort
        if s:has_down()
            call feedkeys("\<C-w>\<C-j>")
        elseif s:has_up()
            call feedkeys("\<C-w>\<C-k>")
        endif
    endfunction
    nnoremap <silent>+ :call SmartCtrlJ()<Cr>
    nnoremap <silent>_ :call SmartCtrlJ()<Cr>
catch
    let g:has_winnr = 0
    nnoremap <Tab>j :echo "winnr('hjkl') is not allowed in this vim, can not adjust panel size!"<Cr>
    nnoremap <Tab>k :echo "winnr('hjkl') is not allowed in this vim, can not adjust panel size!"<Cr>
    nnoremap <Tab>h :echo "winnr('hjkl') is not allowed in this vim, can not adjust panel size!"<Cr>
    nnoremap <Tab>l :echo "winnr('hjkl') is not allowed in this vim, can not adjust panel size!"<Cr>
    nnoremap +      :echo "winnr('hjkl') is not allowed in this vim, can not adjust panel size!"<Cr>
    nnoremap _      :echo "winnr('hjkl') is not allowed in this vim, can not adjust panel size!"<Cr>
endtry
nnoremap <Tab>H <C-w>H
nnoremap <Tab>J <C-w>J
nnoremap <Tab>K <C-w>K
nnoremap <Tab>L <C-w>L
nnoremap <Tab>t <C-w>T
nnoremap <Tab>v :vsplit<Space>
nnoremap <Tab>x :split<Space>
nnoremap <Tab><Tab> <Tab>
nnoremap <C-g> <Tab>
xnoremap <C-g> <Tab>
" ------------------------
" textobj
" ------------------------
if v:version >= 704 || has('nvim')
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/vim-textobj-user
        set rtp+=$ADDINS_PATH/vim-textobj-syntax
        set rtp+=$ADDINS_PATH/vim-textobj-uri
        set rtp+=$ADDINS_PATH/vim-textobj-line
    endif
    " map for uri
    nmap <leader>vu viu
    nmap ,vu vau
    " ------------------------
    " function find space
    " ------------------------
    function! SpaceA()
        call search('\v(\s|^)', 'ebW', line('.'))
        let head_pos = getpos('.')
        call search('\v(\s|$)', 'eW', line('.'))
        let tail_pos = getpos('.')
        return ['v', head_pos, tail_pos]
    endfunction
    function! SpaceI()
        call search('\v(\s|^)', 'ebW', line('.'))
        " If not at the beginning of a line, move right.
        if getline('.')[col('.') - 1] == " "
            normal! l
        endif
        let head_pos = getpos('.')
        echo head_pos
        call search('\v(\s|$)', 'eW', line('.'))
        " If not at the end of a line, move left.
        if getline('.')[col('.') - 1] == " "
            normal! h
        endif
        let tail_pos = getpos('.')
        return ['v', head_pos, tail_pos]
    endfunction
    " ------------------------
    " viS vaS to select between space
    " ------------------------
    call textobj#user#plugin('space', {
                \   'space': {
                \     'select-a-function': 'SpaceA',
                \     'select-a': 'aS',
                \     'select-i-function': 'SpaceI',
                \     'select-i': 'iS',
                \   },
                \ })
    nmap <leader>vs viS
    nmap ,vs vaS
    " ------------------------
    " function find block
    " ------------------------
    function! BlockA()
        let beginline = search('# %%', 'ebW')
        if beginline == 0
            normal! gg
        endif
        let head_pos = getpos('.')
        let endline  = search('# %%', 'eW')
        if endline == 0
            normal! G
        endif
        let tail_pos = getpos('.')
        return ['V', head_pos, tail_pos]
    endfunction
    function! BlockI()
        let beginline = search('# %%', 'ebW')
        if beginline == 0
            normal! gg
            let beginline = 1
        else
            normal! j
        endif
        let head_pos = getpos('.')
        let endline = search('# %%', 'eW')
        if endline == 0
            normal! G
        elseif endline > beginline
            normal! k
        endif
        let tail_pos = getpos('.')
        return ['V', head_pos, tail_pos]
    endfunction
    " ------------------------
    " vib vab to select a block
    " ------------------------
    call textobj#user#plugin('block', {
                \   'block': {
                \     'select-a-function': 'BlockA',
                \     'select-a': 'aB',
                \     'select-i-function': 'BlockI',
                \     'select-i': 'iB',
                \     'region-type': 'V'
                \   },
                \ })
    nmap <leader>vb viB
    nmap ,vb vaB
endif
nmap gb viio<C-[>^
nmap <leader>vi vii
nmap ,vi vai
nmap <leader>va via
nmap ,va vaa
nmap <leader>vf vif
nmap ,vf vaf
nmap <leader>vu viu
nmap ,vu vau
nmap <leader>vl vil
nmap ,vl val
nmap <leader>vt vi%
nmap ,vt va%
" ------------------------
" matchup
" ------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-matchup
endif
function! s:matchup_convenience_maps()
    xnoremap <sid>(std-I) I
    xnoremap <sid>(std-A) A
    xmap <expr> I mode()=='<c-v>'?'<sid>(std-I)':(v:count?'':'1').'i'
    xmap <expr> A mode()=='<c-v>'?'<sid>(std-A)':(v:count?'':'1').'a'
    for l:v in ['', 'v', 'V', '<c-v>']
        execute 'omap <expr>' l:v.'I%' "(v:count?'':'1').'".l:v."i%'"
        execute 'omap <expr>' l:v.'A%' "(v:count?'':'1').'".l:v."a%'"
    endfor
endfunction
call s:matchup_convenience_maps()
nmap <S-tab> g%
" --------------------------
" vim-visual-multi
" --------------------------
nnoremap <silent> c<Cr> *Ncgn
if !exists('g:leovim_loaded') && (has('nvim') || v:version >=800)
    set rtp+=$ADDINS_PATH/vim-visual-multi
    let g:VM_custom_remaps = {'<c-j>': '<ESC>', '<c-k>': 'q', '<c-h>': 'Q'}
endif
" --------------------------
" surround
" --------------------------
nmap ,ew viwS
nmap ,ee v$hS
nmap ,es vt<Space>S
" --------------------------
" sandwich
" --------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-sandwich
endif
nmap s <Nop>
xmap s <Nop>
xmap is <Plug>(textobj-sandwich-query-i)
xmap as <Plug>(textobj-sandwich-query-a)
omap is <Plug>(textobj-sandwich-query-i)
omap as <Plug>(textobj-sandwich-query-a)
xmap in <Plug>(textobj-sandwich-auto-i)
xmap an <Plug>(textobj-sandwich-auto-a)
omap in <Plug>(textobj-sandwich-auto-i)
omap an <Plug>(textobj-sandwich-auto-a)
xmap im <Plug>(textobj-sandwich-literal-query-i)
xmap am <Plug>(textobj-sandwich-literal-query-a)
omap im <Plug>(textobj-sandwich-literal-query-i)
omap am <Plug>(textobj-sandwich-literal-query-a)
nmap <leader>vn vin
nmap ,vn van
nmap <leader>vm vim
nmap ,vm vam
nmap <leader>vy viy
nmap ,vy vay
" ------------------------
" easymotion
" ------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-easymotion
    set rtp+=$ADDINS_PATH/vim-easymotion-chs
    let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj;23456789'
endif
source $CONFIG_PATH/easymotion.vim
" ------------------------
" clever-f
" ------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/clever-f.vim
    let g:clever_f_smart_case = 1
endif
nmap ;     <Plug>(clever-f-repeat-forward)
nmap <M-z> <Plug>(clever-f-repeat-back)
xmap ;     <Plug>(clever-f-repeat-forward)
xmap <M-z> <Plug>(clever-f-repeat-back)
" --------------------------
" local settings
" --------------------------
set nocompatible
set noai
set nosi
set noimdisable
set nojoinspaces
set nospell
set noeb
set nocursorcolumn
set nowrap
set nofoldenable
set nolist
set nobackup
set nowritebackup
set swapfile
set splitright
set splitbelow
set cursorline
set incsearch
set ruler
set hlsearch
set showmode
set vb
set autochdir
set number
set smartcase
set ignorecase
set showmatch
set expandtab
set wildcharm=<Tab>
set shiftwidth=4
set softtabstop=4
set backspace=indent,eol,start
set linespace=0
set enc=utf8
set fencs=utf8,gbk,gb2312,gb18030,cp936,ucs-bom,latin-1
set termencoding=utf-8
set winminheight=0
set scrolljump=5
set scrolloff=3
set mouse=a
try
    set shortmess+=a
catch
    " +a get use short messages
endtry
try
    set shortmess+=c
catch
    " +c get rid of annoying completion notifications
endtry
" -----------------------------------
" switchbuf
" -----------------------------------
set buftype=
set switchbuf=useopen,usetab,newtab
" -----------------------------------
" wildmenu
" -----------------------------------
set wildmenu
if has('nvim')
    set wildoptions+=pum
    cnoremap <expr> <up>   pumvisible() ? '<left>'  : '<up>'
    cnoremap <expr> <down> pumvisible() ? '<right>' : '<down>'
    cnoremap <expr> <C-k>  pumvisible() ? '<left>'  : '<C-k>'
    cnoremap <expr> <C-j>  pumvisible() ? '<right>' : '<C-j>'
else
    set wildmode=longest,list
endif
if has('patch-7.4.2201') || has('nvim')
    set signcolumn=yes
endif
if has('wildignore')
    set wildignore+=*\\tmp\\*,*/tmp/*,*.swp,*.exe,*.dll,*.so,*.zip,*.tar*,*.7z,*.rar,*.gz,*.pyd
endif
" no gui menu
set guioptions-=e
set guioptions-=T
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=M
set guioptions-=m
" --------------------------
" python_support
" --------------------------
let g:python3_host_prog = get(g:, 'python3_host_prog', '')
let g:python_host_prog  = get(g:, 'python_host_prog', '')
try
    let s:jl = execute('jumps')
    unlet s:jl
    let g:has_execute_func = 1
catch
    let g:has_execute_func = 0
endtry
function! Execute(cmd)
    let cmd = a:cmd
    if g:has_execute_func
        return execute(cmd)
    else
        redir => output
        silent execute cmd
        redir END
        return output
    endif
endfunction
" --------------------------
" GetPyxVersion
" --------------------------
function! GetPyxVersion()
    if CYGWIN()
        return 0
    endif
    try
        let l:pyx_version = Execute('py3 print(sys.version)')[1:6]
    catch
        let l:pyx_version = ''
    endtry
    if l:pyx_version == ''
        try
            let l:pyx_version = Execute('py print(sys.version)')[1:6]
        catch
            return 0
        endtry
    endif
    let s:python_version = str2float(l:pyx_version[0:2])
" --------------------------
" python import
" --------------------------
    if s:python_version > 3
python3 << Python3EOF
try:
    import vim
    import ipdb
except Exception:
    pass
else:
    vim.command('let g:ipdb_import = 1')
try:
    import vim
    import pygments
except Exception:
    pass
else:
    vim.command('let g:pygments_import = 1')
Python3EOF
    endif
    if l:pyx_version[5] == ' '
        return s:python_version + str2float(l:pyx_version[4])/100
    else
        return s:python_version + str2float(l:pyx_version[4:5])/1000
    endif
endfunction
let g:python_version = GetPyxVersion()
" --------------------------
" set python_host_prog
" --------------------------
if g:python_version > 3
    if g:python3_host_prog == ''
        if WINDOWS() && !has('nvim')
            try
                let g:python3_host_prog = exepath('python3')
                if get(g:, 'python3_host_prog', '') == ''
                    let g:python3_host_prog = exepath('python')
                endif
            catch
                let g:python3_host_prog = exepath('python')
            endtry
        elseif has('nvim') || v:version >= 800
            let g:python3_host_prog = exepath('python3')
            if get(g:, 'python3_host_prog', '') == ''
                let g:python3_host_prog = exepath('python')
            endif
        else
            let g:python3_host_prog = system('which python3')
        endif
    endif
    let g:python_exe_path = g:python3_host_prog
elseif g:python_version > 2
    if  g:python_host_prog == ''
        if WINDOWS() && !has('nvim')
            try
                let g:python_host_prog = exepath('python2')
                if get(g:, 'python_host_prog', '') == ''
                    let g:python_host_prog = exepath('python')
                endif
            catch
                let g:python_host_prog = exepath('python')
            endtry
        elseif has('nvim') || v:version >= 800
            let g:python_host_prog = exepath('python')
            if get(g:, 'python_host_prog', '') == ''
                let g:python_host_prog = exepath('python')
            endif
        else
            let g:python_host_prog = system('which python')
        endif
    endif
    let g:python_exe_path = g:python_host_prog
endif
" --------------------------
" keymaps
" --------------------------
" home end
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
inoremap <C-a> <Esc>I
inoremap <expr><C-e> pumvisible()? "\<ESC>a":"\<ESC>A"
inoremap <C-f> <ESC>A
nnoremap <C-f> $
xnoremap <C-f> $
onoremap <C-f> $
nnoremap L     $
xnoremap L     $
onoremap L     $
inoremap <C-b> <ESC>I
inoremap <M-F> <ESC>I
nnoremap <C-b> ^
xnoremap <C-b> ^
onoremap <C-b> ^
nnoremap H     ^
xnoremap H     ^
onoremap H     ^
" ------------------------
" nop remap
" ------------------------
map ÏP <F1>
map ÏQ <F2>
map ÏR <F3>
map ÏS <F4>
map <F1> <Nop>
map <F2> <Nop>
map <F3> <Nop>
map <F4> <Nop>
map <F5> <Nop>
map <F6> <Nop>
map <F7> <Nop>
map <F8> <Nop>
map <F9> <Nop>
map <F10> <Nop>
map <F11> <Nop>
map <F12> <Nop>
map <C-z> <Nop>
" ------------------------
" some enhanced shortcuts
" ------------------------
nmap <Tab> <Nop>
xmap <Tab> <Nop>
nmap <C-q> q
nmap <C-m> %
xmap <C-m> %
nmap *     *``
nmap #     #``
nmap !     :!
xmap .     :<C-u>normal .<Cr>
xmap !     y:<C-u>!<C-r>"
" ------------------------
" search visual select range
" ------------------------
function! EscapedSearch() range
    let l:saved_reg = @"
    execute 'normal! vgvy'
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
xnoremap <silent> * :<C-u>call EscapedSearch()<CR>/<C-R>=@/<CR><CR>N
xnoremap <silent> # :<C-u>call EscapedSearch()<CR>?<C-R>=@/<CR><CR>N
xnoremap g; y:<C-u>%s/<C-R>"/
xnoremap g/ y/<C-R>"
" ------------------------
" quit
" ------------------------
nnoremap <leader>ex Q
nnoremap Q  <C-w>z
xnoremap Q  <C-w>z
nnoremap qq <C-w>z
xnoremap qq <C-w>z
" close current buffer
function! Close_current_buf()
    let buffer_num=len(getbufinfo({'buflisted':1}))
    if buffer_num>1
        :bp|bd #
    else
        :bd
    endif
    return buffer_num
endfunction
nnoremap <silent><leader>q :let buf_colosed=Close_current_buf()<CR>
nnoremap <silent><M-q> :q!<Cr>
nnoremap <silent>,q    :qall!<Cr>
nnoremap <silent>zq    :tabclose<Cr>
" ------------------------
" save
" ------------------------
nnoremap <M-s> :w!<CR>
inoremap <M-s> <ESC>:w!<CR>
nnoremap <M-S> :wa!<CR>
inoremap <M-S> <ESC>:wa!<CR>
nnoremap <M-W> :wq!<CR>
inoremap <M-W> <ESC>:wq!<CR>
" ------------------------
" esc
" ------------------------
inoremap <M-q> <ESC>
xnoremap <M-q> <ESC>
cnoremap <M-q> <ESC>
" ------------------------
" remap for cusor move insert mode
" ------------------------
inoremap <M-l> <Right>
inoremap <M-h> <Left>
inoremap <M-j> <Down>
inoremap <M-k> <Up>
" ------------------------
" tab control
" ------------------------
set tabpagemax=10
set showtabline=2
nnoremap <silent> gh     :tabprevious<CR>
nnoremap <silent> <Tab>n :tabm +1<CR>
nnoremap <silent> <Tab>p :tabm -1<CR>
nnoremap <silent> <Tab>1 :tabm 0<CR>
nnoremap <silent> <Tab>0 :tabm<CR>
nnoremap <silent> <M-1> :tabn1<CR>
nnoremap <silent> <M-2> :tabn2<CR>
nnoremap <silent> <M-3> :tabn3<CR>
nnoremap <silent> <M-4> :tabn4<CR>
nnoremap <silent> <M-5> :tabn5<CR>
nnoremap <silent> <M-6> :tabn6<CR>
nnoremap <silent> <M-7> :tabn7<CR>
nnoremap <silent> <M-8> :tabn8<CR>
nnoremap <silent> <M-9> :tabn9<CR>
nnoremap <silent> <M-0> :tablast<CR>
inoremap <silent> <M-1> <ESC>:tabn1<CR>
inoremap <silent> <M-2> <ESC>:tabn2<CR>
inoremap <silent> <M-3> <ESC>:tabn3<CR>
inoremap <silent> <M-4> <ESC>:tabn4<CR>
inoremap <silent> <M-5> <ESC>:tabn5<CR>
inoremap <silent> <M-6> <ESC>:tabn6<CR>
inoremap <silent> <M-7> <ESC>:tabn7<CR>
inoremap <silent> <M-8> <ESC>:tabn8<CR>
inoremap <silent> <M-9> <ESC>:tabn9<CR>
inoremap <silent> <M-0> <ESC>:tablast<CR>
" open window in tab
nnoremap <leader><Tab> :tabe<Space>
nnoremap <leader><Cr>  :e!<Cr>
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
endfunc
" get a single tab name
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
        endif
        return '[No Name]'
    endif
endfunc
" get a single tab label
function! Vim_NeatTabLabel(n)
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfunc
" get a single tab label in gui
function! Vim_NeatGuiTabLabel()
    let l:num = v:lnum
    let l:buflist = tabpagebuflist(l:num)
    let l:winnr = tabpagewinnr(l:num)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfunc
" setup new tabline, just like %M%t in macvim
set tabline=%!Vim_NeatTabLine()
set guitablabel=%{Vim_NeatGuiTabLabel()}
" map config and open file using system browser when has gui
if g:gui_running > 0 || WINDOWS()
    function! s:Filter_Push(desc, wildcard)
        let g:browsefilter .= a:desc . " (" . a:wildcard . ")\t" . a:wildcard . "\n"
    endfunc
    let g:browsefilter = ''
    call s:Filter_Push("All Files", "*")
    call s:Filter_Push("Python", "*.py;*.pyw")
    call s:Filter_Push("C/C++/Object-C", "*.c;*.cpp;*.cc;*.h;*.hh;*.hpp;*.m;*.mm")
    call s:Filter_Push("Rust", "*.rs")
    call s:Filter_Push("Java", "*.java")
    call s:Filter_Push("Text", "*.txt")
    call s:Filter_Push("Vim Script", "*.vim")
    function! Open_Browse()
        let l:path = expand("%:p:h")
        if l:path == '' | let l:path = getcwd() | endif
        if exists('g:browsefilter') && exists('b:browsefilter')
            if g:browsefilter != ''
                let b:browsefilter = g:browsefilter
            endif
        endif
        exec 'browse tabnew '.fnameescape(l:path)
    endfunc
    nnoremap <silent><M-b> :call Open_Browse()<Cr>
    nnoremap <silent><M-n> :tabnext<CR>
    nnoremap <silent><M-p> :tabprevious<CR>
    nnoremap <silent><M-N> :tabm +1<CR>
    nnoremap <silent><M-P> :tabm -1<CR>
    nnoremap <silent><M-\>  <C-w>5+
    nnoremap <silent><M-\|> <C-w>5-
    nnoremap <M-M> :tabm<Space>
    nnoremap <M-B> :registers<Cr>
else
    nnoremap <Tab>M :tabm<Space>
    nnoremap <M-k>r :registers<Cr>
endif
" ------------------------
" yank && paste
" ------------------------
if has('clipboard')
    inoremap <silent><M-v> <C-r><C-o>*
    cnoremap <silent><M-v> <C-r><C-o>*
    nnoremap <silent><M-v> "*gP
    xnoremap <silent><M-v> "*gP
    if has('nvim')
        nnoremap <silent><M-c> "*y:let  @*=trim(@*)<Cr>
        xnoremap <silent><M-c> "*y:let  @*=trim(@*)<Cr>
        nnoremap <silent><M-x> "*x:let  @*=trim(@*)<Cr>
        xnoremap <silent><M-x> "*x:let  @*=trim(@*)<Cr>
        nnoremap <silent><M-X> "*dd:let @*=trim(@*)<Cr>
        nnoremap <silent><M-C> "*yy:let @*=trim(@*)<Cr>
        nnoremap <silent>Y     "*y$:let @*=trim(@*)<Cr>
    else
        nnoremap <silent><M-c> "*y
        xnoremap <silent><M-c> "*y
        nnoremap <silent><M-x> "*x
        xnoremap <silent><M-x> "*x
        nnoremap <silent><M-X> "*dd
        nnoremap <silent><M-C> "*yy
        nnoremap <silent>Y     "*y$
    endif
else
    nnoremap <silent><M-c> "0y
    xnoremap <silent><M-c> "0y
    nnoremap <silent><M-x> "0x
    xnoremap <silent><M-x> "0x
    nnoremap <silent><M-C> "0yy
    nnoremap <silent>Y     "0y$
endif
nnoremap ,y :0,-y<Cr>
nnoremap ,Y vGy
function! YankFromBeginning() abort
    let original_cursor_position = getpos('.')
    exec("normal! v^y")
    call setpos('.', original_cursor_position)
endfunction
nnoremap gy :call YankFromBeginning()<Cr>:echo "Yank from line beginning"<Cr>
xnoremap zp "_c<ESC>p"
xnoremap zP "_c<ESC>P"
xnoremap <M-V> <C-c>`.``gvp``P
" ------------------------
" 缩进等
" ------------------------
imap <M-x> <BS>
imap <M-a> <Del>
xmap >>    >gv
xmap <<    <gv
nnoremap <silent> gj j
nnoremap <silent> gk k
nnoremap <silent> j gj
nnoremap <silent> k gk
" ------------------------
" marks
" ------------------------
nnoremap m<Cr> :marks<Cr>
function! Delmarks()
    let l:m = join(filter(
                \ map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)'),
                \ 'line("''".v:val) == line(".")'))
    if !empty(l:m)
        exe 'delmarks' l:m
    endif
endfunction
nnoremap <silent> m<Space> :call Delmarks()<cr>
" ------------------------
" basic toggle and show
" ------------------------
nnoremap <leader>b :ls<CR>
nnoremap <M-k>n :set nonu! nonu?<CR>
nnoremap <M-k>i :set invrelativenumber<CR>
nnoremap <M-k>f :set nofoldenable! nofoldenable?<CR>
nnoremap <M-k>w :set nowrap! nowrap?<CR>
nnoremap <M-k>h :set nohlsearch? nohlsearch!<CR>
nnoremap <M-k>s :colorscheme<Space>
nnoremap <M-k>t :setfiletype<Space>
nnoremap <M-k>c :command<Cr>
" ------------------------
" pastemode toggle
" ------------------------
if has('nvim') || g:gui_running > 0 || WINDOWS() && !has('nvim')
   inoremap <M-O> <C-o>O
endif
nmap <M-O> O
imap <M-o> <C-\><C-o>:set paste<Cr>
nmap <M-o> :set nopaste! nopaste?<CR>
" ------------------------
" copy to register
" ------------------------
for i in range(26)
    let l_char = nr2char(char2nr('a') + i)
    let u_char = nr2char(char2nr('A') + i)
    exec 'nnoremap <leader>Y' . l_char . ' viw"'. l_char . 'y'
    exec 'nnoremap <leader>Y' . u_char . ' viw"'. u_char . 'y'
    exec 'nnoremap <leader>yy' . l_char . ' "'. l_char . 'yy'
    exec 'nnoremap <leader>yy' . u_char . ' "'. u_char . 'yy'
    exec 'xnoremap <leader>yy' . l_char . ' "'. l_char . 'y'
    exec 'xnoremap <leader>yy' . u_char . ' "'. u_char . 'y'
endfor
"Yank a line without leading whitespaces and line break
nnoremap <leader>yu mp_yg_`p
"Copy a line without leading whitespaces and line break to clipboard
nnoremap <leader>yw mp_"+yg_`P
"Copy file path
nnoremap <leader>yp :let @*=expand("%:p")<cr>:echo '-= File path copied=-'<Cr>
"Copy file name
nnoremap <leader>yf :let @*=expand("%:t")<cr>:echo '-= File name copied=-'<Cr>
"Copy bookmark position reference
nnoremap <leader>yb :let @*=expand("%:p").':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark  copied=-'<cr>'
" cd git project root
if executable('git')
    command! CDR cd %:h | cd `git rev-parse --show-toplevel`
    nnoremap <leader>cr :CDR<CR>
endif
" cd module root
command! CDM cd %:h | exec 'cd' fnameescape(fnamemodify(findfile("pom.xml", escape(expand('%:p:h'), ' ') . ";"), ':h'))
nnoremap <leader>cm :CDM<CR>
" cd folder of current file
nnoremap <leader>cd :lcd %:p:h<Cr>
" ------------------------
" z remap
" ------------------------
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
" map for fold
" ------------------------
nmap <leader>zz za
nmap <leader>zo zfi{
nmap ,zo        zfa{
nmap <leader>zb zfib
nmap ,zb        zfab
nmap <leader>zi zfii
nmap ,zi        zfai
nmap <leader>zc zfic
nmap ,zc        zfac
nmap <leader>zf zfif
nmap ,zf        zfaf
" ------------------------
" Find merge conflict markers
" ------------------------
nnoremap <leader>cf /\v^[<\|=>]{7}( .*\|$)<CR>
nnoremap <leader>cF ?\v^[<\|=>]{7}( .*\|$)<CR>
" --------------------------
" autocmd
" --------------------------
" goto last visited line
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" optional reset cursor on start:
aug resetCursor
    au!
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
aug END
au FileType * setlocal tw=160
au VimEnter,BufNewFile,BufRead *.jl set filetype=julia
au VimEnter,BufNewFile,BufRead *.idr set filetype=idris
au VimEnter,BufNewFile,BufRead *.conf set filetype=conf
au VimEnter,BufNewFile,BufRead *.tex set filetype=latex
au VimEnter,BufNewFile,BufRead *.pandoc set filetype=pandoc
au VimEnter,BufNewFile,BufRead *.coffee set filetype=coffee
au VimEnter,BufNewFile,BufRead *.conf.template set filetype=nginx
au VimEnter,BufNewFile,BufRead *.vimrc*,*.vim set filetype=vim
au VimEnter,BufNewFile,BufRead *.tmux.conf set filetype=tmux
au VimEnter,BufNewFile,BufRead *.ts,*.vue set filetype=typescript
au VimEnter,BufNewFile,BufRead *.R,*.Rnw,*.Rd set filetype=r
au VimEnter,BufNewFile,BufRead *.md,*.markdown,*readme*,*.Rmd set filetype=markdown
" sepcial setting for different type of files
au FileType help,man setlocal number
au FileType python au BufWritePre <buffer> :%retab
au FileType yaml,yml setlocal shiftwidth=2 softtabstop=2 tabstop=2
au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" cd file dir
au WinEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://"   " terminal
            \ && bufname("") !~ "Rg"                   " rg
            \ && bufname("")[0] != "!"                 " some special buf
            \ && getbufvar(winbufnr(winnr()), "&buftype") != "popup"
            \ | lcd %:p:h | endif
augroup AUTOClose
    " 离开InsertMode时，关闭补全，非paste模式
    au InsertLeave * set nopaste
    " 补全完成后关闭预览窗口
    au InsertLeave  * if pumvisible() == 0 | pclose | endif
    au CompleteDone * if pumvisible() == 0 | pclose | endif
    " 退出侧边等
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype")  == "preview"|q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "netrw" |q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "ctrlsf" |q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "qf" |q|endif
augroup END
" --------------------------
" file templates
" --------------------------
autocmd BufNewFile .gitignore       0r $CONFIG_PATH/templates/gitignore.spec
autocmd BufNewFile .lintr           0r $CONFIG_PATH/templates/lintr.spec
autocmd BufNewFile .vimspector.json 0r $CONFIG_PATH/templates/vimspector.json.spec
autocmd SwapExists * let v:swapchoice = 'o'
" from https://github.com/antoinemadec/FixCursorHold.nvim
if has('nvim')
    let g:cursorhold_updatetime = get(g:, 'cursorhold_updatetime', 100)
    let g:fix_cursorhold_nvim_timer = -1
    set eventignore+=CursorHold,CursorHoldI
    augroup fix_cursorhold_nvim
        autocmd!
        autocmd CursorMoved * call CursorHoldTimer()
        autocmd CursorMovedI * call CursorHoldITimer()
    augroup end
    function! CursorHold_Cb(timer_id) abort
        set eventignore-=CursorHold
        doautocmd <nomodeline> CursorHold
        set eventignore+=CursorHold
    endfunction
    function! CursorHoldI_Cb(timer_id) abort
        set eventignore-=CursorHoldI
        doautocmd <nomodeline> CursorHoldI
        set eventignore+=CursorHoldI
    endfunction
    function! CursorHoldTimer() abort
        call timer_stop(g:fix_cursorhold_nvim_timer)
        let g:fix_cursorhold_nvim_timer = timer_start(g:cursorhold_updatetime, 'CursorHold_Cb')
    endfunction
    function! CursorHoldITimer() abort
        call timer_stop(g:fix_cursorhold_nvim_timer)
        let g:fix_cursorhold_nvim_timer = timer_start(g:cursorhold_updatetime, 'CursorHoldI_Cb')
    endfunction
endif
" Comment highlighting
augroup todostrings
    autocmd!
    autocmd Syntax * call matchadd('Todo', '\v\W\zs(BUG|TODO|FIXME|WARN|ERROR)(\(.{-}\))?:?', -1)
    autocmd Syntax * call matchadd('Todo', '\v\W\zs(NOTE|XXX|HELP|OPTIMIZE|HACK)(\(.{-}\))?:?', -2)
augroup END
augroup help_browsing
    autocmd!
    autocmd FileType help nnoremap <buffer> <CR> <C-]>
    autocmd FileType help nnoremap <buffer> <BS> <C-T>
augroup END
augroup Folds
    autocmd!
    autocmd FileType tex setl foldlevel=0 foldnestmax=1
    autocmd BufRead,BufNewFile *.c,*.cpp,*.cc setl foldlevel=0 foldnestmax=1
augroup END
" ------------------------
" second window
" ------------------------
function! Tools_PreviousCursor(mode)
    if winnr('$') <= 1
        return
    endif
    noautocmd silent! wincmd p
    if a:mode == 0
        exec "normal! \<C-u>"
    elseif a:mode == 1
        exec "normal! \<C-d>"
    elseif a:mode == 2
        exec "normal! \<C-e>"
    elseif a:mode == 3
        exec "normal! \<C-y>"
    elseif a:mode == 4
        exec "normal! \<C-w>q"
    elseif a:mode == 5
        exec "normal! zz"
    endif
    noautocmd silent! wincmd p
endfunction
nnoremap <silent><M-U> :call Tools_PreviousCursor(0)<cr>
nnoremap <silent><M-D> :call Tools_PreviousCursor(1)<Cr>
nnoremap <silent><M-E> :call Tools_PreviousCursor(2)<cr>
nnoremap <silent><M-Y> :call Tools_PreviousCursor(3)<Cr>
nnoremap <silent><M-Q> :call Tools_PreviousCursor(4)<Cr>
nnoremap <silent><M-Z> :call Tools_PreviousCursor(5)<Cr>
inoremap <silent><M-U> <ESC>:call Tools_PreviousCursor(0)<cr>
inoremap <silent><M-D> <ESC>:call Tools_PreviousCursor(1)<Cr>
inoremap <silent><M-E> <ESC>:call Tools_PreviousCursor(2)<cr>
inoremap <silent><M-Y> <ESC>:call Tools_PreviousCursor(3)<Cr>
inoremap <silent><M-Q> <ESC>:call Tools_PreviousCursor(4)<Cr>
inoremap <silent><M-Z> <ESC>:call Tools_PreviousCursor(5)<Cr>
" --------------------------
" vim-cycle
" --------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-cycle
    let g:cycle_no_mappings   = 1
    let g:cycle_max_conflict  = 1
    let g:cycle_phased_search = 1
endif
nmap <silent> <leader>a <Plug>CycleNext
xmap <silent> <leader>a <Plug>CycleNext
nmap <silent> <leader>x <Plug>CyclePrev
xmap <silent> <leader>x <Plug>CyclePrev
noremap <silent> <Plug>CycleFallbackNext <C-A>
noremap <silent> <Plug>CycleFallbackPrev <C-X>
let g:cycle_default_groups = [
            \   [['true', 'false']],
            \   [['yes', 'no']],
            \   [['on', 'off']],
            \   [['+', '-']],
            \   [['>', '<']],
            \   [['"', "'"]],
            \   [['==', '!=']],
            \   [['and', 'or']],
            \   [["in", "out"]],
            \   [["up", "down"]],
            \   [["min", "max"]],
            \   [["get", "set"]],
            \   [["add", "remove"]],
            \   [["to", "from"]],
            \   [["read", "write"]],
            \   [["only", "except"]],
            \   [['without', 'with']],
            \   [["exclude", "include"]],
            \   [["asc", "desc"]],
            \   [["begin", "end"]],
            \   [["first", "last"]],
            \   [["slow", "fast"]],
            \   [["small", "large"]],
            \   [["push", "pull"]],
            \   [["before", "after"]],
            \   [["new", "delete"]],
            \   [["while", "until"]],
            \   [["up", "down"]],
            \   [["left", "right"]],
            \   [["top", "bottom"]],
            \   [["one", "two", "three", "four", "five", "six", "seven",
            \     "eight", "nine", "ten"]],
            \   [['是', '否']],
            \   [['void', 'int', 'char']],
            \   [['{:}', '[:]', '(:)'], 'sub_pairs'],
            \   [['（:）', '「:」', '『:』'], 'sub_pairs'],
            \   [['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
            \     'Friday', 'Saturday'], 'hard_case', {'name': 'Days'}],
            \   [['January', 'February', 'March', 'April', 'May', 'June',
            \     'July', 'August', 'September', 'October', 'November',
            \     'December'], 'hard_case', {'name': 'Months'}],
            \ ]
" --------------------------
" indentline
" --------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/indentLine/after
    let g:indentLine_color_dark      = 1 " (default: 2)
    let g:indentLine_color_tty_light = 7 " (default: 4)
    let g:indentLine_enabled         = 0
    let g:indentLine_color_term      = 239
    let g:indentLine_bgcolor_term    = 202
    let g:indentLine_color_gui       = '#A4E57E'
    let g:indentLine_bgcolor_gui     = '#FF5F00'
    let g:indentLine_char_list       = ['|', '¦', '┆', '┊']
endif
nnoremap <M-h>i :IndentLinesToggle<Cr>
" --------------------------
" TMUX config
" --------------------------
if $TMUX != ''
    set ttimeoutlen=30
elseif &ttimeoutlen > 60 || &ttimeoutlen <= 0
    set ttimeoutlen=60
endif
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-tmux-navigator
    let g:tmux_navigator_no_mappings = 1
endif
" NOTE, no need of installed tmux
nnoremap <silent><M-H> :TmuxNavigateLeft<cr>
nnoremap <silent><M-L> :TmuxNavigateRight<cr>
nnoremap <silent><M-J> :TmuxNavigateDown<cr>
nnoremap <silent><M-K> :TmuxNavigateUp<cr>
inoremap <silent><M-H> <ESC>:TmuxNavigateLeft<cr>
inoremap <silent><M-L> <ESC>:TmuxNavigateRight<cr>
inoremap <silent><M-J> <ESC>:TmuxNavigateDown<cr>
inoremap <silent><M-K> <ESC>:TmuxNavigateUp<cr>
if g:has_terminal == 2
    tnoremap <C-w><C-w> <C-_><C-w>
    tnoremap <silent><M-H> <C-_>:TmuxNavigateLeft<cr>
    tnoremap <silent><M-L> <C-_>:TmuxNavigateRight<cr>
    tnoremap <silent><M-J> <C-_>:TmuxNavigateDown<cr>
    tnoremap <silent><M-K> <C-_>:TmuxNavigateUp<cr>
elseif g:has_terminal == 1
    tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>
    tnoremap <silent><M-H> <C-\><C-n>:TmuxNavigateLeft<cr>
    tnoremap <silent><M-L> <C-\><C-n>:TmuxNavigateRight<cr>
    tnoremap <silent><M-J> <C-\><C-n>:TmuxNavigateDown<cr>
    tnoremap <silent><M-K> <C-\><C-n>:TmuxNavigateUp<cr>
endif
nmap <M-k><M-h> <C-w><C-h>
nmap <M-k><M-l> <C-w><C-l>
nmap <M-k><M-j> <C-w><C-j>
nmap <M-k><M-k> <C-w><C-k>
nmap <M-k><M-w> <C-w><C-w>
nmap <M-k><M-f> <C-w>f
" --------------------------
" vim-plug
" --------------------------
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-plug
    let g:plug_threads = 8
endif
" --------------------------
" begin of vim-plug
" --------------------------
silent! call plug#begin(expand('~/.vim/plug'))
function! s:trim(str)
   return substitute(a:str, '[\/]\+$', '', '')
endfunction
function! MyPlug(repo, ...)
    if a:0 > 1
        return s:err('Invalid number of arguments (1..2)')
    endif
    let repo = s:trim(a:repo)
    let idir = '$INSTALL_PATH/' . split(repo, '\/')[1]
    if a:0 == 0
        let dict = {'dir': idir}
    else
        let dict = a:1
        if !has_key(dict, 'dir')
            let dict['dir'] = idir
        endif
    endif
    Plug repo, dict
endfunction
command! -nargs=+ -bar MyPlug call MyPlug(<args>)
" --------------------------
" install plugins
" --------------------------
source $CONFIG_PATH/install/complete_lint.vim
source $CONFIG_PATH/install/plugs.vim
source $CONFIG_PATH/install/languages.vim
" --------------------------
" lightline
" --------------------------
if has('statusline')
    set laststatus=2
    if get(g:, 'lint_tool', '') == 'ale'
        MyPlug 'maximbaz/lightline-ale'
    endif
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/lightline.vim
    endif
    source $SETTINGS_PATH/lightline.vim
endif
" --------------------------
" zfvim
" --------------------------
if HasPlug('wubi') || HasPlug('pinyin')
    MyPlug 'ZSaberLv0/ZFVimIM'
    MyPlug 'ZSaberLv0/ZFVimJob'
    MyPlug 'ZSaberLv0/ZFVimIM_openapi'
    if HasPlug('wubi')
        let g:input_method = 'zfvim_wubi'
        MyPlug 'ZSaberLv0/ZFVimIM_wubi_base'
    else
        let g:input_method = 'zfvim_pinyin'
    endif
    MyPlug 'ZSaberLv0/ZFVimIM_pinyin'
endif
" --------------------------
" test vimrc
" --------------------------
nnoremap <leader>er :tabe ~/.config/.vimrc<Cr>
if filereadable(expand("~/.config/.vimrc")) | source $HOME/.config/.vimrc | endif
" --------------------------
" end of vim-plug
" --------------------------
silent! call plug#end()
if Installed('ZFVimIM')
    augroup ZFVIM
        autocmd!
        autocmd FileType * if ZFVimIME_started() | setlocal omnifunc= | endif
    augroup END
    let g:ZFVimIM_cachePath=$HOME.'/.cache/ZFVimIM'
    let g:ZFVimIM_symbolMap = {
                \   '`' : ['·'],
                \   '!' : ['！'],
                \   '$' : ['￥'],
                \   '^' : ['……'],
                \   '-' : [''],
                \   '_' : ['——'],
                \   '(' : ['（'],
                \   ')' : ['）'],
                \   '[' : ['【'],
                \   ']' : ['】'],
                \   '<' : ['《'],
                \   '>' : ['》'],
                \   '\' : ['、'],
                \   '/' : ['、'],
                \   ';' : ['；'],
                \   ':' : ['：'],
                \   ',' : ['，'],
                \   '.' : ['。'],
                \   '?' : ['？'],
                \   "'" : ['‘', '’'],
                \   '"' : ['“', '”'],
                \   ' ' : [''],
                \   '0' : [''],
                \   '1' : [''],
                \   '2' : [''],
                \   '3' : [''],
                \   '4' : [''],
                \   '5' : [''],
                \   '6' : [''],
                \   '7' : [''],
                \   '8' : [''],
                \   '9' : [''],
                \ }
endif
" --------------------------
" Update an Install
" --------------------------
if executable('git')
    command! MyPlugInstall PlugClean! | PlugInstall --sync
    command! MyPlugUpdate  PlugClean! | PlugUpdate --sync
    nnoremap ,U        :MyPlugInstall<Cr>
    nnoremap <leader>U :MyPlugUpdate<Cr>
    " git.vim
    source $SETTINGS_PATH/git.vim
endif
" --------------------------
" addvanced settings
" --------------------------
source $SETTINGS_PATH/fuzzy_finder.vim
source $SETTINGS_PATH/tree_browser.vim
source $SETTINGS_PATH/grep_tool.vim
source $SETTINGS_PATH/complete_engine.vim
source $SETTINGS_PATH/run_tool.vim
source $SETTINGS_PATH/lint_tool.vim
source $SETTINGS_PATH/symbol_tool.vim
source $SETTINGS_PATH/debug_tool.vim
source $SETTINGS_PATH/differ.vim
source $SETTINGS_PATH/sidebar.vim
source $SETTINGS_PATH/format.vim
source $SETTINGS_PATH/schemes.vim
" searchindex
try
    if Installed("vim-searchindex")
        set shortmess+=S
    else
        set shortmess-=S
    endif
catch
    " pass
endtry
" --------------------------
" whichkey
" --------------------------
if v:version >= 704 && !HasPlug('no-whichkey')
    if !exists('g:leovim_loaded')
        if v:version >= 800 || has('nvim')
            set rtp+=$ADDINS_PATH/vim-which-key
        else
            set rtp+=$ADDINS_PATH/vim-which-key-legacy
        endif
    endif
    " vim-which-key
    set timeout
    set ttimeout
    set timeoutlen=300
    set updatetime=200
    let g:which_key_group_dicts = ''
    if has('patch-8.1.1615') || has('nvim')
        let g:which_key_use_floating_win = 1
    else
        let g:which_key_use_floating_win = 0
    end
    " basic keys
    nnoremap <Space> :WhichKey       " "<Cr>
    nnoremap <Tab>   :WhichKey       "<lt>Tab>"<Cr>
    nnoremap ,       :WhichKey       ","<Cr>
    nnoremap \       :WhichKey       '\'<Cr>
    nnoremap [       :WhichKey       "["<Cr>
    nnoremap ]       :WhichKey       "]"<Cr>
    xnoremap <Space> :WhichKeyVisual " "<Cr>
    xnoremap ,       :WhichKeyVisual ","<Cr>
    xnoremap \       :WhichKeyVisual "\"<Cr>
    xnoremap <Tab>   :WhichKeyVisual "<lt>Tab>"<Cr>
    xnoremap [       :WhichKeyVisual "["<Cr>
    xnoremap ]       :WhichKeyVisual "]"<Cr>
    " g
    nnoremap g1 :WhichKey "g"<Cr>
    nnoremap s1 :WhichKey "s"<Cr>
    nnoremap z1 :WhichKey "Z"<Cr>
    " M- keys
    nnoremap <M-g> :WhichKey "<lt>M-g>"<Cr>
    nnoremap <M-h> :WhichKey "<lt>M-h>"<Cr>
    nnoremap <M-j> :WhichKey "<lt>M-j>"<Cr>
    nnoremap <M-k> :WhichKey "<lt>M-k>"<Cr>
    nnoremap <M-l> :WhichKey "<lt>M-l>"<Cr>
    nnoremap <M-y> :WhichKey "<lt>M-y>"<Cr>
    " search
    if get(g:, 'grep_tool', '') =~ 'leaderf' || get(g:, 'grep_tool', '') =~ 'coc' || get(g:, 'grep_tool', '') =~ 'ctrlsf'
        nnoremap <M-f> :WhichKey '<lt>M-f>'<Cr>
        xnoremap <M-f> :WhichKeyVisual '<lt>M-f>'<Cr>
    endif
    if Installed('vimspector')
        nnoremap <M-m> :WhichKey '<lt>M-m>'<Cr>
        nnoremap <M-u> :WhichKey '<lt>M-u>'<Cr>
    endif
    if Installed("vim-table-mode")
        nnoremap = :WhichKey '='<Cr>
    endif
endif
" --------------------------
" show impport config
" --------------------------
function! s:getVimVersion()
    let l:result=[]
    if has('nvim')
        if g:gui_running > 0
            call add(l:result, 'gnvim-')
        else
            call add(l:result, 'nvim-')
        endif
        let v = api_info().version
        call add(l:result, printf('%d.%d.%d', v.major, v.minor, v.patch))
    else
        if g:gui_running > 0
            call add(l:result, 'gvim-')
        else
            call add(l:result, 'vim-')
        endif
        redir => l:msg | silent! execute ':version' | redir END
        call add(l:result, matchstr(l:msg, 'VIM - Vi IMproved\s\zs\d.\d\ze'))
        call add(l:result, '.')
        call add(l:result, matchstr(l:msg, ':\s\d-\zs\d\{1,4\}\ze'))
    endif
    return join(l:result, "")
endfunction
function! Version()
    let params_dict = {
                \ 'version':      s:getVimVersion(),
                \ 'python':       g:python_version,
                \ 'colors':       g:colors_name,
                \ 'fuzzy_finder': g:fuzzy_finder,
                \ 'tree_browser': g:tree_browser,
                \ }
    if get(g:, 'complete_engine', '') != ''
        let params_dict['complete_engine'] = g:complete_engine
    endif
    if get(g:, 'complete_sinippet', '') != ''
        let params_dict['complete_sinippet'] = g:complete_sinippet
    endif
    if get(g:, 'python_exe_path', '') != ''
        let params_dict['python_exe_path'] = g:python_exe_path
    endif
    if get(g:, 'grep_tool', '') != ''
        let params_dict['grep_tool'] = g:grep_tool
    endif
    if get(g:, 'debug_tool', '') != ''
        let params_dict['debug_tool'] = g:debug_tool
    endif
    if get(g:, 'terminal_plus', '') != ''
        let params_dict['terminal_plus'] = g:terminal_plus
    endif
    if get(g:, 'symbol_tool', '') != ''
        let params_dict['symbol_tool'] = g:symbol_tool
    endif
    if get(g:, 'lint_tool', '') != ''
        let params_dict['lint_tool'] = g:lint_tool
    endif
    if get(g:, 'input_method', '') != ''
        let params_dict['input_method'] = g:input_method
    endif
    if get(g:, 'pygments_import', 0) > 0
        let params_dict['pygments_import'] = g:pygments_import
    endif
    if has('nvim') && exists('$TERM') && $TERM != ''
        let params_dict['$TERM'] = $TERM
    elseif !has('nvim') && exists('&term') && &term != ''
        let params_dict['term'] = &term
    endif
    echo string(params_dict)
endfunction
command! Version call Version()
nnoremap <M-k>v :Version<Cr>
nnoremap <M-k>V :version<Cr>
" --------------------------
" more config
" --------------------------
if filereadable(expand("~/.config/.vimrc")) | source $HOME/.config/.vimrc | endif
" --------------------------
" inweb setting
" --------------------------
if HasPlug('inweb') && !WINDOWS() && g:gui_running == 0
    nmap <M-=> <C-r>
    nmap <M-+> <C-i>
    xmap <M-+> <C-i>
    imap <M-+> <C-i>
    nmap <M-_> <C-o>
    xmap <M-_> <C-o>
    imap <M-_> <C-o>
    nmap <M-}> <C-n>
    xmap <M-}> <C-n>
    nmap <M-{> <C-p>
    xmap <M-}> <C-p>
endif
" --------------------------
" IDE integration
" --------------------------
func! s:getBookmarkUnderCursor(text, pos)
		" Find the start location
		let p = a:pos
		while p >= 0 && a:text[p] =~ '\f'
				let p = p - 1
		endwhile
		let p = p + 1
		" Match file name and position
		let l:m = matchlist(a:text, '\v(\f+)%([#:](\d+))?%(:(\d+))?', p)
		if len(l:m) > 0
				return [l:m[1], l:m[2], l:m[3]]
		endif
		return []
endfunc
func! s:OpenFileLinkInIde(text, pos, ide)
		let l:location = s:getBookmarkUnderCursor(a:text, a:pos)
    if a:ide == 'code'
        let ide = 'code --goto'
    else
        let ide = a:ide
    endif
    " location 0: file, 1: line, 2: column
		if l:location[0] != ''
				if l:location[1] != ''
						if l:location[2] != ''
                if ide =~ 'code'
                    let l:command = ide . " " . l:location[0] . ":" . str2nr(l:location[1]) . ":" . str2nr(l:location[2])
                else
                    let l:command = ide . " --column " . str2nr(l:location[2]) . " " . l:location[0] . ":" . str2nr(l:location[1])
                endif
								echo l:command
								exec "AsyncRun -silent " . l:command
						else
                let l:command = ide . " " . l:location[0] . ":" . str2nr(l:location[1])
								echo l:command
								exec "AsyncRun -silent " . l:command
						endif
				else
						let l:command = ide . " " . l:location[0]
						echo l:command
						exec "AsyncRun -silent " . l:command
				endif
		else
				echo "Not a valid file path"
		endif
endfunc
if executable('idea64')
    command! OpenFileLinkInIdea call s:OpenFileLinkInIde(getline("."), col("."), "idea64")
    nnoremap <leader>eI :OpenFileLinkInIdea<cr>
    nnoremap <leader>ei :<c-r>=printf("AsyncRun -silent idea64 --line %d %s", line("."), expand("%:p"))<cr><cr>
endif
if executable('pycharm64')
    command! OpenFileLinkInPycharm call s:OpenFileLinkInIde(getline("."), col("."), "pycharm64")
    nnoremap <leader>eP :OpenFileLinkInPycharm<cr>
    nnoremap <leader>ep :<c-r>=printf("AsyncRun -silent pycharm64 --line %d %s", line("."), expand("%:p"))<cr><cr>
endif
if executable('code')
    command! OpenFileLinkInVscode call s:OpenFileLinkInIde(getline("."), col("."), "code")
    nnoremap <leader>eV :OpenFileLinkInVscode<cr>
    nnoremap <leader>ev :<c-r>=printf("AsyncRun -silent code --goto %s:%d", expand("%:p"), line("."))<cr><cr>
endif
" ------------------------
" reload config shortcut
" ------------------------
nnoremap ,<space> :source ~/.leovim.conf/init.vim<Cr>
" --------------------------
" set loaded
" --------------------------
let g:leovim_loaded = 1
