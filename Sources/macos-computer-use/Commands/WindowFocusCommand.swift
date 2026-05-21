//
//  WindowFocusCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct WindowFocusCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "window-focus",
        abstract: "聚焦窗口"
    )

    @Argument(help: "窗口 ID")
    var windowId: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = WindowManager.focus(windowId: windowId)

        if json {
            print("""
            {
              "success": \(result.success),
              "message": "\(result.message)"
            }
            """)
        } else {
            print(result.success ? "✓ \(result.message)" : "✗ \(result.message)")
        }
    }
}
