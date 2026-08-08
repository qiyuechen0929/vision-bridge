@echo off
rem setup.bat - Vision Bridge config wizard (ASCII only; Chinese UI is in setup.ps1)
rem Usage:
rem   double-click          -> interactive wizard
rem   setup.bat <key>       -> set GLM key (backward compat)
rem   setup.bat -status     -> show config + test
rem   setup.bat -remove     -> delete .env
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ====================================
echo   Vision Bridge Setup
echo ====================================
echo.
if "%~1"=="-status" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -Status
) else if "%~1"=="-remove" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -RemoveKey
) else if "%~1"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -SetKey "%~1"
)
echo.
echo Done. Press any key to close.
pause >nul
