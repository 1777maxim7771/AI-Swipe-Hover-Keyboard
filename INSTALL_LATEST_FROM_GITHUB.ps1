param(
    [string]$TargetDir = (Join-Path $PSScriptRoot "AI_Swipe_Hover_Keyboard")
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoOwner = "1777maxim7771"
$RepoName = "AI-Swipe-Hover-Keyboard"
$Branch = "main"
$UserAgent = "AI-Swipe-Hover-Keyboard-Installer/4.3.2"
$LogFile = Join-Path $PSScriptRoot "INSTALL_LOG.txt"
$tempRoot = Join-Path $env:TEMP ("AI_Swipe_Hover_Keyboard_Install_" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "latest.zip"
$extractDir = Join-Path $tempRoot "extract"
$backupDir = Join-Path $tempRoot "backup"
$preserveDir = Join-Path $tempRoot "preserve"
$installationChanged = $false

function Write-InstallLog {
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

function Invoke-JsonWithRetry {
    param([string]$Url, [int]$Attempts = 3)
    $lastError = $null
    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        try {
            return Invoke-RestMethod -UseBasicParsing -Uri (Add-CacheBuster $Url) -Headers @{"User-Agent"=$UserAgent; "Cache-Control"="no-cache"} -TimeoutSec 30
        } catch {
            $lastError = $_
            Write-InstallLog ("Manifest attempt {0}/{1} failed: {2}" -f $attempt, $Attempts, $_.Exception.Message)
            if ($attempt -lt $Attempts) { Start-Sleep -Seconds $attempt }
        }
    }
    throw $lastError
}

function Invoke-FileDownloadWithRetry {
    param([string]$Url, [string]$Destination, [int]$Attempts = 3)
    $lastError = $null
    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        try {
            if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Force }
            Write-InstallLog ("Download attempt {0}/{1}" -f $attempt, $Attempts)
            Invoke-WebRequest -UseBasicParsing -Uri (Add-CacheBuster $Url) -OutFile $Destination -Headers @{"User-Agent"=$UserAgent; "Cache-Control"="no-cache"} -TimeoutSec 180
            if ((Get-Item -LiteralPath $Destination).Length -le 0) { throw "Downloaded file is empty." }
            return
        } catch {
            $lastError = $_
            Write-InstallLog ("Download attempt failed: {0}" -f $_.Exception.Message)
            if ($attempt -lt $Attempts) { Start-Sleep -Seconds $attempt }
        }
    }
    throw $lastError
}

function Get-PropertyValue {
    param($Object, [string[]]$Names)
    foreach ($name in $Names) {
        $property = $Object.PSObject.Properties[$name]
        if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return $property.Value
        }
    }
    return $null
}

function Download-PackageFromManifest {
    param($Manifest, [string]$Destination)
    $directUrl = Get-PropertyValue $Manifest @("download_url", "package_url")
    if ($directUrl) {
        Write-InstallLog ("Using direct ZIP manifest field: {0}" -f $directUrl)
        Invoke-FileDownloadWithRetry -Url ([string]$directUrl) -Destination $Destination
        return
    }

    $partsProperty = $Manifest.PSObject.Properties["package_parts"]
    if ($null -ne $partsProperty -and $null -ne $partsProperty.Value -and @($partsProperty.Value).Count -gt 0) {
        $parts = @($partsProperty.Value)
        $builder = New-Object System.Text.StringBuilder
        for ($index = 0; $index -lt $parts.Count; $index++) {
            $partUrl = [string]$parts[$index]
            Write-InstallLog ("Downloading legacy package part {0}/{1}" -f ($index + 1), $parts.Count)
            $response = Invoke-WebRequest -UseBasicParsing -Uri (Add-CacheBuster $partUrl) -Headers @{"User-Agent"=$UserAgent; "Cache-Control"="no-cache"} -TimeoutSec 60
            [void]$builder.Append(([string]$response.Content -replace '\s', ''))
        }
        try {
            [System.IO.File]::WriteAllBytes($Destination, [Convert]::FromBase64String($builder.ToString()))
        } catch {
            throw "Legacy package_parts could not be decoded as Base64: $($_.Exception.Message)"
        }
        return
    }

    $keys = ($Manifest.PSObject.Properties.Name -join ", ")
    throw "latest.json has no supported package field. Expected download_url, package_url, or package_parts. Available fields: $keys"
}

