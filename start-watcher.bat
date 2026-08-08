@echo off
rem start-watcher.bat - launch ClipboardImageWatcher with execution-policy bypass
rem and keep the window open so errors are visible instead of flashing away.
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClipboardImageWatcher.ps1"
echo.
echo Watcher exited with code %ERRORLEVEL%. Press any key to close.
pause >nul
