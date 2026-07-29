@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

set "LOCAL_SCRIPT=%~dp0INSTALL_LATEST_FROM_GITHUB.ps1"
set "TEMP_SCRIPT=%TEMP%\AI_Swipe_Hover_Keyboard_Installer_%RANDOM%_%RANDOM%.ps1"
set "AI_INSTALLER_URL=https://raw.githubusercontent.com/1777maxim7771/AI-Swipe-Hover-Keyboard/main/INSTALL_LATEST_FROM_GITHUB.ps1"
set "AI_TEMP_INSTALLER=%TEMP_SCRIPT%"

rem Fetch the newest installer logic before reading latest.json. This avoids
rem schema mismatch when an old local PS1 expects obsolete manifest fields.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $u=$env:AI_INSTALLER_URL + '?ts=' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds(); Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $env:AI_TEMP_INSTALLER -Headers @{'User-Agent'='AI-Swipe-Hover-Keyboard-Bootstrap';'Cache-Control'='no-cache'} -TimeoutSec 30" >nul 2>&1

if exist "%TEMP_SCRIPT%" (
    set "SCRIPT=%TEMP_SCRIPT%"
) else (
    set "SCRIPT=%LOCAL_SCRIPT%"
)

if not exist "%SCRIPT%" (
    echo [ERROR] No installer script is available.
    echo Local fallback: %LOCAL_SCRIPT%
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -TargetDir "%~dp0AI_Swipe_Hover_Keyboard"
set "EXIT_CODE=%ERRORLEVEL%"
if exist "%TEMP_SCRIPT%" del /q "%TEMP_SCRIPT%" >nul 2>&1
if not "%EXIT_CODE%"=="0" pause
endlocal & exit /b %EXIT_CODE%
