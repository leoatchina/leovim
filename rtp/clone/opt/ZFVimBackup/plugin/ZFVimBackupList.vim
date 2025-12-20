
command! -nargs=* -complete=file ZFBackupList :call ZFBackupList(<q-args>)

function! ZFBackupList(...)
    let filePath = get(a:, 1, '')
    if empty(filePath)
        let filePath = expand('%')
    endif
    if empty(filePath)
        call ZFBackupListDir(getcwd())
        return
    elseif isdirectory(filePath)
        call ZFBackupListDir(filePath)
        return
    endif
    let backupInfoList = ZFBackup_getBackupInfoList(filePath)
    if empty(backupInfoList)
        echo '[ZFBackup] no backup found'
        return
    endif
    if len(backupInfoList) == 1
        call s:backupDiff(filePath, backupInfoList[0])
        return
    endif

    tabnew
    file ZFBackupList
    setlocal buftype=nofile bufhidden=wipe noswapfile
    let openHint = ''
    let reloadHint = ''
    let quitHint = ''
    for k in get(g:, 'ZFBackupKeymap_listBuffer_open', ['o', '<cr>'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_listBuffer_open()<cr>'
        if !empty(openHint)
            let openHint .= ' or '
        endif
        let openHint .= k
    endfor
    for k in get(g:, 'ZFBackupKeymap_listBuffer_reload', ['DD'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_listBuffer_reload()<cr>'
        if !empty(reloadHint)
            let reloadHint .= ' or '
        endif
        let reloadHint .= k
    endfor
    for k in get(g:, 'ZFBackupKeymap_listBuffer_quit', ['q'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_listBuffer_quit()<cr>'
        if !empty(quitHint)
            let quitHint .= ' or '
        endif
        let quitHint .= k
    endfor

    let contents = [
                \   '# backups for file: ' . filePath,
                \   '# ' . openHint . ' to open diff',
                \   '# ' . reloadHint . ' to reload',
                \   '# ' . quitHint . ' or :bd to quit',
                \   '',
                \ ]
    let b:ZFBackupList_filePath = filePath
    let b:ZFBackupList_backupInfoList = backupInfoList
    let b:ZFBackupList_offset = len(contents) + 1
    for backupInfo in backupInfoList
        call add(contents, backupInfo['info'])
    endfor
    call add(contents, '')
    call setline(1, contents)
    setlocal nomodifiable nomodified
    let cursorPos = getpos('.')
    let cursorPos[1] = b:ZFBackupList_offset
    call setpos('.', cursorPos)

    set filetype=ZFBackupList
endfunction

function! ZFBackupKeymap_listBuffer_open()
    if !exists('b:ZFBackupList_filePath') || !exists('b:ZFBackupList_backupInfoList') || !exists('b:ZFBackupList_offset')
        return
    endif
    let index = getpos('.')[1] - b:ZFBackupList_offset
    if index < 0 || index >= len(b:ZFBackupList_backupInfoList)
        return
    endif
    call s:backupDiff(b:ZFBackupList_filePath, b:ZFBackupList_backupInfoList[index])
endfunction
function! ZFBackupKeymap_listBuffer_reload()
    if !exists('b:ZFBackupList_filePath') || !exists('b:ZFBackupList_backupInfoList') || !exists('b:ZFBackupList_offset')
        return
    endif
    let filePath = b:ZFBackupList_filePath
    call ZFBackupKeymap_listBuffer_quit()
    call ZFBackupList(filePath)
endfunction
function! ZFBackupKeymap_listBuffer_quit()
    if !exists('b:ZFBackupList_filePath') || !exists('b:ZFBackupList_backupInfoList') || !exists('b:ZFBackupList_offset')
        return
    endif
    bdelete!
endfunction


function! s:backupDiff(filePath, backupInfo)
    execute 'tabedit ' . substitute(ZFBackup_backupDir() . '/' . a:backupInfo['backupFile'], ' ', '\\ ', 'g')
    diffthis
    call s:diffBufferSetup()
    execute 'file ' . substitute(a:backupInfo['info'], ' ', '\\ ', 'g')
    setlocal buftype=nofile bufhidden=wipe noswapfile nomodifiable

    vsplit
    wincmd l
    let existBuf = bufnr(substitute(a:filePath, '\\', '/', 'g'))
    if existBuf != -1
        execute ':b' . existBuf
    else
        execute 'edit ' . substitute(a:filePath, ' ', '\\ ', 'g')
    endif
    diffthis
    call s:diffBufferSetup()

    execute "normal! \<c-w>l]czz"
    redraw!
    echo '[ZFBackup] ' . a:backupInfo['info']
endfunction
augroup ZFBackup_diffBuffer_augroup
    autocmd!
    autocmd User ZFBackupDiffBufferSetup silent
    autocmd User ZFBackupDiffBufferCleanup silent
augroup END
function! s:diffBufferSetup()
    for k in get(g:, 'ZFBackupKeymap_diffBuffer_quit', ['q'])
        execute 'nnoremap <silent><buffer> ' . k . ' :call ZFBackupKeymap_diffBuffer_quit()<cr>'
    endfor
    doautocmd User ZFBackupDiffBufferSetup
endfunction
function! ZFBackupKeymap_diffBuffer_quit()
    if ZFBackup_isInBackupDir(expand('%'))
        wincmd l
    endif
    silent! diffoff
    for k in get(g:, 'ZFBackupKeymap_diffBuffer_quit', ['q'])
        execute 'silent! unmap <buffer> ' . k
    endfor
    doautocmd User ZFBackupDiffBufferCleanup
    wincmd h
    doautocmd User ZFBackupDiffBufferCleanup
    silent! bdelete!
    tabclose
endfunction

