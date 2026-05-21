//
//  MouseMoveCommand.swift
//  macos-computer-use
//
//  Created by iamme19862002 on 2025.
//  Copyright (c) 2025 iamme19862002. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct MouseMoveCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mouse-move",
        abstract: "移动鼠标到指定坐标"
    )

    @Option(name: .short, help: "X 坐标")
    var x: Int

    @Option(name: .short, help: "Y 坐标")
    var y: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        MouseController.moveTo(x: x, y: y)

        if json {
            print("""
            {
              "success": true,
              "action": "mouse_move",
              "coordinate": [\(x), \(y)]
            }
            """)
        } else {
            print("✓ Mouse moved to (\(x), \(y))")
        }
    }
}
