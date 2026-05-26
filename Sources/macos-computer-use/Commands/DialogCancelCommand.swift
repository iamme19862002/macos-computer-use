//
//  DialogCancelCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct DialogCancelCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dialog-cancel",
        abstract: "取消或关闭系统文件选择器（发送 Escape 键）"
    )

    @Option(name: .long, help: "目标应用名称（可选，用于激活应用）")
    var app: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        // 如果指定了应用，先激活它
        if let appName = app {
            let activateResult = AppManager.activate(appName: appName)
            if !activateResult.success {
                printResult(success: false, message: "无法激活应用: \(appName)")
                return
            }
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
        }
        
        // 发送 Escape 键关闭文件选择器
        if let escapeKey = KeyMap.cgKeyCode(for: "escape") {
            KeyboardController.pressKeys([escapeKey])
            printResult(success: true, message: "已发送 Escape 键关闭文件选择器")
        } else {
            printResult(success: false, message: "无法发送 Escape 键")
        }
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
