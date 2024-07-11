@if not exist "%HOME%" @set HOME=%USERPROFILE%
call del "%HOME%\.leovim.clean"
call del "%HOME%\.leovim"
call del "%HOME%\_ideavimrc"
call del "%HOME%\.vimrc"
call del "%HOME%\.gvimrc"
call del "%HOME%\AppData\local\nvim\init.vim"

call rmdir /Q /S "%HOME%\.leovim*"
