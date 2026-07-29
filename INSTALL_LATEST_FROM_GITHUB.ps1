param(
    [string]$TargetDir = (Join-Path $PSScriptRoot "AI_Swipe_Hover_Keyboard")
)
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$RepoOwner = "1777maxim7771"
$RepoName = "AI-Swipe-Hover-Keyboard"
$Branch = "main"
$tempRoot = Join-Path $env:TEMP ("AI_Swipe_Hover_Keyboard_First_Install_" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "latest.zip"
$extractDir = Join-Path $tempRoot "extract"
try {
    New-Item -ItemType Directory -Path $tempRoot, $extractDir -Force | Out-Null
    Write-Host "Checking the latest version on GitHub..."
    $manifestUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/latest.json"
    $manifest = Invoke-RestMethod -Uri $manifestUrl -Headers @{"User-Agent"="AI-Swipe-Hover-Keyboard-Installer"} -TimeoutSec 30
    if (-not $manifest.package_parts) { throw "latest.json does not contain package_parts." }
    $builder = New-Object System.Text.StringBuilder
    $partNo = 0
    foreach ($url in $manifest.package_parts) {
        $partNo++
        Write-Host ("Downloading part {0}/{1}..." -f $partNo, $manifest.package_parts.Count)
        $part = Invoke-RestMethod -Uri ([string]$url) -Headers @{"User-Agent"="AI-Swipe-Hover-Keyboard-Installer"} -TimeoutSec 45
        [void]$builder.Append(([string]$part).Trim())
    }
    [System.IO.File]::WriteAllBytes($zipPath, [Convert]::FromBase64String($builder.ToString()))
    $actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $expected = ([string]$manifest.sha256).Trim().ToLowerInvariant()
    if ($actual -ne $expected) { throw "SHA-256 verification failed." }
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force
    $source = Get-ChildItem -LiteralPath $extractDir -Directory | Select-Object -First 1
    if (-not $source) { throw "The package does not contain an application directory." }
    if (Test-Path -LiteralPath $TargetDir) {
        $answer = Read-Host "Target directory exists. Replace program files while keeping local settings? [Y/N]"
        if ($answer -notmatch '^[YyДд]') { throw "Installation cancelled by user." }
    } else {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    Copy-Item -LiteralPath (Join-Path $source.FullName '*') -Destination $TargetDir -Recurse -Force
    Write-Host ("Installed version {0} to {1}" -f $manifest.version, $TargetDir)
    $starter = Join-Path $TargetDir "UPDATE_AND_START.bat"
    if (Test-Path -LiteralPath $starter) { Start-Process -FilePath $starter -WorkingDirectory $TargetDir }
    exit 0
}
catch {
    Write-Host ("INSTALL ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
finally {
    try { Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}
