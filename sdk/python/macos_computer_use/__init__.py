#
#  macos_computer_use Python SDK
#  macos-computer-use
#
#  Created by macos-computer-use authors on 2026.
#  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
#  Licensed under the MIT License.
#

"""
macos-computer-use Python SDK

Official Python wrapper for the macos-computer-use CLI tool.
Provides a high-level API for AI Agents to control macOS.

Example:
    from macos_computer_use import MacOSComputerUse

    mcu = MacOSComputerUse()
    mcu.app_launch("Safari")
    mcu.browser_navigate("https://example.com")
    mcu.screenshot()
"""

__version__ = "3.3.0"

from .client import MacOSComputerUse
from .exceptions import (
    MacOSComputerUseError,
    CommandNotFoundError,
    CommandExecutionError,
    TimeoutError,
)

__all__ = [
    "MacOSComputerUse",
    "MacOSComputerUseError",
    "CommandNotFoundError",
    "CommandExecutionError",
    "TimeoutError",
]
