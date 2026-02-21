" ------------------------------------
" Meta key
" ------------------------------------
if has('gui_running') && has('macunix')
    set macmeta
elseif !has('nvim') && utils#is_linux()
    set noesckeys
endif
let s:metacode_group = ["'", ",", ".", ";", ":", "/", "?", "{", "}", "-", "_", "=", "+"]
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
" basic setting
" ------------------------------------
if !has('nvim-0.11')
    let &termencoding=&enc
endif
" ------------------------------------
" map enhance
" ------------------------------------
nnoremap <M-A> ggVG
nnoremap gQ gw
xnoremap gQ gw
" remap for cusor move insert mode
inoremap <M-l> <Right>
inoremap <M-h> <Left>
inoremap <M-j> <Down>
inoremap <M-k> <Up>
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
nnoremap <M-k>z :set nofoldenable! nofoldenable?<Cr>
nnoremap <M-k>u :set ff=unix<Cr>:%s/\r//g<Cr>
if has('nvim')
    nnoremap <M-k>U :UpdateRemotePlugins<Cr>
endif
nnoremap = :<C-r>=
" ------------------------------
" file functions
" ------------------------------
nnoremap <M-k>r :echo utils#get_root_dir()<Cr>
" --------------------------
" python_support
" --------------------------
let g:python_prog = get(g:, 'python_prog', utils#get_python_prog())
if has('nvim')
    let g:python3_host_prog = get(g:, 'python3_host_prog', g:python_prog)
endif
if utils#is_win32unix()
    let g:python_version = 0
else
    " NOTE, cannot use pyxeval/py3eval/pyeval, otherwise neovim will error when pip packages are not installed.
    try
        let py_version = utils#execute('py3 print(sys.version)')
    catch
        try
            let py_version = utils#execute('py print(sys.version)')
        catch
            let py_version = ""
        endtry
    endtry
    let py_version_match = matchstr(py_version, '\v\zs\d{1,}\.\d{1,}\.\d{1,}\ze')
    if py_version_match == ''
        let g:python_version = 0
    else
        let g:python_version = utils#string_to_float(py_version_match, 2)
        if g:python_version > 3
            try
                call py3eval('import pygments')
                let g:pygments_import = get(g:, 'pygments_import', 1)
            catch /.*/
                let g:pygments_import = get(g:, 'pygments_import', 0)
            endtry
            try
                call py3eval('import pretty_errors')
                let g:pretty_errors_import = get(g:, 'pretty_errors_import', 1)
            catch /.*/
                let g:pretty_errors_import = get(g:, 'pretty_errors_import', 0)
            endtry
        endif
    endif
endif
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
if has('termguicolors') || utils#is_win() || utils#has_gui()
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
    let g:has_tricolor = 0
endif
" -----------------------------------
" git version
" -----------------------------------
if executable('git')
    let s:git_version_raw = matchstr(system('git --version'), '\v\zs\d{1,4}.\d{1,4}.\d{1,4}\ze')
    let g:git_version = utils#string_to_float(s:git_version_raw)
else
    let g:git_version = 0
endif
" ------------------------------
" node install tool
" ------------------------------
if executable('node') && executable('npm')
    let s:node_version_raw = matchstr(system('node --version'), '\vv\zs\d{1,4}.\d{1,4}\ze')
    let g:node_version = utils#string_to_float(s:node_version_raw)
else
    let g:node_version = 0
endif
" --------------------------
" set PATH && term
" --------------------------
if utils#is_win()
    if get(g:, 'leovim_loaded', 0) == 0
        let local_bin = utils#expand("$HOME/.local/bin")
        let tools_bin = utils#expand("$HOME/.leovim.windows")
        if isdirectory(local_bin) && $PATH !~ local_bin
            let $PATH = local_bin . ';' . $PATH
        endif
        if isdirectory(tools_bin)
            let $PATH = tools_bin . '\gtags\bin;' . $PATH
            let $PATH = tools_bin . '\cppcheck;' . $PATH
            let $PATH = tools_bin . '\tools;' . $PATH
        endif
    endif
    set winaltkeys=no
    if utils#has_gui()
        set lines=999
        set columns=999
    endif
    " ToggleFullScreen and SetAlpha moved to utils.vim
    if has('libcall') && !has('nvim') && utils#has_gui()
        let g:gvimfullscreendll = $HOME .'\.leovim.windows\tools\gvimfullscreen.dll'
        let g:VimAlpha = 255
        nnoremap <silent><C-cr> <ESC>:call utils#toggle_fullscreen()<Cr>
        nnoremap <silent><M-\>  :call utils#set_alpha(5)<Cr>
        nnoremap <silent><M-\|> :call utils#set_alpha(-5)<Cr>
    endif
else
    if get(g:, 'leovim_loaded', 0) == 0 && isdirectory($HOME . "/.leovim.unix")
        if utils#is_linux()
            let $PATH = $HOME . "/.leovim.unix/linux:" . $PATH
        elseif utils#is_macos()
            if system('uname -m') =~? 'arm64'
                let $PATH = $HOME . "/.leovim.unix/macos/arm64:" . $PATH
            else
                let $PATH = $HOME . "/.leovim.unix/macos/x86_64:" . $PATH
            endif
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
    elseif utils#has_gui() == 0 && !has('nvim')
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
if utils#is_win() && pack#get('tags') || utils#is_unix()
    if utils#is_win() && filereadable(utils#expand("~/.leovim.windows/tools/ctags.exe"))
        let g:ctags_type = 'Universal-json'
    elseif executable('ctags')
        try
            let g:ctags_type = split(system('ctags --version'), ' ')[0]
            if g:ctags_type =~ 'Universal'
                if system('ctags --list-features | grep json') =~ 'json'
                    let g:ctags_type = 'Universal-json'
                else
                    let g:ctags_type = 'Universal'
                endif
            endif
        catch
            let g:ctags_type = ''
        endtry
    else
        let g:ctags_type = ''
    endif
    " gtags must be set based on ctags
    if utils#is_win()
        let $GTAGSCONF = utils#expand($HOME . "/.leovim.windows/gtags/share/gtags/gtags.conf")
    endif
    if executable('gtags') && get(g:, 'ctags_type', '') != '' && exists('$GTAGSCONF') && filereadable($GTAGSCONF)
        let s:gtags_version = matchstr(system('gtags --version'), '\v\zs\d{1,2}.\d{1,2}.\d{1,2}\ze')
        let g:gtags_version = utils#string_to_float(s:gtags_version, 2)
        if get(g:, 'pygments_import', 0)
            let $GTAGSLABEL = 'native-pygments'
        elseif g:ctags_type =~ 'Universal'
            let $GTAGSLABEL = 'new-ctags'
        else
            let $GTAGSLABEL = 'ctags'
        endif
    else
        let g:gtags_version = 0
    endif
else
    let g:ctags_type = ''
    let g:gtags_version = 0
endif
" ------------------------------
" install packs
" ------------------------------
for vim in split(glob("$PLUG_DIR/*.vim"), "\n")
    exec "source " . vim
endfor
" ------------------------------
" <M-Key> map
" ------------------------------
for k in s:metacode_group
    let mkey = '<M-'. k . ">"
    exec "set " . mkey . "=\e" . k
    let modes = ['n', 'x', 'o', 'i']
    for mode in modes
        " maparg returns non-empty characters if mapping exists in that mode
        if empty(maparg(mkey, mode))
            exec(mode . "map " . mkey . " <Nop>")
        endif
    endfor
endfor
nnoremap <M-z> :set nowrap! nowrap?<Cr>
" ------------------------------
" set mason PATH
" ------------------------------
let mason_bin = utils#expand('~/.leovim.d/mason/bin')
if !pack#planned('mason.nvim') && !get(g:, 'leovim_loaded', 0) && isdirectory(mason_bin)
    if utils#is_win()
        let $PATH = mason_bin . ';' . $PATH
    else
        let $PATH = mason_bin . ':' . $PATH
    endif
endif
