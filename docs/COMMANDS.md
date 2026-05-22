# 命令参考手册

> 完整的 macos-computer-use 命令列表和使用说明。

## 命令分类

| 分类 | 命令数量 | 说明 |
|------|----------|------|
| [鼠标操作](#鼠标操作) | 8 | 移动、点击、拖拽、滚动 |
| [键盘操作](#键盘操作) | 4 | 按键、输入、快捷键、序列 |
| [应用管理](#应用管理) | 6 | 启动、退出、激活、隐藏、列表、前台应用 |
| [窗口管理](#窗口管理) | 7 | 列表、调整、移动、状态控制 |
| [UI 元素](#ui-元素) | 5 | 查找、点击、信息、列表、焦点元素 |
| [断言验证](#断言验证) | 4 | 元素、文本、属性、剪贴板 |
| [等待机制](#等待机制) | 3 | 元素、应用、固定等待 |
| [剪贴板](#剪贴板) | 3 | 复制、粘贴、获取 |
| [截图与 OCR](#截图与-ocr) | 4 | 截图、OCR、视觉定位 |
| [系统信息](#系统信息) | 3 | 屏幕、显示器、系统 |
| [进程管理](#进程管理) | 2 | 列表、结束 |
| [文件系统](#文件系统) | 4 | 读取、写入、检查、列出 |
| [测试报告](#测试报告) | 3 | 开始、结束、步骤 |
| [控制流](#控制流) | 1 | 重试 |
| [录制回放](#录制回放) | 2 | 录制、回放 |
| [脚本执行](#脚本执行) | 1 | 执行 JSON 脚本 |

---

## 鼠标操作

### mouse-move

移动鼠标到指定位置。

```bash
# 移动到屏幕坐标
macos-computer-use mouse-move --x 500 --y 300

# 移动到元素中心
macos-computer-use mouse-move --app Safari --target "地址栏"

# 相对移动
macos-computer-use mouse-move --dx 100 --dy 50
```

### left-click

左键点击。

```bash
# 点击坐标
macos-computer-use left-click --x 500 --y 300

# 点击元素
macos-computer-use left-click --app Safari --target "刷新按钮"
```

### right-click

右键点击。

```bash
macos-computer-use right-click --app Finder --target "文件1.txt"
```

### double-click

双击。

```bash
macos-computer-use double-click --app Finder --target "文档文件夹"
```

### middle-click

中键点击（常用于关闭标签页）。

```bash
macos-computer-use middle-click --app Safari --target "标签页标题"
```

### drag

拖拽操作。

```bash
# 从元素A拖拽到元素B
macos-computer-use drag \
  --from-app Finder --from-target "文件1.txt" \
  --to-app Safari --to-target "上传区域"

# 从坐标到坐标
macos-computer-use drag --from-x 100 --from-y 200 --to-x 500 --to-y 600
```

### scroll

滚动。

```bash
# 在应用内滚动
macos-computer-use scroll --app Safari --target "页面内容" --delta-y -500

# 在坐标处滚动
macos-computer-use scroll --x 500 --y 500 --delta-y -300
```

### mouse-hover

鼠标悬停。

```bash
# 悬停在元素上
macos-computer-use mouse-hover --app Safari --target "帮助图标" --duration 2

# 悬停在坐标上
macos-computer-use mouse-hover --x 500 --y 300 --duration 1
```

---

## 键盘操作

### key

按下单个键。

```bash
macos-computer-use key --app Safari --key return
macos-computer-use key --app TextEdit --key escape
```

### type

输入文本。

```bash
# 基本输入
macos-computer-use type --app Safari --target "地址栏" --text "https://www.apple.com"

# 输入后按回车
macos-computer-use type --app Safari --target "搜索框" --text "macOS" --submit

# 清空后输入
macos-computer-use type --app TextEdit --target "文档内容" --text "新内容" --clear
```

### hotkey

组合快捷键。

```bash
# 保存
macos-computer-use hotkey --keys command+s

# 全选
macos-computer-use hotkey --keys command+a

# 截图到剪贴板
macos-computer-use hotkey --keys command+shift+4
```

### key-sequence

按键序列。

```bash
# Vim 操作
macos-computer-use key-sequence --keys "esc,gg,dG" --delay 100
```

---

## 应用管理

### app-launch

启动应用。

```bash
macos-computer-use app-launch --app Safari
macos-computer-use app-launch --app Xcode --wait
```

### app-quit

退出应用。

```bash
macos-computer-use app-quit --app Safari
macos-computer-use app-quit --app Safari --force
```

### app-activate

激活应用（调到前台）。

```bash
macos-computer-use app-activate --app Safari
```

### app-hide

隐藏应用。

```bash
macos-computer-use app-hide --app Safari
```

### app-list

列出运行中的应用。

```bash
macos-computer-use app-list
macos-computer-use app-list --frontmost-only
macos-computer-use app-list --format json
```

### frontmost-app

获取当前前台应用信息。

```bash
macos-computer-use frontmost-app
macos-computer-use frontmost-app --json
```

---

## 窗口管理

### window-list

列出窗口。

```bash
macos-computer-use window-list
macos-computer-use window-list --app Safari
macos-computer-use window-list --visible-only
```

### window-resize

调整窗口大小。

```bash
macos-computer-use window-resize --app Safari --width 1200 --height 800
```

### window-move

移动窗口。

```bash
macos-computer-use window-move --app Safari --x 100 --y 100
macos-computer-use window-move --app Safari --center
```

### window-minimize

最小化窗口。

```bash
macos-computer-use window-minimize --app Safari
```

### window-maximize

最大化窗口。

```bash
macos-computer-use window-maximize --app Safari
```

### window-close

关闭窗口。

```bash
macos-computer-use window-close --app Safari
```

### window-focus

设置焦点到窗口。

```bash
macos-computer-use window-focus --app Safari
```

---

## UI 元素

### element-find

查找元素。

```bash
macos-computer-use element-find --app Safari --name "搜索框"
macos-computer-use element-find --app Safari --type button --label "刷新"
```

### element-click

点击元素。

```bash
macos-computer-use element-click --app Safari --name "登录按钮"
```

### element-info

获取元素信息。

```bash
macos-computer-use element-info --app Safari --name "用户名输入框"
```

### element-list

列出所有元素。

```bash
macos-computer-use element-list --app Safari
macos-computer-use element-list --app Safari --type button
```

### focused-element

获取当前焦点 UI 元素信息。

```bash
macos-computer-use focused-element
macos-computer-use focused-element --json
```

---

## 断言验证

### assert-element-exists

断言元素存在。

```bash
# 断言存在
macos-computer-use assert-element-exists --app Safari --title "地址栏" --timeout 5

# 断言不存在
macos-computer-use assert-element-exists --app Safari --title "错误提示" --not-exists
```

### assert-text-exists

断言文本存在（OCR）。

```bash
# 断言文本存在
macos-computer-use assert-text-exists --app Safari --text "欢迎回来" --timeout 5

# 断言文本不存在
macos-computer-use assert-text-exists --app Safari --text "错误" --not-exists
```

### assert-element-property

断言元素属性。

```bash
macos-computer-use assert-element-property --app Safari --title "提交" --property enabled --value true
```

### assert-clipboard

断言剪贴板内容。

```bash
macos-computer-use assert-clipboard --contains "复制的内容"
macos-computer-use assert-clipboard --equals "精确匹配"
macos-computer-use assert-clipboard --not-empty
```

---

## 等待机制

### wait-for-element

等待元素出现或消失。

```bash
macos-computer-use wait-for-element --app Safari --name "加载完成" --timeout 10
macos-computer-use wait-for-element --app Safari --name "加载中..." --timeout 10 --disappear
```

### wait-for-app

等待应用启动或退出。

```bash
macos-computer-use wait-for-app --app Safari --timeout 15
macos-computer-use wait-for-app --app Safari --timeout 10 --exit
```

### sleep

固定等待。

```bash
macos-computer-use sleep --seconds 3
macos-computer-use sleep --milliseconds 500
```

---

## 剪贴板

### clipboard-copy

复制到剪贴板。

```bash
macos-computer-use clipboard-copy --text "要复制的内容"
```

### clipboard-paste

从剪贴板粘贴。

```bash
macos-computer-use clipboard-paste --app TextEdit --target "文档内容"
```

### clipboard-get

获取剪贴板内容。

```bash
macos-computer-use clipboard-get
```

---

## 截图与 OCR

### screenshot

截图。

```bash
macos-computer-use screenshot --output full.png
macos-computer-use screenshot --app Safari --output safari.png
macos-computer-use screenshot --x 100 --y 100 --width 500 --height 400 --output region.png
```

### ocr

OCR 识别。

```bash
macos-computer-use ocr
macos-computer-use ocr --app Safari
macos-computer-use ocr --x 100 --y 100 --width 500 --height 400
```

### find-image

查找图片。

```bash
macos-computer-use find-image --template "button.png"
macos-computer-use find-image --app Safari --template "icon.png"
```

### click-image

点击图片。

```bash
macos-computer-use click-image --app Safari --template "submit_button.png"
```

---

## 系统信息

### screen-info

屏幕信息。

```bash
macos-computer-use screen-info
```

### display-list

显示器列表。

```bash
macos-computer-use display-list
macos-computer-use display-list --format json
```

### system-info

系统信息。

```bash
macos-computer-use system-info
macos-computer-use system-info --detailed
```

---

## 进程管理

### process-list

列出进程。

```bash
macos-computer-use process-list
macos-computer-use process-list --name Safari
```

### process-kill

结束进程。

```bash
macos-computer-use process-kill --name Safari
macos-computer-use process-kill --pid 12345
```

---

## 文件系统

### file-read

读取文件内容。

```bash
# 读取文本文件
macos-computer-use file-read ~/Documents/note.txt

# 以 base64 编码输出（适用于二进制文件）
macos-computer-use file-read ~/Pictures/image.png --base64

# JSON 输出
macos-computer-use file-read ~/config.json --json
```

### file-write

写入文件内容。

```bash
# 写入文本
macos-computer-use file-write ~/output.txt --text "Hello, World!"

# 追加模式
macos-computer-use file-write ~/log.txt --text "New log entry" --append

# 从 base64 解码写入
macos-computer-use file-write ~/image.png --base64 "iVBORw0KGgo..."

# 自动创建父目录
macos-computer-use file-write ~/new/dir/file.txt --text "content" --create-dirs
```

### file-exists

检查文件或目录是否存在。

```bash
# 检查文件是否存在
macos-computer-use file-exists ~/Documents/report.pdf

# 检查目录是否存在
macos-computer-use file-exists ~/Downloads --directory

# 反向断言（断言不存在）
macos-computer-use file-exists ~/temp.txt --not-exists

# JSON 输出
macos-computer-use file-exists ~/data.json --json
```

### dir-list

列出目录内容。

```bash
# 列出当前目录
macos-computer-use dir-list

# 列出指定目录
macos-computer-use dir-list ~/Documents

# 递归列出
macos-computer-use dir-list ~/Projects --recursive

# 包含隐藏文件
macos-computer-use dir-list ~ --hidden

# JSON 输出
macos-computer-use dir-list ~/Downloads --json
```

---

## 测试报告

### test-start

标记测试开始。

```bash
macos-computer-use test-start --name "登录测试" --id "TC001" --description "验证用户登录功能"
```

### test-end

标记测试结束。

```bash
macos-computer-use test-end --result pass
macos-computer-use test-end --result fail --reason "登录按钮不可点击"
```

### step

标记测试步骤。

```bash
macos-computer-use step --name "输入用户名" --description "在用户名框输入 admin"
```

---

## 控制流

### retry

重试命令。

```bash
macos-computer-use retry --attempts 3 --interval 1 --command "click --app Safari --target 刷新"
```

---

## 录制回放

### record

录制操作。

```bash
macos-computer-use record --output script.json
macos-computer-use record --app Safari --output safari_script.json
```

### replay

回放脚本。

```bash
macos-computer-use replay --input script.json
macos-computer-use replay --input script.json --speed 0.5
```

---

## 脚本执行

### run-script

执行 JSON 脚本。

```bash
macos-computer-use run-script --input workflow.json
```

---

## 全局选项

所有命令都支持以下选项：

| 选项 | 说明 |
|------|------|
| `--json` | JSON 格式输出 |
| `--version` | 显示版本号 |
| `-h, --help` | 显示帮助信息 |

---

## 命令速查表

| 操作 | 命令 |
|------|------|
| 启动应用 | `app-launch --app <name>` |
| 获取前台应用 | `frontmost-app` |
| 获取焦点元素 | `focused-element` |
| 点击元素 | `element-click --app <app> --name <name>` |
| 输入文字 | `type --app <app> --target <target> --text <text>` |
| 按键 | `key --app <app> --key <key>` |
| 快捷键 | `hotkey --keys <keys>` |
| 等待元素 | `wait-for-element --app <app> --name <name> --timeout <sec>` |
| 断言文本 | `assert-text-exists --app <app> --text <text> --timeout <sec>` |
| 截图 | `screenshot --app <app> --output <file>` |
| OCR | `ocr --app <app>` |
| 读取文件 | `file-read <path>` |
| 写入文件 | `file-write <path> --text <text>` |
| 检查文件 | `file-exists <path>` |
| 列出目录 | `dir-list <path>` |
| 重试 | `retry --attempts <n> --command "<cmd>"` |
