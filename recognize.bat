@echo off
rem recognize.bat - launch recognize.ps1 on the newest image in the received folder.
rem Usage: drag & drop an image onto this file, OR double-click to recognize the newest one.
chcp 65001 >nul
cd /d "%~dp0"

set "IMG=%~1"
if "%IMG%"=="" (
    rem no image passed -> use newest file in received folder
    for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-ChildItem -Path '%~dp0received' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"') do set "IMG=%%i"
)

if "%IMG%"=="" (
    echo No image found. Drag & drop an image onto this file, or put images in the received folder.
    pause
    exit /b 1
)

echo Recognizing: %IMG%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0recognize.ps1" -ImagePath "%IMG%" -Channel glm-thinking
echo.
echo Done. Press any key to close.
pause >nul
