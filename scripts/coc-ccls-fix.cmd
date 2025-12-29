::@echo off
set existing="%userprofile%\.leovim.d\coc\extensions\node_modules\coc-ccls\node_modules\ws\lib\extension.js"
set missing="%userprofile%\.leovim.d\coc\extensions\node_modules\coc-ccls\lib\extension.js"
if exist %existing% (
    if not exist %missing% (
        mkdir "%userprofile%\.leovim.d\coc\extensions\node_modules\coc-ccls\lib"
        mklink %missing% %existing%
    )
)
::@echo on
