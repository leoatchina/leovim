function! s:utils#execute(cmd, ...) abort
    if a:0 && a:1 > 0
        utils#execute("!echo " . a:cmd)
    endif
    utils#execute("!" . a:cmd)
endfunction
let s:editor_dirs = []
let s:editor_names = ["code", "trae", "kiro", "qoder", "lingma", "cursor", "windsurf", "positron"]
for editor in s:editor_names
    let dir = fnameescape(get(g:, editor . "_user_dir", ""))
    if utils#is_windows()
        let dir = substitute(dir, '/', '\', 'g')
    endif
    call add(s:editor_dirs, dir)
endfor
function! s:link() abort
    for dir in s:editor_dirs
        if utils#is_windows() && isdirectory(dir)
            let delete_cmd = printf('del /Q /S %s\keybindings.json', dir)
            call s:utils#execute(delete_cmd)
            let rmdir_cmd = printf('rmdir /Q /S %s\snippets', dir)
            call s:utils#execute(rmdir_cmd)
            " mklink
            let mklink_cmd = printf('mklink %s %s', dir . '\keybindings.json', $COMMON_DIR . '\keybindings.json')
            call s:utils#execute(mklink_cmd)
            let mklink_cmd = printf('mklink /d %s %s', dir . '\snippets', $CONF_D_DIR . '\snippets')
            call s:utils#execute(mklink_cmd)
        elseif isdirectory(dir)
            let rm_cmd = printf('rm %s',  dir . '/keybindings.json')
            call s:utils#execute(rm_cmd)
            let rm_cmd = printf('rm -rf %s',  dir . '/snippets')
            call s:utils#execute(rm_cmd)
            " ln -sf
            let ln_cmd = printf('ln -sf %s %s', $COMMON_DIR . '/keybindings.json', dir . '/keybindings.json')
            call s:utils#execute(ln_cmd, 1)
            let ln_cmd = printf('ln -sf %s %s', $CONF_D_DIR . '/snippets', dir)
            call s:utils#execute(ln_cmd, 1)
        endif
    endfor
endfunction
command! MkLinkKeyBindings call s:link()
nnoremap <M-h>K :MkLinkKeyBindings<Cr>
