@echo off
rem recognize.bat - recognize the newest image in received folder via recognize.ps1
rem Usage: drag & drop an image onto this file, OR double-click to use newest image.
rem Uses provider/model from .env (run setup.bat first).
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0recognize.ps1" -ImagePath "%~1"
echo.
echo Done. Press any key to close.
pause >nul
