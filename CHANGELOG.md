# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.1.0] - 2026-05-22

### Added

#### Assertion Commands (P0)
- `assert-element-exists` - Verify UI element presence with configurable timeout and polling
- `assert-text-exists` - OCR-based text verification on screen with region support
- `assert-element-property` - Verify element attributes (enabled, focused, value, visible)
- `assert-clipboard` - Verify clipboard content with contains/equals/not-empty modes

#### Control Flow Commands (P0)
- `retry` - Retry failed commands with configurable attempts and interval

#### Keyboard Enhancement (P0)
- `hotkey` - Send keyboard shortcuts (e.g., command+s, shift+tab)
- `key-sequence` - Send key sequences with delay support (e.g., vim operations)

#### Window Management Enhancement (P1)
- `window-maximize` - Maximize application windows

#### Mouse Enhancement (P1)
- `mouse-hover` - Hover over elements or coordinates with configurable duration

#### Test Reporting (P2)
- `test-start` - Mark test case beginning with metadata
- `test-end` - Mark test case end with result and reason
- `step` - Mark individual test steps

### Changed
- Updated version to 3.1.0
- All new commands support JSON output for AI Agent integration
- Improved error handling with descriptive messages

## [3.0.0] - 2026-05-21

### Added

#### Core Commands
- `screenshot` - Capture full screen, app window, or region
- `cursor-position` - Get current mouse coordinates
- `mouse-move` - Move mouse to absolute or relative position
- `left-click` / `right-click` / `middle-click` / `double-click` - Mouse click operations
- `drag` - Drag and drop between coordinates or elements
- `scroll` - Scroll at position with direction and amount

#### Keyboard Commands
- `key` - Press individual keys
- `type` - Type text into target elements

#### Application Management
- `app-launch` - Launch applications
- `app-quit` - Quit applications (with force option)
- `app-activate` - Bring application to foreground
- `app-hide` - Hide application
- `app-list` - List running applications

#### Window Management
- `window-list` - List all windows
- `window-resize` - Resize windows
- `window-move` - Move windows to position or center
- `window-minimize` - Minimize windows
- `window-close` - Close windows
- `window-focus` - Focus windows

#### UI Element Operations
- `element-find` - Find elements by role, title, identifier
- `element-click` - Click elements
- `element-info` - Get element information
- `element-list` - List all elements in application

#### Wait Mechanisms
- `wait-for-element` - Wait for element appearance/disappearance
- `wait-for-app` - Wait for application launch/exit
- `sleep` - Fixed duration sleep

#### Clipboard Operations
- `clipboard-copy` - Copy text to clipboard
- `clipboard-paste` - Paste from clipboard
- `clipboard-get` - Get clipboard content

#### System Information
- `screen-info` - Get screen information
- `display-list` - List all displays
- `system-info` - Get system information

#### Process Management
- `process-list` - List processes
- `process-kill` - Kill processes by name or PID

#### Recording and Playback
- `record` - Record user actions
- `replay` - Replay recorded actions

#### Script Execution
- `run-script` - Execute JSON script files

#### OCR and Visual Matching
- `ocr` - Optical character recognition
- `find-image` - Find image on screen
- `click-image` - Click found image

### Features
- Zero token overhead - all operations run locally
- JSON output support for all commands
- Accessibility API integration
- Vision framework for OCR
- Core Graphics for screen capture

## [2.0.0] - 2026-05-20

### Added
- Initial stable release with basic mouse and keyboard control
- Application launching and quitting
- Basic screenshot functionality

## [1.0.0] - 2026-05-19

### Added
- Project initialization
- Basic CLI structure with ArgumentParser
- Proof of concept for mouse movement

---

## Version History Summary

| Version | Date | Key Features |
|---------|------|--------------|
| 3.1.0 | 2026-05-22 | Assertions, hotkeys, test reporting, retry |
| 3.0.0 | 2026-05-21 | Full automation suite, OCR, recording |
| 2.0.0 | 2026-05-20 | Stable basic controls |
| 1.0.0 | 2026-05-19 | Initial release |
