set rtp^=$CONF_D_DIR
let &termencoding=&enc
" ------------------------------------
" Meta key
" ------------------------------------
if MACVIM()
    set macmeta
endif
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
nnoremap <M-k>f :set nofoldenable! nofoldenable?<Cr>
nnoremap <M-k>u :set ff=unix<Cr>:%s/\r//g<Cr>
nnoremap <M-z> :set nowrap! nowrap?<Cr>
if has('nvim')
    nnoremap <M-k>U :UpdateRemotePlugins<Cr>
endif
" ------------------------------
" file functions
" ------------------------------
function! AbsDir()
    return Expand('%:p:h', 1)
endfunction
function! AbsPath()
    return Expand('%:p', 1)
endfunction
function! FileName()
    return Expand('%:t', 1)
endfunction
function! FileNameNoEXT()
    return Expand('%:t:r', 1)
endfunction
function! FileReadonly()
    return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction
function! GetRootDir(...)
    let init_dir = AbsDir()
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
nnoremap <M-k>r :echo GetRootDir()<Cr>
" --------------------------
" python_support
" --------------------------
function! s:python_prog()
    let l:root_dir = GetRootDir()
    let l:venv_path = ''
    let l:venv_names = ['venv', '.venv', 'env', '.env']
    for l:venv_name in l:venv_names
        let l:possible_venv = l:root_dir . '/' . l:venv_name
        if isdirectory(l:possible_venv)
            let l:venv_path = l:possible_venv
            break
        endif
    endfor
    " set python_prog path if venv_path
    if !empty(l:venv_path)
        if has('win32') || has('win64')
            let l:python_prog = l:venv_path . '/Scripts/python.exe'
        else
            let l:python_prog = l:venv_path . '/bin/python'
        endif
    endif
    if filereadable(get(l:, "python_prog", ""))
        let g:ale_python_pylint_executable = l:python_prog
        let g:ale_python_flake8_executable = l:python_prog
        return l:python_prog
    elseif executable('python3')
        return exepath('python3')
    elseif executable('python')
        return exepath('python')
    else
        return ""
    endif
endfunction
let g:python_prog = get(g:, 'python_prog', s:python_prog())
if has('nvim')
    let g:python3_host_prog = get(g:, 'python3_host_prog', g:python_prog)
endif
if WIN32UNIX()
    let g:python_version = 0
else
    " NOTE, 不能使用pyxeval/py3eval/pyeval, 否则neovim 没有pip安装相关包时，执行会出错.
    try
        let py_version = Execute('py3 print(sys.version)')
    catch
        try
            let py_version = Execute('py print(sys.version)')
        catch
            let py_version = ""
        endtry
    endtry
    let py_version_match = matchstr(py_version, '\v\zs\d{1,}\.\d{1,}\.\d{1,}\ze')
    if py_version_match == ''
        let g:python_version = 0
    else
        let g:python_version = StringToFloat(py_version_match, 2)
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
" set mason PATH
" ------------------------------
let mason_bin = Expand('~/.leovim.d/mason/bin')
if g:complete_engine != 'cmp' && isdirectory(mason_bin) && $PATH !~ 'mason/bin'
    if WINDOWS()
        let $PATH = mason_bin . ';' . $PATH
    else
        let $PATH = mason_bin . ':' . $PATH
    endif
endif
" ------------------------------
" <M-Key> map
" ------------------------------
" NOTE: must be set affer all plugins are installed
function! s:set_metacode(key)
    exec "set <M-".a:key.">=\e".a:key
endfunction
for c in s:metacode_group
    call s:set_metacode(c)
endfor
