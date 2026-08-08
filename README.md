# 📷 视觉桥（Vision Bridge）

> **给纯文本 AI 装一只"眼睛"——让它也能看懂你的截图**
>
> 作者：陈启粤 · 最后更新：2026-08-09 · 版本：v4.1

---

## 📖 目录

1. [这是什么？为什么需要它？](#1-这是什么为什么需要它)
2. [它是怎么工作的？](#2-它是怎么工作的)
3. [我适合用吗？](#3-我适合用吗)
4. [快速开始（新手必看，4 步）](#4-快速开始新手必看4-步)
5. [怎么让 AI 用上它（关键）](#5-怎么让-ai-用上它关键)
6. [怎么选服务商和模型（含详细推荐）](#6-怎么选服务商和模型含详细推荐)
7. [怎么获取各家的 API Key](#7-怎么获取各家的-api-key)
8. [日常使用指南](#8-日常使用指南)
9. [常见问题排查（遇到问题先看这里）](#9-常见问题排查遇到问题先看这里)
10. [进阶：命令行手动使用](#10-进阶命令行手动使用)
11. [隐私与安全](#11-隐私与安全)
12. [卸载与重置](#12-卸载与重置)
13. [给开发者的说明](#13-给开发者的说明)
14. [更新日志](#14-更新日志)

---

## 1. 这是什么？为什么需要它？

### 你遇到过这种情况吗？

你在 **Claude Code、Codex、OpenCode** 或者**桌面版 AI** 里，接的是**纯文本模型**（比如 DeepSeek、Llama），然后你往对话框里**粘贴一张图片**，期待 AI 告诉你图片里是什么。

结果它回你：

```
[Unsupported Image]
```

或者：

> 抱歉，我无法查看图片。

**AI 完全看不到你的图。**

### 为什么 AI 看不到图？

因为**纯文本模型天生没有"眼睛"**。它们只能处理文字，图片在它们眼里就是一堆没意义的数据。

- ✅ 多模态模型（官方 Claude、GPT-4o、Gemini、GLM-4V 直连）——原生就能看图
- ❌ 纯文本模型（DeepSeek 全系、Llama 等）——不接收图片

很多 AI 工具（Claude Code 等）**本身是支持图片的**，但如果你通过 ccswitch 之类的工具把模型**路由到了 DeepSeek**，DeepSeek 接口不认图片，图就被拒了。

> 这不是工具坏了，是模型通道不支持图片。

### 这个工具怎么解决？

**给纯文本模型装一只"眼睛"。**

它把图片**自动翻译成文字**，再把文字交给 AI——AI 用文字就能"看"图了。

**无需安装 Python / Node / 任何依赖，Windows 10/11 开箱即用。**

### 一句话总结

> **"Windows + 纯文本模型 + 能执行本地脚本的 AI 工具" → 这个工具就是为你做的。**

---

## 2. 它是怎么工作的？

打个比方：**让一个看不见的人"看图"，最好的办法是请旁边的朋友描述给他听。**

```
你截图 / 复制图片
        │
        ▼
监视器（start-watcher）自动把图存到 received/ 文件夹
        │
        ▼
识别脚本（recognize.ps1）调用视觉模型（如智谱 GLM）
        │
        ▼
视觉模型把图片"翻译"成文字
        │
        ▼
你的 AI 用这些文字回答你
```

整个过程**你只管截图、提问**，其他全部自动完成。

### 为什么要用"监视器"存图？

纯文本 AI 收不到图片，但图片在磁盘上留下了痕迹：

1. **粘贴图片到聊天框** → 图被存成临时文件（如 `%TEMP%\xxx-clipboard-xxx.png`）
2. **截图 / 复制图片** → 图进了 Windows 剪贴板

监视器就盯着这两处，一旦发现图片就保存到 `received/` 文件夹，AI 就能读到文件路径、调用识别。

---

## 3. 我适合用吗？

### ✅ 适合用

| 场景 | 说明 |
|---|---|
| Windows + Claude Code / Codex / OpenCode + 纯文本模型 | **核心场景，实测可用** |
| Windows + 桌面版 AI App + 纯文本模型 | 可用，配 `.env` 即可 |
| Windows + 任何 AI 工具，只想手动识别单张图 | 可用，拖图到 `recognize.bat` |
| 断网 / 无 Key，只想提取图片里的文字 | 可用，`windows-ocr.ps1` 离线 OCR |

### ❌ 不需要 / 不能用

| 场景 | 原因 |
|---|---|
| 官方 Claude / GPT-4o / Gemini / GLM-4V 直连 | 模型原生就能看图，**装了反而多余** |
| Mac / Linux | 脚本依赖 Windows 剪贴板 API 和 Windows OCR 引擎，**无法运行** |
| 纯网页版 AI（浏览器里聊天） | 无法执行本地脚本、无法访问本地文件 |
| 没有智谱 / 其它平台 API Key | 识别必须调用云端视觉 API（有免费额度） |

---

## 4. 快速开始（新手必看，4 步）

### 第 1 步：把文件夹放到电脑上

把整个文件夹复制/解压到任意位置，比如：

```
D:\vision-bridge\
```

> **放哪里都行，不用改任何路径。** 工具已经做成了"放哪都能用"（所有脚本都用相对路径定位自己）。

---

### 第 2 步：配置 API Key（只做一次）

双击文件夹里的 **`setup.bat`**。

会弹出一个**全中文**的配置窗口，你跟着做：

```
======== 视觉桥 - 多模型配置向导 ========
当前配置：（如果是第一次，会显示"尚未配置"）

请选择视觉模型服务商：
  1. 智谱 GLM（免费额度，推荐）
  2. 阿里通义千问（DashScope，有免费额度）
  3. OpenAI GPT-4o（付费）
  4. Moonshot Kimi（Kimi AI）
  5. SiliconFlow 硅基流动（有免费视觉模型）
  6. Ollama（本地免费，可离线）
  7. 自定义（任意 OpenAI 兼容接口）

请输入编号（1-7，回车默认 1）：
```

**新手建议：输入 `1` 回车**（智谱 GLM，免费额度最多）。

接着：

```
请选择模型：
  1. glm-4.1v-thinking-flash
  2. glm-4v-flash（免费）
  3. glm-4v-plus

请输入编号（1-3，回车默认 1）：
```

**新手建议：输入 `1` 回车**（`glm-4.1v-thinking-flash`，识别质量好）。
> 如果经常遇到限流（429），可以改成 `2`（`glm-4v-flash`，免费、快、几乎不限流）。

接着：

```
请输入 API Key：
```

**粘贴你的智谱 API Key**（形如 `xxxxxxxx.xxxxxxxx`），回车。

> 没有 Key？看 [第 7 节](#7-怎么获取各家的-api-key) 怎么免费申请。

最后它会：

```
已保存到 .env
正在测试接口连通性（可能需要几秒钟）...
  结果：连接正常 ✓
配置完成！接下来：双击 start-watcher.bat 启动监视器...
```

**看到「连接正常 ✓」就说明配置成功了。**

> ⚠️ **如果看到的是 `结果：FAIL(...)`**，别慌——这只是一个轻量检测，可能因为模型暂时限流或网络问题。先继续往下走，如果识别时真的报错再看 [第 9 节](#9-常见问题排查遇到问题先看这里)。

---

### 第 3 步：启动监视器（日常抓图）

双击 **`start-watcher.bat`**。

会弹出一个蓝色窗口：

```
==============================================
  剪贴板/临时目录 图片监视器 已启动
==============================================
保存目录: D:\vision-bridge\received
视觉桥已配置（.env: True）
现在可以截图 / 复制 / 粘贴图片了。
看到"已保存"后，让 AI 识别图片即可。
按 Ctrl+C 停止。
```

**这个窗口要一直开着**（可以最小化到任务栏）。它负责：
- 监听你的**剪贴板**（截图、复制图片都会进剪贴板）
- 监听系统**临时目录**（把图片粘贴进聊天框时生成的临时文件）
- 把发现的图片存到 `received/` 文件夹

> **窗口没显示"视觉桥已配置"而是黄色警告？** 说明 `.env` 没配置成功，回 [第 2 步](#第-2-步配置-api-key只做一次) 重新跑 `setup.bat`。

---

### 第 4 步：截图并让 AI 识别

**1. 截图 / 复制图片**（任选一种）：

| 方式 | 操作 |
|---|---|
| 屏幕截图 | 按 `Win + Shift + S`，框选要截的区域 |
| 复制网页图片 | 右键图片 → 「复制图片」 |
| 微信/QQ 截图 | 默认会进剪贴板 |
| 复制文件图片 | 在文件管理器复制一张图片 |

**2. 确认监视器抓到了**：监视器窗口会显示

```
[21:30:05] 已保存: img_clip_20260809_213005.png
```

看到"已保存"就说明图片进 `received/` 了。

**3. 让 AI 识别**：回到 AI 对话框，说：

> **「识别一下这张图」** 或 **「分析 received 文件夹里最新的图片」**

AI 就会自动识别并告诉你图片内容。

---

## 5. 怎么让 AI 用上它（关键）

**AI 软件不会自己找到这个文件夹，需要你"带它进去"。** 具体看你用哪种：

### 方式 A：终端版（Claude Code / Codex / OpenCode）

打开命令行，**先进入这个文件夹，再启动 AI**：

```bash
cd D:\vision-bridge     # 进入项目文件夹
claude                   # 或 codex / opencode
```

进去之后，AI 会自动读取文件夹里的 **`CLAUDE.md`**（Claude Code）或 **`AGENTS.md`**（Codex/OpenCode），**自动学会"图片要走识别脚本"**——你什么都不用教。

> 有些工具也支持 `/add-dir` 命令直接授权文件夹，效果一样。

**为什么这样就行？** 因为这些规则文件（`CLAUDE.md` / `AGENTS.md`）是 AI 每次打开项目**自动加载**的"说明书"。它不需要记住任何历史，每次重新读到规则，就会用。

### 方式 B：桌面版 AI

在 AI 工具里**手动打开/授权这个文件夹**（通常叫"打开文件夹"或"添加目录"），让它能访问到项目文件，包括 `.env` 和 `received/`。

> **桌面版和终端版的区别**：桌面版 AI 跑在隔离沙箱里，读不到 Windows 环境变量，但**能读项目文件夹里的 `.env`**——所以 v4.0 起配置统一写在 `.env` 文件，**两种版本都能用**。

---

## 6. 怎么选服务商和模型（含详细推荐）

### 服务商总览

| ID | 服务商 | 特点 | 费用 |
|---|---|---|---|
| `glm` | **智谱 GLM** | 国内直连快，有免费模型，新手首选 | 免费额度 + 低价 |
| `dashscope` | **阿里通义千问** | 阿里云生态，模型质量高 | 免费额度 |
| `openai` | **OpenAI GPT-4o** | 国际最强，但国内访问需要梯子 | 付费 |
| `moonshot` | **Kimi** | 国内可用 | 付费 |
| `siliconflow` | **SiliconFlow 硅基流动** | 聚合多家开源模型，有免费视觉模型 | 免费 + 付费 |
| `ollama` | **Ollama** | 本地运行，完全离线，隐私最好 | 完全免费 |
| `custom` | **自定义** | 任意 OpenAI 兼容接口 | 看情况 |

### 模型推荐（按场景）

**你是新手 / 只是想日常识别**：
- 推荐 `智谱 GLM` + `glm-4v-flash`（**免费**、快、几乎不限流）
- 或者 `SiliconFlow` + `Qwen/Qwen2.5-VL-7B-Instruct`（免费）

**你经常识别图表、代码截图、数学题**：
- 推荐 `glm-4.1v-thinking-flash`（思考能力强）
- 或 `qwen-vl-max`（通义旗舰）

**你追求最高质量**：
- `GPT-4o` / `qwen2.5-vl-72b-instruct` / `glm-4v-plus`

**你特别在意隐私 / 完全离线**：
- `Ollama` + `llava` 或 `qwen2.5vl`（全本地，不联网）

### 各模型完整列表

| 服务商 | 可选模型 | 说明 |
|---|---|---|
| 智谱 GLM | `glm-4.1v-thinking-flash` | 推荐，思考型，识别质量好 |
| | `glm-4v-flash` | 免费，快，日常够用 |
| | `glm-4v-plus` | 高质量 |
| 通义千问 | `qwen-vl-max` | 旗舰，质量高 |
| | `qwen-vl-plus` | 均衡 |
| | `qwen2.5-vl-72b-instruct` | 大模型，质量高 |
| | `qwen2.5-vl-32b-instruct` | 性价比 |
| | `qwen-vl-ocr` | 专攻文字识别 |
| OpenAI | `gpt-4o` | 旗舰 |
| | `gpt-4o-mini` | 轻量 |
| | `gpt-4.1-mini` / `gpt-4.1-nano` | 新一代轻量 |
| Kimi | `kimi-latest` | 最新 |
| | `moonshot-v1-8k-vision-preview` | 视觉预览版 |
| SiliconFlow | `Qwen/Qwen2.5-VL-72B-Instruct` | 免费 |
| | `Qwen/Qwen2.5-VL-7B-Instruct` | 免费轻量 |
| | `deepseek-ai/deepseek-vl2` | 开源视觉 |
| Ollama | `llava` | 经典开源视觉 |
| | `qwen2.5vl` | 通义开源 |
| | `llama3.2-vision` | Meta 开源 |
| | `qwen2-vl` | 通义开源 |

### 怎么切换服务商/模型？

**重新双击 `setup.bat`，选一家新的，自动覆盖配置。** 不用删任何东西。

### 省钱建议

- 日常：免费模型（`glm-4v-flash` / SiliconFlow 免费）
- 复杂任务：才用收费模型
- 大量使用：对比各家的免费额度，够用就行

---

## 7. 怎么获取各家的 API Key

### 智谱 GLM（新手推荐，有免费额度）

1. 打开 [智谱开放平台](https://open.bigmodel.cn/)，手机号注册
2. 登录后，左侧菜单 →「**API Keys**」→「**创建 API Key**」
3. 复制生成的一串字符（形如 `xxxxxxxx.xxxxxxxx`）
4. 双击 `setup.bat` 粘贴进去

### 阿里通义千问

1. 打开 [阿里云百炼](https://bailian.console.aliyun.com/)，注册/登录
2. 开通百炼服务，创建 API-KEY
3. 形如 `sk-xxxxxxxx`

### OpenAI

1. 打开 [OpenAI Platform](https://platform.openai.com/)，注册（需要国外支付方式）
2. API Keys → 创建
3. 形如 `sk-xxxxxxxx`

### Kimi（Moonshot）

1. 打开 [Moonshot 开放平台](https://platform.moonshot.cn/)，注册
2. API Keys → 创建

### SiliconFlow 硅基流动

1. 打开 [SiliconFlow 控制台](https://cloud.siliconflow.cn/)，注册
2. API Keys → 创建（有免费额度）

### Ollama（完全本地，不需要 Key）

1. 下载安装 [Ollama](https://ollama.com/)
2. 拉取一个视觉模型：命令行运行 `ollama pull llava`
3. `setup.bat` 选 Ollama，模型填 `llava`，**不用填 Key**

> ⚠️ **Key 安全提醒**：Key 相当于账号密码。
> - **不要**发到网上、不要提交 GitHub
> - **不要**在截图里露出 Key
> - 泄露了 → 去对应平台「作废」重建一个

---

## 8. 日常使用指南

### 每次怎么用？

1. 确保 `start-watcher.bat` 监视器开着（第一次要双击启动，之后保持开着即可）
2. 截图 / 复制图片
3. 监视器显示"已保存"
4. 对 AI 说「识别图片」

### 每天最顺手的组合

- 开机后双击一次 `start-watcher.bat`，最小化到任务栏
- 一整天想识别什么图，截图后直接问 AI

### 关于 `received/` 文件夹

- 你的所有截图都会存在这里
- **会越来越多**，建议定期清理没用的（直接删文件即可）
- 它是 `.gitignore` 排除的，**不会上传到 GitHub**

### 关于 `.env` 文件

- 你的配置存在这里（服务商、模型、Key）
- **不要删、不要手动编辑**（想改就双击 `setup.bat`）
- **不要上传 GitHub / 发给别人**
- 删了它 = 回到未配置状态，重新跑 `setup.bat` 即可

---

## 9. 常见问题排查（遇到问题先看这里）

### 按现象查

| 现象 | 原因 | 解决 |
|---|---|---|
| 识别报「未配置有效的 VISION_PROVIDER」 | 没跑 `setup.bat` | 双击 `setup.bat` 配置 |
| 识别报「未配置 API Key」 | `.env` 里没 Key | 同上 |
| 监视器窗口黄色警告「尚未配置 API Key」 | 同上 | 同上 |
| 截图后监视器没显示「已保存」 | 监视器没开 / 关了 | 重新双击 `start-watcher.bat` |
| 监视器一直不抓图 | 可能是权限或剪贴板被占用 | 重开监视器；确认是截图/复制图片（不是拖文件） |
| AI 说「找不到图片」 | `received/` 里没有图 | 先截图，确认监视器显示「已保存」 |
| AI 说「找不到 recognize.ps1」 | 没带 AI 进这个文件夹 | 见 [第 5 节](#5-怎么让-ai-用上它关键) |
| 识别结果全是乱码 | 可能是模型问题或图太糊 | 换模型 / 重新截高清图 |

### 按错误码查

| 报错 | 含义 | 解决 |
|---|---|---|
| 退出码 0 | 成功 | 无需处理 |
| 退出码 1 | 通用错误（如找不到图片、图片太大） | 看具体提示；图片 >15MB 先压缩 |
| 退出码 2 | 缺 Key / 认证失败 | 重新跑 `setup.bat` 填 Key；或去平台检查 Key 是否有效 |
| 退出码 3 | 请求过于频繁（429） | 稍等重试，或换个模型（如免费的 `glm-4v-flash`） |
| 退出码 4 | 网络/服务器错误 | 检查网络；Ollama 用户确认 Ollama 已启动 |
| 退出码 5 | 请求被拒绝 | 检查模型名是否写对、接口地址是否正确 |

### 具体问题

**Q：双击 `.bat` 闪退 / 没反应？**
用 `.bat` 启动器（不要直接双击 `.ps1`）。`.bat` 会绕过执行策略、出错时停住显示错误。如果还闪退，手动跑：
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\vision-bridge\setup.ps1" -Status
```

**Q：`setup.bat` 窗口一闪而过，配置没保存？**
可能被安全软件拦截，或系统策略限制。右键 `.bat` →「以管理员身份运行」；或按上面命令手动跑 `setup.ps1`。

**Q：双击 `setup.bat` 后全是乱码 / 英文？**
说明系统代码页不是 UTF-8。`.bat` 已内置 `chcp 65001` 切到 UTF-8，如果还乱码，右键命令行窗口 → 属性 → 字体改为「中文字体」；或确认系统区域设置。

**Q：识别结果不准 / 太慢？**
- 换更强的模型：重新双击 `setup.bat`
- 简单图用免费模型（`glm-4v-flash`）更快
- 图片太大（>15MB）先压缩再识别
- 图太模糊就重新截高清图

**Q：`received/` 越积越多占空间？**
定期清理即可（都是你自己截的图）。

**Q：换电脑 / 分享给朋友？**
1. 拷贝整个文件夹（**最好删掉自己的 `.env`**）
2. 朋友跑一次 `setup.bat`，填**他自己的** Key
3. AI 助手要能访问项目文件夹

**Q：想换一家模型服务商？**
双击 `setup.bat`，重新选一家，自动覆盖 `.env`。

**Q：Ollama 怎么用？**
1. 安装并启动 Ollama
2. `ollama pull llava`
3. 跑 `setup.bat` 选 Ollama，模型填 `llava`，不用填 Key

**Q：报错 429（请求过于频繁）？**
模型访问量过大。稍等重试，或换免费模型（`glm-4v-flash` 几乎不限流）。

**Q：报错 401/403（认证失败）？**
Key 错误或过期。重新跑 `setup.bat`，或去平台作废重建 Key。

**Q：我不想用云 API，能完全离线吗？**
提取文字：`windows-ocr.ps1`（离线 OCR，不联网）。
理解图片（描述/图表）：用 **Ollama**（完全本地免费）。

**Q：`CLAUDE.md` / `AGENTS.md` 里的路径要改吗？**
**不用改。** 都是相对路径（`.\recognize.ps1`），项目放任何位置都能用。

**Q：桌面版 AI 说「读不到 Key / 没配置」？**
1. 确认运行过 `setup.bat`（生成了 `.env`）
2. 确认 `.env` 在项目根目录
3. 确认 AI 有权访问项目文件夹（桌面版要授权目录）

**Q：识别时用哪个模型？是不是每次都要选？**
不用。模型记在 `.env` 里，每次自动用。换模型就重新跑 `setup.bat`。

**Q：多个 AI 工具能同时用吗？**
能。`.env` 在项目里，谁访问项目都能用。前提是各工具都有权访问文件夹。

**Q：GitHub 上有别人下载了我的项目，他会看到我的 Key 吗？**
**不会。** 你的 `.env` 已被 `.gitignore` 排除，不会上传。别人拿到项目也没有你的 Key，需要自己配置。

**Q：`setup.bat` 一定要双击吗？能不能命令行跑？**
可以。命令行进到项目目录：
```powershell
.\setup.bat           # 配置向导
.\setup.bat -status   # 查看配置 + 测试
.\setup.bat -remove   # 删除配置
```

---

## 10. 进阶：命令行手动使用

### recognize.ps1 手动调用

```powershell
# 识别 received/ 里最新一张（用 .env 配置的模型）
powershell -NoProfile -ExecutionPolicy Bypass -File recognize.ps1

# 识别指定图片
powershell -NoProfile -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath "C:\你的图片.png"

# 指定问题（默认是"描述这张图"）
powershell -NoProfile -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath "C:\a.png" -Prompt "这张图里的文字是什么？"

# 临时换模型（不改配置）
powershell -NoProfile -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath "C:\a.png" -Model "glm-4v-flash"

# 输出标准 JSON（给程序用）
powershell -NoProfile -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath "C:\a.png" -Json
```

### recognize.ps1 参数说明

| 参数 | 说明 |
|---|---|
| `-ImagePath`（可选） | 图片路径；**不传则自动找 `received/` 里最新一张** |
| `-Prompt` | 提问/指令，默认"描述这张图" |
| `-Provider` | 临时换服务商（glm/dashscope/...） |
| `-Model` | 临时换模型 |
| `-BaseUrl` | 临时换接口地址 |
| `-Json` | 输出标准 JSON |

### 离线 OCR（不联网提取文字）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File windows-ocr.ps1 -ImagePath "C:\a.png"
```

支持 png/jpg/jpeg/bmp/tif/tiff/gif/webp，中文优先、英文兜底。

### 拖拽识别

直接把图片**拖到 `recognize.bat`** 上，松手就会自动识别。

---

## 11. 隐私与安全

### 图片去了哪里？

- 云端服务（智谱/通义/OpenAI 等）：图片会**发送到对应服务商服务器**识别——和任何在线 OCR、识图工具一样
- 本地 Ollama：图片**不出你电脑**，完全本地

### 你应该知道

- **涉及隐私的图片别用云端识别**（身份证、密码、聊天记录等），或先打码
- 你的图片**只存在本地 `received/`**，识别结果仅用于当次对话
- 你的 API Key 在 `.env` 里，**不会上传 GitHub**（`.gitignore` 已排除）
- 识别脚本**不收集任何数据**，纯本地调用云端 API

### 想完全隐私？

用 **Ollama** 服务商 + 本地模型，图片不离开你的电脑。

---

## 12. 卸载与重置

### 重置配置（回到未配置状态）

```powershell
.\setup.bat -remove
```

或直接删掉项目里的 `.env` 文件。

### 完整卸载

直接删除整个文件夹即可（`received/` 里的截图想留就先拷走）。

### 换 Key 怎么弄？

1. 去对应平台「作废」旧 Key
2. 重新创建新 Key
3. 双击 `setup.bat`，填新 Key（自动覆盖）

---

## 13. 给开发者的说明

### 项目结构

| 文件 | 作用 |
|---|---|
| `setup.bat` | 配置向导入口（双击运行） |
| `setup.ps1` | 配置向导核心（交互式，生成 `.env`） |
| `start-watcher.bat` | 监视器入口（双击运行） |
| `ClipboardImageWatcher.ps1` | 剪贴板 + 临时目录监听，存图到 `received/` |
| `recognize.bat` | 识别入口（双击 / 拖图） |
| `recognize.ps1` | 视觉识别核心（调任意 OpenAI 兼容 API） |
| `providers.ps1` | 服务商注册表（内置 7 家，可扩展） |
| `windows-ocr.ps1` | 离线 OCR 兜底 |
| `CLAUDE.md` | Claude Code 自动接入规则 |
| `AGENTS.md` | Codex / OpenCode 自动接入规则 |
| `.gitignore` | 排除 `.env`、`received/` |
| `.env` | 本地配置（运行时生成） |

### 扩展服务商

编辑 `providers.ps1`，按已有格式加一个条目即可：

```powershell
myprovider = @{
    Name     = '我的服务商'
    BaseUrl  = 'https://api.example.com/v1'
    Models   = @('my-vision-model')
    NeedsKey = $true
}
```

所有服务商必须提供 **OpenAI 兼容** 的 `/chat/completions` 接口。

### 配置说明（.env）

```
VISION_PROVIDER=glm
VISION_API_KEY=你的key
VISION_MODEL=glm-4.1v-thinking-flash
VISION_BASE_URL=https://open.bigmodel.cn/api/paas/v4
```

- `GLM_API_KEY` 是使用智谱时的向后兼容别名
- 优先级：命令行参数 > `.env` > 环境变量 > 默认值

### 编码规范（重要）

- `.ps1` 含中文 → **必须 UTF-8 带 BOM**（否则 PowerShell 5.1 中文乱码/闪退）
- `.bat` → **必须纯 ASCII**（cmd 用系统代码页解析，中文会乱码报错），中文 UI 全放 `.ps1`
- 修改 `.ps1` 后注意保持 BOM

---

## 14. 更新日志

- **v4.1 (2026-08-09)**：全面审查修复；`recognize.ps1` 不传图片自动找最新；`CLAUDE.md`/`AGENTS.md` 路径无关（放哪都能用）
- **v4.0 (2026-08-09)**：支持 7 家服务商；中文配置向导；`.env` 打通桌面版 AI；界面全部中文化
- **v3.1 (2026-08-08)**：新增使用范围说明、各编程工具接入指令
- **v3 (2026-08-08)**：开源重构，去写死路径、新增识别/离线 OCR/配置脚本
- **v2 (2026-08-08)**：源码改纯 ASCII 防 PS5.1 乱码；新增临时目录监听
- **v1 (2026-08-08)**：初版，仅监听剪贴板图片

---

## 开源许可

MIT License —— 自由使用、修改、分发。详见 `LICENSE` 文件。

---

*本方案由陈启粤整理并开源，2026-08-09 最后更新。*
