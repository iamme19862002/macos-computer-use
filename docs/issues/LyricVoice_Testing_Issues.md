# macos-computer-use 测试 LyricVoice 发现的问题

> **测试日期**: 2026-05-25  
> **测试目标**: LyricVoice (AI 音频转字幕 macOS App)  
> **测试工具版本**: macos-computer-use (latest)  

---

## 一、已验证正常工作的功能

| 功能 | 命令示例 | 状态 | 说明 |
|------|---------|------|------|
| `element-list` | `macos-computer-use element-list --app "LyricVoice" --depth 7` | ✅ 正常 | 可以列出 App 主窗口的 UI 元素 |
| `element-click --identifier` | `macos-computer-use element-click --app "LyricVoice" --identifier "add-audio-button"` | ✅ 正常 | 可以成功点击带 Accessibility 标签的按钮 |
| `app-activate` | `macos-computer-use app-activate "LyricVoice"` | ✅ 正常 | 可以激活 App |
| `screenshot` | `macos-computer-use screenshot --output-dir /tmp --filename test.png` | ✅ 正常 | 可以截取屏幕 |
| `hotkey` | `macos-computer-use hotkey --keys "command+shift+g"` | ✅ 正常 | 可以发送组合键 |
| `type` | `macos-computer-use type --text "hello"` | ✅ 正常 | 可以输入文本 |

---

## 二、核心问题：无法操作系统文件选择器 (NSOpenPanel)

### 2.1 问题描述

`macos-computer-use` 无法操作 `NSOpenPanel`（系统文件选择器），这是自动化测试的最大阻塞点。

### 2.2 具体表现

#### 2.2.1 element-list 无法列出文件选择器元素

**命令**:
```bash
macos-computer-use element-list --app "LyricVoice" --depth 7
```

**预期**: 应该列出文件选择器（Sheet）内的所有元素，包括：
- 左侧书签栏（traeeProjects、下载、影片等）
- 右侧文件列表
- 「取消」「打开」按钮

**实际**: 只能列出 LyricVoice 主窗口的元素，文件选择器内的元素完全不可见。

**截图证据**: `/tmp/lyricvoice_test3_filepicker.png`

---

#### 2.2.2 element-click 无法点击文件选择器内的按钮

**命令**:
```bash
# 尝试点击文件选择器内的元素
macos-computer-use element-click --app "LyricVoice" --title "取消"
macos-computer-use element-click --app "LyricVoice" --title "打开"
```

**预期**: 应该成功点击「取消」或「打开」按钮。

**实际**: 返回 "Element not found"。

**原因分析**: 文件选择器是系统级 Sheet，不在 App 的 Accessibility 树中。

---

#### 2.2.3 hotkey 发送的 Command+Shift+G 行为异常

**命令**:
```bash
macos-computer-use hotkey --keys "command+shift+g"
```

**预期**: 在文件选择器中弹出「前往文件夹」对话框。

**实际**: 触发文件选择器的搜索框，而不是「前往文件夹」对话框。

**截图证据**: `/tmp/lyricvoice_test8_goto.png`

**对比**: 手动按 `Command+Shift+G` 可以正常弹出「前往文件夹」对话框。

---

#### 2.2.4 AppleScript 操作文件选择器失败

**AppleScript 代码**:
```applescript
tell application "System Events"
    tell process "LyricVoice"
        set frontmost to true
        set sheet1 to sheet 1 of window "灵听字幕"
        set sg to splitter group 1 of sheet1
        set leftScroll to scroll area 1 of sg
        set outline1 to outline 1 of leftScroll
        
        -- 尝试点击第7行（traeeProjects）
        set row7 to row 7 of outline1
        click row7
    end tell
end tell
```

**预期**: 应该成功点击左侧书签栏的「traeeProjects」。

**实际**: AppleScript 执行成功，但 UI 无响应，文件选择器仍显示 tmp 文件夹。

**截图证据**: `/tmp/lyricvoice_test9_traeprojects.png`

---

#### 2.2.5 坐标点击无效

**命令**:
```bash
# 尝试点击左侧书签区域
macos-computer-use left-click -x 855 -y 435
```

**预期**: 应该点击「traeeProjects」书签，导航到该文件夹。

**实际**: 点击成功（命令返回 ✓），但 UI 无响应。

**原因分析**: 文件选择器可能不接受 Quartz Event API 的点击事件。

---

### 2.3 测试流程执行情况

| 步骤 | 状态 | 说明 |
|------|------|------|
| 1. 启动 App | ✅ 成功 | App 正常启动，显示 Home 页面 |
| 2. 截图确认 | ✅ 成功 | 截图清晰，可以分析 UI 状态 |
| 3. 点击「添加音频」 | ✅ 成功 | `element-click --identifier` 正常工作 |
| 4. 文件选择器弹出 | ✅ 成功 | NSOpenPanel 正常弹出 |
| 5. 选择音频文件 | ❌ **失败** | **无法操作文件选择器** |
| 6. 开始转换 | ⏸️ 阻塞 | 需要先完成步骤 5 |
| 7. 验证结果 | ⏸️ 阻塞 | 需要先完成步骤 6 |

---

## 三、可能的原因分析

