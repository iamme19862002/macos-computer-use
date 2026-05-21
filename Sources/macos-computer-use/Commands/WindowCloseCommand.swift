//
//  WindowCloseCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct WindowCloseCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "window-close",
        abstract: "关闭窗口"
    )

    @Argument(help: "窗口 ID")
    var windowId: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = WindowManager.close(windowId: windowId)

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
