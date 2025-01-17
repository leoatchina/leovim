if WINDOWS()
    let s:vscode_user_dir = substitute(fnameescape(get(g:, "vscode_user_dir", "")), '/', '\', 'g')
    let s:cursor_user_dir = substitute(fnameescape(get(g:, "cursor_user_dir", "")), '/', '\', 'g')
    let s:positron_user_dir = substitute(fnameescape(get(g:, "positron_user_dir", "")), '/', '\', 'g')
    let s:windsurf_user_dir = substitute(fnameescape(get(g:, "windsurf_user_dir", "")), '/', '\', 'g')
else
    let s:vscode_user_dir = fnameescape(get(g:, "vscode_user_dir", ""))
    let s:cursor_user_dir = fnameescape(get(g:, "cursor_user_dir", ""))
    let s:positron_user_dir = fnameescape(get(g:, "positron_user_dir", ""))
    let s:windsurf_user_dir = fnameescape(get(g:, "windsurf_user_dir", ""))
endif
function! s:link_keybindings() abort
    if WINDOWS()
        for dir in [s:cursor_user_dir, s:vscode_user_dir, s:positron_user_dir, s:windsurf_user_dir]
            if isdirectory(dir)
                let delete_cmd = printf('!del /Q /S %s\keybindings.json', dir)
                execute(delete_cmd)
                let rmdir_cmd = printf('!rmdir /Q /S %s\snippets', dir)
                execute(rmdir_cmd)
                " create keybindings.json link
                let mklink_cmd = printf('!mklink %s %s', dir . '\keybindings.json', $CFG_DIR . '\keybindings.json')
                execute(mklink_cmd)
                " create snippets link
                let mklink_cmd = printf('!mklink /d %s %s', dir . '\snippets', $LEOVIM_DIR . '\snippets')
                execute(mklink_cmd)
            endif
        endfor
    else
        for dir in [s:cursor_user_dir, s:vscode_user_dir, s:positron_user_dir]
            if isdirectory(dir)
                let ln_cmd = printf('!ln -sf %s %s', $CFG_DIR . '/keybindings.json', dir . '/keybindings.json')
                execute(ln_cmd)
                let ln_cmd = printf('!ln -sf %s %s', $LEOVIM_DIR . '/snippets', dir . '/snippets')
                execute(ln_cmd)
            endif
        endfor
    endif
endfunction
command! LinkKeyBindings call s:link_keybindings()
nnoremap <M-h>K :LinkKeyBindings<Cr>
