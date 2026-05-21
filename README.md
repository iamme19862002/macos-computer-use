# macos-computer-use

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos)

> 🖱️ macOS 通用计算机控制 CLI - 零 token 开销的 computer-use 工具

一个轻量级、高效的 macOS 命令行工具，用于自动化控制鼠标、键盘、屏幕截图、应用管理和 UI 元素操作。专为 AI Agent 和自动化脚本设计，提供类似 [xdotool](https://github.com/jordansissel/xdotool) 的功能，但专为 macOS 优化。

## ✨ 特性

- 🎯 **零 Token 开销** - 本地执行，无需网络请求
- 📸 **屏幕截图** - 支持全屏截图，自动标记光标位置
- 🖱️ **鼠标控制** - 移动、点击（左/右/中）、双击、拖拽、滚动
- ⌨️ **键盘控制** - 按键组合、文本输入
- 📱 **应用管理** - 启动、关闭、激活、隐藏应用
- 🪟 **窗口管理** - 列出、调整大小、移动、最小化、关闭、聚焦窗口
- 🔍 **UI 元素定位** - 通过 Accessibility API 查找和点击 UI 元素
- ⏱️ **等待机制** - 等待元素出现、应用启动、指定时间
- 📋 **剪贴板操作** - 复制、粘贴、获取剪贴板内容
- 🖥️ **系统信息** - 屏幕、显示器、系统信息查询
- 📊 **进程管理** - 列出进程、结束进程
- 🎬 **录制回放** - 录制操作序列并回放
- 📜 **脚本执行** - 批量执行 JSON 脚本
- 🔤 **OCR 识别** - 识别截图中的文字
- 🎯 **视觉定位** - 基于模板匹配的图像识别定位
- 🚀 **高性能** - 原生 Swift 实现，低延迟
- 📦 **易于安装** - 一键安装脚本
- 🔧 **JSON 输出** - 支持程序化调用

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

### 录制回放

```bash
# 录制操作（默认 60 秒）
macos-computer-use record --output actions.json

# 录制 30 秒
macos-computer-use record --output actions.json --duration 30

# 回放录制的操作
macos-computer-use replay --file actions.json
```

### 脚本执行

```bash
# 执行 JSON 脚本文件
macos-computer-use run-script --file workflow.json
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
│   ├── RecordCommand.swift
│   ├── ReplayCommand.swift
│   ├── RunScriptCommand.swift
│   ├── OCRCommand.swift
│   ├── FindImageCommand.swift
│   └── ClickImageCommand.swift
└── Utils/
    ├── KeyMap.swift              # 键名映射
    └── JSONUtils.swift           # JSON 工具
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

- 灵感来源于 [xdotool](https://github.com/jordansissel/xdotool) - Linux 的 X11 自动化工具
- 使用 [swift-argument-parser](https://github.com/apple/swift-argument-parser) 构建 CLI 界面

---

<p align="center">Made with ❤️ for the macOS automation community</p>
