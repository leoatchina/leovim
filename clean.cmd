@if not exist "%HOME%" @set HOME=%USERPROFILE%
call del "%HOME%\\.vim\\swap\\*.*" /a /f /q
call del "%HOME%\\.vim\\views\\*.*" /a /f /q
call del "%HOME%\\.vim\\backup\\*.*" /a /f /q
