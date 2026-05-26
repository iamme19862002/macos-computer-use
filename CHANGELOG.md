# 更新日志

本项目所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/spec/v2.0.0.html)。

## [未发布]

### 新增

#### 命令
- `cursor-position` - 获取当前鼠标光标位置

### 修复

#### 截图功能
- 修复 `--app` 参数截图不包含系统文件选择器（Sheet）的问题
- 使用 `screencapture -l` 命令截取应用窗口及其附加的 Sheet/对话框
- 新增 `findAllWindows()` 和 `captureAppWindows()` 方法支持应用级截图

#### 元素查找
- 修复 `element-find --title` 无法查找 SwiftUI 按钮的问题
- 现在同时匹配 `title`、`value` 和 `description` 属性，提高查找成功率

#### 命令增强
- `element-click`、`element-find`、`element-list`、`menu-click` 命令添加自动聚焦功能
- `key` 命令支持发送快捷键到指定进程（非全局）
- `type` 命令改用剪贴板粘贴方式，避免中文路径输入乱码
- `DialogOpenFileCommand` 实现完整的文件选择器自动选择文件功能

#### KeyMap
- 添加 `/` 字符映射，支持路径输入

## [3.3.1] - 2026-05-25

### 新增

#### 系统对话框支持
- `element-list --sheet` - 支持列出系统对话框（Sheet）内的 UI 元素，如 NSOpenPanel/NSSavePanel
- `element-click --sheet` - 支持点击系统对话框内的 UI 元素

### 修复

#### 系统对话框操作
- 修复无法操作 NSOpenPanel/NSSavePanel 等系统文件选择器的问题
- 新增 Sheet 元素检测能力，通过 `kAXSheetAttribute` 访问系统对话框
- 支持在系统对话框中查找和点击按钮（如"打开"、"取消"、"前往文件夹"）
- `screenshot-diff` - 对比两张截图的像素级差异，支持差异图输出
- `pixel-color` - 读取指定坐标的像素颜色值（HEX/RGBA）
- `text-select` - 选中文本或获取当前已选文本
- `menu-click` - 通过系统菜单栏操作应用菜单（支持多级菜单）
- `scroll-to-element` - 滚动页面直到指定元素可见
- `notify` - 发送 macOS 系统通知

### 文档
- 命令参考手册补充 7 个缺失命令文档，命令速查表从 24 条扩展至 36 条
- 智能体实战指南新增 3 个实战场景（UI 回归测试、文本编辑自动化、长页面内容抓取）
- 智能体实战指南 Python 工具类补充 20+ 缺失方法，命令覆盖率达 94%
- 智能体实战指南新增 15 条调试技巧和命令覆盖统计表
- README 优化为按功能模块分组的特性列表，新增文档链接表格
- 新增 CODE_OF_CONDUCT.md 行为准则
- 新增 SECURITY.md 安全政策

### 测试
- 新增完整单元测试套件（10 个测试套件，40+ 测试用例）
- 测试覆盖 KeyMap、KeyboardController、CommandResult、AnyCodable、FileSystem、TestCommand、ExitStatus、JSONUtils、Sleep、Integration

## [3.2.0] - 2026-05-22

### 新增

#### 文件系统命令 (P0)
- `file-read` - 读取文件内容，支持 UTF-8 文本和 base64 编码输出
- `file-write` - 写入文件内容，支持文本和 base64 解码写入，支持追加模式
- `file-exists` - 检查文件或目录是否存在，支持反向断言和类型过滤
- `dir-list` - 列出目录内容，支持递归和隐藏文件

#### 状态检测命令 (P0)
- `frontmost-app` - 获取当前前台应用信息
- `focused-element` - 获取当前焦点 UI 元素信息

#### 浏览器控制命令 (P1)
- `browser-navigate` - 在浏览器中导航到指定 URL（支持 Safari/Chrome）
- `browser-get-url` - 获取浏览器当前页面 URL
- `browser-exec-js` - 在浏览器页面执行 JavaScript
- `browser-new-tab` - 新建浏览器标签页
- `browser-close-tab` - 关闭当前浏览器标签页

#### AppleScript 桥接命令 (P1)
- `osascript` - 执行 AppleScript 或 JavaScript for Automation (JXA) 脚本

#### 弹窗处理命令 (P1)
- `dialog-detect` - 检测系统弹窗和权限对话框
- `dialog-dismiss` - 自动关闭弹窗（支持按钮点击和 Escape 键）

### 变更
- 版本号更新至 3.2.0
- 所有新增命令支持 JSON 输出，便于 AI Agent 集成
- 新增文件系统命令补齐 AI Agent "读数据→处理→写结果"闭环能力
- 新增浏览器控制命令支持网页自动化和 SaaS 操作
- 新增弹窗处理命令提升自动化稳定性

