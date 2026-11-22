@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Sync CBORD and CYBORD Repos

:: Enable VT100/ANSI colors in Windows Console and define color codes
for /F "delims=" %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"
set "C_DIM=%ESC%[2m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_RED=%ESC%[91m"
set "C_MAGENTA=%ESC%[95m"
set "C_WHITE=%ESC%[97m"

echo %C_CYAN%%C_BOLD%====================================================================%C_RESET%
echo %C_CYAN%%C_BOLD%   MERCWAR REPO SYNC  ::  CBORD ^& CYBORD%C_RESET%
echo %C_CYAN%%C_BOLD%====================================================================%C_RESET%
echo.

for %%R in (
    "C:\Mercwar-AI\dc2win\dc2win_bk\CBORD"
    "C:\Mercwar-AI\dc2win\dc2win_bk\CYBORD"
) do (
    set "REPO_DIR=%%~R"
    set "REPO_NAME=%%~nxR"
    call :process_repo
)

echo %C_CYAN%%C_BOLD%====================================================================%C_RESET%
echo %C_GREEN%%C_BOLD%  [DONE] All repositories processed.%C_RESET%
echo %C_CYAN%%C_BOLD%====================================================================%C_RESET%
pause
exit /b 0

:process_repo
echo %C_MAGENTA%%C_BOLD%--------------------------------------------------------------------%C_RESET%
echo %C_MAGENTA%%C_BOLD%  TARGET : %C_WHITE%!REPO_NAME!%C_DIM%  (!REPO_DIR!)%C_RESET%
echo %C_MAGENTA%%C_BOLD%--------------------------------------------------------------------%C_RESET%

if not exist "!REPO_DIR!\.git" (
    git -c advice.detachedHead=false -C "!REPO_DIR!" init -b main >nul || goto :err
)

git -C "!REPO_DIR!" remote remove origin 2>nul
git -C "!REPO_DIR!" remote add origin "https://github.com/mercwar/!REPO_NAME!.git" || goto :err

:: 1. Fetch remote and pull images folder onto local disk
echo %C_CYAN%[1/3]%C_RESET% %C_WHITE%Fetching origin and pulling images folder...%C_RESET%
git -c core.autocrlf=false -c advice.detachedHead=false -C "!REPO_DIR!" fetch --quiet origin main || goto :err

git -c core.autocrlf=false -c advice.detachedHead=false -C "!REPO_DIR!" checkout --quiet origin/main -- images 2>nul
if errorlevel 1 (
    echo %C_YELLOW%  [WARN] No 'images' folder found on origin/main for !REPO_NAME!.%C_RESET%
) else (
    echo %C_GREEN%  [OK]   'images' folder synced to "!REPO_DIR!\images"%C_RESET%
)

:: 2. Backup existing remote main to backup-main on GitHub
echo %C_CYAN%[2/3]%C_RESET% %C_WHITE%Backing up remote main -^> backup-main...%C_RESET%
git -C "!REPO_DIR!" push --quiet origin refs/remotes/origin/main:refs/heads/backup-main --force || goto :err
echo %C_GREEN%  [OK]   Remote backup-main updated.%C_RESET%

:: 3. Create fresh main from local files and force-push
echo %C_CYAN%[3/3]%C_RESET% %C_WHITE%Building fresh main and force-pushing...%C_RESET%
git -c core.autocrlf=false -c advice.detachedHead=false -C "!REPO_DIR!" checkout --quiet --orphan fresh_main || goto :err
git -c core.autocrlf=false -C "!REPO_DIR!" reset --quiet || goto :err
git -c core.autocrlf=false -C "!REPO_DIR!" add . || goto :err
git -c core.autocrlf=false -C "!REPO_DIR!" commit --quiet -m "Fresh main with images" || goto :err
git -C "!REPO_DIR!" branch -D main >nul 2>nul
git -C "!REPO_DIR!" branch -M fresh_main main || goto :err
git -c core.autocrlf=false -C "!REPO_DIR!" push --quiet origin main --force || goto :err

echo %C_GREEN%%C_BOLD%  [SUCCESS] !REPO_NAME! synced cleanly!%C_RESET%
echo.
exit /b 0

:err
echo %C_RED%%C_BOLD%  [FAILED] Stopped on !REPO_NAME!. Check the message above.%C_RESET%
echo.
exit /b 1