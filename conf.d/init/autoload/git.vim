" ----------------------------------------
" Git Functions (from git.vim)
" ----------------------------------------
function! git#git_branch() abort
    return get(b:, 'git_branch', '')
endfunction

function! git#root_dir() abort
    return get(b:, 'git_root_dir', '')
endfunction

function! git#lightline_buffers()
    " origin buffers list
    let buffers = copy(lightline#bufferline#buffers())
    try
        let b:file_icon = buffers[1][0][:3]
    catch
        let b:file_icon = ''
    endtry
    " reorder buffers
    if empty(buffers[2])
        let res = buffers
    else
        if empty(buffers[0])
            let res = [buffers[2], buffers[1], []]
        else
            let res = [buffers[0] + buffers[2], buffers[1], []]
        endif
    endif
    let res[1] = [b:file_icon . git#relative_dir()]
    return res
endfunction

function! git#lcd_and_git_update() abort
    if utils#is_ignored() || tolower(getbufvar(winbufnr(winnr()), '&ft')) =~ 'fern'
        return
    endif
    try
        let l:cur_dir = utils#abs_dir()
        if l:cur_dir != ''
            execute 'lcd ' . l:cur_dir
        endif
    catch
        return
    endtry
    if g:git_version > 1.8
        try
            let l:git_root = system('git -C ' . l:cur_dir . ' rev-parse --show-toplevel')
            let b:git_root_dir = substitute(l:git_root, '\n\+$', '', '')
            if v:shell_error != 0 || b:git_root_dir =~ 'fatal:' || b:git_root_dir == ''
                let b:git_root_dir = ''
                let b:git_branch = ''
            else
                let l:branch = system('git -C ' . l:cur_dir . ' rev-parse --abbrev-ref HEAD')
                " TODO: change branch icon according to branch status, referring https://www.nerdfonts.com/cheat-sheet
                let icon = ' '
                let b:git_branch = icon . substitute(l:branch, '\n\+$', '', '')
                if v:shell_error != 0 || b:git_branch =~ 'fatal:' || b:git_branch == ''
                    let b:git_root_dir = ''
                    let b:git_branch = ''
                endif
            endif
        catch
            let b:git_root_dir = ''
            let b:git_branch = ''
        endtry
    else
        let b:git_root_dir = ''
        let b:git_branch = ''
    endif
endfunction

function! git#relative_dir() abort
    let absdir = utils#abs_dir()
    let gitroot = git#root_dir()
    if gitroot != '' && len(absdir) > len(gitroot)
        return gitroot
    else
        return absdir
    endif
endfunction

function! git#relative_path() abort
    let abspath = utils#abs_path()
    let gitroot = git#root_dir()
    if gitroot != '' && len(abspath) > len(gitroot)
        return abspath[len(gitroot)+1:]
    else
        return utils#expand("%:t", 1)
    endif
endfunction
