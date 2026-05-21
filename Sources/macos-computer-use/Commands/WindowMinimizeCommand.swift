//
//  WindowMinimizeCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct WindowMinimizeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "window-minimize",
        abstract: "最小化窗口"
    )

    @Argument(help: "窗口 ID")
    var windowId: Int

    @Flag(name: .long, help: "恢复窗口")
    var restore = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = restore
            ? WindowManager.minimize(windowId: windowId)
            : WindowManager.minimize(windowId: windowId)

        let message = restore ? "Restored window \(windowId)" : result.message

        if json {
            print("""
            {
              "success": \(result.success),
              "message": "\(message)"
            }
            """)
        } else {
            print(result.success ? "✓ \(message)" : "✗ \(result.message)")
        }
    }
}