### 改进
- `run-script` 脚本引擎升级：支持变量、条件分支（if）、循环（for-each/while）、
  每步重试、dry-run 模式
- 引入 `CommandResult` 统一返回格式和 `ExitStatus` 结构化错误码体系
- 所有文档统一使用简体中文命名

## [3.1.0] - 2026-05-22

### 新增

#### 断言命令 (P0)
- `assert-element-exists` - 验证 UI 元素是否存在，支持超时和轮询
- `assert-text-exists` - 基于 OCR 的屏幕文本验证，支持区域查找
- `assert-element-property` - 验证元素属性（enabled、focused、value、visible）
- `assert-clipboard` - 验证剪贴板内容，支持包含/等于/非空模式

#### 控制流命令 (P0)
- `retry` - 失败命令自动重试，支持配置重试次数和间隔

#### 键盘增强 (P0)
- `hotkey` - 发送组合快捷键（如 command+s、shift+tab）
- `key-sequence` - 发送按键序列，支持延迟（如 Vim 操作）

#### 窗口管理增强 (P1)
- `window-maximize` - 最大化应用窗口

#### 鼠标增强 (P1)
- `mouse-hover` - 在元素或坐标上悬停，支持配置持续时间

#### 测试报告 (P2)
- `test-start` - 标记测试用例开始，支持元数据
- `test-end` - 标记测试用例结束，支持结果和原因
- `step` - 标记单个测试步骤

### 变更
- 版本号更新至 3.1.0
- 所有新命令支持 JSON 输出，便于 AI Agent 集成
- 改进错误处理，提供更详细的错误信息

## [3.0.0] - 2026-05-21

### 新增

#### 核心命令
- `screenshot` - 全屏、应用窗口或区域截图
- `cursor-position` - 获取当前鼠标坐标
- `mouse-move` - 移动鼠标到绝对或相对位置
- `left-click` / `right-click` / `middle-click` / `double-click` - 鼠标点击操作
- `drag` - 坐标或元素间的拖拽操作
- `scroll` - 指定位置的滚动操作

#### 键盘命令
- `key` - 按下单个键
- `type` - 向目标元素输入文本

#### 应用管理
- `app-launch` - 启动应用
- `app-quit` - 退出应用（支持强制退出）
- `app-activate` - 将应用调至前台
- `app-hide` - 隐藏应用
- `app-list` - 列出运行中的应用

#### 窗口管理
- `window-list` - 列出所有窗口
- `window-resize` - 调整窗口大小
- `window-move` - 移动窗口位置或居中
- `window-minimize` - 最小化窗口
- `window-close` - 关闭窗口
- `window-focus` - 聚焦窗口

#### UI 元素操作
- `element-find` - 按角色、标题、标识符查找元素
- `element-click` - 点击元素
- `element-info` - 获取元素信息
- `element-list` - 列出应用中的所有元素

#### 等待机制
- `wait-for-element` - 等待元素出现或消失
- `wait-for-app` - 等待应用启动或退出
- `sleep` - 固定时长等待

#### 剪贴板操作
- `clipboard-copy` - 复制文本到剪贴板
- `clipboard-paste` - 从剪贴板粘贴
- `clipboard-get` - 获取剪贴板内容

#### 系统信息
- `screen-info` - 获取屏幕信息
- `display-list` - 列出所有显示器
- `system-info` - 获取系统信息

#### 进程管理
- `process-list` - 列出进程
- `process-kill` - 按名称或 PID 结束进程

#### 录制与回放
- `record` - 录制用户操作
- `replay` - 回放录制的操作

#### 脚本执行
- `run-script` - 执行 JSON 脚本文件

#### OCR 与视觉定位
- `ocr` - 光学字符识别
- `find-image` - 在屏幕上查找图片
- `click-image` - 点击找到的图片

### 特性
- 零 Token 开销 - 所有操作本地执行
- 所有命令支持 JSON 输出
- Accessibility API 集成
- Vision 框架 OCR 支持
- Core Graphics 屏幕捕获

## [2.0.0] - 2026-05-20

### 新增
- 初始稳定版本，包含基础鼠标和键盘控制
- 应用启动和退出
- 基础截图功能

## [1.0.0] - 2026-05-19

### 新增
- 项目初始化
- 基于 ArgumentParser 的基础 CLI 结构
- 鼠标移动概念验证

---

## 版本历史摘要

| 版本 | 日期 | 主要特性 |
|---------|------|--------------|
| 3.2.0 | 2026-05-22 | 文件系统操作、状态检测 |
| 3.1.0 | 2026-05-22 | 断言、快捷键、测试报告、重试 |
| 3.0.0 | 2026-05-21 | 完整自动化套件、OCR、录制 |
| 2.0.0 | 2026-05-20 | 稳定基础控制 |
| 1.0.0 | 2026-05-19 | 初始版本 |
