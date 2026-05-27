//
//  DialogOpenFileCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation
import ApplicationServices
import AppKit

struct DialogOpenFileCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dialog-open-file",
        abstract: "在系统文件选择器中自动选择文件（使用「前往文件夹」功能）"
    )

    @Option(name: .long, help: "目标应用名称")
    var app: String

    @Option(name: .long, help: "要选择的文件完整路径")
    var path: String

    @Option(name: .long, help: "点击按钮打开文件选择器（按钮标题，如：添加文件）")
    var button: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    @Option(name: .long, help: "每个步骤的超时时间（秒，默认：5）")
    var timeout: Int = 5

    func run() async throws {
        // 1. 激活应用
        let activateResult = AppManager.activate(appName: app)
        if !activateResult.success {
            printResult(success: false, message: "无法激活应用: \(app)")
            return
        }

        try await Task.sleep(nanoseconds: 800_000_000)

        _ = AppManager.activate(appName: app)
        try await Task.sleep(nanoseconds: 300_000_000)

        // 2. 如果指定了按钮，先点击按钮打开文件选择器
        if let buttonTitle = button {
            printResult(success: true, message: "正在查找并点击按钮: \(buttonTitle)")
            let buttonClicked = clickButton(title: buttonTitle)
            if !buttonClicked {
                printResult(success: false, message: "无法点击按钮: \(buttonTitle)，请确认按钮标题正确")
                return
            }
            printResult(success: true, message: "按钮已点击，等待文件选择器...")

            // 等待文件选择器出现
            let fileDialogAppeared = await waitForFileDialog(timeout: timeout)
            if !fileDialogAppeared {
                printResult(success: false, message: "文件选择器未在 \(timeout) 秒内出现")
                return
            }
            printResult(success: true, message: "文件选择器已出现")

            try await Task.sleep(nanoseconds: 500_000_000)
        }

        // 3. 检测文件选择器是否已打开（支持文件选择器已打开或未打开的情况）
        _ = isFileDialogOpen()

        // 4. 发送 Cmd+Shift+G 打开「前往文件夹」对话框
        // 无论文件选择器是否已打开，都需要打开「前往文件夹」对话框来输入路径
        let shortcutSent = sendGoToFolderShortcut(appName: app)
        if !shortcutSent {
            printResult(success: false, message: "无法发送「前往文件夹」快捷键")
            return
        }

        // 5. 等待「前往文件夹」输入框出现并确保聚焦
        let inputBoxReady = await waitForInputBoxAndFocus(timeout: timeout)
        if !inputBoxReady {
            printResult(success: false, message: "路径输入框未就绪")
            return
        }

        // 6. 输入文件路径（使用剪贴板粘贴确保中文路径正确）
        // 先确保输入框聚焦
        let textFieldResults = AccessibilityManager.findElements(byRole: "textfield", inApp: app)
        if let firstTextField = textFieldResults.first {
            _ = AccessibilityManager.clickElement(firstTextField.element)
            try await Task.sleep(nanoseconds: 200_000_000)
        }
        
        let pasteSuccess = pasteTextToProcess(appName: app, text: path)
        if !pasteSuccess {
            // 降级方案：直接输入
            let textSent = sendTextToProcess(appName: app, text: path)
            if !textSent {
                KeyboardController.typeText(path)
            }
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        // 7. 按回车确认路径
        sendKeyToProcess(appName: app, key: "return")

        // 7. 等待文件选择器跳转到目标文件夹
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // 8. 再次按回车确认选择文件
        sendKeyToProcess(appName: app, key: "return")

        // 9. 最终验证：检查文件选择器是否关闭
        try await Task.sleep(nanoseconds: 500_000_000)
        let fileDialogClosed = await verifyFileDialogClosed()

        if fileDialogClosed {
            printResult(success: true, message: "已选择文件: \(path)")
        } else {
            printResult(success: false, message: "文件选择可能未完成，对话框未关闭")
        }
    }

    private func clickButton(title: String) -> Bool {
        // 方法1: 使用 AccessibilityManager.findElements 查找按钮（同时匹配 title、value、description）
        let results = AccessibilityManager.findElements(
            byRole: "button",
            byTitle: title,
            inApp: app
        )
        
        if let firstButton = results.first {
            return AccessibilityManager.clickElement(firstButton.element)
        }
        
        // 方法2: 使用 description 查找（有些按钮 title 为空，但 description 有值）
        let resultsByDescription = AccessibilityManager.findElements(
            byRole: "button",
            byDescription: title,
            inApp: app
        )
        
        if let firstButton = resultsByDescription.first {
            return AccessibilityManager.clickElement(firstButton.element)
        }
        
        return false
    }

    private func waitForFileDialog(timeout: Int) async -> Bool {
        let startTime = Date()
        let checkInterval: UInt64 = 300_000_000  // 300ms
        
        while Date().timeIntervalSince(startTime) < Double(timeout) {
            // 检查文件选择器是否打开（使用多种方法）
            if isFileDialogOpen() {
                return true
            }
            
            try? await Task.sleep(nanoseconds: checkInterval)
        }
        return false
    }

    private func isFileDialogOpen() -> Bool {
        // 方法1: 使用 AccessibilityManager.findElements 查找 Sheet（与 element-find --role sheet 一致）
        let sheetResults = AccessibilityManager.findElements(byRole: "sheet", inApp: app)
        if !sheetResults.isEmpty {
            return true
        }
        
        // 方法2: 使用 AccessibilityManager.findElements 查找 Panel/Dialog
        let dialogResults = AccessibilityManager.findElements(byRole: "dialog", inApp: app)
        if !dialogResults.isEmpty {
            return true
        }

        // 方法3: 使用 findPanelElements 和 findSheetElements（备选）
        let panels = AccessibilityManager.findPanelElements(inApp: app)
        if !panels.isEmpty {
            return true
        }

        let sheets = AccessibilityManager.findSheetElements(inApp: app)
        if !sheets.isEmpty {
            return true
        }

        // 方法4: 检查窗口列表中的标题
        if let windowList = getWindowList() {
            for window in windowList {
                if let title = window["title"] as? String {
                    let lowerTitle = title.lowercased()
                    if lowerTitle.contains("打开") || lowerTitle.contains("open") ||
                       lowerTitle.contains("保存") || lowerTitle.contains("save") ||
                       lowerTitle.contains("选择") || lowerTitle.contains("choose") {
                        if let ownerName = window[kCGWindowOwnerName as String] as? String,
                           ownerName.lowercased().contains(app.lowercased()) {
                            return true
                        }
                    }
                }
            }
        }

        return false
    }

    private func sendGoToFolderShortcut(appName: String) -> Bool {
        // 方法1: 使用 AppleScript 发送快捷键
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "System Events"
            tell process "\(escapedAppName)"
                set frontmost to true
                keystroke "g" using {command down, shift down}
            end tell
        end tell
        """

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus == 0 {
                return true
            }
        } catch {
            // 失败时尝试方法2
        }

        // 方法2: 使用 CGEvent 发送快捷键
        return sendGoToFolderShortcutViaCGEvent()
    }

    private func sendGoToFolderShortcutViaCGEvent() -> Bool {
        // 发送 Command+Shift+G
        let keyG: CGKeyCode = 5  // 'g' key
        let commandKey: CGEventFlags = .maskCommand
        let shiftKey: CGEventFlags = .maskShift

        // 创建按键按下事件
        guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyG, keyDown: true) else {
            return false
        }
        keyDown.flags = [commandKey, shiftKey]

        // 创建按键释放事件
        guard let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyG, keyDown: false) else {
            return false
        }
        keyUp.flags = []

        // 发送事件
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)

        return true
    }

    private func sendTextToProcess(appName: String, text: String) -> Bool {
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "System Events"
            tell process "\(escapedAppName)"
                keystroke "\(escapedText)"
            end tell
        end tell
        """

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func pasteTextToProcess(appName: String, text: String) -> Bool {
        // 使用剪贴板粘贴，确保中文路径正确输入
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")

        // 先将文本复制到剪贴板
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        // 使用 AppleScript 粘贴
        let script = """
        tell application "System Events"
            tell process "\(escapedAppName)"
                keystroke "v" using {command down}
            end tell
        end tell
        """

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func sendKeyToProcess(appName: String, key: String) {
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        let script: String
        if key == "return" {
            script = """
            tell application "System Events"
                tell process "\(escapedAppName)"
                    key code 36
                end tell
            end tell
            """
        } else {
            script = """
            tell application "System Events"
                tell process "\(escapedAppName)"
                    keystroke "\(key)"
                end tell
            end tell
            """
        }

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            if let keyCode = KeyMap.cgKeyCode(for: key) {
                KeyboardController.pressKeys([keyCode])
            }
        }
    }

    private func waitForGoToFolderDialog(timeout: Int) async -> Bool {
        let startTime = Date()

        let initialTextFieldCount = countTextFieldsInSheetsAndPanels()

        while Date().timeIntervalSince(startTime) < Double(timeout) {
            // 方法1: 检测窗口标题
            if let windowList = getWindowList() {
                for window in windowList {
                    if let title = window["title"] as? String {
                        if title.contains("前往") || title.contains("Go To") ||
                           title.contains("Go to") || title.contains("转到") ||
                           title.contains("前往文件夹") || title.contains("Go to Folder") {
                            return true
                        }
                    }
                }
            }

            // 方法2: 检测文本输入框数量增加（「前往文件夹」对话框包含文本输入框）
            let currentTextFieldCount = countTextFieldsInSheetsAndPanels()
            if currentTextFieldCount > initialTextFieldCount {
                return true
            }

            // 方法3: 直接检测是否有可编辑的文本框出现
            if hasEditableTextFieldInForeground() {
                return true
            }

            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return false
    }

    private func hasEditableTextFieldInForeground() -> Bool {
        let appElements = AccessibilityManager.findAppElements(named: app)
        guard !appElements.isEmpty else {
            return false
        }

        for appElement in appElements {
            var focusedElement: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
            if result == .success, let element = focusedElement as! AXUIElement? {
                var role: CFTypeRef?
                if AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role) == .success,
                   let roleStr = role as? String {
                    if roleStr == "AXTextField" || roleStr == "AXComboBox" {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func waitForInputBoxAndFocus(timeout: Int) async -> Bool {
        let startTime = Date()
        let checkInterval: UInt64 = 300_000_000  // 300ms
        
        while Date().timeIntervalSince(startTime) < Double(timeout) {
            // 方法1: 使用 AccessibilityManager.findElements 查找文本框（最可靠）
            let textFieldResults = AccessibilityManager.findElements(byRole: "textfield", inApp: app)
            if !textFieldResults.isEmpty {
                // 找到文本框，确保聚焦
                if let firstTextField = textFieldResults.first {
                    _ = AccessibilityManager.clickElement(firstTextField.element)
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
                return true
            }
            
            // 方法2: 检测是否有可编辑的文本框出现
            if hasEditableTextFieldInForeground() {
                try? await Task.sleep(nanoseconds: 100_000_000)
                return true
            }
            
            // 方法3: 检测「前往文件夹」对话框标题
            if let windowList = getWindowList() {
                for window in windowList {
                    if let title = window["title"] as? String {
                        if title.contains("前往") || title.contains("Go To") ||
                           title.contains("Go to") || title.contains("转到") ||
                           title.contains("前往文件夹") || title.contains("Go to Folder") {
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            return true
                        }
                    }
                }
            }
            
            try? await Task.sleep(nanoseconds: checkInterval)
        }
        
        // 超时后，如果已经有文本框，也认为是成功的
        let finalResults = AccessibilityManager.findElements(byRole: "textfield", inApp: app)
        if !finalResults.isEmpty {
            // 确保聚焦
            if let firstTextField = finalResults.first {
                _ = AccessibilityManager.clickElement(firstTextField.element)
            }
            return true
        }
        
        return false
    }

    private func countTextFieldsInSheetsAndPanels() -> Int {
        var count = 0

        let appElements = AccessibilityManager.findAppElements(named: app)
        guard !appElements.isEmpty else {
            return 0
        }

        for appElement in appElements {
            var windows: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windows)
            guard result == .success, let windowArray = windows as? [AXUIElement] else {
                continue
            }

            for window in windowArray {
                var sheets: CFTypeRef?
                if AXUIElementCopyAttributeValue(window, kAXSheetAttribute as CFString, &sheets) == .success,
                   let sheetArray = sheets as? [AXUIElement] {
                    for sheet in sheetArray {
                        count += countTextFieldsInElement(sheet)
                    }
                }

                var role: CFTypeRef?
                let roleResult = AXUIElementCopyAttributeValue(window, kAXRoleAttribute as CFString, &role)
                if roleResult == .success, let roleStr = role as? String, roleStr == "AXSheet" {
                    count += countTextFieldsInElement(window)
                }
            }
        }

        return count
    }

    private func countTextFieldsInElement(_ element: AXUIElement) -> Int {
        var count = 0

        var role: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role) == .success,
           let roleStr = role as? String {
            if roleStr == "AXTextField" || roleStr == "AXComboBox" {
                count += 1
            }
        }

        var children: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children) == .success,
           let childArray = children as? [AXUIElement] {
            for child in childArray {
                count += countTextFieldsInElement(child)
            }
        }

        return count
    }

    private func getWindowList() -> [[String: Any]]? {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowList = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        return windowList as? [[String: Any]]
    }

    private func verifyFileDialogClosed() async -> Bool {
        let panels = AccessibilityManager.findPanelElements(inApp: app)
        let sheets = AccessibilityManager.findSheetElements(inApp: app)
        return panels.isEmpty && sheets.isEmpty
    }

    private func printResult(success: Bool, message: String) {
        if json {
            print("""
            {
              "success": \(success),
              "message": "\(message)"
            }
            """)
        } else {
            print(success ? "✓ \(message)" : "✗ \(message)")
        }
    }
}
