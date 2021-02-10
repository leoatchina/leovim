@if not exist "%HOME%" @set HOME=%USERPROFILE%
call del "%HOME%\.vimrc.clean"
call del "%HOME%\.vim.conf"
call del "%HOME%\.vimrc"
call del "%HOME%\.gvimrc"
call del "%HOME%\AppData\local\nvim\init.vim"
call del "%HOME%\AppData\local\nvim\ginit.vim"


call rmdir /Q /S "%HOME%\.vim"
call rmdir /Q /S "%HOME%\.vim.plugins"
