//
//  WindowResizeCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import CoreGraphics

struct WindowResizeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "window-resize",
        abstract: "调整窗口大小"
    )

    @Argument(help: "窗口 ID")
    var windowId: Int

    @Option(name: .shortAndLong, help: "宽度")
    var width: Int

    @Option(name: .shortAndLong, help: "高度")
    var height: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = WindowManager.resize(
            windowId: windowId,
            width: CGFloat(width),
            height: CGFloat(height)
        )

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
