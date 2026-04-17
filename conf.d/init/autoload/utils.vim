" ----------------------------------------
" System Detection Functions
" ----------------------------------------
function! utils#is_neovide() abort
    return exists('g:neovide') && has('nvim')
endfunction

function! utils#is_vscode() abort
    return exists('g:vscode') && has('nvim')
endfunction

function! utils#is_win() abort
    return has('win32') || has('win64')
endfunction

function! utils#is_macos() abort
    return has('macunix')
endfunction

function! utils#is_win32unix() abort
    return has('win32unix') && !has('macunix')
endfunction

function! utils#is_linux() abort
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction

function! utils#is_unix() abort
    return has('unix') && !has('win32unix')
endfunction

function! utils#has_gui() abort
    if has('gui_running')
        return 1
    elseif has('nvim')
        if has('gui_vimr')
            return 1
        elseif exists('g:GuiLoaded') && g:GuiLoaded != 0
            return 1
        elseif exists('*nvim_list_uis') && len(nvim_list_uis()) > 0
            return get(nvim_list_uis()[0], 'ext_termcolors', 0) ? 0 : 1
        elseif exists("+termguicolors") && (&termguicolors) != 0
            return 1
        elseif utils#is_neovide()
            return 1
        elseif utils#is_vscode()
            return 0
        else
            return 0
        endif
    else
        return 0
    endif
endfunction

function! utils#has_packadd() abort
    return exists(':packadd') > 0
endfunction

function! utils#has_qfloc() abort
    if !empty(getqflist()) || !empty(getloclist(0))
        return 1
    else
        return 0
    endif
endfunction

function! utils#has_map(key, mode) abort
    try
        let mp = maparg(a:key, a:mode)
        if empty(mp) || mp =~# 'Nop'
            return 0
        else
            return 1
        endif
    catch /.*/
        return 0
    endtry
endfunction
" ----------------------------------------
" File Path Functions
" ----------------------------------------
function! utils#get_dir(path) abort
    if isdirectory(a:path)
      let dir = fnamemodify(a:path, ':p')
    elseif filereadable(a:path)
      let dir = fnamemodify(a:path, ':p:h')
    else
      let dir = fnamemodify(getcwd(), ':p')
    endif
    let dir = fnamemodify(dir, ':~')
    let dir = escape(dir, ' %#|"')
    return dir
endfunction

