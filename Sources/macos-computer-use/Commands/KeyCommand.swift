//
//  KeyCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct KeyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "key",
        abstract: "按键或组合键（如 command+c, shift+tab），支持发送到指定应用"
    )

    @Option(name: .shortAndLong, help: "键名组合，用 + 连接（如 command+c）")
    var key: String

    @Option(name: .long, help: "目标应用名称（可选，指定则发送到该应用进程并自动激活）")
    var app: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        // 如果指定了应用，先激活应用再发送快捷键
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
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // 使用 AppleScript 发送到进程
            let success = sendKeyToProcess(appName: appName, key: key)
            if success {
                if json {
                    print("""
                    {
                      "success": true,
                      "action": "key",
                      "key": "\(key)",
                      "app": "\(appName)"
                    }
                    """)
                } else {
                    print("✓ Key pressed: \(key) -> \(appName)")
                }
            } else {
                if json {
                    print("""
                    {
                      "success": false,
                      "action": "key",
                      "key": "\(key)",
                      "app": "\(appName)",
                      "message": "Failed to send key to process"
                    }
                    """)
                } else {
                    print("✗ Failed to send key \(key) to \(appName)")
                }
            }
            return
        }

        // 全局快捷键
        let keyCodes = KeyboardController.parseKeys(key)

        guard !keyCodes.isEmpty else {
            throw ValidationError("Invalid key combination: \(key)")
        }

        KeyboardController.pressKeys(keyCodes)

        if json {
            print("""
            {
              "success": true,
              "action": "key",
              "key": "\(key)"
            }
            """)
        } else {
            print("✓ Key pressed: \(key)")
        }
    }

    /// 使用 AppleScript 发送快捷键到指定进程
    private func sendKeyToProcess(appName: String, key: String) -> Bool {
        let escapedAppName = appName.replacingOccurrences(of: "\"", with: "\\\"")

        // 解析键组合
        let parts = key.split(separator: "+").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        // 构建 AppleScript
        var script: String

        if parts.count == 1 {
            // 单键
            let keyChar = parts[0]
            
            // 检查是否是特殊键（需要使用 key code）
            if let keyCode = keyCodeForSpecialKey(keyChar) {
                // 使用 key code
                script = """
                tell application "System Events"
                    tell process "\(escapedAppName)"
                        set frontmost to true
                        key code \(keyCode)
                    end tell
                end tell
                """
            } else {
                // 使用普通 keystroke
                script = """
                tell application "System Events"
                    tell process "\(escapedAppName)"
                        set frontmost to true
                        keystroke "\(keyChar)"
                    end tell
                end tell
                """
            }
        } else {
            // 组合键
            let modifiers = parts.dropLast()
            let mainKey = parts.last!

            var modifierList: [String] = []
            for mod in modifiers {
                switch mod {
                case "command", "cmd":
                    modifierList.append("command down")
                case "shift":
                    modifierList.append("shift down")
                case "option", "alt":
                    modifierList.append("option down")
                case "control", "ctrl":
                    modifierList.append("control down")
                default:
                    break
                }
            }

            let modifierString = modifierList.joined(separator: ", ")
            
            // 检查主键是否是特殊键
            if let keyCode = keyCodeForSpecialKey(mainKey) {
                // 特殊键使用 key code
                script = """
                tell application "System Events"
                    tell process "\(escapedAppName)"
                        set frontmost to true
                        key code \(keyCode) using {\(modifierString)}
                    end tell
                end tell
                """
            } else {
                // 普通键使用 keystroke
                script = """
                tell application "System Events"
                    tell process "\(escapedAppName)"
                        set frontmost to true
                        keystroke "\(mainKey)" using {\(modifierString)}
                    end tell
                end tell
                """
            }
        }

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

    /// 将特殊键名转换为 AppleScript key code
    private func keyCodeForSpecialKey(_ key: String) -> Int? {
        switch key {
        case "return", "enter":
            return 36
        case "tab":
            return 48
        case "space":
            return 49
        case "escape", "esc":
            return 53
        case "delete", "backspace":
            return 51
        case "forwarddelete", "del":
            return 117
        case "home":
            return 115
        case "end":
            return 119
        case "pageup":
            return 116
        case "pagedown":
            return 121
        case "up":
            return 126
        case "down":
            return 125
        case "left":
            return 123
        case "right":
            return 124
        default:
            return nil
        }
    }
}
