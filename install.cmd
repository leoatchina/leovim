@if not exist "%HOME%" @set HOME=%USERPROFILE%
@set PWD=%~dp0
@set APP_PATH=%PWD:~0,-1%

REM mkdir necesarry
call md "%HOME%\AppData\local\nvim"
call md "%HOME%\AppData\Roaming\Zed"

REM mklink of conf.d dir
IF "%APP_PATH%" == "%HOME%\.leovim" (
    echo "leovim is already installed in %HOME%\.leovim"
) ELSE (
    echo "leovim is going to be linked to %HOME%\.leovim"
    call rmdir "%HOME%\.leovim"
    call mklink /d "%HOME%\.leovim" "%APP_PATH%"
)
echo

REM delete files
call del "%HOME%\.vimrc"


REM create vimrc
echo if filereadable(expand("~/.vimrc.local")) > "%HOME%\.vimrc"
echo    source ~/.vimrc.local >> "%HOME%\.vimrc"
echo else >> "%HOME%\.vimrc"
echo    source ~/.leovim/conf.d/init.vim >> "%HOME%\.vimrc"
echo endif >> "%HOME%\.vimrc"

REM cp vimrc
call del "%HOME%\AppData\local\nvim\init.vim"
call copy "%HOME%\.vimrc" "%HOME%\AppData\local\nvim\init.vim"

REM mklink keymap for zed
call del "%HOME%\AppData\Roaming\Zed\keymap.json"
call mklink "%HOME%\AppData\Roaming\Zed\keymap.json" "%APP_PATH%\scripts\keymap.json"

REM create gvimrc
IF NOT EXIST "%HOME%\.gvimrc" (
    copy "%HOME%\.leovim\scripts\gvimrc" "%HOME%\.gvimrc"
)

REM mklink
call del    "%HOME%\_leovim.clean.cmd"
call mklink "%HOME%\_leovim.clean.cmd" "%APP_PATH%\clean.cmd"

REM mkdir for install
IF NOT EXIST "%HOME%\.leovim.d" (
    call md "%HOME%\.leovim.d"
)

REM copy local
IF NOT EXIST "%HOME%\.vimrc.opt" (
    call copy "%APP_PATH%\conf.d\runtime\opt.vim" "%HOME%\.vimrc.opt"
)

REM setup vim tools for windows
IF NOT EXIST "%HOME%\.leovim.windows" (
    call git clone --depth=1 https://github.com/leoatchina/leovim-windows.git "%HOME%\.leovim.windows"
) ELSE (
    call cd "%HOME%\.leovim.windows"
    call git pull
)
