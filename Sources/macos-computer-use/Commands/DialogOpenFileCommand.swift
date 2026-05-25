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

    func run() async throws {
        // 步骤 1: 激活应用
        let activateResult = AppManager.activate(appName: app)
        if !activateResult.success {
            printResult(success: false, message: "无法激活应用: \(app)")
            return
        }
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        
        // 步骤 2: 打开「前往文件夹」对话框 (Command+Shift+G)
        let keys = KeyboardController.parseKeys("command+shift+g")
        guard !keys.isEmpty else {
            printResult(success: false, message: "无法解析快捷键")
            return
        }
        KeyboardController.pressKeys(keys)
        
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8秒，等待对话框打开
        
        // 步骤 3: 输入文件路径
        KeyboardController.typeText(path)
        
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
        
        // 步骤 4: 按回车确认路径
        if let returnKey = KeyMap.cgKeyCode(for: "return") {
            KeyboardController.pressKeys([returnKey])
        }
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒，等待文件被选中
        
        // 步骤 5: 再次按回车确认选择文件
        if let returnKey = KeyMap.cgKeyCode(for: "return") {
            KeyboardController.pressKeys([returnKey])
        }
        
        printResult(success: true, message: "已选择文件: \(path)")
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
