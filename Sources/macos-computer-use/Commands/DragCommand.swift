//
//  DragCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import CoreGraphics

struct DragCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "drag",
        abstract: "从当前位置拖拽到目标坐标"
    )

    @Option(name: .long, help: "目标 X 坐标")
    var toX: Int

    @Option(name: .long, help: "目标 Y 坐标")
    var toY: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let from = MouseController.currentPosition()
        let to = CGPoint(x: toX, y: toY)
        MouseController.drag(from: from, to: to)

        if json {
            print("""
            {
              "success": true,
              "action": "left_click_drag",
              "from": [\(Int(from.x)), \(Int(from.y))],
              "to": [\(toX), \(toY)]
            }
            """)
        } else {
            print("✓ Dragged from (\(Int(from.x)), \(Int(from.y))) to (\(toX), \(toY))")
        }
    }
}
