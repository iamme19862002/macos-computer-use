# 贡献指南

感谢你对 macos-computer-use 项目的关注！我们欢迎各种形式的贡献，包括但不限于：

- 提交 bug 报告
- 提出新功能建议
- 改进文档
- 提交代码修复或新功能

## 如何贡献

### 报告问题

如果你发现了 bug 或有改进建议，请通过 [GitHub Issues](https://github.com/iamme19862002/macos-computer-use/issues) 提交。

提交问题时，请尽可能提供以下信息：

- **问题描述** - 清晰描述发生了什么
- **复现步骤** - 如何重现这个问题
- **预期行为** - 你期望发生什么
- **实际行为** - 实际发生了什么
- **环境信息** - macOS 版本、Swift 版本等
- **截图/日志** - 如果有的话

### 提交代码

1. **Fork 仓库**
   ```bash
   git clone https://github.com/iamme19862002/macos-computer-use.git
   cd macos-computer-use
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **进行更改**
   - 编写清晰的代码
   - 遵循现有的代码风格
   - 添加必要的注释
   - 更新相关文档

4. **测试你的更改**
   ```bash
   swift build
   swift test
   ```

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 描述你的更改"
   ```

   提交信息格式遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/)：
   - `feat:` - 新功能
   - `fix:` - 修复 bug
   - `docs:` - 文档更新
   - `style:` - 代码格式（不影响功能）
   - `refactor:` - 代码重构
   - `perf:` - 性能优化
   - `test:` - 测试相关
   - `chore:` - 构建/工具相关

6. **推送到你的 Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 描述你的更改
   - 关联相关的 Issue（如果有）

## 代码规范

### Swift 代码风格

- 使用 4 个空格缩进
- 类/结构体名使用 PascalCase
- 函数/变量名使用 camelCase
- 常量使用大写 snake_case
- 添加适当的访问控制修饰符

### 文件头注释

所有 Swift 文件都应包含文件头注释：

```swift
//
//  文件名.swift
//  macos-computer-use
//
//  Created by 作者名 on 年份.
//  Copyright (c) 年份 作者名. All rights reserved.
//  Licensed under the MIT License.
//
```

### 文档注释

公共 API 应使用 Swift 文档注释格式：

```swift
/// 功能描述
/// - Parameters:
///   - param1: 参数1描述
///   - param2: 参数2描述
/// - Returns: 返回值描述
func myFunction(param1: String, param2: Int) -> Bool {
    // ...
}
```

## 开发环境设置

### 要求

- macOS 14.0+
- Xcode 15.0+ 或 Swift 5.9+
- Git

### 构建项目

```bash
# 调试构建
swift build

# 发布构建
swift build -c release

# 运行测试
swift test
```

### 安装本地版本

```bash
swift build -c release
cp .build/release/macos-computer-use /usr/local/bin/
```

## 发布流程

维护者请遵循以下发布流程：

1. 更新 `CHANGELOG.md`
2. 更新版本号（在 `main.swift` 中）
3. 创建 git tag
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
4. 在 GitHub 上创建 Release

## 行为准则

参与本项目即表示你同意遵守以下准则：

- 尊重所有参与者
- 欢迎新人和不同观点
- 专注于建设性反馈
- 避免攻击性或歧视性语言

## 获取帮助

如果你有任何问题，可以通过以下方式获取帮助：

- 查看 [README.md](README.md)
- 搜索 [GitHub Issues](https://github.com/iamme19862002/macos-computer-use/issues)
- 创建新的 Issue

## 许可证

通过贡献代码，你同意你的贡献将在 [MIT 许可证](LICENSE) 下发布。

---

再次感谢你的贡献！🎉
