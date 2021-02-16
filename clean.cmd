@if not exist "%HOME%" @set HOME=%USERPROFILE%
call del "%HOME%\\.vim\\.vim-swap\\*.*" /a /f /q
call del "%HOME%\\.vim\\.vim-views\\*.*" /a /f /q
call del "%HOME%\\.vim\\.vim-backup\\*.*" /a /f /q
