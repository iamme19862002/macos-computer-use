---
name: "git-flow-guide"
description: "Provides Git Flow workflow guidance, branch management, commit conventions, and release procedures. Invoke when user asks about Git workflow, branching strategy, commit standards, or release management."
---

# Git Flow 开发规范指南

## 概述

本规范基于 [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) 分支模型，适用于开源项目的版本管理和协作开发。

## 分支模型

### 长期分支

| 分支 | 说明 | 保护规则 |
|------|------|----------|
| `main` | 生产环境代码，永远可部署 | ✅ 禁止直接推送，需 PR 合并 |
| `develop` | 开发集成分支，包含最新功能 | ✅ 禁止直接推送，需 PR 合并 |

### 临时分支

| 分支前缀 | 用途 | 来源分支 | 合并目标 |
|----------|------|----------|----------|
| `feature/*` | 新功能开发 | `develop` | `develop` |
| `bugfix/*` | Bug 修复 | `develop` | `develop` |
| `release/*` | 版本发布准备 | `develop` | `main` + `develop` |
| `hotfix/*` | 生产环境紧急修复 | `main` | `main` + `develop` |

## 分支命名规范

```
feature/user-authentication
feature/api-rate-limiting
bugfix/memory-leak-in-cache
release/v1.2.0
hotfix/security-vulnerability-fix
```

## 提交信息规范 (Conventional Commits)

### 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型 (Type)

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(api): add user login endpoint` |
| `fix` | Bug 修复 | `fix(ui): resolve button alignment issue` |
| `docs` | 文档更新 | `docs(readme): update installation guide` |
| `style` | 代码格式（不影响功能） | `style: format with swift-format` |
| `refactor` | 代码重构 | `refactor(core): simplify error handling` |
| `perf` | 性能优化 | `perf(query): optimize database index` |
| `test` | 测试相关 | `test(auth): add login unit tests` |
| `chore` | 构建/工具/依赖 | `chore(deps): update dependency versions` |
| `ci` | CI/CD 配置 | `ci(github): add automated testing` |
| `revert` | 回滚提交 | `revert: revert "feat: add new feature"` |

### 范围 (Scope)

可选，表示影响的模块或组件：

- `api` - API 接口
- `ui` - 用户界面
- `core` - 核心功能
- `cli` - 命令行工具
- `docs` - 文档
- `deps` - 依赖
- `ci` - 持续集成

### 主题 (Subject)

- 使用祈使句，现在时态
- 首字母小写
- 不加句号结尾
- 不超过 50 个字符

### 正文 (Body)

- 详细描述变更原因和实现方式
- 每行不超过 72 个字符
- 使用空行分隔段落

### 页脚 (Footer)

- 引用 Issue：`Closes #123`, `Fixes #456`
- 破坏性变更：`BREAKING CHANGE: description`

### 完整示例

```
feat(api): add OAuth2 authentication support

Implement OAuth2 flow for third-party integrations.
Supports Google, GitHub, and Apple sign-in.

- Add OAuth2 provider configuration
- Implement token exchange endpoint
- Add user profile synchronization

Closes #234
BREAKING CHANGE: auth token format changed from JWT to opaque tokens
```

## 开发流程

### 1. 开始新功能

```bash
# 从 develop 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/my-new-feature

# 开发完成后提交
git add .
git commit -m "feat(scope): add new feature"

# 推送并创建 PR
git push origin feature/my-new-feature
# 在 GitHub/Gitee 创建 PR 合并到 develop
```

### 2. 修复 Bug

```bash
# 从 develop 创建修复分支
git checkout develop
git pull origin develop
git checkout -b bugfix/fix-memory-leak

# 修复后提交
git commit -m "fix(core): resolve memory leak in cache manager"

# 推送并创建 PR
git push origin bugfix/fix-memory-leak
```

### 3. 发布版本

