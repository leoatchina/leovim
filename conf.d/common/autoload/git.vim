" ----------------------------------------
" Git Functions (from git.vim)
" ----------------------------------------
function! git#git_branch() abort
    return get(b:, 'git_branch', '')
endfunction

function! git#git_root_dir() abort
    return get(b:, 'git_root_dir', '')
endfunction

function! git#lcd_and_git_update() abort
    if utils#ft_bt_ignored() || tolower(getbufvar(winbufnr(winnr()), '&ft')) =~ 'fern' || tolower(getbufvar(winbufnr(winnr()), '&bt')) == 'nofile'
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
    let gitroot = git#git_root_dir()
    if gitroot != '' && len(absdir) > len(gitroot)
        return gitroot
    else
        return absdir
    endif
endfunction

function! git#relative_path() abort
    let abspath = utils#abs_path()
    let gitroot = git#git_root_dir()
    if gitroot != '' && len(abspath) > len(gitroot)
        return abspath[len(gitroot)+1:]
    else
        return utils#expand("%:t", 1)
    endif
endfunction
