# CLAUDE.md - Claude Code 接入配置

> 本文件让 Claude Code 在本项目中自动使用视觉桥识别图片。
> 作者：陈启粤 · 2026-08-08

## 你（Claude Code）需要知道的核心规则

**底层模型是纯文本（如 DeepSeek），无法直接"看"图片。** 用户给图片时，你拿到的是文件路径而非像素。**不要假装能看图**，也不要猜测图片内容。必须调用视觉桥脚本把图片转成文字，再基于文字回答。

## 图片识别规则（每次遇到图片都执行）

当用户要求识别/分析图片、或提到某张图片路径时：

1. 确认文件存在：`Test-Path -LiteralPath "<图片路径>"`
2. 运行视觉桥脚本（**必须用完整命令**）：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "D:\claudecode图片识别方法\recognize.ps1" -ImagePath "<图片路径>" -Channel glm-thinking
   ```

   - 简单描述可换 `-Channel glm`（免费、快）
   - 加 `-Json` 可拿标准 JSON（字段：task_type / tool_used / confidence / result）
   - **只看 `result` 字段**做分析
3. 用识别出的文字回答用户。汇报时附带一句识别来源（`tool_used`），例如"已通过 GLM-4.1V-Thinking 识别"。

## 常见图片位置

- 监视器自动保存的图：`D:\claudecode图片识别方法\received\`（最新一张可用：按时间倒序取第一个）
- 用户拖拽/指定的任意路径

## 故障处理

- 脚本报错 `GLM_API_KEY not set` → 让用户跑 `setup.bat` 配置 Key
- 脚本退出码 2（认证失败）→ Key 错误或过期
- 脚本退出码 4（网络）→ 让用户检查网络/防火墙
- 视觉 API 全失败 → 用离线 OCR 兜底：
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File "D:\claudecode图片识别方法\windows-ocr.ps1" -ImagePath "<图片路径>"
  ```
- 全部失败 → 明确告诉用户失败原因，请其描述图片内容

## 工具链概览

| 脚本 | 用途 |
|---|---|
| `recognize.ps1` | 视觉识别（调 GLM API），主通道 |
| `windows-ocr.ps1` | 离线 OCR 兜底（断网/无 Key 时） |
| `setup.ps1` / `setup.bat` | 配置 API Key |
| `ClipboardImageWatcher.ps1` | 剪贴板/临时目录图片监视器（后台） |
