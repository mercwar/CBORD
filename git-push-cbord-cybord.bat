@echo off
setlocal EnableExtensions
title Move Remote Main to Branch and Push Local to Clean Main

for /f "delims=" %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "STAMP=%%I"
if "%STAMP%"=="" set "STAMP=latest"

echo ====================================================================
echo MERCWAR GIT MOVE-AND-PUSH - Archive Branch: archive-%STAMP%
echo ====================================================================
echo.

call :sync_repo "C:\Mercwar-AI\dc2win\dc2win_bk\CBORD" "CBORD"
if errorlevel 1 goto :fail

call :sync_repo "C:\Mercwar-AI\dc2win\dc2win_bk\CYBORD" "CYBORD"
if errorlevel 1 goto :fail

echo ====================================================================
echo [DONE] Remote mains moved to archive-%STAMP% and local files pushed to main.
echo ====================================================================
pause
exit /b 0

:sync_repo
set "DIR=%~1"
set "NAME=%~2"

echo --------------------------------------------------------------------
echo TARGET: %NAME%  (%DIR%)
echo --------------------------------------------------------------------

if not exist "%DIR%" (
    echo [ERROR] Local folder not found: %DIR%
    exit /b 1
)

if not exist "%DIR%\.git" (
    git -c advice.detachedHead=false -C "%DIR%" init -b main >nul
    if errorlevel 1 exit /b 1
)

git -C "%DIR%" remote remove origin >nul 2>nul
git -C "%DIR%" remote add origin "https://github.com/mercwar/%NAME%.git"
if errorlevel 1 exit /b 1

:: 1. Fetch remote main and move it to archive-<timestamp> branch on GitHub
echo [1/3] Moving remote main to branch archive-%STAMP%...
git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" fetch --quiet origin main >nul 2>nul
if not errorlevel 1 (
    git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" push --quiet origin refs/remotes/origin/main:refs/heads/archive-%STAMP% --force
    if errorlevel 1 exit /b 1
    echo [OK] Remote main saved on branch: archive-%STAMP%
) else (
    echo [INFO] No remote main found on origin.
)

:: 2. Create an empty orphan branch (leaves all local disk files untouched)
echo [2/3] Creating clean empty main branch from local files...
git -C "%DIR%" branch -D temp_clean >nul 2>nul
git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" checkout --quiet --orphan temp_clean
if errorlevel 1 exit /b 1

git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" reset --quiet
if errorlevel 1 exit /b 1

:: 3. Stage local files into clean main and force-push to replace old remote main
echo [3/3] Committing local files and pushing to main...
git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" add -A
if errorlevel 1 exit /b 1

git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" commit --quiet --allow-empty -m "Local %NAME% (%STAMP%)"
if errorlevel 1 exit /b 1

git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" branch -D main >nul 2>nul
git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" branch -M temp_clean main
if errorlevel 1 exit /b 1

git -c core.autocrlf=false -c advice.detachedHead=false -C "%DIR%" push -u --quiet origin main --force
if errorlevel 1 exit /b 1

echo [SUCCESS] %NAME% remote main moved to archive-%STAMP% and local files pushed to main.
echo.
exit /b 0

:fail
echo.
echo [FAILED] Stopped. Run this .bat from cmd.exe to see the exact git error.
pause
exit /b 1