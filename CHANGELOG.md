# 更新日志

本项目所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/spec/v2.0.0.html)。

## [未发布]

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

### 变更
- 版本号更新至 3.2.0
- 所有新增命令支持 JSON 输出，便于 AI Agent 集成
- 新增文件系统命令补齐 AI Agent "读数据→处理→写结果"闭环能力

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
