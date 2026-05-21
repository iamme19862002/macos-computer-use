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
git clone https://github.com/yourusername/macos-computer-use.git
cd macos-computer-use
./install.sh
```

### 方式二：手动构建

```bash
git clone https://github.com/yourusername/macos-computer-use.git
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

# 指定输出