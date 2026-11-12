@rem vim-herdr-navigation -- herdr side (Windows)
@rem
@rem Invoked by a herdr keybind as: navigate.cmd <left|down|up|right>
@rem
@rem herdr cannot track Unix foreground process groups on Windows, so Vim
@rem panes self-report instead: the editor side sets the pane token
@rem "vim-herdr-nav" while it runs (see conf.d/main/plugin/multiplexer.vim).
@rem When the token is present, the chord is forwarded into that pane for
@rem Vim's <M-H/J/K/L> mappings; otherwise herdr moves its own pane focus.
@rem
@rem No jq needed: detection is a token lookup via `herdr pane get`.

@echo off
setlocal enableextensions

set "dir=%~1"
if not defined dir goto usage

set "herdr=%HERDR_BIN_PATH%"
if not defined herdr set "herdr=herdr"
set "pane=%HERDR_PANE_ID%"

set "key="
if "%dir%"=="left"   set "key=alt+H"
if "%dir%"=="down"   set "key=alt+J"
if "%dir%"=="up"     set "key=alt+K"
if "%dir%"=="right"  set "key=alt+L"
if defined key goto detect
echo navigate.cmd: unknown direction: %dir% 1>&2
exit /b 2

:usage
echo usage: navigate.cmd ^<left^|down^|up^|right^> 1>&2
exit /b 2

:detect
set "forward=0"
if not defined pane goto run
"%herdr%" pane get "%pane%" 2>nul | findstr /i /c:"vim-herdr-nav" >nul 2>&1
if errorlevel 1 goto run
set "forward=1"

:run
if "%forward%"=="1" (
    "%herdr%" pane send-keys "%pane%" "%key%"
    exit /b
)
if defined pane (
    "%herdr%" pane focus --direction "%dir%" --pane "%pane%"
    exit /b
)
rem Invoked outside a pane (no $HERDR_PANE_ID): fall back to global focus.
"%herdr%" pane focus --direction "%dir%" --current
exit /b
