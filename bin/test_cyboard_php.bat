@echo off
setlocal
title CYBORD PHP Host Verification Suite

:: ============================================================================
::  BIN-ROOTED CONFIGURATION (%~dp0 = C:\Mercwar-AI\CYBORD\bin\)
:: ============================================================================
set "BIN_DIR=%~dp0"
set "HOST_EXE=%BIN_DIR%cybord_php.exe"
set "CBORD_DLL=%BIN_DIR%cbord.dll"
set "TEST_PHP=%BIN_DIR%test_cybord_bridge.php"
set "HEX_PAYLOAD=A16474657374626F6B"

:: Enable ANSI terminal colors
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
set "C_RESET=%ESC%[0m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_RED=%ESC%[91m"
set "C_GRAY=%ESC%[90m"

echo.
echo %C_CYAN%====================================================================%C_RESET%
echo %C_CYAN%  CYBORD PHP CLI HOST - RUNTIME VERIFICATION SUITE%C_RESET%
echo %C_CYAN%====================================================================%C_RESET%
echo   %C_GRAY%Bin Dir  : %BIN_DIR%%C_RESET%
echo   %C_GRAY%CLI Host : %HOST_EXE%%C_RESET%
echo   %C_GRAY%Library  : %CBORD_DLL%%C_RESET%
echo   %C_GRAY%Bridge   : %TEST_PHP%%C_RESET%
echo %C_CYAN%--------------------------------------------------------------------%C_RESET%
echo.

if not exist "%HOST_EXE%" (
    echo   %C_RED%[FAIL] Missing host executable: %HOST_EXE%%C_RESET%
    goto :END
)
if not exist "%CBORD_DLL%" (
    echo   %C_RED%[FAIL] Missing CBORD library  : %CBORD_DLL%%C_RESET%
    goto :END
)
if not exist "%TEST_PHP%" (
    echo   %C_RED%[FAIL] Missing bridge script  : %TEST_PHP%%C_RESET%
    goto :END
)

"%HOST_EXE%" "%TEST_PHP%" "%HEX_PAYLOAD%"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo %C_GREEN%====================================================================%C_RESET%
    echo %C_GREEN%  PASSED - cybord_php.exe + Session + cbord.dll + Win32 API Ready%C_RESET%
    echo %C_GREEN%====================================================================%C_RESET%
) else (
    echo %C_RED%====================================================================%C_RESET%
    echo %C_RED%  FAILED - Host exited with code %EXIT_CODE%%C_RESET%
    echo %C_RED%====================================================================%C_RESET%
)

:END
echo.
pause
