# AGENTS.md - OpenCode 接入配置

> 本文件让 OpenCode 在本项目中自动使用视觉桥识别图片。
> 作者：陈启粤 · 2026-08-09 · v4.1
> 说明：本文件所有路径均为**相对本项目根目录**，项目放在任何位置都能用，无需改路径。

## 核心规则

**底层模型是纯文本（如 DeepSeek），无法直接"看"图片。** 用户给图片时，你拿到的是文件路径而非像素。**不要假装能看图**，也不要猜测图片内容。必须调用视觉桥脚本把图片转成文字，再基于文字回答。

## 图片识别规则（每次遇到图片都执行）

当用户要求识别/分析图片、或提到某张图片路径时：

1. 确认脚本存在：项目根目录下有 `recognize.ps1`
2. 确认文件存在：`Test-Path -LiteralPath "<图片路径>"`
3. 运行视觉桥脚本（脚本就在本项目根目录，用相对路径即可）：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File ".\recognize.ps1" -ImagePath "<图片路径>"
   ```

   - 模型 / 服务商由项目根目录的 `.env` 决定
   - 加 `-Json` 可拿标准 JSON（字段：task_type / tool_used / confidence / result）
   - **只看 `result` 字段**做分析
   - 临时换模型：加 `-Model <模型>`；临时换服务商：加 `-Provider <id>` `-BaseUrl <url>`
4. 用识别出的文字回答用户。汇报时附带一句识别来源（`tool_used`）。

## 常见图片位置

- 监视器自动保存的图：本项目根目录的 `received\` 文件夹（最新一张按时间倒序取第一个）
- 用户拖拽/指定的任意路径

## 配置与多模型

- 配置在项目根目录 `.env`：`VISION_PROVIDER`（glm/dashscope/openai/moonshot/siliconflow/ollama/custom）、`VISION_API_KEY`、`VISION_MODEL`、`VISION_BASE_URL`
- 用户改配置只需双击 `setup.bat`（交互式中文向导）
- 只看到旧版 `GLM_API_KEY` 环境变量时自动按 glm 处理，向后兼容

## 故障处理

- 脚本报错 `未配置有效的 VISION_PROVIDER` / `未配置 API Key` → 让用户跑 `setup.bat` 配置
- 退出码 2（认证失败）→ key 错误或过期
- 退出码 3（限流）→ 稍后重试或换免费模型
- 退出码 4（网络）→ 检查网络/防火墙；Ollama 确认服务已启动
- 视觉 API 全失败 → 离线 OCR 兜底：
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\windows-ocr.ps1" -ImagePath "<图片路径>"
  ```
- 全部失败 → 明确告诉用户失败原因，请其描述图片内容

## 工具链概览

| 脚本 | 用途 |
|---|---|
| `setup.bat` / `setup.ps1` | 交互式配置向导（选模型、填 key、生成 .env、测连通） |
| `recognize.ps1` | 视觉识别（调任意 OpenAI 兼容视觉 API），主通道 |
| `providers.ps1` | 服务商注册表（内置 7 家，可扩展） |
| `windows-ocr.ps1` | 离线 OCR 兜底（断网/无 Key 时） |
| `ClipboardImageWatcher.ps1` | 剪贴板/临时目录图片监视器（后台） |
