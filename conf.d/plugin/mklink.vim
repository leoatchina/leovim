function! s:execute(cmd, ...) abort
    if a:0 && a:1 > 0
        execute("!echo " . a:cmd)
    endif
    execute("!" . a:cmd)
endfunction
let s:editor_dirs = []
let s:editor_names = ["code", "trae", "kiro", "qoder", "lingma", "cursor", "windsurf", "positron"]
for editor in s:editor_names
    let dir = fnameescape(get(g:, editor . "_user_dir", ""))
    if WINDOWS()
        let dir = substitute(dir, '/', '\', 'g')
    endif
    call add(s:editor_dirs, dir)
endfor
function! s:link() abort
    for dir in s:editor_dirs
        if WINDOWS() && isdirectory(dir)
            let delete_cmd = printf('del /Q /S %s\keybindings.json', dir)
            call s:execute(delete_cmd)
            let rmdir_cmd = printf('rmdir /Q /S %s\snippets', dir)
            call s:execute(rmdir_cmd)
            " mklink
            let mklink_cmd = printf('mklink %s %s', dir . '\keybindings.json', $CFG_DIR . '\keybindings.json')
            call s:execute(mklink_cmd)
            let mklink_cmd = printf('mklink /d %s %s', dir . '\snippets', $CONF_D_DIR . '\snippets')
            call s:execute(mklink_cmd)
        elseif isdirectory(dir)
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
