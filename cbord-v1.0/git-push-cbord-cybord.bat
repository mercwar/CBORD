@echo off
setlocal EnableDelayedExpansion
title Sync CBORD and CYBORD Repos

set "REPO1=C:\Mercwar-AI\dc2win\dc2win_bk\CBORD"
set "REPO2=C:\Mercwar-AI\dc2win\dc2win_bk\CYBORD"
set "IMG_DIR=C:\Mercwar-AI\dc2win\dc2win_bk\pulled_images"

if not exist "%IMG_DIR%" mkdir "%IMG_DIR%"

for %%R in ("%REPO1%" "%REPO2%") do (
    echo ====================================================================
    echo   PROCESSING: %%~nxR
    echo ====================================================================
    
    pushd "%%~R"

    :: Clean up temp branch if left over from the previous run
    git branch -D temp_empty >nul 2>&1

    :: Detect current branch name (e.g., main or master)
    for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD') do set "MAIN_BRANCH=%%B"
    echo   Active Branch: !MAIN_BRANCH!

    :: 1. Fetch remote state & extract images
    git fetch origin
    if not exist "%IMG_DIR%\%%~nxR" mkdir "%IMG_DIR%\%%~nxR"
    git archive origin/!MAIN_BRANCH! --format=tar 2>nul | tar -x -C "%IMG_DIR%\%%~nxR" --wildcards "*.png" "*.jpg" "*.jpeg" "*.gif" "*.ico" "*.bmp" "*.webp" "*.svg" 2>nul

    :: 2. Push current remote state to a dated backup branch
    git push origin origin/!MAIN_BRANCH!:refs/heads/backup-%DATE:~-4%%DATE:~4,2%%DATE:~7,2% 2>nul

    :: 3. Push an empty commit directly to remote without touching local files
    for /f "delims=" %%E in ('git commit-tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904 -m "Reset repository"') do set "EMPTY_COMMIT=%%E"
    git push origin !EMPTY_COMMIT!:refs/heads/!MAIN_BRANCH! --force

    :: 4. Stage and force-push your local working directory back up
    git add -A
    git commit -m "Sync local copy" >nul 2>&1
    git push origin !MAIN_BRANCH! --force

    popd
)

echo.
echo [DONE] Images extracted to %IMG_DIR%, remote backed up, and local copies pushed.
pause
