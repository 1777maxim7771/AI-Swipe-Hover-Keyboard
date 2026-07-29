@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

set "LOCAL_UPDATER=%~dp0PROGRAM_FILES\UPDATE_FROM_GITHUB.ps1"
set "TEMP_UPDATER=%TEMP%\AI_Swipe_Hover_Keyboard_Updater_%RANDOM%_%RANDOM%.ps1"
set "AI_UPDATER_URL=https://raw.githubusercontent.com/1777maxim7771/AI-Swipe-Hover-Keyboard/main/UPDATE_FROM_GITHUB.ps1"
set "AI_TEMP_UPDATER=%TEMP_UPDATER%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $u=$env:AI_UPDATER_URL + '?ts=' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds(); Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $env:AI_TEMP_UPDATER -Headers @{'User-Agent'='AI-Swipe-Hover-Keyboard-Bootstrap';'Cache-Control'='no-cache'} -TimeoutSec 30" >nul 2>&1

if exist "%TEMP_UPDATER%" (
    set "UPDATER=%TEMP_UPDATER%"
) else (
    set "UPDATER=%LOCAL_UPDATER%"
)

if not exist "%UPDATER%" (
    echo [ERROR] No updater script is available.
    echo Local fallback: %LOCAL_UPDATER%
    pause
    exit /b 1
)

start "AI Swipe Hover Keyboard Updater" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%UPDATER%" -InstallDir "%~dp0"
exit /b 0
