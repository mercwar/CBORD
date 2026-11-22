@echo off
setlocal EnableDelayedExpansion
title CBORD Native Win32 Runtime - Interactive Console

for /f %%A in ('echo prompt $E^| cmd') do set "E=%%A"

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "EXE=%ROOT%\cbord.exe"

:menu
cls
if exist "%EXE%" (set "STATUS=!E![92mREADY!E![0m") else (set "STATUS=!E![91mMISSING cbord.exe!E![0m")

echo.
echo  !E![96m+------------------------------------------------------------------------------+!E![0m
echo  !E![96m^|!E![1;96m   ______ ____   ____  ____  ____                                             !E![96m^|!E![0m
echo  !E![96m^|!E![1;96m  / ____// __ ) / __ \/ __ \/ __ \                                            !E![96m^|!E![0m
echo  !E![96m^|!E![1;96m / /    / __  ^|/ / / / /_/ / / / /                                            !E![96m^|!E![0m
echo  !E![96m^|!E![1;96m/ /___ / /_/ // /_/ / _, _/ /_/ /                                             !E![96m^|!E![0m
echo  !E![96m^|!E![1;96m\____//_____/ \____/_/ ^|_/_____/                                              !E![96m^|!E![0m
echo  !E![96m^|!E![1;97m  Interactive Win32 Runtime Interface                                         !E![96m^|!E![0m
echo  !E![96m+------------------------------------------------------------------------------+!E![0m
echo    Runtime Status: !STATUS!   ^|   Dir: !E![90m%ROOT%!E![0m
echo.
echo    !E![93m[1]!E![0m Run Custom Win32 API Call      !E![90m(e.g. MessageBoxW NULL "Hi" "CBORD" MB_OK+MB_ICONINFORMATION)!E![0m
echo    !E![93m[2]!E![0m Run JSON Payload Call          !E![90m(e.g. {"MessageBoxW":[0,"Hi","CBORD",64]})!E![0m
echo    !E![93m[3]!E![0m Test: Info Dialog              !E![90m(MessageBoxW + "MB_OK|MB_ICONINFORMATION")!E![0m
echo    !E![93m[4]!E![0m Test: Yes/No Prompt            !E![90m(MessageBoxW + "MB_YESNO|MB_ICONQUESTION")!E![0m
echo    !E![93m[5]!E![0m Test: Audio Chime ^& Beep       !E![90m(MessageBeep + Beep 750 Hz)!E![0m
echo    !E![93m[6]!E![0m Search Exported APIs ^& Consts  !E![90m(Filter win32_table.h by keyword)!E![0m
echo    !E![93m[7]!E![0m Build / Rebuild Runtime        !E![90m(Run build script)!E![0m
echo    !E![93m[0]!E![0m Exit
echo.
set "CHOICE="
set /p "CHOICE=  !E![96mSelect an option [0-7]: !E![0m"

if "%CHOICE%"=="1" goto :opt_cli
if "%CHOICE%"=="2" goto :opt_json
if "%CHOICE%"=="3" goto :opt_msgbox
if "%CHOICE%"=="4" goto :opt_yesno
if "%CHOICE%"=="5" goto :opt_beep
if "%CHOICE%"=="6" goto :opt_search
if "%CHOICE%"=="7" goto :opt_build
if "%CHOICE%"=="0" exit /b 0
goto :menu

:opt_cli
echo.
echo   !E![90mEnter Win32 function and arguments (or leave blank to cancel):!E![0m
setlocal DisableDelayedExpansion
set "CMD_INPUT="
set /p "CMD_INPUT=  cbord> "
if not defined CMD_INPUT (
    endlocal
    goto :menu
)
set "SAFE_CLI=%CMD_INPUT:|=^^|%"
"%EXE%" --cli %SAFE_CLI%
set "RC=%ERRORLEVEL%"
endlocal
echo   !E![90m[Exit Code: %RC%] Press any key to continue...!E![0m
pause >nul
goto :menu

:opt_json
echo.
echo   !E![90mEnter JSON payload (or leave blank to cancel):!E![0m
setlocal DisableDelayedExpansion
set "JSON_INPUT="
set /p "JSON_INPUT=  json> "
if not defined JSON_INPUT (
    endlocal
    goto :menu
)
set "SAFE_JSON=%JSON_INPUT:"=\"%"
"%EXE%" --json "%SAFE_JSON%"
set "RC=%ERRORLEVEL%"
endlocal
echo   !E![90m[Exit Code: %RC%] Press any key to continue...!E![0m
pause >nul
goto :menu

:opt_msgbox
"%EXE%" MessageBoxW NULL "CBORD Native Win32 Runtime is active!" "CBORD Info" "MB_OK|MB_ICONINFORMATION"
goto :menu

:opt_yesno
"%EXE%" MessageBoxW NULL "Testing Win32 constant flags (MB_YESNO | MB_ICONQUESTION)." "CBORD Prompt" "MB_YESNO|MB_ICONQUESTION"
goto :menu

:opt_beep
"%EXE%" MessageBeep "MB_ICONEXCLAMATION"
"%EXE%" Beep 750 300
goto :menu

:opt_search
echo.
set "TBL="
if exist "%ROOT%\win32_table.h" set "TBL=%ROOT%\win32_table.h"
if not defined TBL if exist "%ROOT%\..\win32_table.h" set "TBL=%ROOT%\..\win32_table.h"
if not defined TBL (
    echo   !E![91m[ERROR] win32_table.h not found.!E![0m
    pause >nul
    goto :menu
)
set "QUERY="
set /p "QUERY=  !E![96mSearch API or Constant (e.g. MessageBox, MB_ICON, CreateWindow): !E![0m"
if not defined QUERY goto :menu
echo.
findstr /i /c:"\"%QUERY%" "%TBL%"
echo.
echo   !E![90mPress any key to return to menu...!E![0m
pause >nul
goto :menu

:opt_build
echo.
for %%D in ("%ROOT%" "%ROOT%\..") do (
    if exist "%%~fD\build_win32api.bat" (
        call "%%~fD\build_win32api.bat"
        goto :menu
    )
    if exist "%%~fD\build.bat" (
        call "%%~fD\build.bat"
        goto :menu
    )
)
echo   !E![91m[ERROR] No build script found.!E![0m
pause >nul
goto :menu
