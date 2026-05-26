---
name: "macos-computer-use-dev-workflow"
description: "macos-computer-use 项目开发规范指南，涵盖 Git Flow 分支管理、版本号规范、CHANGELOG 维护、文档同步等全流程。在开发新功能、修复 Bug、发布版本、更新文档时必须调用此 skill。"
---

# macos-computer-use 开发规范指南

## 概述

本规范确保 macos-computer-use 项目的开发流程标准化，包括代码管理、版本控制、文档维护等方面的一致性。

---

## 一、Git Flow 分支管理规范

### 1.1 分支模型

#### 长期分支（受保护）

| 分支 | 用途 | 保护规则 |
|------|------|----------|
| `main` | 生产环境代码，永远可部署 | 禁止直接推送，需通过 PR/合并请求 |
| `develop` | 开发集成分支，包含最新功能 | 禁止直接推送，需通过 PR/合并请求 |

#### 临时分支

| 分支前缀 | 用途 | 来源分支 | 合并目标 | 命名示例 |
|----------|------|----------|----------|----------|
| `feature/*` | 新功能开发 | `develop` | `develop` | `feature/add-screenshot-command` |
| `bugfix/*` | Bug 修复（非紧急） | `develop` | `develop` | `bugfix/fix-element-click-chinese` |
| `release/*` | 版本发布准备 | `develop` | `main` + `develop` | `release/v3.4.0` |
| `hotfix/*` | 生产环境紧急修复 | `main` | `main` + `develop` | `hotfix/fix-security-issue` |

### 1.2 开发流程

#### 新功能开发流程

```bash
# 1. 从 develop 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/<feature-name>

# 2. 开发并提交（遵循提交规范）
git add .
git commit -m "feat(scope): description"

# 3. 推送并创建 PR
git push origin feature/<feature-name>
# 在 GitHub/Gitee 创建 PR 合并到 develop
```

#### Bug 修复流程

```bash
# 1. 从 develop 创建修复分支
git checkout develop
git pull origin develop
git checkout -b bugfix/<bug-description>

# 2. 修复并提交
git add .
git commit -m "fix(scope): description"

# 3. 推送到远程
git push origin bugfix/<bug-description>
```

#### 紧急热修复流程（Hotfix）

```bash
# 1. 从 main 创建热修复分支
git checkout main
git pull origin main
git checkout -b hotfix/<description>

# 2. 修复并提交
git add .
git commit -m "fix(scope): description"

# 3. 合并到 main 和 develop
git checkout main
git merge --no-ff hotfix/<description>
git tag -a v<version> -m "Hotfix version <version>"
git push origin main --tags

git checkout develop
git merge --no-ff hotfix/<description>
git push origin develop

# 4. 删除热修复分支
git branch -d hotfix/<description>
git push origin --delete hotfix/<description>
```

---

## 二、提交信息规范（Conventional Commits）

### 2.1 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 2.2 类型（Type）

| 类型 | 用途 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(screenshot): add --app parameter` |
| `fix` | Bug 修复 | `fix(element): fix Chinese title matching` |
| `docs` | 文档更新 | `docs(readme): update API examples` |
| `style` | 代码格式（不影响功能） | `style: format with swift-format` |
| `refactor` | 代码重构 | `refactor(core): simplify error handling` |
| `perf` | 性能优化 | `perf(screenshot): optimize capture speed` |
| `test` | 测试相关 | `test(keyboard): add unit tests` |
| `chore` | 构建/工具/依赖 | `chore(deps): update dependency versions` |
| `ci` | CI/CD 配置 | `ci(github): add automated testing` |
| `revert` | 回滚提交 | `revert: revert "feat: add new feature"` |

### 2.3 范围（Scope）

常用范围：
- `screenshot` - 截图相关
- `element` - UI 元素操作
- `keyboard` - 键盘控制
- `mouse` - 鼠标控制
- `cli` - 命令行接口
- `docs` - 文档
- `core` - 核心功能
- `test` - 测试

### 2.4 主题（Subject）规范

- 使用祈使句，现在时态
- 首字母小写
- 不加句号结尾
- 不超过 50 个字符
- 清晰描述变更内容

### 2.5 完整示例

```
feat(screenshot): add --app parameter for window capture

Add support for capturing specific application windows using
the --app parameter. This allows users to screenshot windows
by app name or bundle ID.

- Add findWindowId() helper function
- Update ScreenshotCommand to accept --app option
- Update documentation with examples

