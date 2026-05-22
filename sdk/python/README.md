# macos-computer-use Python SDK

Official Python SDK for [macos-computer-use](https://github.com/macos-computer-use/macos-computer-use) - macOS computer control for AI Agents.

## Installation

```bash
pip install macos-computer-use
```

## Quick Start

```python
from macos_computer_use import MacOSComputerUse

mcu = MacOSComputerUse()

# Screenshot
mcu.screenshot()

# Launch app
mcu.app_launch("Safari")
mcu.browser_navigate("https://example.com")

# File operations
mcu.file_write("~/hello.txt", text="Hello, World!")
content = mcu.file_read("~/hello.txt")

# UI automation
mcu.element_click("Safari", "地址栏")
mcu.type_text("https://apple.com")
mcu.key("return")

# Notifications
mcu.notify("Task Complete", message="Your automation has finished")
```

## Requirements

- macOS 11.0+
- Python 3.8+
- macos-computer-use CLI installed

## Documentation

See [智能体实战指南](https://github.com/macos-computer-use/macos-computer-use/blob/main/docs/智能体实战指南.md) for detailed usage.
