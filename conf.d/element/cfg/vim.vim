set rtp^=$CONF_D_DIR
let &termencoding=&enc
" ------------------------------------
" Meta key
" ------------------------------------
let s:metacode_group = ["'", ",", ".", ";", ":", "/", "?", "{", "}", "-", "_", "=", "+"]
if has('nvim') || HAS_GUI()
    for k in s:metacode_group
        let mkey = "<M-" . k . ">"
        exec printf("map %s <Nop>", mkey)
    endfor
endif
" NOTE: add metacode_group must be execute after map to nop
for i in range(10)
    " 48 is ascii of 0
    call add(s:metacode_group, nr2char(48 + i))
endfor
for i in range(26)
    " 65 is ascii of A
    call add(s:metacode_group, nr2char(65 + i))
    " 97 is ascii of a
    call add(s:metacode_group, nr2char(97 + i))
endfor
" ------------------------------------
" map enhance
" ------------------------------------
nnoremap <M-A> ggVG
nnoremap gQ gw
xnoremap gQ gw
nnoremap <M-:> :
inoremap <M-:> <ESC>:
xnoremap <M-:> <ESC>:
snoremap <M-:> <ESC>:
cnoremap <M-:> <C-u>
" remap for cusor move insert mode
inoremap <M-l> <Right>
inoremap <M-h> <Left>
inoremap <M-j> <Down>
inoremap <M-k> <Up>
" <C-o>/<C-m>
nnoremap <C-m> <C-i>
" save
nnoremap <C-s> :w!<Cr>
onoremap <C-s> :w!<Cr>
cnoremap <C-s> w!<Cr>
inoremap <C-s> <C-o>:w!<Cr>
xnoremap <C-s> <ESC>:w!<Cr>
nnoremap <leader>W :wa!<Cr>
xnoremap <leader>W <ESC>:wa!<Cr>
" buffers mark messages
nnoremap <leader><leader> <C-^>
" map to <esc>
inoremap <M-q> <ESC>
xnoremap <M-q> <ESC>
cnoremap <M-q> <ESC>
inoremap <M-w> <ESC>
xnoremap <M-w> <ESC>
cnoremap <M-w> <ESC>
" basic set
nnoremap <M-k>f :set nofoldenable! nofoldenable?<Cr>
nnoremap <M-k>w :set nowrap! nowrap?<Cr>
nnoremap <M-k>u :set ff=unix<Cr>:%s/\r//g<Cr>
if has('nvim')
    nnoremap <M-k>U :UpdateRemotePlugins<Cr>
endif
function! s:toggle_modify() abort
    if &modifiable
        setl nomodifiable
        echo 'Current buffer is now non-modifiable'
    else
        setl modifiable
        echo 'Current buffer is now modifiable'
    endif
endfunction
command! ToggleModity call s:toggle_modify()
nnoremap <M-k><space> :ToggleModity<Cr>
" --------------------------
" python_support
" --------------------------
function! s:get_python_exe()
    try
        if executable('python3')
            let python = exepath('python3')
        elseif executable('python')
            let python = exepath('python')
        elseif executable('python2')
            let python = exepath('python2')
        else
            return ""
        endif
    catch
        return ""
    endtry
endfunction
let g:python3_host_prog = get(g:, 'python3_host_prog', s:get_python_exe())
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
    endif
    return pyx_version
endfunction
let g:python_exe = s:get_python_exe()
let g:python_version = s:get_python_version()
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
" ===============================================================================================================
" install begin
" ===============================================================================================================
let $DEPLOY_DIR = Expand("~/.leovim.d")
call plug#begin(Expand("$DEPLOY_DIR/pack/add/opt"))
if filereadable(Expand("$DEPLOY_DIR/pack.vim"))
    source ~/.leovim.d/pack.vim
endif
for vim in split(glob("$INSTALL_DIR/*.vim"), "\n")
    exec "source " . vim
endfor
function! s:plug_update() abort
    let vimrc_opt = Expand('~/.vimrc.opt')
    if filereadable(vimrc_opt)
        execute "source " . vimrc_opt
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
let mason_bin = Expand('~/.leovim.d/mason/bin')
if g:complete_engine != 'cmp' && isdirectory(mason_bin) && $PATH !~ 'mason/bin'
    if WINDOWS()
        let $PATH = mason_bin . ';' . $PATH
    else
        let $PATH = mason_bin . ':' . $PATH
    endif
endif
" ===============================================================================================================
" <M-Key> map for vim
" ===============================================================================================================
" NOTE: must be set affer all plugins are installed
if !has('nvim') && HAS_GUI() == 0
    function! s:set_metacode(key)
        exec "set <M-".a:key.">=\e".a:key
    endfunction
    for c in s:metacode_group
        call s:set_metacode(c)
    endfor
endif
