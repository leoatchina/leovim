" ----------------------------------------
" Git Functions (from git.vim)
" ----------------------------------------
function! git#branch() abort
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

let s:git_cache = {}   " dir -> [git_root_dir, git_branch]

function! git#lcd_and_update() abort
    if utils#is_ignored() || tolower(getbufvar(winbufnr(winnr()), '&ft')) =~ 'fern' || utils#is_popup()
        return
    endif
    let l:cur_dir = utils#abs_dir()
    if l:cur_dir == ''
        return
    endif
    " 仅在目录变化时切换窗口 cwd（getcwd(winnr()) 为窗口局部 cwd）
    if getcwd(winnr()) !=# fnamemodify(expand('%:p:h'), ':p')
        try
            execute 'lcd ' . l:cur_dir
        catch
        endtry
    endif
    " 目录级缓存：同一目录只 fork 一次 git
    if has_key(s:git_cache, l:cur_dir)
        let [b:git_root_dir, b:git_branch] = s:git_cache[l:cur_dir]
        return
    endif
    let b:git_root_dir = ''
    let b:git_branch = ''
    if g:git_version > 1.8
        try
            " 一次 fork 输出三行：is-inside-work-tree / root / branch
            let l:out = system('git -C ' . l:cur_dir . ' rev-parse --is-inside-work-tree --show-toplevel --abbrev-ref HEAD 2>/dev/null')
            if v:shell_error == 0
                let l:lines = split(l:out, "\n")
                if len(l:lines) >= 3 && get(l:lines, 0, '') ==# 'true' && l:lines[1] != ''
                    let b:git_root_dir = l:lines[1]
                    let icon = ' '
                    let b:git_branch = icon . l:lines[2]
                endif
            endif
        catch
            let b:git_root_dir = ''
            let b:git_branch = ''
        endtry
    endif
    let s:git_cache[l:cur_dir] = [b:git_root_dir, b:git_branch]
endfunction

" 切换分支 / rebase 后缓存过期时手动刷新
command! GitRefresh let s:git_cache = {} | call git#lcd_and_update()

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
