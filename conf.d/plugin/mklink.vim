if WINDOWS()
    let s:code_user_dir = substitute(fnameescape(get(g:, "code_user_dir", "")), '/', '\', 'g')
    let s:trae_user_dir = substitute(fnameescape(get(g:, "trae_user_dir", "")), '/', '\', 'g')
    let s:cursor_user_dir = substitute(fnameescape(get(g:, "cursor_user_dir", "")), '/', '\', 'g')
    let s:positron_user_dir = substitute(fnameescape(get(g:, "positron_user_dir", "")), '/', '\', 'g')
    let s:windsurf_user_dir = substitute(fnameescape(get(g:, "windsurf_user_dir", "")), '/', '\', 'g')
else
    let s:code_user_dir = fnameescape(get(g:, "code_user_dir", ""))
    let s:trae_user_dir = fnameescape(get(g:, "trae_user_dir", ""))
    let s:cursor_user_dir = fnameescape(get(g:, "cursor_user_dir", ""))
    let s:positron_user_dir = fnameescape(get(g:, "positron_user_dir", ""))
    let s:windsurf_user_dir = fnameescape(get(g:, "windsurf_user_dir", ""))
endif
function! s:execute(cmd, ...) abort
    if a:0 && a:1 > 0
        execute("!echo " . a:cmd)
    endif
    execute("!" . a:cmd)
endfunction
function! s:link() abort
        for dir in [s:code_user_dir, s:trae_user_dir, s:cursor_user_dir, s:windsurf_user_dir, s:positron_user_dir]
            if WINDOWS() && isdirectory(dir)
                " rm
                let delete_cmd = printf('del /Q /S %s\keybindings.json', dir)
                call s:execute(delete_cmd)
                let rmdir_cmd = printf('rmdir /Q /S %s\snippets', dir)
                call s:execute(rmdir_cmd)
                " mklink
                let mklink_cmd = printf('mklink %s %s', dir . '\keybindings.json', $CFG_DIR . '\keybindings.json')
                call s:execute(mklink_cmd)
                let mklink_cmd = printf('mklink /d %s %s', dir . '\snippets', $LEOVIM_DIR . '\snippets')
                call s:execute(mklink_cmd)
            elseif isdirectory(dir)
                " rm
                let rm_cmd = printf('rm %s',  dir . '/keybindings.json')
                call s:execute(rm_cmd)
                let rm_cmd = printf('rm -rf %s',  dir . '/snippets')
                call s:execute(rm_cmd)
                " ln -sf
                let ln_cmd = printf('ln -sf %s %s', $CFG_DIR . '/keybindings.json', dir . '/keybindings.json')
                call s:execute(ln_cmd, 1)
                let ln_cmd = printf('ln -sf %s %s', $CONF_D_DIR . '/snippets', dir)
                call s:execute(ln_cmd, 1)
            endif
        endfor
endfunction
command! MkLinkKeyBindings call s:link()
nnoremap <M-h>K :MkLinkKeyBindings<Cr>
