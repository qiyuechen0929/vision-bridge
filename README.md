# 📷 Claude Code 图片识别桥（Vision Bridge for Text-Only Models）

> 给"纯文本模型"（DeepSeek 等）加眼睛 —— 让粘贴图片也能被 AI 看懂
>
> 作者：陈启粤 · 最后更新：2026-08-08 · 版本：v3.1

---

## ✨ 这是什么

一个 **Windows 脚本工具包**，解决一个很实际的问题：

**当你用 Claude Code / Codex 等 AI 工具接上纯文本模型（比如 DeepSeek）时，粘贴图片会被拒绝（`[Unsupported Image]`），AI 完全看不到图。**

这套工具通过 **剪贴板/临时目录监视 + 云端视觉模型** 的方式，把图片"翻译"成文字再交给 AI，让纯文本模型也能"看"图。

**无需安装 Python / Node / 任何依赖，Windows 10/11 开箱即用。**

---

## 🔍 为什么需要这个？（原理）

### 问题根源

图片能不能被 AI 看懂，取决于**模型是否多模态**：

| 模型类型 | 例子 | 能否直接看图 |
|---|---|---|
| 多模态模型 | OpenAI GPT-4o、Anthropic Claude、智谱 GLM-4V、Google Gemini | ✅ 原生支持，粘贴即识别 |
| 纯文本模型 | DeepSeek 全系、Llama 等 | ❌ 接口不接收图片消息 |

Claude Code 本身支持视觉，但如果你用 **ccswitch 把模型路由到了 DeepSeek**，DeepSeek 接口不认图片消息，图片就被拒了。**这不是工具的问题，是模型通道不支持图片。**

### 解决方案

虽然模型收不到图片，但图片在磁盘上留下了痕迹：

1. 粘贴图片到桌面 App → 图被存为**临时文件**（如 `%TEMP%\xxx-clipboard-xxx.png`）
2. 复制/截图图片 → 图进入 **Windows 剪贴板**

所以我们的思路是：

```
你截图/复制/粘贴图片
        │
        ▼
监视器脚本（本工具）── 抓取剪贴板 + 临时目录图片
        │
        ▼
保存到 received/ 文件夹
        │
        ▼
视觉模型 API（GLM-4.1V-Thinking）── 图片转文字
        │
        ▼
纯文本主模型（DeepSeek）── 用文字做推理、分析、回答
```

一句话：**把像素转成文字，绕过纯文本模型的限制。**

---

## 🎯 使用范围（谁适用 / 谁不适用）

### ✅ 适用人群

| 场景 | 是否适用 | 说明 |
|---|---|---|
| Windows + Claude Code / OpenCode / Codex 等**终端 AI 工具** + 纯文本模型（DeepSeek 等） | ✅ **强烈推荐** | 这是本工具的核心场景，实测可用 |
| Windows + 桌面版 AI App + 纯文本模型 | ✅ 可用 | 配 `ClipboardImageWatcher.ps1` 监视剪贴板 |
| Windows + 任何 AI 工具，只想手动识别单张图 | ✅ 可用 | 拖图到 `recognize.bat` 即可 |
| 断网 / 无 Key，只想离线提取图片文字 | ✅ 可用 | `windows-ocr.ps1` 离线 OCR |

### ❌ 不适用 / 不需要

| 场景 | 原因 |
|---|---|
| **Mac / Linux** | 脚本依赖 Windows 剪贴板 API 和 Windows 离线 OCR 引擎，无法运行 |
| **官方多模态模型用户**（官方 Claude、GPT-4o、Gemini、GLM-4V 直连） | 模型原生就能看图，**不需要本工具**，装了反而多余 |
| **纯网页版 AI**（浏览器里聊天，无法执行本地脚本 / 无法访问本地文件） | 脚本在你电脑上，网页 AI 碰不到 |
| 用户没有智谱 API Key | 识别必须调用 GLM 云端 API，需要各自注册（有免费额度） |

