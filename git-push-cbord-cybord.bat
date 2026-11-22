@echo off
setlocal EnableExtensions
title Sync CBORD and CYBORD Repos

for %%R in (
    "C:\Mercwar-AI\dc2win\dc2win_bk\CBORD"
    "C:\Mercwar-AI\dc2win\dc2win_bk\CYBORD"
) do (
    set "REPO_DIR=%%~R"
    set "REPO_NAME=%%~nxR"
    call :process_repo
)

echo ====================================================================
echo [DONE] Finished.
pause
exit /b 0

:process_repo
echo ====================================================================
echo   PROCESSING: %REPO_NAME%
echo ====================================================================

if not exist "%REPO_DIR%\.git" (
    git -C "%REPO_DIR%" init -b main || goto :err
)

:: Set exact GitHub URL for this repo
git -C "%REPO_DIR%" remote remove origin 2>nul
git -C "%REPO_DIR%" remote add origin "https://github.com/mercwar/%REPO_NAME%.git" || goto :err

:: 1. Fetch remote and pull the images folder straight onto your disk
echo [1/3] Downloading images folder from origin/main...
git -C "%REPO_DIR%" fetch origin main || goto :err
git -C "%REPO_DIR%" checkout origin/main -- images 2>nul
if errorlevel 1 (
    echo [WARN] No 'images' folder found on origin/main for %REPO_NAME%.
) else (
    echo [OK] 'images' folder downloaded to "%REPO_DIR%\images"
)

:: 2. Backup existing remote main to backup-main on GitHub
echo [2/3] Backing up remote main to backup-main...
git -C "%REPO_DIR%" push origin refs/remotes/origin/main:refs/heads/backup-main --force || goto :err

:: 3. Create fresh main from your local files (including images) and force-push
echo [3/3] Pushing local repo into fresh main...
git -C "%REPO_DIR%" checkout --orphan fresh_main || goto :err
git -C "%REPO_DIR%" reset || goto :err
git -C "%REPO_DIR%" add -A || goto :err
git -C "%REPO_DIR%" commit -m "Fresh main with images" || goto :err
git -C "%REPO_DIR%" branch -D main 2>nul
git -C "%REPO_DIR%" branch -M fresh_main main || goto :err
git -C "%REPO_DIR%" push origin main --force || goto :err

echo [SUCCESS] %REPO_NAME% synced!
echo.
exit /b 0

:err
echo [FAILED] Stopped on %REPO_NAME%. Check the error message above.
echo.
exit /b 1