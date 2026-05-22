#
#  client.py
#  macos-computer-use Python SDK
#
#  Created by macos-computer-use authors on 2026.
#  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
#  Licensed under the MIT License.
#

"""
MacOSComputerUse Python 客户端

提供完整的 macOS 计算机控制能力，封装所有 CLI 命令。
"""

import json
import subprocess
import shutil
from typing import Dict, List, Optional, Any

from .exceptions import CommandNotFoundError, CommandExecutionError


class MacOSComputerUse:
    """
    macOS 计算机控制客户端

    封装 macos-computer-use CLI 的所有功能，提供 Pythonic API。

    Args:
        binary_path: CLI 可执行文件路径（默认自动查找）
        timeout: 默认命令超时时间（秒）
        json_output: 默认使用 JSON 输出
    """

    def __init__(
        self,
        binary_path: Optional[str] = None,
        timeout: float = 30.0,
        json_output: bool = True,
    ):
        self.binary_path = binary_path or self._find_binary()
        self.timeout = timeout
        self.json_output = json_output

    def _find_binary(self) -> str:
        """自动查找 CLI 可执行文件"""
        paths = [
            "macos-computer-use",
            "/usr/local/bin/macos-computer-use",
            "/opt/homebrew/bin/macos-computer-use",
            str(Path.home() / ".local/bin/macos-computer-use"),
        ]
        for path in paths:
            if shutil.which(path):
                return path
        raise CommandNotFoundError(
            "未找到 macos-computer-use 可执行文件，请先安装"
        )

    def _execute(
        self,
        command: str,
        timeout: Optional[float] = None,
    ) -> Dict[str, Any]:
        """执行 CLI 命令"""
        cmd = [self.binary_path] + command.split()
        if self.json_output and "--json" not in command:
            cmd.append("--json")

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout or self.timeout,
            )
        except subprocess.TimeoutExpired:
            raise TimeoutError(f"命令执行超时: {command}")
        except FileNotFoundError:
            raise CommandNotFoundError(f"找不到可执行文件: {self.binary_path}")

        if result.returncode != 0 and not result.stdout:
            raise CommandExecutionError(
                f"命令执行失败: {result.stderr}",
                exit_code=result.returncode,
                stderr=result.stderr,
            )

        try:
            return json.loads(result.stdout) if result.stdout else {}
        except json.JSONDecodeError:
            return {"raw_output": result.stdout.strip()}

    # ==================== 截图 ====================

    def screenshot(
        self,
        output_dir: Optional[str] = None,
        filename: Optional[str] = None,
        region: Optional[str] = None,
        app: Optional[str] = None,
    ) -> Dict[str, Any]:
        """截取屏幕截图"""
        cmd = "screenshot"
        if output_dir:
            cmd += f" --output-dir '{output_dir}'"
        if filename:
            cmd += f" --filename '{filename}'"
        if region:
            cmd += f" --region '{region}'"
        if app:
            cmd += f" --app '{app}'"
        return self._execute(cmd)

    def screenshot_diff(
        self,
        image1: str,
        image2: str,
        output: Optional[str] = None,
        threshold: int = 30,
    ) -> Dict[str, Any]:
        """对比两张截图差异"""
        cmd = f"screenshot-diff '{image1}' '{image2}'"
        if output:
            cmd += f" --output '{output}'"
        if threshold != 30:
            cmd += f" --threshold {threshold}"
        return self._execute(cmd)

    # ==================== 鼠标 ====================

    def cursor_position(self) -> Dict[str, Any]:
        """获取鼠标位置"""
        return self._execute("cursor-position")

    def mouse_move(self, x: int, y: int, duration: float = 0.5) -> Dict[str, Any]:
        """移动鼠标"""
        return self._execute(f"mouse-move --x {x} --y {y} --duration {duration}")

    def left_click(self, x: Optional[int] = None, y: Optional[int] = None) -> Dict[str, Any]:
        """左键点击"""
        cmd = "left-click"
        if x is not None and y is not None:
            cmd += f" --x {x} --y {y}"
        return self._execute(cmd)

    def right_click(self, x: Optional[int] = None, y: Optional[int] = None) -> Dict[str, Any]:
        """右键点击"""
        cmd = "right-click"
        if x is not None and y is not None:
            cmd += f" --x {x} --y {y}"
        return self._execute(cmd)

    def middle_click(self, x: Optional[int] = None, y: Optional[int] = None) -> Dict[str, Any]:
        """中键点击"""
        cmd = "middle-click"
        if x is not None and y is not None:
            cmd += f" --x {x} --y {y}"
        return self._execute(cmd)

    def double_click(self, x: Optional[int] = None, y: Optional[int] = None) -> Dict[str, Any]:
        """双击"""
        cmd = "double-click"
        if x is not None and y is not None:
            cmd += f" --x {x} --y {y}"
        return self._execute(cmd)

    def mouse_hover(self, x: int, y: int) -> Dict[str, Any]:
        """鼠标悬停"""
        return self._execute(f"mouse-hover --x {x} --y {y}")

    def drag(self, from_x: int, from_y: int, to_x: int, to_y: int) -> Dict[str, Any]:
        """拖拽"""
        return self._execute(f"drag --from-x {from_x} --from-y {from_y} --to-x {to_x} --to-y {to_y}")

    def scroll(self, x: int, y: int, direction: str = "down", amount: int = 3) -> Dict[str, Any]:
        """滚动"""
        return self._execute(f"scroll --x {x} --y {y} --direction {direction} --amount {amount}")

    # ==================== 键盘 ====================

    def key(self, key_name: str, app: Optional[str] = None) -> Dict[str, Any]:
        """按下按键"""
        cmd = f"key --key {key_name}"
        if app:
            cmd += f" --app '{app}'"
        return self._execute(cmd)

    def hotkey(self, keys: str) -> Dict[str, Any]:
        """按下快捷键"""
        return self._execute(f"hotkey --keys '{keys}'")

    def key_sequence(self, keys: str) -> Dict[str, Any]:
        """按键序列"""
        return self._execute(f"key-sequence --keys '{keys}'")

    def type_text(self, text: str, app: Optional[str] = None, target: Optional[str] = None) -> Dict[str, Any]:
        """输入文本"""
        cmd = f"type --text '{text}'"
        if app:
            cmd += f" --app '{app}'"
        if target:
            cmd += f" --target '{target}'"
        return self._execute(cmd)

    # ==================== 应用管理 ====================

    def app_launch(self, app_name: str) -> Dict[str, Any]:
        """启动应用"""
        return self._execute(f"app-launch --app '{app_name}'")

    def app_quit(self, app_name: str) -> Dict[str, Any]:
        """退出应用"""
        return self._execute(f"app-quit --app '{app_name}'")

    def app_list(self, frontmost_only: bool = False) -> List[Dict[str, Any]]:
        """列出运行中的应用"""
        cmd = "app-list"
        if frontmost_only:
            cmd += " --frontmost-only"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []

    def app_activate(self, app_name: str) -> Dict[str, Any]:
        """激活应用"""
        return self._execute(f"app-activate --app '{app_name}'")

    def app_hide(self, app_name: str) -> Dict[str, Any]:
        """隐藏应用"""
        return self._execute(f"app-hide --app '{app_name}'")

    def frontmost_app(self) -> Dict[str, Any]:
        """获取当前前台应用"""
        return self._execute("frontmost-app")

    # ==================== 窗口管理 ====================

    def window_list(self, app: Optional[str] = None) -> List[Dict[str, Any]]:
        """列出窗口"""
        cmd = "window-list"
        if app:
            cmd += f" --app '{app}'"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []

    def window_resize(self, app: str, width: int, height: int) -> Dict[str, Any]:
        """调整窗口大小"""
        return self._execute(f"window-resize --app '{app}' --width {width} --height {height}")

    def window_move(self, app: str, x: int, y: int) -> Dict[str, Any]:
        """移动窗口"""
        return self._execute(f"window-move --app '{app}' --x {x} --y {y}")

    def window_minimize(self, app: str) -> Dict[str, Any]:
        """最小化窗口"""
        return self._execute(f"window-minimize --app '{app}'")

    def window_maximize(self, app: str) -> Dict[str, Any]:
        """最大化窗口"""
        return self._execute(f"window-maximize --app '{app}'")

    def window_close(self, app: str) -> Dict[str, Any]:
        """关闭窗口"""
        return self._execute(f"window-close --app '{app}'")

    def window_focus(self, app: str) -> Dict[str, Any]:
        """聚焦窗口"""
        return self._execute(f"window-focus --app '{app}'")

    # ==================== UI 元素 ====================

    def element_find(
        self,
        app: Optional[str] = None,
        title: Optional[str] = None,
        role: Optional[str] = None,
        identifier: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """查找 UI 元素"""
        cmd = "element-find"
        if app:
            cmd += f" --app '{app}'"
        if title:
            cmd += f" --title '{title}'"
        if role:
            cmd += f" --role '{role}'"
        if identifier:
            cmd += f" --identifier '{identifier}'"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []

    def element_click(self, app: str, name: str) -> Dict[str, Any]:
        """点击 UI 元素"""
        return self._execute(f"element-click --app '{app}' --name '{name}'")

    def element_info(self, app: str, name: str) -> Dict[str, Any]:
        """获取元素信息"""
        return self._execute(f"element-info --app '{app}' --name '{name}'")

    def element_list(self, app: str, type: Optional[str] = None) -> List[Dict[str, Any]]:
        """列出所有元素"""
        cmd = f"element-list --app '{app}'"
        if type:
            cmd += f" --type '{type}'"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []

    def focused_element(self) -> Dict[str, Any]:
        """获取当前焦点元素"""
        return self._execute("focused-element")

    def scroll_to_element(
        self,
        app: str,
        name: Optional[str] = None,
        role: Optional[str] = None,
        identifier: Optional[str] = None,
        max_scrolls: int = 20,
    ) -> Dict[str, Any]:
        """滚动直到元素可见"""
        cmd = f"scroll-to-element --app '{app}'"
        if name:
            cmd += f" --name '{name}'"
        if role:
            cmd += f" --role '{role}'"
        if identifier:
            cmd += f" --identifier '{identifier}'"
        if max_scrolls != 20:
            cmd += f" --max-scrolls {max_scrolls}"
        return self._execute(cmd)

    # ==================== 等待 ====================

    def wait_for_element(
        self,
        app: str,
        name: str,
        timeout: float = 10.0,
    ) -> Dict[str, Any]:
        """等待元素出现"""
        return self._execute(f"wait-for-element --app '{app}' --name '{name}' --timeout {timeout}")

    def wait_for_app(self, app_name: str, timeout: float = 10.0) -> Dict[str, Any]:
        """等待应用启动"""
        return self._execute(f"wait-for-app --app '{app_name}' --timeout {timeout}")

    def sleep(self, seconds: float) -> Dict[str, Any]:
        """固定等待"""
        return self._execute(f"sleep --seconds {seconds}")

    # ==================== 断言 ====================

    def assert_element_exists(self, app: str, name: str, timeout: float = 5.0) -> bool:
        """断言元素存在"""
        try:
            result = self._execute(f"assert-element-exists --app '{app}' --name '{name}' --timeout {timeout}")
            return result.get("success", False)
        except CommandExecutionError:
            return False

    def assert_text_exists(self, app: str, text: str, timeout: float = 5.0) -> bool:
        """断言文本存在"""
        try:
            result = self._execute(f"assert-text-exists --app '{app}' --text '{text}' --timeout {timeout}")
            return result.get("success", False)
        except CommandExecutionError:
            return False

    def assert_element_property(self, app: str, name: str, property: str, value: str, timeout: float = 5.0) -> bool:
        """断言元素属性"""
        try:
            result = self._execute(f"assert-element-property --app '{app}' --name '{name}' --property '{property}' --value '{value}' --timeout {timeout}")
            return result.get("success", False)
        except CommandExecutionError:
            return False

    def assert_clipboard(self, expected: str, timeout: float = 5.0) -> bool:
        """断言剪贴板内容"""
        try:
            result = self._execute(f"assert-clipboard --expected '{expected}' --timeout {timeout}")
            return result.get("success", False)
        except CommandExecutionError:
            return False

    # ==================== 剪贴板 ====================

    def clipboard_copy(self, text: str) -> Dict[str, Any]:
        """复制到剪贴板"""
        return self._execute(f"clipboard-copy --text '{text}'")

    def clipboard_paste(self) -> Dict[str, Any]:
        """粘贴剪贴板内容"""
        return self._execute("clipboard-paste")

    def clipboard_get(self) -> Dict[str, Any]:
        """获取剪贴板内容"""
        return self._execute("clipboard-get")

    # ==================== 文件系统 ====================

    def file_read(self, path: str, base64: bool = False) -> Dict[str, Any]:
        """读取文件"""
        cmd = f"file-read '{path}'"
        if base64:
            cmd += " --base64"
        return self._execute(cmd)

    def file_write(
        self,
        path: str,
        text: Optional[str] = None,
        base64: Optional[str] = None,
        append: bool = False,
    ) -> Dict[str, Any]:
        """写入文件"""
        cmd = f"file-write '{path}'"
        if text:
            cmd += f" --text '{text}'"
        if base64:
            cmd += f" --base64 '{base64}'"
        if append:
            cmd += " --append"
        return self._execute(cmd)

    def file_exists(self, path: str, directory: bool = False) -> bool:
        """检查文件是否存在"""
        cmd = f"file-exists '{path}'"
        if directory:
            cmd += " --directory"
        result = self._execute(cmd)
        return result.get("success", False)

    def dir_list(self, path: str = ".", recursive: bool = False) -> List[Dict[str, Any]]:
        """列出目录"""
        cmd = f"dir-list '{path}'"
        if recursive:
            cmd += " --recursive"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []

    # ==================== 浏览器控制 ====================

    def browser_navigate(self, url: str, browser: str = "Safari") -> Dict[str, Any]:
        """浏览器导航"""
        return self._execute(f"browser-navigate '{url}' --browser {browser}")

    def browser_get_url(self, browser: str = "Safari") -> Dict[str, Any]:
        """获取当前页面 URL"""
        return self._execute(f"browser-get-url --browser {browser}")

    def browser_exec_js(self, script: str, browser: str = "Safari") -> Dict[str, Any]:
        """执行 JavaScript"""
        return self._execute(f"browser-exec-js '{script}' --browser {browser}")

    def browser_new_tab(self, url: Optional[str] = None, browser: str = "Safari") -> Dict[str, Any]:
        """新建标签页"""
        cmd = "browser-new-tab"
        if url:
            cmd += f" '{url}'"
        cmd += f" --browser {browser}"
        return self._execute(cmd)

    def browser_close_tab(self, browser: str = "Safari") -> Dict[str, Any]:
        """关闭标签页"""
        return self._execute(f"browser-close-tab --browser {browser}")

    # ==================== AppleScript ====================

    def osascript(self, script: str, language: str = "applescript") -> Dict[str, Any]:
        """执行 AppleScript/JXA"""
        return self._execute(f"osascript '{script}' --language {language}")

    # ==================== 弹窗处理 ====================

    def dialog_detect(self, title: Optional[str] = None, button: Optional[str] = None) -> Dict[str, Any]:
        """检测弹窗"""
        cmd = "dialog-detect"
        if title:
            cmd += f" --title '{title}'"
        if button:
            cmd += f" --button '{button}'"
        return self._execute(cmd)

    def dialog_dismiss(self, click: Optional[str] = None, escape: bool = False) -> Dict[str, Any]:
        """关闭弹窗"""
        cmd = "dialog-dismiss"
        if click:
            cmd += f" --click '{click}'"
        if escape:
            cmd += " --escape"
        return self._execute(cmd)

    # ==================== 像素颜色 ====================

    def pixel_color(self, x: int, y: int) -> Dict[str, Any]:
        """读取像素颜色"""
        return self._execute(f"pixel-color --x {x} --y {y}")

    # ==================== 文本选择 ====================

    def text_select(self, text: Optional[str] = None, select_all: bool = False) -> Dict[str, Any]:
        """选中文本或获取已选文本"""
        if select_all:
            return self._execute("text-select --all")
        if text:
            return self._execute(f"text-select --text '{text}'")
        return self._execute("text-select")

    # ==================== 菜单操作 ====================

    def menu_click(self, path: str, app: Optional[str] = None) -> Dict[str, Any]:
        """点击菜单项"""
        cmd = f"menu-click '{path}'"
        if app:
            cmd += f" --app '{app}'"
        return self._execute(cmd)

    # ==================== 通知 ====================

    def notify(self, title: str, message: Optional[str] = None) -> Dict[str, Any]:
        """发送通知"""
        cmd = f"notify '{title}'"
        if message:
            cmd += f" --message '{message}'"
        return self._execute(cmd)

    # ==================== 脚本执行 ====================

    def run_script(self, file: str, dry_run: bool = False) -> Dict[str, Any]:
        """执行 JSON 脚本"""
        cmd = f"run-script --file '{file}'"
        if dry_run:
            cmd += " --dry-run"
        return self._execute(cmd)

    # ==================== 重试 ====================

    def retry(self, command: str, attempts: int = 3, interval: float = 1.0) -> Dict[str, Any]:
        """重试命令"""
        return self._execute(f"retry --attempts {attempts} --interval {interval} --command '{command}'")

    # ==================== 系统信息 ====================

    def screen_info(self) -> Dict[str, Any]:
        """获取屏幕信息"""
        return self._execute("screen-info")

    def display_list(self) -> List[Dict[str, Any]]:
        """列出显示器"""
        result = self._execute("display-list")
        return result if isinstance(result, list) else []

    def system_info(self) -> Dict[str, Any]:
        """获取系统信息"""
        return self._execute("system-info")

    # ==================== 录制回放 ====================

    def record(self, output: str) -> Dict[str, Any]:
        """开始录制"""
        return self._execute(f"record --output '{output}'")

    def replay(self, input_file: str) -> Dict[str, Any]:
        """回放录制"""
        return self._execute(f"replay --input '{input_file}'")

    # ==================== OCR 与视觉定位 ====================

    def ocr(self, app: Optional[str] = None, image: Optional[str] = None) -> Dict[str, Any]:
        """OCR 识别"""
        cmd = "ocr"
        if app:
            cmd += f" --app '{app}'"
        if image:
            cmd += f" --image '{image}'"
        return self._execute(cmd)

    def find_image(self, template: str, threshold: float = 0.8) -> Dict[str, Any]:
        """查找图片"""
        return self._execute(f"find-image --template '{template}' --threshold {threshold}")

    def click_image(self, template: str, threshold: float = 0.8) -> Dict[str, Any]:
        """点击图片"""
        return self._execute(f"click-image --template '{template}' --threshold {threshold}")

    # ==================== 文件对话框 ====================

    def dialog_open(self, app: str, path: Optional[str] = None) -> Dict[str, Any]:
        """触发打开文件对话框"""
        cmd = f"dialog-open --app '{app}'"
        if path:
            cmd += f" --path '{path}'"
        return self._execute(cmd)

    def dialog_save(self, app: str, filename: Optional[str] = None) -> Dict[str, Any]:
        """触发保存文件对话框"""
        cmd = f"dialog-save --app '{app}'"
        if filename:
            cmd += f" --filename '{filename}'"
        return self._execute(cmd)

    # ==================== 测试报告 ====================

    def test_start(self, name: str, test_id: Optional[str] = None) -> Dict[str, Any]:
        """开始测试"""
        cmd = f"test-start --name '{name}'"
        if test_id:
            cmd += f" --id '{test_id}'"
        return self._execute(cmd)

    def test_end(self, result: str, reason: Optional[str] = None) -> Dict[str, Any]:
        """结束测试"""
        cmd = f"test-end --result '{result}'"
        if reason:
            cmd += f" --reason '{reason}'"
        return self._execute(cmd)

    def step(self, name: str, description: Optional[str] = None) -> Dict[str, Any]:
        """记录测试步骤"""
        cmd = f"step --name '{name}'"
        if description:
            cmd += f" --description '{description}'"
        return self._execute(cmd)

    # ==================== 进程管理 ====================

    def process_list(self, filter: Optional[str] = None) -> List[Dict[str, Any]]:
        """列出进程"""
        cmd = "process-list"
        if filter:
            cmd += f" --filter '{filter}'"
        result = self._execute(cmd)
        return result if isinstance(result, list) else []

    def process_kill(self, pid: int, force: bool = False) -> Dict[str, Any]:
        """结束进程"""
        cmd = f"process-kill {pid}"
        if force:
            cmd += " --force"
        return self._execute(cmd)


from pathlib import Path
