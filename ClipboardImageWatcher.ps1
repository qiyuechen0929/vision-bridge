# ClipboardImageWatcher.ps1 - paste/copy/screenshot image forwarder
# =============================================================
# Watches the clipboard and system temp dirs for new images, then
# saves them into the "received" folder next to this script.
#
# Why this exists:
#   Some AI backends (e.g. DeepSeek) are text-only and reject image
#   messages. But pasted images still land on disk (clipboard / temp
#   files). This script grabs them so your AI assistant can read the
#   file and send it to a vision model (GLM-4.1V-Thinking) instead.
#
# Requirements: Windows 10/11 only. No install, no Python.
# Run: double-click start-watcher.bat  (recommended)
# Stop: Ctrl+C
# =============================================================

$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---- config ----
# Save folder: "received" directory next to this script.
$saveDir = Join-Path $PSScriptRoot 'received'
$watchDirs = @("$env:TEMP", "$env:USERPROFILE\AppData\Local\Temp") | Select-Object -Unique

New-Item -ItemType Directory -Force -Path $saveDir | Out-Null

# Remember hashes we already saved so the same image is not re-saved.
$seen = New-Object 'System.Collections.Generic.HashSet[string]'

function Save-ImageBytes([byte[]]$Bytes, [string]$Tag) {
    try {
        if ($Bytes.Length -lt 100) { return }
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $hash = [BitConverter]::ToString($sha.ComputeHash($Bytes)).Replace('-', '')
        $sha.Dispose()
        if ($seen.Contains($hash)) { return }
        $seen.Add($hash) | Out-Null
        $ts = Get-Date -Format "yyyyMMdd_HHmmssfff"
        $path = Join-Path $saveDir ("img_{0}_{1}.png" -f $Tag, $ts)
        [IO.File]::WriteAllBytes($path, $Bytes)
        Write-Host ("[{0}] SAVED: {1}" -f (Get-Date -Format "HH:mm:ss"), (Split-Path $path -Leaf)) -ForegroundColor Yellow
    } catch {
        Write-Host ("SAVE FAILED: " + $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  Clipboard/Temp Image Forwarder started" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ("Save dir: {0}" -f $saveDir) -ForegroundColor Gray
Write-Host ""
Write-Host "Now screenshot / copy / paste an image into chat." -ForegroundColor Gray
Write-Host "When you see SAVED, ask your AI to recognize the image." -ForegroundColor Gray
Write-Host "Ctrl+C to stop." -ForegroundColor Gray
Write-Host ""

$lastSweep = Get-Date

while ($true) {
    # ---- channel 1: clipboard image ----
    try {
        $img = [System.Windows.Forms.Clipboard]::GetImage()
        if ($null -ne $img) {
            $ms = New-Object System.IO.MemoryStream
            $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
            $bytes = $ms.ToArray()
            $ms.Dispose()
            $img.Dispose()
            Save-ImageBytes -Bytes $bytes -Tag "clip"
        }
    } catch { }

    # ---- channel 2: temp dirs (images produced when pasting into a chat app) ----
    $now = Get-Date
    if (($now - $lastSweep).TotalSeconds -ge 2) {
        $lastSweep = $now
        foreach ($dir in $watchDirs) {
            if (-not (Test-Path $dir)) { continue }
            try {
                $candidates = Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Extension -in '.png', '.jpg', '.jpeg', '.bmp', '.webp' -and $_.LastWriteTime -gt (Get-Date).AddSeconds(-10) }
                foreach ($f in $candidates) {
                    try {
                        $b = [IO.File]::ReadAllBytes($f.FullName)
                        Save-ImageBytes -Bytes $b -Tag "temp"
                    } catch { }
                }
            } catch { }
        }
    }

    Start-Sleep -Milliseconds 800
}
