@if not exist "%HOME%" @set HOME=%USERPROFILE%
@echo off
call del "%HOME%\.vim\swap\*.*"   /a /f /q
call del "%HOME%\.vim\shada.main"   /a /f /q
call del "%HOME%\.vim\shada.main.*" /a /f /q
@echo on
echo "vim temp files cleaned"