try {
    New-Item -ItemType Directory -Path $tempRoot, $extractDir, $backupDir, $preserveDir -Force | Out-Null
    Write-InstallLog "Checking the latest version on GitHub..."
    $manifestUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/latest.json"
    $manifest = Invoke-JsonWithRetry -Url $manifestUrl
    if (-not $manifest.version) { throw "latest.json does not contain version." }
    if (-not $manifest.sha256) { throw "latest.json does not contain sha256." }

    Download-PackageFromManifest -Manifest $manifest -Destination $zipPath
    $actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $expected = ([string]$manifest.sha256).Trim().ToLowerInvariant()
    Write-InstallLog ("Expected SHA-256: {0}" -f $expected)
    Write-InstallLog ("Actual SHA-256:   {0}" -f $actual)
    if ($actual -ne $expected) { throw "SHA-256 verification failed." }

    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force
    $source = Get-ChildItem -LiteralPath $extractDir -Directory | Select-Object -First 1
    if (-not $source) { throw "The package does not contain an application directory." }
    if (-not (Test-Path -LiteralPath (Join-Path $source.FullName "PROGRAM_FILES"))) { throw "The package does not contain PROGRAM_FILES." }

    if (Test-Path -LiteralPath $TargetDir) {
        Write-InstallLog "Creating rollback backup and preserving local configuration."
        Copy-Item -LiteralPath $TargetDir -Destination $backupDir -Recurse -Force
        $currentProgram = Join-Path $TargetDir "PROGRAM_FILES"
        foreach ($name in @("API_KEY_CONFIG.bat", "settings.json", "window_position.json", "letter_learning.json", "language_usage.json", "logs")) {
            $current = Join-Path $currentProgram $name
            if (Test-Path -LiteralPath $current) { Copy-Item -LiteralPath $current -Destination $preserveDir -Recurse -Force }
        }
    }

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    $installationChanged = $true
    Get-ChildItem -LiteralPath $source.FullName -Force | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $TargetDir -Recurse -Force }

    $newProgram = Join-Path $TargetDir "PROGRAM_FILES"
    foreach ($saved in Get-ChildItem -LiteralPath $preserveDir -Force -ErrorAction SilentlyContinue) {
        $target = Join-Path $newProgram $saved.Name
        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
        Copy-Item -LiteralPath $saved.FullName -Destination $target -Recurse -Force
    }

    $installationChanged = $false
    Write-InstallLog ("Installed version {0} to {1}" -f $manifest.version, $TargetDir)
    $starter = Join-Path $TargetDir "UPDATE_AND_START.bat"
    if (Test-Path -LiteralPath $starter) { Start-Process -FilePath $starter -WorkingDirectory $TargetDir }
    exit 0
}
catch {
    Write-InstallLog ("INSTALL ERROR: " + $_.Exception.Message)
    if ($installationChanged) {
        try {
            $savedTarget = Get-ChildItem -LiteralPath $backupDir -Directory | Select-Object -First 1
            if ($savedTarget) {
                Write-InstallLog "Restoring previous installation from rollback backup."
                if (Test-Path -LiteralPath $TargetDir) { Remove-Item -LiteralPath $TargetDir -Recurse -Force }
                Copy-Item -LiteralPath $savedTarget.FullName -Destination $TargetDir -Recurse -Force
            }
        } catch {
            Write-InstallLog ("ROLLBACK ERROR: " + $_.Exception.Message)
        }
    }
    exit 1
}
finally {
    try { Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    try { if ($PSCommandPath -like (Join-Path $env:TEMP "AI_Swipe_Hover_Keyboard_Installer_*.ps1")) { Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue } } catch {}
}
