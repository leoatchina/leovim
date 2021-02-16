@if not exist "%HOME%" @set HOME=%USERPROFILE%
@set PWD=%~dp0
@set APP_PATH=%PWD:~0,-1%

REM mkdir necesarry
call md "%HOME%\AppData\local\nvim"
call md "%HOME%\.cache"
call md "%HOME%\.cache\tags"
call md "%HOME%\.cache\session"

REM mklink of config dir
IF "%APP_PATH%" == "%HOME%\.leovim.conf" (
    echo "leovim is already installed in %HOME%\.leovim.conf"
) ELSE (
    echo "leovim is going to be linked to %HOME%\.leovim.conf"
		call rmdir "%HOME%\.leovim.conf"
		call mklink /d "%HOME%\.leovim.conf" "%APP_PATH%"
)
echo

REM delete files
call del "%HOME%\.vimrc.clean"
call del "%HOME%\.vimrc"
call del "%HOME%\AppData\local\nvim\init.vim"

REM mklink clean script
call mklink "%HOME%\.vimrc.clean" "%APP_PATH%\clean.cmd"

REM cp vimrc
echo if filereadable(expand("~/.vimrc.test")) > "%HOME%\.vimrc"
echo    source ~/.vimrc.test>> "%HOME%\.vimrc"
echo else >> "%HOME%\.vimrc"
echo    source ~/.leovim.conf/init.vim >> "%HOME%\.vimrc"
echo endif >> "%HOME%\.vimrc"
call copy "%HOME%\.vimrc" "%HOME%\AppData\local\nvim\init.vim"
call copy "%HOME%\.vimrc" "%HOME%\.gvimrc"

REM mkdir for install
IF NOT EXIST "%HOME%\.vim" (
    call md "%HOME%\.vim"
)
REM copy files
IF NOT EXIST "%HOME%\.vimrc.local" (
    call copy "%APP_PATH%\local.vim" "%HOME%\.vimrc.local"
)

REM setup vim tools for windows
IF NOT EXIST "%HOME%\.leovim.plug\windows-tools" (
    IF NOT EXIST "%HOME%\.leovim.plug" (
        call md "%HOME%\.leovim.plug"
    )
    call git clone --depth=1 https://gitee.com/leoatchina/leovim-windows.git "%HOME%\.leovim.plug\windows-tools"
) ELSE (
    call cd "%HOME%\.leovim.plug\windows-tools"
    call git pull
)
