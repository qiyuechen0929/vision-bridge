# recognize.ps1 - 通过任意 OpenAI 兼容视觉 API 识别图片
# =============================================================
# 用法：
#   powershell -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath <图片路径> [-Prompt "问题"] [-Json]
#   powershell -ExecutionPolicy Bypass -File recognize.ps1    （不传图片则自动找 received/ 里最新一张）
#
# 配置（本脚本同目录 .env，由 setup.bat 生成）：
#   VISION_PROVIDER  = glm | dashscope | openai | moonshot | siliconflow | ollama | custom
#   VISION_API_KEY   = 你的 API Key（Ollama 不需要）
#   VISION_MODEL     = 使用的模型（默认取服务商第一个）
#   VISION_BASE_URL  = 接口地址（provider=custom 时必填）
#
# 向后兼容：
#   - .env 或环境变量里的 GLM_API_KEY 等价于 provider=glm
#   - -Channel 参数保留但已废弃（v3 旧参数），provider 一律由 .env 决定
#   - -Provider / -Model / -BaseUrl 可临时覆盖 .env（通常不需要）
#
# 退出码：0 成功 · 1 通用错误 · 2 缺 Key/认证失败 · 3 限流 · 4 网络 · 5 请求被拒
# =============================================================

param(
    [string]$ImagePath = '',
    [string]$Prompt = 'Describe this image in detail.',
    [ValidateSet('glm', 'glm-thinking')][string]$Channel = 'glm-thinking',
    [string]$Provider = '',
    [string]$Model = '',
    [string]$BaseUrl = '',
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 加载服务商注册表（用于默认值） ---
. (Join-Path $PSScriptRoot 'providers.ps1')

function Get-EnvValue([string]$Name) {
    $v = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, 'User') }
    if (-not $v) { $v = [Environment]::GetEnvironmentVariable($Name, 'Machine') }
    return $v
}

# 解析本脚本同目录的 .env 文件为哈希表
function Read-DotEnv {
    $envPath = Join-Path $PSScriptRoot '.env'
    $map = @{}
    if (Test-Path -LiteralPath $envPath) {
        foreach ($line in Get-Content -LiteralPath $envPath -Encoding UTF8) {
            $line = $line.Trim()
            if (-not $line -or $line.StartsWith('#') -or $line -notmatch '=') { continue }
            $k = $line.Substring(0, $line.IndexOf('=')).Trim()
            $v = $line.Substring($line.IndexOf('=') + 1).Trim().Trim('"', "'")
            $map[$k] = $v
        }
    }
    return $map
}

# ---- 1. 解析图片路径（未指定时自动找 received/ 最新一张） ----
if (-not $ImagePath) {
    $receivedDir = Join-Path $PSScriptRoot 'received'
    if (Test-Path -LiteralPath $receivedDir) {
        $newest = Get-ChildItem -LiteralPath $receivedDir -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($newest) { $ImagePath = $newest.FullName }
    }
    if (-not $ImagePath) {
        Write-Error "错误：没有指定图片，且 received/ 文件夹里没有图片。把图片拖到 recognize.bat 上，或放到 received/ 文件夹。"
        exit 1
    }
}
if (-not (Test-Path -LiteralPath $ImagePath)) {
    Write-Error "错误：找不到图片：$ImagePath"
    exit 1
}

# ---- 2. 解析配置（优先级：命令行参数 > .env > 环境变量 > 默认值） ----
$envCfg = Read-DotEnv

# 服务商
$resolvedProvider = $Provider
if (-not $resolvedProvider) { $resolvedProvider = $envCfg['VISION_PROVIDER'] }
if (-not $resolvedProvider -and ($envCfg['GLM_API_KEY'] -or (Get-EnvValue 'GLM_API_KEY'))) {
    $resolvedProvider = 'glm'
}
if (-not $resolvedProvider -or -not $VisionProviders.Contains($resolvedProvider)) {
    Write-Error "错误：未配置有效的 VISION_PROVIDER。请先运行 setup.bat（或在 .env 中设置 VISION_PROVIDER）。"
    exit 2
}
$p = $VisionProviders[$resolvedProvider]

