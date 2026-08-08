# providers.ps1 - 视觉模型服务商注册表（共用配置）
# =============================================================
# 供 setup.ps1（配置向导）和 recognize.ps1（识别）共同使用。
# 所有服务商都提供 OpenAI 兼容的 /chat/completions 接口。
#
# .env 中的字段：
#   VISION_PROVIDER  = 下列 id 之一（glm, dashscope, openai, ...）
#   VISION_API_KEY   = 对应服务商的 API Key
#   VISION_MODEL     = 使用的模型（可选，默认取 Models[0]）
#   VISION_BASE_URL  = 接口地址（仅 provider=custom 时必填）
#
# 向后兼容：.env 里的 GLM_API_KEY 等价于 provider=glm。
# =============================================================

$VisionProviders = [ordered]@{
    glm = @{
        Name     = '智谱 GLM（免费额度，推荐）'
        BaseUrl  = 'https://open.bigmodel.cn/api/paas/v4'
        Models   = @('glm-4.1v-thinking-flash', 'glm-4v-flash', 'glm-4v-plus')
        NeedsKey = $true
    }
    dashscope = @{
        Name     = '阿里通义千问（DashScope，有免费额度）'
        BaseUrl  = 'https://dashscope.aliyuncs.com/compatible-mode/v1'
        Models   = @('qwen-vl-max', 'qwen-vl-plus', 'qwen2.5-vl-72b-instruct', 'qwen2.5-vl-32b-instruct', 'qwen-vl-ocr')
        NeedsKey = $true
    }
    openai = @{
        Name     = 'OpenAI GPT-4o（付费）'
        BaseUrl  = 'https://api.openai.com/v1'
        Models   = @('gpt-4o', 'gpt-4o-mini', 'gpt-4.1-mini', 'gpt-4.1-nano')
        NeedsKey = $true
    }
    moonshot = @{
        Name     = 'Moonshot Kimi（Kimi AI）'
        BaseUrl  = 'https://api.moonshot.cn/v1'
        Models   = @('kimi-latest', 'moonshot-v1-8k-vision-preview')
        NeedsKey = $true
    }
    siliconflow = @{
        Name     = 'SiliconFlow 硅基流动（有免费视觉模型）'
        BaseUrl  = 'https://api.siliconflow.cn/v1'
        Models   = @('Qwen/Qwen2.5-VL-72B-Instruct', 'Qwen/Qwen2.5-VL-7B-Instruct', 'deepseek-ai/deepseek-vl2')
        NeedsKey = $true
    }
    ollama = @{
        Name     = 'Ollama（本地免费，可离线）'
        BaseUrl  = 'http://localhost:11434/v1'
        Models   = @('llava', 'qwen2.5vl', 'llama3.2-vision', 'qwen2-vl')
        NeedsKey = $false
    }
    custom = @{
        Name     = '自定义（任意 OpenAI 兼容接口）'
        BaseUrl  = ''
        Models   = @()
        NeedsKey = $true
    }
}
