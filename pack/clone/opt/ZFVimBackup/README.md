
more convenient file backup util for vim

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)

# how to use

1. use [Vundle](https://github.com/VundleVim/Vundle.vim) or any other plugin manager you like to install

    ```
    Plugin 'ZSaberLv0/ZFVimBackup'
    ```

1. edit your file, backups would be made automatically when you save files,
    or, make backups manually by `:ZFBackupSave` or `:ZFBackupSaveDir`
1. if anything wrong, use `:ZFBackupList` or `:ZFBackupListDir` to popup and choose backup to diff and restore

# functions

* `ZFBackup_backupDir()` : get backup dir
* `ZFBackupSave [filePath]` or `call ZFBackupSave([filePath])` : save backup for specified file
* `ZFBackupSaveDir [filePath]` or `call ZFBackupSaveDir([filePath])` : save backup for specified dir,
    `wildignore` and `ZFIgnoreGet()` are applied
* `ZFBackupRemove [filePath]` or `call ZFBackupRemove([filePath])` : remove backup for specified file
* `ZFBackupRemoveDir [filePath]` or `call ZFBackupRemoveDir([filePath])` : remove backup for specified dir
* `ZFBackupList [filePath]` or `call ZFBackupList([filePath])` : restore backup for specified file
* `ZFBackupListDir [filePath]` or `call ZFBackupListDir([filePath])` : restore backup for specified dir
* `ZFBackup_getBackupInfoList([filePath])` or `ZFBackup_getAllBackupInfoList()` :
    get a list of backup info for specified file:
    ```
    [
      {
        'backupFile' : 'backup file name under backupDir',
        'name' : 'original file's name',
        'path' : 'original file's parent's abs path, may be empty when local config file messed up',
        'pathMD5' : 'original file's parent's abs path's md5',
        'time' : 'backup saved time, string',
        'info' : 'a short info to show the backup',
      },
    ]
    ```
* `ZFBackup_clean()` : remove all backup files
* `ZFBackup_enable()` : enable auto backup
* `ZFBackup_disable()` : disable auto backup
* `ZFBackup_autoClean()` : clean outdated backup

# configs

* `g:ZFBackup_autoEnable` : whether enable by default, default: `1`
* `g:ZFBackup_stateFilePath` : path for local state file, default: `~/.vim_cache`
* `g:ZFBackup_path` : path for backups, default: `~/.vim_cache`
* `g:ZFBackup_backupFunc` : function to perform actual backup, default: `ZFBackup_backupFunc`
* `g:ZFBackup_hashFunc` : function to get file's hash, default: `ZFBackup_hashFunc`
    * you need one of thse command to make backup available:
        * `md5` or `md5sum` (for Linux like systems)
        * `certutil` (for Windows)
    * if none of them are available,
        you may supply your own,
        or use the builtin vim script version by `let g:ZFBackup_hashFunc_fallback_enable = 1`
        (which may be slow)
* `g:ZFBackup_backupFilter` : Dictonary that contain filter functions to filter files to backup,
    key is any module name you like,
    value is filter function `function(filePath)`,
    return `1` to prevent the file from being backup,
    return `0` means the file needs backup,
    return `-1` means pass to next filter,
    if all filter return `-1`, then it means the file needs backup
    * `g:ZFBackup_backupFilterEnableDefault` : whether enable the default filter,
        which use [ZSaberLv0/ZFVimIgnore](https://github.com/ZSaberLv0/ZFVimIgnore) to filter,
        default: `1`

        to specify custom ignore for ZFBackup only:

        ```
        if !exists('g:ZFIgnoreData')
            let g:ZFIgnoreData = {}
        endif
        let g:ZFIgnoreData['MyCustomIgnore'] = {
                    \   'ZFBackup' : {
                    \     'file' : {
                    \       '*.png' : 1,
                    \     },
                    \     'dir' : {
                    \     },
                    \   },
                    \ }
        ```

* `g:ZFBackup_includeTempname` : whether backup files created by `tempname()`, default: `0`
* `g:ZFBackup_maxFileSize` : if file large than this size, do not backup, default: `2 * 1024 * 1024` (2MB)
* `g:ZFBackup_maxBackupPerFile` : max number of backups for one file, default: `10`
* `g:ZFBackup_maxBackup` : max number of backups, default: `500`
* `g:ZFBackup_autoClean` : auto clean outdated backup, use 0 to disable auto clean, default: `7 * 24 * 60 * 60` (7 day)

