@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "SCRIPT=%~dp0INSTALL_LATEST_FROM_GITHUB.ps1"
if not exist "%SCRIPT%" (
  echo [ERROR] INSTALL_LATEST_FROM_GITHUB.ps1 was not found.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -TargetDir "%~dp0AI_Swipe_Hover_Keyboard"
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" pause
endlocal & exit /b %EXIT_CODE%
