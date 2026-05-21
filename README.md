# macos-computer-use

macOS 通用计算机控制 CLI - 零 token 开销的 computer-use 工具

替代 MCP 服务的本地 CLI 方案，提供完整的 UI 自动化能力（截图、鼠标、键盘控制），所有操作在本地执行，不消耗任何 LLM token。

## 功能特性

- **截图**: 全屏捕获，返回 `file://` URL（非图片流）
- **鼠标控制**: 移动、左/右/中键点击、双击、拖拽、滚动
- **键盘控制**: 单键、组合键、文本输入
- **JSON 输出**: 所有命令支持 `--json` 标志，便于 AI Agent 解析
- **零 Token 开销**: 纯本地执行，不经过 MCP 服务

## 系统要求

- macOS 13.0+
- Xcode 16.0+ / Swift 6.0+

## 安装

### 方式一：快速安装（推荐）

```bash
git clone <repo-url>
cd macos-computer-use
./install.sh
```

### 方式二：手动构建

```bash
swift build -c release
cp .build/release/macos-computer-use /usr/local/bin/
```

### 权限说明

首次运行截图或控制命令时，macOS 会请求以下权限，请在**系统设置 > 隐私与安全性**中允许：

- **屏幕录制**: 用于截图功能
- **辅助功能**: 用于鼠标和键盘控制

## 命令参考

### 截图

```bash
# 基本截图（人类可读输出）
macos-computer-use screenshot

# JSON 输出（供 AI 解析）
macos-computer-use screenshot --json

# 自定义输出目录和文件名
macos-computer-use screenshot --output-dir ~/Desktop --filename myshot.png
```

返回示例（JSON）：
```json
{
  "success": true,
  "url": "file:///Users/xxx/.macos_computer_use/screenshots/screenshot_1234567890.png",
  "filepath": "/Users/xxx/.macos_computer_use/screenshots/screenshot_1234567890.png",
  "filename": "screenshot_1234567890.png",
  "size_bytes": 1490210,
  "image_width": 3024,
  "image_height": 1964,
  "cursor_position": {"x": 519, "y": 616}
}
```

### 获取光标位置

```bash
macos-computer-use cursor-position --json
```

### 鼠标移动

```bash
macos-computer-use mouse-move -x 100 -y 200 --json
```

### 点击操作

```bash
# 在当前位置左键点击
macos-computer-use left-click --json

# 在指定坐标左键点击
macos-computer-use left-click -x 500 -y 300 --json

# 右键点击
macos-computer-use right-click -x 500 -y 300 --json

# 中键点击
macos-computer-use middle-click -x 500 -y 300 --json

# 双击
macos-computer-use double-click -x 500 -y 300 --json
```

### 拖拽

```bash
macos-computer-use drag --to-x 800 --to-y 600 --json
```

### 滚动

```bash
macos-computer-use scroll -x 500 -y 300 --direction down --amount 500 --json
```

### 按键

```bash
# 单键
macos-computer-use key --keys "return" --json

# 组合键
macos-computer-use key --keys "command+c" --json
macos-computer-use key --keys "shift+tab" --json
macos-computer-use key --keys "command+space" --json
```

支持的键名：`command`, `shift`, `option`, `control`, `return`, `enter`, `tab`, `space`, `escape`, `delete`, `up`, `down`, `left`, `right`, `a-z`, `0-9`, `f1-f12` 等。

### 输入文本

```bash
macos-computer-use type --text "Hello World" --json
```

## AI Agent 集成示例

由于 CLI 直接返回 JSON，AI Agent 可以轻松调用：

```bash
# 截图并获取 URL
URL=$(macos-computer-use screenshot --json | jq -r '.url')
echo "Screenshot saved at: $URL"

# 移动鼠标并点击
macos-computer-use mouse-move -x 100 -y 100 --json
macos-computer-use left-click --json

# 执行组合键
macos-computer-use key --keys "command+space" --json
```

## 与 MCP 对比

| 特性 | MCP 服务 | macos-computer-use CLI |
|------|----------|----------------------|
| Token 消耗 | 高（图片流 base64） | **零** |
| 截图传输 | 图片流 | **file:// URL** |
| 依赖 | Node.js + MCP 服务器 | **仅 macOS 系统** |
| 启动时间 | 需启动服务 | **毫秒级** |
| 适用场景 | 跨平台 | **macOS 专用** |

## 项目结构

```
macos-computer-use/
├── Package.swift           # Swift Package Manager 配置
├── Sources/
│   └── macos-computer-use/
│       ├── main.swift      # CLI 入口
│       ├── Core/
│       │   ├── MouseController.swift      # 鼠标控制
│       │   ├── KeyboardController.swift   # 键盘控制
│       │   └── ScreenshotTool.swift       # 截图工具
│       ├── Commands/       # 11 个 CLI 命令
│       │   ├── ScreenshotCommand.swift
│       │   ├── CursorPositionCommand.swift
│       │   ├── MouseMoveCommand.swift
│       │   ├── LeftClickCommand.swift
│       │   ├── RightClickCommand.swift
│       │   ├── MiddleClickCommand.swift
│       │   ├── DoubleClickCommand.swift
│       │   ├── DragCommand.swift
│       │   ├── ScrollCommand.swift
│       │   ├── KeyCommand.swift
│       │   └── TypeCommand.swift
│       └── Utils/
│           └── KeyMap.swift  # 键名映射
├── install.sh              # 安装脚本
└── README.md               # 本文档
```

## License

MIT
