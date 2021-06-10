@if not exist "%HOME%" @set HOME=%USERPROFILE%
call del "%HOME%\.leovim.clean"
call del "%HOME%\.leovim.conf"
call del "%HOME%\.vimrc"
call del "%HOME%\.gvimrc"
call del "%HOME%\_ideavimrc"
call del "%HOME%\AppData\local\nvim\init.vim"
call del "%HOME%\AppData\local\nvim\ginit.vim"


call rmdir /Q /S "%HOME%\.vim"
call rmdir /Q /S "%HOME%\.leovim.plug"
