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
        Write-Host ("[{0}] 已保存: {1}" -f (Get-Date -Format "HH:mm:ss"), (Split-Path $path -Leaf)) -ForegroundColor Yellow
    } catch {
        Write-Host ("保存失败: " + $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  剪贴板/临时目录 图片监视器 已启动" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ("保存目录: {0}" -f $saveDir) -ForegroundColor Gray
Write-Host ""

# ---- 启动自检：视觉桥是否已配置 ----
$envFile = Join-Path $PSScriptRoot '.env'
$hasDotEnv = Test-Path -LiteralPath $envFile
$hasLegacyKey = [bool]([Environment]::GetEnvironmentVariable('GLM_API_KEY', 'User'))
if (-not $hasDotEnv -and -not $hasLegacyKey) {
    Write-Host "警告：尚未配置 API Key。请先双击 setup.bat 完成配置，否则无法识别图片。" -ForegroundColor Yellow
} else {
    Write-Host ("视觉桥已配置（.env: {0}，环境变量 Key: {1}）。" -f $hasDotEnv, $hasLegacyKey) -ForegroundColor Gray
}
Write-Host ""
Write-Host "现在可以截图 / 复制 / 粘贴图片了。" -ForegroundColor Gray
Write-Host "看到 SAVED 后，让 AI 识别图片即可。" -ForegroundColor Gray
Write-Host "按 Ctrl+C 停止。" -ForegroundColor Gray
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
