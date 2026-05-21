//
//  RightClickCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import CoreGraphics

struct RightClickCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "right-click",
        abstract: "右键点击（可选坐标）"
    )

    @Option(name: .short, help: "X 坐标（可选）")
    var x: Int?

    @Option(name: .short, help: "Y 坐标（可选）")
    var y: Int?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let point: CGPoint? = (x != nil && y != nil) ? CGPoint(x: x!, y: y!) : nil
        MouseController.rightClick(at: point)

        if json {
            if let px = x, let py = y {
                print("""
                {
                  "success": true,
                  "action": "right_click",
                  "coordinate": [\(px), \(py)]
                }
                """)
            } else {
                print("""
                {
                  "success": true,
                  "action": "right_click"
                }
                """)
            }
        } else {
            if let px = x, let py = y {
                print("✓ Right clicked at (\(px), \(py))")
            } else {
                print("✓ Right clicked at current position")
            }
        }
    }
}
