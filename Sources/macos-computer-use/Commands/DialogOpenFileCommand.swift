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

struct DialogOpenFileCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dialog-open-file",
        abstract: "在系统文件选择器中自动选择文件（使用「前往文件夹」功能）"
    )

    @Option(name: .long, help: "目标应用名称")
    var app: String

    @Option(name: .long, help: "要选择的文件完整路径")
    var path: String

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    @Option(name: .long, help: "每个步骤的超时时间（秒，默认：5）")
    var timeout: Int = 5

    func run() async throws {
        // 步骤 1: 激活应用（确保应用在前台）
        let activateResult = AppManager.activate(appName: app)
        if !activateResult.success {
            printResult(success: false, message: "无法激活应用: \(app)")
            return
        }
        
        // 额外等待确保应用完全激活
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // 步骤 2: 再次确保应用是前台（防止其他应用抢占焦点）
        _ = AppManager.activate(appName: app)
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // 步骤 3: 使用 AppleScript 发送 Cmd+Shift+G 到应用进程
        // 注意：必须使用 AppleScript 直接发送到进程，全局快捷键无法作用于系统文件选择器
        // AppleScript 中的 "set frontmost to true" 会确保目标进程接收快捷键
        let shortcutSent = sendGoToFolderShortcut(appName: app)
        if !shortcutSent {
            printResult(success: false, message: "无法发送「前往文件夹」快捷键")
            return
        }
        
        // 验证：等待「前往文件夹」对话框出现
        let goToFolderAppeared = await waitForGoToFolderDialog(timeout: timeout)
        if !goToFolderAppeared {
            printResult(success: false, message: "「前往文件夹」对话框未出现")
            return
        }
        
        // 步骤 4: 输入文件路径（使用 AppleScript 确保输入到正确位置）
        let textSent = sendTextToProcess(appName: app, text: path)
        if !textSent {
            // 回退到使用 KeyboardController
            KeyboardController.typeText(path)
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 步骤 5: 按回车确认路径
        sendKeyToProcess(appName: app, key: "return")

        // 等待文件选择器跳转到目标文件夹
        try await Task.sleep(nanoseconds: 1_500_000_000) // 等待1.5秒让文件选择器跳转

        // 步骤 6: 再次按回车确认选择文件
        sendKeyToProcess(appName: app, key: "return")
        
        // 最终验证：检查文件选择器是否关闭
        try await Task.sleep(nanoseconds: 500_000_000)
        let fileDialogClosed = await verifyFileDialogClosed()
        
        if fileDialogClosed {
            printResult(success: true, message: "已选择文件: \(path)")
        } else {
            printResult(success: false, message: "文件选择可能未完成，对话框未关闭")
        }
    }
    
    /// 使用 AppleScript 发送「前往文件夹」快捷键到指定进程
    private func sendGoToFolderShortcut(appName: String) -> Bool {
        // 转义应用名称中的双引号
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
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    /// 使用 AppleScript 发送文本到指定进程
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
    
    /// 使用 AppleScript 发送按键到指定进程
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
            // 忽略错误，回退到使用 KeyboardController
            if let keyCode = KeyMap.cgKeyCode(for: key) {
                KeyboardController.pressKeys([keyCode])
            }
        }
    }
    
    /// 等待「前往文件夹」对话框出现
    private func waitForGoToFolderDialog(timeout: Int) async -> Bool {
        let startTime = Date()
        
        // 记录初始状态：文件选择器打开前的文本输入框数量
        let initialTextFieldCount = countTextFieldsInSheets()
        
        while Date().timeIntervalSince(startTime) < Double(timeout) {
            // 方法1: 检查是否有包含「前往」或「Go To」标题的窗口
            if let windowList = getWindowList() {
                for window in windowList {
                    if let title = window["title"] as? String {
                        if title.contains("前往") || title.contains("Go To") ||
                           title.contains("Go to") || title.contains("转到") {
                            return true
                        }
                    }
                }
            }

            // 方法2: 检查 sheet 中的文本输入框数量是否增加
            // 「前往文件夹」对话框会添加一个新的文本输入框
            let currentTextFieldCount = countTextFieldsInSheets()
            if currentTextFieldCount > initialTextFieldCount {
                return true
            }

            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return false
    }

    /// 统计 sheet 中的文本输入框数量
    private func countTextFieldsInSheets() -> Int {
        var count = 0
        
        // 获取应用进程
        let appElements = AccessibilityManager.findAppElements(named: app)
        guard !appElements.isEmpty else {
            return 0
        }
        
        // 遍历每个应用实例
        for appElement in appElements {
            // 获取所有窗口
            var windows: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windows)
            guard result == .success, let windowArray = windows as? [AXUIElement] else {
                continue
            }
            
            // 遍历每个窗口的 sheet
            for window in windowArray {
                var sheets: CFTypeRef?
                if AXUIElementCopyAttributeValue(window, kAXSheetAttribute as CFString, &sheets) == .success,
                   let sheetArray = sheets as? [AXUIElement] {
                    for sheet in sheetArray {
                        count += countTextFieldsInElement(sheet)
                    }
                }
            }
        }
        
        return count
    }
    
    /// 统计元素中的文本输入框数量
    private func countTextFieldsInElement(_ element: AXUIElement) -> Int {
        var count = 0
        
        // 检查当前元素是否是文本输入框
        var role: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role) == .success,
           let roleStr = role as? String {
            if roleStr == "AXTextField" || roleStr == "AXComboBox" {
                count += 1
            }
        }
        
        // 递归检查子元素
        var children: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children) == .success,
           let childArray = children as? [AXUIElement] {
            for child in childArray {
                count += countTextFieldsInElement(child)
            }
        }
        
        return count
    }
    
    /// 获取窗口列表
    private func getWindowList() -> [[String: Any]]? {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowList = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        return windowList as? [[String: Any]]
    }
    
    /// 验证文件选择器是否已关闭
    private func verifyFileDialogClosed() async -> Bool {
        let sheets = AccessibilityManager.findSheetElements(inApp: app)
        return sheets.isEmpty
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