### ⚠️ 一句话总结

> **"Windows + 纯文本模型 + 能执行本地脚本的 AI 工具" 用户 → 开箱即用。**
> 其它组合 → 要么不需要，要么需要改造。

---

## 🚀 快速开始（5 步）

### 第 1 步：下载

把整个文件夹放到你电脑上任意位置（比如 `D:\vision-bridge`）。

### 第 2 步：配置 API Key

双击运行 **`setup.bat`**（或右键 `setup.ps1` → 使用 PowerShell 运行），按提示输入你的智谱 API Key。

> 还没有 Key？见下文【如何获取免费 Key】。

### 第 3 步：启动监视器

双击 **`start-watcher.bat`**。

- 弹出一个蓝色窗口，显示 `Clipboard/Temp Image Forwarder started`
- **这个窗口必须保持开着**（可最小化到任务栏），关掉就停止监听

### 第 4 步：截图 / 复制 / 粘贴图片

在任意地方：

- **屏幕截图**：按 `Win + Shift + S` 框选（自动进剪贴板）
- **复制网页图片**：右键图片 → 复制图片
- **微信/QQ 截图**：默认进剪贴板
- **直接粘贴进 AI 对话框**：临时文件会被捕获

脚本窗口会显示 `SAVED: img_clip_xxx.png`，图片已保存到 `received/` 文件夹。

### 第 5 步：让 AI 识别

回到 AI 对话框，说一句：

> 「识别刚才的图」或「分析 received 文件夹里最新的图片」

AI 会读取图片、调用视觉模型识别、给你分析结果。

---

## 🔑 如何获取免费 Key（智谱 GLM）

识别图片用的是**智谱 AI 的视觉模型**。

### 注册 & 创建