### 3.1 系统安全限制
- macOS 对系统对话框（NSOpenPanel）有额外的安全限制
- 可能需要「辅助功能」权限才能操作系统对话框
- 即使 LyricVoice 有辅助功能权限，系统对话框可能仍有独立的安全限制

### 3.2 Accessibility API 限制
- `NSOpenPanel` 作为系统级 Sheet，可能不在 App 的 Accessibility 树中
- `element-list` 只能访问 App 主窗口的元素，无法访问系统对话框
- 系统对话框可能使用独立的 Accessibility 上下文

### 3.3 Quartz Event API 限制
- 坐标点击（`left-click`）可能无法作用于系统对话框
- 系统对话框可能需要特殊的 Event 类型才能响应
- 系统对话框可能只响应「真实」的用户输入，而非模拟的 Event

---

## 四、建议的解决方案

### 4.1 方案 1：支持操作系统级对话框（推荐）

**目标**: 让 `macos-computer-use` 能够操作 `NSOpenPanel`/`NSSavePanel`

**可能的实现方式**:
1. 添加 `--sheet` 或 `--panel` 参数，专门访问 Sheet 内的元素
2. 使用更低级的 API（如 `AXUIElementCreateSystemWide`）访问系统对话框
3. 添加特殊的事件类型来操作系统对话框

**示例命令**:
```bash
# 列出文件选择器内的元素
macos-computer-use element-list --app "LyricVoice" --sheet 1 --depth 5

# 点击文件选择器内的按钮
macos-computer-use element-click --app "LyricVoice" --sheet 1 --title "打开"

# 点击左侧书签
macos-computer-use element-click --app "LyricVoice" --sheet 1 --row "traeeProjects"
```

---

### 4.2 方案 2：增强 hotkey 功能

**目标**: 让 `hotkey` 命令在文件选择器中能正确触发「前往文件夹」

**可能的实现方式**:
1. 检测当前是否有系统对话框，并针对性地发送事件
2. 使用 `CGEventTap` 确保快捷键被正确传递到系统对话框

**示例命令**:
```bash
# 在文件选择器中打开「前往文件夹」
macos-computer-use hotkey --target sheet --keys "command+shift+g"
```

---

### 4.3 方案 3：添加 AppleScript 桥接

**目标**: 通过 AppleScript 操作系统对话框

**可能的实现方式**:
1. 添加 `applescript` 命令，直接执行 AppleScript 代码
2. 封装常用的文件选择器操作（如「前往文件夹」「选择文件」）

**示例命令**:
```bash
# 在文件选择器中输入路径
macos-computer-use applescript --code '
    tell application "System Events"
        tell process "LyricVoice"
            keystroke "g" using {command down, shift down}
            delay 0.5
            keystroke "/path/to/file.wav"
            keystroke return
        end tell
    end tell
'
```

---

### 4.4 方案 4：添加拖拽文件功能

**目标**: 支持从 Finder 拖拽文件到 App

**可能的实现方式**:
1. 增强 `drag` 命令，支持跨窗口拖拽
2. 添加 `drag-file` 命令，专门用于拖拽文件

**示例命令**:
```bash
# 从 Finder 拖拽文件到 App
macos-computer-use drag-file --from-path "/path/to/file.wav" --to-app "LyricVoice" --to-region "1200,600,200,200"
```

---

## 五、相关截图

以下截图保存在 `/tmp/` 目录，可作为问题证据：

| 截图文件 | 说明 |
|---------|------|
| `lyricvoice_test1_home.png` | LyricVoice Home 页面 |
| `lyricvoice_test2_activated.png` | App 激活状态 |
| `lyricvoice_test3_filepicker.png` | 文件选择器弹出 |
| `lyricvoice_test4_after_click.png` | 坐标点击后无响应 |
| `lyricvoice_test5_check.png` | 文件选择器仍在显示 |
| `lyricvoice_test6_after_click2.png` | 再次尝试坐标点击 |
| `lyricvoice_test7_search.png` | 尝试输入路径 |
| `lyricvoice_test8_goto.png` | hotkey 发送 Command+Shift+G 后 |
| `lyricvoice_test9_traeprojects.png` | AppleScript 点击后无响应 |
| `lyricvoice_test10_marked.png` | 使用 --mark-elements 标记元素 |
| `lyricvoice_test11_goto2.png` | 再次尝试 hotkey |
| `lyricvoice_test12_select_media.png` | 点击「选择音视频文件」按钮 |
| `lyricvoice_test13_cancelled.png` | 取消文件选择器后 |

---

## 六、测试环境

- **操作系统**: macOS (版本未记录)
- **LyricVoice 版本**: Debug 版本（本地构建）
- **macos-computer-use 版本**: Latest
- **测试音频**: `/Users/wangmin/traeProjects/LyricVoice/test/audio/chinese_10s.wav`

---

## 七、结论

**macos-computer-use 在操作 LyricVoice 主界面时表现良好**，`element-click --identifier` 可以正常工作。

**但无法操作系统文件选择器（NSOpenPanel）**，这是自动化测试的最大阻塞点。建议优先实现「支持操作系统级对话框」功能。

---

*文档创建时间: 2026-05-25*  
*作者: SOLO Agent*