Closes #123
```

---

## 三、版本号规范（SemVer）

### 3.1 格式

```
主版本号.次版本号.修订号[-预发布标识]
```

示例：`3.4.0`, `3.4.1-beta.1`, `3.5.0-alpha.2`

### 3.2 版本递增规则

| 版本变化 | 触发条件 | 示例 |
|----------|----------|------|
| **MAJOR** | 不兼容的 API 变更 | `3.x.x` → `4.0.0` |
| **MINOR** | 向下兼容的功能新增 | `3.4.x` → `3.5.0` |
| **PATCH** | 向下兼容的问题修复 | `3.4.1` → `3.4.2` |

### 3.3 预发布版本

```
3.5.0-alpha.1  # 内部测试版
3.5.0-beta.2   # 公开测试版
3.5.0-rc.1     # 发布候选版
```

### 3.4 版本号更新时机

- **开发阶段**：在 `release/*` 分支上确定版本号
- **发布时**：在合并到 `main` 分支时打 tag
- **版本文件**：同步更新 `Sources/macos-computer-use/main.swift` 中的版本常量

---

## 四、CHANGELOG 维护规范

### 4.1 格式

采用 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 格式：

```markdown
## [未发布]

### Added
- 新增功能描述

### Changed
- 变更描述

### Deprecated
- 废弃功能描述

### Removed
- 移除功能描述

### Fixed
- 修复描述

### Security
- 安全修复描述

## [3.4.0] - 2026-05-25

### Added
- 新增 screenshot --app 参数支持

### Fixed
- 修复 element-click 中文标题匹配问题
```

### 4.2 维护规则

1. **每个 PR/合并必须更新 CHANGELOG.md**
2. **在 `[未发布]` 部分添加变更记录**
3. **发布时添加日期和版本号**
4. **按类别分组（Added/Changed/Fixed 等）**
5. **保持最新的在顶部**

### 4.3 更新时机

| 场景 | 操作 |
|------|------|
| 开发新功能 | 在 `[未发布]` 的 `### Added` 下添加 |
| 修复 Bug | 在 `[未发布]` 的 `### Fixed` 下添加 |
| 重构代码 | 在 `[未发布]` 的 `### Changed` 下添加 |
| 废弃功能 | 在 `[未发布]` 的 `### Deprecated` 下添加 |
| 发布版本 | 将 `[未发布]` 改为 `[版本号] - 日期`，新增空的 `[未发布]` |

---

## 五、文档同步规范

### 5.1 必须同步更新的文档

当进行以下变更时，必须同步更新相关文档：

| 变更类型 | 必须更新的文档 | 可选更新的文档 |
|----------|---------------|---------------|
| 新增命令 | README.md, 命令参考手册.md | 智能体实战指南.md |
| 修改命令参数 | 命令参考手册.md, README.md | - |
| 修复 Bug | CHANGELOG.md | - |
| 新增功能示例 | 智能体实战指南.md, 提效实战指南.md | README.md |
| 修改 API 行为 | 命令参考手册.md, README.md | - |
| 性能优化 | CHANGELOG.md | README.md |

### 5.2 文档更新检查清单

每个 PR 必须检查：

- [ ] README.md 中的命令示例是否正确
- [ ] 命令参考手册.md 中的命令说明是否更新
- [ ] 命令速查表是否包含新增/修改的命令
- [ ] CHANGELOG.md 是否记录变更
- [ ] 实战指南中的代码示例是否仍然有效

### 5.3 文档命名规范

- 使用简体中文命名文档文件
- 文档存放在 `docs/` 目录
- 主要文档：
  - `docs/命令参考手册.md` - 完整命令说明
  - `docs/智能体实战指南.md` - AI Agent 使用场景
  - `docs/提效实战指南.md` - 日常提效场景

---

## 六、测试规范

### 6.1 测试类型

| 测试类型 | 范围 | 必须性 |
|----------|------|--------|
| 单元测试 | 核心工具类（KeyMap, KeyboardController 等） | 必须 |
| 编译测试 | `swift build` 通过 | 必须 |
| 功能测试 | 实际运行命令验证 | 推荐 |
| 集成测试 | 多命令组合场景 | 推荐 |

### 6.2 测试命令

```bash
# 编译测试
swift build

# 单元测试
swift test

# 功能测试（示例）
.build/debug/macos-computer-use key --key "return" --json
.build/debug/macos-computer-use drag --start-x 100 --start-y 100 --to-x 200 --to-y 200 --json
```

### 6.3 测试通过标准

- 编译无错误（警告可以接受）
- 单元测试全部通过
- 新增功能必须通过功能测试验证

---

## 七、发布流程

### 7.1 发布前检查清单

- [ ] 所有功能已合并到 `develop`
- [ ] CHANGELOG.md 已更新
- [ ] 版本号已确定
- [ ] 文档已同步更新
- [ ] 所有测试通过
- [ ] 无已知严重 Bug

### 7.2 发布步骤

```bash
# 1. 从 develop 创建 release 分支
git checkout develop
git pull origin develop
git checkout -b release/v3.4.0

# 2. 版本准备（更新版本号、CHANGELOG 日期等）
# 编辑 Sources/macos-computer-use/main.swift 中的版本号
# 编辑 CHANGELOG.md 添加发布日期

git add .
git commit -m "chore(release): prepare v3.4.0"

# 3. 合并到 main
git checkout main
git merge --no-ff release/v3.4.0 -m "release(v3.4.0): release version 3.4.0"
git tag -a v3.4.0 -m "Release version 3.4.0"
git push origin main --tags

# 4. 合并回 develop
git checkout develop
git merge --no-ff release/v3.4.0 -m "chore(release): merge v3.4.0 back to develop"
git push origin develop

# 5. 删除 release 分支
git branch -d release/v3.4.0
git push origin --delete release/v3.4.0
```

### 7.3 发布后操作

- 在 GitHub/Gitee 创建 Release 说明
- 更新 README.md 中的版本徽章（如需要）
- 通知相关方新版本发布

---

## 八、代码审查清单

### 8.1 审查要点

- [ ] 代码符合 Swift 风格规范
- [ ] 提交信息符合 Conventional Commits
- [ ] 分支命名符合 Git Flow 规范
- [ ] CHANGELOG.md 已更新
- [ ] 相关文档已同步更新
- [ ] 新增功能有测试覆盖
- [ ] 无敏感信息泄露
- [ ] 无调试代码遗留

### 8.2 禁止事项

- 禁止直接向 `main` 或 `develop` 推送代码
- 禁止在提交信息中使用非英文（除非是特定术语）
- 禁止提交包含敏感信息（API Key、密码等）的代码
- 禁止跳过测试直接合并

---

## 九、快速参考

### 9.1 常用命令速查

```bash
# 开始新功能
git checkout develop && git pull && git checkout -b feature/name

# 修复 Bug
git checkout develop && git pull && git checkout -b bugfix/name

# 提交规范
git commit -m "feat(scope): description"
git commit -m "fix(scope): description"
git commit -m "docs(scope): description"

# 推送分支
git push origin branch-name

# 合并到 develop
git checkout develop && git merge --no-ff feature/name

# 打标签
git tag -a v3.4.0 -m "Release version 3.4.0"
git push origin --tags
```

### 9.2 版本号决策流程

```
有破坏性变更？
  ├─ 是 → MAJOR + 1 (3.4.0 → 4.0.0)
  └─ 否 → 有新增功能？
           ├─ 是 → MINOR + 1 (3.4.0 → 3.5.0)
           └─ 否 → PATCH + 1 (3.4.0 → 3.4.1)
```

---

## 十、示例：完整开发流程

### 场景：新增 screenshot --app 参数

```bash
# 1. 创建分支
git checkout develop
git pull origin develop
git checkout -b feature/screenshot-app-param

# 2. 开发代码
# 编辑 ScreenshotCommand.swift
# 编辑 ScreenshotTool.swift

# 3. 更新文档
# 编辑 docs/命令参考手册.md
# 编辑 README.md

# 4. 更新 CHANGELOG
echo "### Added
- 新增 screenshot --app 参数支持应用窗口截图" >> CHANGELOG.md

# 5. 测试
swift build
swift test
.build/debug/macos-computer-use screenshot --app "Safari" --json

# 6. 提交
git add .
git commit -m "feat(screenshot): add --app parameter for window capture

Add support for capturing specific application windows using
the --app parameter.

- Add findWindowId() helper function in ScreenshotTool
- Update ScreenshotCommand to accept --app option
- Update documentation with examples
- Update CHANGELOG.md"

# 7. 推送
git push origin feature/screenshot-app-param

# 8. 创建 PR 合并到 develop
# 在 GitHub/Gitee 上操作

# 9. 合并后删除分支
git checkout develop
git branch -d feature/screenshot-app-param
```

---

## 总结

遵循本规范可以确保：

1. **代码管理清晰** - Git Flow 分支模型保证代码质量
2. **版本控制规范** - SemVer 版本号让用户了解变更影响
3. **变更可追溯** - CHANGELOG 记录完整变更历史
4. **文档一致性** - 文档与代码同步更新，避免信息过时
5. **协作高效** - 标准化流程减少沟通成本

**核心原则：任何代码变更都必须伴随相应的文档和 CHANGELOG 更新。**