# API Key
$apiKey = $envCfg['VISION_API_KEY']
if (-not $apiKey) { $apiKey = $envCfg['GLM_API_KEY'] }
if (-not $apiKey) { $apiKey = Get-EnvValue 'GLM_API_KEY' }

# 模型
$model = $Model
if (-not $model) { $model = $envCfg['VISION_MODEL'] }
if (-not $model) { $model = $p.Models[0] }
if (-not $model) { $model = 'gpt-4o' }

# 接口地址
$baseUrl = $BaseUrl
if (-not $baseUrl) { $baseUrl = $envCfg['VISION_BASE_URL'] }
if (-not $baseUrl) { $baseUrl = $p.BaseUrl }
if (-not $baseUrl) {
    Write-Error "错误：未配置 VISION_BASE_URL。请在 .env 中设置（自定义服务商必须填）。"
    exit 2
}

# Key 检查（本地服务商如 Ollama 跳过）
if ($p.NeedsKey -and -not $apiKey) {
    Write-Error "错误：未配置 API Key。请先运行 setup.bat。"
    exit 2
}

# ---- 3. 编码图片 ----
$bytes = [IO.File]::ReadAllBytes($ImagePath)
$sizeMB = [Math]::Round($bytes.Length / 1MB, 2)
if ($sizeMB -gt 15) {
    Write-Error "错误：图片太大（${sizeMB} MB）。请先压缩。"
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
$bodyObj = @{ model = $model; messages = @(@{ role = 'user'; content = $content }) }
$body = $bodyObj | ConvertTo-Json -Depth 12
# PS5.1 下传字符串 body 会按 ISO-8859-1 编码导致中文乱码，必须转 UTF-8 字节。
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

$uri = $baseUrl.TrimEnd('/') + '/chat/completions'

# ---- 4. 调用 API ----
$headers = @{ 'Content-Type' = 'application/json; charset=utf-8' }
if ($apiKey) { $headers['Authorization'] = "Bearer $apiKey" }

try {
    $r = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $bodyBytes -TimeoutSec 120
} catch {
    $status = 0
    if ($_.Exception.Response) {
        try { $status = [int]$_.Exception.Response.StatusCode } catch { }
    }
    switch ($status) {
        401 { Write-Error "错误：认证失败 (401)。请检查 API Key。"; exit 2 }
        403 { Write-Error "错误：认证失败 (403)。请检查 API Key。"; exit 2 }
        429 { Write-Error "错误：请求过于频繁 (429)。请稍后重试。"; exit 3 }
        default {
            if ($status -eq 0 -or $status -ge 500) {
                Write-Error "错误：网络/服务器 ($status)：$($_.Exception.Message)"; exit 4
            }
            Write-Error "错误：请求被拒绝 ($status)：$($_.Exception.Message)"; exit 5
        }
    }
}

# ---- 5. 输出 ----
if ($r.choices -and $r.choices[0].message.content) {
    $result = $r.choices[0].message.content
    # 去掉部分模型输出的标记符
    $result = $result -replace '<\|begin_of_box\|>', '' -replace '<\|end_of_box\|>', ''
    $result = $result.Trim()
    if ($Json) {
        $envelope = [ordered]@{
            task_type  = 'image_reasoning'
            tool_used  = "$resolvedProvider`:$model"
            confidence = 'high'
            result     = $result
            metadata   = [ordered]@{
                model  = $model
                image  = [IO.Path]::GetFileName($ImagePath)
                usage  = $r.usage
            }
        }
        Write-Output ($envelope | ConvertTo-Json -Depth 8)
    } else {
        Write-Output $result
    }
    exit 0
}

Write-Error '错误：接口返回内容为空。'
exit 1
