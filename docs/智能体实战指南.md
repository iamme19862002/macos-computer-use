# AI Agent 实战指南

> 本指南面向 AI Agent 开发者，展示如何利用 macos-computer-use 完成智能化 UI 自动化。

## 目录

- [核心价值](#核心价值)
- [使用模式](#使用模式)
- [实战场景](#实战场景)
- [Python 工具库](#python-工具库)
- [最佳实践](#最佳实践)
- [故障排除](#故障排除)

---

## 核心价值

### 为什么 AI Agent 需要这个工具？

| 传统方案 | macos-computer-use |
|----------|-------------------|
| 调用远程 API（消耗 Token） | 本地执行（零 Token） |
| 只能获取文本（无法操作 UI） | 直接控制鼠标、键盘、应用 |
| 无法读写本地文件 | 完整的文件系统操作 |
| 无法感知当前状态 | 前台应用/焦点元素检测 |
| 无法验证操作结果 | 断言验证（OCR + 元素检查） |
| 单步执行无容错 | 重试、等待、条件判断 |

### Agent 能力增强

```
Before: Agent 只能"建议"用户操作
After:  Agent 直接"执行"并"验证"操作
```

---

## 使用模式

### 模式 1：观察-思考-行动循环

```python
def agent_observe_think_act(task):
    while not task.completed:
        # 1. 观察：截图 + OCR
        screenshot = execute("macos-computer-use screenshot --output current.png")
        ocr_result = execute("macos-computer-use ocr --format json")
        
        # 2. 思考：分析状态并决策
        action = llm_decide(ocr_result, task)
        
        # 3. 行动：执行操作
        execute(action.command)
        
        # 4. 验证：断言检查
        if action.needs_verify:
            result = execute(action.verify_command)
            if not result.success:
                continue  # 重试
```

### 模式 2：自动化测试执行器

```python
def run_test_suite(test_cases):
    results = []
    for case in test_cases:
        execute(f"macos-computer-use test-start --name '{case.name}' --id '{case.id}'")
        
        for step in case.steps:
            execute(f"macos-computer-use step --name '{step.name}'")
            try:
                output = execute(step.command)
                step.result = "PASS"
            except:
                execute("macos-computer-use screenshot --output error.png")
                step.result = "FAIL"
                break
        
        result = "PASS" if all(s.result == "PASS" for s in case.steps) else "FAIL"
        execute(f"macos-computer-use test-end --result {result}")
        results.append({"case": case.name, "result": result})
    
    return results
```

### 模式 3：自我修复工作流

```python
def self_healing_workflow():
    # 尝试操作，失败自动恢复
    try:
        execute("macos-computer-use app-activate --app Safari")
    except:
        execute("macos-computer-use app-launch --app Safari")
        execute("macos-computer-use wait-for-app --app Safari --timeout 10")
    
    # 使用重试处理不稳定操作
    execute("""
        macos-computer-use retry --attempts 5 --interval 2 
        --command "click --app Safari --target '刷新按钮'"
    """)
```

---

## 实战场景

### 场景 1：智能网页数据抓取

```bash
#!/bin/bash
# Agent 自动抓取网页数据

echo "=== 智能数据抓取 ==="

# 1. 启动浏览器
macos-computer-use app-launch --app Safari
macos-computer-use wait-for-app --app Safari --timeout 10

# 2. 导航到目标网站
macos-computer-use type --app Safari --target "地址栏" --text "https://news.ycombinator.com" --submit
macos-computer-use assert-text-exists --app Safari --text "Hacker News" --timeout 10

# 3. 滚动加载更多内容
for i in {1..3}; do
    macos-computer-use scroll --app Safari --target "页面内容" --delta-y -800
    macos-computer-use sleep --seconds 1
done

# 4. OCR 识别标题
macos-computer-use ocr --app Safari --format json > /tmp/hn_titles.json

# 5. 分析并点击感兴趣的文章
# Agent 解析 JSON，找到包含 "AI" 或 "Machine Learning" 的标题
# 然后点击对应位置

# 6. 截图保存结果
macos-computer-use screenshot --app Safari --output hackernews.png

echo "=== 抓取完成 ==="
```

### 场景 2：自动化软件测试

```bash
#!/bin/bash
# 完整的自动化测试套件

set -e

echo "=== 软件自动化测试 ==="

# 测试 1：登录功能
macos-computer-use test-start --name "登录功能测试" --id "TC001"

macos-computer-use step --name "启动应用"
macos-computer-use app-launch --app "MyApp"
macos-computer-use wait-for-app --app "MyApp" --timeout 10

macos-computer-use step --name "验证登录界面"
macos-computer-use assert-element-exists --app "MyApp" --title "用户名" --timeout 5
macos-computer-use assert-element-exists --app "MyApp" --title "密码"

macos-computer-use step --name "输入正确凭据"
macos-computer-use type --app "MyApp" --target "用户名" --text "admin" --clear
macos-computer-use type --app "MyApp" --target "密码" --text "password123" --clear

macos-computer-use step --name "点击登录"
macos-computer-use click --app "MyApp" --target "登录"

macos-computer-use step --name "验证登录成功"
macos-computer-use assert-text-exists --app "MyApp" --text "欢迎回来" --timeout 5

macos-computer-use test-end --result pass

# 测试 2：表单验证
macos-computer-use test-start --name "表单验证测试" --id "TC002"

macos-computer-use step --name "清空用户名"
macos-computer-use type --app "MyApp" --target "用户名" --text "" --clear

macos-computer-use step --name "点击登录"
macos-computer-use click --app "MyApp" --target "登录"

macos-computer-use step --name "验证错误提示"
macos-computer-use assert-text-exists --app "MyApp" --text "用户名不能为空" --timeout 3

macos-computer-use test-end --result pass

# 测试 3：窗口管理
macos-computer-use test-start --name "窗口管理测试" --id "TC003"

macos-computer-use step --name "最大化窗口"
macos-computer-use window-maximize --app "MyApp"

macos-computer-use step --name "截图验证"
macos-computer-use screenshot --app "MyApp" --output maximized.png

macos-computer-use test-end --result pass

# 清理
macos-computer-use app-quit --app "MyApp"

echo "=== 所有测试通过 ==="
```

### 场景 3：跨应用数据迁移

```bash
#!/bin/bash
# 从 Excel 迁移数据到 Web 表单

echo "=== 跨应用数据迁移 ==="

# 1. 打开 Excel 并复制数据
macos-computer-use app-activate --app "Microsoft Excel"
macos-computer-use click --app "Microsoft Excel" --target "A1"
macos-computer-use hotkey --keys command+c

# 验证复制成功
macos-computer-use assert-clipboard --not-empty

# 2. 切换到浏览器
macos-computer-use app-activate --app Safari
macos-computer-use click --app Safari --target "数据输入框"
macos-computer-use clipboard-paste

# 3. 提交表单
macos-computer-use click --app Safari --target "提交"

# 4. 验证提交成功
macos-computer-use assert-text-exists --app Safari --text "提交成功" --timeout 5

# 5. 返回 Excel，标记已完成
macos-computer-use app-activate --app "Microsoft Excel"
macos-computer-use type --app "Microsoft Excel" --target "B1" --text "已迁移"

echo "=== 迁移完成 ==="
```

### 场景 4：自动化报告生成

```bash
#!/bin/bash
# 自动生成日报

echo "=== 自动化日报生成 ==="

# 1. 打开数据源
macos-computer-use app-launch --app Safari
macos-computer-use wait-for-app --app Safari --timeout 10

# 2. 访问数据看板
macos-computer-use type --app Safari --target "地址栏" --text "https://dashboard.company.com" --submit
macos-computer-use assert-text-exists --app Safari --text "Dashboard" --timeout 10

# 3. 截图关键指标
macos-computer-use screenshot --app Safari --output /tmp/metrics.png

# 4. 打开邮件客户端
macos-computer-use app-activate --app "Mail"

# 5. 创建新邮件
macos-computer-use hotkey --keys command+n

# 6. 填写邮件内容
macos-computer-use type --app "Mail" --target "收件人" --text "team@company.com"
macos-computer-use hotkey --keys tab
macos-computer-use type --app "Mail" --target "主题" --text "每日数据报告 - $(date +%Y-%m-%d)"
macos-computer-use hotkey --keys tab
macos-computer-use type --app "Mail" --target "正文" --text "请查看附件中的今日数据指标。"

# 7. 附加截图
# （拖拽截图到邮件）
macos-computer-use drag --from-x 100 --from-y 100 --to-x 500 --to-y 500

# 8. 发送邮件
macos-computer-use hotkey --keys command+return

echo "=== 日报已发送 ==="
```

### 场景 5：智能客服自动化

```bash
#!/bin/bash
# 自动处理客服工单

echo "=== 智能客服处理 ==="

while true; do
    # 1. 刷新工单列表
    macos-computer-use app-activate --app Safari
    macos-computer-use hotkey --keys command+r
    macos-computer-use sleep --seconds 3
    
    # 2. OCR 检查新工单
    macos-computer-use ocr --app Safari --format json > /tmp/tickets.json
    
    # 3. Agent 分析工单内容
    # 如果有"紧急"标记的工单
    if macos-computer-use assert-text-exists --app Safari --text "紧急" --timeout 1; then
        echo "发现紧急工单"
        
        # 4. 点击工单
        macos-computer-use click --app Safari --target "紧急工单"
        macos-computer-use sleep --seconds 2
        
        # 5. 查看详情并截图
        macos-computer-use screenshot --app Safari --output /tmp/urgent_ticket.png
        
        # 6. 发送通知给主管
        macos-computer-use app-activate --app "Slack"
        macos-computer-use click --app "Slack" --target "主管频道"
        macos-computer-use type --app "Slack" --target "消息输入" --text "发现紧急工单，请查看截图"
        macos-computer-use hotkey --keys return
    fi
    
    # 7. 等待一段时间后再次检查
    macos-computer-use sleep --seconds 30
done
```

### 场景 6：自动化开发环境配置

```bash
#!/bin/bash
# 为新项目自动配置开发环境

echo "=== 开发环境自动配置 ==="

# 1. 创建项目目录（使用文件系统命令）
macos-computer-use file-write ~/Projects/new-project/.gitkeep --text "" --create-dirs

# 2. 初始化 Git
macos-computer-use app-launch --app Terminal
macos-computer-use wait-for-app --app Terminal --timeout 5
macos-computer-use type --app Terminal --text "cd ~/Projects/new-project && git init"
macos-computer-use key --app Terminal --key return

# 3. 创建 README（使用文件系统命令）
macos-computer-use file-write ~/Projects/new-project/README.md --text "# New Project\n\nProject description here."

# 4. 创建初始文件
macos-computer-use file-write ~/Projects/new-project/index.js --text "console.log('Hello World');"

# 5. 打开 VS Code
macos-computer-use app-launch --app "Visual Studio Code"
macos-computer-use wait-for-app --app "Visual Studio Code" --timeout 10

# 6. 打开项目文件夹
macos-computer-use hotkey --keys command+o
macos-computer-use sleep --seconds 1
macos-computer-use type --text "~/Projects/new-project"
macos-computer-use key --key return

# 7. 验证文件创建成功
macos-computer-use file-exists ~/Projects/new-project/README.md
macos-computer-use dir-list ~/Projects/new-project

# 8. 打开浏览器查看文档
macos-computer-use app-launch --app Safari
macos-computer-use type --app Safari --target "地址栏" --text "https://docs.example.com" --submit

echo "=== 环境配置完成 ==="
```

### 场景 7：智能文件处理工作流

```bash
#!/bin/bash
# 自动读取配置文件、处理数据、写入结果

echo "=== 智能文件处理 ==="

# 1. 检查配置文件是否存在
if ! macos-computer-use file-exists ~/config.json; then
    echo "配置文件不存在，创建默认配置"
    macos-computer-use file-write ~/config.json --text '{"api_url": "https://api.example.com", "timeout": 30}'
fi

# 2. 读取配置文件
config=$(macos-computer-use file-read ~/config.json --json)
echo "配置内容: $config"

# 3. 获取当前前台应用信息
app_info=$(macos-computer-use frontmost-app --json)
echo "当前应用: $app_info"

# 4. 获取焦点元素信息
focused=$(macos-computer-use focused-element --json)
echo "焦点元素: $focused"

# 5. 处理数据并写入日志
macos-computer-use file-write ~/process.log --text "[$(date)] 处理完成\n" --append

# 6. 列出工作目录
macos-computer-use dir-list ~/Documents --json

echo "=== 文件处理完成 ==="
```

### 场景 8：浏览器自动化数据抓取

```python
#!/usr/bin/env python3
# 使用浏览器控制命令进行网页数据抓取

from macos_computer_use import MacOSComputerUse

mcu = MacOSComputerUse()

# 1. 导航到目标网站
mcu.browser_navigate("https://example.com/data")

# 2. 等待页面加载
mcu.sleep(3)

# 3. 获取当前 URL 确认导航成功
url = mcu.browser_get_url()
print(f"当前页面: {url}")

# 4. 执行 JavaScript 获取数据
title = mcu.browser_exec_js("document.title")
print(f"页面标题: {title}")

# 5. 提取页面数据
data = mcu.browser_exec_js("JSON.stringify(Array.from(document.querySelectorAll('tr')).map(r => r.innerText))")
print(f"表格数据: {data}")

# 6. 保存到文件
mcu.file_write("~/scraped_data.json", text=data)

# 7. 关闭浏览器标签页
mcu.browser_close_tab()
```

### 场景 9：弹窗检测与自动处理

```bash
#!/bin/bash
# 自动化流程中检测并处理系统弹窗

echo "=== 弹窗检测与处理 ==="

# 1. 启动可能触发弹窗的操作
macos-computer-use app-launch --app Safari

# 2. 等待并检测弹窗
sleep 2
result=$(macos-computer-use dialog-detect --json)
if echo "$result" | grep -q '"detected":true'; then
    echo "检测到弹窗，尝试自动关闭"
    macos-computer-use dialog-dismiss --escape
fi

# 3. 继续主流程
macos-computer-use browser-navigate https://example.com

# 4. 循环检测弹窗（权限弹窗可能延迟出现）
for i in {1..5}; do
    sleep 1
    dialog=$(macos-computer-use dialog-detect --title "权限" --json)
    if echo "$dialog" | grep -q '"detected":true'; then
        echo "检测到权限弹窗，点击不允许"
        macos-computer-use dialog-dismiss --click "不允许"
        break
    fi
done

echo "=== 弹窗处理完成 ==="
```

### 场景 10：AppleScript 扩展自动化

```bash
#!/bin/bash
# 使用 AppleScript 扩展自动化能力

# 1. 获取系统信息
macos-computer-use osascript 'return system version of (system info)'

# 2. 控制 iTunes/音乐应用
macos-computer-use osascript 'tell application "Music" to play'

# 3. 使用 JXA 操作复杂对象
macos-computer-use osascript 'Application("Finder").desktop.items()[0].name()' --language javascript

# 4. 发送系统通知
macos-computer-use osascript 'display notification "任务完成" with title "自动化"'
```

---

## Python 工具库

### 完整工具类

```python
import subprocess
import json
import time
from typing import Optional, Dict, Any, List

class MacOSComputerUse:
    """macos-computer-use Python 封装"""
    
    def __init__(self, json_output: bool = True):
        self.json_output = json_output
    
    def _execute(self, command: str) -> Dict[str, Any]:
        """执行命令并解析结果"""
        full_command = f"macos-computer-use {command}"
        if self.json_output and "--json" not in command:
            full_command += " --json"
        
        result = subprocess.run(
            full_command.split(),
            capture_output=True,
            text=True
        )
        
        try:
            output = json.loads(result.stdout)
            output["exit_code"] = result.returncode
            return output
        except json.JSONDecodeError:
            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr,
                "exit_code": result.returncode
            }
    
    # 应用管理
    def app_launch(self, app: str, wait: bool = False) -> Dict:
        cmd = f"app-launch --app {app}"
        if wait:
            cmd += " --wait"
        return self._execute(cmd)
    
    def app_quit(self, app: str, force: bool = False) -> Dict:
        cmd = f"app-quit --app {app}"
        if force:
            cmd += " --force"
        return self._execute(cmd)
    
    def app_activate(self, app: str) -> Dict:
        return self._execute(f"app-activate --app {app}")
    
    # 鼠标操作
    def click(self, app: str, target: str) -> Dict:
        return self._execute(f"click --app {app} --target '{target}'")
    
    def type_text(self, app: str, target: str, text: str, clear: bool = False, submit: bool = False) -> Dict:
        cmd = f"type --app {app} --target '{target}' --text '{text}'"
        if clear:
            cmd += " --clear"
        if submit:
            cmd += " --submit"
        return self._execute(cmd)
    
    def hotkey(self, keys: str) -> Dict:
        return self._execute(f"hotkey --keys {keys}")
    
    # 断言验证
    def assert_element_exists(self, app: str, title: str, timeout: float = 5) -> bool:
        result = self._execute(f"assert-element-exists --app {app} --title '{title}' --timeout {timeout}")
        return result.get("success", False)
    
    def assert_text_exists(self, app: str, text: str, timeout: float = 5) -> bool:
        result = self._execute(f"assert-text-exists --app {app} --text '{text}' --timeout {timeout}")
        return result.get("success", False)
    
    def assert_clipboard(self, contains: Optional[str] = None, equals: Optional[str] = None) -> bool:
        if contains:
            result = self._execute(f"assert-clipboard --contains '{contains}'")
        elif equals:
            result = self._execute(f"assert-clipboard --equals '{equals}'")
        else:
            result = self._execute("assert-clipboard --not-empty")
        return result.get("success", False)
    
    # 等待
    def wait_for_element(self, app: str, name: str, timeout: float = 10) -> Dict:
        return self._execute(f"wait-for-element --app {app} --name '{name}' --timeout {timeout}")
    
    def sleep(self, seconds: float) -> None:
        time.sleep(seconds)
    
    # 截图与 OCR
    def screenshot(self, app: Optional[str] = None, output: str = "screenshot.png") -> Dict:
        cmd = f"screenshot --output {output}"
        if app:
            cmd += f" --app {app}"
        return self._execute(cmd)
    
    def ocr(self, app: Optional[str] = None) -> List[Dict]:
        cmd = "ocr"
        if app:
            cmd += f" --app {app}"
        result = self._execute(cmd)
        return result.get("results", [])
    
    # 文件系统
    def file_read(self, path: str, base64: bool = False) -> Dict:
        cmd = f"file-read '{path}'"
        if base64:
            cmd += " --base64"
        return self._execute(cmd)
    
    def file_write(self, path: str, text: Optional[str] = None, base64: Optional[str] = None, append: bool = False) -> Dict:
        cmd = f"file-write '{path}'"
        if text:
            cmd += f" --text '{text}'"
        if base64:
            cmd += f" --base64 '{base64}'"
        if append:
            cmd += " --append"
        return self._execute(cmd)
    
    def file_exists(self, path: str, directory: bool = False, not_exists: bool = False) -> bool:
        cmd = f"file-exists '{path}'"
        if directory:
            cmd += " --directory"
        if not_exists:
            cmd += " --not-exists"
        result = self._execute(cmd)
        return result.get("success", False)
    
    def dir_list(self, path: str = ".", recursive: bool = False) -> List[Dict]:
        cmd = f"dir-list '{path}'"
        if recursive:
            cmd += " --recursive"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []
    
    # 状态检测
    def frontmost_app(self) -> Dict:
        return self._execute("frontmost-app")
    
    def focused_element(self) -> Dict:
        return self._execute("focused-element")
    
    # 浏览器控制
    def browser_navigate(self, url: str, browser: str = "Safari") -> Dict:
        return self._execute(f"browser-navigate '{url}' --browser {browser}")
    
    def browser_get_url(self, browser: str = "Safari") -> Dict:
        return self._execute(f"browser-get-url --browser {browser}")
    
    def browser_exec_js(self, script: str, browser: str = "Safari") -> Dict:
        return self._execute(f"browser-exec-js '{script}' --browser {browser}")
    
    def browser_new_tab(self, url: Optional[str] = None, browser: str = "Safari") -> Dict:
        cmd = f"browser-new-tab"
        if url:
            cmd += f" '{url}'"
        cmd += f" --browser {browser}"
        return self._execute(cmd)
    
    def browser_close_tab(self, browser: str = "Safari") -> Dict:
        return self._execute(f"browser-close-tab --browser {browser}")
    
    # AppleScript 桥接
    def osascript(self, script: str, language: str = "applescript") -> Dict:
        return self._execute(f"osascript '{script}' --language {language}")
    
    # 弹窗处理
    def dialog_detect(self, title: Optional[str] = None, button: Optional[str] = None) -> Dict:
        cmd = "dialog-detect"
        if title:
            cmd += f" --title '{title}'"
        if button:
            cmd += f" --button '{button}'"
        return self._execute(cmd)
    
    def dialog_dismiss(self, click: Optional[str] = None, escape: bool = False) -> Dict:
        cmd = "dialog-dismiss"
        if click:
            cmd += f" --click '{click}'"
        if escape:
            cmd += " --escape"
        return self._execute(cmd)
    
    # 测试报告
    def test_start(self, name: str, test_id: Optional[str] = None) -> Dict:
        cmd = f"test-start --name '{name}'"
        if test_id:
            cmd += f" --id {test_id}"
        return self._execute(cmd)
    
    def test_end(self, result: str, reason: Optional[str] = None) -> Dict:
        cmd = f"test-end --result {result}"
        if reason:
            cmd += f" --reason '{reason}'"
        return self._execute(cmd)
    
    def step(self, name: str, description: Optional[str] = None) -> Dict:
        cmd = f"step --name '{name}'"
        if description:
            cmd += f" --description '{description}'"
        return self._execute(cmd)
    
    # 重试
    def retry(self, command: str, attempts: int = 3, interval: float = 1.0) -> Dict:
        return self._execute(f"retry --attempts {attempts} --interval {interval} --command '{command}'")

# 使用示例
def example():
    mcu = MacOSComputerUse()
    
    # 启动应用
    mcu.app_launch("Safari", wait=True)
    
    # 导航到网站
    mcu.type_text("Safari", "地址栏", "apple.com", submit=True)
    
    # 验证页面加载
    if mcu.assert_text_exists("Safari", "Apple", timeout=10):
        print("页面加载成功")
        mcu.screenshot(app="Safari", output="apple.png")
    else:
        print("页面加载失败")
    
    # 关闭应用
    mcu.app_quit("Safari")

if __name__ == "__main__":
    example()
```

---

## 最佳实践

### 1. 始终使用断言验证

```python
# ❌ 不好：只操作不验证
mcu.click("Safari", "登录")

# ✅ 好：操作后验证
mcu.click("Safari", "登录")
assert mcu.assert_text_exists("Safari", "欢迎回来", timeout=5)
```

### 2. 使用 JSON 输出便于解析

```python
result = mcu._execute("assert-element-exists --app Safari --title 地址栏 --json")
if result["success"]:
    print(f"元素位置: ({result['element']['x']}, {result['element']['y']})")
```

### 3. 合理使用超时和重试

```python
# 网络操作给足够超时
mcu.assert_text_exists("Safari", "加载完成", timeout=30)

# 不稳定操作使用重试
mcu.retry("click --app Safari --target 刷新", attempts=5, interval=2)
```

### 4. 失败时截图保留现场

```python
import atexit

def on_error():
    mcu.screenshot(output=f"error_{int(time.time())}.png")

atexit.register(on_error)
```

### 5. 使用测试标记追踪进度

```python
mcu.test_start("用户注册流程", "TC001")
mcu.step("打开注册页面")
# ... 操作 ...
mcu.step("填写表单")
# ... 操作 ...
mcu.step("提交注册")
# ... 操作 ...
mcu.test_end("pass")
```

---

## 故障排除

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 元素找不到 | 应用未激活 | 先执行 `app-activate` |
| 操作没反应 | 焦点在其他窗口 | 确保目标应用在前台 |
| 断言超时 | 页面未加载完 | 增加超时时间或先 `sleep` |
| OCR 识别率低 | 分辨率或字体问题 | 放大窗口或调整对比度 |
| 快捷键无效 | 应用未聚焦 | 使用 `app-activate` 后再发送 |

### 调试技巧

```bash
# 1. 截图查看当前状态
macos-computer-use screenshot --output debug.png

# 2. OCR 识别屏幕内容
macos-computer-use ocr --format json

# 3. 列出所有元素
macos-computer-use element-list --app Safari

# 4. 获取元素详细信息
macos-computer-use element-info --app Safari --name "目标元素"

# 5. 使用 JSON 输出查看完整结果
macos-computer-use assert-element-exists --app Safari --title "地址栏" --json
```

---

> 通过本指南，AI Agent 可以充分利用 macos-computer-use 完成复杂的 UI 自动化任务，实现真正的智能化操作。
