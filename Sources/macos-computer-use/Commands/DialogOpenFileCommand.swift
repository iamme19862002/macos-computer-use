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
        // 0. 验证文件是否存在
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            printResult(success: false, message: "文件不存在: \(path)")
            return
        }
        
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

        // 4. 检查「前往文件夹」是否已打开，如果已打开则先 ESC 退出
        // 先激活应用，确保能正确查找到元素
        _ = AppManager.activate(appName: app)
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // 检查「前往文件夹」是否已打开：查找在 sheet/dialog 中的 textfield
        let goToFolderOpen = isGoToFolderOpen(appName: app)
        if goToFolderOpen {
            // 「前往文件夹」已打开，先 ESC 退出
            printResult(success: true, message: "检测到「前往文件夹」已打开，先 ESC 退出")
            sendKeyToProcess(appName: app, key: "esc")
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        // 5. 发送 Cmd+Shift+G 打开「前往文件夹」对话框
        let shortcutSent = sendGoToFolderShortcut(appName: app)
        if !shortcutSent {
            printResult(success: false, message: "无法发送「前往文件夹」快捷键")
            return
        }

        // 6. 等待「前往文件夹」输入框出现并确保聚焦
        let inputBoxReady = await waitForInputBoxAndFocus(timeout: timeout)
        if !inputBoxReady {
            printResult(success: false, message: "路径输入框未就绪")
            return
        }

        // 7. 输入文件路径
        inputPathUsingPaste(appName: app, path: path)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 验证输入是否成功
        let inputSuccess = verifyInputValue(appName: app, expectedValue: path)
        if !inputSuccess {
            printResult(success: false, message: "路径输入失败：无法将路径输入到文件选择器")
            return
        }
        try await Task.sleep(nanoseconds: 500_000_000)

        // 7. 按回车确认路径
        sendKeyToProcess(appName: app, key: "return")

        // 8. 等待文件选择器跳转到目标文件夹
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // 9. 再次按回车确认选择文件
        sendKeyToProcess(appName: app, key: "return")

        // 10. 最终验证：检查文件选择器是否关闭
        try await Task.sleep(nanoseconds: 500_000_000)
        let fileDialogClosed = await verifyFileDialogClosed()

        if fileDialogClosed {
            printResult(success: true, message: "已选择文件: \(path)")
        } else {
            printResult(success: false, message: "文件选择失败：对话框未关闭，请检查路径是否正确")
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
            
            // 额外检查：直接使用 findElements 查找 sheet（与 element-find --role sheet 一致）
            let sheetResults = AccessibilityManager.findElements(byRole: "sheet", inApp: app)
            if !sheetResults.isEmpty {
                return true
            }
            
            try? await Task.sleep(nanoseconds: checkInterval)
        }
        
        // 超时后再次检查
        let finalSheets = AccessibilityManager.findElements(byRole: "sheet", inApp: app)
        if !finalSheets.isEmpty {
            return true
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

    private func isGoToFolderOpen(appName: String) -> Bool {
        // 检查「前往文件夹」是否已打开
        // 「前往文件夹」在 SwiftUI 应用中是一个独立的 sheet，ID 为 "GoToWindow"
        // 与文件选择器的 "open-panel" sheet 不同
        
        let sheetResults = AccessibilityManager.findElements(byRole: "sheet", inApp: appName)
        for sheet in sheetResults {
            if sheet.info.identifier == "GoToWindow" {
                return true
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

    private func clearAndInputPath(appName: String, path: String) -> Bool {
        // 方法1: ESC退出 + Cmd+Shift+G重新打开（自动全选）+ 粘贴
        if escAndReopenThenInput(appName: appName, path: path) {
            Thread.sleep(forTimeInterval: 0.3)
            if verifyInputValue(appName: appName, expectedValue: path) {
                return true
            }
        }
        
        // 方法2: 点击清空按钮 + 输入新路径
        printResult(success: false, message: "ESC重开方法失败，尝试清空按钮")
        if clickClearButtonAndInput(appName: appName, path: path) {
            Thread.sleep(forTimeInterval: 0.3)
            if verifyInputValue(appName: appName, expectedValue: path) {
                return true
            }
        }
        
        // 方法3: 使用 AppleScript 直接设置文本框的值
        printResult(success: false, message: "清空按钮方法失败，尝试 AppleScript 直接设置")
        if setTextFieldValueUsingAppleScript(appName: appName, value: path) {
            Thread.sleep(forTimeInterval: 0.3)
            if verifyInputValue(appName: appName, expectedValue: path) {
                return true
            }
        }
        
        // 方法4: 使用 Cmd+A + 剪贴板粘贴
        printResult(success: false, message: "AppleScript 直接设置失败，尝试剪贴板粘贴")
        inputPathUsingPaste(appName: appName, path: path)
        Thread.sleep(forTimeInterval: 0.3)
        return verifyInputValue(appName: appName, expectedValue: path)
    }
    
    private func escAndReopenThenInput(appName: String, path: String) -> Bool {
        // 设置剪贴板
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        
        // 检查「前往文件夹」输入框是否已经打开
        let textFieldResults = AccessibilityManager.findElements(byRole: "textfield", inApp: appName)
        let goToFolderOpen = !textFieldResults.isEmpty
        
        var script: String
        if goToFolderOpen {
            // 「前往文件夹」已打开：ESC退出 + Cmd+Shift+G重新打开 + 粘贴
            script = """
            tell application "System Events"
                tell process "\(escapedAppName)"
                    set frontmost to true
                    delay 0.2
                    -- ESC退出当前「前往文件夹」对话框
                    key code 53
                    delay 0.3
                    -- Cmd+Shift+G重新打开（会自动全选）
                    keystroke "g" using {command down, shift down}
                    delay 0.3
                    -- 粘贴（替换全选的内容）
                    keystroke "v" using command down
                    delay 0.3
                end tell
            end tell
            """
        } else {
            // 「前往文件夹」未打开：直接 Cmd+Shift+G打开 + 粘贴
            script = """
            tell application "System Events"
                tell process "\(escapedAppName)"
                    set frontmost to true
                    delay 0.2
                    -- Cmd+Shift+G打开（会自动全选）
                    keystroke "g" using {command down, shift down}
                    delay 0.3
                    -- 粘贴（替换全选的内容）
                    keystroke "v" using command down
                    delay 0.3
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
            return task.terminationStatus == 0
        } catch {
            printResult(success: false, message: "ESC重开方法失败: \(error)")
            return false
        }
    }
    
    private func clickClearButtonAndInput(appName: String, path: String) -> Bool {
        // 查找清空按钮（通常是 button，description 包含 "清除" 或 "clear" 或显示为 X）
        let buttonResults = AccessibilityManager.findElements(byRole: "button", inApp: appName)
        
        // 查找可能是清空按钮的按钮（通常在文本框附近，且没有标题或描述）
        for button in buttonResults {
            var titleValue: CFTypeRef?
            var descriptionValue: CFTypeRef?
            
            AXUIElementCopyAttributeValue(button.element, kAXTitleAttribute as CFString, &titleValue)
            AXUIElementCopyAttributeValue(button.element, kAXDescriptionAttribute as CFString, &descriptionValue)
            
            let title = (titleValue as? String) ?? ""
            let description = (descriptionValue as? String) ?? ""
            
            // 清空按钮通常没有标题，或者描述包含 "clear" 或 "清除"
            if title.isEmpty || description.lowercased().contains("clear") || description.contains("清除") {
                let clickResult = AccessibilityManager.clickElement(button.element)
                if clickResult {
                    Thread.sleep(forTimeInterval: 0.3)
                    // 输入新路径
                    inputPathUsingPaste(appName: appName, path: path)
                    return true
                }
            }
        }
        
        return false
    }
    
    private func setTextFieldValueUsingAppleScript(appName: String, value: String) -> Bool {
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
        
        // 尝试直接设置文本框的值
        let script = """
        tell application "System Events"
            tell process "\(escapedAppName)"
                set frontmost to true
                delay 0.3
                tell text field 1 of sheet 1 of window 1
                    set value to "\(escapedValue)"
                end tell
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
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if task.terminationStatus == 0 {
                return true
            } else {
                printResult(success: false, message: "AppleScript 错误: \(output)")
                return false
            }
        } catch {
            printResult(success: false, message: "AppleScript 执行失败: \(error)")
            return false
        }
    }
    
    private func verifyInputValue(appName: String, expectedValue: String) -> Bool {
        // 多次尝试验证，因为输入可能有延迟
        for attempt in 1...3 {
            // 查找 PathTextField（「前往文件夹」输入框）
            let textFieldResults = AccessibilityManager.findElements(byRole: "textfield", inApp: appName)
            var pathTextField: AXUIElement?
            for result in textFieldResults {
                if result.info.identifier == "PathTextField" {
                    pathTextField = result.element
                    break
                }
            }
            
            guard let textField = pathTextField else {
                printResult(success: false, message: "验证失败：未找到「前往文件夹」输入框（尝试 \(attempt)/3）")
                Thread.sleep(forTimeInterval: 0.2)
                continue
            }
            
            var value: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(textField, kAXValueAttribute as CFString, &value)
            if result == .success, let stringValue = value as? String {
                // 允许部分匹配（因为路径可能被截断显示）
                let normalizedExpected = expectedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                let normalizedActual = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
                printResult(success: true, message: "验证尝试 \(attempt)/3: 期望值='\(normalizedExpected)', 实际值='\(normalizedActual)'")
                
                if normalizedActual == normalizedExpected {
                    printResult(success: true, message: "验证成功：路径完全匹配")
                    return true
                }
                
                // 检查是否包含关键部分（文件名）
                let expectedURL = URL(fileURLWithPath: normalizedExpected)
                let actualURL = URL(fileURLWithPath: normalizedActual)
                
                if expectedURL.lastPathComponent == actualURL.lastPathComponent {
                    printResult(success: true, message: "验证成功：文件名匹配")
                    return true
                }
                
                // 检查是否包含期望路径（部分匹配）
                if normalizedActual.contains(expectedURL.lastPathComponent) {
                    printResult(success: true, message: "验证成功：包含文件名")
                    return true
                }
                
                printResult(success: false, message: "验证失败：路径不匹配（尝试 \(attempt)/3）")
            } else {
                printResult(success: false, message: "验证失败：无法读取输入框值（尝试 \(attempt)/3），错误码: \(result.rawValue)")
            }
            
            if attempt < 3 {
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
        
        return false
    }
    
    private func inputPathUsingPaste(appName: String, path: String) {
        // 先聚焦 PathTextField（「前往文件夹」输入框）
        let textFieldResults = AccessibilityManager.findElements(byRole: "textfield", inApp: appName)
        for result in textFieldResults {
            if result.info.identifier == "PathTextField" {
                _ = AccessibilityManager.setFocus(result.element)
                Thread.sleep(forTimeInterval: 0.3)
                break
            }
        }
        
        // 使用剪贴板粘贴路径
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        
        // 方法: Cmd+A 全选 + Delete 删除 + 粘贴
        let script = """
        tell application "System Events"
            tell process "\(escapedAppName)"
                set frontmost to true
                delay 0.3
                -- Cmd+A 全选当前内容
                keystroke "a" using command down
                delay 0.2
                -- Delete 删除选中内容
                key code 51
                delay 0.2
                -- 粘贴（Cmd+V）
                keystroke "v" using command down
                delay 0.3
            end tell
        end tell
        """
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            printResult(success: false, message: "AppleScript 粘贴失败: \(error)")
        }
    }
    
    private func fallbackInputUsingKeystrokes(appName: String, path: String) {
        // 最后降级：直接逐个字符输入
        for char in path {
            if let keyCode = KeyMap.cgKeyCode(for: String(char)) {
                KeyboardController.pressKeys([keyCode])
            }
        }
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
                    set frontmost to true
                    key code 36
                end tell
            end tell
            """
        } else if key == "esc" {
            script = """
            tell application "System Events"
                tell process "\(escapedAppName)"
                    set frontmost to true
                    key code 53
                end tell
            end tell
            """
        } else {
            script = """
            tell application "System Events"
                tell process "\(escapedAppName)"
                    set frontmost to true
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
            // 查找 PathTextField（「前往文件夹」输入框）
            let textFieldResults = AccessibilityManager.findElements(byRole: "textfield", inApp: app)
            for result in textFieldResults {
                if result.info.identifier == "PathTextField" {
                    // 找到「前往文件夹」输入框，确保聚焦
                    _ = AccessibilityManager.setFocus(result.element)
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    return true
                }
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
        
        // 超时后，如果已经有 PathTextField，也认为是成功的
        let finalResults = AccessibilityManager.findElements(byRole: "textfield", inApp: app)
        for result in finalResults {
            if result.info.identifier == "PathTextField" {
                _ = AccessibilityManager.setFocus(result.element)
                return true
            }
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