```bash
# 从 develop 创建发布分支
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# 版本准备（更新版本号、CHANGELOG 等）
git commit -m "chore(release): prepare v1.2.0"

# 合并到 main
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# 合并回 develop
git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop

# 删除发布分支
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### 4. 紧急修复 (Hotfix)

```bash
# 从 main 创建热修复分支
git checkout main
git pull origin main
git checkout -b hotfix/fix-security-issue

# 修复后提交
git commit -m "fix(security): patch SQL injection vulnerability"

# 合并到 main 和 develop
git checkout main
git merge --no-ff hotfix/fix-security-issue
git tag -a v1.2.1 -m "Hotfix version 1.2.1"
git push origin main --tags

git checkout develop
git merge --no-ff hotfix/fix-security-issue
git push origin develop

# 删除热修复分支
git branch -d hotfix/fix-security-issue
```

## Pull Request 规范

### PR 标题格式

```
[<type>] <description>
```

示例：
- `[feat] Add user authentication system`
- `[fix] Resolve memory leak in cache`
- `[docs] Update API documentation`

### PR 描述模板

```markdown
## 变更内容
<!-- 描述本次 PR 的主要变更 -->

## 相关 Issue
<!-- 关联的 Issue 编号，如 Closes #123 -->

## 测试说明
<!-- 如何测试这些变更 -->

## 检查清单
- [ ] 代码遵循项目规范
- [ ] 添加/更新了测试
- [ ] 更新了文档
- [ ] 通过了所有测试
- [ ] 没有引入破坏性变更（如有请说明）
```

### 代码审查要求

- 至少 1 名维护者审查通过
- 所有 CI 检查通过
- 解决所有审查意见
- 保持提交历史整洁（必要时 squash）

## 版本号规范 (SemVer)

采用 [语义化版本](https://semver.org/lang/zh-CN/)：

```
主版本号.次版本号.修订号
```

| 版本变化 | 触发条件 | 示例 |
|----------|----------|------|
| 主版本号 (MAJOR) | 不兼容的 API 变更 | `1.0.0` → `2.0.0` |
| 次版本号 (MINOR) | 向下兼容的功能新增 | `1.0.0` → `1.1.0` |
| 修订号 (PATCH) | 向下兼容的问题修复 | `1.0.0` → `1.0.1` |

### 预发布版本

```
1.0.0-alpha.1
1.0.0-beta.2
1.0.0-rc.1
```

## CHANGELOG 规范

采用 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 格式：

```markdown
## [1.2.0] - 2026-05-21

### Added
- 新增用户认证系统
- 支持 OAuth2 登录

### Changed
- 优化数据库查询性能

### Fixed
- 修复内存泄漏问题
- 修复并发访问 bug

### Deprecated
- 废弃旧版 API v1

### Removed
- 移除不再使用的配置项

### Security
- 修复 SQL 注入漏洞
```

## 常用 Git 命令速查

```bash
# 查看分支状态
git status

# 查看提交历史
git log --oneline --graph --all

# 查看某个文件的修改历史
git log -p <file>

# 撤销未暂存的修改
git checkout -- <file>

# 撤销已暂存的修改
git reset HEAD <file>

# 修改最后一次提交
git commit --amend

# 交互式 rebase（整理提交历史）
git rebase -i HEAD~3

# 查看远程分支
git branch -r

# 清理已删除的远程分支
git fetch --prune

# 查看标签
git tag -l

# 推送所有标签
git push origin --tags
```

## 最佳实践

1. **频繁提交** - 小步快跑，每次提交一个逻辑单元
2. **写清楚提交信息** - 让其他人（和未来的自己）能理解变更原因
3. **及时拉取更新** - 开发前先从远程拉取最新代码
4. **解决冲突本地** - 在推送前解决所有合并冲突
5. **保护主分支** - 禁止直接推送 main/develop
6. **代码审查** - 所有变更都需要审查
7. **自动化测试** - CI 通过后才能合并
8. **版本标签** - 每个发布版本都要打标签
