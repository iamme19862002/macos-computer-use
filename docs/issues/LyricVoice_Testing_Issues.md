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

> **更新状态** (2026-05-25): 部分问题已修复，见下方各小节说明

### 2.1 问题描述

`macos-computer-use` 无法操作 `NSOpenPanel`（系统文件选择器），这是自动化测试的最大阻塞点。

### 2.2 具体表现

#### 2.2.1 element-list 无法列出文件选择器元素

**状态**: ⚠️ **部分修复** (v3.3.1)

**命令**:
```bash
# 旧版本（无法列出）
macos-computer-use element-list --app "LyricVoice" --depth 7

# 新版本（添加 --sheet 参数）
macos-computer-use element-list --app "LyricVoice" --sheet --depth 7
```

**预期**: 应该列出文件选择器（Sheet）内的所有元素，包括：
- 左侧书签栏（traeeProjects、下载、影片等）
- 右侧文件列表
- 「取消」「打开」按钮

**实际**:
- ✅ **已修复**: 添加 `--sheet` 参数后，对传统 AppKit 应用（如 TextEdit）可以列出文件选择器元素
- ❌ **限制**: 对现代 SwiftUI 应用（如 LyricVoice），文件选择器运行在独立进程，仍无法通过 `--sheet` 访问

**截图证据**: `/tmp/lyricvoice_test3_filepicker.png`

**限制说明**:
- `--sheet` 只能访问作为 Sheet 附加到应用窗口的系统对话框
- macOS 现代文件选择器运行在独立的 "Open and Save Panel Service" 进程中，不在应用 Accessibility 树中
- 详见 [四、建议的解决方案](#四建议的解决方案) 中的 `--sheet` 限制说明

---

#### 2.2.2 element-click 无法点击文件选择器内的按钮

**状态**: ⚠️ **部分修复** (v3.3.1)

**命令**:
```bash
# 旧版本（无法点击）
macos-computer-use element-click --app "LyricVoice" --title "取消"
macos-computer-use element-click --app "LyricVoice" --title "打开"

# 新版本（添加 --sheet 参数）
macos-computer-use element-click --app "TextEdit" --sheet --title "打开" --role button
```

**预期**: 应该成功点击「取消」或「打开」按钮。

**实际**:
- ✅ **已修复**: 添加 `--sheet` 参数后，对传统 AppKit 应用（如 TextEdit）可以点击文件选择器内的按钮
- ❌ **限制**: 对现代 SwiftUI 应用（如 LyricVoice），文件选择器运行在独立进程，仍无法通过 `--sheet` 点击

**原因分析**:
- 文件选择器是系统级 Sheet，不在 App 的 Accessibility 树中
- `--sheet` 参数通过 `kAXSheetAttribute` 访问 Sheet 元素，但仅适用于传统 Sheet 模式
- 现代文件选择器运行在 "Open and Save Panel Service" 独立进程中

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
| 5. 选择音频文件 | ✅ **已修复** | 使用 `dialog-open-file` 命令 |
| 6. 开始转换 | ✅ 可继续 | 文件选择后可以继续 |
| 7. 验证结果 | ✅ 可继续 | 流程可完成 |

**修复后的完整流程**:
```bash
# 1. 启动 LyricVoice
macos-computer-use app-launch "LyricVoice"
sleep 2

# 2. 点击「添加音频」按钮
macos-computer-use element-click --app "LyricVoice" --identifier "add-audio-button"
sleep 1

# 3. 在文件选择器中选择文件（使用新命令）
macos-computer-use dialog-open-file \
  --app "LyricVoice" \
  --path "/Users/wangmin/traeProjects/LyricVoice/test/audio/chinese_10s.wav"

# 4. 等待转换完成...
```

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

### 4.1 方案 1：支持操作系统级对话框（已实现）

**目标**: 让 `macos-computer-use` 能够操作 `NSOpenPanel`/`NSSavePanel`

**实现状态** (v3.3.1+):
✅ **已实现**: 添加 `--sheet` 参数支持访问传统 Sheet 模式的系统对话框
✅ **已实现**: 添加 `dialog-open-file` 命令支持现代应用的文件选择器

**已实现的命令**:

**A. 传统 Sheet 模式（AppKit 应用如 TextEdit）**:
```bash
# 列出文件选择器内的元素
macos-computer-use element-list --app "TextEdit" --sheet --depth 5

# 点击文件选择器内的按钮
macos-computer-use element-click --app "TextEdit" --sheet --title "打开"
```

**B. 现代独立进程模式（SwiftUI 应用如 LyricVoice）**:

**重要前提**：必须先打开文件选择器（通过按钮点击、菜单或快捷键）

```bash
# 步骤 1: 打开文件选择器（方式因应用而异）
# 方式 A: 点击界面按钮
macos-computer-use element-click --app "LyricVoice" --identifier "add-audio-button"

# 方式 B: 使用菜单
macos-computer-use menu-click "文件,打开" --app "LyricVoice"

# 方式 C: 使用快捷键
macos-computer-use hotkey --keys "command+o"

# 步骤 2: 等待文件选择器打开
sleep 1

# 步骤 3: 在文件选择器中自动选择文件
macos-computer-use dialog-open-file \
  --app "LyricVoice" \
  --path "/Users/wangmin/traeProjects/LyricVoice/test/audio/chinese_10s.wav"
```

**`--sheet` 参数限制说明**:

| 应用场景 | 是否支持 | 说明 |
|---------|---------|------|
| 传统 AppKit 应用（TextEdit） | ✅ 支持 | 文件选择器作为 Sheet 附加到窗口，可通过 `--sheet` 访问 |
| 现代 SwiftUI 应用（LyricVoice） | ❌ 不支持 | 文件选择器运行在独立进程，不在应用 Accessibility 树中 |
| 系统级权限对话框 | ❌ 不支持 | 需要特殊权限和 API |

**技术原理**:
- `--sheet` 参数通过 `kAXSheetAttribute` 访问窗口的 Sheet 元素
- `dialog-open-file` 使用 Command+Shift+G「前往文件夹」功能绕过 Accessibility 限制
- 现代文件选择器运行在 "Open and Save Panel Service" 独立进程中

**替代方案**:
```bash
# 检测文件选择器（通过 window-list）
macos-computer-use window-list --json | grep '"打开"'

# 关闭文件选择器（发送 Escape 键）
macos-computer-use key --key escape
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
