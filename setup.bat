@echo off
rem setup.bat - configure the vision bridge (API key + status check)
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ====================================
echo   Vision Bridge - Setup
echo ====================================
echo.
set /p KEY=Enter your Zhipu GLM API Key (or press Enter to just check status):
if "%KEY%"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -Status
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -SetKey "%KEY%"
)
echo.
echo Press any key to close.
pause >nul
