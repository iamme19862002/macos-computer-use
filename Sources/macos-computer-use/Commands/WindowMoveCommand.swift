//
//  WindowMoveCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import CoreGraphics

struct WindowMoveCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "window-move",
        abstract: "移动窗口位置"
    )

    @Argument(help: "窗口 ID")
    var windowId: Int

    @Option(name: .short, help: "X 坐标")
    var x: Int

    @Option(name: .short, help: "Y 坐标")
    var y: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = WindowManager.move(
            windowId: windowId,
            x: CGFloat(x),
            y: CGFloat(y)
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
