# macos-computer-use 文档中心

> 欢迎使用 macos-computer-use —— 专为 AI Agent 和自动化测试设计的 macOS 控制工具。

## 文档目录

| 文档 | 说明 | 目标读者 |
|------|------|----------|
| [COMMANDS.md](COMMANDS.md) | 完整命令参考手册 | 所有用户 |
| [AI_AGENT_GUIDE.md](AI_AGENT_GUIDE.md) | AI Agent 实战指南 | AI 开发者 |
| [AUTOMATION_SCENARIOS.md](AUTOMATION_SCENARIOS.md) | 自动化场景案例 | 自动化工程师 |
| [PRODUCTIVITY_GUIDE.md](PRODUCTIVITY_GUIDE.md) | 提效实战指南 | 效率工作者 |

## 快速开始

```bash
# 安装
swift build -c release
sudo cp .build/release/macos-computer-use /usr/local/bin/

# 查看版本
macos-computer-use --version

# 查看帮助
macos-computer-use --help
```

## 核心特性

- **零 Token 开销**：所有操作本地执行，不调用远程 API
- **AI Agent 原生支持**：JSON 输出，断言验证，错误处理
- **完整 UI 自动化**：鼠标、键盘、应用、窗口、元素操作
- **智能验证**：OCR 文字识别，视觉定位，元素断言
- **测试框架集成**：测试标记，步骤记录，重试机制

## 版本信息

当前版本：**3.1.0**

查看 [CHANGELOG.md](../CHANGELOG.md) 了解详细更新历史。