1. 打开 [智谱开放平台](https://open.bigmodel.cn/)
2. 手机号注册登录（**新用户送免费体验额度**）
3. 左侧菜单 → **「API Keys」** → **「创建 API Key」**
4. 得到形如 `xxxxxxxx.xxxxxxxx` 的字符串，这就是你的 Key

### 配置 Key

运行 `setup.bat` 按提示输入即可；脚本会把它存为**用户级环境变量 `GLM_API_KEY`**（持久化，重开会话仍有效）。

> ⚠️ **安全提醒**：Key 相当于账号密码，**不要公开**（别传 GitHub / 发给别人）。泄露了就在智谱控制台作废重建。

### 验证

```powershell
# 看 Key 是否已配置
$key = [Environment]::GetEnvironmentVariable('GLM_API_KEY', 'User'); [bool]$key

# 测网络
Test-NetConnection open.bigmodel.cn -Port 443
```

---

## 💰 免费 / 低成本模型推荐

| 模型 ID | 用途 | 费用 | 推荐度 |
|---|---|---|---|
| `glm-4v-flash` | 简单图片描述、日常识别 | **免费** | ⭐⭐⭐ 日常首选 |
| `glm-4.1v-thinking-flash` | 复杂推理、图表、代码截图、多元素交互 | 免费额度 + 低价 | ⭐⭐⭐⭐ 推荐 |
| `glm-4.5v` | 高质量视觉理解 | 付费（有免费额度） | ⭐⭐⭐ 高质量需求 |
| 百度 OCR（`general_basic`） | 纯文字提取、扫描件 | 免费额度（约 1000 次/天） | ⭐⭐ 仅提文字时 |

**省钱建议**：简单任务用 `glm-4v-flash`（免费、快），复杂任务才用 `glm-4.1v-thinking-flash`。

---

## 🤖 怎么接入你的 AI 助手

**核心思路**：你的 AI 是纯文本模型，不能直接看图。所以要让 AI 形成习惯——**遇到图片路径时，先跑 `recognize.ps1` 把图转成文字，再基于文字回答**。

本工具把图片存到 `received/` 文件夹，你可以用**任何方式**让 AI 读这个文件夹。

### ⚡ 一键接入（推荐）：用项目自带的配置文件

本项目已内置接入配置文件，**Claude Code 会自动读 `CLAUDE.md`，OpenCode 会自动读 `AGENTS.md`**。

**做法**：在你的 AI 工具里打开本项目目录（`cd` 进去或 `/add-dir` 授权），它就会自动加载规则，以后你只要给图片路径 / 说"看图"，它就会自动调用视觉桥。

> ⚠️ **注意**：`CLAUDE.md` / `AGENTS.md` 里默认写的是 `D:\claudecode图片识别方法\recognize.ps1`。**如果项目不在这个路径，改一下这两个文件里的路径**再使用。

### 方式 A：让 AI 直接读（全自动，适合桌面版）

在 AI 对话框里告诉它（一次即可，它会记住）：

> 我有一个剪贴板图片监视器，它会把图片保存到 `<完整路径>\received\` 文件夹。以后我说"识别图片"时，你就读取该文件夹里最新的图片文件，然后调用视觉模型识别，再基于识别结果回答我。

**你的 AI 需要能访问 `received/` 文件夹**（在 Claude Code 里可用 `/add-dir` 或授权文件夹，在 Codex 里用 `--sandbox` 或授权）。

### 方式 B：手动拖拽

直接把图片拖到 **`recognize.bat`** 上，它会自动调用视觉模型识别并把结果打印在窗口里。

### 方式 C：命令行调用

```powershell
# 识别最新一张
.\recognize.bat

# 识别指定图片（简单描述，免费）
powershell -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath "D:\a.png" -Channel glm

# 识别指定图片（复杂推理）
powershell -ExecutionPolicy Bypass -File recognize.ps1 -ImagePath "D:\a.png" -Channel glm-thinking -Json
```

### 方式 D：离线 OCR（不联网兜底）

网络 / Key 不可用，只想提取文字：

```powershell
powershell -ExecutionPolicy Bypass -File windows-ocr.ps1 -ImagePath "D:\a.png"
```

---

## 🧩 各编程工具的接入指令（手把手）

下面是每个主流 AI 编程工具的**具体配置方法**。核心命令都是同一句：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\claudecode图片识别方法\recognize.ps1" -ImagePath "<图片路径>" -Channel glm-thinking
```

> 把 `D:\claudecode图片识别方法\` 换成你实际的解压路径。

### Claude Code（终端版）

**方法 1：自动加载（推荐）**

项目已含 `CLAUDE.md`。在项目目录启动 Claude Code 即可自动生效：

```bash
cd D:\claudecode图片识别方法
claude
```

之后直接说：
```
帮我看看这张图 D:\图片\test.png
```

**方法 2：手动告诉它**

在 Claude Code 对话里粘贴这段指令：

> 当我给你图片路径时，你无法直接看图（底层是纯文本模型）。你必须先运行命令：`powershell -NoProfile -ExecutionPolicy Bypass -File "D:\claudecode图片识别方法\recognize.ps1" -ImagePath "<图片路径>" -Channel glm-thinking`，把输出的 result 当作图片内容，再基于它回答我。

### OpenCode（终端版）

**方法 1：自动加载（推荐）**

项目已含 `AGENTS.md`。在项目目录启动 OpenCode 即可自动生效：

```bash
cd D:\claudecode图片识别方法
opencode
```

**方法 2：手动告诉它**

在 OpenCode 里粘贴：

> 我给你图片路径时，先用 `powershell -NoProfile -ExecutionPolicy Bypass -File "D:\claudecode图片识别方法\recognize.ps1" -ImagePath "<图片路径>" -Channel glm-thinking` 把图片转成文字，再用识别结果回答我。

### Codex（终端版）

Codex 支持 `AGENTS.md`，也会自动加载。或在对话里粘贴同样的指令。Codex 需要授权文件访问：`codex --sandbox workspace` 或按提示授权 `received/` 文件夹。

### Cursor / Windsurf（IDE）

1. 打开项目文件夹（打开后会识别到 `CLAUDE.md` / `AGENTS.md`）
2. 或在 `Rules` / `.cursorrules` 里粘贴上面那句核心指令
3. 图片以文件路径方式引用：`分析 D:\图片\test.png 这张图`

### 其它工具（通用）

给 AI 粘贴这句话，让它记住：

> 我运行在 Windows，图片识别需要走视觉桥。当出现图片时：先运行 `powershell -NoProfile -ExecutionPolicy Bypass -File "D:\claudecode图片识别方法\recognize.ps1" -ImagePath "<图片绝对路径>" -Channel glm-thinking`，得到文字后再回答我。不要把图片当像素处理。

---

## 📁 文件说明

| 文件 | 作用 |
|---|---|
| `start-watcher.bat` | 🖱️ 双击启动监视器（推荐入口） |
| `recognize.bat` | 🖱️ 双击 / 拖图识别最新图片 |
| `setup.bat` | 🖱️ 配置 API Key |
| `ClipboardImageWatcher.ps1` | 监视脚本（剪贴板 + 临时目录双路） |
| `recognize.ps1` | 视觉识别脚本（调 GLM API） |
| `windows-ocr.ps1` | 离线 OCR 兜底（Windows 自带引擎） |
| `setup.ps1` | 配置引导脚本 |
| `CLAUDE.md` | 🤖 Claude Code 自动接入配置（遇到图片自动调视觉桥） |
| `AGENTS.md` | 🤖 OpenCode / Codex 自动接入配置 |
| `received/` | 图片落盘目录（自动创建） |
| `README.md` | 本文档 |

---

## 🔧 脚本命令参考

### ClipboardImageWatcher.ps1

监视剪贴板 + 临时目录，图片存到 `received/`。去重（同一图不重复保存）。

```powershell
powershell -ExecutionPolicy Bypass -File ClipboardImageWatcher.ps1
```

### recognize.ps1

调用智谱视觉模型识别图片。

| 参数 | 说明 |
|---|---|
| `-ImagePath`（必填） | 图片路径 |
| `-Prompt` | 提问/指令，默认"描述这张图" |
| `-Channel` | `glm`（免费/简单）或 `glm-thinking`（复杂/推荐） |
| `-Json` | 输出标准 JSON |

退出码：`0` 成功 · `1` 通用错误 · `2` 缺 Key/认证失败 · `3` 限流 · `4` 网络 · `5` 请求被拒。

### windows-ocr.ps1

离线 OCR。支持 png/jpg/jpeg/bmp/tif/tiff/gif/webp。中文优先，英文兜底。

### setup.ps1

| 参数 | 说明 |
|---|---|
| `-SetKey <key>` | 保存 API Key |
| `-RemoveKey` | 删除 Key |
| `-Status` | 查看状态 + 测网络 |

---

## 🛠 故障排查（FAQ）

### Q1：脚本闪退 / 双击没反应？

用 `.bat` 启动器而不是直接双击 `.ps1`。`.bat` 会自动绕过执行策略、出错时窗口会停住显示错误。如果还闪退，手动跑：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\vision-bridge\ClipboardImageWatcher.ps1"
```

### Q2：保存的图片在哪个文件夹？

`received/`，脚本启动时自动创建。

### Q3：识别结果不准 / 太慢？

- 简单图用 `-Channel glm`（免费、快）
- 复杂图（图表/数学/代码截图）用 `-Channel glm-thinking`
- 图片太大（>15MB）先压缩再识别

### Q4：`received/` 越积越多占空间？

定期清理 `received/` 文件夹即可。

### Q5：换电脑 / 分享给朋友怎么配？

1. `received/` 是脚本同级目录，自动适配，**无需改路径**
2. 朋友需要有**自己的**智谱 API Key（跑一次 `setup.bat`）
3. AI 助手要能访问 `received/` 文件夹

### Q6：为什么官方 Claude 用户不需要这个？

官方 Claude 是多模态模型，粘贴图片原生就能看，不需要绕路。**本工具只对纯文本模型（DeepSeek 等）用户有意义。**

### Q7：和 Codex 的 `ds-vision-skill` 什么关系？

同思路的两套实现。Codex 那套更完整（带缓存、多通道降级、百度 OCR、本地大模型），本工具是精简版，原理一致：**图片 → 外部视觉 API → 文字 → 主模型推理**。

### Q8：我的 AI 助手读不到 `received/` 文件夹？

需要给 AI 授权这个文件夹（Claude Code：`/add-dir <路径>`；或对话框里选文件夹授权）。这是必须的一步。

### Q9：Mac / Linux 能用吗？

**不能。** 脚本依赖 Windows 剪贴板 API 和 Windows 离线 OCR 引擎（WinRT），Mac/Linux 无法运行。这类平台建议直接用原生多模态模型。

### Q10：`CLAUDE.md` / `AGENTS.md` 里的路径要改吗？

**要。** 这两个文件里默认写的是 `D:\claudecode图片识别方法\recognize.ps1`。如果你的项目不在这个路径，用文本编辑器打开这两个文件，把路径替换成你电脑上的实际路径即可。不改的话 AI 会找不到脚本。

### Q11：我不想用 Cloud API，能完全离线吗？

可以提取文字（用 `windows-ocr.ps1`，离线 OCR），但**无法做复杂图片理解**（描述、图表分析等），因为那是云端视觉模型的强项。若需完全本地化视觉理解，需自行部署 Ollama + qwen2.5-vl 等本地视觉模型。

---

## 🔗 参考链接

| 用途 | 网址 |
|---|---|
| 智谱开放平台（注册、拿 Key） | https://open.bigmodel.cn/ |
| 智谱 API 文档 | https://open.bigmodel.cn/dev/api |
| 智谱定价 | https://open.bigmodel.cn/pricing |
| 百度 OCR（可选） | https://console.bce.baidu.com/ |
| Claude Code 文档 | https://docs.anthropic.com/en/docs/claude-code |
| ccswitch（模型路由） | https://github.com/cs-switch/ccswitch |

---

## 🔒 隐私说明

- 图片会发送到**智谱云端服务器**识别（如同任何在线 OCR / 识图工具）
- 涉及隐私的图片请勿使用，或先打码
- API Key 请妥善保管，不要公开分享
- 图片仅保存在你本地 `received/`，识别结果仅用于当次对话

---

## 📄 License

MIT License —— 自由使用、修改、分发。详见 `LICENSE` 文件。

---

## 📜 更新日志

- **v3.1 (2026-08-08)**：README 新增「使用范围」章节（适用/不适用人群、平台限制）；新增「各编程工具接入指令」手把手教程（Claude Code / OpenCode / Codex / Cursor / 通用）；新增 `CLAUDE.md` / `AGENTS.md` 自动接入配置；FAQ 补充路径修改、Mac/Linux、离线等问题
- **v3 (2026-08-08)**：开源重构。脚本去写死路径、同级 `received/` 自动适配；新增 `recognize.ps1`（纯 PowerShell 识别，不依赖 Python）、`windows-ocr.ps1`（离线兜底）、`setup.ps1`（一键配置）、`recognize.bat`（拖图即识别）
- **v2 (2026-08-08)**：源码改纯 ASCII 避免 PowerShell 5.1 中文乱码闪退；新增临时目录监听
- **v1 (2026-08-08)**：初版，仅监听剪贴板图片

---

*本方案由陈启粤整理并开源，2026-08-08 最后更新。*
