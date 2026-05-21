//
//  ScrollCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import CoreGraphics

struct ScrollCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "scroll",
        abstract: "在指定位置滚动"
    )

    @Option(name: .short, help: "X 坐标")
    var x: Int

    @Option(name: .short, help: "Y 坐标")
    var y: Int

    @Option(name: .shortAndLong, help: "滚动方向 (up/down/left/right)")
    var direction: String

    @Option(name: .shortAndLong, help: "滚动量（像素，默认 300）")
    var amount: Int = 300

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        guard let scrollDir = ScrollDirection(rawValue: direction.lowercased()) else {
            throw ValidationError("Invalid direction: \(direction). Use up, down, left, or right.")
        }

        let point = CGPoint(x: x, y: y)
        MouseController.scroll(at: point, direction: scrollDir, amount: amount)

        if json {
            print("""
            {
              "success": true,
              "action": "scroll",
              "coordinate": [\(x), \(y)],
              "direction": "\(direction)",
              "amount": \(amount)
            }
            """)
        } else {
            print("✓ Scrolled \(direction) by \(amount) pixels at (\(x), \(y))")
        }
    }
}
