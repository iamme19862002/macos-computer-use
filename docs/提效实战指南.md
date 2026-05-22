# 提效实战指南

> 本指南展示如何使用 macos-computer-use 提升工作效率和生产力，包含大量实用场景。

## 目录

- [日常办公自动化](#日常办公自动化)
- [开发工作流](#开发工作流)
- [数据处理](#数据处理)
- [会议与协作](#会议与协作)
- [系统维护](#系统维护)
- [批量操作](#批量操作)

---

## 日常办公自动化

### 场景 1：自动整理桌面

```bash
#!/bin/bash
# 每天自动整理桌面文件到对应文件夹

echo "=== 桌面整理 ==="

# 创建分类文件夹
mkdir -p ~/Desktop/截图/$(date +%Y-%m)
mkdir -p ~/Desktop/文档/PDF
mkdir -p ~/Desktop/文档/Office
mkdir -p ~/Desktop/压缩包
mkdir -p ~/Desktop/其他

# 移动截图
mv ~/Desktop/Screen\ Shot*.png ~/Desktop/截图/$(date +%Y-%m)/ 2>/dev/null
mv ~/Desktop/Screen\ Recording*.mov ~/Desktop/截图/$(date +%Y-%m)/ 2>/dev/null

# 移动 PDF
mv ~/Desktop/*.pdf ~/Desktop/文档/PDF/ 2>/dev/null

# 移动 Office 文档
mv ~/Desktop/*.docx ~/Desktop/*.xlsx ~/Desktop/*.pptx ~/Desktop/文档/Office/ 2>/dev/null

# 移动压缩包
mv ~/Desktop/*.zip ~/Desktop/*.rar ~/Desktop/*.7z ~/Desktop/压缩包/ 2>/dev/null

# 打开 Finder 查看结果
macos-computer-use app-activate --app Finder
macos-computer-use hotkey --keys command+shift+g
macos-computer-use type --text "~/Desktop"
macos-computer-use hotkey --keys return

echo "=== 整理完成 ==="
```

### 场景 2：自动回复邮件模板

```bash
#!/bin/bash
# 快速回复常见邮件

echo "=== 自动邮件回复 ==="

# 激活邮件客户端
macos-computer-use app-activate --app Mail

# 创建新邮件
macos-computer-use hotkey --keys command+n

# 填写收件人（从剪贴板获取）
macos-computer-use clipboard-paste --app Mail --target "收件人"
macos-computer-use hotkey --keys tab

# 选择邮件模板
echo "选择邮件模板："
echo "1. 会议邀请确认"
echo "2. 文件已发送"
echo "3. 延期申请"
read -p "请输入编号: " template

case $template in
    1)
        macos-computer-use type --app Mail --target "主题" --text "会议邀请确认"
        macos-computer-use hotkey --keys tab
        macos-computer-use type --app Mail --target "正文" --text "您好，

我已收到会议邀请，确认参加。

谢谢！"
        ;;
    2)
        macos-computer-use type --app Mail --target "主题" --text "文件已发送"
        macos-computer-use hotkey --keys tab
        macos-computer-use type --app Mail --target "正文" --text "您好，

附件是所需的文件，请查收。

如有问题请随时联系。"
        ;;
    3)
        macos-computer-use type --app Mail --target "主题" --text "关于项目延期的申请"
        macos-computer-use hotkey --keys tab
        macos-computer-use type --app Mail --target "正文" --text "您好，

由于技术难点需要更多时间解决，申请将项目延期至下周。

详细说明如下：

谢谢理解！"
        ;;
esac

echo "=== 邮件已创建，请检查发送 ==="
```

### 场景 3：自动备份重要文件

```bash
#!/bin/bash
# 自动备份文档到云盘

echo "=== 文件备份 ==="

BACKUP_DIR="~/Backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# 备份文档
cp -r ~/Documents/Important "$BACKUP_DIR/"

# 备份桌面
cp -r ~/Desktop/文档 "$BACKUP_DIR/"

# 打开云盘客户端上传
macos-computer-use app-launch --app "百度网盘"
macos-computer-use wait-for-app --app "百度网盘" --timeout 10

# 拖拽备份文件夹到云盘
macos-computer-use drag \
  --from-app Finder --from-target "$(basename $BACKUP_DIR)" \
  --to-app "百度网盘" --to-target "上传区域"

# 等待上传完成
macos-computer-use assert-text-exists --app "百度网盘" --text "上传完成" --timeout 300

echo "=== 备份完成 ==="
```

---

## 开发工作流

### 场景 4：一键启动开发环境

```bash
#!/bin/bash
# 一键启动所有开发工具

echo "=== 启动开发环境 ==="

# 启动终端
macos-computer-use app-launch --app Terminal
macos-computer-use wait-for-app --app Terminal --timeout 5

# 启动 VS Code
macos-computer-use app-launch --app "Visual Studio Code"
macos-computer-use wait-for-app --app "Visual Studio Code" --timeout 10

# 启动浏览器
macos-computer-use app-launch --app Safari
macos-computer-use wait-for-app --app Safari --timeout 10

# 启动数据库工具
macos-computer-use app-launch --app "TablePlus"
macos-computer-use wait-for-app --app "TablePlus" --timeout 10

# 启动 API 测试工具
macos-computer-use app-launch --app Postman
macos-computer-use wait-for-app --app Postman --timeout 10

# 排列窗口
macos-computer-use window-move --app "Visual Studio Code" --x 0 --y 0
macos-computer-use window-resize --app "Visual Studio Code" --width 1200 --height 1400

macos-computer-use window-move --app Safari --x 1200 --y 0
macos-computer-use window-resize --app Safari --width 800 --height 700

macos-computer-use window-move --app Terminal --x 1200 --y 700
macos-computer-use window-resize --app Terminal --width 800 --height 700

echo "=== 开发环境已就绪 ==="
```

### 场景 5：自动化代码提交

```bash
#!/bin/bash
# 自动提交代码并创建 PR

echo "=== 自动化代码提交 ==="

# 打开终端
macos-computer-use app-activate --app Terminal

# 检查 git 状态
macos-computer-use type --app Terminal --text "cd ~/Projects/my-project && git status"
macos-computer-use key --app Terminal --key return
macos-computer-use sleep --seconds 2

# 添加所有变更
macos-computer-use type --app Terminal --text "git add ."
macos-computer-use key --app Terminal --key return

# 提交（使用规范格式）
macos-computer-use type --app Terminal --text "git commit -m 'feat: update features'"
macos-computer-use key --app Terminal --key return

# 推送到远程
macos-computer-use type --app Terminal --text "git push origin feature/new-feature"
macos-computer-use key --app Terminal --key return

# 打开浏览器创建 PR
macos-computer-use app-activate --app Safari
macos-computer-use type --app Safari --target "地址栏" --text "https://github.com/user/repo/pull/new/feature/new-feature" --submit

echo "=== 代码已提交，请在浏览器中完成 PR 创建 ==="
```

### 场景 6：自动化测试运行

```bash
#!/bin/bash
# 运行测试并生成报告

echo "=== 运行自动化测试 ==="

# 打开终端
macos-computer-use app-activate --app Terminal

# 运行测试
macos-computer-use type --app Terminal --text "cd ~/Projects/my-project && npm test"
macos-computer-use key --app Terminal --key return

# 等待测试完成（通过检查终端输出）
macos-computer-use assert-text-exists --app Terminal --text "Test Suites" --timeout 120

# 截图测试结果
macos-computer-use screenshot --app Terminal --output test_result.png

# 如果测试失败，打开报告
if ! macos-computer-use assert-text-exists --app Terminal --text "passed" --timeout 1; then
    macos-computer-use app-activate --app Safari
    macos-computer-use type --app Safari --target "地址栏" --text "file:///~/Projects/my-project/coverage/index.html" --submit
fi

echo "=== 测试完成 ==="
```

---

## 数据处理

### 场景 7：批量重命名文件

```bash
#!/bin/bash
# 批量重命名照片文件

echo "=== 批量重命名 ==="

# 打开 Finder 到目标文件夹
macos-computer-use app-activate --app Finder
macos-computer-use hotkey --keys command+shift+g
macos-computer-use type --text "~/Photos/2026-05"
macos-computer-use hotkey --keys return

# 选择所有文件
macos-computer-use hotkey --keys command+a

# 右键选择重命名
macos-computer-use right-click --app Finder --target "IMG_0001.jpg"
macos-computer-use click --app Finder --target "重新命名 XX 个项目"

# 选择格式重命名
macos-computer-use click --app Finder --target "格式"
macos-computer-use type --app Finder --target "名称格式" --text "旅行_2026-05-"
macos-computer-use click --app Finder --target "重新命名"

echo "=== 重命名完成 ==="
```

### 场景 8：批量转换图片格式

```bash
#!/bin/bash
# 批量将 HEIC 转换为 JPG

echo "=== 图片格式转换 ==="

# 打开终端
macos-computer-use app-activate --app Terminal

# 使用 sips 批量转换
macos-computer-use type --app Terminal --text "cd ~/Photos && for f in *.HEIC; do sips -s format jpeg \"$f\" --out \"${f%.HEIC}.jpg\"; done"
macos-computer-use key --app Terminal --key return

# 等待转换完成
macos-computer-use assert-text-exists --app Terminal --text "$" --timeout 60

# 打开文件夹查看结果
macos-computer-use app-activate --app Finder
macos-computer-use hotkey --keys command+shift+g
macos-computer-use type --text "~/Photos"
macos-computer-use hotkey --keys return

echo "=== 转换完成 ==="
```

---

## 会议与协作

### 场景 9：自动准备会议材料

```bash
#!/bin/bash
# 自动准备会议材料

echo "=== 准备会议材料 ==="

MEETING_NAME="周会"
DATE=$(date +%Y-%m-%d)

# 创建会议记录文档
macos-computer-use app-launch --app TextEdit
macos-computer-use wait-for-app --app TextEdit --timeout 5

# 填写会议模板
macos-computer-use type --app TextEdit --target "文档内容" --text "# $MEETING_NAME - $DATE

## 参会人员
- 

## 议程
1. 
2. 
3. 

## 讨论内容

## 行动计划
- [ ] 

## 下次会议
- 时间：
- 议题：
"

# 保存文档
macos-computer-use hotkey --keys command+s
macos-computer-use type --text "~/Documents/会议记录/${MEETING_NAME}_${DATE}.md"
macos-computer-use key --key return

# 打开日历创建会议
macos-computer-use app-launch --app Calendar
macos-computer-use wait-for-app --app Calendar --timeout 5

# 创建新事件
macos-computer-use hotkey --keys command+n
macos-computer-use type --app Calendar --target "标题" --text "$MEETING_NAME"
macos-computer-use hotkey --keys tab
macos-computer-use type --app Calendar --target "位置" --text "会议室 A"

echo "=== 会议材料已准备 ==="
```

### 场景 10：自动记录会议笔记

```bash
#!/bin/bash
# 会议期间自动截图记录

echo "=== 会议记录模式 ==="

# 创建会议记录目录
MEETING_DIR="~/Documents/会议记录/$(date +%Y-%m-%d_%H-%M)"
mkdir -p "$MEETING_DIR"

# 打开笔记应用
macos-computer-use app-launch --app Notes
macos-computer-use wait-for-app --app Notes --timeout 5

# 创建新笔记
macos-computer-use hotkey --keys command+n
macos-computer-use type --app Notes --target "标题" --text "会议记录 - $(date +%H:%M)"

# 每 5 分钟截图一次
echo "开始记录，按 Ctrl+C 停止"
count=1
while true; do
    macos-computer-use screenshot --output "$MEETING_DIR/screenshot_${count}.png"
    macos-computer-use type --app Notes --target "内容" --text "
[截图 $count - $(date +%H:%M:%S)]
"
    count=$((count + 1))
    sleep 300
done
```

---

## 系统维护

### 场景 11：系统清理与优化

```bash
#!/bin/bash
# 定期系统清理

echo "=== 系统清理 ==="

# 打开终端
macos-computer-use app-activate --app Terminal

# 清理缓存
macos-computer-use type --app Terminal --text "sudo rm -rf ~/Library/Caches/*"
macos-computer-use key --app Terminal --key return

# 清理下载文件夹（超过 30 天的文件）
macos-computer-use type --app Terminal --text "find ~/Downloads -mtime +30 -delete"
macos-computer-use key --app Terminal --key return

# 清空废纸篓
macos-computer-use type --app Terminal --text "osascript -e 'tell application \"Finder\" to empty trash'"
macos-computer-use key --app Terminal --key return

# 更新 Homebrew
macos-computer-use type --app Terminal --text "brew update && brew upgrade"
macos-computer-use key --app Terminal --key return

# 等待完成
macos-computer-use assert-text-exists --app Terminal --text "$" --timeout 300

# 显示磁盘使用情况
macos-computer-use type --app Terminal --text "df -h"
macos-computer-use key --app Terminal --key return

echo "=== 清理完成 ==="
```

### 场景 12：自动更新应用

```bash
#!/bin/bash
# 批量更新应用

echo "=== 应用更新 ==="

# 打开 App Store
macos-computer-use app-launch --app "App Store"
macos-computer-use wait-for-app --app "App Store" --timeout 10

# 点击更新标签
macos-computer-use click --app "App Store" --target "更新"

# 点击全部更新
if macos-computer-use assert-element-exists --app "App Store" --title "全部更新" --timeout 5; then
    macos-computer-use click --app "App Store" --target "全部更新"
    echo "开始更新所有应用..."
    
    # 等待更新完成
    macos-computer-use assert-text-exists --app "App Store" --text "没有可用更新" --timeout 600
fi

# 更新 Homebrew 应用
macos-computer-use app-activate --app Terminal
macos-computer-use type --app Terminal --text "brew upgrade"
macos-computer-use key --app Terminal --key return

echo "=== 更新完成 ==="
```

---

## 批量操作

### 场景 13：批量发送个性化邮件

```bash
#!/bin/bash
# 批量发送个性化邮件

echo "=== 批量邮件发送 ==="

# 邮件列表
RECIPIENTS=(
    "zhangsan@example.com:张三"
    "lisi@example.com:李四"
    "wangwu@example.com:王五"
)

for item in "${RECIPIENTS[@]}"; do
    IFS=':' read -r email name <<< "$item"
    
    echo "发送邮件给 $name ($email)..."
    
    # 激活邮件客户端
    macos-computer-use app-activate --app Mail
    
    # 创建新邮件
    macos-computer-use hotkey --keys command+n
    
    # 填写收件人
    macos-computer-use type --app Mail --target "收件人" --text "$email"
    macos-computer-use hotkey --keys tab
    
    # 填写主题
    macos-computer-use type --app Mail --target "主题" --text "项目进展汇报"
    macos-computer-use hotkey --keys tab
    
    # 填写个性化内容
    macos-computer-use type --app Mail --target "正文" --text "尊敬的 $name，

您好！

以下是本周的项目进展汇报：

1. 已完成任务：
   - 

2. 进行中任务：
   - 

3. 下周计划：
   - 

如有任何问题，请随时联系。

谢谢！"
    
    # 发送邮件
    macos-computer-use hotkey --keys command+return
    
    # 等待发送完成
    macos-computer-use sleep --seconds 2
done

echo "=== 所有邮件已发送 ==="
```

### 场景 14：批量处理图片

```bash
#!/bin/bash
# 批量调整图片大小并添加水印

echo "=== 批量图片处理 ==="

# 打开终端
macos-computer-use app-activate --app Terminal

# 创建输出目录
mkdir -p ~/Pictures/Processed

# 批量处理
macos-computer-use type --app Terminal --text "cd ~/Pictures/Raw && for f in *.jpg; do
  # 调整大小
  sips -Z 1920 \"$f\" --out ~/Pictures/Processed/\"$f\"
  
  # 添加水印（使用 ImageMagick）
  convert ~/Pictures/Processed/\"$f\" -gravity SouthEast -pointsize 30 -fill white -annotate +10+10 '© 2026 Company' ~/Pictures/Processed/\"$f\"
done"
macos-computer-use key --app Terminal --key return

# 等待处理完成
macos-computer-use assert-text-exists --app Terminal --text "$" --timeout 300

# 打开处理后的文件夹
macos-computer-use app-activate --app Finder
macos-computer-use hotkey --keys command+shift+g
macos-computer-use type --text "~/Pictures/Processed"
macos-computer-use hotkey --keys return

echo "=== 图片处理完成 ==="
```

### 场景 15：自动化社交媒体发布

```bash
#!/bin/bash
# 自动发布内容到社交媒体

echo "=== 社交媒体发布 ==="

# 打开浏览器
macos-computer-use app-launch --app Safari
macos-computer-use wait-for-app --app Safari --timeout 10

# 访问 Twitter
macos-computer-use type --app Safari --target "地址栏" --text "https://twitter.com/compose/tweet" --submit
macos-computer-use assert-text-exists --app Safari --text "撰写新推文" --timeout 10

# 输入推文内容
macos-computer-use type --app Safari --target "推文内容" --text "今日工作进展：
✅ 完成新功能开发
✅ 修复 3 个 bug
✅ 发布 v3.1.0 版本

#开发 #更新"

# 附加图片（如果有）
if [ -f "/tmp/screenshot.png" ]; then
    macos-computer-use click --app Safari --target "添加图片"
    macos-computer-use type --text "/tmp/screenshot.png"
    macos-computer-use key --key return
fi

# 发布推文
macos-computer-use click --app Safari --target "推文"

# 验证发布成功
macos-computer-use assert-text-exists --app Safari --text "你的推文已发布" --timeout 5

echo "=== 推文已发布 ==="
```

---

## 高级技巧

### 使用录制回放自动化重复任务

```bash
# 录制一次，永久使用

# 1. 开始录制
macos-computer-use record --output daily_task.json

# 2. 手动执行一次任务
# ... 操作 ...

# 3. 停止录制（Ctrl+C）

# 4. 以后每天自动执行
macos-computer-use replay --input daily_task.json
```

### 使用 JSON 脚本编排复杂工作流

```json
{
  "name": "每日工作流",
  "steps": [
    {"action": "app-launch", "params": {"app": "Safari"}},
    {"action": "wait-for-app", "params": {"app": "Safari", "timeout": 10}},
    {"action": "type", "params": {"app": "Safari", "target": "地址栏", "text": "https://mail.company.com", "submit": true}},
    {"action": "assert-text-exists", "params": {"app": "Safari", "text": "收件箱", "timeout": 10}},
    {"action": "screenshot", "params": {"app": "Safari", "output": "inbox.png"}}
  ]
}
```

执行脚本：
```bash
macos-computer-use run-script --input daily_workflow.json
```

---

> 通过这些实战场景，你可以将 macos-computer-use 融入日常工作，大幅提升效率。
