" ----------------------------------------
" System Detection Functions
" ----------------------------------------
function! utils#is_windows() abort
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
        elseif exists('g:vscode')
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

function! utils#is_file_readonly() abort
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
        if utils#is_windows() && curr_dir[-2:-1] == ':/' || utils#is_unix() && curr_dir ==# '/'
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

function! utils#trip_trailing_whitespace() abort
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

function! utils#escape(param) abort
    return substitute(escape(a:param, '/\.*$^~[#'), '\n', '\\n', 'g')
endfunction

function! utils#get_visual_selection(...) abort
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

function! utils#viw() abort
    set iskeyword-=_ iskeyword-=#
    call timer_start(300, {-> execute("set iskeyword+=_  iskeyword+=#")})
    call feedkeys("viwo",'n')
endfunction

" ----------------------------------------
" Package Management Functions
" ----------------------------------------
function! utils#is_require(pack) abort
    return count(g:require_group, a:pack) > 0
endfunction

function! utils#add_require(...) abort
    if a:0 == 0
        return
    endif
    for require in a:000
        if !utils#is_require(require)
            call add(g:require_group, require)
        endif
    endfor
endfunction

function! utils#is_planned(...) abort
    if empty(a:000)
        return 0
    endif
    for pack in a:000
        let pack = tolower(pack)
        if !has_key(g:leovim_installed, pack)
            return 0
        endif
    endfor
    return 1
endfunction

function! utils#is_installed(...) abort
    if empty(a:000)
        return 0
    endif
    for pack in a:000
        let pack = tolower(pack)
        if !has_key(g:leovim_installed, pack) || get(g:leovim_installed, pack, 0) == 0
            return 0
        endif
    endfor
    return 1
endfunction

" ----------------------------------------
" Extended Check Functions (from check.vim)
" ----------------------------------------
function! utils#is_planned_fzf() abort
    return utils#is_planned('fzf', 'fzf.vim')
endfunction

function! utils#is_planned_coc() abort
    return utils#is_require('coc') && g:node_version >= 16.18 && (has('nvim') || has('patch-9.0.0438'))
endfunction

function! utils#is_planned_lsp() abort
    return (utils#is_require('cmp') || utils#is_require('blink') || utils#is_require('blink.lua')) && has('nvim-0.11')
endfunction

function! utils#is_planned_adv_comp_eng() abort
    return utils#is_planned_coc() || utils#is_planned_lsp()
endfunction

function! utils#is_planned_leaderf() abort
    return utils#is_planned('leaderf')
endfunction

function! utils#pref_fzf() abort
    return utils#is_planned_fzf() && (get(g:, 'prefer_fzf', utils#is_unix()) || !utils#is_planned_leaderf())
endfunction

function! utils#is_installed_lsp() abort
    return utils#is_installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'call-graph.nvim',
                \ 'symbol-usage.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'formatter.nvim',
                \ 'dropbar.nvim',
                \ 'aerial.nvim',
                \ )
endfunction

function! utils#is_installed_coc() abort
    return utils#is_installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && utils#is_planned_fzf()
endfunction

function! utils#is_installed_blink() abort
    return utils#is_installed('blink.cmp', 'friendly-snippets', 'nvim-autopairs')
endfunction

function! utils#is_installed_cmp() abort
    return utils#is_installed(
                \ 'nvim-cmp',
                \ 'cmp-nvim-lsp',
                \ 'cmp-nvim-lua',
                \ 'cmp-buffer',
                \ 'cmp-cmdline',
                \ 'cmp-vsnip',
                \ 'cmp-nvim-lsp-signature-help',
                \ 'cmp-async-path',
                \ 'lspkind-nvim',
                \ 'colorful-menu.nvim',
                \ 'friendly-snippets',
                \ 'nvim-autopairs',
                \ )
endfunction

function! utils#is_installed_adv() abort
    return utils#is_installed('coc.nvim') || utils#is_installed_lsp()
endfunction

" ----------------------------------------
" Text Object Functions (from init.vim)
" ----------------------------------------
function! utils#current_line_a() abort
    normal! ^
    let head_pos = getpos('.')
    normal! $
    let tail_pos = getpos('.')
    return ['v', head_pos, tail_pos]
endfunction

function! utils#current_line_i() abort
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

function! utils#block_a() abort
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
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

function! utils#block_i() abort
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
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

" ----------------------------------------
" GUI Functions (from main.vim)
" ----------------------------------------
function! utils#toggle_fullscreen() abort
    if has('libcall') && !has('nvim') && utils#has_gui() && utils#is_windows()
        let g:gvimfullscreendll = $HOME ."\\.leovim.windows\\tools\\gvimfullscreen.dll"
        call libcallnr(g:gvimfullscreendll, "ToggleFullScreen", -1)
    endif
endfunction

function! utils#set_alpha(alpha) abort
    if has('libcall') && !has('nvim') && utils#has_gui() && utils#is_windows()
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
