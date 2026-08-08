# recognize.ps1 - recognize an image with GLM vision API (pure PowerShell)
# =============================================================
# Usage:
#   powershell -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath <image> [-Prompt "<question>"] [-Model glm-thinking] [-Json]
#
# Channels / models:
#   glm           = glm-4v-flash            (free, fast, simple descriptions)
#   glm-thinking  = glm-4.1v-thinking-flash (complex reasoning, charts, screenshots)
#
# API key: read from env var GLM_API_KEY (Process/User/Machine). See setup.ps1.
#
# Exit codes: 0 success, 1 generic, 2 missing key/auth, 3 rate limited,
#             4 network/server, 5 request rejected.
# =============================================================

param(
    [Parameter(Mandatory = $true)][string]$ImagePath,
    [string]$Prompt = 'Describe this image in detail.',
    [ValidateSet('glm', 'glm-thinking')][string]$Channel = 'glm-thinking',
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-EnvValue([string]$Name) {
    $v = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, 'User') }
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, 'Machine') }
    return $v
}

# ---- 1. check image ----
if (-not (Test-Path -LiteralPath $ImagePath)) {
    Write-Error "ERROR: image not found: $ImagePath"
    exit 1
}

# ---- 2. resolve endpoint/model ----
$baseUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions'
$model = if ($Channel -eq 'glm') { 'glm-4v-flash' } else { 'glm-4.1v-thinking-flash' }

# ---- 3. resolve key ----
$key = Get-EnvValue 'GLM_API_KEY'
if (-not $key) {
    Write-Error "ERROR: GLM_API_KEY not set. Run setup.ps1 first."
    exit 2
}

# ---- 4. encode image ----
$bytes = [IO.File]::ReadAllBytes($ImagePath)
$sizeMB = [Math]::Round($bytes.Length / 1MB, 2)
if ($sizeMB -gt 15) {
    Write-Error "ERROR: image too large (${sizeMB} MB). Downscale it first."
    exit 1
}
$b64 = [Convert]::ToBase64String($bytes)
$ext = [IO.Path]::GetExtension($ImagePath).ToLower()
$mime = switch ($ext) {
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.png'  { 'image/png' }
    '.webp' { 'image/webp' }
    '.gif'  { 'image/gif' }
    '.bmp'  { 'image/bmp' }
    default { 'image/png' }
}

$content = @(@{ type = 'image_url'; image_url = @{ url = "data:$mime;base64,$b64" } })
if ($Prompt) { $content += @{ type = 'text'; text = $Prompt } }
$body = @{ model = $model; messages = @(@{ role = 'user'; content = $content }) } |
    ConvertTo-Json -Depth 12

# ---- 5. call API ----
try {
    $r = Invoke-RestMethod -Uri $baseUrl -Method Post `
        -Headers @{ Authorization = "Bearer $key" } `
        -ContentType 'application/json; charset=utf-8' `
        -Body $body -TimeoutSec 120
} catch {
    $status = 0
    if ($_.Exception.Response) {
        try { $status = [int]$_.Exception.Response.StatusCode } catch { }
    }
    switch ($status) {
        401 { Write-Error "ERROR: auth failed (401). Check your GLM_API_KEY."; exit 2 }
        403 { Write-Error "ERROR: auth failed (403). Check your GLM_API_KEY."; exit 2 }
        429 { Write-Error "ERROR: rate limited (429). Try again later."; exit 3 }
        default {
            if ($status -eq 0 -or $status -ge 500) {
                Write-Error "ERROR: network/server ($status): $($_.Exception.Message)"; exit 4
            }
            Write-Error "ERROR: request rejected ($status): $($_.Exception.Message)"; exit 5
        }
    }
}

# ---- 6. output ----
if ($r.choices -and $r.choices[0].message.content) {
    $result = $r.choices[0].message.content
    # strip GLM box markers like <|begin_of_box|> / <|end_of_box|>
    $result = $result -replace '<\|begin_of_box\|>', '' -replace '<\|end_of_box\|>', ''
    $result = $result.Trim()
    if ($Json) {
        $envelope = [ordered]@{
            task_type  = 'image_reasoning'
            tool_used  = "$Channel`:$model"
            confidence = 'high'
            result     = $result
            metadata   = [ordered]@{
                model = $model
                image = [IO.Path]::GetFileName($ImagePath)
                usage = $r.usage
            }
        }
        Write-Output ($envelope | ConvertTo-Json -Depth 8)
    } else {
        Write-Output $result
    }
    exit 0
}

Write-Error 'ERROR: empty response content.'
exit 1
