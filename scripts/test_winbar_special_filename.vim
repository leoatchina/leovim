set nomore
set runtimepath^=/mnt/users/leo/.leovim/conf.d/init
source /mnt/users/leo/.leovim/conf.d/main/plugin/window.vim

function! s:check_winbar_filename(fname) abort
    execute 'edit ' . fnameescape(a:fname)
    setlocal filetype=markdown
    OpenWinBar
    if index(get(menu_info('WinBar', 'n'), 'submenus', []), a:fname) < 0
        cquit 1
    endif
    CloseWinBar
    if index(get(menu_info('WinBar', 'n'), 'submenus', []), a:fname) >= 0
        cquit 2
    endif
    bwipe!
endfunction

call s:check_winbar_filename('[x] (y).md')
call s:check_winbar_filename('a b.md')
call s:check_winbar_filename('a&b.md')
qa!
