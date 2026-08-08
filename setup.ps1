# setup.ps1 - one-click configuration for the vision bridge
# =============================================================
# Sets GLM_API_KEY as a User-level environment variable (persistent)
# and verifies network connectivity to the Zhipu API.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File setup.ps1              (show status)
#   powershell -ExecutionPolicy Bypass -File setup.ps1 -SetKey <key>
#   powershell -ExecutionPolicy Bypass -File setup.ps1 -RemoveKey
#   powershell -ExecutionPolicy Bypass -File setup.ps1 -Status
# =============================================================

param(
    [string]$SetKey,
    [switch]$RemoveKey,
    [switch]$Status
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-EnvValue([string]$Name) {
    $v = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, 'User') }
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, 'Machine') }
    return $v
}

Write-Host ""
Write-Host "==== Vision Bridge Setup ====" -ForegroundColor Cyan

# ---- remove key ----
if ($RemoveKey) {
    [Environment]::SetEnvironmentVariable('GLM_API_KEY', $null, 'User')
    Write-Host "GLM_API_KEY removed." -ForegroundColor Yellow
    return
}

# ---- set key ----
if ($SetKey) {
    if ($SetKey -notmatch '^[A-Za-z0-9]+\.[A-Za-z0-9]+$') {
        Write-Host "WARNING: the key format looks unusual (expect xxxx.xxxx). Saving anyway..." -ForegroundColor Yellow
    }
    [Environment]::SetEnvironmentVariable('GLM_API_KEY', $SetKey, 'User')
    Write-Host "GLM_API_KEY saved to User environment variables." -ForegroundColor Green
    Write-Host "NOTE: open a NEW PowerShell window (or restart the app) for it to take effect." -ForegroundColor Yellow
}

# ---- status ----
$key = Get-EnvValue 'GLM_API_KEY'
$hasKey = [bool]$key
$keyPreview = ''
if ($hasKey -and $key.Length -gt 8) { $keyPreview = $key.Substring(0, 8) + '...' }
Write-Host ""
Write-Host ("- GLM_API_KEY set:      {0}" -f $(if ($hasKey) { "YES ($keyPreview)" } else { 'NO' }))
Write-Host "- PowerShell version:  $($PSVersionTable.PSVersion)"
Write-Host "- Windows:             $([Environment]::OSVersion.VersionString)"

# ---- network check ----
Write-Host ""
Write-Host "Testing network to open.bigmodel.cn:443 ..." -ForegroundColor Gray
$tcp = New-Object System.Net.Sockets.TcpClient
try {
    $iar = $tcp.BeginConnect('open.bigmodel.cn', 443, $null, $null)
    if ($iar.AsyncWaitHandle.WaitOne(700) -and $tcp.Connected) {
        Write-Host "Network: OK (port 443 reachable)" -ForegroundColor Green
    } else {
        Write-Host "Network: FAILED (cannot reach port 443). Check firewall/proxy." -ForegroundColor Red
    }
} catch {
    Write-Host "Network: FAILED ($($_.Exception.Message))" -ForegroundColor Red
} finally {
    $tcp.Close()
}

Write-Host ""
if (-not $hasKey) {
    Write-Host "Next step: get a free key at https://open.bigmodel.cn/ then run:" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File setup.ps1 -SetKey <your-key>" -ForegroundColor Yellow
} else {
    Write-Host "Ready. Start the watcher and ask your AI to recognize images." -ForegroundColor Green
}
Write-Host ""
