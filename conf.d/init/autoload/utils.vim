" ----------------------------------------
" System Detection Functions
" ----------------------------------------
function! utils#is_vscode() abort
    return exists('g:vscode')
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
        elseif exists('g:neovide')
            return 1
        elseif utils#is_vscode()
            return 0
        elseif exists('g:GuiLoaded') && g:GuiLoaded != 0
            return 1
        elseif exists('*nvim_list_uis') && len(nvim_list_uis()) > 0
            return get(nvim_list_uis()[0], 'ext_termcolors', 0) ? 0 : 1
        elseif exists("+termguicolors") && (&termguicolors) != 0
            return 1
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
" ----------------------------------------
" File Path Functions
" ----------------------------------------
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
        if utils#is_win() && curr_dir[-2:-1] == ':/' || utils#is_unix() && curr_dir ==# '/'
            return init_dir
        endif
        for each in l:root
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
let s:autoclose_ft_buf = [
            \ 'netrw', 'tagbar', 'vista', 'vista_kind',
            \ 'qf', 'loclist', 'rg', 'outline',
            \ 'leaderf', 'fzf', 'help', 'man', 'startify',
            \ 'git', 'gitcommit', 'fugitive', 'fugtiveblame', 'diff',
            \ 'vimspector', 'vimspectorprompt',
            \ 'terminal', 'floaterm', 'popup', 'undotree',
            \ 'dropbar', 'dropbar_preview',
            \ ]
function! s:autoclose(check_last_win) abort
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
" format
" ----------------------------------------
function! utils#format(visual)
    let col = col('.')
    let line = line('.')
    if a:visual
        silent! normal gv=
    else
        silent! normal ggVG=
    endif
    call cursor(line, col)
    echo "Using vim's builtin formatprg."
endfunction
