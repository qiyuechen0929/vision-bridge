@echo off
rem start-watcher.bat - launch ClipboardImageWatcher (vision bridge)
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClipboardImageWatcher.ps1"
echo.
echo Watcher exited with code %ERRORLEVEL%. Press any key to close.
pause >nul
