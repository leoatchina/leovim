@if not exist "%HOME%" @set HOME=%USERPROFILE%
call rmdir /Q /S "%HOME%\.leovim.d\pack"
