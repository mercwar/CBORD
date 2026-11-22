@echo off
setlocal

if "%~1"=="" exit /b 0

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

rundll32.exe "%ROOT%\cbord.dll",API %*
exit /b %ERRORLEVEL%
