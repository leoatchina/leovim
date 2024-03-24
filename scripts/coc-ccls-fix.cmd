::@echo off
set existing="%userprofile%\AppData\Local\nvim-data\coc\extensions\node_modules\coc-ccls\node_modules\ws\lib\extension.js"
set missing="%userprofile%\AppData\Local\nvim-data\coc\extensions\node_modules\coc-ccls\lib\extension.js"
if exist %existing% (
    if not exist %missing% (
        mkdir "%userprofile%\AppData\Local\nvim-data\coc\extensions\node_modules\coc-ccls\lib"
        mklink %missing% %existing%
    )
)
::@echo on
