param(
    [Parameter(Mandatory = $true)]
    [string]$InstallDir
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoOwner = "1777maxim7771"
$RepoName = "AI-Swipe-Hover-Keyboard"
$Branch = "main"
$UserAgent = "AI-Swipe-Hover-Keyboard-Updater/4.3.2"
$InstallDir = [System.IO.Path]::GetFullPath($InstallDir)
$LogFile = Join-Path $InstallDir "UPDATE_LOG.txt"

function Write-UpdateLog {
    param([string]$Message)
    $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    try { Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8 } catch {}
}

function Add-CacheBuster {
    param([string]$Url)
    $separator = if ($Url.Contains("?")) { "&" } else { "?" }
    return $Url + $separator + "ts=" + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
}

function Get-VersionFromFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return [version]"0.0.0" }
    $content = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    $match = [regex]::Match($content, '(?im)^Version:\s*([0-9]+(?:\.[0-9]+){1,3})\s*$')
    if (-not $match.Success) { return [version]"0.0.0" }
    try { return [version]$match.Groups[1].Value } catch { return [version]"0.0.0" }
}

function Start-Keyboard {
    $noConsole = Join-Path $InstallDir "PROGRAM_FILES\START_NO_CONSOLE.bat"
    $withConsole = Join-Path $InstallDir "PROGRAM_FILES\START_WITH_CONSOLE.bat"
    if (Test-Path -LiteralPath $noConsole) {
        Write-UpdateLog "Starting application without console."
        Start-Process -FilePath $noConsole -WorkingDirectory (Split-Path $noConsole)
        return
    }
    if (Test-Path -LiteralPath $withConsole) {
        Write-UpdateLog "Starting application with console."
        Start-Process -FilePath $withConsole -WorkingDirectory (Split-Path $withConsole)
        return
    }
    throw "No application start BAT file was found."
}

$tempInstaller = Join-Path $env:TEMP ("AI_Swipe_Hover_Keyboard_Installer_" + [guid]::NewGuid().ToString("N") + ".ps1")
try {
    Write-UpdateLog "Checking GitHub repository for a newer or repaired version..."
    $manifestUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/latest.json"
    $manifest = Invoke-RestMethod -UseBasicParsing -Uri (Add-CacheBuster $manifestUrl) -Headers @{"User-Agent"=$UserAgent; "Cache-Control"="no-cache"} -TimeoutSec 30
    if (-not $manifest.version) { throw "latest.json does not contain version." }

    $localVersion = Get-VersionFromFile (Join-Path $InstallDir "VERSION_INFO.txt")
    $remoteVersion = [version][string]$manifest.version
    $sourcePath = Join-Path $InstallDir "PROGRAM_FILES\vertical_predictive_letter_wheel.py"
    $localSourceHash = if (Test-Path -LiteralPath $sourcePath) { (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant() } else { "missing" }
    $expectedSourceHash = if ($manifest.repair_source_sha256) { ([string]$manifest.repair_source_sha256).Trim().ToLowerInvariant() } else { $localSourceHash }

    Write-UpdateLog ("Local version:  {0}" -f $localVersion)
    Write-UpdateLog ("GitHub version: {0}" -f $remoteVersion)
    Write-UpdateLog ("Local source SHA-256:    {0}" -f $localSourceHash)
    Write-UpdateLog ("Expected source SHA-256: {0}" -f $expectedSourceHash)

    if ($localVersion -ge $remoteVersion -and $localSourceHash -eq $expectedSourceHash) {
        Write-UpdateLog "Installed version and source integrity are current."
        Start-Keyboard
        exit 0
    }

    Write-UpdateLog "Update or source repair is required. Downloading the newest installer..."
    $installerUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/INSTALL_LATEST_FROM_GITHUB.ps1"
    Invoke-WebRequest -UseBasicParsing -Uri (Add-CacheBuster $installerUrl) -OutFile $tempInstaller -Headers @{"User-Agent"=$UserAgent; "Cache-Control"="no-cache"} -TimeoutSec 60
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempInstaller -TargetDir $InstallDir
    exit $LASTEXITCODE
}
catch {
    Write-UpdateLog ("UPDATE ERROR: " + $_.Exception.Message)
    Write-UpdateLog "Starting the local installation when possible."
    try { Start-Keyboard } catch { Write-UpdateLog ("START ERROR: " + $_.Exception.Message) }
    exit 1
}
finally {
    try { Remove-Item -LiteralPath $tempInstaller -Force -ErrorAction SilentlyContinue } catch {}
    try { if ($PSCommandPath -like (Join-Path $env:TEMP "AI_Swipe_Hover_Keyboard_Updater_*.ps1")) { Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue } } catch {}
}