function! utils#abs_dir() abort
    return substitute(utils#expand('%:p:h', 1), '^vscode-remote://[^/]\+/%2B[^/]\+', '', '')
endfunction

function! utils#abs_path() abort
    return substitute(utils#expand('%:p', 1), '^vscode-remote://[^/]\+/%2B[^/]\+', '', '')
endfunction

function! utils#file_name() abort
    return utils#expand('%:t', 1)
endfunction

function! utils#file_name_no_ext() abort
    return utils#expand('%:t:r', 1)
endfunction

function! utils#file_readonly() abort
    return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction

function! utils#get_root_dir(...) abort
    let init_dir = utils#abs_dir()
    let curr_dir = init_dir
    if a:0
        let l:root = a:000
    else
        let l:root = g:root_patterns + g:root_files
    endif
    while 1
        if utils#is_win() && curr_dir[1] == ':' || utils#is_unix() && curr_dir ==# '/'
            return init_dir
        endif
        for each in l:root
            let chk_path = curr_dir . '/' . each
            if isdirectory(chk_path) || filereadable(chk_path)
                return substitute(curr_dir, '\', '/', 'g')
            endif
        endfor
        let curr_dir = fnamemodify(curr_dir, ":h")
    endwhile
endfunction

function! utils#get_vcs_dir() abort
    return utils#get_root_dir('.git', '.svn', '.hg', '.cvs', '.bzr')
endfunction
" ----------------------------------------
" String Utility Functions
" ----------------------------------------
function! utils#trim(str) abort
    return substitute(a:str, "^\s\+\|\s\+$", "", "g")
endfunction

function! utils#expand(path, ...) abort
    if a:0 && a:1
        return substitute(fnameescape(expand(a:path)), '\', '/', 'g')
    else
        return fnameescape(expand(a:path))
    endif
endfunction

function! utils#execute(cmd) abort
    if exists("*execute")
        return execute(a:cmd)
    else
        redir => output
        silent! execute a:cmd
        redir END
        return output
    endif
endfunction

function! utils#string_to_float(str, ...) abort
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

function! utils#escape(param) abort
    " Escape search-special chars but allow literal '#'
    return substitute(escape(a:param, '/\.*$^~['), '\n', '\\n', 'g')
endfunction

function! utils#trip_whitespace() abort
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

function! utils#get_cword() abort
    return expand('<cword>')
endfunction

function! utils#get_visual(...) abort
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
        return utils#escape(join(lines, "\n"))
    else
        return join(lines, "\n")
    endif
endfunction

function! utils#get_python_prog()
    let l:venv_path = ''
    let l:root_dir = utils#get_root_dir('venv', 'env', '.venv', '.env')
    let l:venv_names = ['venv', 'env', '.venv', '.env']
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
            let $PATH = l:venv_path . "\bin;". $PATH
        else
            let l:python_prog = l:venv_path . '/bin/python'
            let $PATH = l:venv_path . "/bin:". $PATH
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

function! utils#move_to_end_and_add_semicolon() abort
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

function! utils#enhance_search() range
    let l:saved_reg = @"
    execute 'normal! vgvy'
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
" ----------------------------------------
" GUI Functions (from main.vim)
" ----------------------------------------
function! utils#toggle_fullscreen() abort
    if has('libcall') && !has('nvim') && utils#has_gui() && utils#is_win()
        let g:gvimfullscreendll = $HOME ."\\.leovim.windows\\tools\\gvimfullscreen.dll"
        call libcallnr(g:gvimfullscreendll, "ToggleFullScreen", -1)
    endif
endfunction

function! utils#set_alpha(alpha) abort
    if has('libcall') && !has('nvim') && utils#has_gui() && utils#is_win()
        let g:VimAlpha = get(g:, 'VimAlpha', 255) + a:alpha
        if g:VimAlpha < 95
            let g:VimAlpha = 95
        endif
        if g:VimAlpha > 255
            let g:VimAlpha = 255
        endif
        let g:gvimfullscreendll = $HOME ."\\.leovim.windows\\tools\\gvimfullscreen.dll"
        call libcall(g:gvimfullscreendll, 'SetAlpha', g:VimAlpha)
    endif
endfunction
" ----------------------------------------
" Mode Function
" ----------------------------------------
function! utils#mode() abort
    let l:modes_dict={
                \ "\<C-V>": 'V·Block',
                \ 'Rv': 'V·Replace',
                \ 'n':  'NORMAL',
                \ 'v':  'VISUAL',
                \ 'V':  'V·Line',
                \ 'i':  'INSERT',
                \ 'R':  'R',
                \ 'c':  'Command',
                \}
    let m = mode()
    if has_key(l:modes_dict, m)
        let m = l:modes_dict[m]
    else
        let m = ""
    endif
    return m
endfunction
" ----------------------------------------
" AutoClose
" ----------------------------------------
function! utils#is_popup()
    return exists('*win_gettype') && win_gettype() ==# 'popup'
endfunction
let s:autoclose_ft_buf = [
            \ 'netrw', 'tagbar', 'vista', 'vista_kind',
            \ 'qf', 'loclist', 'rg', 'outline', 'nofile',
            \ 'leaderf', 'fzf', 'help', 'man',
            \ 'git', 'gitcommit', 'fugitive', 'fugtiveblame', 'diff',
            \ 'vimspector', 'vimspectorprompt',
            \ 'terminal', 'floaterm', 'undotree',
            \ 'dropbar', 'dropbar_preview',
            \ ]
function! s:autoclose(check_last_win) abort
    if utils#is_popup()
        return 0
    endif
    let ft = tolower(getbufvar(winbufnr(winnr()), '&ft'))
    let bt = tolower(getbufvar(winbufnr(winnr()), '&bt'))
    if a:check_last_win == 0
        return ft == '' || index(s:autoclose_ft_buf, ft) >= 0 || index(s:autoclose_ft_buf, bt) >= 0
    elseif winnr("$") <= 1 && a:check_last_win > 0
        return index(s:autoclose_ft_buf, ft) >= 0 || index(s:autoclose_ft_buf, bt) >= 0
    else
        return 0
    endif
endfunction
function! utils#is_ignored() abort
    return s:autoclose(0)
endfunction
function! utils#autoclose_lastwin() abort
    return s:autoclose(1)
endfunction
" ----------------------------------------
" choose one
" ----------------------------------------
function! s:get_char_from_used(used, text) abort
    " 作用: 为菜单项字符串 text 选择一个未被占用的快捷键，并插入 '&' 标记。
    " 参数:
    "   a:used -> 已占用的快捷键列表(单字符)，用于避免冲突。
    "   a:text -> 原始菜单文本。
    " 返回:
    "   new_used: 追加了新快捷键后的列表
    "   marked  : 带 '&' 的菜单文本(例如 "&Open" 或 "O&pen")
    let used = a:used
    let lowered = map(copy(a:used), 'tolower(v:val)')
    let text = a:text
    " 第一阶段: 优先从 text 自身字符中挑选未占用字符。
    " pos: 当前检查的字符下标。
    for pos in range(len(text))
        if index(lowered, tolower(text[pos])) < 0
            call add(used, text[pos])
            if pos == 0
                return [used, '&' . text]
            else
                return [used, text[:pos-1] . '&' . text[pos:]]
            endif
        endif
    endfor
    " 第二阶段(兜底): 若 text 全部字符都已占用，从 fallback 常量中找可用字符。
    " fallback: 候选兜底快捷键集合(数字+符号常量)。
    " fb_len: fallback 的长度，避免重复计算。
    let fallback = '123456789!@#$%^*-=_+'
    let fb_len = len(fallback)
    for pos in range(fb_len)
        if index(used, fallback[pos]) < 0
            call add(used, fallback[pos])
            return [used, '&' . fallback[pos] . text]
        endif
    endfor
    " 全部占用时退化为原始文本。
    return [used, text]
endfunction
function! utils#choose_one(lst, ...) abort
    " 作用: 在一组字符串中让用户选择一项，返回被选中的原始字符串。
    " 参数:
    "   a:lst      -> 候选项列表。
    "   a:1(可选)  -> 对话框标题 title，默认 "Please choose one."。
    "   a:2(可选)  -> add_num，>=1 时使用数字快捷键(&1..&9)。
    "   a:3(可选)  -> 取消项文本，默认 "0None"。
    " 返回:
    "   选中的 items[sel]；取消或无效选择返回 ""。
    let items = a:lst
    if len(items) == 0
        return ""
    elseif len(items) > 9
        " confirm() 模式下仅支持最多 9 个有效候选项。
        let items = items[:8]
    endif
    if a:0 && a:1 != ''
        let title = a:1
    else
        let title = "Please choose one."
    endif
    if a:0 >= 2 && a:2 >= 1
        let use_num = 1
    else
        let use_num = 0
    endif
    " num: 当前菜单项计数；menu: 传给 quickui/confirm 的展示文本列表。
    let num = 0
    let menu = []
    for item in items
        let num += 1
        if use_num
            call add(menu, '&' . num . ' ' . item)
        else
            " used_char: 已占用的快捷键集合，仅在非数字模式使用。
            if !exists('used_char')
                let used_char = []
            endif
            let [used_char, item] = s:get_char_from_used(used_char, item)
            call add(menu, item)
        endif
    endfor
    " 优先使用 vim-quickui 的 listbox；不存在时回退到内置 confirm()。
    if pack#planned('vim-quickui')
        " boxopt 常量说明:
        "   title -> 窗口标题
        "   index -> 默认光标位置(读取 g:quickui#listbox#cursor)
        "   w     -> 列表宽度(64)
        let boxopt = {'title': title, 'index':g:quickui#listbox#cursor, 'w': 64}
        let sel = quickui#listbox#inputlist(menu, boxopt)
        if sel >= 0
            return items[sel]
        endif
    else
        let num += 1
        if a:0 >= 3 && a:3 != ''
            call add(menu, '&' . a:3)
        else
            call add(menu, '&0None')
        endif
        let text = join(menu, "\n")
        let sel = confirm(title, text, num)
        if sel > 0 && sel < num
            return items[sel - 1]
        endif
    endif
    return ""
endfunction
