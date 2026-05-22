# macos-computer-use

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos)

> 🖱️ macOS 通用计算机控制 CLI - 零 token 开销的 computer-use 工具

一个原生 Swift 编写的高性能 macOS 自动化工具集，提供 **68+ 条命令** 完整覆盖鼠标控制、键盘输入、应用与窗口管理、UI 元素定位、屏幕截图与 OCR、浏览器自动化、文件系统操作、弹窗处理、录制回放、脚本执行、系统通知等全场景计算机控制能力。

与云端方案不同，所有操作**本地执行、零网络依赖、零 Token 开销**，响应延迟低至毫秒级。工具同时内置 **MCP Server 模式**，支持通过 [Model Context Protocol](https://modelcontextprotocol.io) 协议被 Claude、Cursor、Windsurf 等 AI Agent 直接调用，是构建本地 AI 工作流的理想基础设施。

## ✨ 特性

### 核心交互
- 🖱️ **鼠标控制** - 移动、点击（左/右/中）、双击、拖拽、滚动、悬停
- ⌨️ **键盘控制** - 单键、组合快捷键、文本输入、按键序列
- 📱 **应用管理** - 启动、退出、激活、隐藏、列表、前台应用
- 🪟 **窗口管理** - 列出、调整大小、移动、最小化、最大化、关闭、聚焦

### UI 自动化
- 🔍 **UI 元素定位** - 通过 Accessibility API 查找、点击、获取信息
- ⏱️ **等待机制** - 等待元素出现/消失、应用启动/退出、固定等待
- 📋 **剪贴板操作** - 复制、粘贴、获取内容
- 🔔 **弹窗处理** - 检测和关闭系统弹窗（权限弹窗、确认对话框等）
- 📝 **文本操作** - 选中文本、获取已选文本
- 🍎 **菜单点击** - 通过系统菜单栏操作应用菜单

### 视觉与图像
- 📸 **屏幕截图** - 全屏、区域、指定应用、标记 UI 元素
- 🔤 **OCR 识别** - 识别截图中的文字
- 🎯 **视觉定位** - 基于模板匹配的图像识别定位
- 🔄 **截图对比** - 像素级对比两张截图差异
- 🎨 **像素颜色** - 读取指定坐标的像素颜色值

### 系统与文件
- 🖥️ **系统信息** - 屏幕、显示器、系统信息、光标位置查询
- 📊 **进程管理** - 列出进程、结束进程
- 📁 **文件系统** - 读取、写入、检查文件，列出目录
- 🌐 **浏览器控制** - 导航、获取 URL、执行 JS、标签页管理
- 🎭 **AppleScript 桥接** - 执行 AppleScript/JXA 脚本
- 📢 **系统通知** - 发送 macOS 系统通知

### 高级功能
- 🎬 **录制回放** - 录制操作序列并回放
- 📜 **脚本执行** - 批量执行 JSON 脚本（支持变量/条件/循环）
- 🧪 **测试报告** - 测试开始/结束/步骤标记
- 🔄 **控制流** - 重试机制
- 🎯 **零 Token 开销** - 本地执行，无需网络请求
- 🚀 **高性能** - 原生 Swift 实现，低延迟
- 🔧 **JSON 输出** - 所有命令支持 JSON 格式输出，便于程序化调用
- 🤖 **AI Agent 原生支持** - 专为 LLM Agent 设计的命令结构和输出格式

## 📋 系统要求

- macOS 14.0 或更高版本
- Swift 5.9 或更高版本
- 辅助功能权限（首次使用时需要授权）

## 🚀 安装

### 方式一：使用安装脚本（推荐）

```bash
git clone https://github.com/iamme19862002/macos-computer-use.git
cd macos-computer-use
./install.sh
```

### 方式二：手动构建

```bash
git clone https://github.com/iamme19862002/macos-computer-use.git
cd macos-computer-use
swift build -c release
cp .build/release/macos-computer-use /usr/local/bin/
```

### 权限设置

首次使用时，系统会提示授予**辅助功能**权限：

1. 打开 **系统设置** → **隐私与安全性** → **辅助功能**
2. 点击 **+** 按钮
3. 添加你的终端应用（如 Terminal、iTerm2、Trae 等）

## 📚 文档

| 文档 | 说明 | 链接 |
|------|------|------|
| 命令参考手册 | 完整的命令列表和使用说明 | [docs/命令参考手册.md](docs/命令参考手册.md) |
| 智能体实战指南 | AI Agent 开发者的实战场景和 Python 工具库 | [docs/智能体实战指南.md](docs/智能体实战指南.md) |
| 变更日志 | 版本更新记录 | [CHANGELOG.md](CHANGELOG.md) |
| 贡献指南 | 如何参与项目贡献 | [CONTRIBUTING.md](CONTRIBUTING.md) |

## 📖 使用指南

### 基本用法

```bash
# 查看帮助
macos-computer-use --help

# 查看子命令帮助
macos-computer-use help screenshot
```

### 屏幕截图

```bash
# 基本截图
macos-computer-use screenshot

# JSON 输出
macos-computer-use screenshot --json

# 指定输出目录
macos-computer-use screenshot --outputDir ~/Desktop

# 自定义文件名
macos-computer-use screenshot --filename myscreenshot.png
```

### 鼠标控制

```bash
# 获取光标位置
macos-computer-use cursor-position

# 移动鼠标
macos-computer-use mouse-move -x 100 -y 200

# 左键点击（当前位置）
macos-computer-use left-click

# 左键点击（指定位置）
macos-computer-use left-click -x 100 -y 200

# 右键点击
macos-computer-use right-click -x 100 -y 200

# 中键点击
macos-computer-use middle-click -x 100 -y 200

# 双击
macos-computer-use double-click -x 100 -y 200

# 拖拽
macos-computer-use drag --toX 500 --toY 300

# 滚动
macos-computer-use scroll -x 500 -y 300 --direction down --amount 500
```

### 键盘控制

```bash
# 按键组合
macos-computer-use key --keys "command+c"
macos-computer-use key --keys "shift+tab"
macos-computer-use key --keys "command+shift+4"

# 输入文本
macos-computer-use type --text "Hello, World!"
```

### 应用管理

```bash
# 启动应用
macos-computer-use app-launch Safari

# 关闭应用
macos-computer-use app-quit Safari

# 强制关闭
macos-computer-use app-quit Safari --force

# 列出运行中的应用
macos-computer-use app-list
macos-computer-use app-list --json

# 激活应用（调到前台）
macos-computer-use app-activate Safari

# 隐藏应用
macos-computer-use app-hide Safari

# 取消隐藏
macos-computer-use app-hide Safari --unhide
```

### 窗口管理

```bash
# 列出所有窗口
macos-computer-use window-list

# 只列出屏幕上的窗口
macos-computer-use window-list --on-screen

# 列出指定 PID 的窗口
macos-computer-use window-list --pid 1234

# JSON 输出
macos-computer-use window-list --json

# 调整窗口大小
macos-computer-use window-resize 12345 --width 800 --height 600

# 移动窗口
macos-computer-use window-move 12345 -x 100 -y 200

# 最小化窗口
macos-computer-use window-minimize 12345

# 关闭窗口
macos-computer-use window-close 12345

# 聚焦窗口
macos-computer-use window-focus 12345
```

### UI 元素操作

```bash
# 查找 UI 元素
macos-computer-use element-find --role button --app Safari
macos-computer-use element-find --title "确定" --app WeChat
macos-computer-use element-find --identifier "submit-btn"

# 点击 UI 元素
macos-computer-use element-click --role button --title "发送"
macos-computer-use element-click --identifier "confirm-button" --app Safari

# 获取指定位置的元素信息
macos-computer-use element-info -x 500 -y 300
macos-computer-use element-info -x 500 -y 300 --json

# 列出应用的 UI 元素树
macos-computer-use element-list --app Safari
macos-computer-use element-list --app Safari --depth 2 --json
```

### 等待机制

```bash
# 等待 UI 元素出现
macos-computer-use wait-for-element --role button --title "提交" --timeout 10

# 等待应用启动
macos-computer-use wait-for-app Safari --timeout 15

# 等待指定时间（毫秒）
macos-computer-use sleep --ms 1000
```

### 剪贴板操作

```bash
# 复制文本到剪贴板
macos-computer-use clipboard-copy "Hello, World!"

# 从剪贴板粘贴
macos-computer-use clipboard-paste

# 获取剪贴板内容
macos-computer-use clipboard-get
macos-computer-use clipboard-get --json
```

### 系统信息

```bash
# 获取主屏幕信息
macos-computer-use screen-info
macos-computer-use screen-info --json

# 列出所有显示器
macos-computer-use display-list
macos-computer-use display-list --json

# 获取系统信息
macos-computer-use system-info
macos-computer-use system-info --json
```

### 进程管理

```bash
# 列出所有进程
macos-computer-use process-list

# 按名称过滤进程
macos-computer-use process-list --filter Safari

# JSON 输出
macos-computer-use process-list --json

# 结束进程
macos-computer-use process-kill 12345

# 强制结束进程
macos-computer-use process-kill 12345 --force
```

### 文件系统操作

```bash
# 读取文件内容
macos-computer-use file-read ~/Documents/note.txt

# 以 base64 编码读取二进制文件
macos-computer-use file-read ~/Pictures/image.png --base64

# 写入文件
macos-computer-use file-write ~/output.txt --text "Hello, World!"

# 追加内容
macos-computer-use file-write ~/log.txt --text "New entry" --append

# 检查文件是否存在
macos-computer-use file-exists ~/Documents/report.pdf

# 检查目录是否存在
macos-computer-use file-exists ~/Downloads --directory

# 列出目录内容
macos-computer-use dir-list ~/Documents

# 递归列出
macos-computer-use dir-list ~/Projects --recursive
```

### 状态检测

```bash
# 获取当前前台应用
macos-computer-use frontmost-app
macos-computer-use frontmost-app --json

# 获取当前焦点元素
macos-computer-use focused-element
macos-computer-use focused-element --json
```

### 录制回放

```bash
# 录制操作（默认 60 秒）
macos-computer-use record --output actions.json

# 录制 30 秒
macos-computer-use record --output actions.json --duration 30

# 回放录制的操作
macos-computer-use replay --file actions.json
```

### 浏览器控制

```bash
# 导航到 URL
macos-computer-use browser-navigate https://apple.com

# 获取当前页面 URL
macos-computer-use browser-get-url

# 执行 JavaScript
macos-computer-use browser-exec-js "document.title"

# 新建标签页
macos-computer-use browser-new-tab https://example.com

# 关闭标签页
macos-computer-use browser-close-tab
```

### AppleScript 桥接

```bash
# 执行 AppleScript
macos-computer-use osascript 'display dialog "Hello"'

# 执行 JXA
macos-computer-use osascript 'Application("Safari").name()' --language javascript
```

### 弹窗处理

```bash
# 检测系统弹窗
macos-computer-use dialog-detect

# 关闭弹窗
macos-computer-use dialog-dismiss

# 点击指定按钮关闭
macos-computer-use dialog-dismiss --click "不允许"
```

### 脚本执行

```bash
# 执行 JSON 脚本文件
macos-computer-use run-script --file workflow.json

# 仅验证脚本语法
macos-computer-use run-script --file workflow.json --dry-run
```

脚本文件示例 (`workflow.json`):
```json
[
  { "action": "app-launch", "params": { "app": "Safari" } },
  { "action": "sleep", "params": { "ms": "2000" } },
  { "action": "mouse-move", "params": { "x": "500", "y": "300" } },
  { "action": "click", "params": {} },
  { "action": "type", "params": { "text": "Hello World" } },
  { "action": "key", "params": { "keys": "return" } }
]
```

### 截图增强

```bash
# 截取指定区域
macos-computer-use screenshot --region "100,200,800,600"

# 截取指定窗口
macos-computer-use screenshot --window-id 12345

# 截图并标记 UI 元素
macos-computer-use screenshot --mark-elements
```

### OCR 文字识别

```bash
# 识别截图中的文字
macos-computer-use ocr ~/screenshot.png

# 识别指定区域的文字
macos-computer-use ocr ~/screenshot.png --region "100,200,300,400"

# JSON 输出
macos-computer-use ocr ~/screenshot.png --json
```

### 视觉定位

```bash
# 在屏幕上查找图片
macos-computer-use find-image ~/button.png

# 设置匹配阈值
macos-computer-use find-image ~/button.png --threshold 0.9

# 查找并点击图片
macos-computer-use click-image ~/button.png

# JSON 输出
macos-computer-use click-image ~/button.png --json
```
### 支持的按键名称

| 类型 | 按键 |
|------|------|
| 修饰键 | `command`, `cmd`, `shift`, `option`, `alt`, `control`, `ctrl`, `fn` |
| 导航键 | `return`, `enter`, `tab`, `space`, `backspace`, `delete`, `escape`, `esc`, `left`, `right`, `up`, `down`, `home`, `end`, `page_up`, `page_down` |
| 功能键 | `f1` - `f15` |
| 字母 | `a` - `z` |
| 数字 | `0` - `9` |

## 🔧 开发

### 项目结构

```
Sources/macos-computer-use/
├── main.swift                    # 入口点
├── Core/
│   ├── ScreenshotTool.swift      # 截图功能
│   ├── MouseController.swift     # 鼠标控制
│   ├── KeyboardController.swift  # 键盘控制
│   ├── AppManager.swift          # 应用管理
│   ├── WindowManager.swift       # 窗口管理
│   ├── AccessibilityManager.swift # UI 元素定位
│   ├── WaitManager.swift         # 等待机制
│   ├── ClipboardManager.swift    # 剪贴板操作
│   ├── SystemInfoManager.swift   # 系统信息
│   ├── ProcessManager.swift      # 进程管理
│   ├── Recorder.swift            # 录制回放
│   ├── OCRManager.swift          # OCR 文字识别
│   └── VisualMatcher.swift       # 视觉定位
├── Commands/                     # CLI 命令
│   ├── ScreenshotCommand.swift
│   ├── CursorPositionCommand.swift
│   ├── MouseMoveCommand.swift
│   ├── LeftClickCommand.swift
│   ├── RightClickCommand.swift
│   ├── MiddleClickCommand.swift
│   ├── DoubleClickCommand.swift
│   ├── DragCommand.swift
│   ├── ScrollCommand.swift
│   ├── KeyCommand.swift
│   ├── TypeCommand.swift
│   ├── AppLaunchCommand.swift
│   ├── AppQuitCommand.swift
│   ├── AppListCommand.swift
│   ├── AppActivateCommand.swift
│   ├── AppHideCommand.swift
│   ├── FrontmostAppCommand.swift
│   ├── WindowListCommand.swift
│   ├── WindowResizeCommand.swift
│   ├── WindowMoveCommand.swift
│   ├── WindowMinimizeCommand.swift
│   ├── WindowCloseCommand.swift
│   ├── WindowFocusCommand.swift
│   ├── ElementFindCommand.swift
│   ├── ElementClickCommand.swift
│   ├── ElementInfoCommand.swift
│   ├── ElementListCommand.swift
│   ├── FocusedElementCommand.swift
│   ├── WaitForElementCommand.swift
│   ├── WaitForAppCommand.swift
│   ├── SleepCommand.swift
│   ├── ClipboardCopyCommand.swift
│   ├── ClipboardPasteCommand.swift
│   ├── ClipboardGetCommand.swift
│   ├── ScreenInfoCommand.swift
│   ├── DisplayListCommand.swift
│   ├── SystemInfoCommand.swift
│   ├── ProcessListCommand.swift
│   ├── ProcessKillCommand.swift
│   ├── FileReadCommand.swift
│   ├── FileWriteCommand.swift
│   ├── FileExistsCommand.swift
│   ├── DirListCommand.swift
│   ├── BrowserNavigateCommand.swift
│   ├── BrowserGetUrlCommand.swift
│   ├── BrowserExecJsCommand.swift
│   ├── BrowserNewTabCommand.swift
│   ├── BrowserCloseTabCommand.swift
│   ├── OsascriptCommand.swift
│   ├── DialogDetectCommand.swift
│   ├── DialogDismissCommand.swift
│   ├── RecordCommand.swift
│   ├── ReplayCommand.swift
│   ├── RunScriptCommand.swift
│   ├── OCRCommand.swift
│   ├── FindImageCommand.swift
│   └── ClickImageCommand.swift
└── Utils/
    ├── KeyMap.swift              # 键名映射
    ├── JSONUtils.swift           # JSON 工具
    └── CommandResult.swift       # 统一返回格式
```

### 构建

```bash
# 调试构建
swift build

# 发布构建
swift build -c release

# 运行测试
swift test
```

## 🤝 贡献

欢迎贡献代码！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目。

### 提交 Issue

如果你发现了 bug 或有新功能建议，请通过 [GitHub Issues](../../issues) 提交。

### 提交 PR

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request

## 📄 许可证

本项目基于 [MIT 许可证](LICENSE) 开源。

## 🙏 致谢

- 受 [Anthropic Computer Use](https://docs.anthropic.com/en/docs/build-with-claude/computer-use) 和 [OpenAI CUA](https://platform.openai.com/docs/guides/computer-use) 启发，致力于提供本地化的 computer-use 能力
- 使用 [swift-argument-parser](https://github.com/apple/swift-argument-parser) 构建 CLI 界面
- 遵循 [Model Context Protocol](https://modelcontextprotocol.io) 标准实现 AI Agent 集成

---

<p align="center">Made with ❤️ for the macOS automation community</p>
