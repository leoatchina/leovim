
command! -nargs=* -complete=dir ZFBackupListDir :call ZFBackupListDir(<q-args>)

function! s:ZFBackupListDir_sortFunc(backupInfo1, backupInfo2)
    if a:backupInfo1['pathMD5'] == a:backupInfo2['pathMD5']
        return 0
    elseif a:backupInfo1['pathMD5'] < a:backupInfo2['pathMD5']
        return -1
    else
        return 1
    endif
endfunction

function! ZFBackupListDir(...)
    let dirPath = get(a:, 1, '')
    if empty(dirPath)
        let dirPath = getcwd()
    endif
    let absPath = CygpathFix_absPath(dirPath)
    let backupsInDir = {}
    for backupInfo in ZFBackup_getAllBackupInfoList()
        if stridx(backupInfo['path'], absPath) == 0
            let backupsInDir[backupInfo['path'] . '/' . backupInfo['name']] = backupInfo
        endif
    endfor
    if empty(backupsInDir)
        echo '[ZFBackup] no backup found'
        return
    endif
    if len(backupsInDir) == 1
        call ZFBackupList(keys(backupsInDir)[0])
        return
    endif

    tabnew
    file ZFBackupListDir
    setlocal buftype=nofile bufhidden=wipe noswapfile

    let openHint = ''
    let reloadHint = ''
    let quitHint = ''
    for k in get(g:, 'ZFBackupKeymap_listDirBuffer_open', ['o', '<cr>'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_listDirBuffer_open()<cr>'
        if !empty(openHint)
            let openHint .= ' or '
        endif
        let openHint .= k
    endfor
    for k in get(g:, 'ZFBackupKeymap_listDirBuffer_reload', ['DD'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_listDirBuffer_reload()<cr>'
        if !empty(reloadHint)
            let reloadHint .= ' or '
        endif
        let reloadHint .= k
    endfor
    for k in get(g:, 'ZFBackupKeymap_listDirBuffer_quit', ['q'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_listDirBuffer_quit()<cr>'
        if !empty(quitHint)
            let quitHint .= ' or '
        endif
        let quitHint .= k
    endfor

    let contents = [
                \   '# backups for dir: ' . absPath,
                \   '# ' . openHint . ' to list backup for file',
                \   '# ' . reloadHint . ' to reload',
                \   '# ' . quitHint . ' or :bd to quit',
                \   '',
                \ ]
    let b:ZFBackupListDir_dirPath = absPath
    let b:ZFBackupListDir_filesToList = []
    let b:ZFBackupListDir_offset = len(contents) + 1
    let contentsTmp = []
    let maxLen = 0
    let backupInfoList = values(backupsInDir)
    call sort(backupInfoList, function('s:ZFBackupListDir_sortFunc'))
    for backupInfo in backupInfoList
        call add(b:ZFBackupListDir_filesToList, backupInfo['path'] . '/' . backupInfo['name'])
        let relIndex = stridx(backupInfo['path'] . '/' . backupInfo['name'], absPath)
        if relIndex == 0
            let pathInfo = strpart(backupInfo['path'] . '/' . backupInfo['name'], len(absPath))
        else
            let pathInfo = backupInfo['path'] . '/' . backupInfo['name']
        endif
        if len(backupInfo['name']) > maxLen
            let maxLen = len(backupInfo['name'])
        endif
        call add(contentsTmp, [backupInfo['name'], pathInfo])
    endfor
    for t in contentsTmp
        call add(contents, t[0] . repeat(' ', maxLen - len(t[0])) . ' => ' . t[1])
    endfor

    call add(contents, '')
    call setline(1, contents)
    setlocal nomodifiable nomodified
    let cursorPos = getpos('.')
    let cursorPos[1] = b:ZFBackupListDir_offset
    call setpos('.', cursorPos)

    set filetype=ZFBackupListDir
endfunction

function! ZFBackupKeymap_listDirBuffer_open()
    if !exists('b:ZFBackupListDir_dirPath') || !exists('b:ZFBackupListDir_filesToList') || !exists('b:ZFBackupListDir_offset')
        return
    endif
    let index = getpos('.')[1] - b:ZFBackupListDir_offset
    if index < 0 || index >= len(b:ZFBackupListDir_filesToList)
        return
    endif
    call ZFBackupList(b:ZFBackupListDir_filesToList[index])
endfunction
function! ZFBackupKeymap_listDirBuffer_reload()
    if !exists('b:ZFBackupListDir_dirPath') || !exists('b:ZFBackupListDir_filesToList') || !exists('b:ZFBackupListDir_offset')
        return
    endif
    let dirPath = b:ZFBackupListDir_dirPath
    call ZFBackupKeymap_listDirBuffer_quit()
    call ZFBackupListDir(dirPath)
endfunction
function! ZFBackupKeymap_listDirBuffer_quit()
    if !exists('b:ZFBackupListDir_dirPath') || !exists('b:ZFBackupListDir_filesToList') || !exists('b:ZFBackupListDir_offset')
        return
    endif
    bdelete!
endfunction

