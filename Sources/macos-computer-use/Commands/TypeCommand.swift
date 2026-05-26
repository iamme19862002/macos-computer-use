//
//  TypeCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation
import AppKit

struct TypeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "type",
        abstract: "输入文本字符串，支持指定应用（使用剪贴板粘贴避免乱码）"
    )

    @Option(name: .shortAndLong, help: "要输入的文本")
    var text: String

    @Option(name: .long, help: "目标应用名称（可选，指定则发送到该应用进程并自动激活）")
    var app: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        // 如果指定了应用，先激活应用
        if let appName = app {
            let activateResult = AppManager.activate(appName: appName)
            if !activateResult.success {
                if json {
                    print("""
                    {
                      "success": false,
                      "message": "Failed to activate app: \(appName)"
                    }
                    """)
                } else {
                    print("✗ Failed to activate app: \(appName)")
                }
                return
            }
            // 等待应用完全激活
            try await Task.sleep(nanoseconds: 300_000_000)

            // 使用剪贴板粘贴方式发送文本（避免中文乱码）
            let success = pasteTextToProcess(appName: appName, text: text)
            if success {
                if json {
                    print("""
                    {
                      "success": true,
                      "action": "type",
                      "text": "\(text)",
                      "app": "\(appName)"
                    }
                    """)
                } else {
                    print("✓ Typed: \(text) -> \(appName)")
                }
            } else {
                if json {
                    print("""
                    {
                      "success": false,
                      "action": "type",
                      "text": "\(text)",
                      "app": "\(appName)",
                      "message": "Failed to paste text to process"
                    }
                    """)
                } else {
                    print("✗ Failed to type '\(text)' to \(appName)")
                }
            }
            return
        }

        // 全局输入：使用剪贴板粘贴
        pasteTextGlobally(text: text)

        if json {
            print("""
            {
              "success": true,
              "action": "type",
              "text": "\(text)"
            }
            """)
        } else {
            print("✓ Typed: \(text)")
        }
    }

    /// 使用剪贴板粘贴方式发送文本到指定进程（避免中文乱码）
    private func pasteTextToProcess(appName: String, text: String) -> Bool {
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")

        // 使用剪贴板粘贴方式：
        // 1. 将文本写入剪贴板
        // 2. 发送 Command+V 粘贴
        let script = """
        tell application "System Events"
            tell process "\(escapedAppName)"
                set frontmost to true
                set the clipboard to "\(escapedText)"
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

    /// 全局粘贴文本
    private func pasteTextGlobally(text: String) {
        // 将文本写入剪贴板
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // 发送 Command+V 粘贴
        if let vKey = KeyMap.cgKeyCode(for: "v") {
            KeyboardController.pressKeys([vKey, KeyMap.cgKeyCode(for: "command")!])
        }
    }
}
