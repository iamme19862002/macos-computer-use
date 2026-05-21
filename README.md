# macos-computer-use

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos)

> 🖱️ macOS 通用计算机控制 CLI - 零 token 开销的 computer-use 工具

一个轻量级、高效的 macOS 命令行工具，用于自动化控制鼠标、键盘和屏幕截图。专为 AI Agent 和自动化脚本设计，提供类似 [xdotool](https://github.com/jordansissel/xdotool) 的功能，但专为 macOS 优化。

## ✨ 特性

- 🎯 **零 Token 开销** - 本地执行，无需网络请求
- 📸 **屏幕截图** - 支持全屏截图，自动标记光标位置
- 🖱️ **鼠标控制** - 移动、点击（左/右/中）、双击、拖拽、滚动
- ⌨️ **键盘控制** - 按键组合、文本输入
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
├── main.swift                 # 入口点
├── Core/
│   ├── ScreenshotTool.swift   # 截图功能
│   ├── MouseController.swift  # 鼠标控制
│   └── KeyboardController.swift # 键盘控制
├── Commands/                  # CLI 命令
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
│   └── TypeCommand.swift
└── Utils/
    └── KeyMap.swift           # 键名映射
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
