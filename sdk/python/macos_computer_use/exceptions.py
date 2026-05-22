#
#  exceptions.py
#  macos-computer-use Python SDK
#
#  Created by macos-computer-use authors on 2026.
#  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
#  Licensed under the MIT License.
#

"""
SDK 异常定义
"""


class MacOSComputerUseError(Exception):
    """基础异常类"""
    pass


class CommandNotFoundError(MacOSComputerUseError):
    """命令未找到"""
    pass


class CommandExecutionError(MacOSComputerUseError):
    """命令执行失败"""

    def __init__(self, message: str, exit_code: int = None, stderr: str = None):
        super().__init__(message)
        self.exit_code = exit_code
        self.stderr = stderr


class TimeoutError(MacOSComputerUseError):
    """执行超时"""
    pass
