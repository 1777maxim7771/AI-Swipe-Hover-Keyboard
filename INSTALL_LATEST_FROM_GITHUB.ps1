param([string]$TargetDir = (Join-Path $PSScriptRoot "AI_Swipe_Hover_Keyboard"))
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$manifestUrl = "https://raw.githubusercontent.com/1777maxim7771/AI-Swipe-Hover-Keyboard/main/latest.json"
$tempRoot = Join-Path $env:TEMP ("AI_Swipe_Hover_Keyboard_Install_" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "latest.zip"
$extractDir = Join-Path $tempRoot "extract"
try {
    New-Item -ItemType Directory -Path $tempRoot, $extractDir -Force | Out-Null
    Write-Host "Checking the latest version on GitHub..."
    $manifest = Invoke-RestMethod -Uri $manifestUrl -Headers @{"User-Agent"="AI-Swipe-Hover-Keyboard-Installer"} -TimeoutSec 30
    if (-not $manifest.download_url) { throw "latest.json does not contain download_url." }
    Invoke-WebRequest -Uri ([string]$manifest.download_url) -OutFile $zipPath -Headers @{"User-Agent"="AI-Swipe-Hover-Keyboard-Installer"} -TimeoutSec 90
    $actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $expected = ([string]$manifest.sha256).Trim().ToLowerInvariant()
    if ($actual -ne $expected) { throw "SHA-256 verification failed." }
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force
    $source = Get-ChildItem -LiteralPath $extractDir -Directory | Select-Object -First 1
    if (-not $source) { throw "The package does not contain an application directory." }
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Get-ChildItem -LiteralPath $source.FullName -Force | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $TargetDir -Recurse -Force }
    Write-Host ("Installed version {0} to {1}" -f $manifest.version, $TargetDir)
    $starter = Join-Path $TargetDir "UPDATE_AND_START.bat"
    if (Test-Path -LiteralPath $starter) { Start-Process -FilePath $starter -WorkingDirectory $TargetDir }
    exit 0
} catch {
    Write-Host ("INSTALL ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
} finally {
    try { Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}
