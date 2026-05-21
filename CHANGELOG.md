# Changelog

所有项目的显著变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [1.0.0] - 2025-05-21

### Added
- 初始版本发布
- 屏幕截图功能，支持 JSON 输出和自定义输出目录
- 鼠标控制功能：
  - 获取光标位置
  - 移动鼠标到指定坐标
  - 左键/右键/中键点击
  - 双击
  - 拖拽
  - 滚动（上下左右）
- 键盘控制功能：
  - 按键组合（支持 xdotool 风格键名）
  - 文本输入
- 完整的 CLI 界面，使用 swift-argument-parser
- 安装脚本支持

### Technical
- 使用 Swift 5.9 开发
- 支持 macOS 14.0+
- 基于 CoreGraphics 框架实现底层控制
- 采用多策略回退机制确保截图可靠性

[Unreleased]: https://github.com/iamme19862002/macos-computer-use/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/iamme19862002/macos-computer-use/releases/tag/v1.0.0
